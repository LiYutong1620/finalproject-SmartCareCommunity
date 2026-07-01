package com.smartcare.business.dashboard.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.smartcare.business.elder.domain.ElAlert;
import com.smartcare.business.elder.domain.ElCareOrder;
import com.smartcare.business.elder.domain.ElCareStaff;
import com.smartcare.business.elder.mapper.ElAlertMapper;
import com.smartcare.business.elder.mapper.ElCareOrderMapper;
import com.smartcare.business.elder.mapper.ElCareStaffMapper;
import com.smartcare.business.property.domain.CmBuilding;
import com.smartcare.business.property.domain.CmHouse;
import com.smartcare.business.property.domain.CmResident;
import com.smartcare.business.property.mapper.CmBuildingMapper;
import com.smartcare.business.property.mapper.CmHouseMapper;
import com.smartcare.business.property.mapper.CmResidentMapper;
import com.smartcare.business.repair.domain.RpOrder;
import com.smartcare.business.repair.mapper.RpOrderMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;

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
    private final ElCareStaffMapper careStaffMapper;
    private final CmResidentMapper residentMapper;
    private final CmBuildingMapper buildingMapper;
    private final CmHouseMapper houseMapper;
    private final JdbcTemplate jdbcTemplate;

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

        data.put("totalOrders", totalOrders);
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

        // --- 独居老人数（年龄>=60且备注含"独居"） ---
        List<CmResident> elders = residentMapper.selectList(
            new LambdaQueryWrapper<CmResident>()
                .ge(CmResident::getAge, 60)
                .eq(CmResident::getDelFlag, "0"));
        long livingAloneCount = elders.stream()
            .filter(r -> r.getRemark() != null && r.getRemark().contains("独居"))
            .count();

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
        data.put("highRiskAlertCount", highRiskAlertCount);
        data.put("todayNewAlerts", todayNewAlerts);
        data.put("careCompletionRate", careCompletionRate);
        return data;
    }

    /**
     * 预警趋势：近30天每日预警数量
     */
    public List<Map<String, Object>> getAlertTrend() {
        LocalDateTime startDate = LocalDate.now().minusDays(29).atStartOfDay();
        List<ElAlert> alerts = alertMapper.selectList(
            new LambdaQueryWrapper<ElAlert>().ge(ElAlert::getCreateTime, startDate));

        Map<String, Long> dailyCount = alerts.stream()
            .collect(Collectors.groupingBy(
                a -> a.getCreateTime().toLocalDate().format(DATE_FMT),
                Collectors.counting()));

        return buildTrendList(dailyCount);
    }

    /**
     * 工单趋势：近30天每日工单数量
     */
    public List<Map<String, Object>> getOrderTrend() {
        LocalDateTime startDate = LocalDate.now().minusDays(29).atStartOfDay();
        List<RpOrder> orders = orderMapper.selectList(
            new LambdaQueryWrapper<RpOrder>().ge(RpOrder::getCreateTime, startDate));

        Map<String, Long> dailyCount = orders.stream()
            .collect(Collectors.groupingBy(
                o -> o.getCreateTime().toLocalDate().format(DATE_FMT),
                Collectors.counting()));

        return buildTrendList(dailyCount);
    }

    /**
     * 关怀人员绩效：姓名、关怀工单数、完成数、完成率
     */
    public List<Map<String, Object>> getStaffPerformance() {
        List<ElCareStaff> staffList = careStaffMapper.selectList(null);
        if (staffList.isEmpty()) {
            return Collections.emptyList();
        }

        // 一次性查出所有关怀工单，在内存中按 assigneeId 分组
        List<ElCareOrder> allOrders = careOrderMapper.selectList(null);
        Map<Long, List<ElCareOrder>> ordersByStaff = allOrders.stream()
            .filter(o -> o.getAssigneeId() != null)
            .collect(Collectors.groupingBy(ElCareOrder::getAssigneeId));

        List<Map<String, Object>> result = new ArrayList<>();
        for (ElCareStaff staff : staffList) {
            List<ElCareOrder> staffOrders = ordersByStaff.getOrDefault(staff.getStaffId(), Collections.emptyList());
            int total = staffOrders.size();
            long completed = staffOrders.stream().filter(o -> "completed".equals(o.getStatus())).count();
            double rate = total == 0 ? 0 : Math.round(completed * 10000.0 / total) / 100.0;

            Map<String, Object> item = new HashMap<>();
            item.put("name", staff.getName());
            item.put("totalCareOrders", total);
            item.put("completedOrders", completed);
            item.put("completionRate", rate);
            result.add(item);
        }
        return result;
    }

    /**
     * 高风险老人TOP10：姓名、年龄、预警次数、最近预警时间
     */
    public List<Map<String, Object>> getRiskResidents() {
        List<ElAlert> allAlerts = alertMapper.selectList(null);
        if (allAlerts.isEmpty()) {
            return Collections.emptyList();
        }

        // 按住户ID分组统计预警次数和最近预警时间
        Map<Long, List<ElAlert>> alertsByResident = allAlerts.stream()
            .collect(Collectors.groupingBy(ElAlert::getResidentId));

        // 查询所有相关住户信息
        Set<Long> residentIds = alertsByResident.keySet();
        List<CmResident> residents = residentMapper.selectList(
            new LambdaQueryWrapper<CmResident>().in(CmResident::getResidentId, residentIds));
        Map<Long, CmResident> residentMap = residents.stream()
            .collect(Collectors.toMap(CmResident::getResidentId, r -> r));

        // 构建结果并按预警次数降序排序，取TOP10
        List<Map<String, Object>> result = new ArrayList<>();
        for (Map.Entry<Long, List<ElAlert>> entry : alertsByResident.entrySet()) {
            Long residentId = entry.getKey();
            List<ElAlert> residentAlerts = entry.getValue();
            CmResident resident = residentMap.get(residentId);

            Map<String, Object> item = new HashMap<>();
            item.put("name", resident != null ? resident.getName() : "未知");
            item.put("age", resident != null && resident.getAge() != null ? resident.getAge() : 0);
            item.put("alertCount", residentAlerts.size());
            // 最近预警时间
            LocalDateTime latestTime = residentAlerts.stream()
                .map(ElAlert::getCreateTime)
                .filter(Objects::nonNull)
                .max(LocalDateTime::compareTo)
                .orElse(null);
            item.put("lastAlertTime", latestTime != null ? latestTime.format(DATETIME_FMT) : "");
            result.add(item);
        }

        result.sort((a, b) -> Integer.compare(
            (Integer) b.get("alertCount"), (Integer) a.get("alertCount")));

        return result.size() > 10 ? result.subList(0, 10) : result;
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
     * 构建近30天的趋势列表（补齐无数据的日期为0）
     */
    private List<Map<String, Object>> buildTrendList(Map<String, Long> dailyCount) {
        List<Map<String, Object>> trend = new ArrayList<>();
        LocalDate today = LocalDate.now();
        for (int i = 29; i >= 0; i--) {
            LocalDate date = today.minusDays(i);
            String dateStr = date.format(DATE_FMT);
            Map<String, Object> item = new HashMap<>();
            item.put("date", dateStr);
            item.put("count", dailyCount.getOrDefault(dateStr, 0L));
            trend.add(item);
        }
        return trend;
    }
}
