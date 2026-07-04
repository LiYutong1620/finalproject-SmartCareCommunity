package com.smartcare.business.repair.service;



import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;

import com.fasterxml.jackson.core.JsonProcessingException;

import com.fasterxml.jackson.databind.JsonNode;

import com.fasterxml.jackson.databind.ObjectMapper;

import com.fasterxml.jackson.databind.node.ArrayNode;

import com.fasterxml.jackson.databind.node.ObjectNode;

import com.smartcare.business.repair.domain.RpOrder;

import com.smartcare.business.repair.domain.RpOrderEval;

import com.smartcare.business.repair.domain.RpOrderProgress;

import com.smartcare.business.repair.domain.RpRepairType;

import com.smartcare.business.repair.domain.RpRepairWeeklyReport;

import com.smartcare.business.repair.domain.RpWorkerProfile;

import com.smartcare.business.repair.mapper.RpOrderEvalMapper;

import com.smartcare.business.repair.mapper.RpOrderMapper;

import com.smartcare.business.repair.mapper.RpOrderProgressMapper;

import com.smartcare.business.repair.mapper.RpRepairTypeMapper;

import com.smartcare.business.repair.mapper.RpRepairWeeklyReportMapper;

import com.smartcare.business.repair.mapper.RpWorkerProfileMapper;

import com.smartcare.framework.ai.ZhipuAiClient;

import com.smartcare.system.domain.SysUser;

import com.smartcare.system.service.UserAccountService;

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

import java.util.Comparator;

import java.util.HashMap;

import java.util.LinkedHashMap;

import java.util.List;

import java.util.Map;

import java.util.stream.Collectors;



@Service

@RequiredArgsConstructor

public class RepairReportService {



    private final RpRepairWeeklyReportMapper reportMapper;

    private final RpOrderMapper orderMapper;

    private final RpOrderEvalMapper evalMapper;

    private final RpOrderProgressMapper progressMapper;

    private final RpRepairTypeMapper typeMapper;

    private final RpWorkerProfileMapper workerProfileMapper;

    private final UserAccountService accountService;

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



        Map<Long, String> typeNames = typeMapper.selectList(null).stream()

            .collect(Collectors.toMap(RpRepairType::getTypeId, RpRepairType::getTypeName, (a, b) -> a));



        int total = orders.size();

        int completed = 0;

        int overtime = 0;

        int duplicate = 0;

        double totalHours = 0;

        Map<String, TypeAgg> typeAggs = new LinkedHashMap<>();

        Map<Long, WorkerAgg> workerAggs = new LinkedHashMap<>();



        for (RpOrder order : orders) {

            if (order.getDuplicateFlag() != null && order.getDuplicateFlag() == 1) {

                duplicate++;

            }

            String typeLabel = resolveTypeName(order, typeNames);

            TypeAgg typeAgg = typeAggs.computeIfAbsent(typeLabel, k -> new TypeAgg());

            typeAgg.total++;



            if (order.getWorkerId() != null) {

                WorkerAgg workerAgg = workerAggs.computeIfAbsent(order.getWorkerId(), k -> new WorkerAgg());

                workerAgg.assigned++;

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

            typeAgg.completed++;

            typeAgg.hours.add(hours);

            if (order.getWorkerId() != null) {

                WorkerAgg workerAgg = workerAggs.computeIfAbsent(order.getWorkerId(), k -> new WorkerAgg());

                workerAgg.completed++;

                workerAgg.hours.add(hours);

            }

        }



        BigDecimal avgHours = completed == 0 ? BigDecimal.ZERO

            : BigDecimal.valueOf(totalHours / completed).setScale(2, RoundingMode.HALF_UP);

        BigDecimal overtimeRate = completed == 0 ? BigDecimal.ZERO

            : BigDecimal.valueOf(overtime * 100.0 / completed).setScale(2, RoundingMode.HALF_UP);

        BigDecimal duplicateRate = total == 0 ? BigDecimal.ZERO

            : BigDecimal.valueOf(duplicate * 100.0 / total).setScale(2, RoundingMode.HALF_UP);

        BigDecimal goodRate = calcGoodRate(startTime, endTime);

        BigDecimal completeRate = total == 0 ? BigDecimal.ZERO

            : BigDecimal.valueOf(completed * 100.0 / total).setScale(2, RoundingMode.HALF_UP);



        String typeStats = toJson(buildTypeStats(typeAggs));

        String workerStats = toJson(buildWorkerStats(workerAggs));

        String suggestions = buildSummary(total, completed, completeRate, overtimeRate, duplicateRate,

            goodRate, avgHours, typeAggs, workerAggs);



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

        RpRepairWeeklyReport existing = reportMapper.selectOne(new LambdaQueryWrapper<RpRepairWeeklyReport>()

            .eq(RpRepairWeeklyReport::getWeekStart, start)

            .last("LIMIT 1"));

        if (existing != null) {

            report.setReportId(existing.getReportId());

            reportMapper.updateById(report);

        } else {

            reportMapper.insert(report);

        }

        return report;

    }



