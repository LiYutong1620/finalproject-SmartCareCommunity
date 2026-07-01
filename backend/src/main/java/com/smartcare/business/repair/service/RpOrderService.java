package com.smartcare.business.repair.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.smartcare.business.property.domain.CmBuilding;
import com.smartcare.business.property.domain.CmHouse;
import com.smartcare.business.property.mapper.CmBuildingMapper;
import com.smartcare.business.property.mapper.CmHouseMapper;
import com.smartcare.business.repair.domain.RpOrder;
import com.smartcare.business.repair.domain.RpOrderImage;
import com.smartcare.business.repair.domain.RpOrderProgress;
import com.smartcare.business.repair.mapper.RpOrderMapper;
import com.smartcare.business.repair.mapper.RpOrderProgressMapper;
import com.smartcare.common.exception.ServiceException;
import com.smartcare.system.domain.SysMessage;
import com.smartcare.system.domain.SysUser;
import com.smartcare.system.mapper.SysUserMapper;
import com.smartcare.system.service.SysMessageService;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Lazy;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ThreadLocalRandom;

@Service
@RequiredArgsConstructor
public class RpOrderService {

    private final RpOrderMapper orderMapper;
    private final RpOrderProgressMapper progressMapper;
    private final SysMessageService messageService;
    private final RpOrderImageService imageService;
    private final RpWorkerProfileService workerProfileService;
    private final SysUserMapper userMapper;
    private final CmHouseMapper houseMapper;
    private final CmBuildingMapper buildingMapper;
    @Lazy
    private final RepairAiEngineService repairAiEngineService;
    private final RepairStepTemplateService repairStepTemplateService;

    public String generateOrderNo() {
        return "RP" + LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMddHHmmss"))
            + ThreadLocalRandom.current().nextInt(1000, 9999);
    }

    @Transactional
    public RpOrder submit(RpOrder order) {
        return submit(order, null);
    }

    @Transactional
    public RpOrder submit(RpOrder order, List<String> imageUrls) {
        order.setOrderNo(generateOrderNo());
        order.setStatus("pending");
        order.setUrgeCount(0);
        order.setFrozen(0);
        order.setHighRisk(0);
        order.setDuplicateFlag(0);
        orderMapper.insert(order);

        if (imageUrls != null && !imageUrls.isEmpty()) {
            imageService.saveImages(order.getOrderId(), imageUrls);
        }

        addProgress(order.getOrderId(), "提交报修", order.getOwnerId().toString(), "业主提交报修单");
        repairAiEngineService.processNewOrder(order.getOrderId());
        return order;
    }

    @Transactional
    public void supplement(Long orderId, Long ownerId, String description, List<String> imageUrls) {
        RpOrder order = getById(orderId);
        if (!order.getOwnerId().equals(ownerId)) {
            throw new ServiceException("无权操作");
        }
        if (!"pending".equals(order.getStatus()) || order.getWorkerId() != null) {
            throw new ServiceException("当前状态不可补充");
        }
        if (StringUtils.hasText(description)) {
            String old = StringUtils.hasText(order.getDescription()) ? order.getDescription() : "";
            order.setDescription(old.isEmpty() ? description : old + "\n" + description);
            orderMapper.updateById(order);
        }
        if (imageUrls != null && !imageUrls.isEmpty()) {
            imageService.saveImages(orderId, imageUrls);
        }
        addProgress(orderId, "补充报修", ownerId.toString(), "业主补充报修信息");
    }

    public void addProgress(Long orderId, String node, String operator, String remark) {
        RpOrderProgress p = new RpOrderProgress();
        p.setOrderId(orderId);
        p.setNodeName(node);
        p.setOperator(operator);
        p.setRemark(remark);
        progressMapper.insert(p);
    }

    public List<RpOrderProgress> listProgress(Long orderId) {
        return progressMapper.selectList(
            new LambdaQueryWrapper<RpOrderProgress>()
                .eq(RpOrderProgress::getOrderId, orderId)
                .orderByAsc(RpOrderProgress::getCreateTime)
        );
    }

    public Map<String, Object> detail(Long orderId) {
        RpOrder order = getById(orderId);
        Map<String, Object> result = new HashMap<>();
        result.put("order", order);
        result.put("progress", listProgress(orderId));
        result.put("images", imageService.getByOrderId(orderId));
        return result;
    }

    public Map<String, Object> ownerDetail(Long orderId, Long ownerId) {
        RpOrder order = getById(orderId);
        if (!order.getOwnerId().equals(ownerId)) {
            throw new ServiceException("无权查看");
        }
        Map<String, Object> result = detail(orderId);
        if (order.getWorkerId() != null) {
            result.put("worker", workerProfileService.getWorkerPublicInfo(order.getWorkerId()));
        }
        return result;
    }

