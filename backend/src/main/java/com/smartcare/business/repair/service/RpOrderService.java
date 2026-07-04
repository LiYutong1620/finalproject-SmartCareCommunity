package com.smartcare.business.repair.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.smartcare.business.property.domain.CmBuilding;
import com.smartcare.business.property.domain.CmHouse;
import com.smartcare.business.property.mapper.CmBuildingMapper;
import com.smartcare.business.property.mapper.CmHouseMapper;
import com.smartcare.business.repair.domain.RpOrder;
import com.smartcare.business.repair.domain.RpOrderFieldRecord;
import com.smartcare.business.repair.domain.RpOrderEval;
import com.smartcare.business.repair.domain.RpOrderImage;
import com.smartcare.business.repair.domain.RpOrderProgress;
import com.smartcare.business.repair.mapper.RpOrderMapper;
import com.smartcare.business.repair.mapper.RpOrderProgressMapper;
import com.smartcare.common.exception.ServiceException;
import com.smartcare.system.domain.SysMessage;
import com.smartcare.system.domain.SysUser;
import com.smartcare.system.service.UserAccountService;
import com.smartcare.system.service.SysMessageService;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.ObjectProvider;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

@Service
@RequiredArgsConstructor
public class RpOrderService {

    private final RpOrderMapper orderMapper;
    private final RpOrderProgressMapper progressMapper;
    private final SysMessageService messageService;
    private final RpOrderImageService imageService;
    private final RpOrderEvalService evalService;
    private final RpOrderFieldService fieldService;
    private final RpWorkerProfileService workerProfileService;
    private final CmHouseMapper houseMapper;
    private final CmBuildingMapper buildingMapper;
    private final UserAccountService accountService;
    private final ObjectProvider<RepairAiEngineService> aiEngineProvider;

    /** 工单号：RP + yyyyMMdd + 当日4位序号，共14字符，如 RP202606210001 */
    public String generateOrderNo() {
        String prefix = "RP" + LocalDate.now().format(DateTimeFormatter.BASIC_ISO_DATE);
        int next = maxDailySeq(prefix) + 1;
        if (next > 9999) {
            throw new ServiceException("当日工单编号已达上限");
        }
        return prefix + String.format("%04d", next);
    }

    private int maxDailySeq(String prefix) {
        List<RpOrder> list = orderMapper.selectList(
            new LambdaQueryWrapper<RpOrder>()
                .likeRight(RpOrder::getOrderNo, prefix)
                .select(RpOrder::getOrderNo));
        int max = 0;
        int suffixLen = 4;
        for (RpOrder o : list) {
            String no = o.getOrderNo();
            if (!StringUtils.hasText(no) || !no.startsWith(prefix)) {
                continue;
            }
            String suffix = no.substring(prefix.length());
            if (suffix.length() == suffixLen && suffix.chars().allMatch(Character::isDigit)) {
                try {
                    max = Math.max(max, Integer.parseInt(suffix));
                } catch (NumberFormatException ignored) {
                    // skip invalid
                }
            }
        }
        return max;
    }

    @Transactional
    public RpOrder submit(RpOrder order) {
        order.setOrderNo(generateOrderNo());
        order.setStatus("pending");
        order.setUrgeCount(0);
        order.setFrozen(0);
        if (!StringUtils.hasText(order.getUrgency())) {
            order.setUrgency("normal");
        }
        orderMapper.insert(order);
        addProgress(order.getOrderId(), "提交报修", userDisplayName(order.getOwnerId()), "业主提交报修单");
        aiEngineProvider.ifAvailable(engine -> engine.processNewOrder(order.getOrderId()));
        RpOrder latest = orderMapper.selectById(order.getOrderId());
        return latest != null ? latest : order;
    }

    @Transactional
    public RpOrder submitWithImages(RpOrder order, List<String> imageUrls) {
        RpOrder created = submit(order);
        imageService.saveImages(created.getOrderId(), imageUrls);
        return created;
    }

