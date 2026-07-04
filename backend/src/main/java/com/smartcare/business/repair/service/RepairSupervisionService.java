package com.smartcare.business.repair.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.smartcare.business.property.domain.CmBuilding;
import com.smartcare.business.property.domain.CmHouse;
import com.smartcare.business.property.mapper.CmBuildingMapper;
import com.smartcare.business.property.mapper.CmHouseMapper;
import com.smartcare.business.repair.domain.RpOrder;
import com.smartcare.business.repair.domain.RpRepairType;
import com.smartcare.business.repair.mapper.RpOrderMapper;
import com.smartcare.business.repair.mapper.RpRepairTypeMapper;
import com.smartcare.system.domain.SysUser;
import com.smartcare.system.service.UserAccountService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class RepairSupervisionService {

    private final RpOrderMapper orderMapper;
    private final RpRepairTypeMapper typeMapper;
    private final CmHouseMapper houseMapper;
    private final CmBuildingMapper buildingMapper;
    private final UserAccountService accountService;
    private final RepairDispatchConfigService dispatchConfigService;

    public Map<String, Object> stats() {
        Map<String, Object> stats = new HashMap<>();
        stats.put("pending", countByStatus("pending"));
        stats.put("assigned", countByStatus("assigned"));
        stats.put("processing", countByStatus("processing"));
        stats.put("waitAccept", countByStatus("wait_accept"));
        stats.put("completedToday", countCompletedSince(LocalDateTime.now().toLocalDate().atStartOfDay()));
        stats.put("highRiskPending", orderMapper.selectCount(new LambdaQueryWrapper<RpOrder>()
            .eq(RpOrder::getStatus, "pending")
            .eq(RpOrder::getHighRisk, 1)));
        stats.put("duplicatePending", orderMapper.selectCount(new LambdaQueryWrapper<RpOrder>()
            .eq(RpOrder::getStatus, "pending")
            .eq(RpOrder::getDuplicateFlag, 1)));
        stats.put("autoDispatchEnabled", dispatchConfigService.isAutoDispatchEnabled());
        return stats;
    }

    public Page<Map<String, Object>> pageEnriched(int pageNum, int pageSize, String status, String urgency,
                                                   Long typeId, Integer highRisk, Integer duplicateFlag,
                                                   LocalDateTime startTime, LocalDateTime endTime) {
        LambdaQueryWrapper<RpOrder> qw = new LambdaQueryWrapper<RpOrder>()
            .eq(StringUtils.hasText(status), RpOrder::getStatus, status)
            .eq(StringUtils.hasText(urgency), RpOrder::getUrgency, urgency)
            .eq(typeId != null, RpOrder::getTypeId, typeId)
            .eq(highRisk != null, RpOrder::getHighRisk, highRisk)
            .eq(duplicateFlag != null, RpOrder::getDuplicateFlag, duplicateFlag)
            .ge(startTime != null, RpOrder::getCreateTime, startTime)
            .le(endTime != null, RpOrder::getCreateTime, endTime)
            .orderByDesc(RpOrder::getCreateTime);
        Page<RpOrder> raw = orderMapper.selectPage(new Page<>(pageNum, pageSize), qw);
        Map<Long, String> typeNames = typeMapper.selectList(null).stream()
            .collect(Collectors.toMap(RpRepairType::getTypeId, RpRepairType::getTypeName, (a, b) -> a));
        List<Map<String, Object>> rows = new ArrayList<>();
        for (RpOrder order : raw.getRecords()) {
            rows.add(toRow(order, typeNames));
        }
        Page<Map<String, Object>> page = new Page<>(pageNum, pageSize, raw.getTotal());
        page.setRecords(rows);
        return page;
    }

    private Map<String, Object> toRow(RpOrder order, Map<Long, String> typeNames) {
        Map<String, Object> row = new HashMap<>();
        row.put("orderId", order.getOrderId());
        row.put("orderNo", order.getOrderNo());
        row.put("description", order.getDescription());
        row.put("status", order.getStatus());
        row.put("urgency", order.getUrgency());
        row.put("typeId", order.getTypeId());
        row.put("workerId", order.getWorkerId());
        row.put("highRisk", order.getHighRisk());
        row.put("duplicateFlag", order.getDuplicateFlag());
        row.put("aiTypeLabel", order.getAiTypeLabel());
        row.put("createTime", order.getCreateTime());
        row.put("expectedTime", order.getExpectedTime());
        row.put("assignReason", order.getAssignReason());
        row.put("typeName", resolveTypeName(order, typeNames));
        row.put("ownerName", resolveOwnerName(order.getOwnerId()));
        row.put("ownerAddress", resolveAddress(order.getHouseId()));
        row.put("workerName", resolveWorkerName(order.getWorkerId()));
        row.put("needManualDispatch", "pending".equals(order.getStatus())
            && (Integer.valueOf(1).equals(order.getHighRisk()) || Integer.valueOf(1).equals(order.getDuplicateFlag())));
        return row;
    }

    private String resolveTypeName(RpOrder order, Map<Long, String> typeNames) {
        if (StringUtils.hasText(order.getAiTypeLabel())) {
            return order.getAiTypeLabel();
        }
        if (order.getTypeId() != null && typeNames.containsKey(order.getTypeId())) {
            return typeNames.get(order.getTypeId());
        }
        return "—";
    }

    private String resolveOwnerName(Long ownerId) {
        if (ownerId == null) {
            return "—";
        }
        SysUser user = accountService.findById(ownerId);
        if (user == null) {
            return "—";
        }
        return StringUtils.hasText(user.getNickName()) ? user.getNickName() : user.getUsername();
    }

    private String resolveWorkerName(Long workerId) {
        if (workerId == null) {
            return null;
        }
        SysUser user = accountService.findById(workerId);
        if (user == null) {
            return "ID:" + workerId;
        }
        return StringUtils.hasText(user.getNickName()) ? user.getNickName() : user.getUsername();
    }

    private String resolveAddress(Long houseId) {
        if (houseId == null) {
            return "—";
        }
        CmHouse house = houseMapper.selectById(houseId);
        if (house == null) {
            return "—";
        }
        CmBuilding building = house.getBuildingId() != null ? buildingMapper.selectById(house.getBuildingId()) : null;
        String buildingNo = building != null ? building.getBuildingNo() : "";
        return buildingNo + (StringUtils.hasText(house.getHouseNo()) ? house.getHouseNo() : "");
    }

    private long countByStatus(String status) {
        return orderMapper.selectCount(new LambdaQueryWrapper<RpOrder>().eq(RpOrder::getStatus, status));
    }

    private long countCompletedSince(LocalDateTime since) {
        return orderMapper.selectCount(new LambdaQueryWrapper<RpOrder>()
            .eq(RpOrder::getStatus, "completed")
            .ge(RpOrder::getUpdateTime, since));
    }
}
