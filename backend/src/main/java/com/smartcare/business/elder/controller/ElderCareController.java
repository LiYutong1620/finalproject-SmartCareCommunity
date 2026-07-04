package com.smartcare.business.elder.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.smartcare.business.elder.domain.*;
import com.smartcare.business.elder.mapper.ElAlertMapper;
import com.smartcare.business.elder.mapper.ElAiMonitorLogMapper;
import com.smartcare.business.elder.mapper.ElCareOrderMapper;
import com.smartcare.business.elder.mapper.ElDisposalRecordMapper;
import com.smartcare.business.elder.mapper.ElTempGuardianMapper;
import com.smartcare.business.elder.service.*;
import com.smartcare.common.core.domain.AjaxResult;
import com.smartcare.common.core.page.TableDataInfo;
import com.smartcare.framework.security.SecurityUtils;
import com.smartcare.system.service.UserAccountService;
import lombok.RequiredArgsConstructor;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/property/elder")
@RequiredArgsConstructor
public class ElderCareController {

    private final ElAlertMapper alertMapper;
    private final ElAiMonitorLogMapper monitorLogMapper;
    private final ElCareOrderMapper careOrderMapper;
    private final ElDisposalRecordMapper disposalRecordMapper;
    private final ElCareStaffService careStaffService;
    private final ElCareStaffTypeService careStaffTypeService;
    private final ElCareOrderService careOrderService;
    private final JdbcTemplate jdbcTemplate;
    private final UserAccountService accountService;
    private final ElTempGuardianMapper tempGuardianMapper;

    // ==================== 预警管理 ====================

    @GetMapping("/alert/list")
    public AjaxResult alertList(@RequestParam(defaultValue = "1") int pageNum,
                                @RequestParam(defaultValue = "10") int pageSize,
                                @RequestParam(required = false) String alertType,
                                @RequestParam(required = false) String keyword,
                                @RequestParam(required = false) String status) {
        LambdaQueryWrapper<ElAlert> alertQw = new LambdaQueryWrapper<ElAlert>();
        if (StringUtils.hasText(status)) {
            if ("processing".equals(status)) {
                alertQw.in(ElAlert::getStatus, "processing", "handled");
            } else {
                alertQw.eq(ElAlert::getStatus, status);
            }
        }
        Page<ElAlert> page = alertMapper.selectPage(new Page<>(pageNum, pageSize),
            alertQw
                .eq(alertType != null && !alertType.isEmpty(), ElAlert::getAlertType, alertType)
                .like(keyword != null && !keyword.isEmpty(), ElAlert::getContent, keyword)
                .last("ORDER BY CASE status WHEN 'pending' THEN 0 WHEN 'processing' THEN 1 WHEN 'handled' THEN 2 WHEN 'closed' THEN 3 ELSE 4 END ASC, create_time DESC"));

        // 填充老人姓名和处理人姓名
        List<ElAlert> records = page.getRecords();
        fillAlertNames(records);
        records.forEach(this::enrichAlertDisplay);

        return AjaxResult.success(new TableDataInfo(page.getTotal(), records));
    }

    @PostMapping("/alert")
    public AjaxResult createAlert(@RequestBody ElAlert alert) {
        alert.setStatus("pending");
        alert.setCreateTime(LocalDateTime.now());
        alertMapper.insert(alert);
        return AjaxResult.success();
    }

    /** 预警详情（包含老人信息、处置记录） */
    @GetMapping("/alert/{alertId}")
    public AjaxResult alertDetail(@PathVariable Long alertId) {
        ElAlert alert = alertMapper.selectById(alertId);
        if (alert == null) return AjaxResult.error("预警不存在");
        fillAlertElderInfo(alert);
        enrichAlertDisplay(alert);
        List<ElDisposalRecord> records = disposalRecordMapper.selectList(
            new LambdaQueryWrapper<ElDisposalRecord>()
                .eq(ElDisposalRecord::getAlertId, alertId)
                .orderByDesc(ElDisposalRecord::getHandleTime)
        );
        fillRecordHandlerNames(records);
        ElCareOrder careOrder = careOrderService.getByAlertId(alertId);
        if (careOrder != null) {
            fillOrderNames(List.of(careOrder));
        }
        Map<String, Object> result = new LinkedHashMap<>();
        result.put("alert", alert);
        result.put("records", records);
        result.put("careOrder", careOrder);
        return AjaxResult.success(result);
    }