    public void addProgress(Long orderId, String node, String operator, String remark) {
        RpOrderProgress p = new RpOrderProgress();
        p.setOrderId(orderId);
        p.setNodeName(node);
        p.setOperator(operator);
        p.setRemark(remark);
        progressMapper.insert(p);
    }

    public Page<RpOrder> pageByOwner(Long ownerId, int pageNum, int pageSize, String status, String scope) {
        LambdaQueryWrapper<RpOrder> qw = new LambdaQueryWrapper<RpOrder>()
            .eq(RpOrder::getOwnerId, ownerId)
            .orderByDesc(RpOrder::getCreateTime);
        if (StringUtils.hasText(status)) {
            if ("processing".equals(status)) {
                qw.eq(RpOrder::getStatus, "processing");
            } else if ("pending".equals(status)) {
                // 业主端「待接单」Tab：含未派单与已派单待维修工接单
                qw.in(RpOrder::getStatus, "pending", "assigned");
            } else {
                qw.eq(RpOrder::getStatus, status);
            }
        } else if ("active".equals(scope)) {
            qw.notIn(RpOrder::getStatus, "completed", "cancelled");
        } else if ("history".equals(scope)) {
            qw.in(RpOrder::getStatus, "completed", "cancelled");
        }
        return orderMapper.selectPage(new Page<>(pageNum, pageSize), qw);
    }

    public Page<RpOrder> pageAll(int pageNum, int pageSize, String status, String urgency,
                                 Long typeId, LocalDateTime startTime, LocalDateTime endTime) {
        return orderMapper.selectPage(new Page<>(pageNum, pageSize), buildListQuery(status, urgency, typeId, startTime, endTime, null));
    }

    public Page<RpOrder> pageByWorker(Long workerId, int pageNum, int pageSize, String status,
                                      LocalDateTime startTime, LocalDateTime endTime) {
        LambdaQueryWrapper<RpOrder> qw = buildListQuery(status, null, null, startTime, endTime, workerId);
        return orderMapper.selectPage(new Page<>(pageNum, pageSize), qw);
    }

    /** 待办：待接单 + 处理中 + 待验收 */
    public Page<RpOrder> pageTodoByWorker(Long workerId, int pageNum, int pageSize,
                                          String status, String urgency) {
        LambdaQueryWrapper<RpOrder> qw = new LambdaQueryWrapper<RpOrder>()
            .eq(RpOrder::getWorkerId, workerId)
            .in(RpOrder::getStatus, "assigned", "processing", "wait_accept");
        if (StringUtils.hasText(status)) {
            qw.eq(RpOrder::getStatus, status);
        }
        if (StringUtils.hasText(urgency)) {
            qw.eq(RpOrder::getUrgency, urgency);
        }
        qw.orderByAsc(RpOrder::getStatus).orderByDesc(RpOrder::getCreateTime);
        Page<RpOrder> page = orderMapper.selectPage(new Page<>(pageNum, pageSize), qw);
        enrichWorkerTodoFlags(page.getRecords(), workerId);
        return page;
    }

    /** 历史：已完成工单，按完成时间倒序 */
    public Page<RpOrder> pageHistoryByWorker(Long workerId, int pageNum, int pageSize,
                                             LocalDateTime startTime, LocalDateTime endTime,
                                             String urgency) {
        LambdaQueryWrapper<RpOrder> qw = new LambdaQueryWrapper<RpOrder>()
            .eq(RpOrder::getWorkerId, workerId)
            .eq(RpOrder::getStatus, "completed")
            .orderByDesc(RpOrder::getUpdateTime);
        if (StringUtils.hasText(urgency)) {
            qw.eq(RpOrder::getUrgency, urgency);
        }
        if (startTime != null) {
            qw.ge(RpOrder::getUpdateTime, startTime);
        }
        if (endTime != null) {
            qw.le(RpOrder::getUpdateTime, endTime);
        }
        Page<RpOrder> page = orderMapper.selectPage(new Page<>(pageNum, pageSize), qw);
        enrichHistoryCompleteTime(page.getRecords());
        return page;
    }

