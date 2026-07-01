package com.smartcare.business.repair.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.smartcare.business.property.domain.CmHouse;
import com.smartcare.business.property.mapper.CmHouseMapper;
import com.smartcare.business.repair.domain.RpOrder;
import com.smartcare.business.repair.domain.RpRepairType;
import com.smartcare.business.repair.domain.RpWorkerProfile;
import com.smartcare.business.repair.mapper.RpOrderMapper;
import com.smartcare.business.repair.mapper.RpRepairTypeMapper;
import com.smartcare.business.repair.mapper.RpWorkerProfileMapper;
import com.smartcare.system.domain.SysUser;
import com.smartcare.system.mapper.SysUserMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.ObjectProvider;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.time.LocalDateTime;
import java.util.Comparator;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Objects;

@Service
@RequiredArgsConstructor
public class RepairAiEngineService {

    private static final List<String> EMERGENCY_WORDS = List.of("漏电", "燃气泄漏", "燃气", "一氧化碳", "火灾", "爆炸", "冒烟", "紧急");
    private static final List<String> URGENT_WORDS = List.of("严重", "大量", "无法使用", "不停", "持续", "漫水", "跳闸");
    private static final List<String> HIGH_RISK_WORDS = List.of("漏电", "燃气泄漏", "燃气", "一氧化碳", "火灾", "爆炸");

    private final RpOrderMapper orderMapper;
    private final RpRepairTypeMapper typeMapper;
    private final RpWorkerProfileMapper workerProfileMapper;
    private final SysUserMapper userMapper;
    private final CmHouseMapper houseMapper;
    private final RpOrderImageService imageService;
    private final ObjectProvider<RpOrderService> orderServiceProvider;

    @Transactional
    public void processNewOrder(Long orderId) {
        RpOrder order = orderMapper.selectById(orderId);
        if (order == null) {
            return;
        }
        String text = nullToEmpty(order.getDescription()).toLowerCase(Locale.ROOT);
        ClassifyResult classify = classifyFault(order.getTypeId(), text);
        String urgency = classifyUrgency(text, order.getUrgency());
        if (!imageService.getByOrderId(orderId).isEmpty() && "normal".equals(urgency)) {
            urgency = "urgent";
        }
        boolean highRisk = detectHighRisk(text);
        boolean duplicate = detectDuplicate(order);

        if (order.getTypeId() == null && classify.typeId() != null) {
            order.setTypeId(classify.typeId());
        }
        order.setAiTypeLabel(classify.typeLabel());
        order.setUrgency(urgency);
        order.setHighRisk(highRisk ? 1 : 0);
        order.setDuplicateFlag(duplicate ? 1 : 0);
        orderMapper.updateById(order);

        StringBuilder remark = new StringBuilder("AI识别：")
            .append(classify.typeLabel())
            .append("，紧急程度=").append(urgencyLabel(urgency));
        if (highRisk) {
            remark.append("，高风险");
        }
        if (duplicate) {
            remark.append("，重复报修");
        }
        RpOrderService orderService = orderServiceProvider.getObject();
        orderService.addProgress(orderId, "AI智能分析", "AI", remark.toString());
    }

    @Transactional
    public Long autoDispatch(Long orderId) {
        RpOrder order = orderMapper.selectById(orderId);
        if (order == null || !"pending".equals(order.getStatus())) {
            return null;
        }
        String typeLabel = resolveTypeLabel(order);
        Long workerId = selectWorker(order, typeLabel);
        if (workerId != null) {
            orderServiceProvider.getObject().assign(orderId, workerId, "AI手动触发自动派单", "AI");
        }
        return workerId;
    }

    public Map<String, Object> analyzePreview(String description, Long typeId) {
        String text = nullToEmpty(description).toLowerCase(Locale.ROOT);
        ClassifyResult classify = classifyFault(typeId, text);
        return Map.of(
            "typeId", classify.typeId(),
            "typeLabel", classify.typeLabel(),
            "urgency", classifyUrgency(text, "normal"),
            "highRisk", detectHighRisk(text),
            "urgencyLabel", urgencyLabel(classifyUrgency(text, "normal"))
        );
    }

    private ClassifyResult classifyFault(Long existingTypeId, String text) {
        if (existingTypeId != null) {
            RpRepairType type = typeMapper.selectById(existingTypeId);
            if (type != null) {
                return new ClassifyResult(existingTypeId, type.getTypeName());
            }
        }
        List<RpRepairType> types = typeMapper.selectList(new LambdaQueryWrapper<>());
        RpRepairType best = null;
        int bestScore = 0;
        for (RpRepairType type : types) {
            int score = scoreType(type.getTypeName(), text);
            if (score > bestScore) {
                bestScore = score;
                best = type;
            }
        }
        if (best != null && bestScore > 0) {
            return new ClassifyResult(best.getTypeId(), best.getTypeName());
        }
        if (containsAny(text, "漏水", "水管", "龙头", "渗水")) {
            return new ClassifyResult(2L, "水管漏水");
        }
        if (containsAny(text, "跳闸", "短路", "插座", "电路", "漏电")) {
            return new ClassifyResult(4L, "跳闸");
        }
        if (containsAny(text, "马桶", "堵塞", "下水道")) {
            return new ClassifyResult(1L, "马桶堵塞");
        }
        return new ClassifyResult(null, "其他故障");
    }

