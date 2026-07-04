package com.smartcare.business.elder.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.smartcare.business.elder.domain.ElAiMonitorLog;
import com.smartcare.business.elder.domain.ElAlert;
import com.smartcare.business.elder.domain.ElCareOrder;
import com.smartcare.business.elder.domain.ElUtilityData;
import com.smartcare.business.elder.mapper.ElAiMonitorLogMapper;
import com.smartcare.business.elder.mapper.ElAlertMapper;
import com.smartcare.business.elder.mapper.ElUtilityDataMapper;
import com.smartcare.business.property.domain.CmResident;
import com.smartcare.business.property.mapper.CmResidentMapper;
import com.smartcare.business.property.service.ResidentCareTagService;
import com.smartcare.common.core.page.TableDataInfo;
import com.smartcare.common.exception.ServiceException;
import com.smartcare.framework.ai.ZhipuAiClient;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;

/**
 * AI 安全监测服务（方案B：仅水电生活迹象 + 用量异常，不依赖健康硬件）
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class ElAiMonitorService {

    private final ZhipuAiClient aiClient;
    private final ElAlertMapper alertMapper;
    private final CmResidentMapper residentMapper;
    private final ElAiMonitorLogMapper monitorLogMapper;
    private final ElUtilityDataMapper utilityDataMapper;
    private final ElUtilityMonitorService utilityMonitorService;
    private final ElCareOrderService careOrderService;
    private final JdbcTemplate jdbcTemplate;
    private final ResidentCareTagService careTagService;

    /**
     * 执行完整 AI 安全监测：水电生活迹象 + 用量异常 → AI 分析 → 预警 + 待指派工单
     */
    @Transactional
    public Map<String, Object> performFullCheck(Long residentId) {
        CmResident resident = residentMapper.selectById(residentId);
        if (resident == null) {
            throw new ServiceException("住户不存在");
        }

        LocalDateTime checkTime = LocalDateTime.now();
        List<Map<String, Object>> anomalies = utilityMonitorService.detectAnomalies(residentId);

        String riskLevel = "green";
        String reason = "水电与生活迹象正常";
        int alertLevel = 2;

        if (!anomalies.isEmpty()) {
            int maxLevel = anomalies.stream()
                .mapToInt(a -> (Integer) a.getOrDefault("level", 3))
                .min().orElse(3);
            alertLevel = maxLevel;
            riskLevel = maxLevel == 1 ? "red" : "yellow";
            reason = anomalies.stream()
                .map(a -> (String) a.get("description"))
                .collect(Collectors.joining("；"));
        }

        String aiResponse = "";
        Long alertId = null;
        Long careOrderId = null;
        boolean skippedDuplicate = false;

        if ("yellow".equals(riskLevel) || "red".equals(riskLevel)) {
            ElAlert openAlert = findOpenAlert(residentId);
            if (openAlert != null) {
                skippedDuplicate = true;
                alertId = openAlert.getAlertId();
                ElCareOrder openOrder = careOrderService.getByAlertId(alertId);
                careOrderId = openOrder != null ? openOrder.getCareId() : null;
                aiResponse = "该老人已有未处理预警（ID：" + alertId + "），本次监测未重复生成。";
            } else {
                aiResponse = analyzeWithAi(residentId, reason, anomalies);

                String alertType = resolveAlertType(anomalies);
                ElAlert alert = new ElAlert();
                alert.setResidentId(residentId);
                alert.setAlertType(alertType);
                alert.setAlertLevel(alertLevel);
                alert.setContent(reason.length() > 500 ? reason.substring(0, 500) : reason);
                alert.setStatus("pending");
                alert.setCreateTime(checkTime);
                alertMapper.insert(alert);
                alertId = alert.getAlertId();

                String careItem = "[AI监测] " + reason;
                careOrderId = careOrderService.createPendingOrderForAlert(
                    alertId, residentId, careItem, alertLevel);
            }
        }

        ElAiMonitorLog logEntry = new ElAiMonitorLog();
        logEntry.setResidentId(residentId);
        logEntry.setCheckTime(checkTime);
        logEntry.setRiskLevel(riskLevel);
        logEntry.setReason(reason);
        logEntry.setAiResponse(StringUtils.hasText(aiResponse) ? aiResponse : null);
        logEntry.setAlertId(alertId);
        logEntry.setCreateTime(checkTime);
        monitorLogMapper.insert(logEntry);

        Map<String, Object> result = new LinkedHashMap<>();
        result.put("logId", logEntry.getLogId());
        result.put("residentId", residentId);
        result.put("residentName", resident.getName());
        result.put("riskLevel", riskLevel);
        result.put("reason", reason);
        result.put("aiResponse", aiResponse);
        result.put("alertId", alertId);
        result.put("careOrderId", careOrderId);
        result.put("alertCreated", alertId != null && !skippedDuplicate);
        result.put("orderCreated", careOrderId != null && !skippedDuplicate);
        result.put("skippedDuplicate", skippedDuplicate);
        result.put("checkTime", checkTime);
        result.put("anomalies", anomalies);
        return result;
    }

    /** 查找该老人尚未闭环的预警（待处理 / 处理中） */
    private ElAlert findOpenAlert(Long residentId) {
        return alertMapper.selectOne(
            new LambdaQueryWrapper<ElAlert>()
                .eq(ElAlert::getResidentId, residentId)
                .in(ElAlert::getStatus, "pending", "processing")
                .orderByDesc(ElAlert::getCreateTime)
                .last("LIMIT 1")
        );
    }

    private String resolveAlertType(List<Map<String, Object>> anomalies) {
        boolean hasLivingSign = anomalies.stream()
            .anyMatch(a -> "no_living_sign".equals(a.get("type")));
        return hasLivingSign ? "living_sign" : "utility_anomaly";
    }

    /**
     * 调用智谱 AI 分析水电异常，生成关怀建议
     */
    public String analyzeWithAi(Long residentId, String reason, List<Map<String, Object>> anomalies) {
        if (!aiClient.isAvailable()) {
            return "【AI 未配置】请物业人员根据水电监测规则结果安排上门关怀。";
        }

        CmResident resident = residentMapper.selectById(residentId);
        String name = resident != null ? resident.getName() : "未知";

        LocalDateTime since = LocalDateTime.now().minusDays(7);
        List<ElUtilityData> utilityRecords = utilityDataMapper.selectList(
            new LambdaQueryWrapper<ElUtilityData>()
                .eq(ElUtilityData::getResidentId, residentId)
                .ge(ElUtilityData::getRecordTime, since)
                .orderByDesc(ElUtilityData::getRecordTime)
                .last("LIMIT 48")
        );

        StringBuilder utilitySummary = new StringBuilder();
        for (ElUtilityData u : utilityRecords) {
            utilitySummary.append(String.format("- %s 用水:%s 用电:%s\n",
                u.getRecordTime(),
                u.getWaterUsage() != null ? u.getWaterUsage() : "0",
                u.getElectricUsage() != null ? u.getElectricUsage() : "0"));
        }
        if (utilitySummary.isEmpty()) {
            utilitySummary.append("（近7天暂无水电记录）");
        }

        String anomalyDetail = anomalies.stream()
            .map(a -> String.format("[%s] %s", a.get("type"), a.get("description")))
            .collect(Collectors.joining("\n"));

        String systemPrompt = "你是社区物业 AI 安全监测助手。监测仅基于水电用量推断生活迹象与用量异常，" +
            "不使用健康手环等设备数据。请用简洁中文（200字以内）给出风险判断、关怀措施建议和紧急程度。";

        String userMessage = String.format("""
            老人姓名：%s
            规则判定结果：%s
            异常明细：
            %s
            
            近7天水电记录（最新在前）：
            %s
            """, name, reason, anomalyDetail, utilitySummary);

        try {
            return aiClient.chatSimple(systemPrompt, userMessage);
        } catch (Exception e) {
            log.warn("AI 分析失败，residentId={}: {}", residentId, e.getMessage());
            return "【AI 调用失败】" + reason + "。建议物业人员安排上门关怀。";
        }
    }

    public Map<String, Object> getMonitorStatus() {
        Map<String, Object> status = new LinkedHashMap<>();
        LocalDateTime todayStart = LocalDateTime.now().toLocalDate().atStartOfDay();

        status.put("aloneElderCount", careTagService.listAiMonitorTargets().size());

        Long todayCheckCount = monitorLogMapper.selectCount(
            new LambdaQueryWrapper<ElAiMonitorLog>()
                .ge(ElAiMonitorLog::getCheckTime, todayStart)
        );
        status.put("todayCheckCount", todayCheckCount != null ? todayCheckCount : 0);

        Long todayAlertCount = monitorLogMapper.selectCount(
            new LambdaQueryWrapper<ElAiMonitorLog>()
                .ge(ElAiMonitorLog::getCheckTime, todayStart)
                .in(ElAiMonitorLog::getRiskLevel, "yellow", "red")
        );
        status.put("todayAlertCount", todayAlertCount != null ? todayAlertCount : 0);

        ElAiMonitorLog latestAlert = monitorLogMapper.selectOne(
            new LambdaQueryWrapper<ElAiMonitorLog>()
                .in(ElAiMonitorLog::getRiskLevel, "yellow", "red")
                .orderByDesc(ElAiMonitorLog::getCheckTime)
                .last("LIMIT 1")
        );
        if (latestAlert != null) {
            CmResident r = residentMapper.selectById(latestAlert.getResidentId());
            Map<String, Object> latest = new LinkedHashMap<>();
            latest.put("checkTime", latestAlert.getCheckTime());
            latest.put("riskLevel", latestAlert.getRiskLevel());
            latest.put("residentName", r != null ? r.getName() : "未知");
            latest.put("reason", latestAlert.getReason());
            status.put("latestAlert", latest);
        } else {
            status.put("latestAlert", null);
        }
        return status;
    }

    public TableDataInfo listMonitorLogs(int pageNum, int pageSize) {
        Page<ElAiMonitorLog> page = monitorLogMapper.selectPage(
            new Page<>(pageNum, pageSize),
            new LambdaQueryWrapper<ElAiMonitorLog>()
                .orderByDesc(ElAiMonitorLog::getCheckTime)
        );

        Set<Long> residentIds = page.getRecords().stream()
            .map(ElAiMonitorLog::getResidentId)
            .filter(Objects::nonNull)
            .collect(Collectors.toSet());
        Map<Long, String> nameMap = new HashMap<>();
        if (!residentIds.isEmpty()) {
            for (CmResident r : residentMapper.selectBatchIds(residentIds)) {
                nameMap.put(r.getResidentId(), r.getName());
            }
        }

        List<Map<String, Object>> rows = new ArrayList<>();
        for (ElAiMonitorLog entry : page.getRecords()) {
            Map<String, Object> row = new LinkedHashMap<>();
            row.put("logId", entry.getLogId());
            row.put("residentId", entry.getResidentId());
            row.put("residentName", nameMap.getOrDefault(entry.getResidentId(), "未知"));
            row.put("checkTime", entry.getCheckTime());
            row.put("riskLevel", entry.getRiskLevel());
            row.put("reason", entry.getReason());
            row.put("aiResponse", entry.getAiResponse());
            row.put("alertId", entry.getAlertId());
            row.put("createTime", entry.getCreateTime());
            rows.add(row);
        }
        return new TableDataInfo(page.getTotal(), rows);
    }

    public TableDataInfo listAloneElders(int pageNum, int pageSize, String name, String gender) {
        List<CmResident> all = careTagService.listAiMonitorTargets().stream()
            .filter(r -> !StringUtils.hasText(name) || (r.getName() != null && r.getName().contains(name)))
            .filter(r -> !StringUtils.hasText(gender) || gender.equals(r.getGender()))
            .toList();

        long total = all.size();
        int from = Math.max(0, (pageNum - 1) * pageSize);
        int to = Math.min(all.size(), from + pageSize);
        List<CmResident> page = from >= all.size() ? List.of() : all.subList(from, to);

        Map<Long, String> addressMap = batchQueryAddress(
            page.stream().map(CmResident::getResidentId).toList());

        List<Map<String, Object>> rows = new ArrayList<>();
        for (CmResident r : page) {
            Map<String, Object> row = new LinkedHashMap<>();
            row.put("residentId", r.getResidentId());
            row.put("name", r.getName());
            row.put("gender", r.getGender());
            row.put("age", r.getAge());
            row.put("phone", r.getPhone());
            row.put("emergencyContact", formatEmergency(r));
            row.put("emergencyName", r.getEmergencyName());
            row.put("emergencyPhone", r.getEmergencyPhone());
            row.put("emergencyRelation", r.getEmergencyRelation());
            row.put("address", addressMap.getOrDefault(r.getResidentId(), ""));
            row.put("livingAlone", careTagService.isAloneElder(r) ? "1" : "0");
            row.put("careTags", careTagService.computeAutoTagNames(r));
            rows.add(row);
        }
        return new TableDataInfo(total, rows);
    }

    private Map<Long, String> batchQueryAddress(List<Long> residentIds) {
        Map<Long, String> addressMap = new HashMap<>();
        if (residentIds.isEmpty()) {
            return addressMap;
        }
        String ids = residentIds.stream().map(String::valueOf).collect(Collectors.joining(","));
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
        return addressMap;
    }

    private String formatEmergency(CmResident r) {
        if (StringUtils.hasText(r.getEmergencyName()) || StringUtils.hasText(r.getEmergencyPhone())) {
            String rel = StringUtils.hasText(r.getEmergencyRelation()) ? "（" + r.getEmergencyRelation() + "）" : "";
            return (r.getEmergencyName() != null ? r.getEmergencyName() : "") + rel +
                (StringUtils.hasText(r.getEmergencyPhone()) ? " " + r.getEmergencyPhone() : "");
        }
        return r.getEmergencyContact();
    }

    private String abbreviate(String text, int max) {
        if (!StringUtils.hasText(text)) {
            return "";
        }
        String t = text.trim().replaceAll("\\s+", " ");
        return t.length() <= max ? t : t.substring(0, max) + "...";
    }
}