    private String resolveTypeName(RpOrder order, Map<Long, String> typeNames) {

        if (StringUtils.hasText(order.getAiTypeLabel())) {

            return order.getAiTypeLabel();

        }

        if (order.getTypeId() != null && typeNames.containsKey(order.getTypeId())) {

            return typeNames.get(order.getTypeId());

        }

        return "未分类";

    }



    private String resolveWorkerName(Long workerId) {

        RpWorkerProfile profile = workerProfileMapper.selectById(workerId);

        if (profile != null && StringUtils.hasText(profile.getRealName())) {

            return profile.getRealName();

        }

        SysUser user = accountService.findById(workerId);

        if (user != null) {

            if (StringUtils.hasText(user.getNickName())) {

                return user.getNickName();

            }

            if (StringUtils.hasText(user.getUsername())) {

                return user.getUsername();

            }

        }

        return "维修工" + workerId;

    }



    private List<Map<String, Object>> buildTypeStats(Map<String, TypeAgg> typeAggs) {

        return typeAggs.entrySet().stream()

            .sorted(Comparator.comparingInt((Map.Entry<String, TypeAgg> e) -> e.getValue().total).reversed())

            .map(e -> {

                TypeAgg agg = e.getValue();

                Map<String, Object> row = new LinkedHashMap<>();

                row.put("name", e.getKey());

                row.put("total", agg.total);

                row.put("completed", agg.completed);

                row.put("avgHours", avgOf(agg.hours));

                return row;

            })

            .collect(Collectors.toList());

    }



    private List<Map<String, Object>> buildWorkerStats(Map<Long, WorkerAgg> workerAggs) {

        return workerAggs.entrySet().stream()

            .sorted(Comparator.comparingInt((Map.Entry<Long, WorkerAgg> e) -> e.getValue().assigned).reversed())

            .map(e -> {

                WorkerAgg agg = e.getValue();

                Map<String, Object> row = new LinkedHashMap<>();

                row.put("workerId", e.getKey());

                row.put("name", resolveWorkerName(e.getKey()));

                row.put("assigned", agg.assigned);

                row.put("completed", agg.completed);

                row.put("avgHours", avgOf(agg.hours));

                return row;

            })

            .collect(Collectors.toList());

    }



