package com.smartcare.business.elder.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.smartcare.business.elder.domain.ElAiMonitorLog;
import com.smartcare.business.elder.domain.ElAlert;
import com.smartcare.business.elder.domain.ElHealthRecord;
import com.smartcare.business.elder.mapper.ElAiMonitorLogMapper;
import com.smartcare.business.elder.mapper.ElAlertMapper;
import com.smartcare.business.elder.mapper.ElHealthRecordMapper;
import com.smartcare.business.property.domain.CmResident;
import com.smartcare.business.property.mapper.CmResidentMapper;
import com.smartcare.common.core.page.TableDataInfo;
import com.smartcare.framework.ai.ZhipuAiClient;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.time.Duration;
import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;

/**
 * 独居老人AI安全监测服务
 * 结合规则引擎与智谱AI对独居老人进行安全风险评估
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class ElAiMonitorService {

    private final ZhipuAiClient aiClient;
    private final ElAlertMapper alertMapper;
    private final ElHealthRecordMapper healthRecordMapper;
    private final CmResidentMapper residentMapper;
    private final ElAiMonitorLogMapper monitorLogMapper;
    private final ElUtilityMonitorService utilityMonitorService;
    private final JdbcTemplate jdbcTemplate;

    /** 活动超时阈值（小时）—— 超过此时间无活动视为红色风险 */
    private static final long ACTIVITY_TIMEOUT_HOURS = 2;
    /** 健康数据近况窗口（小时） */
    private static final long HEALTH_RECENT_HOURS = 24;
    /** AI分析数据窗口（天） */
    private static final long AI_ANALYSIS_DAYS = 7;

    // ==================== 规则引擎 ====================

    /**
     * 规则引擎检查单个独居老人风险等级
     *
     * 规则1：最后活动时间超过2小时 → red
     * 规则2：近24h健康记录连续异常（心率>100 或 <50）→ yellow
     * 规则3：无近期健康数据 → yellow
     * 正常 → green
     */
    public Map<String, Object> checkAloneElderRisk(Long residentId) {
        CmResident resident = residentMapper.selectById(residentId);
        Map<String, Object> result = new LinkedHashMap<>();
        result.put("residentId", residentId);
        result.put("residentName", resident != null ? resident.getName() : "未知");

        String riskLevel = "green";
        String reason = "各项指标正常";

        if (resident == null) {
            result.put("riskLevel", "red");
            result.put("reason", "住户档案不存在");
            return result;
        }

        // 更新最后活动时间为当前（模拟活动检测）
        LocalDateTime now = LocalDateTime.now();
        LocalDateTime lastActivity = resident.getLastActivityTime();

        // 规则1：最后活动时间超过2小时
        if (lastActivity == null || lastActivity.isBefore(now.minusHours(ACTIVITY_TIMEOUT_HOURS))) {
            riskLevel = "red";
            if (lastActivity == null) {
                reason = "长时间未检测到任何活动（无活动记录）";
            } else {
                long hours = Duration.between(lastActivity, now).toHours();
                reason = "最后活动时间距今已超过" + hours + "小时，可能存在安全隐患";
            }
        } else {
            // 规则2 & 3：检查近24h健康数据
            List<ElHealthRecord> recentRecords = healthRecordMapper.selectList(
                new LambdaQueryWrapper<ElHealthRecord>()
                    .eq(ElHealthRecord::getResidentId, residentId)
                    .ge(ElHealthRecord::getRecordTime, now.minusHours(HEALTH_RECENT_HOURS))
                    .orderByDesc(ElHealthRecord::getRecordTime)
            );

            if (recentRecords.isEmpty()) {
                // 规则3：无近期健康数据
                riskLevel = "yellow";
                reason = "近24小时无健康数据上传，无法监测老人身体状况";
            } else {
                // 规则2：检查心率异常
                List<ElHealthRecord> abnormalRecords = new ArrayList<>();
                for (ElHealthRecord record : recentRecords) {
                    if (record.getHeartRate() != null &&
                        (record.getHeartRate() > 100 || record.getHeartRate() < 50)) {
                        abnormalRecords.add(record);
                    }
                }
                if (!abnormalRecords.isEmpty()) {
                    riskLevel = "yellow";
                    ElHealthRecord latest = abnormalRecords.get(0);
                    reason = String.format("近24h健康数据异常：心率%d（正常范围50-100），检测时间%s",
                        latest.getHeartRate(), latest.getRecordTime());
                }
            }
        }

        result.put("riskLevel", riskLevel);
        result.put("reason", reason);
        result.put("lastActivityTime", lastActivity);
        result.put("checkTime", now);
        return result;
    }

    // ==================== AI 分析 ====================

    /**
     * 调用智谱AI分析老人行为健康数据，判断是否存在安全隐患
     * AI不可用时返回降级提示
     */
    public String analyzeWithAi(Long residentId) {
        CmResident resident = residentMapper.selectById(residentId);
        if (resident == null) {
            return "住户档案不存在，无法进行AI分析";
        }

        // 获取近7天健康数据
        LocalDateTime since = LocalDateTime.now().minusDays(AI_ANALYSIS_DAYS);
        List<ElHealthRecord> records = healthRecordMapper.selectList(
            new LambdaQueryWrapper<ElHealthRecord>()
                .eq(ElHealthRecord::getResidentId, residentId)
                .ge(ElHealthRecord::getRecordTime, since)
                .orderByAsc(ElHealthRecord::getRecordTime)
        );

        // 构造AI分析prompt
        String systemPrompt = "你是一名专业的社区养老安全分析助手。请根据独居老人的健康监测数据，" +
            "分析老人是否存在安全隐患（如跌倒、突发疾病、长时间无活动等），" +
            "并给出具体建议。回复请简洁明了，不超过200字。";

        StringBuilder userMessage = new StringBuilder();
        userMessage.append("独居老人信息：姓名=").append(resident.getName())
            .append("，年龄=").append(resident.getAge() != null ? resident.getAge() : "未知")
            .append("，性别=").append(resident.getGender() != null ? resident.getGender() : "未知")
            .append("。\n");

        userMessage.append("最后活动时间：");
        if (resident.getLastActivityTime() != null) {
            userMessage.append(resident.getLastActivityTime());
            long hours = Duration.between(resident.getLastActivityTime(), LocalDateTime.now()).toHours();
            userMessage.append("（距今").append(hours).append("小时）");
        } else {
            userMessage.append("无记录");
        }
        userMessage.append("。\n");

        userMessage.append("近").append(AI_ANALYSIS_DAYS).append("天健康数据记录共").append(records.size()).append("条：\n");
        if (records.isEmpty()) {
            userMessage.append("无任何健康数据记录。\n");
        } else {
            // 最多取最近20条避免prompt过长
            int limit = Math.min(records.size(), 20);
            int start = Math.max(0, records.size() - limit);
            for (int i = start; i < records.size(); i++) {
                ElHealthRecord r = records.get(i);
                userMessage.append(String.format("  - %s | 心率:%s | 血压:%s | 步数:%s\n",
                    r.getRecordTime(),
                    r.getHeartRate() != null ? r.getHeartRate() : "无",
                    StringUtils.hasText(r.getBloodPressure()) ? r.getBloodPressure() : "无",
                    r.getSteps() != null ? r.getSteps() : "无"));
            }
        }

        userMessage.append("\n请分析该老人当前安全状况，是否存在风险，并给出建议。");

        try {
            return aiClient.chatSimple(systemPrompt, userMessage.toString());
        } catch (Exception e) {
            log.warn("AI分析失败，residentId={}，降级返回规则引擎结果: {}", residentId, e.getMessage());
            return "AI分析服务暂时不可用，请参考规则引擎检测结果。" + e.getMessage();
        }
    }

    // ==================== 完整检查 ====================

    /**
     * 执行完整检查（规则引擎 + AI分析）并生成预警
     * 1. 规则引擎检查
     * 2. 如果规则触发yellow/red，调用AI获取详细分析
     * 3. 创建ElAlert（如果是yellow/red）
     * 4. 记录监测日志 ElAiMonitorLog
     */
    @Transactional
    public Map<String, Object> performFullCheck(Long residentId) {
        // 1. 规则引擎检查
        Map<String, Object> ruleResult = checkAloneElderRisk(residentId);
        String riskLevel = (String) ruleResult.get("riskLevel");
        String reason = (String) ruleResult.get("reason");
        LocalDateTime checkTime = LocalDateTime.now();

        // 2. 如果触发yellow/red，调用AI获取详细分析
        String aiResponse = "";
        Long alertId = null;

        if ("yellow".equals(riskLevel) || "red".equals(riskLevel)) {
            aiResponse = analyzeWithAi(residentId);

            // 3. 创建预警
            ElAlert alert = new ElAlert();
            alert.setResidentId(residentId);
            alert.setAlertType("alone_monitor");
            alert.setAlertLevel("red".equals(riskLevel) ? 1 : 2);
            alert.setContent(reason + (StringUtils.hasText(aiResponse) ? " | AI建议：" + abbreviate(aiResponse, 200) : ""));
            alert.setStatus("pending");
            alert.setCreateTime(checkTime);
            alertMapper.insert(alert);
            alertId = alert.getAlertId();
        }

        // 4. 记录监测日志
        ElAiMonitorLog logEntry = new ElAiMonitorLog();
        logEntry.setResidentId(residentId);
        logEntry.setCheckTime(checkTime);
        logEntry.setRiskLevel(riskLevel);
        logEntry.setReason(reason);
        logEntry.setAiResponse(StringUtils.hasText(aiResponse) ? aiResponse : null);
        logEntry.setAlertId(alertId);
        logEntry.setCreateTime(checkTime);
        monitorLogMapper.insert(logEntry);

        // 5. 更新老人最后活动时间（模拟活动检测，green状态正常更新）
        if ("green".equals(riskLevel)) {
            CmResident resident = new CmResident();
            resident.setResidentId(residentId);
            resident.setLastActivityTime(checkTime);
            residentMapper.updateById(resident);
        }

        // 6. 水电时序异常检测
        List<Map<String, Object>> utilityAnomalies = Collections.emptyList();
        try {
            utilityAnomalies = utilityMonitorService.detectAnomalies(residentId);
            if (!utilityAnomalies.isEmpty()) {
                // 升级风险等级
                int utilityMaxLevel = utilityAnomalies.stream()
                    .mapToInt(a -> (Integer) a.getOrDefault("level", 3))
                    .min().orElse(3);
                if (utilityMaxLevel == 1 && !"red".equals(riskLevel)) {
                    riskLevel = "red";
                } else if (utilityMaxLevel == 2 && "green".equals(riskLevel)) {
                    riskLevel = "yellow";
                }
                String utilityDesc = utilityAnomalies.stream()
                    .map(a -> (String) a.get("description"))
                    .collect(Collectors.joining("；"));
                reason = reason + " | 水电异常：" + utilityDesc;
            }
        } catch (Exception e) {
            log.warn("水电异常检测失败: {}", e.getMessage());
        }

        // 返回检测结果
        Map<String, Object> result = new LinkedHashMap<>();
        result.put("logId", logEntry.getLogId());
        result.put("residentId", residentId);
        result.put("residentName", ruleResult.get("residentName"));
        result.put("riskLevel", riskLevel);
        result.put("reason", reason);
        result.put("aiResponse", aiResponse);
        result.put("alertId", alertId);
        result.put("checkTime", checkTime);
        result.put("utilityAnomalies", utilityAnomalies);
        return result;
    }

    // ==================== 监测状态概览 ====================

    /**
     * 获取监测状态概览
     * 返回：监测中老人数、今日检查数、今日预警数、最近预警
     */
    public Map<String, Object> getMonitorStatus() {
        Map<String, Object> status = new LinkedHashMap<>();
        LocalDateTime todayStart = LocalDateTime.now().toLocalDate().atStartOfDay();

        // 监测中老人数（独居老人）
        Long aloneCount = residentMapper.selectCount(
            new LambdaQueryWrapper<CmResident>()
                .eq(CmResident::getIsAloneLiving, 1)
                .eq(CmResident::getDelFlag, "0")
        );
        status.put("aloneElderCount", aloneCount != null ? aloneCount : 0);

        // 今日检查数
        Long todayCheckCount = monitorLogMapper.selectCount(
            new LambdaQueryWrapper<ElAiMonitorLog>()
                .ge(ElAiMonitorLog::getCheckTime, todayStart)
        );
        status.put("todayCheckCount", todayCheckCount != null ? todayCheckCount : 0);

        // 今日预警数
        Long todayAlertCount = monitorLogMapper.selectCount(
            new LambdaQueryWrapper<ElAiMonitorLog>()
                .ge(ElAiMonitorLog::getCheckTime, todayStart)
                .in(ElAiMonitorLog::getRiskLevel, "yellow", "red")
        );
        status.put("todayAlertCount", todayAlertCount != null ? todayAlertCount : 0);

        // 最近一次预警
        ElAiMonitorLog latestAlert = monitorLogMapper.selectOne(
            new LambdaQueryWrapper<ElAiMonitorLog>()
                .in(ElAiMonitorLog::getRiskLevel, "yellow", "red")
                .orderByDesc(ElAiMonitorLog::getCheckTime)
                .last("LIMIT 1")
        );
        if (latestAlert != null) {
            CmResident resident = residentMapper.selectById(latestAlert.getResidentId());
            Map<String, Object> latest = new LinkedHashMap<>();
            latest.put("checkTime", latestAlert.getCheckTime());
            latest.put("riskLevel", latestAlert.getRiskLevel());
            latest.put("residentName", resident != null ? resident.getName() : "未知");
            latest.put("reason", latestAlert.getReason());
            status.put("latestAlert", latest);
        } else {
            status.put("latestAlert", null);
        }

        return status;
    }

    // ==================== 监测日志列表 ====================

    /**
     * 获取AI监测日志列表（分页）
     */
    public TableDataInfo listMonitorLogs(int pageNum, int pageSize) {
        Page<ElAiMonitorLog> page = monitorLogMapper.selectPage(
            new Page<>(pageNum, pageSize),
            new LambdaQueryWrapper<ElAiMonitorLog>()
                .orderByDesc(ElAiMonitorLog::getCheckTime)
        );

        // 补充老人姓名信息
        List<Map<String, Object>> rows = new ArrayList<>();
        Set<Long> residentIds = new HashSet<>();
        for (ElAiMonitorLog log : page.getRecords()) {
            if (log.getResidentId() != null) {
                residentIds.add(log.getResidentId());
            }
        }
        Map<Long, String> nameMap = new HashMap<>();
        if (!residentIds.isEmpty()) {
            List<CmResident> residents = residentMapper.selectBatchIds(residentIds);
            for (CmResident r : residents) {
                nameMap.put(r.getResidentId(), r.getName());
            }
        }

        for (ElAiMonitorLog log : page.getRecords()) {
            Map<String, Object> row = new LinkedHashMap<>();
            row.put("logId", log.getLogId());
            row.put("residentId", log.getResidentId());
            row.put("residentName", nameMap.getOrDefault(log.getResidentId(), "未知"));
            row.put("checkTime", log.getCheckTime());
            row.put("riskLevel", log.getRiskLevel());
            row.put("reason", log.getReason());
            row.put("aiResponse", log.getAiResponse());
            row.put("alertId", log.getAlertId());
            row.put("createTime", log.getCreateTime());
            rows.add(row);
        }

        return new TableDataInfo(page.getTotal(), rows);
    }

    // ==================== 独居老人列表 ====================

    /**
     * 获取独居老人列表（含最新风险等级）
     */
    public List<Map<String, Object>> listAloneElders() {
        List<CmResident> residents = residentMapper.selectList(
            new LambdaQueryWrapper<CmResident>()
                .eq(CmResident::getIsAloneLiving, 1)
                .eq(CmResident::getDelFlag, "0")
                .orderByAsc(CmResident::getResidentId)
        );

        // 批量查询地址
        Map<Long, String> addressMap = new HashMap<>();
        if (!residents.isEmpty()) {
            String ids = residents.stream()
                .map(r -> String.valueOf(r.getResidentId()))
                .collect(Collectors.joining(","));
            try {
                List<Map<String, Object>> addrRows = jdbcTemplate.queryForList(
                    "SELECT r.resident_id, CONCAT(IFNULL(b.building_no,''), IFNULL(h.house_no,'')) as address " +
                    "FROM cm_resident r " +
                    "LEFT JOIN cm_house h ON r.house_id = h.house_id " +
                    "LEFT JOIN cm_building b ON h.building_id = b.building_id " +
                    "WHERE r.resident_id IN (" + ids + ")");
                for (Map<String, Object> ar : addrRows) {
                    addressMap.put(((Number) ar.get("resident_id")).longValue(),
                        ar.get("address") != null ? ar.get("address").toString() : "");
                }
            } catch (Exception e) {
                log.warn("查询老人地址失败: {}", e.getMessage());
            }
        }

        List<Map<String, Object>> rows = new ArrayList<>();
        for (CmResident r : residents) {
            Map<String, Object> row = new LinkedHashMap<>();
            row.put("residentId", r.getResidentId());
            row.put("name", r.getName());
            row.put("gender", r.getGender());
            row.put("age", r.getAge());
            row.put("phone", r.getPhone());
            row.put("emergencyContact", r.getEmergencyContact());
            row.put("address", addressMap.getOrDefault(r.getResidentId(), ""));
            row.put("livingAlone", r.getIsAloneLiving() != null && r.getIsAloneLiving() == 1 ? "1" : "0");
            rows.add(row);
        }
        return rows;
    }

    // ==================== 工具方法 ====================

    private String abbreviate(String text, int max) {
        if (!StringUtils.hasText(text)) {
            return "";
        }
        String t = text.trim().replaceAll("\\s+", " ");
        return t.length() <= max ? t : t.substring(0, max) + "...";
    }
}