    public Map<String, Object> workerDetail(Long orderId, Long workerId) {
        RpOrder order = getById(orderId);
        if (order.getWorkerId() != null && !order.getWorkerId().equals(workerId)) {
            throw new ServiceException("无权查看");
        }
        Map<String, Object> result = detail(orderId);
        SysUser owner = userMapper.selectById(order.getOwnerId());
        if (owner != null) {
            Map<String, Object> ownerInfo = new HashMap<>();
            ownerInfo.put("nickName", owner.getNickName());
            ownerInfo.put("phone", RpWorkerProfileService.maskPhone(owner.getPhone()));
            result.put("owner", ownerInfo);
        }
        if (order.getHouseId() != null) {
            CmHouse house = houseMapper.selectById(order.getHouseId());
            if (house != null) {
                CmBuilding building = house.getBuildingId() != null
                    ? buildingMapper.selectById(house.getBuildingId()) : null;
                String buildingNo = building != null ? building.getBuildingNo() + "栋 " : "";
                result.put("houseAddress", buildingNo + house.getHouseNo());
            }
        }
        result.put("repairSteps", repairStepTemplateService.matchSteps(order.getTypeId(), order.getDescription()));
        return result;
    }

    @Transactional
    public List<String> saveWorkerImages(Long orderId, Long workerId, List<String> imageUrls) {
        RpOrder order = getById(orderId);
        if (order.getWorkerId() == null || !order.getWorkerId().equals(workerId)) {
            throw new ServiceException("无权操作");
        }
        if (imageUrls == null || imageUrls.isEmpty()) {
            throw new ServiceException("请上传图片");
        }
        List<RpOrderImage> existing = imageService.getByOrderId(orderId);
        if (existing.size() + imageUrls.size() > 9) {
            throw new ServiceException("现场图片最多9张");
        }
        imageService.saveImages(orderId, imageUrls);
        addProgress(orderId, "上传现场图", workerId.toString(), "上传" + imageUrls.size() + "张现场照片");
        return imageUrls;
    }

    public Page<RpOrder> pageByOwner(Long ownerId, int pageNum, int pageSize, String status) {
        return orderMapper.selectPage(new Page<>(pageNum, pageSize),
            new LambdaQueryWrapper<RpOrder>()
                .eq(RpOrder::getOwnerId, ownerId)
                .eq(StringUtils.hasText(status), RpOrder::getStatus, status)
                .orderByDesc(RpOrder::getCreateTime));
    }

    public Page<RpOrder> pageAll(int pageNum, int pageSize, String status, String urgency, String keyword,
                                 Long typeId, String startDate, String endDate) {
        LocalDateTime start = parseStart(startDate);
        LocalDateTime end = parseEnd(endDate);
        LambdaQueryWrapper<RpOrder> qw = new LambdaQueryWrapper<RpOrder>()
            .eq(StringUtils.hasText(status), RpOrder::getStatus, status)
            .eq(StringUtils.hasText(urgency), RpOrder::getUrgency, urgency)
            .eq(typeId != null, RpOrder::getTypeId, typeId)
            .ge(start != null, RpOrder::getCreateTime, start)
            .le(end != null, RpOrder::getCreateTime, end)
            .orderByDesc(RpOrder::getHighRisk)
            .orderByDesc(RpOrder::getCreateTime);
        if (StringUtils.hasText(keyword)) {
            qw.and(w -> w.like(RpOrder::getOrderNo, keyword).or().like(RpOrder::getDescription, keyword));
        }
        return orderMapper.selectPage(new Page<>(pageNum, pageSize), qw);
    }

    public Page<RpOrder> pageAll(int pageNum, int pageSize, String status, String urgency, String keyword) {
        return pageAll(pageNum, pageSize, status, urgency, keyword, null, null, null);
    }

    public Page<RpOrder> pageByWorker(Long workerId, int pageNum, int pageSize, String status, String urgency,
                                      String keyword, String startDate, String endDate) {
        LocalDateTime start = parseStart(startDate);
        LocalDateTime end = parseEnd(endDate);
        LambdaQueryWrapper<RpOrder> qw = new LambdaQueryWrapper<RpOrder>()
            .and(w -> w.eq(RpOrder::getWorkerId, workerId)
                .or(o -> o.eq(RpOrder::getStatus, "pending").isNull(RpOrder::getWorkerId)))
            .eq(StringUtils.hasText(status), RpOrder::getStatus, status)
            .eq(StringUtils.hasText(urgency), RpOrder::getUrgency, urgency)
            .ge(start != null, RpOrder::getCreateTime, start)
            .le(end != null, RpOrder::getCreateTime, end)
            .orderByDesc(RpOrder::getCreateTime);
        if (StringUtils.hasText(keyword)) {
            qw.and(w -> w.like(RpOrder::getOrderNo, keyword).or().like(RpOrder::getDescription, keyword));
        }
        return orderMapper.selectPage(new Page<>(pageNum, pageSize), qw);
    }

    public RpOrder getById(Long orderId) {
        RpOrder order = orderMapper.selectById(orderId);
        if (order == null) {
            throw new ServiceException("工单不存在");
        }
        return order;
    }