    /** 预警详情内指派关怀人员（同步工单指派 + 预警进入处理中） */
    @PutMapping("/alert/{alertId}/assign")
    public AjaxResult assignAlertCare(@PathVariable Long alertId, @RequestBody Map<String, Object> body) {
        ElAlert alert = alertMapper.selectById(alertId);
        if (alert == null) return AjaxResult.error("预警不存在");
        if ("closed".equals(alert.getStatus())) {
            return AjaxResult.error("预警已完成，无法指派");
        }
        Long staffId = Optional.ofNullable(body.get("staffId"))
            .map(Object::toString).map(Long::valueOf).orElse(null);
        if (staffId == null) {
            return AjaxResult.error("请选择关怀人员");
        }
        ElCareOrder order = careOrderService.getByAlertId(alertId);
        if (order == null) {
            return AjaxResult.error("未找到关联关怀工单");
        }
        careOrderService.assignCareOrder(order.getCareId(), staffId);
        ElAlert upd = new ElAlert();
        upd.setAlertId(alertId);
        upd.setStatus("processing");
        upd.setHandlerId(SecurityUtils.getUserId());
        if (alert.getProcessStartTime() == null) {
            upd.setProcessStartTime(LocalDateTime.now());
        }
        alertMapper.updateById(upd);
        return AjaxResult.success();
    }

    /** 开始处理预警（状态变为处理中） */
    @PutMapping("/alert/{alertId}/process")
    public AjaxResult processAlert(@PathVariable Long alertId) {
        ElAlert alert = alertMapper.selectById(alertId);
        if (alert == null) return AjaxResult.error("预警不存在");
        if ("closed".equals(alert.getStatus())) {
            return AjaxResult.error("预警已完成，无法变更");
        }
        ElAlert upd = new ElAlert();
        upd.setAlertId(alertId);
        upd.setStatus("processing");
        upd.setHandlerId(SecurityUtils.getUserId());
        if (alert.getProcessStartTime() == null) {
            upd.setProcessStartTime(LocalDateTime.now());
        }
        alertMapper.updateById(upd);
        return AjaxResult.success();
    }

    /** 预警闭环（填写处置记录后状态变为已完成） */
    @PutMapping("/alert/{alertId}/close")
    public AjaxResult closeAlert(@PathVariable Long alertId, @RequestBody Map<String, Object> body) {
        ElAlert alert = alertMapper.selectById(alertId);
        if (alert == null) return AjaxResult.error("预警不存在");
        String checkResult = parseStr(body.get("checkResult"));
        String disposalResult = parseStr(body.get("disposalResult"));
        if (!StringUtils.hasText(checkResult)) {
            return AjaxResult.error("请填写上门核查情况");
        }
        if (!StringUtils.hasText(disposalResult)) {
            return AjaxResult.error("请填写处理结果");
        }
        LocalDateTime visitTime = parseDateTime(body.get("visitTime"));
        if (visitTime == null) {
            return AjaxResult.error("请选择上门核查时间");
        }
        LocalDateTime completeTime = LocalDateTime.now();

        ElCareOrder order = careOrderService.getByAlertId(alertId);
        if (order != null && !"completed".equals(order.getStatus())) {
            ElCareOrder orderUpd = new ElCareOrder();
            orderUpd.setCareId(order.getCareId());
            orderUpd.setStatus("completed");
            orderUpd.setCheckResult(checkResult);
            orderUpd.setDisposalResult(disposalResult);
            orderUpd.setResult("上门核查：" + checkResult + " | 处理结果：" + disposalResult);
            orderUpd.setCompleteTime(completeTime);
            careOrderMapper.updateById(orderUpd);
        }

        ElDisposalRecord record = new ElDisposalRecord();
        record.setAlertId(alertId);
        if (order != null) {
            record.setCareId(order.getCareId());
        }
        record.setHandlerId(SecurityUtils.getUserId());
        record.setHandleTime(visitTime);
        record.setCheckResult(checkResult);
        record.setDisposalResult(disposalResult);
        record.setCreateTime(completeTime);
        disposalRecordMapper.insert(record);

        ElAlert upd = new ElAlert();
        upd.setAlertId(alertId);
        upd.setStatus("closed");
        upd.setHandlerId(SecurityUtils.getUserId());
        upd.setHandleTime(completeTime);
        upd.setHandleResult(disposalResult);
        if (alert.getProcessStartTime() == null) {
            upd.setProcessStartTime(visitTime);
        }
        alertMapper.updateById(upd);
        return AjaxResult.success();
    }