    private void enrichHistoryCompleteTime(List<RpOrder> orders) {
        if (orders == null || orders.isEmpty()) {
            return;
        }
        List<Long> orderIds = orders.stream().map(RpOrder::getOrderId).toList();
        List<RpOrderProgress> progressList = progressMapper.selectList(
            new LambdaQueryWrapper<RpOrderProgress>()
                .in(RpOrderProgress::getOrderId, orderIds)
                .eq(RpOrderProgress::getNodeName, "验收完成"));
        Map<Long, LocalDateTime> completeTimeMap = new HashMap<>();
        for (RpOrderProgress p : progressList) {
            completeTimeMap.merge(p.getOrderId(), p.getCreateTime(),
                (a, b) -> a.isAfter(b) ? a : b);
        }
        for (RpOrder order : orders) {
            LocalDateTime completeTime = completeTimeMap.get(order.getOrderId());
            if (completeTime != null) {
                order.setRepairCompleteTime(completeTime);
            } else if (order.getUpdateTime() != null) {
                order.setRepairCompleteTime(order.getUpdateTime());
            }
        }
        orders.sort(Comparator.comparing(RpOrder::getRepairCompleteTime,
            Comparator.nullsLast(Comparator.reverseOrder())));
    }

    private void enrichWorkerTodoFlags(List<RpOrder> orders, Long workerId) {
        if (orders == null || orders.isEmpty()) {
            return;
        }
        Set<Long> appendOrderIds = messageService.findUnreadAppendOrderIds(workerId);
        for (RpOrder order : orders) {
            order.setAppendPending(appendOrderIds.contains(order.getOrderId()));
        }
    }

    private LambdaQueryWrapper<RpOrder> buildListQuery(String status, String urgency, Long typeId,
                                                       LocalDateTime startTime, LocalDateTime endTime,
                                                       Long workerId) {
        LambdaQueryWrapper<RpOrder> qw = new LambdaQueryWrapper<RpOrder>()
            .eq(workerId != null, RpOrder::getWorkerId, workerId)
            .eq(StringUtils.hasText(status), RpOrder::getStatus, status)
            .eq(StringUtils.hasText(urgency), RpOrder::getUrgency, urgency)
            .eq(typeId != null, RpOrder::getTypeId, typeId)
            .ge(startTime != null, RpOrder::getCreateTime, startTime)
            .le(endTime != null, RpOrder::getCreateTime, endTime)
            .orderByDesc(RpOrder::getCreateTime);
        return qw;
    }

    public Page<RpOrder> pagePendingPool(int pageNum, int pageSize) {
        return orderMapper.selectPage(new Page<>(pageNum, pageSize),
            new LambdaQueryWrapper<RpOrder>()
                .eq(RpOrder::getStatus, "pending")
                .isNull(RpOrder::getWorkerId)
                .orderByDesc(RpOrder::getCreateTime));
    }

    public RpOrder getById(Long orderId) {
        RpOrder o = orderMapper.selectById(orderId);
        if (o == null) throw new ServiceException("工单不存在");
        return o;
    }

