package com.smartcare.business.elder.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.smartcare.business.elder.domain.ElAiMonitorLog;
import com.smartcare.business.elder.domain.ElAlert;
import com.smartcare.business.elder.domain.ElCareOrder;
import com.smartcare.business.elder.domain.ElUtilityData;
import com.smartcare.business.elder.mapper.ElAiMonitorLogMapper;
import com.smartcare.business.elder.mapper.ElAlertMapper;
import com.smartcare.business.elder.mapper.ElCareOrderMapper;
import com.smartcare.business.elder.mapper.ElUtilityDataMapper;
import com.smartcare.business.property.domain.CmResident;
import com.smartcare.business.property.mapper.CmResidentMapper;
import com.smartcare.common.core.page.TableDataInfo;
import com.smartcare.framework.ai.ZhipuAiClient;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.*;
import java.util.stream.Collectors;

/**
 * 独居老人水电数据时序监测服务（方案B：仅水电 + 生活迹象推断）
 *
 * 检测规则：
 * 1. 生活迹象：近3小时用水用电均为零，且历史有正常模式 → 一级
 * 2. 连续24小时全零或无数据上报 → 一级
 * 3. 用餐时段（早/午/晚）用水异常偏低 → 二级
 * 4. 单项指标长时间为零（另一项正常）→ 二级
 * 5. 数据上报稀疏（可能设备异常）→ 二级
 * 6. 用量突增/突减（相对7日均值）→ 二级
 * 7. 单小时用量尖峰（超历史3倍）→ 二级
 * 8. 日间整体用量异常偏低 → 二级
 * 9. 夜间高用量 → 二级
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class ElUtilityMonitorService {

    private final ElUtilityDataMapper utilityDataMapper;
    private final ElAlertMapper alertMapper;
    private final ElCareOrderMapper careOrderMapper;
    private final CmResidentMapper residentMapper;
    private final ElAiMonitorLogMapper monitorLogMapper;
    private final ZhipuAiClient aiClient;
    private final JdbcTemplate jdbcTemplate;

    /** 无使用判定阈值（小于此值视为无使用） */
    private static final BigDecimal ZERO_THRESHOLD = new BigDecimal("0.01");
    /** 突增倍数阈值 */
    private static final double SURGE_MULTIPLIER = 2.0;
    /** 突减比例阈值 */
    private static final double DROP_MULTIPLIER = 0.5;
    /** 夜间小时列表（22,23,0,1,2,3,4） */
    private static final Set<Integer> NIGHT_HOURS = Set.of(22, 23, 0, 1, 2, 3, 4);
    /** 夜间高用量阈值：超过日间平均的1.5倍 */
    private static final double NIGHT_HIGH_MULTIPLIER = 1.5;
    /** 历史数据窗口（天）—— 用于计算平均值 */
    private static final int HISTORY_DAYS = 7;
    /** 生活迹象检测窗口（小时）—— 近 N 小时无用水用电且历史有正常模式 */
    private static final int ACTIVITY_WINDOW_HOURS = 3;
    /** 用餐时段小时 */
    private static final Set<Integer> MEAL_HOURS = Set.of(7, 8, 9, 11, 12, 13, 17, 18, 19);
    /** 日间小时 6-20 */
    private static final int DAY_START = 6;
    private static final int DAY_END = 20;
    /** 尖峰倍数 */
    private static final double SPIKE_MULTIPLIER = 3.0;
    /** 日间偏低比例 */
    private static final double DAY_LOW_RATIO = 0.3;

    // ==================== 核心异常检测 ====================

    /**
     * 对单个独居老人执行水电时序异常检测
     * 返回检测结果列表（可能有多个异常）
     */
    public List<Map<String, Object>> detectAnomalies(Long residentId) {
        List<Map<String, Object>> anomalies = new ArrayList<>();
        LocalDateTime now = LocalDateTime.now();

        // 获取近24小时数据
        List<ElUtilityData> recent24h = utilityDataMapper.selectList(
            new LambdaQueryWrapper<ElUtilityData>()
                .eq(ElUtilityData::getResidentId, residentId)
                .ge(ElUtilityData::getRecordTime, now.minusHours(24))
                .orderByAsc(ElUtilityData::getRecordTime)
        );

        // 获取历史数据（近7天，不含最近24小时）用于计算平均值
        List<ElUtilityData> historyData = utilityDataMapper.selectList(
            new LambdaQueryWrapper<ElUtilityData>()
                .eq(ElUtilityData::getResidentId, residentId)
                .ge(ElUtilityData::getRecordTime, now.minusDays(HISTORY_DAYS))
                .lt(ElUtilityData::getRecordTime, now.minusHours(24))
                .orderByAsc(ElUtilityData::getRecordTime)
        );

        // 规则2：连续24小时无用水用电
        Map<String, Object> noUsageAnomaly = checkNoUsage24h(recent24h, residentId);
        if (noUsageAnomaly != null) {
            anomalies.add(noUsageAnomaly);
        }

        // 规则1：近几小时无生活迹象（24h全零时不重复报）
        if (noUsageAnomaly == null) {
            Map<String, Object> livingSignAnomaly = checkNoLivingSign(recent24h, historyData, residentId, now);
            if (livingSignAnomaly != null) {
                anomalies.add(livingSignAnomaly);
            }
        }

        // 计算历史平均（分日间/夜间）
        BigDecimal histAvgWater = calcAverage(historyData, "water", null);
        BigDecimal histAvgElectric = calcAverage(historyData, "electric", null);
        BigDecimal histDaytimeAvgWater = calcAverage(historyData, "water", false);
        BigDecimal histDaytimeAvgElectric = calcAverage(historyData, "electric", false);

        Map<String, Object> mealAnomaly = checkMealTimeLowWater(recent24h, historyData, residentId);
        if (mealAnomaly != null) {
            anomalies.add(mealAnomaly);
        }

        Map<String, Object> partialZeroAnomaly = checkPartialUtilityZero(recent24h, historyData, residentId);
        if (partialZeroAnomaly != null) {
            anomalies.add(partialZeroAnomaly);
        }

        Map<String, Object> sparseAnomaly = checkSparseReporting(recent24h, residentId);
        if (sparseAnomaly != null) {
            anomalies.add(sparseAnomaly);
        }

        // 规则：突增（最近数据 vs 历史平均）
        Map<String, Object> surgeAnomaly = checkSurge(recent24h, histAvgWater, histAvgElectric, residentId);
        if (surgeAnomaly != null) {
            anomalies.add(surgeAnomaly);
        }

        // 规则：突减
        Map<String, Object> dropAnomaly = checkDrop(recent24h, histAvgWater, histAvgElectric, residentId);
        if (dropAnomaly != null) {
            anomalies.add(dropAnomaly);
        }

        Map<String, Object> spikeAnomaly = checkHourlySpike(recent24h, histAvgWater, histAvgElectric, residentId);
        if (spikeAnomaly != null) {
            anomalies.add(spikeAnomaly);
        }

        Map<String, Object> dayLowAnomaly = checkDaytimeAbnormalLow(recent24h, histDaytimeAvgWater, histDaytimeAvgElectric, residentId);
        if (dayLowAnomaly != null) {
            anomalies.add(dayLowAnomaly);
        }

        // 规则：夜间高用量
        Map<String, Object> nightAnomaly = checkNightHighUsage(recent24h, histDaytimeAvgWater, histDaytimeAvgElectric, residentId);
        if (nightAnomaly != null) {
            anomalies.add(nightAnomaly);
        }

        return anomalies;
    }

    /**
     * 生活迹象：近 ACTIVITY_WINDOW_HOURS 小时用水用电均为零，且历史存在正常用量模式
     */
    private Map<String, Object> checkNoLivingSign(List<ElUtilityData> recent24h, List<ElUtilityData> historyData,
                                                    Long residentId, LocalDateTime now) {
        LocalDateTime windowStart = now.minusHours(ACTIVITY_WINDOW_HOURS);
        List<ElUtilityData> recentWindow = recent24h.stream()
            .filter(d -> d.getRecordTime() != null && !d.getRecordTime().isBefore(windowStart))
            .toList();
        if (recentWindow.isEmpty()) {
            return null;
        }

        boolean allZero = recentWindow.stream().allMatch(d ->
            (d.getWaterUsage() == null || d.getWaterUsage().compareTo(ZERO_THRESHOLD) < 0)
                && (d.getElectricUsage() == null || d.getElectricUsage().compareTo(ZERO_THRESHOLD) < 0));
        if (!allZero) {
            return null;
        }

        BigDecimal histAvgWater = calcAverage(historyData, "water", null);
        BigDecimal histAvgElectric = calcAverage(historyData, "electric", null);
        boolean hasNormalPattern = histAvgWater.compareTo(ZERO_THRESHOLD) > 0
            || histAvgElectric.compareTo(ZERO_THRESHOLD) > 0;
        if (!hasNormalPattern) {
            return null;
        }

        Map<String, Object> anomaly = new LinkedHashMap<>();
        anomaly.put("type", "no_living_sign");
        anomaly.put("level", 1);
        anomaly.put("description", String.format(
            "【生活迹象】近%d小时用水、用电均接近零；对比近7天历史存在正常用量（水均%.2fL/h、电均%.2fkWh/h），疑似长时间无活动",
            ACTIVITY_WINDOW_HOURS, histAvgWater.doubleValue(), histAvgElectric.doubleValue()));
        anomaly.put("residentId", residentId);
        return anomaly;
    }

    /**
     * 规则2：检测连续24小时无用水用电
     */
    private Map<String, Object> checkNoUsage24h(List<ElUtilityData> recent24h, Long residentId) {
        if (recent24h.isEmpty()) {
            // 无数据也视为异常（可能设备离线）
            Map<String, Object> anomaly = new LinkedHashMap<>();
            anomaly.put("type", "no_usage_24h");
            anomaly.put("level", 1); // 高风险
            anomaly.put("description", "【数据缺失】连续24小时无水电数据上报，可能采集设备离线或通讯中断，需人工核查");
            anomaly.put("residentId", residentId);
            return anomaly;
        }

        // 检查所有24h内的数据是否都接近零
        boolean allZeroWater = recent24h.stream()
            .allMatch(d -> d.getWaterUsage() == null || d.getWaterUsage().compareTo(ZERO_THRESHOLD) < 0);
        boolean allZeroElectric = recent24h.stream()
            .allMatch(d -> d.getElectricUsage() == null || d.getElectricUsage().compareTo(ZERO_THRESHOLD) < 0);

        if (allZeroWater && allZeroElectric) {
            Map<String, Object> anomaly = new LinkedHashMap<>();
            anomaly.put("type", "no_usage_24h");
            anomaly.put("level", 1); // 高风险
            anomaly.put("description", String.format(
                "【生活迹象】连续24小时用水、用电均为零（共%d条记录）；对比历史存在正常模式，存在较高安全风险",
                recent24h.size()));
            anomaly.put("residentId", residentId);
            anomaly.put("dataPoints", recent24h.size());
            return anomaly;
        }
        return null;
    }

    /**
     * 规则2：检测水电用量突增（超过历史平均2倍）
     */
    private Map<String, Object> checkSurge(List<ElUtilityData> recent24h, BigDecimal histAvgWater, BigDecimal histAvgElectric, Long residentId) {
        if (recent24h.isEmpty() || (histAvgWater.compareTo(ZERO_THRESHOLD) < 0 && histAvgElectric.compareTo(ZERO_THRESHOLD) < 0)) {
            return null;
        }

        // 计算最近24h的平均值
        BigDecimal recentAvgWater = calcRecentAverage(recent24h, "water");
        BigDecimal recentAvgElectric = calcRecentAverage(recent24h, "electric");

        List<String> surges = new ArrayList<>();
        if (histAvgWater.compareTo(ZERO_THRESHOLD) > 0 &&
            recentAvgWater.compareTo(histAvgWater.multiply(BigDecimal.valueOf(SURGE_MULTIPLIER))) > 0) {
            surges.add(String.format("用水突增：近24h均%.2fL/h，高于7日基线%.2fL/h的200%%",
                recentAvgWater.doubleValue(), histAvgWater.doubleValue()));
        }
        if (histAvgElectric.compareTo(ZERO_THRESHOLD) > 0 &&
            recentAvgElectric.compareTo(histAvgElectric.multiply(BigDecimal.valueOf(SURGE_MULTIPLIER))) > 0) {
            surges.add(String.format("用电突增：近24h均%.2fkWh/h，高于7日基线%.2fkWh/h的200%%",
                recentAvgElectric.doubleValue(), histAvgElectric.doubleValue()));
        }

        if (!surges.isEmpty()) {
            Map<String, Object> anomaly = new LinkedHashMap<>();
            anomaly.put("type", "usage_surge");
            anomaly.put("level", 2);
            anomaly.put("description", "【用量异常】" + String.join("；", surges));
            anomaly.put("residentId", residentId);
            return anomaly;
        }
        return null;
    }

    /**
     * 规则3：检测水电用量突减（低于历史平均1/2）
     */
    private Map<String, Object> checkDrop(List<ElUtilityData> recent24h, BigDecimal histAvgWater, BigDecimal histAvgElectric, Long residentId) {
        if (recent24h.isEmpty() || (histAvgWater.compareTo(ZERO_THRESHOLD) < 0 && histAvgElectric.compareTo(ZERO_THRESHOLD) < 0)) {
            return null;
        }

        BigDecimal recentAvgWater = calcRecentAverage(recent24h, "water");
        BigDecimal recentAvgElectric = calcRecentAverage(recent24h, "electric");

        List<String> drops = new ArrayList<>();
        if (histAvgWater.compareTo(ZERO_THRESHOLD) > 0 &&
            recentAvgWater.compareTo(histAvgWater.multiply(BigDecimal.valueOf(DROP_MULTIPLIER))) < 0 &&
            recentAvgWater.compareTo(ZERO_THRESHOLD) > 0) { // 非零才算突减（零是no_usage规则）
            drops.add(String.format("用水突减：近24h均%.2fL/h，低于7日基线%.2fL/h的50%%",
                recentAvgWater.doubleValue(), histAvgWater.doubleValue()));
        }
        if (histAvgElectric.compareTo(ZERO_THRESHOLD) > 0 &&
            recentAvgElectric.compareTo(histAvgElectric.multiply(BigDecimal.valueOf(DROP_MULTIPLIER))) < 0 &&
            recentAvgElectric.compareTo(ZERO_THRESHOLD) > 0) {
            drops.add(String.format("用电突减：近24h均%.2fkWh/h，低于7日基线%.2fkWh/h的50%%",
                recentAvgElectric.doubleValue(), histAvgElectric.doubleValue()));
        }

        if (!drops.isEmpty()) {
            Map<String, Object> anomaly = new LinkedHashMap<>();
            anomaly.put("type", "usage_drop");
            anomaly.put("level", 2);
            anomaly.put("description", "【用量异常】" + String.join("；", drops));
            anomaly.put("residentId", residentId);
            return anomaly;
        }
        return null;
    }

    /**
     * 规则4：检测夜间（22:00-5:00）高用量异常
     */
    private Map<String, Object> checkNightHighUsage(List<ElUtilityData> recent24h, BigDecimal daytimeAvgWater, BigDecimal daytimeAvgElectric, Long residentId) {
        // 筛选夜间数据
        List<ElUtilityData> nightData = recent24h.stream()
            .filter(d -> d.getRecordTime() != null && NIGHT_HOURS.contains(d.getRecordTime().getHour()))
            .collect(Collectors.toList());

        if (nightData.isEmpty()) return null;

        BigDecimal nightAvgWater = calcRecentAverage(nightData, "water");
        BigDecimal nightAvgElectric = calcRecentAverage(nightData, "electric");

        List<String> nightIssues = new ArrayList<>();
        BigDecimal nightWaterThreshold = daytimeAvgWater.multiply(BigDecimal.valueOf(NIGHT_HIGH_MULTIPLIER));
        BigDecimal nightElectricThreshold = daytimeAvgElectric.multiply(BigDecimal.valueOf(NIGHT_HIGH_MULTIPLIER));

        if (daytimeAvgWater.compareTo(ZERO_THRESHOLD) > 0 && nightAvgWater.compareTo(nightWaterThreshold) > 0) {
            nightIssues.add(String.format("夜间用水偏高：22:00-5:00均%.2fL/h，为日间均值%.2fL/h的%.0f%%以上",
                nightAvgWater.doubleValue(), daytimeAvgWater.doubleValue(), NIGHT_HIGH_MULTIPLIER * 100));
        }
        if (daytimeAvgElectric.compareTo(ZERO_THRESHOLD) > 0 && nightAvgElectric.compareTo(nightElectricThreshold) > 0) {
            nightIssues.add(String.format("夜间用电偏高：22:00-5:00均%.2fkWh/h，为日间均值%.2fkWh/h的%.0f%%以上",
                nightAvgElectric.doubleValue(), daytimeAvgElectric.doubleValue(), NIGHT_HIGH_MULTIPLIER * 100));
        }

        if (!nightIssues.isEmpty()) {
            Map<String, Object> anomaly = new LinkedHashMap<>();
            anomaly.put("type", "night_high_usage");
            anomaly.put("level", 2);
            anomaly.put("description", "【用量异常】" + String.join("；", nightIssues));
            anomaly.put("residentId", residentId);
            return anomaly;
        }
        return null;
    }

    /** 用餐时段用水异常偏低（历史该时段有用水习惯） */
    private Map<String, Object> checkMealTimeLowWater(List<ElUtilityData> recent24h, List<ElUtilityData> historyData, Long residentId) {
        List<ElUtilityData> mealRecent = recent24h.stream()
            .filter(d -> d.getRecordTime() != null && MEAL_HOURS.contains(d.getRecordTime().getHour()))
            .toList();
        if (mealRecent.isEmpty()) {
            return null;
        }
        boolean mealAllLowWater = mealRecent.stream().allMatch(d ->
            d.getWaterUsage() == null || d.getWaterUsage().compareTo(ZERO_THRESHOLD) < 0);
        if (!mealAllLowWater) {
            return null;
        }
        BigDecimal histMealWater = calcAverage(
            historyData.stream().filter(d -> d.getRecordTime() != null && MEAL_HOURS.contains(d.getRecordTime().getHour())).toList(),
            "water", null);
        if (histMealWater.compareTo(BigDecimal.valueOf(2)) <= 0) {
            return null;
        }
        Map<String, Object> anomaly = new LinkedHashMap<>();
        anomaly.put("type", "meal_time_low");
        anomaly.put("level", 2);
        anomaly.put("description", String.format(
            "【生活迹象】早/午/晚用餐时段（7-9、11-13、17-19点）用水均为零；历史同期用水均%.2fL/h，偏离日常作息",
            histMealWater.doubleValue()));
        anomaly.put("residentId", residentId);
        return anomaly;
    }

    /** 单项指标12小时以上为零，另一项仍有用量 */
    private Map<String, Object> checkPartialUtilityZero(List<ElUtilityData> recent24h, List<ElUtilityData> historyData, Long residentId) {
        if (recent24h.size() < 12) {
            return null;
        }
        List<ElUtilityData> last12h = recent24h.subList(Math.max(0, recent24h.size() - 12), recent24h.size());
        boolean waterZero = last12h.stream().allMatch(d -> d.getWaterUsage() == null || d.getWaterUsage().compareTo(ZERO_THRESHOLD) < 0);
        boolean electricZero = last12h.stream().allMatch(d -> d.getElectricUsage() == null || d.getElectricUsage().compareTo(ZERO_THRESHOLD) < 0);
        BigDecimal histWater = calcAverage(historyData, "water", null);
        BigDecimal histElectric = calcAverage(historyData, "electric", null);

        String detail = null;
        if (waterZero && !electricZero && histWater.compareTo(ZERO_THRESHOLD) > 0) {
            detail = "近12小时用水为零但仍有用电，历史用水基线正常，需关注是否未正常起居用水";
        } else if (electricZero && !waterZero && histElectric.compareTo(ZERO_THRESHOLD) > 0) {
            detail = "近12小时用电为零但仍有用水，历史用电基线正常，需关注是否电器长期未使用或设备故障";
        }
        if (detail == null) {
            return null;
        }
        Map<String, Object> anomaly = new LinkedHashMap<>();
        anomaly.put("type", "partial_zero");
        anomaly.put("level", 2);
        anomaly.put("description", "【用量异常】" + detail);
        anomaly.put("residentId", residentId);
        return anomaly;
    }

    /** 24h内上报点数过少 */
    private Map<String, Object> checkSparseReporting(List<ElUtilityData> recent24h, Long residentId) {
        if (recent24h.isEmpty()) {
            return null;
        }
        if (recent24h.size() >= 18) {
            return null;
        }
        Map<String, Object> anomaly = new LinkedHashMap<>();
        anomaly.put("type", "sparse_data");
        anomaly.put("level", 2);
        anomaly.put("description", String.format(
            "【数据缺失】近24小时仅上报%d条水电记录（正常应≥18条/小时级），数据稀疏可能影响监测准确性",
            recent24h.size()));
        anomaly.put("residentId", residentId);
        return anomaly;
    }

    /** 单小时尖峰用量 */
    private Map<String, Object> checkHourlySpike(List<ElUtilityData> recent24h, BigDecimal histAvgWater, BigDecimal histAvgElectric, Long residentId) {
        if (recent24h.isEmpty()) {
            return null;
        }
        List<String> spikes = new ArrayList<>();
        for (ElUtilityData d : recent24h) {
            if (histAvgWater.compareTo(ZERO_THRESHOLD) > 0 && d.getWaterUsage() != null
                && d.getWaterUsage().compareTo(histAvgWater.multiply(BigDecimal.valueOf(SPIKE_MULTIPLIER))) > 0) {
                spikes.add(String.format("%s 用水%.2fL", d.getRecordTime(), d.getWaterUsage().doubleValue()));
            }
            if (histAvgElectric.compareTo(ZERO_THRESHOLD) > 0 && d.getElectricUsage() != null
                && d.getElectricUsage().compareTo(histAvgElectric.multiply(BigDecimal.valueOf(SPIKE_MULTIPLIER))) > 0) {
                spikes.add(String.format("%s 用电%.2fkWh", d.getRecordTime(), d.getElectricUsage().doubleValue()));
            }
        }
        if (spikes.isEmpty()) {
            return null;
        }
        String sample = spikes.size() > 2 ? String.join("、", spikes.subList(0, 2)) + " 等" : String.join("、", spikes);
        Map<String, Object> anomaly = new LinkedHashMap<>();
        anomaly.put("type", "hourly_spike");
        anomaly.put("level", 2);
        anomaly.put("description", "【用量异常】出现单小时尖峰用量（超7日基线300%）：" + sample);
        anomaly.put("residentId", residentId);
        return anomaly;
    }

    /** 日间整体用量显著低于历史 */
    private Map<String, Object> checkDaytimeAbnormalLow(List<ElUtilityData> recent24h, BigDecimal histDayWater, BigDecimal histDayElectric, Long residentId) {
        List<ElUtilityData> dayData = recent24h.stream()
            .filter(d -> {
                int h = d.getRecordTime().getHour();
                return h >= DAY_START && h <= DAY_END;
            }).toList();
        if (dayData.isEmpty() || (histDayWater.compareTo(ZERO_THRESHOLD) <= 0 && histDayElectric.compareTo(ZERO_THRESHOLD) <= 0)) {
            return null;
        }
        BigDecimal dayWater = calcRecentAverage(dayData, "water");
        BigDecimal dayElectric = calcRecentAverage(dayData, "electric");
        List<String> issues = new ArrayList<>();
        BigDecimal lowWater = histDayWater.multiply(BigDecimal.valueOf(DAY_LOW_RATIO));
        BigDecimal lowElectric = histDayElectric.multiply(BigDecimal.valueOf(DAY_LOW_RATIO));
        if (histDayWater.compareTo(ZERO_THRESHOLD) > 0 && dayWater.compareTo(lowWater) < 0 && dayWater.compareTo(ZERO_THRESHOLD) > 0) {
            issues.add(String.format("日间用水均%.2fL/h，低于基线%.2fL/h的30%%", dayWater.doubleValue(), histDayWater.doubleValue()));
        }
        if (histDayElectric.compareTo(ZERO_THRESHOLD) > 0 && dayElectric.compareTo(lowElectric) < 0 && dayElectric.compareTo(ZERO_THRESHOLD) > 0) {
            issues.add(String.format("日间用电均%.2fkWh/h，低于基线%.2fkWh/h的30%%", dayElectric.doubleValue(), histDayElectric.doubleValue()));
        }
        if (issues.isEmpty()) {
            return null;
        }
        Map<String, Object> anomaly = new LinkedHashMap<>();
        anomaly.put("type", "daytime_low");
        anomaly.put("level", 2);
        anomaly.put("description", "【生活迹象】" + String.join("；", issues) + "，日间活动量可能不足");
        anomaly.put("residentId", residentId);
        return anomaly;
    }

    // ==================== 自动预警与工单生成 ====================

    /**
     * 执行完整水电异常检测，并自动生成预警+关怀工单
     */
    @Transactional
    public Map<String, Object> performUtilityCheck(Long residentId) {
        List<Map<String, Object>> anomalies = detectAnomalies(residentId);
        Map<String, Object> result = new LinkedHashMap<>();
        result.put("residentId", residentId);
        result.put("checkTime", LocalDateTime.now());
        result.put("anomalyCount", anomalies.size());
        result.put("anomalies", anomalies);

        if (anomalies.isEmpty()) {
            result.put("status", "normal");
            // 正常情况也记录AI监测日志
            writeMonitorLog(residentId, "green", "各项指标正常", null, null);
            return result;
        }

        // 取最高风险等级
        int maxLevel = anomalies.stream()
            .mapToInt(a -> (Integer) a.getOrDefault("level", 3))
            .min().orElse(3);

        // 构建预警内容
        String alertContent = anomalies.stream()
            .map(a -> (String) a.get("description"))
            .collect(Collectors.joining("；"));

        // AI分析
        String aiAnalysis = analyzeUtilityWithAi(residentId, anomalies);
        if (aiAnalysis != null && !aiAnalysis.isEmpty()) {
            alertContent += " | AI建议：" + (aiAnalysis.length() > 150 ? aiAnalysis.substring(0, 150) + "..." : aiAnalysis);
        }

        // 创建预警
        ElAlert alert = new ElAlert();
        alert.setResidentId(residentId);
        alert.setAlertType("utility_anomaly");
        alert.setAlertLevel(maxLevel);
        alert.setContent(alertContent.length() > 250 ? alertContent.substring(0, 250) : alertContent);
        alert.setStatus("pending");
        alert.setCreateTime(LocalDateTime.now());
        alertMapper.insert(alert);

        result.put("alertId", alert.getAlertId());
        result.put("status", "alert_created");

        // 高风险时自动创建关怀工单（指派给网格员）
        if (maxLevel == 1) {
            Long gridWorkerId = findGridWorker(residentId);
            ElCareOrder order = new ElCareOrder();
            order.setResidentId(residentId);
            order.setCareItem("[AI自动] 水电异常高优先级工单：" + anomalies.get(0).get("description"));
            order.setStatus(gridWorkerId != null ? "assigned" : "pending");
            order.setAssigneeId(gridWorkerId);
            order.setCreateTime(LocalDateTime.now());
            careOrderMapper.insert(order);
            result.put("careOrderId", order.getCareId());
            result.put("assignedTo", gridWorkerId);
        }

        result.put("aiAnalysis", aiAnalysis);

        // 写入AI监测日志
        writeMonitorLog(residentId, anomalies.isEmpty() ? "green" : (maxLevel == 1 ? "red" : "yellow"),
                alertContent, aiAnalysis, alert.getAlertId());

        return result;
    }

    /**
     * 写入AI监测日志记录
     */
    private void writeMonitorLog(Long residentId, String riskLevel, String reason, String aiResponse, Long alertId) {
        try {
            ElAiMonitorLog logEntry = new ElAiMonitorLog();
            logEntry.setResidentId(residentId);
            logEntry.setCheckTime(LocalDateTime.now());
            logEntry.setRiskLevel(riskLevel);
            logEntry.setReason(reason != null && reason.length() > 500 ? reason.substring(0, 500) : reason);
            logEntry.setAiResponse(aiResponse);
            logEntry.setAlertId(alertId);
            logEntry.setCreateTime(LocalDateTime.now());
            monitorLogMapper.insert(logEntry);
        } catch (Exception e) {
            log.warn("写入AI监测日志失败: {}", e.getMessage());
        }
    }

    /**
     * 调用AI分析水电异常数据
     */
    private String analyzeUtilityWithAi(Long residentId, List<Map<String, Object>> anomalies) {
        try {
            if (!aiClient.isAvailable()) return null;

            CmResident resident = residentMapper.selectById(residentId);
            String residentName = resident != null ? resident.getName() : "未知";

            String systemPrompt = "你是智慧社区独居老人安全监测AI助手。请根据老人的水电使用异常数据，" +
                "分析可能的原因和风险，并给出简洁的处置建议。回复不超过150字。";

            StringBuilder userMsg = new StringBuilder();
            userMsg.append("独居老人「").append(residentName).append("」的水电使用出现以下异常：\n");
            for (Map<String, Object> a : anomalies) {
                userMsg.append("- ").append(a.get("description")).append("\n");
            }
            userMsg.append("\n请分析可能原因并给出处置建议。");

            return aiClient.chatSimple(systemPrompt, userMsg.toString());
        } catch (Exception e) {
            log.warn("水电异常AI分析失败: {}", e.getMessage());
            return null;
        }
    }

    /**
     * 查找负责该老人所在楼栋的网格员（关怀人员）
     */
    private Long findGridWorker(Long residentId) {
        try {
            List<Map<String, Object>> staff = jdbcTemplate.queryForList(
                "SELECT s.staff_id FROM el_care_staff s " +
                "WHERE s.staff_type = '护理员' AND s.status = '在岗' " +
                "ORDER BY s.staff_id ASC LIMIT 1");
            if (!staff.isEmpty()) {
                return ((Number) staff.get(0).get("staff_id")).longValue();
            }
        } catch (Exception e) {
            log.warn("查找网格员失败: {}", e.getMessage());
        }
        return null;
    }

    // ==================== 数据模拟 ====================

    /** 每位老人固定的用量基线（同一人每次生成形态一致，不同老人有差异） */
    private record ElderUsageProfile(double waterScale, double electricScale, double activityFactor) {}

    private ElderUsageProfile profileFor(Long residentId) {
        long id = residentId != null ? residentId : 1L;
        double waterScale = 0.55 + (id % 11) * 0.11;
        double electricScale = 0.42 + (id % 9) * 0.14;
        double activityFactor = 0.75 + (id % 5) * 0.12;
        return new ElderUsageProfile(waterScale, electricScale, activityFactor);
    }

    private Random elderRandom(Long residentId, long salt) {
        long seed = (residentId != null ? residentId : 0L) * 1009L + salt;
        return new Random(seed);
    }

    private BigDecimal scaledWater(Random random, double baseMin, double baseRange, ElderUsageProfile profile) {
        double v = (baseMin + random.nextDouble() * baseRange) * profile.waterScale() * profile.activityFactor();
        return BigDecimal.valueOf(v).setScale(2, RoundingMode.HALF_UP);
    }

    private BigDecimal scaledElectric(Random random, double baseMin, double baseRange, ElderUsageProfile profile) {
        double v = (baseMin + random.nextDouble() * baseRange) * profile.electricScale() * profile.activityFactor();
        return BigDecimal.valueOf(v).setScale(2, RoundingMode.HALF_UP);
    }

    /**
     * 为指定老人生成模拟水电数据（最近N天，每小时一条）
     */
    @Transactional
    public int generateSimulatedData(Long residentId, int days) {
        LocalDateTime now = LocalDateTime.now();
        LocalDateTime start = now.minusDays(days).withMinute(0).withSecond(0).withNano(0);

        // 先删除该老人的旧模拟数据
        utilityDataMapper.delete(
            new LambdaQueryWrapper<ElUtilityData>()
                .eq(ElUtilityData::getResidentId, residentId)
                .eq(ElUtilityData::getSource, "simulated")
        );

        ElderUsageProfile profile = profileFor(residentId);
        Random random = elderRandom(residentId, days);
        List<ElUtilityData> batch = new ArrayList<>();
        LocalDateTime cursor = start;

        while (cursor.isBefore(now)) {
            int hour = cursor.getHour();
            ElUtilityData data = new ElUtilityData();
            data.setResidentId(residentId);
            data.setRecordTime(cursor);
            data.setSource("simulated");
            data.setCreateTime(LocalDateTime.now());

            if (NIGHT_HOURS.contains(hour)) {
                data.setWaterUsage(scaledWater(random, 0, 2, profile));
                data.setElectricUsage(scaledElectric(random, 0.1, 0.3, profile));
            } else if (hour >= 6 && hour <= 9) {
                data.setWaterUsage(scaledWater(random, 8, 12, profile));
                data.setElectricUsage(scaledElectric(random, 0.5, 1.5, profile));
            } else if (hour >= 11 && hour <= 13) {
                data.setWaterUsage(scaledWater(random, 5, 10, profile));
                data.setElectricUsage(scaledElectric(random, 0.4, 1.2, profile));
            } else if (hour >= 17 && hour <= 20) {
                data.setWaterUsage(scaledWater(random, 10, 15, profile));
                data.setElectricUsage(scaledElectric(random, 0.8, 2.0, profile));
            } else {
                data.setWaterUsage(scaledWater(random, 2, 5, profile));
                data.setElectricUsage(scaledElectric(random, 0.2, 0.8, profile));
            }

            batch.add(data);
            cursor = cursor.plusHours(1);
        }

        for (ElUtilityData d : batch) {
            utilityDataMapper.insert(d);
        }
        return batch.size();
    }

    /**
     * 生成异常模拟数据（最近24小时全部为0，用于测试告警）
     */
    @Transactional
    public int generateAnomalyData(Long residentId, String anomalyType) {
        LocalDateTime now = LocalDateTime.now();
        LocalDateTime start = now.minusHours(24).withMinute(0).withSecond(0).withNano(0);

        // 先确保有历史数据
        long histCount = utilityDataMapper.selectCount(
            new LambdaQueryWrapper<ElUtilityData>()
                .eq(ElUtilityData::getResidentId, residentId)
                .lt(ElUtilityData::getRecordTime, start)
        );
        if (histCount < 48) {
            // 先生成7天正常数据作为基线
            generateSimulatedData(residentId, 8);
        }

        // 删除最近24小时的数据
        utilityDataMapper.delete(
            new LambdaQueryWrapper<ElUtilityData>()
                .eq(ElUtilityData::getResidentId, residentId)
                .ge(ElUtilityData::getRecordTime, start)
        );

        Random random = elderRandom(residentId, anomalyType.hashCode());
        ElderUsageProfile profile = profileFor(residentId);
        List<ElUtilityData> batch = new ArrayList<>();
        LocalDateTime cursor = start;

        while (cursor.isBefore(now)) {
            ElUtilityData data = new ElUtilityData();
            data.setResidentId(residentId);
            data.setRecordTime(cursor);
            data.setSource("simulated");
            data.setCreateTime(LocalDateTime.now());

            switch (anomalyType) {
                case "no_usage" -> {
                    data.setWaterUsage(BigDecimal.ZERO);
                    data.setElectricUsage(BigDecimal.ZERO);
                }
                case "no_living_sign" -> {
                    boolean inRecentWindow = cursor.isAfter(now.minusHours(ACTIVITY_WINDOW_HOURS));
                    if (inRecentWindow) {
                        data.setWaterUsage(BigDecimal.ZERO);
                        data.setElectricUsage(BigDecimal.ZERO);
                    } else {
                        data.setWaterUsage(scaledWater(random, 5, 8, profile));
                        data.setElectricUsage(scaledElectric(random, 0.3, 0.8, profile));
                    }
                }
                case "surge" -> {
                    double surgeFactor = 2.2 + (residentId % 4) * 0.35;
                    data.setWaterUsage(scaledWater(random, 12, 18, profile)
                        .multiply(BigDecimal.valueOf(surgeFactor)).setScale(2, RoundingMode.HALF_UP));
                    data.setElectricUsage(scaledElectric(random, 1.2, 2.5, profile)
                        .multiply(BigDecimal.valueOf(surgeFactor * 0.85)).setScale(2, RoundingMode.HALF_UP));
                }
                case "night_high" -> {
                    int hour = cursor.getHour();
                    if (NIGHT_HOURS.contains(hour)) {
                        data.setWaterUsage(scaledWater(random, 14, 22, profile));
                        data.setElectricUsage(scaledElectric(random, 1.5, 2.8, profile));
                    } else {
                        data.setWaterUsage(scaledWater(random, 5, 8, profile));
                        data.setElectricUsage(scaledElectric(random, 0.3, 0.8, profile));
                    }
                }
                default -> {
                    data.setWaterUsage(scaledWater(random, 5, 8, profile));
                    data.setElectricUsage(scaledElectric(random, 0.3, 0.8, profile));
                }
            }
            batch.add(data);
            cursor = cursor.plusHours(1);
        }

        for (ElUtilityData d : batch) {
            utilityDataMapper.insert(d);
        }
        return batch.size();
    }

    // ==================== 数据查询 ====================

    /**
     * 分页查询水电数据
     */
    public TableDataInfo listUtilityData(Long residentId, int pageNum, int pageSize) {
        LambdaQueryWrapper<ElUtilityData> qw = new LambdaQueryWrapper<ElUtilityData>()
            .eq(residentId != null, ElUtilityData::getResidentId, residentId)
            .orderByDesc(ElUtilityData::getRecordTime);
        Page<ElUtilityData> page = utilityDataMapper.selectPage(new Page<>(pageNum, pageSize), qw);
        return new TableDataInfo(page.getTotal(), page.getRecords());
    }

    /**
     * 获取老人最近N小时水电数据（用于图表展示）
     */
    public List<ElUtilityData> getRecentData(Long residentId, int hours) {
        return utilityDataMapper.selectList(
            new LambdaQueryWrapper<ElUtilityData>()
                .eq(ElUtilityData::getResidentId, residentId)
                .ge(ElUtilityData::getRecordTime, LocalDateTime.now().minusHours(hours))
                .orderByAsc(ElUtilityData::getRecordTime)
        );
    }

    // ==================== 工具方法 ====================

    private BigDecimal calcAverage(List<ElUtilityData> data, String type, Boolean nightOnly) {
        if (data.isEmpty()) return BigDecimal.ZERO;

        List<ElUtilityData> filtered = data;
        if (nightOnly != null) {
            filtered = data.stream()
                .filter(d -> {
                    boolean isNight = NIGHT_HOURS.contains(d.getRecordTime().getHour());
                    return nightOnly ? isNight : !isNight;
                })
                .collect(Collectors.toList());
        }
        if (filtered.isEmpty()) return BigDecimal.ZERO;

        BigDecimal sum = BigDecimal.ZERO;
        for (ElUtilityData d : filtered) {
            BigDecimal val = "water".equals(type) ? d.getWaterUsage() : d.getElectricUsage();
            if (val != null) sum = sum.add(val);
        }
        return sum.divide(BigDecimal.valueOf(filtered.size()), 4, RoundingMode.HALF_UP);
    }

    private BigDecimal calcRecentAverage(List<ElUtilityData> data, String type) {
        if (data.isEmpty()) return BigDecimal.ZERO;
        BigDecimal sum = BigDecimal.ZERO;
        for (ElUtilityData d : data) {
            BigDecimal val = "water".equals(type) ? d.getWaterUsage() : d.getElectricUsage();
            if (val != null) sum = sum.add(val);
        }
        return sum.divide(BigDecimal.valueOf(data.size()), 4, RoundingMode.HALF_UP);
    }
}