    /** 查询某预警关联的处置记录 */
    @GetMapping("/disposal-record/list")
    public AjaxResult disposalRecordList(@RequestParam(required = false) Long alertId,
                                         @RequestParam(required = false) Long careId) {
        LambdaQueryWrapper<ElDisposalRecord> qw = new LambdaQueryWrapper<ElDisposalRecord>()
            .eq(alertId != null, ElDisposalRecord::getAlertId, alertId)
            .eq(careId != null, ElDisposalRecord::getCareId, careId)
            .orderByDesc(ElDisposalRecord::getHandleTime);
        List<ElDisposalRecord> records = disposalRecordMapper.selectList(qw);
        fillRecordHandlerNames(records);
        return AjaxResult.success(records);
    }

    /** 新增处置记录 */
    @PostMapping("/disposal-record")
    public AjaxResult addDisposalRecord(@RequestBody ElDisposalRecord record) {
        record.setHandlerId(SecurityUtils.getUserId());
        record.setHandleTime(LocalDateTime.now());
        record.setCreateTime(LocalDateTime.now());
        disposalRecordMapper.insert(record);
        return AjaxResult.success();
    }

    // ==================== 关怀人员类型 ====================

    @GetMapping("/staff-type/list")
    public AjaxResult staffTypeList() {
        return AjaxResult.success(careStaffTypeService.listAll());
    }

    @PostMapping("/staff-type")
    public AjaxResult addStaffType(@RequestBody Map<String, String> body) {
        careStaffTypeService.add(body.get("typeName"));
        return AjaxResult.success();
    }

    @DeleteMapping("/staff-type/{typeId}")
    public AjaxResult deleteStaffType(@PathVariable Long typeId) {
        careStaffTypeService.delete(typeId);
        return AjaxResult.success();
    }

    // ==================== 关怀人员 ====================

    @GetMapping("/staff/by-resident/{residentId}")
    public AjaxResult staffByResident(@PathVariable Long residentId) {
        return AjaxResult.success(careStaffService.listByResidentBuilding(residentId));
    }

    @GetMapping("/staff/list")
    public AjaxResult staffList(@RequestParam(defaultValue = "1") int pageNum,
                                @RequestParam(defaultValue = "10") int pageSize,
                                @RequestParam(required = false) Long buildingId,
                                @RequestParam(required = false) String staffType) {
        return AjaxResult.success(careStaffService.list(pageNum, pageSize, buildingId, staffType));
    }

    @PostMapping("/staff")
    public AjaxResult addStaff(@RequestBody ElCareStaff staff) {
        careStaffService.add(staff);
        return AjaxResult.success();
    }

    @PutMapping("/staff")
    public AjaxResult updateStaff(@RequestBody ElCareStaff staff) {
        careStaffService.update(staff);
        return AjaxResult.success();
    }

    @DeleteMapping("/staff/{staffId}")
    public AjaxResult deleteStaff(@PathVariable Long staffId) {
        careStaffService.delete(staffId);
        return AjaxResult.success();
    }

    // ==================== 关怀工单 ====================