    public Map<String, Object> buildDetail(Long orderId, Long userId, String role) {
        RpOrder order = getById(orderId);
        verifyAccess(order, userId, role);
        backfillProgressIfEmpty(order);
        List<RpOrderProgress> progress = progressMapper.selectList(
            new LambdaQueryWrapper<RpOrderProgress>()
                .eq(RpOrderProgress::getOrderId, orderId)
                .orderByAsc(RpOrderProgress::getCreateTime));
        progress.forEach(p -> {
            p.setOperator(resolveOperatorLabel(p.getOperator()));
            p.setRemark(sanitizeProgressRemark(p.getRemark()));
        });
        if ("completed".equals(order.getStatus())) {
            progress.stream()
                .filter(p -> "验收完成".equals(p.getNodeName()) || "完成维修".equals(p.getNodeName()))
                .max(Comparator.comparing(RpOrderProgress::getCreateTime, Comparator.nullsLast(Comparator.naturalOrder())))
                .ifPresentOrElse(
                    p -> order.setRepairCompleteTime(p.getCreateTime()),
                    () -> order.setRepairCompleteTime(order.getUpdateTime()));
        }
        if ("worker".equals(role)) {
            messageService.markReadByBizId(userId, orderId.toString(), "业主补充信息");
            order.setAppendPending(false);
            if ("assigned".equals(order.getStatus())) {
                messageService.markReadByBizId(userId, orderId.toString(), "系统派单");
            }
        }
        List<RpOrderImage> images = imageService.getByOrderId(orderId);
        Map<String, Object> data = new HashMap<>();
        data.put("order", order);
        data.put("progress", progress);
        data.put("images", images);
        if (order.getWorkerId() != null) {
            try {
                data.put("worker", workerProfileService.getWorkerPublicInfo(order.getWorkerId()));
            } catch (ServiceException ignored) {
                data.put("worker", null);
            }
        }
        data.put("owner", buildOwnerInfo(order));
        if ("worker".equals(role)) {
            Map<String, Object> fieldCtx = fieldService.buildWorkerFieldContext(orderId, order.getStatus());
            data.putAll(fieldCtx);
            if ("completed".equals(order.getStatus())) {
                RpOrderEval evaluation = evalService.findByOrderId(orderId);
                if (evaluation != null) {
                    data.put("evaluation", evaluation);
                }
            }
        } else if ("property".equals(role)) {
            data.put("fieldRecords", fieldService.listByOrderId(orderId));
            data.put("aiAnalysis", buildAiAnalysis(order, progress));
        }
        return data;
    }

    /** 从工单字段与 AI 分析进度节点组装结构化分诊结果（含 GLM-4V 摘要） */
    private Map<String, Object> buildAiAnalysis(RpOrder order, List<RpOrderProgress> progress) {
        Map<String, Object> ai = new LinkedHashMap<>();
        ai.put("typeLabel", order.getAiTypeLabel());
        ai.put("urgency", order.getUrgency());
        ai.put("highRisk", Integer.valueOf(1).equals(order.getHighRisk()));
        ai.put("duplicate", Integer.valueOf(1).equals(order.getDuplicateFlag()));
        ai.put("visionUsed", false);
        ai.put("visionSummary", "");
        ai.put("source", "rule");

        if (progress != null) {
            for (RpOrderProgress node : progress) {
                if (!"AI智能分析".equals(node.getNodeName()) || !StringUtils.hasText(node.getRemark())) {
                    continue;
                }
                String remark = node.getRemark();
                ai.put("rawRemark", remark);
                int marker = remark.indexOf("GLM-4V：");
                if (marker >= 0) {
                    ai.put("visionUsed", true);
                    ai.put("source", "glm-4v");
                    int start = marker + "GLM-4V：".length();
                    int end = remark.indexOf('）', start);
                    ai.put("visionSummary", end > start ? remark.substring(start, end) : remark.substring(start).trim());
                }
                break;
            }
        }
        return ai;
    }

    private Map<String, Object> buildOwnerInfo(RpOrder order) {
        Map<String, Object> owner = new HashMap<>();
        if (order.getOwnerId() != null) {
            SysUser user = accountService.findById(order.getOwnerId());
            if (user != null) {
                owner.put("name", StringUtils.hasText(user.getNickName()) ? user.getNickName() : user.getUsername());
                owner.put("phone", user.getPhone());
            }
        }
        if (order.getHouseId() != null) {
            CmHouse house = houseMapper.selectById(order.getHouseId());
            if (house != null) {
                owner.put("houseNo", house.getHouseNo());
                owner.put("area", house.getArea());
                if (house.getBuildingId() != null) {
                    CmBuilding building = buildingMapper.selectById(house.getBuildingId());
                    if (building != null) {
                        owner.put("address", building.getBuildingNo() + house.getHouseNo());
                    }
                }
            }
        }
        return owner;
    }

