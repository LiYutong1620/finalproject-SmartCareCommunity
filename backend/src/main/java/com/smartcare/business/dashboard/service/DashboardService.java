package com.smartcare.business.dashboard.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.smartcare.business.elder.domain.ElAlert;
import com.smartcare.business.elder.domain.ElCareOrder;
import com.smartcare.business.elder.mapper.ElAlertMapper;
import com.smartcare.business.elder.mapper.ElCareOrderMapper;
import com.smartcare.business.property.domain.CmBuilding;
import com.smartcare.business.property.domain.CmHouse;
import com.smartcare.business.property.domain.CmResident;
import com.smartcare.business.property.mapper.CmBuildingMapper;
import com.smartcare.business.property.mapper.CmHouseMapper;
import com.smartcare.business.property.mapper.CmResidentMapper;
import com.smartcare.business.property.service.ResidentCareTagService;
import com.smartcare.system.domain.SysUser;
import com.smartcare.system.service.UserAccountService;
import com.smartcare.business.repair.domain.RpOrder;
import com.smartcare.business.repair.mapper.RpOrderMapper;
import com.smartcare.framework.ai.ZhipuAiClient;
import lombok.RequiredArgsConstructor;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.time.temporal.TemporalAdjusters;
import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class DashboardService {

    private final RpOrderMapper orderMapper;
    private final ElAlertMapper alertMapper;
    private final ElCareOrderMapper careOrderMapper;
    private final CmResidentMapper residentMapper;
    private final CmBuildingMapper buildingMapper;
    private final CmHouseMapper houseMapper;
    private final JdbcTemplate jdbcTemplate;
    private final ResidentCareTagService careTagService;
    private final UserAccountService accountService;
    private final ZhipuAiClient zhipuAiClient;

    private static final DateTimeFormatter DATE_FMT = DateTimeFormatter.ofPattern("yyyy-MM-dd");
    private static final DateTimeFormatter DATETIME_FMT = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");

    /**
     * 综合统计：工单总数、完成数、完成率、老人总数、待处理预警数、本月关怀率
     */
    public Map<String, Object> getSummaryStats() {
        Map<String, Object> data = new HashMap<>();

        // --- 维修工单统计 ---
        long totalOrders = orderMapper.selectCount(null);
        long completedOrders = orderMapper.selectCount(
            new LambdaQueryWrapper<RpOrder>().eq(RpOrder::getStatus, "completed"));
        double completionRate = totalOrders == 0 ? 0 :
            Math.round(completedOrders * 10000.0 / totalOrders) / 100.0;

        // --- 老人总数（年龄>=60） ---
        long elderTotal = residentMapper.selectCount(
            new LambdaQueryWrapper<CmResident>()
                .ge(CmResident::getAge, 60)
                .eq(CmResident::getDelFlag, "0"));

        // --- 待处理预警数 ---
        long pendingAlerts = alertMapper.selectCount(
            new LambdaQueryWrapper<ElAlert>().eq(ElAlert::getStatus, "pending"));

        // --- 本月关怀率 ---
        LocalDateTime monthStart = LocalDate.now().withDayOfMonth(1).atStartOfDay();
        long monthCareTotal = careOrderMapper.selectCount(
            new LambdaQueryWrapper<ElCareOrder>().ge(ElCareOrder::getCreateTime, monthStart));
        long monthCareCompleted = careOrderMapper.selectCount(
            new LambdaQueryWrapper<ElCareOrder>()
                .ge(ElCareOrder::getCreateTime, monthStart)
                .eq(ElCareOrder::getStatus, "completed"));
        double monthlyCareRate = monthCareTotal == 0 ? 0 :
            Math.round(monthCareCompleted * 10000.0 / monthCareTotal) / 100.0;

        // --- 今日报修 ---
        LocalDateTime todayStart = LocalDate.now().atStartOfDay();
        long todayRepairs = orderMapper.selectCount(
            new LambdaQueryWrapper<RpOrder>().ge(RpOrder::getCreateTime, todayStart));

        // --- AI 监测老人数 ---
        long monitorElders = careTagService.listAiMonitorTargets().size();

        // --- 今日预警 ---
        long todayAlerts = alertMapper.selectCount(
            new LambdaQueryWrapper<ElAlert>().ge(ElAlert::getCreateTime, todayStart));

        data.put("totalOrders", totalOrders);
        data.put("todayRepairs", todayRepairs);
        data.put("monitorElders", monitorElders);
        data.put("todayAlerts", todayAlerts);
        data.put("completedOrders", completedOrders);
        data.put("completionRate", completionRate);
        data.put("elderTotal", elderTotal);
        data.put("pendingAlerts", pendingAlerts);
        data.put("monthlyCareRate", monthlyCareRate);
        return data;
    }

    /**
     * 老人关怀统计：独居老人数、高风险预警数、今日新增预警、关怀工单完成率
     */
    public Map<String, Object> getElderStats() {
        Map<String, Object> data = new HashMap<>();

        // --- 独居老人数（系统自动判定：≥60岁且房屋在住仅1人） ---
        long livingAloneCount = careTagService.countLivingAloneElders();
        long monitorTargetCount = careTagService.listAiMonitorTargets().size();

        // --- 高风险预警数（alertLevel=1） ---
        long highRiskAlertCount = alertMapper.selectCount(
            new LambdaQueryWrapper<ElAlert>().eq(ElAlert::getAlertLevel, 1));

        // --- 今日新增预警 ---
        LocalDateTime todayStart = LocalDate.now().atStartOfDay();
        long todayNewAlerts = alertMapper.selectCount(
            new LambdaQueryWrapper<ElAlert>().ge(ElAlert::getCreateTime, todayStart));

        // --- 关怀工单完成率 ---
        long careTotal = careOrderMapper.selectCount(null);
        long careCompleted = careOrderMapper.selectCount(
            new LambdaQueryWrapper<ElCareOrder>().eq(ElCareOrder::getStatus, "completed"));
        double careCompletionRate = careTotal == 0 ? 0 :
            Math.round(careCompleted * 10000.0 / careTotal) / 100.0;

        data.put("livingAloneCount", livingAloneCount);
        data.put("monitorTargetCount", monitorTargetCount);
        data.put("highRiskAlertCount", highRiskAlertCount);
        data.put("todayNewAlerts", todayNewAlerts);
        data.put("careCompletionRate", careCompletionRate);
        return data;
    }

    /**
     * 工单完成率趋势（按日/周/月切换）
     */
    public Map<String, Object> getCompletionRateTrend(String period) {
        List<RpOrder> allOrders = orderMapper.selectList(null);
        Map<String, Object> result = new HashMap<>();

        // 饼图数据：整体完成/未完成
        long total = allOrders.size();
        long completed = allOrders.stream().filter(o -> "completed".equals(o.getStatus())).count();
        result.put("pieData", List.of(
            Map.of("name", "已完成", "value", completed),
            Map.of("name", "未完成", "value", total - completed)
        ));

        // 折线图数据：按时间段的完成率
        List<Map<String, Object>> trendData = new ArrayList<>();
        LocalDate today = LocalDate.now();

        if ("day".equals(period)) {
            // 近7天每日完成率
            for (int i = 6; i >= 0; i--) {
                LocalDate date = today.minusDays(i);
                String label = date.format(DateTimeFormatter.ofPattern("MM-dd"));
                long dayTotal = allOrders.stream()
                    .filter(o -> o.getCreateTime() != null && o.getCreateTime().toLocalDate().equals(date)).count();
                long dayCompleted = allOrders.stream()
                    .filter(o -> o.getCreateTime() != null && o.getCreateTime().toLocalDate().equals(date)
                        && "completed".equals(o.getStatus())).count();
                double rate = dayTotal == 0 ? 0 : Math.round(dayCompleted * 10000.0 / dayTotal) / 100.0;
                trendData.add(Map.of("label", label, "rate", rate, "total", dayTotal, "completed", dayCompleted));
            }
        } else if ("week".equals(period)) {
            // 近6周每周完成率
            for (int i = 5; i >= 0; i--) {
                LocalDate weekStart = today.minusWeeks(i).with(TemporalAdjusters.previousOrSame(DayOfWeek.MONDAY));
                LocalDate weekEnd = weekStart.plusDays(6);
                String label = "第" + weekStart.format(DateTimeFormatter.ofPattern("ww")) + "周";
                long wTotal = allOrders.stream()
                    .filter(o -> o.getCreateTime() != null
                        && !o.getCreateTime().toLocalDate().isBefore(weekStart)
                        && !o.getCreateTime().toLocalDate().isAfter(weekEnd)).count();
                long wCompleted = allOrders.stream()
                    .filter(o -> o.getCreateTime() != null
                        && !o.getCreateTime().toLocalDate().isBefore(weekStart)
                        && !o.getCreateTime().toLocalDate().isAfter(weekEnd)
                        && "completed".equals(o.getStatus())).count();
                double rate = wTotal == 0 ? 0 : Math.round(wCompleted * 10000.0 / wTotal) / 100.0;
                trendData.add(Map.of("label", label, "rate", rate, "total", wTotal, "completed", wCompleted));
            }
        } else {
            // 近12个月每月完成率
            for (int i = 11; i >= 0; i--) {
                LocalDate monthStart = today.minusMonths(i).withDayOfMonth(1);
                LocalDate monthEnd = monthStart.plusMonths(1).minusDays(1);
                String label = monthStart.format(DateTimeFormatter.ofPattern("yyyy-MM"));
                long mTotal = allOrders.stream()
                    .filter(o -> o.getCreateTime() != null
                        && !o.getCreateTime().toLocalDate().isBefore(monthStart)
                        && !o.getCreateTime().toLocalDate().isAfter(monthEnd)).count();
                long mCompleted = allOrders.stream()
                    .filter(o -> o.getCreateTime() != null
                        && !o.getCreateTime().toLocalDate().isBefore(monthStart)
                        && !o.getCreateTime().toLocalDate().isAfter(monthEnd)
                        && "completed".equals(o.getStatus())).count();
                double rate = mTotal == 0 ? 0 : Math.round(mCompleted * 10000.0 / mTotal) / 100.0;
                trendData.add(Map.of("label", label, "rate", rate, "total", mTotal, "completed", mCompleted));
            }
        }
        result.put("trendData", trendData);
        return result;
    }

    /**
     * 报修分布（按故障类型 + 按楼栋）
     */
    public Map<String, Object> getRepairDistribution() {
        Map<String, Object> result = new HashMap<>();

        // 按故障类型分布
        List<Map<String, Object>> byType = jdbcTemplate.queryForList(
            "SELECT rt.type_name AS name, COUNT(o.order_id) AS value " +
            "FROM rp_order o LEFT JOIN rp_repair_type rt ON o.type_id = rt.type_id " +
            "GROUP BY o.type_id, rt.type_name ORDER BY value DESC");
        result.put("byType", byType);

        // 按楼栋分布
        List<Map<String, Object>> byBuilding = jdbcTemplate.queryForList(
            "SELECT b.building_no AS name, COUNT(o.order_id) AS value " +
            "FROM rp_order o " +
            "LEFT JOIN cm_house h ON o.house_id = h.house_id " +
            "LEFT JOIN cm_building b ON h.building_id = b.building_id " +
            "GROUP BY b.building_id, b.building_no ORDER BY value DESC");
        result.put("byBuilding", byBuilding);

        return result;
    }

    /**
     * 预警趋势（按类型分类：老人安全预警 / 设备预警）
     */
    public Map<String, Object> getAlertTrendByType() {
        LocalDateTime startDate = LocalDate.now().minusDays(29).atStartOfDay();
        List<ElAlert> alerts = alertMapper.selectList(
            new LambdaQueryWrapper<ElAlert>().ge(ElAlert::getCreateTime, startDate));

        // 定义类型分类
        Set<String> deviceTypes = Set.of("device_offline", "device_fault", "device_battery_low");

        Map<String, Long> elderDaily = new HashMap<>();
        Map<String, Long> deviceDaily = new HashMap<>();

        for (ElAlert alert : alerts) {
            if (alert.getCreateTime() == null) continue;
            String dateStr = alert.getCreateTime().toLocalDate().format(DATE_FMT);
            if (deviceTypes.contains(alert.getAlertType())) {
                deviceDaily.merge(dateStr, 1L, Long::sum);
            } else {
                elderDaily.merge(dateStr, 1L, Long::sum);
            }
        }

        Map<String, Object> result = new HashMap<>();
        result.put("dates", buildDateLabels());
        result.put("elderSafety", buildCountList(elderDaily));
        result.put("deviceAlert", buildCountList(deviceDaily));
        return result;
    }

    private List<String> buildDateLabels() {
        List<String> labels = new ArrayList<>();
        LocalDate today = LocalDate.now();
        for (int i = 29; i >= 0; i--) {
            labels.add(today.minusDays(i).format(DATE_FMT));
        }
        return labels;
    }

    private List<Long> buildCountList(Map<String, Long> dailyCount) {
        List<Long> counts = new ArrayList<>();
        LocalDate today = LocalDate.now();
        for (int i = 29; i >= 0; i--) {
            String dateStr = today.minusDays(i).format(DATE_FMT);
            counts.add(dailyCount.getOrDefault(dateStr, 0L));
        }
        return counts;
    }

    /**
     * 报修工单状态分布
     */
    public List<Map<String, Object>> getOrderStatusDistribution() {
        List<RpOrder> allOrders = orderMapper.selectList(null);
        Map<String, Long> statusCount = allOrders.stream()
            .collect(Collectors.groupingBy(o -> {
                String s = o.getStatus();
                if (s == null) return "未知";
                return switch (s) {
                    case "pending" -> "待接单";
                    case "assigned" -> "已派单";
                    case "accepted" -> "已接单";
                    case "in_progress" -> "维修中";
                    case "completed" -> "已完成";
                    case "evaluated" -> "已评价";
                    case "rejected" -> "已拒绝";
                    default -> s;
                };
            }, Collectors.counting()));
        return statusCount.entrySet().stream()
            .map(e -> {
                Map<String, Object> m = new HashMap<>();
                m.put("name", e.getKey());
                m.put("value", e.getValue());
                return m;
            })
            .sorted((a, b) -> Long.compare((Long) b.get("value"), (Long) a.get("value")))
            .collect(Collectors.toList());
    }

    /**
     * 维修工负载TOP5
     */
    public List<Map<String, Object>> getWorkerLoad() {
        List<RpOrder> allOrders = orderMapper.selectList(
            new LambdaQueryWrapper<RpOrder>().isNotNull(RpOrder::getWorkerId));
        Map<Long, Long> workerCount = allOrders.stream()
            .collect(Collectors.groupingBy(RpOrder::getWorkerId, Collectors.counting()));

        // 查询维修工姓名
        List<Map<String, Object>> result = new ArrayList<>();
        for (Map.Entry<Long, Long> entry : workerCount.entrySet()) {
            SysUser worker = accountService.findById(entry.getKey());
            String name = worker != null && StringUtils.hasText(worker.getNickName())
                ? worker.getNickName() : "维修工#" + entry.getKey();
            Map<String, Object> item = new HashMap<>();
            item.put("name", name);
            item.put("value", entry.getValue());
            result.add(item);
        }
        result.sort((a, b) -> Long.compare((Long) b.get("value"), (Long) a.get("value")));
        return result.size() > 5 ? result.subList(0, 5) : result;
    }

    /**
     * 预警处理趋势：近14日新增 vs 已处理
     */
    public Map<String, Object> getAlertProcessTrend() {
        LocalDate today = LocalDate.now();
        LocalDateTime startTime = today.minusDays(13).atStartOfDay();
        List<ElAlert> alerts = alertMapper.selectList(
            new LambdaQueryWrapper<ElAlert>().ge(ElAlert::getCreateTime, startTime));

        Map<String, Long> newDaily = new LinkedHashMap<>();
        Map<String, Long> processedDaily = new LinkedHashMap<>();
        for (int i = 13; i >= 0; i--) {
            String label = today.minusDays(i).format(DateTimeFormatter.ofPattern("MM-dd"));
            newDaily.put(label, 0L);
            processedDaily.put(label, 0L);
        }

        for (ElAlert alert : alerts) {
            if (alert.getCreateTime() != null) {
                String createLabel = alert.getCreateTime().toLocalDate().format(DateTimeFormatter.ofPattern("MM-dd"));
                if (newDaily.containsKey(createLabel)) {
                    newDaily.merge(createLabel, 1L, Long::sum);
                }
            }
            if (alert.getHandleTime() != null) {
                String handleLabel = alert.getHandleTime().toLocalDate().format(DateTimeFormatter.ofPattern("MM-dd"));
                if (processedDaily.containsKey(handleLabel)) {
                    processedDaily.merge(handleLabel, 1L, Long::sum);
                }
            }
        }

        Map<String, Object> result = new HashMap<>();
        result.put("labels", new ArrayList<>(newDaily.keySet()));
        result.put("newAlerts", new ArrayList<>(newDaily.values()));
        result.put("processedAlerts", new ArrayList<>(processedDaily.values()));
        return result;
    }

    /**
     * 住户结构（年龄段 + 产权关系，供旭日图/金字塔图）
     */
    public Map<String, Object> getResidentStructure() {
        List<CmResident> residents = residentMapper.selectList(
            new LambdaQueryWrapper<CmResident>().eq(CmResident::getDelFlag, "0"));

        Map<String, Map<String, Long>> grouped = new LinkedHashMap<>();
        for (String ageGroup : List.of("少年儿童(0-17)", "青年(18-44)", "中年(45-59)", "老年(60+)")) {
            grouped.put(ageGroup, new LinkedHashMap<>(Map.of("产权人", 0L, "家属/租客", 0L)));
        }

        for (CmResident r : residents) {
            String ageGroup = resolveAgeGroup(r.getAge());
            String role = r.getIsOwner() != null && r.getIsOwner() == 1 ? "产权人" : "家属/租客";
            grouped.computeIfAbsent(ageGroup, k -> new LinkedHashMap<>())
                .merge(role, 1L, Long::sum);
        }

        Map<String, Object> sunburst = new LinkedHashMap<>();
        sunburst.put("name", "住户");
        List<Map<String, Object>> ageChildren = new ArrayList<>();
        grouped.forEach((age, roles) -> {
            long total = roles.values().stream().mapToLong(Long::longValue).sum();
            if (total == 0) {
                return;
            }
            Map<String, Object> ageNode = new LinkedHashMap<>();
            ageNode.put("name", age);
            ageNode.put("value", total);
            List<Map<String, Object>> roleChildren = new ArrayList<>();
            roles.forEach((role, count) -> {
                if (count > 0) {
                    roleChildren.add(Map.of("name", role, "value", count));
                }
            });
            ageNode.put("children", roleChildren);
            ageChildren.add(ageNode);
        });
        sunburst.put("children", ageChildren);

        List<Map<String, Object>> byLivingStatus = jdbcTemplate.queryForList(
            "SELECT CASE living_status WHEN '1' THEN '在住' WHEN '2' THEN '空置' WHEN '3' THEN '出租' ELSE '其他' END AS name, "
                + "COUNT(*) AS value FROM cm_resident WHERE del_flag='0' GROUP BY living_status");

        Map<String, Object> result = new HashMap<>();
        result.put("sunburst", sunburst);
        result.put("byLivingStatus", byLivingStatus);
        return result;
    }

    /**
     * 房屋结构（户型 + 面积段 + 居住状态）
     */
    public Map<String, Object> getHouseStructure() {
        List<CmHouse> houses = houseMapper.selectList(null);
        Map<String, Long> layoutCount = new LinkedHashMap<>();
        Map<String, Long> areaCount = new LinkedHashMap<>(Map.of(
            "≤70㎡", 0L, "70-90㎡", 0L, ">90㎡", 0L));

        for (CmHouse house : houses) {
            String layout = StringUtils.hasText(house.getLayout()) ? house.getLayout() : "未知户型";
            layoutCount.merge(layout, 1L, Long::sum);
            if (house.getArea() == null) {
                areaCount.merge("≤70㎡", 1L, Long::sum);
            } else {
                double area = house.getArea().doubleValue();
                if (area <= 70) {
                    areaCount.merge("≤70㎡", 1L, Long::sum);
                } else if (area <= 90) {
                    areaCount.merge("70-90㎡", 1L, Long::sum);
                } else {
                    areaCount.merge(">90㎡", 1L, Long::sum);
                }
            }
        }

        List<Map<String, Object>> byLayout = layoutCount.entrySet().stream()
            .sorted((a, b) -> Long.compare(b.getValue(), a.getValue()))
            .map(e -> {
                Map<String, Object> m = new HashMap<>();
                m.put("name", e.getKey());
                m.put("value", e.getValue());
                return m;
            }).collect(Collectors.toList());

        List<Map<String, Object>> byAreaRange = areaCount.entrySet().stream()
            .map(e -> Map.<String, Object>of("name", e.getKey(), "value", e.getValue()))
            .collect(Collectors.toList());

        List<Map<String, Object>> byOccupancy = jdbcTemplate.queryForList(
            "SELECT CASE r.living_status WHEN '1' THEN '在住' WHEN '2' THEN '空置' WHEN '3' THEN '出租' ELSE '其他' END AS name, "
                + "COUNT(DISTINCT h.house_id) AS value FROM cm_house h "
                + "LEFT JOIN cm_resident r ON h.house_id = r.house_id AND r.del_flag='0' "
                + "GROUP BY r.living_status");

        Map<String, Object> result = new HashMap<>();
        result.put("byLayout", byLayout);
        result.put("byAreaRange", byAreaRange);
        result.put("byOccupancy", byOccupancy);
        return result;
    }

    /**
     * AI 安全预测：综合报修、预警、设施状态，输出预防性维护建议
     */
    public Map<String, Object> getAiSafetyPrediction() {
        List<Map<String, Object>> buildingRepairs = jdbcTemplate.queryForList(
            "SELECT b.building_no AS name, b.building_id AS buildingId, COUNT(o.order_id) AS repairCount "
                + "FROM rp_order o JOIN cm_house h ON o.house_id = h.house_id "
                + "JOIN cm_building b ON h.building_id = b.building_id "
                + "GROUP BY b.building_id, b.building_no ORDER BY repairCount DESC LIMIT 8");

        List<Map<String, Object>> typeHotspots = jdbcTemplate.queryForList(
            "SELECT COALESCE(rt.type_name, o.ai_type_label, '未分类') AS name, COUNT(*) AS value, "
                + "SUM(CASE WHEN o.duplicate_flag = 1 THEN 1 ELSE 0 END) AS duplicateCount "
                + "FROM rp_order o LEFT JOIN rp_repair_type rt ON o.type_id = rt.type_id "
                + "GROUP BY o.type_id, rt.type_name, o.ai_type_label ORDER BY value DESC LIMIT 6");

        long pendingDeviceAlerts = alertMapper.selectCount(new LambdaQueryWrapper<ElAlert>()
            .eq(ElAlert::getStatus, "pending")
            .in(ElAlert::getAlertType, "device_offline", "device_fault", "device_battery_low"));
        long pendingElderAlerts = alertMapper.selectCount(new LambdaQueryWrapper<ElAlert>()
            .eq(ElAlert::getStatus, "pending")
            .notIn(ElAlert::getAlertType, "device_offline", "device_fault", "device_battery_low"));

        List<Map<String, Object>> riskBuildings = new ArrayList<>();
        for (Map<String, Object> row : buildingRepairs) {
            Long buildingId = row.get("buildingId") != null ? ((Number) row.get("buildingId")).longValue() : null;
            long repairCount = row.get("repairCount") != null ? ((Number) row.get("repairCount")).longValue() : 0;
            long alertCount = countBuildingAlerts(buildingId);
            int score = (int) Math.min(100, repairCount * 8 + alertCount * 15 + pendingDeviceAlerts);
            Map<String, Object> item = new LinkedHashMap<>();
            item.put("name", row.get("name"));
            item.put("score", score);
            item.put("repairCount", repairCount);
            item.put("alertCount", alertCount);
            item.put("level", score >= 70 ? "高" : score >= 40 ? "中" : "低");
            riskBuildings.add(item);
        }

        List<Map<String, Object>> hotSpots = new ArrayList<>();
        for (Map<String, Object> row : typeHotspots) {
            long dup = row.get("duplicateCount") != null ? ((Number) row.get("duplicateCount")).longValue() : 0;
            if (dup <= 0 && ((Number) row.get("value")).longValue() < 2) {
                continue;
            }
            Map<String, Object> spot = new LinkedHashMap<>();
            spot.put("name", row.get("name"));
            spot.put("count", row.get("value"));
            spot.put("duplicateCount", dup);
            spot.put("suggestion", dup > 0
                ? "同类故障反复出现，建议开展专项排查与预防性维护"
                : "报修频次偏高，建议增加巡检频次");
            hotSpots.add(spot);
        }

        List<Map<String, Object>> suggestions = buildPreventiveSuggestions(
            riskBuildings, hotSpots, pendingDeviceAlerts, pendingElderAlerts);

        String overview = buildPredictionOverview(riskBuildings, hotSpots, pendingDeviceAlerts, pendingElderAlerts);

        Map<String, Object> result = new LinkedHashMap<>();
        result.put("overview", overview);
        result.put("riskBuildings", riskBuildings);
        result.put("hotSpots", hotSpots);
        result.put("suggestions", suggestions);
        result.put("pendingDeviceAlerts", pendingDeviceAlerts);
        result.put("pendingElderAlerts", pendingElderAlerts);
        return result;
    }

    private long countBuildingAlerts(Long buildingId) {
        if (buildingId == null) {
            return 0;
        }
        Long count = jdbcTemplate.queryForObject(
            "SELECT COUNT(a.alert_id) FROM el_alert a "
                + "JOIN cm_resident r ON a.resident_id = r.resident_id "
                + "JOIN cm_house h ON r.house_id = h.house_id "
                + "WHERE h.building_id = ? AND a.status IN ('pending','processing')",
            Long.class, buildingId);
        return count == null ? 0 : count;
    }

    private String resolveAgeGroup(Integer age) {
        if (age == null) {
            return "青年(18-44)";
        }
        if (age < 18) {
            return "少年儿童(0-17)";
        }
        if (age < 45) {
            return "青年(18-44)";
        }
        if (age < 60) {
            return "中年(45-59)";
        }
        return "老年(60+)";
    }

    private List<Map<String, Object>> buildPreventiveSuggestions(
        List<Map<String, Object>> riskBuildings,
        List<Map<String, Object>> hotSpots,
        long pendingDeviceAlerts,
        long pendingElderAlerts) {
        List<Map<String, Object>> list = new ArrayList<>();
        if (!riskBuildings.isEmpty()) {
            Map<String, Object> top = riskBuildings.get(0);
            list.add(Map.of(
                "title", "重点楼栋预防巡检",
                "level", top.get("level"),
                "content", "「" + top.get("name") + "」综合风险较高（报修 "
                    + top.get("repairCount") + " 单、在途预警 " + top.get("alertCount")
                    + " 条），建议本周内开展公区与户内联合巡检。"));
        }
        for (int i = 0; i < Math.min(2, hotSpots.size()); i++) {
            Map<String, Object> spot = hotSpots.get(i);
            list.add(Map.of(
                "title", "高频故障点位",
                "level", "中",
                "content", "「" + spot.get("name") + "」累计报修 " + spot.get("count")
                    + " 次" + (((Number) spot.get("duplicateCount")).longValue() > 0 ? "，含重复报修" : "")
                    + "，" + spot.get("suggestion") + "。"));
        }
        if (pendingDeviceAlerts > 0) {
            list.add(Map.of(
                "title", "公共设施预警",
                "level", "高",
                "content", "当前有 " + pendingDeviceAlerts
                    + " 条设备类预警待处理，建议优先排查电梯、监控、道闸等公区设施。"));
        }
        if (pendingElderAlerts > 0) {
            list.add(Map.of(
                "title", "独居老人关怀",
                "level", "中",
                "content", "有 " + pendingElderAlerts
                    + " 条老人安全预警待跟进，建议结合水电监测数据上门复核。"));
        }
        list.add(Map.of(
            "title", "由被动转主动",
            "level", "低",
            "content", "基于报修与预警趋势，对高频类型提前备件、对高风险楼栋增派巡检，降低突发报修与紧急预警。"));
        return list;
    }

    private String buildPredictionOverview(
        List<Map<String, Object>> riskBuildings,
        List<Map<String, Object>> hotSpots,
        long pendingDeviceAlerts,
        long pendingElderAlerts) {
        String buildingBrief = riskBuildings.isEmpty() ? "暂无" :
            riskBuildings.stream().limit(3)
                .map(b -> b.get("name") + "(风险" + b.get("level") + ")")
                .collect(Collectors.joining("、"));
        String hotspotBrief = hotSpots.isEmpty() ? "暂无" :
            hotSpots.stream().limit(3).map(h -> (String) h.get("name")).collect(Collectors.joining("、"));
        String brief = """
            高风险楼栋：%s；高频故障：%s；待处理设备预警 %d 条、老人预警 %d 条。
            """.formatted(buildingBrief, hotspotBrief, pendingDeviceAlerts, pendingElderAlerts);
        if (zhipuAiClient.isAvailable()) {
            try {
                return zhipuAiClient.chatSimple(
                    "你是智慧社区 AI 安全顾问。根据数据用 2-3 句话概括风险并强调预防性维护，不要 markdown。",
                    brief);
            } catch (Exception ignored) {
                // fallback
            }
        }
        return "AI 智能体已综合报修分布、预警信息与设施运行状态：当前需重点关注 "
            + buildingBrief + " 等楼栋，以及 " + hotspotBrief
            + " 等高频故障类型，建议由被动维修转向主动预防性维护。";
    }
}
