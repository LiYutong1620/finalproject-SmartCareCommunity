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
 * 独居老人水电数据时序异常监测服务
 *
 * 检测规则：
 * 1. 连续24小时无用水用电 → 高风险（红色）
 * 2. 水电用量突增（超历史平均2倍）→ 中风险（黄色）
 * 3. 水电用量突减（低于历史平均1/2）→ 中风险（黄色）
 * 4. 夜间时段（22:00-5:00）高用量异常 → 中风险（黄色）
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

        // 规则1：连续24小时无用水用电
        Map<String, Object> noUsageAnomaly = checkNoUsage24h(recent24h, residentId);
        if (noUsageAnomaly != null) {
            anomalies.add(noUsageAnomaly);
        }

        // 计算历史平均（分日间/夜间）
        BigDecimal histAvgWater = calcAverage(historyData, "water", null);
        BigDecimal histAvgElectric = calcAverage(historyData, "electric", null);
        BigDecimal histDaytimeAvgWater = calcAverage(historyData, "water", false);
        BigDecimal histDaytimeAvgElectric = calcAverage(historyData, "electric", false);

        // 规则2：突增（最近数据 vs 历史平均）
        Map<String, Object> surgeAnomaly = checkSurge(recent24h, histAvgWater, histAvgElectric, residentId);
        if (surgeAnomaly != null) {
            anomalies.add(surgeAnomaly);
        }

        // 规则3：突减
        Map<String, Object> dropAnomaly = checkDrop(recent24h, histAvgWater, histAvgElectric, residentId);
        if (dropAnomaly != null) {
            anomalies.add(dropAnomaly);
        }

        // 规则4：夜间高用量
        Map<String, Object> nightAnomaly = checkNightHighUsage(recent24h, histDaytimeAvgWater, histDaytimeAvgElectric, residentId);
        if (nightAnomaly != null) {
            anomalies.add(nightAnomaly);
        }

        return anomalies;
    }

    /**
     * 规则1：检测连续24小时无用水用电
     */
    private Map<String, Object> checkNoUsage24h(List<ElUtilityData> recent24h, Long residentId) {
        if (recent24h.isEmpty()) {
            // 无数据也视为异常（可能设备离线）
            Map<String, Object> anomaly = new LinkedHashMap<>();
            anomaly.put("type", "no_usage_24h");
            anomaly.put("level", 1); // 高风险
            anomaly.put("description", "连续24小时无水电数据上报，可能设备离线或老人异常");
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
            anomaly.put("description", "连续24小时无用水且无用电，老人可能存在安全隐患");
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
            surges.add(String.format("用水量突增（当前平均%.2fL/h，历史平均%.2fL/h，超过2倍）",
                recentAvgWater.doubleValue(), histAvgWater.doubleValue()));
        }
        if (histAvgElectric.compareTo(ZERO_THRESHOLD) > 0 &&
            recentAvgElectric.compareTo(histAvgElectric.multiply(BigDecimal.valueOf(SURGE_MULTIPLIER))) > 0) {
            surges.add(String.format("用电量突增（当前平均%.2fkWh/h，历史平均%.2fkWh/h，超过2倍）",
                recentAvgElectric.doubleValue(), histAvgElectric.doubleValue()));
        }

        if (!surges.isEmpty()) {
            Map<String, Object> anomaly = new LinkedHashMap<>();
            anomaly.put("type", "usage_surge");
            anomaly.put("level", 2); // 中风险
            anomaly.put("description", String.join("；", surges));
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
            drops.add(String.format("用水量突减（当前平均%.2fL/h，历史平均%.2fL/h，低于1/2）",
                recentAvgWater.doubleValue(), histAvgWater.doubleValue()));
        }
        if (histAvgElectric.compareTo(ZERO_THRESHOLD) > 0 &&
            recentAvgElectric.compareTo(histAvgElectric.multiply(BigDecimal.valueOf(DROP_MULTIPLIER))) < 0 &&
            recentAvgElectric.compareTo(ZERO_THRESHOLD) > 0) {
            drops.add(String.format("用电量突减（当前平均%.2fkWh/h，历史平均%.2fkWh/h，低于1/2）",
                recentAvgElectric.doubleValue(), histAvgElectric.doubleValue()));
        }

        if (!drops.isEmpty()) {
            Map<String, Object> anomaly = new LinkedHashMap<>();
            anomaly.put("type", "usage_drop");
            anomaly.put("level", 2);
            anomaly.put("description", String.join("；", drops));
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
            nightIssues.add(String.format("夜间(22:00-5:00)用水异常偏高（夜间平均%.2fL/h，日间平均%.2fL/h）",
                nightAvgWater.doubleValue(), daytimeAvgWater.doubleValue()));
        }
        if (daytimeAvgElectric.compareTo(ZERO_THRESHOLD) > 0 && nightAvgElectric.compareTo(nightElectricThreshold) > 0) {
            nightIssues.add(String.format("夜间(22:00-5:00)用电异常偏高（夜间平均%.2fkWh/h，日间平均%.2fkWh/h）",
                nightAvgElectric.doubleValue(), daytimeAvgElectric.doubleValue()));
        }

        if (!nightIssues.isEmpty()) {
            Map<String, Object> anomaly = new LinkedHashMap<>();
            anomaly.put("type", "night_high_usage");
            anomaly.put("level", 2);
            anomaly.put("description", String.join("；", nightIssues));
            anomaly.put("residentId", residentId);
            return anomaly;
        }
        return null;
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

        Random random = new Random(residentId + days);
        List<ElUtilityData> batch = new ArrayList<>();
        LocalDateTime cursor = start;

        while (cursor.isBefore(now)) {
            int hour = cursor.getHour();
            ElUtilityData data = new ElUtilityData();
            data.setResidentId(residentId);
            data.setRecordTime(cursor);
            data.setSource("simulated");
            data.setCreateTime(LocalDateTime.now());

            // 模拟正常用水用电模式
            if (NIGHT_HOURS.contains(hour)) {
                // 夜间：低用量
                data.setWaterUsage(BigDecimal.valueOf(random.nextDouble() * 2).setScale(2, RoundingMode.HALF_UP));
                data.setElectricUsage(BigDecimal.valueOf(0.1 + random.nextDouble() * 0.3).setScale(2, RoundingMode.HALF_UP));
            } else if (hour >= 6 && hour <= 9) {
                // 早间高峰
                data.setWaterUsage(BigDecimal.valueOf(8 + random.nextDouble() * 12).setScale(2, RoundingMode.HALF_UP));
                data.setElectricUsage(BigDecimal.valueOf(0.5 + random.nextDouble() * 1.5).setScale(2, RoundingMode.HALF_UP));
            } else if (hour >= 11 && hour <= 13) {
                // 午间
                data.setWaterUsage(BigDecimal.valueOf(5 + random.nextDouble() * 10).setScale(2, RoundingMode.HALF_UP));
                data.setElectricUsage(BigDecimal.valueOf(0.4 + random.nextDouble() * 1.2).setScale(2, RoundingMode.HALF_UP));
            } else if (hour >= 17 && hour <= 20) {
                // 晚间高峰
                data.setWaterUsage(BigDecimal.valueOf(10 + random.nextDouble() * 15).setScale(2, RoundingMode.HALF_UP));
                data.setElectricUsage(BigDecimal.valueOf(0.8 + random.nextDouble() * 2.0).setScale(2, RoundingMode.HALF_UP));
            } else {
                // 其他时段
                data.setWaterUsage(BigDecimal.valueOf(2 + random.nextDouble() * 5).setScale(2, RoundingMode.HALF_UP));
                data.setElectricUsage(BigDecimal.valueOf(0.2 + random.nextDouble() * 0.8).setScale(2, RoundingMode.HALF_UP));
            }

            batch.add(data);
            cursor = cursor.plusHours(1);
        }

        // 批量插入
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

        Random random = new Random();
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
                    // 全部为0
                    data.setWaterUsage(BigDecimal.ZERO);
                    data.setElectricUsage(BigDecimal.ZERO);
                }
                case "surge" -> {
                    // 突增：所有值都是正常的3倍
                    data.setWaterUsage(BigDecimal.valueOf(30 + random.nextDouble() * 40).setScale(2, RoundingMode.HALF_UP));
                    data.setElectricUsage(BigDecimal.valueOf(3 + random.nextDouble() * 5).setScale(2, RoundingMode.HALF_UP));
                }
                case "night_high" -> {
                    int hour = cursor.getHour();
                    if (NIGHT_HOURS.contains(hour)) {
                        // 夜间高用量
                        data.setWaterUsage(BigDecimal.valueOf(20 + random.nextDouble() * 20).setScale(2, RoundingMode.HALF_UP));
                        data.setElectricUsage(BigDecimal.valueOf(2 + random.nextDouble() * 3).setScale(2, RoundingMode.HALF_UP));
                    } else {
                        // 日间正常
                        data.setWaterUsage(BigDecimal.valueOf(5 + random.nextDouble() * 8).setScale(2, RoundingMode.HALF_UP));
                        data.setElectricUsage(BigDecimal.valueOf(0.3 + random.nextDouble() * 0.8).setScale(2, RoundingMode.HALF_UP));
                    }
                }
                default -> {
                    data.setWaterUsage(BigDecimal.valueOf(5 + random.nextDouble() * 8).setScale(2, RoundingMode.HALF_UP));
                    data.setElectricUsage(BigDecimal.valueOf(0.3 + random.nextDouble() * 0.8).setScale(2, RoundingMode.HALF_UP));
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