    private void verifyAccess(RpOrder order, Long userId, String role) {
        if (userId == null || !StringUtils.hasText(role)) {
            return;
        }
        switch (role) {
            case "owner" -> {
                if (!order.getOwnerId().equals(userId)) {
                    throw new ServiceException("无权查看该工单");
                }
            }
            case "worker" -> {
                boolean mine = userId.equals(order.getWorkerId());
                boolean pool = "pending".equals(order.getStatus()) && order.getWorkerId() == null;
                if (!mine && !pool) {
                    throw new ServiceException("无权查看该工单");
                }
            }
            case "property" -> {
                // 物业可查看全部
            }
            default -> throw new ServiceException("无权查看该工单");
        }
    }

    @Transactional
    public void cancel(Long orderId, Long ownerId) {
        RpOrder o = getById(orderId);
        if (!o.getOwnerId().equals(ownerId)) throw new ServiceException("无权操作");
        if (!"pending".equals(o.getStatus()) && !"assigned".equals(o.getStatus())) {
            throw new ServiceException("当前状态不可取消");
        }
        o.setStatus("cancelled");
        orderMapper.update(null, new LambdaUpdateWrapper<RpOrder>()
            .eq(RpOrder::getOrderId, orderId)
            .set(RpOrder::getStatus, "cancelled")
            .set(RpOrder::getWorkerId, null));
        addProgress(orderId, "取消报修", userDisplayName(ownerId), "业主取消");
    }

    @Transactional
    public void editPending(Long orderId, Long ownerId, String description, LocalDateTime expectedTime,
                            List<String> newImageUrls, List<Long> keepImageIds) {
        RpOrder o = getById(orderId);
        if (!o.getOwnerId().equals(ownerId)) {
            throw new ServiceException("无权操作");
        }
        if (!"pending".equals(o.getStatus()) && !"assigned".equals(o.getStatus())) {
            throw new ServiceException("仅待接单状态的工单可编辑");
        }
        if (!StringUtils.hasText(description)) {
            throw new ServiceException("请填写故障描述");
        }
        o.setDescription(description.trim());
        o.setExpectedTime(expectedTime);
        orderMapper.updateById(o);
        syncEditImages(orderId, keepImageIds, newImageUrls);
        addProgress(orderId, "编辑报修", userDisplayName(ownerId), "业主修改报修信息");
        aiEngineProvider.ifAvailable(engine -> engine.processNewOrder(orderId));
    }

    private void syncEditImages(Long orderId, List<Long> keepImageIds, List<String> newImageUrls) {
        Set<Long> keepSet = keepImageIds == null ? Set.of() : new HashSet<>(keepImageIds);
        List<RpOrderImage> current = imageService.getByOrderId(orderId);
        List<Long> removeIds = new ArrayList<>();
        for (RpOrderImage img : current) {
            if (!keepSet.contains(img.getImageId())) {
                removeIds.add(img.getImageId());
            }
        }
        imageService.deleteByIds(removeIds);
        int kept = keepSet.size();
        int adding = newImageUrls == null ? 0 : newImageUrls.size();
        if (kept + adding > 9) {
            throw new ServiceException("现场图片最多9张");
        }
        if (newImageUrls != null && !newImageUrls.isEmpty()) {
            imageService.saveImages(orderId, newImageUrls);
        }
    }

