package com.smartcare.business.repair.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.smartcare.business.repair.domain.RpOrder;
import com.smartcare.business.repair.domain.RpRepairType;
import com.smartcare.business.repair.mapper.RpRepairTypeMapper;
import com.smartcare.framework.ai.ZhipuAiClient;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

@Slf4j
@Service
@RequiredArgsConstructor
public class RepairAiStepService {

    private static final Pattern JSON_BLOCK = Pattern.compile("```(?:json)?\\s*([\\s\\S]*?)```", Pattern.CASE_INSENSITIVE);

    private static final String SYSTEM_PROMPT = """
        你是智慧社区维修专家。根据报修信息为上门维修工生成可操作的维修步骤。
        要求：
        1. 步骤 4~6 条，每条一句话，按执行顺序排列
        2. 包含安全注意事项与现场排查要点
        3. 语言简洁专业，适合维修工现场参考
        4. 仅输出 JSON，格式：{"steps":["步骤1","步骤2",...]}
        """;

    private final ZhipuAiClient aiClient;
    private final RepairStepTemplateService templateService;
    private final RpRepairTypeMapper typeMapper;
    private final ObjectMapper objectMapper;

    public Map<String, Object> generateStepsForOrder(RpOrder order) {
        String typeName = resolveTypeName(order);
        if (aiClient.isAvailable()) {
            try {
                List<String> steps = generateByAi(typeName, order.getDescription(), order.getUrgency());
                if (!steps.isEmpty()) {
                    Map<String, Object> result = new LinkedHashMap<>();
                    result.put("typeName", typeName);
                    result.put("steps", steps);
                    result.put("source", "ai");
                    return result;
                }
            } catch (Exception e) {
                log.warn("AI 维修步骤生成失败，使用模板兜底: {}", e.getMessage());
            }
        }
        Map<String, Object> fallback = templateService.matchSteps(order.getTypeId(), order.getDescription());
        fallback.put("source", "template");
        return fallback;
    }

    private List<String> generateByAi(String typeName, String description, String urgency) {
        String userContent = """
            报修类型：%s
            紧急程度：%s
            故障描述：%s
            """.formatted(
            StringUtils.hasText(typeName) ? typeName : "通用维修",
            urgencyLabel(urgency),
            StringUtils.hasText(description) ? description : "未提供详细描述");
        String raw = aiClient.chatForExtract(SYSTEM_PROMPT, userContent);
        return parseSteps(raw);
    }

    private List<String> parseSteps(String raw) {
        if (!StringUtils.hasText(raw)) {
            return List.of();
        }
        String json = raw.trim();
        Matcher matcher = JSON_BLOCK.matcher(json);
        if (matcher.find()) {
            json = matcher.group(1).trim();
        }
        int start = json.indexOf('{');
        int end = json.lastIndexOf('}');
        if (start >= 0 && end > start) {
            json = json.substring(start, end + 1);
        }
        try {
            JsonNode node = objectMapper.readTree(json);
            JsonNode stepsNode = node.path("steps");
            if (!stepsNode.isArray()) {
                return List.of();
            }
            List<String> steps = new ArrayList<>();
            for (JsonNode item : stepsNode) {
                String text = item.asText("").trim();
                if (StringUtils.hasText(text)) {
                    steps.add(text);
                }
            }
            return steps;
        } catch (Exception e) {
            log.warn("解析 AI 维修步骤失败: {}", e.getMessage());
            return List.of();
        }
    }

    private String resolveTypeName(RpOrder order) {
        if (order.getTypeId() != null) {
            RpRepairType type = typeMapper.selectById(order.getTypeId());
            if (type != null && StringUtils.hasText(type.getTypeName())) {
                return type.getTypeName();
            }
        }
        if (StringUtils.hasText(order.getAiTypeLabel())) {
            return order.getAiTypeLabel();
        }
        return StringUtils.hasText(order.getDescription()) ? order.getDescription() : "通用维修";
    }

    private String urgencyLabel(String urgency) {
        if (!StringUtils.hasText(urgency)) {
            return "普通";
        }
        return switch (urgency) {
            case "emergency" -> "紧急";
            case "urgent" -> "较急";
            default -> "普通";
        };
    }
}
