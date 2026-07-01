package com.smartcare.business.elder.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.smartcare.business.elder.domain.*;
import com.smartcare.business.elder.mapper.ElAlertMapper;
import com.smartcare.business.elder.mapper.ElCareOrderMapper;
import com.smartcare.business.elder.mapper.ElDisposalRecordMapper;
import com.smartcare.business.elder.service.*;
import com.smartcare.common.core.domain.AjaxResult;
import com.smartcare.common.core.page.TableDataInfo;
import com.smartcare.framework.security.SecurityUtils;
import lombok.RequiredArgsConstructor;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/property/elder")
@RequiredArgsConstructor
public class ElderCareController {

    private final ElAlertMapper alertMapper;
    private final ElCareOrderMapper careOrderMapper;
    private final ElDisposalRecordMapper disposalRecordMapper;
    private final ElCareStaffService careStaffService;
    private final ElHealthMonitorService healthMonitorService;
    private final ElDisposalPlanService disposalPlanService;
    private final ElCareOrderService careOrderService;
    private final ElUtilityMonitorService utilityMonitorService;
    private final JdbcTemplate jdbcTemplate;

    // ==================== 预警管理 ====================

    @GetMapping("/alert/list")
    public AjaxResult alertList(@RequestParam(defaultValue = "1") int pageNum,
                                @RequestParam(defaultValue = "10") int pageSize,
                                @RequestParam(required = false) String alertType,
                                @RequestParam(required = false) String keyword,
                                @RequestParam(defaultValue = "createTime") String orderBy,
                                @RequestParam(defaultValue = "desc") String orderDir) {
        Page<ElAlert> page = alertMapper.selectPage(new Page<>(pageNum, pageSize),
            new LambdaQueryWrapper<ElAlert>()
                .eq(alertType != null && !alertType.isEmpty(), ElAlert::getAlertType, alertType)
                .like(keyword != null && !keyword.isEmpty(), ElAlert::getContent, keyword)
                .orderByDesc("desc".equals(orderDir), ElAlert::getCreateTime)
                .orderByAsc("asc".equals(orderDir), ElAlert::getCreateTime));

        // 填充老人姓名和处理人姓名
        List<ElAlert> records = page.getRecords();
        fillAlertNames(records);

        return AjaxResult.success(new TableDataInfo(page.getTotal(), records));
    }

    @PostMapping("/alert")
    public AjaxResult createAlert(@RequestBody ElAlert alert) {
        alert.setStatus("pending");
        alert.setCreateTime(LocalDateTime.now());
        alertMapper.insert(alert);
        return AjaxResult.success();
    }

    @PutMapping("/alert/handle")
    public AjaxResult handle(@RequestBody ElAlert alert) {
        alert.setHandlerId(SecurityUtils.getUserId());
        alert.setHandleTime(LocalDateTime.now());
        alert.setStatus("handled");
        alertMapper.updateById(alert);
        return AjaxResult.success();
    }

    /** 预警详情（包含老人信息、处置记录） */
    @GetMapping("/alert/{alertId}")
    public AjaxResult alertDetail(@PathVariable Long alertId) {
        ElAlert alert = alertMapper.selectById(alertId);
        if (alert == null) return AjaxResult.error("预警不存在");
        // 填充老人信息
        fillAlertElderInfo(alert);
        // 获取处置记录
        List<ElDisposalRecord> records = disposalRecordMapper.selectList(
            new LambdaQueryWrapper<ElDisposalRecord>()
                .eq(ElDisposalRecord::getAlertId, alertId)
                .orderByDesc(ElDisposalRecord::getHandleTime)
        );
        fillRecordHandlerNames(records);
        Map<String, Object> result = new LinkedHashMap<>();
        result.put("alert", alert);
        result.put("records", records);
        return AjaxResult.success(result);
    }