    @Transactional
    public void appendInfo(Long orderId, Long ownerId, String description, List<String> imageUrls) {
        RpOrder o = getById(orderId);
        if (!o.getOwnerId().equals(ownerId)) {
            throw new ServiceException("无权操作");
        }
        if (!"processing".equals(o.getStatus())) {
            throw new ServiceException("仅处理中的工单可追加信息");
        }
        if (!StringUtils.hasText(description) && (imageUrls == null || imageUrls.isEmpty())) {
            throw new ServiceException("请填写追加内容或上传图片");
        }
        if (StringUtils.hasText(description)) {
            String merged = nullToEmpty(o.getDescription()) + "\n[追加] " + description.trim();
            orderMapper.update(null, new LambdaUpdateWrapper<RpOrder>()
                .eq(RpOrder::getOrderId, orderId)
                .set(RpOrder::getDescription, merged));
        }
        if (imageUrls != null && !imageUrls.isEmpty()) {
            imageService.saveImages(orderId, imageUrls);
        }
        addProgress(orderId, "追加信息", userDisplayName(ownerId),
            StringUtils.hasText(description) ? description.trim() : "追加现场图片");
        if (o.getWorkerId() != null) {
            notifyUser(o.getWorkerId(), "order", "业主补充信息",
                "工单 #" + o.getOrderNo() + " 的业主追加了补充说明/图片", orderId);
        }
    }

    @Transactional
    public void assign(Long orderId, Long workerId, String reason, String operator) {
        RpOrder o = getById(orderId);
        o.setWorkerId(workerId);
        o.setStatus("assigned");
        o.setAssignReason(reason);
        orderMapper.updateById(o);
        addProgress(orderId, "派单", operator, "指派维修工：" + userDisplayName(workerId)
            + (StringUtils.hasText(reason) ? "，原因：" + reason : ""));
        notifyUser(o.getOwnerId(), "order", "工单已派单", "工单" + o.getOrderNo() + "已指派维修人员", orderId);
        notifyUser(workerId, "order", "系统派单", "您有一个新的工单需要处理", orderId);
    }

    @Transactional
    public void updateStatus(Long orderId, String status, String operator, String remark) {
        RpOrder o = getById(orderId);
        o.setStatus(status);
        orderMapper.updateById(o);
        addProgress(orderId, statusLabel(status), operator, remark);
    }

    @Transactional
    public void updateUrgencyAndType(Long orderId, String urgency, Long typeId, String reason, String operator) {
        RpOrder o = getById(orderId);
        if (StringUtils.hasText(urgency)) {
            o.setUrgency(urgency);
        }
        if (typeId != null) {
            o.setTypeId(typeId);
        }
        orderMapper.updateById(o);
        addProgress(orderId, "调整工单", operator, reason);
    }

    @Transactional
    public void accept(Long orderId, Long workerId) {
        RpOrder o = getById(orderId);
        if ("assigned".equals(o.getStatus())) {
            if (!workerId.equals(o.getWorkerId())) {
                throw new ServiceException("无权操作该工单");
            }
            o.setStatus("processing");
            orderMapper.updateById(o);
            addProgress(orderId, "接单", userDisplayName(workerId), "维修工确认接单");
            notifyUser(o.getOwnerId(), "order", "维修工已接单", "工单" + o.getOrderNo() + "维修工已接单处理", orderId);
            messageService.markReadByBizId(workerId, orderId.toString(), "系统派单");
            return;
        }
        if (!"pending".equals(o.getStatus())) {
            throw new ServiceException("当前工单不可接单");
        }
        if (o.getWorkerId() != null && !o.getWorkerId().equals(workerId)) {
            throw new ServiceException("工单已被其他维修工接单");
        }
        o.setWorkerId(workerId);
        o.setStatus("processing");
        orderMapper.updateById(o);
        addProgress(orderId, "接单", userDisplayName(workerId), "维修工接单");
        notifyUser(o.getOwnerId(), "order", "维修工已接单", "工单" + o.getOrderNo() + "维修工已接单处理", orderId);
    }