    @GetMapping("/care-order/list")
    public AjaxResult careOrderList(@RequestParam(defaultValue = "1") int pageNum,
                                    @RequestParam(defaultValue = "10") int pageSize,
                                    @RequestParam(required = false) String status,
                                    @RequestParam(required = false) Long assigneeId) {
        TableDataInfo data = careOrderService.listCareOrders(pageNum, pageSize, status, assigneeId);
        // 填充老人姓名和指派人员姓名
        @SuppressWarnings("unchecked")
        List<ElCareOrder> records = (List<ElCareOrder>) data.getRows();
        fillOrderNames(records);
        return AjaxResult.success(data);
    }

    @PostMapping("/care-order")
    public AjaxResult createCareOrder(@RequestBody ElCareOrder order) {
        careOrderService.createCareOrder(order);
        return AjaxResult.success();
    }

    @PutMapping("/care-order/{id}/assign")
    public AjaxResult assignCareOrder(@PathVariable Long id, @RequestBody Map<String, Object> body) {
        Long staffId = Optional.ofNullable(body.get("staffId"))
            .map(Object::toString).map(Long::valueOf).orElse(null);
        careOrderService.assignCareOrder(id, staffId);
        return AjaxResult.success();
    }

    @PutMapping("/care-order/{id}/complete")
    public AjaxResult completeCareOrder(@PathVariable Long id, @RequestBody Map<String, Object> body) {
        String checkResult = parseStr(body.get("checkResult"));
        String supportMeasure = parseStr(body.get("supportMeasure"));
        String disposalResult = parseStr(body.get("disposalResult"));
        careOrderService.completeCareOrder(id, checkResult, supportMeasure, disposalResult);
        // 同时创建处置记录
        ElDisposalRecord record = new ElDisposalRecord();
        record.setCareId(id);
        record.setHandlerId(SecurityUtils.getUserId());
        record.setHandleTime(LocalDateTime.now());
        record.setCheckResult(checkResult);
        record.setSupportMeasure(supportMeasure);
        record.setDisposalResult(disposalResult);
        record.setCreateTime(LocalDateTime.now());
        disposalRecordMapper.insert(record);
        return AjaxResult.success();
    }

    // ==================== 工单相关增强 ====================

    /** 工单详情（包含处置记录） */
    @GetMapping("/care-order/{id}")
    public AjaxResult careOrderDetail(@PathVariable Long id) {
        ElCareOrder order = careOrderMapper.selectById(id);
        if (order == null) return AjaxResult.error("工单不存在");
        // 填充老人姓名
        fillOrderNames(List.of(order));
        // 获取处置记录
        List<ElDisposalRecord> records = disposalRecordMapper.selectList(
            new LambdaQueryWrapper<ElDisposalRecord>()
                .eq(ElDisposalRecord::getCareId, id)
                .orderByDesc(ElDisposalRecord::getHandleTime)
        );
        fillRecordHandlerNames(records);
        Map<String, Object> result = new LinkedHashMap<>();
        result.put("order", order);
        result.put("records", records);
        return AjaxResult.success(result);
    }

    // ==================== 私有方法 ==

    private void fillAlertNames(List<ElAlert> alerts) {
        if (alerts == null || alerts.isEmpty()) return;
        // 获取老人信息
        List<Long> residentIds = alerts.stream().map(ElAlert::getResidentId)
            .distinct().collect(Collectors.toList());
        if (!residentIds.isEmpty()) {
            String ids = residentIds.stream().map(String::valueOf).collect(Collectors.joining(","));
            List<Map<String, Object>> residents = jdbcTemplate.queryForList(
                "SELECT r.resident_id, r.name, r.phone, r.emergency_contact, " +
                "r.emergency_name, r.emergency_phone, r.emergency_relation, " +
                "CONCAT(b.building_no, h.house_no) as address " +
                "FROM cm_resident r " +
                "LEFT JOIN cm_house h ON r.house_id = h.house_id " +
                "LEFT JOIN cm_building b ON h.building_id = b.building_id " +
                "WHERE r.resident_id IN (" + ids + ")");
            Map<Long, Map<String, Object>> residentMap = residents.stream().collect(Collectors.toMap(
                r -> ((Number) r.get("resident_id")).longValue(),
                r -> r,
                (a, b) -> a));
            alerts.forEach(a -> {
                Map<String, Object> info = residentMap.get(a.getResidentId());
                if (info != null) {
                    a.setResidentName((String) info.get("name"));
                    a.setAddress((String) info.get("address"));
                    a.setElderPhone((String) info.get("phone"));
                    a.setFamilyPhone(formatEmergencyContact(info));
                } else {
                    a.setResidentName("未知");
                }
            });
        }
        // 获取处理人姓名
        List<Long> handlerIds = alerts.stream().map(ElAlert::getHandlerId)
            .filter(id -> id != null).distinct().collect(Collectors.toList());
        if (!handlerIds.isEmpty()) {
            Map<Long, String> handlerMap = accountService.findDisplayNames(handlerIds);
            alerts.forEach(a -> {
                if (a.getHandlerId() != null) {
                    a.setHandlerName(handlerMap.getOrDefault(a.getHandlerId(), "未知"));
                }
            });
        }
    }

