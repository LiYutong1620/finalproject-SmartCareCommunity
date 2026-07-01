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
import java.time.YearMonth;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class RepairAnalyticsService {

    private final RpOrderMapper orderMapper;
    private final RpOrderEvalMapper evalMapper;
    private final RpOrderProgressMapper progressMapper;

    public Map<String, Object> monthlyTrend(int months) {
        int size = months <= 0 ? 6 : months;
        List<String> labels = new ArrayList<>();
        List<BigDecimal> scoreTrend = new ArrayList<>();
        List<BigDecimal> overtimeTrend = new ArrayList<>();
        List<Integer> orderTrend = new ArrayList<>();

        YearMonth current = YearMonth.now();
        for (int i = size - 1; i >= 0; i--) {
            YearMonth month = current.minusMonths(i);
            LocalDateTime start = month.atDay(1).atStartOfDay();
            LocalDateTime end = month.atEndOfMonth().atTime(23, 59, 59);
            labels.add(month.toString());

            List<RpOrder> orders = orderMapper.selectList(new LambdaQueryWrapper<RpOrder>()
                .ge(RpOrder::getCreateTime, start)
                .le(RpOrder::getCreateTime, end));
            orderTrend.add(orders.size());

            List<RpOrder> completed = orders.stream()
                .filter(o -> "completed".equals(o.getStatus()))
                .toList();
            int overtimeCount = 0;
            for (RpOrder order : completed) {
                double hours = calcCompleteHours(order);
                int promise = order.getPromiseHours() == null ? 24 : order.getPromiseHours();
                if (hours > promise) {
                    overtimeCount++;
                }
            }
            BigDecimal overtimeRate = completed.isEmpty() ? BigDecimal.ZERO
                : BigDecimal.valueOf(overtimeCount * 100.0 / completed.size()).setScale(2, RoundingMode.HALF_UP);
            overtimeTrend.add(overtimeRate);

            List<RpOrderEval> evals = evalMapper.selectList(new LambdaQueryWrapper<RpOrderEval>()
                .ge(RpOrderEval::getCreateTime, start)
                .le(RpOrderEval::getCreateTime, end));
            if (evals.isEmpty()) {
                scoreTrend.add(BigDecimal.ZERO);
            } else {
                double avg = evals.stream()
                    .filter(e -> e.getScore() != null)
                    .mapToInt(RpOrderEval::getScore)
                    .average()
                    .orElse(0);
                scoreTrend.add(BigDecimal.valueOf(avg).setScale(2, RoundingMode.HALF_UP));
            }
        }

        Map<String, Object> result = new LinkedHashMap<>();
        result.put("labels", labels);
        result.put("scoreTrend", scoreTrend);
        result.put("overtimeTrend", overtimeTrend);
        result.put("orderTrend", orderTrend);
        return result;
    }

    private double calcCompleteHours(RpOrder order) {
        LocalDateTime start = order.getCreateTime();
        LocalDateTime end = order.getUpdateTime() != null ? order.getUpdateTime() : LocalDateTime.now();
        List<RpOrderProgress> progress = progressMapper.selectList(new LambdaQueryWrapper<RpOrderProgress>()
            .eq(RpOrderProgress::getOrderId, order.getOrderId())
            .orderByAsc(RpOrderProgress::getCreateTime));
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
}