    @Transactional
    public void reject(Long orderId, Long workerId, String reason, String remark) {
        if (!StringUtils.hasText(reason)) {
            throw new ServiceException("请选择拒单原因");
        }
        if (!StringUtils.hasText(remark)) {
            throw new ServiceException("请填写拒单说明");
        }
        String fullReason = reason.trim() + "：" + remark.trim();
        if (fullReason.length() > 255) {
            fullReason = fullReason.substring(0, 255);
        }
        RpOrder o = getById(orderId);
        if ("assigned".equals(o.getStatus()) && workerId.equals(o.getWorkerId())) {
            orderMapper.update(null, new LambdaUpdateWrapper<RpOrder>()
                .eq(RpOrder::getOrderId, orderId)
                .set(RpOrder::getWorkerId, null)
                .set(RpOrder::getStatus, "pending")
                .set(RpOrder::getRejectReason, fullReason));
            addProgress(orderId, "拒单", userDisplayName(workerId), rejectProgressRemark(workerId, fullReason));
            aiEngineProvider.ifAvailable(engine -> engine.redispatchAfterReject(orderId, workerId));
            return;
        }
        if (!"pending".equals(o.getStatus())) {
            throw new ServiceException("当前工单不可拒单");
        }
        o.setRejectReason(fullReason);
        orderMapper.updateById(o);
        addProgress(orderId, "拒单", userDisplayName(workerId), fullReason);
    }

    @Transactional
    public RpOrderFieldRecord workerOnSite(Long orderId, Long workerId) {
        RpOrderFieldRecord record = fieldService.startOnSite(orderId, workerId);
        addProgress(orderId, "到场检查", userDisplayName(workerId), "维修工已到达现场");
        return record;
    }

    @Transactional
    public RpOrderFieldRecord saveFieldRecord(Long orderId, Long workerId, Long recordId,
                                              String content, List<String> imageUrls, boolean closeVisit) {
        return fieldService.saveRecord(orderId, workerId, recordId, content, imageUrls, closeVisit);
    }

    @Transactional
    public void complete(Long orderId, Long workerId) {
        RpOrder o = getById(orderId);
        if (workerId != null && !workerId.equals(o.getWorkerId())) {
            throw new ServiceException("无权操作该工单");
        }
        if (!"processing".equals(o.getStatus())) {
            throw new ServiceException("当前工单不可完成维修");
        }
        RpOrderFieldRecord record = fieldService.prepareForComplete(orderId, workerId);
        o.setStatus("wait_accept");
        orderMapper.updateById(o);
        String remark = StringUtils.hasText(record.getContent()) ? record.getContent() : "维修完成待验收";
        addProgress(orderId, "完成维修", workerId != null ? userDisplayName(workerId) : "系统", remark);
        notifyUser(o.getOwnerId(), "order", "待验收", "工单" + o.getOrderNo() + "已完成维修，请验收评价", orderId);
    }

    @Transactional
    public void ownerAccept(Long orderId, String signImage, Integer score, String tags, String content) {
        RpOrder o = getById(orderId);
        if (!"wait_accept".equals(o.getStatus())) {
            throw new ServiceException("当前工单不可验收");
        }
        o.setSignImage(signImage);
        o.setStatus("completed");
        orderMapper.updateById(o);
        addProgress(orderId, "验收完成", userDisplayName(o.getOwnerId()), "评分:" + score);
        if (score != null) {
            evalService.saveEval(orderId, score, tags, content);
        }
        if (o.getWorkerId() != null) {
            String evalContent = "工单 #" + o.getOrderNo() + " 的业主已完成验收评价"
                + (score != null ? "，评分：" + score : "");
            notifyUser(o.getWorkerId(), "order", "业主验收评价", evalContent, orderId);
        }
    }

    public void saveOrderImages(Long orderId, List<String> imageUrls) {
        imageService.saveImages(orderId, imageUrls);
    }

    private void notifyUser(Long userId, String type, String title, String content) {
        notifyUser(userId, type, title, content, null);
    }