    /** 填充单个预警的老人详细信息 */
    private void fillAlertElderInfo(ElAlert alert) {
        fillAlertNames(List.of(alert));
    }

    /** 拆分预警规则描述与 AI 建议（兼容旧数据 content 含「| AI建议：」） */
    private void enrichAlertDisplay(ElAlert alert) {
        if (alert == null) {
            return;
        }
        String content = alert.getContent();
        String reason = content;
        String aiFromContent = null;
        if (StringUtils.hasText(content)) {
            int idx = content.indexOf(" | AI建议：");
            if (idx >= 0) {
                reason = content.substring(0, idx).trim();
                aiFromContent = content.substring(idx + " | AI建议：".length()).trim();
            }
        }
        alert.setAlertReason(reason);

        ElAiMonitorLog monitorLog = monitorLogMapper.selectOne(
            new LambdaQueryWrapper<ElAiMonitorLog>()
                .eq(ElAiMonitorLog::getAlertId, alert.getAlertId())
                .orderByDesc(ElAiMonitorLog::getCheckTime)
                .last("LIMIT 1")
        );
        if (monitorLog != null) {
            if (StringUtils.hasText(monitorLog.getReason())) {
                alert.setAlertReason(monitorLog.getReason());
            }
            if (StringUtils.hasText(monitorLog.getAiResponse())) {
                alert.setAiSuggestion(monitorLog.getAiResponse());
            }
        }
        if (!StringUtils.hasText(alert.getAiSuggestion()) && StringUtils.hasText(aiFromContent)) {
            alert.setAiSuggestion(aiFromContent);
        }
    }

    /** 填充处置记录的处理人姓名 */
    private void fillRecordHandlerNames(List<ElDisposalRecord> records) {
        if (records == null || records.isEmpty()) return;
        List<Long> handlerIds = records.stream().map(ElDisposalRecord::getHandlerId)
            .filter(Objects::nonNull).distinct().collect(Collectors.toList());
        if (!handlerIds.isEmpty()) {
            Map<Long, String> nameMap = accountService.findDisplayNames(handlerIds);
            records.forEach(r -> r.setHandlerName(nameMap.getOrDefault(r.getHandlerId(), "未知")));
        }
    }