    /** 预警闭环（填写处置记录后状态变为已闭环） */
    @PutMapping("/alert/{alertId}/close")
    public AjaxResult closeAlert(@PathVariable Long alertId, @RequestBody Map<String, Object> body) {
        ElAlert alert = alertMapper.selectById(alertId);
        if (alert == null) return AjaxResult.error("预警不存在");
        // 创建处置记录
        ElDisposalRecord record = new ElDisposalRecord();
        record.setAlertId(alertId);
        record.setHandlerId(SecurityUtils.getUserId());
        record.setHandleTime(LocalDateTime.now());
        record.setCheckResult(parseStr(body.get("checkResult")));
        record.setSupportMeasure(parseStr(body.get("supportMeasure")));
        record.setDisposalResult(parseStr(body.get("disposalResult")));
        record.setCreateTime(LocalDateTime.now());
        disposalRecordMapper.insert(record);
        // 更新预警状态为已闭环
        ElAlert upd = new ElAlert();
        upd.setAlertId(alertId);
        upd.setStatus("closed");
        upd.setHandlerId(SecurityUtils.getUserId());
        upd.setHandleTime(LocalDateTime.now());
        upd.setHandleResult(parseStr(body.get("disposalResult")));
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

    // ==================== 关怀人员 ====================

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

    // ==================== 健康监测 ====================

    @PostMapping("/health/record")
    public AjaxResult recordHealth(@RequestBody Map<String, Object> body) {
        Long residentId = Optional.ofNullable(body.get("residentId"))
            .map(Object::toString).map(Long::valueOf).orElse(null);
        ElHealthRecord record = new ElHealthRecord();
        record.setHeartRate(parseInt(body.get("heartRate")));
        record.setBloodPressure(parseStr(body.get("bloodPressure")));
        record.setSteps(parseInt(body.get("steps")));
        healthMonitorService.recordHealthData(residentId, record);
        return AjaxResult.success();
    }

    @GetMapping("/health/{residentId}")
    public AjaxResult healthRecords(@PathVariable Long residentId,
                                    @RequestParam(defaultValue = "1") int pageNum,
                                    @RequestParam(defaultValue = "10") int pageSize) {
        return AjaxResult.success(healthMonitorService.listHealthRecords(residentId, pageNum, pageSize));
    }

    // ==================== 处置预案 ====================

    @GetMapping("/disposal-plan/list")
    public AjaxResult disposalPlanList(@RequestParam(defaultValue = "1") int pageNum,
                                       @RequestParam(defaultValue = "10") int pageSize,
                                       @RequestParam(required = false) Integer level) {
        return AjaxResult.success(disposalPlanService.list(pageNum, pageSize, level));
    }

    @PostMapping("/disposal-plan")
    public AjaxResult addDisposalPlan(@RequestBody ElDisposalPlan plan) {
        disposalPlanService.add(plan);
        return AjaxResult.success();
    }

    @PutMapping("/disposal-plan")
    public AjaxResult updateDisposalPlan(@RequestBody ElDisposalPlan plan) {
        disposalPlanService.update(plan);
        return AjaxResult.success();
    }

    @DeleteMapping("/disposal-plan/{planId}")
    public AjaxResult deleteDisposalPlan(@PathVariable Long planId) {
        disposalPlanService.delete(planId);
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
                    a.setFamilyPhone((String) info.get("emergency_contact"));
                } else {
                    a.setResidentName("未知");
                }
            });
        }
        // 获取处理人姓名
        List<Long> handlerIds = alerts.stream().map(ElAlert::getHandlerId)
            .filter(id -> id != null).distinct().collect(Collectors.toList());
        if (!handlerIds.isEmpty()) {
            String ids = handlerIds.stream().map(String::valueOf).collect(Collectors.joining(","));
            List<Map<String, Object>> users = jdbcTemplate.queryForList(
                "SELECT user_id, nick_name FROM sys_user WHERE user_id IN (" + ids + ")");
            Map<Long, String> handlerMap = users.stream().collect(Collectors.toMap(
                r -> ((Number) r.get("user_id")).longValue(),
                r -> (String) r.get("nick_name"),
                (a, b) -> a));
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

    /** 填充处置记录的处理人姓名 */
    private void fillRecordHandlerNames(List<ElDisposalRecord> records) {
        if (records == null || records.isEmpty()) return;
        List<Long> handlerIds = records.stream().map(ElDisposalRecord::getHandlerId)
            .filter(Objects::nonNull).distinct().collect(Collectors.toList());
        if (!handlerIds.isEmpty()) {
            String ids = handlerIds.stream().map(String::valueOf).collect(Collectors.joining(","));
            List<Map<String, Object>> users = jdbcTemplate.queryForList(
                "SELECT user_id, nick_name FROM sys_user WHERE user_id IN (" + ids + ")");
            Map<Long, String> nameMap = users.stream().collect(Collectors.toMap(
                r -> ((Number) r.get("user_id")).longValue(),
                r -> (String) r.get("nick_name"),
                (a, b) -> a));
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
                "SELECT resident_id, name FROM cm_resident WHERE resident_id IN (" + ids + ")");
            Map<Long, String> nameMap = residents.stream().collect(Collectors.toMap(
                r -> ((Number) r.get("resident_id")).longValue(),
                r -> (String) r.get("name"),
                (a, b) -> a));
            orders.forEach(o -> o.setElderName(nameMap.getOrDefault(o.getResidentId(), "未知")));
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
}