    private void notifyUser(Long userId, String type, String title, String content, Long orderId) {
        SysMessage msg = new SysMessage();
        msg.setMsgType(type);
        msg.setTitle(title);
        msg.setContent(content);
        msg.setPriority("normal");
        if (orderId != null) {
            msg.setBizId(orderId.toString());
        }
        messageService.send(msg, List.of(userId));
    }

    private void backfillProgressIfEmpty(RpOrder order) {
        Long count = progressMapper.selectCount(
            new LambdaQueryWrapper<RpOrderProgress>().eq(RpOrderProgress::getOrderId, order.getOrderId()));
        if (count != null && count > 0) {
            return;
        }
        String ownerName = userDisplayName(order.getOwnerId());
        LocalDateTime base = order.getCreateTime() != null ? order.getCreateTime() : LocalDateTime.now();
        insertProgress(order.getOrderId(), "提交报修", ownerName, "业主提交报修单", base);
        insertProgress(order.getOrderId(), "AI智能分析", "智能引擎", "系统已自动分析故障类型与紧急程度", base.plusMinutes(1));
        if (order.getWorkerId() != null) {
            String workerName = userDisplayName(order.getWorkerId());
            insertProgress(order.getOrderId(), "派单", "物业派单", "指派维修工：" + workerName, base.plusHours(1));
            if ("wait_accept".equals(order.getStatus()) || "completed".equals(order.getStatus())) {
                insertProgress(order.getOrderId(), "完成维修", workerName, "维修完成待验收", base.plusHours(4));
            }
        }
        if ("wait_accept".equals(order.getStatus())) {
            insertProgress(order.getOrderId(), "待验收", "系统", "等待业主验收评价", base.plusHours(5));
        }
        if ("completed".equals(order.getStatus())) {
            insertProgress(order.getOrderId(), "验收完成", ownerName, "业主已验收", base.plusHours(6));
        }
        if ("cancelled".equals(order.getStatus())) {
            insertProgress(order.getOrderId(), "取消报修", ownerName, "业主取消", base.plusHours(1));
        }
    }

    private void insertProgress(Long orderId, String node, String operator, String remark, LocalDateTime time) {
        RpOrderProgress p = new RpOrderProgress();
        p.setOrderId(orderId);
        p.setNodeName(node);
        p.setOperator(operator);
        p.setRemark(remark);
        p.setCreateTime(time);
        progressMapper.insert(p);
    }

    private String userDisplayName(Long userId) {
        if (userId == null) {
            return "系统";
        }
        SysUser user = accountService.findById(userId);
        if (user == null) {
            return userId.toString();
        }
        return StringUtils.hasText(user.getNickName()) ? user.getNickName() : user.getUsername();
    }

    private String resolveOperatorLabel(String operator) {
        if (!StringUtils.hasText(operator)) {
            return "";
        }
        if ("AI".equalsIgnoreCase(operator)) {
            return "智能引擎";
        }
        if ("system".equalsIgnoreCase(operator)) {
            return "系统";
        }
        try {
            return userDisplayName(Long.parseLong(operator.trim()));
        } catch (NumberFormatException ignored) {
            return operator;
        }
    }

    private String rejectProgressRemark(Long workerId, String fullReason) {
        return "REJECT_WID:" + workerId + "|" + fullReason;
    }

    private String sanitizeProgressRemark(String remark) {
        if (!StringUtils.hasText(remark) || !remark.startsWith("REJECT_WID:")) {
            return remark;
        }
        int pipe = remark.indexOf('|');
        return pipe >= 0 && pipe + 1 < remark.length() ? remark.substring(pipe + 1) : remark;
    }

    private String statusLabel(String status) {
        return switch (status) {
            case "pending" -> "待接单";
            case "assigned" -> "待接单";
            case "processing" -> "处理中";
            case "wait_accept" -> "待验收";
            case "completed" -> "已完成";
            case "cancelled" -> "已取消";
            default -> status;
        };
    }

    private String nullToEmpty(String value) {
        return value == null ? "" : value;
    }
}