    private int scoreType(String typeName, String text) {
        if (!StringUtils.hasText(typeName)) {
            return 0;
        }
        String lowerName = typeName.toLowerCase(Locale.ROOT);
        if (text.contains(lowerName)) {
            return 10;
        }
        int score = 0;
        if (lowerName.length() >= 2) {
            for (int i = 0; i + 2 <= lowerName.length(); i++) {
                String token = lowerName.substring(i, i + 2);
                if (text.contains(token)) {
                    score += 2;
                }
            }
        }
        return score;
    }

    private String classifyUrgency(String text, String current) {
        if (containsAny(text, EMERGENCY_WORDS)) {
            return "emergency";
        }
        if (containsAny(text, URGENT_WORDS)) {
            return "urgent";
        }
        return StringUtils.hasText(current) ? current : "normal";
    }

    private boolean detectHighRisk(String text) {
        return containsAny(text, HIGH_RISK_WORDS);
    }

    private boolean detectDuplicate(RpOrder order) {
        if (order.getHouseId() == null) {
            return false;
        }
        LambdaQueryWrapper<RpOrder> qw = new LambdaQueryWrapper<RpOrder>()
            .eq(RpOrder::getHouseId, order.getHouseId())
            .ne(RpOrder::getOrderId, order.getOrderId())
            .ne(RpOrder::getStatus, "cancelled")
            .ge(RpOrder::getCreateTime, LocalDateTime.now().minusDays(7));
        if (order.getTypeId() != null) {
            qw.eq(RpOrder::getTypeId, order.getTypeId());
        }
        return orderMapper.selectCount(qw) > 0;
    }

    private Long selectWorker(RpOrder order, String typeLabel) {
        List<SysUser> workers = userMapper.selectList(new LambdaQueryWrapper<SysUser>()
            .eq(SysUser::getUserType, "1")
            .eq(SysUser::getStatus, "0"));
        if (workers.isEmpty()) {
            return null;
        }
        Long buildingId = null;
        if (order.getHouseId() != null) {
            CmHouse house = houseMapper.selectById(order.getHouseId());
            if (house != null) {
                buildingId = house.getBuildingId();
            }
        }
        Long finalBuildingId = buildingId;
        return workers.stream()
            .map(worker -> scoreWorker(worker, finalBuildingId, typeLabel))
            .filter(Objects::nonNull)
            .max(Comparator.comparingInt(WorkerScore::score))
            .map(WorkerScore::workerId)
            .orElse(workers.get(0).getUserId());
    }

    private WorkerScore scoreWorker(SysUser worker, Long buildingId, String typeLabel) {
        RpWorkerProfile profile = workerProfileMapper.selectById(worker.getUserId());
        if (profile != null && ("rest".equals(profile.getWorkStatus()) || "busy".equals(profile.getWorkStatus()))) {
            return null;
        }
        int score = 0;
        if (profile != null && profile.getAvgScore() != null) {
            score += profile.getAvgScore().intValue() * 10;
        }
        if (buildingId != null && buildingId.equals(worker.getBuildingId())) {
            score += 30;
        }
        if (profile != null && StringUtils.hasText(profile.getCertName())) {
            score += skillMatch(profile.getCertName(), typeLabel);
        }
        if (profile == null || !"rest".equals(profile.getWorkStatus())) {
            score += 5;
        }
        return new WorkerScore(worker.getUserId(), score);
    }

    private int skillMatch(String certName, String typeLabel) {
        if (!StringUtils.hasText(certName) || !StringUtils.hasText(typeLabel)) {
            return 0;
        }
        if (typeLabel.contains("电") || typeLabel.contains("跳闸")) {
            return certName.contains("电") ? 25 : 0;
        }
        if (typeLabel.contains("水") || typeLabel.contains("漏")) {
            return certName.contains("水") || certName.contains("暖") ? 25 : 0;
        }
        return certName.contains("维修") ? 10 : 5;
    }

    private String resolveTypeLabel(RpOrder order) {
        if (StringUtils.hasText(order.getAiTypeLabel())) {
            return order.getAiTypeLabel();
        }
        if (order.getTypeId() != null) {
            RpRepairType type = typeMapper.selectById(order.getTypeId());
            if (type != null) {
                return type.getTypeName();
            }
        }
        return "其他故障";
    }

    private boolean containsAny(String text, List<String> words) {
        for (String word : words) {
            if (text.contains(word.toLowerCase(Locale.ROOT))) {
                return true;
            }
        }
        return false;
    }

    private boolean containsAny(String text, String... words) {
        for (String word : words) {
            if (text.contains(word.toLowerCase(Locale.ROOT))) {
                return true;
            }
        }
        return false;
    }

    private String urgencyLabel(String urgency) {
        return switch (urgency) {
            case "emergency" -> "紧急";
            case "urgent" -> "较急";
            default -> "普通";
        };
    }

    private String nullToEmpty(String value) {
        return value == null ? "" : value;
    }

    private record ClassifyResult(Long typeId, String typeLabel) {}

    private record WorkerScore(Long workerId, int score) {}
}
