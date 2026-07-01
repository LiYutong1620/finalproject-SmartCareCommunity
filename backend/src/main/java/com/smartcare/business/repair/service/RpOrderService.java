package com.smartcare.business.repair.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.smartcare.business.repair.domain.RpOrder;
import com.smartcare.business.repair.domain.RpOrderProgress;
import com.smartcare.business.repair.mapper.RpOrderMapper;
import com.smartcare.business.repair.mapper.RpOrderProgressMapper;
import com.smartcare.common.exception.ServiceException;
import com.smartcare.system.service.SysMessageService;
import com.smartcare.system.domain.SysMessage;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.concurrent.ThreadLocalRandom;

@Service
@RequiredArgsConstructor
public class RpOrderService {

    private final RpOrderMapper orderMapper;
    private final RpOrderProgressMapper progressMapper;
    private final SysMessageService messageService;

    public String generateOrderNo() {
        return "RP" + LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMddHHmmss"))
            + ThreadLocalRandom.current().nextInt(1000, 9999);
    }

    @Transactional
    public RpOrder submit(RpOrder order) {
        order.setOrderNo(generateOrderNo());
        order.setStatus("pending");
        order.setUrgeCount(0);
        order.setFrozen(0);
        orderMapper.insert(order);
        addProgress(order.getOrderId(), "提交报修", order.getOwnerId().toString(), "业主提交报修单");
        return order;
    }

    public void addProgress(Long orderId, String node, String operator, String remark) {
        RpOrderProgress p = new RpOrderProgress();
        p.setOrderId(orderId);
        p.setNodeName(node);
        p.setOperator(operator);
        p.setRemark(remark);
        progressMapper.insert(p);
    }

    public Page<RpOrder> pageByOwner(Long ownerId, int pageNum, int pageSize, String status) {
        return orderMapper.selectPage(new Page<>(pageNum, pageSize),
            new LambdaQueryWrapper<RpOrder>()
                .eq(RpOrder::getOwnerId, ownerId)
                .eq(StringUtils.hasText(status), RpOrder::getStatus, status)
                .orderByDesc(RpOrder::getCreateTime));
    }

    public Page<RpOrder> pageAll(int pageNum, int pageSize, String status, String urgency) {
        return orderMapper.selectPage(new Page<>(pageNum, pageSize),
            new LambdaQueryWrapper<RpOrder>()
                .eq(StringUtils.hasText(status), RpOrder::getStatus, status)
                .eq(StringUtils.hasText(urgency), RpOrder::getUrgency, urgency)
                .orderByDesc(RpOrder::getCreateTime));
    }

    public Page<RpOrder> pageByWorker(Long workerId, int pageNum, int pageSize, String status) {
        return orderMapper.selectPage(new Page<>(pageNum, pageSize),
            new LambdaQueryWrapper<RpOrder>()
                .eq(RpOrder::getWorkerId, workerId)
                .eq(StringUtils.hasText(status), RpOrder::getStatus, status)
                .orderByDesc(RpOrder::getCreateTime));
    }

    public RpOrder getById(Long orderId) {
        RpOrder o = orderMapper.selectById(orderId);
        if (o == null) throw new ServiceException("工单不存在");
        return o;
    }

    @Transactional
    public void cancel(Long orderId, Long ownerId) {
        RpOrder o = getById(orderId);
        if (!o.getOwnerId().equals(ownerId)) throw new ServiceException("无权操作");
        if (!"pending".equals(o.getStatus()) || o.getWorkerId() != null) {
            throw new ServiceException("当前状态不可撤销");
        }
        o.setStatus("cancelled");
        orderMapper.updateById(o);
        addProgress(orderId, "撤销报修", ownerId.toString(), "业主撤销");
    }

    @Transactional
    public void urge(Long orderId, Long ownerId) {
        RpOrder o = getById(orderId);
        if (!o.getOwnerId().equals(ownerId)) throw new ServiceException("无权操作");
        if (o.getUrgeCount() >= 3) throw new ServiceException("今日催单次数已达上限");
        o.setUrgeCount(o.getUrgeCount() + 1);
        orderMapper.updateById(o);
        addProgress(orderId, "催单", ownerId.toString(), "业主发起催单");
    }

    @Transactional
    public void assign(Long orderId, Long workerId, String reason, String operator) {
        RpOrder o = getById(orderId);
        o.setWorkerId(workerId);
        o.setStatus("processing");
        o.setAssignReason(reason);
        orderMapper.updateById(o);
        addProgress(orderId, "派单", operator, "指派维修工:" + workerId);
        notifyUser(o.getOwnerId(), "order", "工单已派单", "工单" + o.getOrderNo() + "已指派维修人员");
    }

    @Transactional
    public void updateStatus(Long orderId, String status, String operator, String remark) {
        RpOrder o = getById(orderId);
        o.setStatus(status);
        orderMapper.updateById(o);
        addProgress(orderId, status, operator, remark);
    }

    @Transactional
    public void accept(Long orderId, Long workerId) {
        RpOrder o = getById(orderId);
        o.setWorkerId(workerId);
        o.setStatus("processing");
        orderMapper.updateById(o);
        addProgress(orderId, "接单", workerId.toString(), "维修工接单");
    }

    @Transactional
    public void complete(Long orderId) {
        updateStatus(orderId, "wait_accept", "system", "维修完成待验收");
    }

    @Transactional
    public void ownerAccept(Long orderId, String signImage, Integer score, String tags) {
        RpOrder o = getById(orderId);
        o.setSignImage(signImage);
        o.setStatus("completed");
        orderMapper.updateById(o);
        addProgress(orderId, "验收完成", o.getOwnerId().toString(), "评分:" + score);
    }

    @Transactional
    public RpOrder copyOrder(Long orderId, Long ownerId) {
        RpOrder src = getById(orderId);
        if (!"completed".equals(src.getStatus())) throw new ServiceException("仅已完成工单可复投");
        RpOrder copy = new RpOrder();
        copy.setOwnerId(ownerId);
        copy.setHouseId(src.getHouseId());
        copy.setTypeId(src.getTypeId());
        copy.setDescription(src.getDescription());
        copy.setUrgency(src.getUrgency());
        return submit(copy);
    }

    private void notifyUser(Long userId, String type, String title, String content) {
        SysMessage msg = new SysMessage();
        msg.setMsgType(type);
        msg.setTitle(title);
        msg.setContent(content);
        msg.setPriority("normal");
        messageService.send(msg, List.of(userId));
    }
}
