package com.smartcare.business.repair.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.smartcare.business.repair.domain.RpOrder;
import com.smartcare.business.repair.domain.RpOrderEval;
import com.smartcare.business.repair.domain.RpOrderProgress;
import com.smartcare.business.repair.domain.RpRepairWeeklyReport;
import com.smartcare.business.repair.mapper.RpOrderEvalMapper;
import com.smartcare.business.repair.mapper.RpOrderMapper;
import com.smartcare.business.repair.mapper.RpOrderProgressMapper;
import com.smartcare.business.repair.mapper.RpRepairWeeklyReportMapper;
import com.smartcare.framework.ai.ZhipuAiClient;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class RepairReportService {

    private final RpRepairWeeklyReportMapper reportMapper;
    private final RpOrderMapper orderMapper;
    private final RpOrderEvalMapper evalMapper;
    private final RpOrderProgressMapper progressMapper;
    private final ZhipuAiClient zhipuAiClient;
    private final ObjectMapper objectMapper;

    public Page<RpRepairWeeklyReport> pageReports(int pageNum, int pageSize) {
        return reportMapper.selectPage(new Page<>(pageNum, pageSize),
            new LambdaQueryWrapper<RpRepairWeeklyReport>().orderByDesc(RpRepairWeeklyReport::getCreateTime));
    }

    @Transactional
    public RpRepairWeeklyReport generateWeeklyReport(LocalDate weekStart) {
        LocalDate start = weekStart != null ? weekStart : previousMonday(LocalDate.now());
        LocalDate end = start.plusDays(6);
        LocalDateTime startTime = start.atStartOfDay();
        LocalDateTime endTime = end.atTime(23, 59, 59);

        List<RpOrder> orders = orderMapper.selectList(new LambdaQueryWrapper<RpOrder>()
            .ge(RpOrder::getCreateTime, startTime)
            .le(RpOrder::getCreateTime, endTime));

        int total = orders.size();
        int completed = 0;
        int overtime = 0;
        int duplicate = 0;
        double totalHours = 0;
        Map<String, List<Double>> typeHours = new HashMap<>();
        Map<Long, List<Double>> workerHours = new HashMap<>();

        for (RpOrder order : orders) {
            if (order.getDuplicateFlag() != null && order.getDuplicateFlag() == 1) {
                duplicate++;
            }
            if (!"completed".equals(order.getStatus())) {
                continue;
            }
            completed++;
            double hours = calcCompleteHours(order);
            totalHours += hours;
            int promise = order.getPromiseHours() == null ? 24 : order.getPromiseHours();
            if (hours > promise) {
                overtime++;
            }
            String typeLabel = StringUtils.hasText(order.getAiTypeLabel()) ? order.getAiTypeLabel() : "其他";
            typeHours.computeIfAbsent(typeLabel, k -> new ArrayList<>()).add(hours);
            if (order.getWorkerId() != null) {
                workerHours.computeIfAbsent(order.getWorkerId(), k -> new ArrayList<>()).add(hours);
            }
        }

        BigDecimal avgHours = completed == 0 ? BigDecimal.ZERO
            : BigDecimal.valueOf(totalHours / completed).setScale(2, RoundingMode.HALF_UP);
        BigDecimal overtimeRate = completed == 0 ? BigDecimal.ZERO
            : BigDecimal.valueOf(overtime * 100.0 / completed).setScale(2, RoundingMode.HALF_UP);
        BigDecimal duplicateRate = total == 0 ? BigDecimal.ZERO
            : BigDecimal.valueOf(duplicate * 100.0 / total).setScale(2, RoundingMode.HALF_UP);
        BigDecimal goodRate = calcGoodRate(startTime, endTime);

        String typeStats = toJson(buildAvgStats(typeHours));
        String workerStats = toJson(buildWorkerStats(workerHours));
        String suggestions = buildSuggestions(total, completed, overtimeRate, duplicateRate, goodRate, avgHours);

        RpRepairWeeklyReport report = new RpRepairWeeklyReport();
        report.setWeekStart(start);
        report.setWeekEnd(end);
        report.setTotalOrders(total);
        report.setAvgCompleteHours(avgHours);
        report.setOvertimeRate(overtimeRate);
        report.setDuplicateRate(duplicateRate);
        report.setGoodRate(goodRate);
        report.setTypeStats(typeStats);
        report.setWorkerStats(workerStats);
        report.setSuggestions(suggestions);
        report.setCreateTime(LocalDateTime.now());
        reportMapper.insert(report);
        return report;
    }

    private double calcCompleteHours(RpOrder order) {
        List<RpOrderProgress> progress = progressMapper.selectList(new LambdaQueryWrapper<RpOrderProgress>()
            .eq(RpOrderProgress::getOrderId, order.getOrderId())
            .orderByAsc(RpOrderProgress::getCreateTime));
        LocalDateTime start = order.getCreateTime();
        LocalDateTime end = order.getUpdateTime() != null ? order.getUpdateTime() : LocalDateTime.now();
        for (RpOrderProgress item : progress) {
            if ("验收完成".equals(item.getNodeName()) && item.getCreateTime() != null) {
                end = item.getCreateTime();
                break;
            }
        }
        if (start == null) {
            return 0;
        }
        return ChronoUnit.MINUTES.between(start, end) / 60.0;
    }

    private BigDecimal calcGoodRate(LocalDateTime start, LocalDateTime end) {
        List<RpOrderEval> evals = evalMapper.selectList(new LambdaQueryWrapper<RpOrderEval>()
            .ge(RpOrderEval::getCreateTime, start)
            .le(RpOrderEval::getCreateTime, end));
        if (evals.isEmpty()) {
            return BigDecimal.ZERO;
        }
        long good = evals.stream().filter(e -> e.getScore() != null && e.getScore() >= 4).count();
        return BigDecimal.valueOf(good * 100.0 / evals.size()).setScale(2, RoundingMode.HALF_UP);
    }

    private Map<String, BigDecimal> buildAvgStats(Map<String, List<Double>> grouped) {
        Map<String, BigDecimal> result = new LinkedHashMap<>();
        grouped.forEach((key, values) -> {
            double avg = values.stream().mapToDouble(Double::doubleValue).average().orElse(0);
            result.put(key, BigDecimal.valueOf(avg).setScale(2, RoundingMode.HALF_UP));
        });
        return result;
    }

    private Map<String, BigDecimal> buildWorkerStats(Map<Long, List<Double>> grouped) {
        Map<String, BigDecimal> result = new LinkedHashMap<>();
        grouped.forEach((workerId, values) -> {
            double avg = values.stream().mapToDouble(Double::doubleValue).average().orElse(0);
            result.put("worker-" + workerId, BigDecimal.valueOf(avg).setScale(2, RoundingMode.HALF_UP));
        });
        return result;
    }

    private String buildSuggestions(int total, int completed, BigDecimal overtimeRate,
                                    BigDecimal duplicateRate, BigDecimal goodRate, BigDecimal avgHours) {
        String summary = """
            本周工单总数=%d，完成=%d，平均完成时长=%s小时，超时率=%s%%，重复报修率=%s%%，好评率=%s%%。
            请基于这些数据给出3条可执行的物业维修优化建议。
            """.formatted(total, completed, avgHours, overtimeRate, duplicateRate, goodRate);
        if (zhipuAiClient.isAvailable()) {
            try {
                return zhipuAiClient.chatSimple(
                    "你是智慧社区物业运营顾问，请根据工单数据给出简洁可执行的优化建议，分点输出。",
                    summary);
            } catch (Exception ignored) {
                // fallback below
            }
        }
        List<String> tips = new ArrayList<>();
        if (overtimeRate.compareTo(BigDecimal.valueOf(20)) > 0) {
            tips.add("建议增加夜间维修班次或高峰时段备勤人员，降低超时率。");
        }
        if (duplicateRate.compareTo(BigDecimal.valueOf(10)) > 0) {
            tips.add("建议对重复报修点位开展专项排查，减少同类故障反复出现。");
        }
        if (goodRate.compareTo(BigDecimal.valueOf(85)) < 0) {
            tips.add("建议加强维修工服务培训，并优化派单匹配规则。");
        }
        if (tips.isEmpty()) {
            tips.add("当前整体运行平稳，建议继续保持自动派单与AI分类策略。");
        }
        return String.join("\n", tips);
    }

    private String toJson(Object value) {
        try {
            return objectMapper.writeValueAsString(value);
        } catch (JsonProcessingException e) {
            return "{}";
        }
    }

    private LocalDate previousMonday(LocalDate today) {
        LocalDate date = today.minusWeeks(1);
        while (date.getDayOfWeek() != DayOfWeek.MONDAY) {
            date = date.minusDays(1);
        }
        return date;
    }
}