    private BigDecimal avgOf(List<Double> values) {

        if (values.isEmpty()) {

            return null;

        }

        double avg = values.stream().mapToDouble(Double::doubleValue).average().orElse(0);

        return BigDecimal.valueOf(avg).setScale(2, RoundingMode.HALF_UP);

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



    private String buildSummary(int total, int completed, BigDecimal completeRate,

                                BigDecimal overtimeRate, BigDecimal duplicateRate,

                                BigDecimal goodRate, BigDecimal avgHours,

                                Map<String, TypeAgg> typeAggs, Map<Long, WorkerAgg> workerAggs) {

        String typeBrief = typeAggs.entrySet().stream()

            .sorted(Comparator.comparingInt((Map.Entry<String, TypeAgg> e) -> e.getValue().total).reversed())

            .limit(5)

            .map(e -> e.getKey() + "(" + e.getValue().total + "单)")

            .collect(Collectors.joining("、"));

        String workerBrief = workerAggs.entrySet().stream()

            .sorted(Comparator.comparingInt((Map.Entry<Long, WorkerAgg> e) -> e.getValue().assigned).reversed())

            .limit(5)

            .map(e -> resolveWorkerName(e.getKey()) + "(" + e.getValue().assigned + "单)")

            .collect(Collectors.joining("、"));



        String dataBrief = """

            统计周期工单=%d，完成=%d（完成率=%s%%），平均完成时长=%s小时，超时率=%s%%，重复报修率=%s%%，好评率=%s%%。

            故障类型分布：%s

            维修工接单：%s

            """.formatted(total, completed, completeRate, avgHours, overtimeRate, duplicateRate, goodRate,

            StringUtils.hasText(typeBrief) ? typeBrief : "无",

            StringUtils.hasText(workerBrief) ? workerBrief : "无");



        if (zhipuAiClient.isAvailable()) {

            try {

                String aiText = zhipuAiClient.chatSimple(

                    """

                    你是智慧社区物业运营顾问。请根据工单数据输出 JSON，不要 markdown 代码块，格式：

                    {"highlights":["优点1","优点2"],"issues":["待改进1","待改进2"],"suggestions":["建议1","建议2","建议3","建议4"]}

                    每类至少2条、建议至少4条，内容具体可执行，结合数据中的类型分布与维修工负载。

                    """,

                    dataBrief);

                JsonNode node = parseSummaryJson(aiText);

                if (node != null) {

                    return node.toString();

                }

            } catch (Exception ignored) {

                // fallback below

            }

        }

        return buildRuleSummary(total, completed, completeRate, overtimeRate, duplicateRate,

            goodRate, avgHours, typeAggs, workerAggs).toString();

    }



    private JsonNode parseSummaryJson(String aiText) {

        if (!StringUtils.hasText(aiText)) {

            return null;

        }

        String trimmed = aiText.trim();

        int start = trimmed.indexOf('{');

        int end = trimmed.lastIndexOf('}');

        if (start < 0 || end <= start) {

            return null;

        }

        try {

            JsonNode node = objectMapper.readTree(trimmed.substring(start, end + 1));

            if (node.has("highlights") && node.has("issues") && node.has("suggestions")) {

                return node;

            }

        } catch (JsonProcessingException ignored) {

            // fallback

        }

        return null;

    }



    private ObjectNode buildRuleSummary(int total, int completed, BigDecimal completeRate,

                                        BigDecimal overtimeRate, BigDecimal duplicateRate,

                                        BigDecimal goodRate, BigDecimal avgHours,

                                        Map<String, TypeAgg> typeAggs, Map<Long, WorkerAgg> workerAggs) {

        ObjectNode root = objectMapper.createObjectNode();

        ArrayNode highlights = root.putArray("highlights");

        ArrayNode issues = root.putArray("issues");

        ArrayNode suggestions = root.putArray("suggestions");



        if (completed > 0) {

            highlights.add("本周共完成 " + completed + " 单，整体完成率 " + completeRate + "%。");

        }

        if (goodRate.compareTo(BigDecimal.valueOf(85)) >= 0) {

            highlights.add("业主好评率达到 " + goodRate + "%，服务口碑表现良好。");

        } else if (goodRate.compareTo(BigDecimal.ZERO) > 0) {

            highlights.add("本周收到业主评价，好评率 " + goodRate + "%，仍有提升空间。");

        }

        if (workerAggs.size() > 1) {

            highlights.add("共有 " + workerAggs.size() + " 名维修工参与本周工单处理，人力覆盖较为均衡。");

        } else if (workerAggs.size() == 1) {

            issues.add("本周工单主要由 1 名维修工承担，存在单点依赖与负载集中风险。");

        }

        if (typeAggs.size() >= 3) {

            highlights.add("故障类型覆盖 " + typeAggs.size() + " 类，数据样本较丰富，便于针对性优化。");

        }



        if (overtimeRate.compareTo(BigDecimal.valueOf(20)) > 0) {

            issues.add("超时率达到 " + overtimeRate + "%，部分工单未在承诺时限内闭环。");

        } else if (completed > 0 && overtimeRate.compareTo(BigDecimal.valueOf(10)) > 0) {

            issues.add("超时率 " + overtimeRate + "% 略高于理想值，需关注高峰时段响应。");

        }

        if (duplicateRate.compareTo(BigDecimal.valueOf(10)) > 0) {

            issues.add("重复报修率 " + duplicateRate + "%，同类故障反复出现需排查根因。");

        }

        if (goodRate.compareTo(BigDecimal.valueOf(85)) < 0 && goodRate.compareTo(BigDecimal.ZERO) > 0) {

            issues.add("好评率 " + goodRate + "% 未达 85% 目标，业主满意度有待加强。");

        }

        if (completeRate.compareTo(BigDecimal.valueOf(70)) < 0 && total > 0) {

            issues.add("完成率仅 " + completeRate + "%，在途/待验收工单积压需加快流转。");

        }

        typeAggs.entrySet().stream()

            .filter(e -> e.getValue().total >= 2 && e.getValue().completed == 0)

            .limit(2)

            .forEach(e -> issues.add("「" + e.getKey() + "」本周 " + e.getValue().total + " 单均未完成，需重点跟进。"));



        String topType = typeAggs.entrySet().stream()

            .max(Comparator.comparingInt(e -> e.getValue().total))

            .map(Map.Entry::getKey).orElse(null);

        if (topType != null) {

            suggestions.add("针对高频类型「" + topType + "」整理标准处理流程与常用备件清单，缩短平均耗时（当前整体 " + avgHours + "h）。");

        }

        if (overtimeRate.compareTo(BigDecimal.valueOf(15)) > 0) {

            suggestions.add("在 17:00–21:00 报修高峰增加备勤维修工，或启用紧急工单优先派单策略。");

        }

        if (duplicateRate.compareTo(BigDecimal.valueOf(5)) > 0) {

            suggestions.add("对重复报修点位开展联合巡检，记录根因并纳入月度维保计划。");

        }

        if (goodRate.compareTo(BigDecimal.valueOf(90)) < 0) {

            suggestions.add("加强上门礼仪、完工说明与现场清理培训，完工后主动引导业主评价。");

        }

        if (workerAggs.size() <= 1 && total >= 3) {

            suggestions.add("评估维修工排班与技能矩阵，避免工单过度集中至单人，提升并行处理能力。");

        }

        suggestions.add("保持 AI 自动分类与派单策略，每周复盘后微调类型关键词与派单权重。");

        suggestions.add("对超时与低分工单建立「原因标签」机制，纳入下周复盘跟踪闭环。");



        if (highlights.isEmpty()) {

            highlights.add("本周报修量较少，系统运行平稳，可继续观察趋势变化。");

        }

        if (issues.isEmpty()) {

            issues.add("暂无明显异常指标，建议持续关注在途工单与业主反馈。");

        }



        return root;

    }



    private String toJson(Object value) {

        try {

            return objectMapper.writeValueAsString(value);

        } catch (JsonProcessingException e) {

            return "[]";

        }

    }



    private LocalDate previousMonday(LocalDate today) {

        LocalDate date = today.minusWeeks(1);

        while (date.getDayOfWeek() != DayOfWeek.MONDAY) {

            date = date.minusDays(1);

        }

        return date;

    }



    private static class TypeAgg {

        int total;

        int completed;

        List<Double> hours = new ArrayList<>();

    }



    private static class WorkerAgg {

        int assigned;

        int completed;

        List<Double> hours = new ArrayList<>();

    }

}

