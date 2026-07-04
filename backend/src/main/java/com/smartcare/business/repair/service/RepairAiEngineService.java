package com.smartcare.business.repair.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.smartcare.business.property.domain.CmHouse;
import com.smartcare.business.property.mapper.CmHouseMapper;
import com.smartcare.business.repair.domain.RpOrder;
import com.smartcare.business.repair.domain.RpOrderImage;
import com.smartcare.business.repair.domain.RpOrderProgress;
import com.smartcare.business.repair.domain.RpRepairType;
import com.smartcare.business.repair.domain.RpWorkerProfile;
import com.smartcare.business.repair.mapper.RpOrderMapper;
import com.smartcare.business.repair.mapper.RpOrderProgressMapper;
import com.smartcare.business.repair.mapper.RpRepairTypeMapper;
import com.smartcare.business.repair.mapper.RpWorkerProfileMapper;
import com.smartcare.business.repair.support.WorkerSkillCatalog;
import com.smartcare.framework.ai.ZhipuAiClient;
import com.smartcare.system.domain.SysUser;
import com.smartcare.system.service.UserAccountService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.ObjectProvider;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Objects;
import java.util.Set;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class RepairAiEngineService {

    private static final List<String> EMERGENCY_WORDS = List.of("漏电", "燃气泄漏", "燃气", "一氧化碳", "火灾", "爆炸", "冒烟", "紧急");
    private static final List<String> URGENT_WORDS = List.of("严重", "大量", "无法使用", "不停", "持续", "漫水", "跳闸");
    private static final List<String> HIGH_RISK_WORDS = List.of("漏电", "燃气泄漏", "燃气", "一氧化碳", "火灾", "爆炸");
    private static final int VISION_MAX_IMAGES = 3;

    private final RpOrderMapper orderMapper;
    private final RpOrderProgressMapper progressMapper;
    private final RpRepairTypeMapper typeMapper;
    private final RpWorkerProfileMapper workerProfileMapper;
    private final RpWorkerProfileService workerProfileService;
    private final UserAccountService accountService;
    private final CmHouseMapper houseMapper;
    private final RpOrderImageService imageService;
    private final RepairUploadService repairUploadService;
    private final ZhipuAiClient zhipuAiClient;
    private final ObjectMapper objectMapper;
    private final ObjectProvider<RpOrderService> orderServiceProvider;
    private final RepairDispatchConfigService dispatchConfigService;

    @Transactional
    public void processNewOrder(Long orderId) {
        RpOrder order = orderMapper.selectById(orderId);
        if (order == null) {
            return;
        }
        String text = nullToEmpty(order.getDescription()).toLowerCase(Locale.ROOT);
        ClassifyResult classify = classifyFault(order.getTypeId(), text);
        String urgency = classifyUrgency(text, order.getUrgency());
        boolean highRisk = detectHighRisk(text);
        boolean duplicate = detectDuplicate(order);

        List<RpOrderImage> images = imageService.getByOrderId(orderId);
        VisionAnalysisResult vision = analyzeWithVision(order, images, classify);
        if (vision != null) {
            if (vision.typeId() != null || StringUtils.hasText(vision.typeLabel())) {
                classify = new ClassifyResult(
                    vision.typeId() != null ? vision.typeId() : classify.typeId(),
                    StringUtils.hasText(vision.typeLabel()) ? vision.typeLabel() : classify.typeLabel()
                );
            }
            urgency = mergeUrgency(urgency, vision.urgency());
            highRisk = highRisk || vision.highRisk();
        } else if (!images.isEmpty() && "normal".equals(urgency)) {
            urgency = "urgent";
        }

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
        if (vision != null && StringUtils.hasText(vision.summary())) {
            remark.append("（GLM-4V：").append(vision.summary()).append("）");
        }
        if (highRisk) {
            remark.append("，高风险");
        }
        if (duplicate) {
            remark.append("，重复报修");
        }
        RpOrderService orderService = orderServiceProvider.getObject();
        orderService.addProgress(orderId, "AI智能分析", "AI", remark.toString());

        tryAutoDispatchAfterAnalysis(orderId);
    }

    private void tryAutoDispatchAfterAnalysis(Long orderId) {
        if (!dispatchConfigService.isAutoDispatchEnabled()) {
            return;
        }
        RpOrder order = orderMapper.selectById(orderId);
        if (order == null || !"pending".equals(order.getStatus()) || order.getWorkerId() != null) {
            return;
        }
        Map<String, Object> result = dispatchInternal(orderId, "AI系统自动派单");
        if (result == null) {
            RpOrderService orderService = orderServiceProvider.getObject();
            orderService.addProgress(orderId, "待人工派单", "AI", "暂无合适维修工，请物业审核后人工派单");
        }
    }

    @Transactional
    public void reanalyzeOrder(Long orderId) {
        processNewOrder(orderId);
    }

    @Transactional
    public Map<String, Object> batchAutoDispatch() {
        List<RpOrder> pending = orderMapper.selectList(new LambdaQueryWrapper<RpOrder>()
            .eq(RpOrder::getStatus, "pending")
            .isNull(RpOrder::getWorkerId)
            .orderByAsc(RpOrder::getCreateTime));
        int success = 0;
        int skipped = 0;
        List<String> failures = new ArrayList<>();
        for (RpOrder order : pending) {
            if (Integer.valueOf(1).equals(order.getHighRisk()) || Integer.valueOf(1).equals(order.getDuplicateFlag())) {
                skipped++;
                continue;
            }
            Map<String, Object> result = dispatchInternal(order.getOrderId(), "AI批量自动派单");
            if (result != null) {
                success++;
            } else {
                failures.add(order.getOrderNo());
            }
        }
        Map<String, Object> summary = new LinkedHashMap<>();
        summary.put("success", success);
        summary.put("skipped", skipped);
        summary.put("failed", failures.size());
        summary.put("failedOrderNos", failures);
        return summary;
    }

    public Map<String, Object> recommendWorker(Long orderId) {
        RpOrder order = orderMapper.selectById(orderId);
        if (order == null) {
            return Map.of();
        }
        String typeLabel = resolveTypeLabel(order);
        Long buildingId = null;
        if (order.getHouseId() != null) {
            CmHouse house = houseMapper.selectById(order.getHouseId());
            if (house != null) {
                buildingId = house.getBuildingId();
            }
        }
        Long finalBuildingId = buildingId;
        List<Map<String, Object>> ranked = accountService.listByUserType("1").stream()
            .filter(w -> "0".equals(w.getStatus()))
            .map(worker -> scoreWorker(worker, finalBuildingId, typeLabel))
            .filter(Objects::nonNull)
            .sorted(Comparator.comparingInt(WorkerScore::score).reversed())
            .limit(5)
            .map(ws -> {
                SysUser w = accountService.findById(ws.workerId());
                Map<String, Object> item = new LinkedHashMap<>();
                item.put("workerId", ws.workerId());
                item.put("workerName", w != null && StringUtils.hasText(w.getNickName()) ? w.getNickName() : ws.workerId());
                item.put("score", ws.score());
                return item;
            })
            .toList();
        Map<String, Object> data = new LinkedHashMap<>();
        data.put("typeLabel", typeLabel);
        data.put("candidates", ranked);
        data.put("recommendedWorkerId", ranked.isEmpty() ? null : ranked.get(0).get("workerId"));
        return data;
    }

    @Transactional
    public void redispatchAfterReject(Long orderId, Long rejectedWorkerId) {
        RpOrder order = orderMapper.selectById(orderId);
        if (order == null || !"pending".equals(order.getStatus())) {
            return;
        }
        Set<Long> excluded = collectRejectedWorkerIds(orderId, rejectedWorkerId);
        Map<String, Object> result = dispatchInternalExcluding(orderId, "AI拒单后自动改派", excluded);
        if (result == null) {
            RpOrderService orderService = orderServiceProvider.getObject();
            orderService.addProgress(orderId, "待人工派单", "AI", "推荐维修工均已拒单或暂无合适人选，请物业人工派单");
        }
    }

    private Set<Long> collectRejectedWorkerIds(Long orderId, Long latestRejected) {
        Set<Long> excluded = new HashSet<>();
        if (latestRejected != null) {
            excluded.add(latestRejected);
        }
        List<RpOrderProgress> records = progressMapper.selectList(new LambdaQueryWrapper<RpOrderProgress>()
            .eq(RpOrderProgress::getOrderId, orderId)
            .eq(RpOrderProgress::getNodeName, "拒单"));
        for (RpOrderProgress record : records) {
            String remark = record.getRemark();
            if (!StringUtils.hasText(remark) || !remark.startsWith("REJECT_WID:")) {
                continue;
            }
            int pipe = remark.indexOf('|');
            String idPart = pipe > 0 ? remark.substring("REJECT_WID:".length(), pipe) : remark.substring("REJECT_WID:".length());
            try {
                excluded.add(Long.parseLong(idPart.trim()));
            } catch (NumberFormatException ignored) {
                // skip malformed
            }
        }
        return excluded;
    }

    private Map<String, Object> dispatchInternalExcluding(Long orderId, String reason, Set<Long> excludedWorkerIds) {
        RpOrder order = orderMapper.selectById(orderId);
        if (order == null || !"pending".equals(order.getStatus())) {
            return null;
        }
        String typeLabel = resolveTypeLabel(order);
        Long workerId = selectWorkerExcluding(order, typeLabel, excludedWorkerIds);
        if (workerId == null) {
            return null;
        }
        orderServiceProvider.getObject().assign(orderId, workerId, reason, "AI");
        SysUser worker = accountService.findById(workerId);
        String workerName = worker != null && StringUtils.hasText(worker.getNickName())
            ? worker.getNickName() : String.valueOf(workerId);
        return Map.of("workerId", workerId, "workerName", workerName, "typeLabel", typeLabel);
    }

    private Long selectWorkerExcluding(RpOrder order, String typeLabel, Set<Long> excludedWorkerIds) {
        Set<Long> excluded = excludedWorkerIds == null ? Set.of() : excludedWorkerIds;
        List<SysUser> workers = accountService.listByUserType("1").stream()
            .filter(w -> "0".equals(w.getStatus()))
            .filter(w -> !excluded.contains(w.getUserId()))
            .toList();
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

    @Transactional
    public Map<String, Object> autoDispatch(Long orderId) {
        return dispatchInternal(orderId, "物业触发AI派单");
    }

    private Map<String, Object> dispatchInternal(Long orderId, String reason) {
        RpOrder order = orderMapper.selectById(orderId);
        if (order == null || !"pending".equals(order.getStatus())) {
            return null;
        }
        String typeLabel = resolveTypeLabel(order);
        Long workerId = selectWorker(order, typeLabel);
        if (workerId == null) {
            return null;
        }
        orderServiceProvider.getObject().assign(orderId, workerId, reason, "AI");
        SysUser worker = accountService.findById(workerId);
        String workerName = worker != null && StringUtils.hasText(worker.getNickName())
            ? worker.getNickName() : String.valueOf(workerId);
        return Map.of("workerId", workerId, "workerName", workerName, "typeLabel", typeLabel);
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
                List<RpRepairType> all = typeMapper.selectList(new LambdaQueryWrapper<>());
                return new ClassifyResult(existingTypeId, buildTypeLabel(type, all));
            }
        }
        List<RpRepairType> types = typeMapper.selectList(new LambdaQueryWrapper<>());
        Map<Long, RpRepairType> typeMap = types.stream()
            .collect(Collectors.toMap(RpRepairType::getTypeId, t -> t, (a, b) -> a));
        RpRepairType best = null;
        int bestScore = 0;
        for (RpRepairType type : types) {
            int score = scoreType(type, text, typeMap);
            if (isLeaf(type, types)) {
                score += 2;
            }
            if (score > bestScore) {
                bestScore = score;
                best = type;
            }
        }
        if (best != null && bestScore > 0) {
            if (!isLeaf(best, types)) {
                RpRepairType child = findBestChild(best.getTypeId(), types, text, typeMap);
                if (child != null) {
                    return new ClassifyResult(child.getTypeId(), buildTypeLabel(child, types));
                }
            }
            return new ClassifyResult(best.getTypeId(), buildTypeLabel(best, types));
        }
        return new ClassifyResult(null, "其他故障");
    }

    private boolean isLeaf(RpRepairType type, List<RpRepairType> all) {
        Long id = type.getTypeId();
        return all.stream().noneMatch(t -> id.equals(t.getParentId()));
    }

    private RpRepairType findBestChild(Long parentId, List<RpRepairType> all, String text,
                                       Map<Long, RpRepairType> typeMap) {
        RpRepairType best = null;
        int bestScore = 0;
        for (RpRepairType type : all) {
            if (!parentId.equals(type.getParentId())) {
                continue;
            }
            int score = scoreType(type, text, typeMap);
            if (score > bestScore) {
                bestScore = score;
                best = type;
            }
        }
        return bestScore > 0 ? best : null;
    }

    private String buildTypeLabel(RpRepairType type, List<RpRepairType> all) {
        if (type.getParentId() != null && type.getParentId() > 0) {
            for (RpRepairType parent : all) {
                if (type.getParentId().equals(parent.getTypeId())) {
                    return parent.getTypeName() + "/" + type.getTypeName();
                }
            }
        }
        return type.getTypeName();
    }

    private int scoreType(RpRepairType type, String text, Map<Long, RpRepairType> typeMap) {
        int score = scoreText(type.getTypeName(), text, 12);
        score += scoreKeywords(type.getKeywords(), text, 15);
        if (type.getParentId() != null && type.getParentId() > 0) {
            RpRepairType parent = typeMap.get(type.getParentId());
            if (parent != null) {
                score += scoreText(parent.getTypeName(), text, 6);
                score += scoreKeywords(parent.getKeywords(), text, 10);
            }
        }
        return score;
    }

    private int scoreKeywords(String keywords, String text, int hitScore) {
        if (!StringUtils.hasText(keywords)) {
            return 0;
        }
        int score = 0;
        for (String part : keywords.split("[,，、]")) {
            score += scoreText(part.trim(), text, hitScore);
        }
        return score;
    }

    private int scoreText(String source, String text, int fullHitScore) {
        if (!StringUtils.hasText(source)) {
            return 0;
        }
        String lowerName = source.toLowerCase(Locale.ROOT);
        if (text.contains(lowerName)) {
            return fullHitScore;
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
        List<SysUser> workers = accountService.listByUserType("1").stream()
            .filter(w -> "0".equals(w.getStatus()))
            .toList();
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
        if (profile != null) {
            score += WorkerSkillCatalog.levelScore(profile.getWorkerLevel());
            if (workerProfileService.hasApprovedCert(worker.getUserId())) {
                score += 5;
            }
        }
        List<String> skills = workerProfileService.listApprovedSkillNames(worker.getUserId());
        score += WorkerSkillCatalog.matchTypeLabel(skills, typeLabel);
        score += 5;
        return new WorkerScore(worker.getUserId(), score);
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

    /**
     * 使用 GLM-4V 对报修图文进行多模态分诊；未配置 API Key 或无图片时返回 null。
     */
    private VisionAnalysisResult analyzeWithVision(RpOrder order, List<RpOrderImage> images,
                                                   ClassifyResult ruleFallback) {
        if (images == null || images.isEmpty() || !zhipuAiClient.isAvailable()) {
            return null;
        }
        List<String> imageUrls = images.stream()
            .map(RpOrderImage::getImageUrl)
            .filter(StringUtils::hasText)
            .toList();
        List<String> base64List = repairUploadService.loadImageBase64List(imageUrls, VISION_MAX_IMAGES);
        if (base64List.isEmpty()) {
            return null;
        }

        List<RpRepairType> types = typeMapper.selectList(new LambdaQueryWrapper<>());
        String typeOptions = types.stream()
            .filter(t -> isLeaf(t, types))
            .map(t -> buildTypeLabel(t, types))
            .distinct()
            .limit(30)
            .collect(Collectors.joining("、"));

        String prompt = """
            你是社区报修智能分诊助手。请结合文字描述与现场图片，判断故障类型、紧急程度与是否高风险。
            可选故障类型（优先从中选择，格式可为「大类/小类」）：%s
            文字描述：%s
            请严格只输出 JSON，不要 markdown：
            {"typeLabel":"故障类型","urgency":"emergency或urgent或normal","highRisk":true或false,"summary":"20字内现场判断"}
            urgency 规则：漏电/燃气/火灾/爆炸等为 emergency；大量漏水/严重堵塞等为 urgent；其余 normal。
            highRisk：漏电、燃气泄漏、火灾、爆炸等应为 true。
            """.formatted(typeOptions, nullToEmpty(order.getDescription()));

        try {
            String raw = zhipuAiClient.multimodalChat(prompt, base64List);
            JsonNode node = parseJsonNode(raw);
            if (node == null) {
                return null;
            }
            String typeLabel = node.path("typeLabel").asText("");
            String urgency = normalizeUrgency(node.path("urgency").asText(""));
            boolean highRisk = node.path("highRisk").asBoolean(false);
            String summary = node.path("summary").asText("");
            Long typeId = resolveTypeIdByLabel(typeLabel, types);
            if (!StringUtils.hasText(typeLabel) && ruleFallback != null) {
                typeLabel = ruleFallback.typeLabel();
                typeId = ruleFallback.typeId();
            }
            return new VisionAnalysisResult(typeId, typeLabel, urgency, highRisk, summary);
        } catch (Exception e) {
            log.warn("GLM-4V 报修分诊失败，回退规则引擎: {}", e.getMessage());
            return null;
        }
    }

    private JsonNode parseJsonNode(String raw) {
        if (!StringUtils.hasText(raw)) {
            return null;
        }
        String text = raw.trim();
        int start = text.indexOf('{');
        int end = text.lastIndexOf('}');
        if (start >= 0 && end > start) {
            text = text.substring(start, end + 1);
        }
        try {
            return objectMapper.readTree(text);
        } catch (Exception e) {
            return null;
        }
    }

    private String normalizeUrgency(String urgency) {
        if (!StringUtils.hasText(urgency)) {
            return "normal";
        }
        String u = urgency.trim().toLowerCase(Locale.ROOT);
        if ("emergency".equals(u) || "紧急".equals(u)) {
            return "emergency";
        }
        if ("urgent".equals(u) || "较急".equals(u)) {
            return "urgent";
        }
        return "normal";
    }

    private String mergeUrgency(String ruleUrgency, String visionUrgency) {
        int ruleScore = urgencyScore(ruleUrgency);
        int visionScore = urgencyScore(visionUrgency);
        return visionScore >= ruleScore ? visionUrgency : ruleUrgency;
    }

    private int urgencyScore(String urgency) {
        return switch (nullToEmpty(urgency)) {
            case "emergency" -> 3;
            case "urgent" -> 2;
            default -> 1;
        };
    }

    private Long resolveTypeIdByLabel(String typeLabel, List<RpRepairType> types) {
        if (!StringUtils.hasText(typeLabel) || types.isEmpty()) {
            return null;
        }
        String label = typeLabel.trim();
        for (RpRepairType type : types) {
            if (!isLeaf(type, types)) {
                continue;
            }
            String built = buildTypeLabel(type, types);
            if (label.equals(built) || label.equals(type.getTypeName())) {
                return type.getTypeId();
            }
        }
        String lower = label.toLowerCase(Locale.ROOT);
        for (RpRepairType type : types) {
            if (!isLeaf(type, types)) {
                continue;
            }
            String built = buildTypeLabel(type, types).toLowerCase(Locale.ROOT);
            if (lower.contains(built) || built.contains(lower)) {
                return type.getTypeId();
            }
        }
        return null;
    }

    private record ClassifyResult(Long typeId, String typeLabel) {}

    private record WorkerScore(Long workerId, int score) {}

    private record VisionAnalysisResult(Long typeId, String typeLabel, String urgency,
                                        boolean highRisk, String summary) {}
}
