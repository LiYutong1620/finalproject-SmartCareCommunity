package com.smartcare.business.elder.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.smartcare.business.elder.domain.ElCareOrder;
import com.smartcare.business.elder.mapper.ElCareOrderMapper;
import com.smartcare.common.core.page.TableDataInfo;
import com.smartcare.common.exception.ServiceException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor
public class ElCareOrderService {

    private final ElCareOrderMapper careOrderMapper;

    @Transactional
    public void createCareOrder(ElCareOrder order) {
        if (order.getResidentId() == null) {
            throw new ServiceException("住户ID不能为空");
        }
        if (!StringUtils.hasText(order.getCareItem())) {
            throw new ServiceException("关怀事项不能为空");
        }
        order.setStatus("pending");
        if (order.getCreateTime() == null) {
            order.setCreateTime(LocalDateTime.now());
        }
        careOrderMapper.insert(order);
    }

    @Transactional
    public void assignCareOrder(Long careId, Long staffId) {
        ElCareOrder order = careOrderMapper.selectById(careId);
        if (order == null) {
            throw new ServiceException("关怀工单不存在");
        }
        if ("completed".equals(order.getStatus()) || "closed".equals(order.getStatus())) {
            throw new ServiceException("该工单已结束，无法指派");
        }
        ElCareOrder upd = new ElCareOrder();
        upd.setCareId(careId);
        upd.setAssigneeId(staffId);
        upd.setStatus("assigned");
        careOrderMapper.updateById(upd);
    }

    @Transactional
    public void completeCareOrder(Long careId, String checkResult, String supportMeasure, String disposalResult) {
        ElCareOrder order = careOrderMapper.selectById(careId);
        if (order == null) {
            throw new ServiceException("关怀工单不存在");
        }
        if ("completed".equals(order.getStatus())) {
            throw new ServiceException("该工单已完成");
        }
        ElCareOrder upd = new ElCareOrder();
        upd.setCareId(careId);
        upd.setStatus("completed");
        upd.setCheckResult(checkResult);
        upd.setSupportMeasure(supportMeasure);
        upd.setDisposalResult(disposalResult);
        // 同时拼接到result字段保持兼容
        upd.setResult("核查结果：" + (checkResult != null ? checkResult : "") +
            " | 帮扶措施：" + (supportMeasure != null ? supportMeasure : "") +
            " | 处置结果：" + (disposalResult != null ? disposalResult : ""));
        careOrderMapper.updateById(upd);
    }

    public TableDataInfo listCareOrders(int pageNum, int pageSize, String status, Long assigneeId) {
        LambdaQueryWrapper<ElCareOrder> qw = new LambdaQueryWrapper<ElCareOrder>()
            .eq(StringUtils.hasText(status), ElCareOrder::getStatus, status)
            .eq(assigneeId != null, ElCareOrder::getAssigneeId, assigneeId)
            .orderByDesc(ElCareOrder::getCreateTime);
        Page<ElCareOrder> page = careOrderMapper.selectPage(new Page<>(pageNum, pageSize), qw);
        return new TableDataInfo(page.getTotal(), page.getRecords());
    }

    /** 预警触发时自动创建待指派工单（一预警一工单） */
    @Transactional
    public Long createPendingOrderForAlert(Long alertId, Long residentId, String careItem, Integer level) {
        if (alertId != null) {
            ElCareOrder existing = careOrderMapper.selectOne(new LambdaQueryWrapper<ElCareOrder>()
                .eq(ElCareOrder::getAlertId, alertId)
                .last("LIMIT 1"));
            if (existing != null) {
                return existing.getCareId();
            }
        }
        ElCareOrder order = new ElCareOrder();
        order.setAlertId(alertId);
        order.setResidentId(residentId);
        order.setCareItem(careItem);
        order.setStatus("pending");
        order.setLevel(level);
        order.setCreateTime(LocalDateTime.now());
        careOrderMapper.insert(order);
        return order.getCareId();
    }

    public ElCareOrder getByAlertId(Long alertId) {
        if (alertId == null) {
            return null;
        }
        return careOrderMapper.selectOne(new LambdaQueryWrapper<ElCareOrder>()
            .eq(ElCareOrder::getAlertId, alertId)
            .last("LIMIT 1"));
    }
}