    @Transactional
    public void cancel(Long orderId, Long ownerId) {
        RpOrder order = getById(orderId);
        if (!order.getOwnerId().equals(ownerId)) {
            throw new ServiceException("无权操作");
        }
        if (!"pending".equals(order.getStatus()) || order.getWorkerId() != null) {
            throw new ServiceException("当前状态不可撤销，仅待分配且未派单的工单可撤销");
        }
        order.setStatus("cancelled");
        orderMapper.updateById(order);
        addProgress(orderId, "撤销报修", ownerId.toString(), "业主撤销");
    }

    @Transactional
    public void urge(Long orderId, Long ownerId) {
        RpOrder order = getById(orderId);
        if (!order.getOwnerId().equals(ownerId)) {
            throw new ServiceException("无权操作");
        }
        if (order.getUrgeCount() >= 3) {
            throw new ServiceException("今日催单次数已达上限");
        }
        order.setUrgeCount(order.getUrgeCount() + 1);
        orderMapper.updateById(order);
        addProgress(orderId, "催单", ownerId.toString(), "业主发起催单");
    }

    @Transactional
    public void assign(Long orderId, Long workerId, String reason, String operator) {
        RpOrder order = getById(orderId);
        order.setWorkerId(workerId);
        order.setStatus("processing");
        order.setAssignReason(reason);
        orderMapper.updateById(order);
        addProgress(orderId, "派单", operator, "指派维修工:" + workerId);
        notifyUser(order.getOwnerId(), "order", "工单已派单", "工单" + order.getOrderNo() + "已指派维修人员");
        notifyUser(workerId, "order", "新工单派单", "您有新的维修工单 " + order.getOrderNo() + "，请及时处理");
    }

    @Transactional
    public void adjust(Long orderId, String urgency, Long typeId, String operator, String reason) {
        RpOrder order = getById(orderId);
        if (StringUtils.hasText(urgency)) {
            order.setUrgency(urgency);
        }
        if (typeId != null) {
            order.setTypeId(typeId);
        }
        orderMapper.updateById(order);
        addProgress(orderId, "工单调整", operator, StringUtils.hasText(reason) ? reason : "调整紧急程度或故障类型");
    }

    @Transactional
    public void updateStatus(Long orderId, String status, String operator, String remark) {
        RpOrder order = getById(orderId);
        order.setStatus(status);
        orderMapper.updateById(order);
        addProgress(orderId, status, operator, remark);
    }

    @Transactional
    public void accept(Long orderId, Long workerId) {
        RpOrder order = getById(orderId);
        if (!"pending".equals(order.getStatus())) {
            throw new ServiceException("当前状态不可接单");
        }
        if (order.getWorkerId() != null && !workerId.equals(order.getWorkerId())) {
            throw new ServiceException("该工单已被其他维修工接单");
        }
        order.setWorkerId(workerId);
        order.setStatus("processing");
        orderMapper.updateById(order);
        addProgress(orderId, "接单", workerId.toString(), "维修工接单");
        notifyUser(order.getOwnerId(), "order", "维修工已接单", "工单" + order.getOrderNo() + "已有维修人员接单");
    }

    @Transactional
    public void reject(Long orderId, Long workerId, String reason) {
        RpOrder order = getById(orderId);
        if (order.getWorkerId() != null && !workerId.equals(order.getWorkerId())) {
            throw new ServiceException("无权操作");
        }
        orderMapper.update(null, new LambdaUpdateWrapper<RpOrder>()
            .eq(RpOrder::getOrderId, orderId)
            .set(RpOrder::getWorkerId, null)
            .set(RpOrder::getStatus, "pending")
            .set(RpOrder::getRejectReason, reason));
        addProgress(orderId, "拒单", workerId.toString(), reason);
    }

    @Transactional
    public void complete(Long orderId) {
        updateStatus(orderId, "wait_accept", "system", "维修完成待验收");
    }

    @Transactional
    public void ownerAccept(Long orderId, String signImage, Integer score, String tags) {
        RpOrder order = getById(orderId);
        order.setSignImage(signImage);
        order.setStatus("completed");
        orderMapper.updateById(order);
        addProgress(orderId, "验收完成", order.getOwnerId().toString(), "评分:" + score + (StringUtils.hasText(tags) ? " 标签:" + tags : ""));
    }

    @Transactional
    public RpOrder copyOrder(Long orderId, Long ownerId) {
        RpOrder src = getById(orderId);
        if (!"completed".equals(src.getStatus())) {
            throw new ServiceException("仅已完成工单可复投");
        }
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

    private LocalDateTime parseStart(String dateStr) {
        if (!StringUtils.hasText(dateStr)) {
            return null;
        }
        return LocalDate.parse(dateStr).atStartOfDay();
    }

    private LocalDateTime parseEnd(String dateStr) {
        if (!StringUtils.hasText(dateStr)) {
            return null;
        }
        return LocalDate.parse(dateStr).atTime(LocalTime.MAX);
    }
}