    private void fillOrderNames(List<ElCareOrder> orders) {
        if (orders == null || orders.isEmpty()) return;
        // 获取老人姓名
        List<Long> residentIds = orders.stream().map(ElCareOrder::getResidentId)
            .distinct().collect(Collectors.toList());
        if (!residentIds.isEmpty()) {
            String ids = residentIds.stream().map(String::valueOf).collect(Collectors.joining(","));
            List<Map<String, Object>> residents = jdbcTemplate.queryForList(
                "SELECT r.resident_id, r.name, h.building_id, " +
                "CONCAT(IFNULL(b.building_no,''), IFNULL(h.house_no,'')) as address " +
                "FROM cm_resident r " +
                "LEFT JOIN cm_house h ON r.house_id = h.house_id " +
                "LEFT JOIN cm_building b ON h.building_id = b.building_id " +
                "WHERE r.resident_id IN (" + ids + ")");
            Map<Long, Map<String, Object>> residentMap = residents.stream().collect(Collectors.toMap(
                r -> ((Number) r.get("resident_id")).longValue(),
                r -> r,
                (a, b) -> a));
            orders.forEach(o -> {
                Map<String, Object> info = residentMap.get(o.getResidentId());
                if (info != null) {
                    o.setElderName((String) info.get("name"));
                    o.setAddress((String) info.get("address"));
                    Object bid = info.get("building_id");
                    if (bid != null) {
                        o.setBuildingId(((Number) bid).longValue());
                    }
                } else {
                    o.setElderName("未知");
                }
            });
        }
        // 获取指派人员姓名
        List<Long> assigneeIds = orders.stream().map(ElCareOrder::getAssigneeId)
            .filter(id -> id != null).distinct().collect(Collectors.toList());
        if (!assigneeIds.isEmpty()) {
            String ids = assigneeIds.stream().map(String::valueOf).collect(Collectors.joining(","));
            List<Map<String, Object>> staffs = jdbcTemplate.queryForList(
                "SELECT staff_id, name FROM el_care_staff WHERE staff_id IN (" + ids + ")");
            Map<Long, String> staffMap = staffs.stream().collect(Collectors.toMap(
                r -> ((Number) r.get("staff_id")).longValue(),
                r -> (String) r.get("name"),
                (a, b) -> a));
            orders.forEach(o -> {
                if (o.getAssigneeId() != null) {
                    o.setAssigneeName(staffMap.getOrDefault(o.getAssigneeId(), "未知"));
                }
            });
        }
    }

    private Integer parseInt(Object value) {
        if (value == null) return null;
        try {
            return Integer.valueOf(value.toString());
        } catch (NumberFormatException e) {
            return null;
        }
    }

    private String parseStr(Object value) {
        return value != null ? value.toString() : null;
    }

    private LocalDateTime parseDateTime(Object value) {
        if (value == null || !StringUtils.hasText(value.toString())) {
            return null;
        }
        String text = value.toString().trim();
        try {
            if (text.contains("T")) {
                return LocalDateTime.parse(text.replace(" ", "T").substring(0, Math.min(19, text.length())));
            }
            return LocalDateTime.parse(text, java.time.format.DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));
        } catch (Exception e) {
            try {
                return LocalDateTime.parse(text, java.time.format.DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm"));
            } catch (Exception ex) {
                return null;
            }
        }
    }

    private String formatEmergencyContact(Map<String, Object> info) {
        String name = info.get("emergency_name") != null ? info.get("emergency_name").toString() : "";
        String phone = info.get("emergency_phone") != null ? info.get("emergency_phone").toString() : "";
        String relation = info.get("emergency_relation") != null ? info.get("emergency_relation").toString() : "";
        if (StringUtils.hasText(name) || StringUtils.hasText(phone)) {
            String rel = StringUtils.hasText(relation) ? "（" + relation + "）" : "";
            return name + rel + (StringUtils.hasText(phone) ? " " + phone : "");
        }
        Object legacy = info.get("emergency_contact");
        return legacy != null ? legacy.toString() : "";
    }

    // ==================== 临时监护登记 ====================

    @GetMapping("/temp-guardian/list")
    public AjaxResult tempGuardianList(@RequestParam(required = false) Long residentId) {
        List<ElTempGuardian> list = tempGuardianMapper.selectList(
            new LambdaQueryWrapper<ElTempGuardian>()
                .eq(residentId != null, ElTempGuardian::getResidentId, residentId)
                .orderByDesc(ElTempGuardian::getStartTime)
        );
        return AjaxResult.success(list);
    }

    @PostMapping("/temp-guardian")
    public AjaxResult addTempGuardian(@RequestBody ElTempGuardian guardian) {
        guardian.setStatus("1");
        guardian.setCreateTime(LocalDateTime.now());
        tempGuardianMapper.insert(guardian);
        return AjaxResult.success();
    }

    @PutMapping("/temp-guardian/{id}/close")
    public AjaxResult closeTempGuardian(@PathVariable Long id) {
        ElTempGuardian upd = new ElTempGuardian();
        upd.setId(id);
        upd.setStatus("0");
        tempGuardianMapper.updateById(upd);
        return AjaxResult.success();
    }
}
