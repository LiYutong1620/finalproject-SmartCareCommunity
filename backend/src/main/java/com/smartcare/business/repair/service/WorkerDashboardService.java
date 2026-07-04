package com.smartcare.business.repair.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.smartcare.business.repair.domain.RpOrder;
import com.smartcare.business.repair.domain.RpOrderEval;
import com.smartcare.business.repair.domain.RpOrderProgress;
import com.smartcare.business.repair.mapper.RpOrderEvalMapper;
import com.smartcare.business.repair.mapper.RpOrderMapper;
import com.smartcare.business.repair.mapper.RpOrderProgressMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Set;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class WorkerDashboardService {

    private static final DateTimeFormatter DATE_LABEL = DateTimeFormatter.ofPattern("MM-dd");

    private final RpOrderMapper orderMapper;
    private final RpOrderProgressMapper progressMapper;
    private final RpOrderEvalMapper evalMapper;

    public Map<String, Object> getDashboard(Long workerId, int trendDays) {
        int days = trendDays == 30 ? 30 : 7;
        List<Long> completedOrderIds = findCompletedOrderIds(workerId);

        Map<String, Object> data = new HashMap<>();
        data.put("pendingTotal", countPendingTotal(workerId));
        data.put("completedTotal", completedOrderIds.size());
        data.put("goodRateTotal", calcGoodRate(completedOrderIds));
        data.put("trend", buildTrend(workerId, days));
        data.put("evalSummary", buildEvalSummary(workerId, completedOrderIds));
        return data;
    }

    /** 累计评价详情（从近到远） */
    public Map<String, Object> getEvaluations(Long workerId) {
        List<Long> completedOrderIds = findCompletedOrderIds(workerId);
        Map<String, Object> result = new LinkedHashMap<>();
        if (completedOrderIds.isEmpty()) {
            result.put("stats", emptyEvalStats());
            result.put("evaluations", List.of());
            return result;
        }

        Map<Long, RpOrder> orderMap = orderMapper.selectList(new LambdaQueryWrapper<RpOrder>()
                .eq(RpOrder::getWorkerId, workerId)
                .in(RpOrder::getOrderId, completedOrderIds))
            .stream()
            .collect(Collectors.toMap(RpOrder::getOrderId, o -> o, (a, b) -> a));

        List<RpOrderEval> evals = evalMapper.selectList(new LambdaQueryWrapper<RpOrderEval>()
            .in(RpOrderEval::getOrderId, completedOrderIds)
            .orderByDesc(RpOrderEval::getCreateTime));

        result.put("stats", buildEvalStats(evals));
        result.put("evaluations", evals.stream().map(e -> toEvalRow(e, orderMap)).toList());
        return result;
    }

    private Map<String, Object> emptyEvalStats() {
        Map<String, Object> stats = new LinkedHashMap<>();
        stats.put("evalCount", 0);
        stats.put("avgScore", BigDecimal.ZERO);
        stats.put("goodRate", BigDecimal.ZERO);
        stats.put("neutralRate", BigDecimal.ZERO);
        stats.put("badRate", BigDecimal.ZERO);
        stats.put("comprehensiveGoodRate", BigDecimal.ZERO);
        return stats;
    }

    private Map<String, Object> buildEvalStats(List<RpOrderEval> evals) {
        Map<String, Object> stats = new LinkedHashMap<>();
        if (evals.isEmpty()) {
            return emptyEvalStats();
        }
        int total = evals.size();
        long good = evals.stream().filter(e -> e.getScore() != null && e.getScore() >= 4).count();
        long neutral = evals.stream().filter(e -> e.getScore() != null && e.getScore() == 3).count();
        long bad = evals.stream().filter(e -> e.getScore() != null && e.getScore() <= 2).count();
        double avg = evals.stream()
            .map(RpOrderEval::getScore)
            .filter(Objects::nonNull)
            .mapToInt(Integer::intValue)
            .average()
            .orElse(0);

        stats.put("evalCount", total);
        stats.put("avgScore", BigDecimal.valueOf(avg).setScale(1, RoundingMode.HALF_UP));
        stats.put("goodRate", ratePercent(good, total));
        stats.put("neutralRate", ratePercent(neutral, total));
        stats.put("badRate", ratePercent(bad, total));
        stats.put("comprehensiveGoodRate", ratePercent(good, total));
        return stats;
    }

    private BigDecimal ratePercent(long part, int total) {
        if (total == 0) {
            return BigDecimal.ZERO;
        }
        return BigDecimal.valueOf(part * 100.0 / total).setScale(1, RoundingMode.HALF_UP);
    }

    private Map<String, Object> toEvalRow(RpOrderEval eval, Map<Long, RpOrder> orderMap) {
        Map<String, Object> row = new LinkedHashMap<>();
        RpOrder order = orderMap.get(eval.getOrderId());
        Integer score = eval.getScore();
        row.put("orderId", eval.getOrderId());
        row.put("orderNo", order != null ? order.getOrderNo() : "");
        row.put("score", score);
        row.put("tags", eval.getTags());
        row.put("content", eval.getContent());
        row.put("createTime", eval.getCreateTime());
        if (score != null && score >= 4) {
            row.put("type", "good");
        } else if (score != null && score <= 2) {
            row.put("type", "bad");
        } else {
            row.put("type", "neutral");
        }
        return row;
    }

    private int countPendingTotal(Long workerId) {
        Long count = orderMapper.selectCount(new LambdaQueryWrapper<RpOrder>()
            .eq(RpOrder::getWorkerId, workerId)
            .in(RpOrder::getStatus, "assigned", "processing", "wait_accept"));
        return count != null ? count.intValue() : 0;
    }

    private List<Long> findCompletedOrderIds(Long workerId) {
        return orderMapper.selectList(new LambdaQueryWrapper<RpOrder>()
                .eq(RpOrder::getWorkerId, workerId)
                .eq(RpOrder::getStatus, "completed")
                .select(RpOrder::getOrderId))
            .stream()
            .map(RpOrder::getOrderId)
            .toList();
    }

    private BigDecimal calcGoodRate(List<Long> completedOrderIds) {
        if (completedOrderIds.isEmpty()) {
            return BigDecimal.ZERO;
        }
        List<RpOrderEval> evals = evalMapper.selectList(new LambdaQueryWrapper<RpOrderEval>()
            .in(RpOrderEval::getOrderId, completedOrderIds));
        if (evals.isEmpty()) {
            return BigDecimal.ZERO;
        }
        long good = evals.stream().filter(e -> e.getScore() != null && e.getScore() >= 4).count();
        return BigDecimal.valueOf(good * 100.0 / evals.size()).setScale(1, RoundingMode.HALF_UP);
    }

    private List<Map<String, Object>> buildTrend(Long workerId, int days) {
        List<Map<String, Object>> trend = new ArrayList<>();
        LocalDate today = LocalDate.now();
        for (int i = days - 1; i >= 0; i--) {
            LocalDate day = today.minusDays(i);
            LocalDateTime start = day.atStartOfDay();
            LocalDateTime end = start.plusDays(1).minusNanos(1);
            int count = countCompletedOnDay(workerId, start, end);
            Map<String, Object> point = new HashMap<>();
            point.put("date", day.format(DATE_LABEL));
            point.put("count", count);
            trend.add(point);
        }
        return trend;
    }

    private int countCompletedOnDay(Long workerId, LocalDateTime start, LocalDateTime end) {
        List<RpOrderProgress> accepted = progressMapper.selectList(new LambdaQueryWrapper<RpOrderProgress>()
            .eq(RpOrderProgress::getNodeName, "验收完成")
            .ge(RpOrderProgress::getCreateTime, start)
            .le(RpOrderProgress::getCreateTime, end));
        if (accepted.isEmpty()) {
            return 0;
        }
        Set<Long> orderIds = accepted.stream().map(RpOrderProgress::getOrderId).collect(Collectors.toSet());
        Long count = orderMapper.selectCount(new LambdaQueryWrapper<RpOrder>()
            .eq(RpOrder::getWorkerId, workerId)
            .eq(RpOrder::getStatus, "completed")
            .in(RpOrder::getOrderId, orderIds));
        return count != null ? count.intValue() : 0;
    }

    private Map<String, Object> buildEvalSummary(Long workerId, List<Long> completedOrderIds) {
        Map<String, Object> summary = new LinkedHashMap<>();
        if (completedOrderIds.isEmpty()) {
            summary.put("evalCount", 0);
            summary.put("avgScore", BigDecimal.ZERO);
            summary.put("goodRate", BigDecimal.ZERO);
            summary.put("recentEvals", List.of());
            return summary;
        }
        Map<Long, RpOrder> orderMap = orderMapper.selectList(new LambdaQueryWrapper<RpOrder>()
                .eq(RpOrder::getWorkerId, workerId)
                .in(RpOrder::getOrderId, completedOrderIds))
            .stream()
            .collect(Collectors.toMap(RpOrder::getOrderId, o -> o, (a, b) -> a));

        List<RpOrderEval> evals = evalMapper.selectList(new LambdaQueryWrapper<RpOrderEval>()
            .in(RpOrderEval::getOrderId, completedOrderIds)
            .orderByDesc(RpOrderEval::getCreateTime));

        summary.put("evalCount", evals.size());
        if (evals.isEmpty()) {
            summary.put("avgScore", BigDecimal.ZERO);
            summary.put("goodRate", BigDecimal.ZERO);
            summary.put("recentEvals", List.of());
            return summary;
        }

        double avg = evals.stream()
            .map(RpOrderEval::getScore)
            .filter(Objects::nonNull)
            .mapToInt(Integer::intValue)
            .average()
            .orElse(0);
        summary.put("avgScore", BigDecimal.valueOf(avg).setScale(1, RoundingMode.HALF_UP));
        summary.put("goodRate", calcGoodRate(completedOrderIds));

        List<Map<String, Object>> recent = evals.stream()
            .limit(3)
            .map(eval -> {
                Map<String, Object> row = new LinkedHashMap<>();
                RpOrder order = orderMap.get(eval.getOrderId());
                row.put("orderId", eval.getOrderId());
                row.put("orderNo", order != null ? order.getOrderNo() : "");
                row.put("score", eval.getScore());
                row.put("tags", eval.getTags());
                row.put("content", eval.getContent());
                row.put("createTime", eval.getCreateTime());
                return row;
            })
            .toList();
        summary.put("recentEvals", recent);
        return summary;
    }
}
