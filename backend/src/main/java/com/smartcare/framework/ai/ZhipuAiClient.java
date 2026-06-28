package com.smartcare.framework.ai;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ArrayNode;
import com.fasterxml.jackson.databind.node.ObjectNode;
import com.smartcare.common.exception.ServiceException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import okhttp3.MediaType;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.RequestBody;
import okhttp3.Response;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

@Slf4j
@Component
@RequiredArgsConstructor
public class ZhipuAiClient {

    private static final MediaType JSON = MediaType.parse("application/json; charset=utf-8");

    private final ZhipuAiProperties properties;
    private final OkHttpClient zhipuOkHttpClient;
    private final ObjectMapper objectMapper;

    public boolean isAvailable() {
        return properties.isEnabled() && StringUtils.hasText(properties.getApiKey());
    }

    /** GLM-4-Plus：RAG 文本问答、多轮对话 */
    public String chatWithHistory(String systemPrompt, List<ZhipuChatMessage> history, String userMessage) {
        List<ZhipuChatMessage> messages = new ArrayList<>();
        messages.add(ZhipuChatMessage.system(systemPrompt));
        if (history != null) {
            messages.addAll(history);
        }
        messages.add(ZhipuChatMessage.user(userMessage));
        return chat(properties.getTextModel(), messages, properties.getMaxTokens(), properties.getTemperature());
    }

    /** 单轮结构化抽取（知识库自学习等，使用快速模型） */
    public String chatForExtract(String systemPrompt, String userMessage) {
        List<ZhipuChatMessage> messages = List.of(
            ZhipuChatMessage.system(systemPrompt),
            ZhipuChatMessage.user(userMessage)
        );
        return chat(properties.getExtractModel(), messages,
            properties.getExtractMaxTokens(), properties.getExtractTemperature());
    }

    /** 单轮对话（RAG 等，使用标准模型） */
    public String chatSimple(String systemPrompt, String userMessage) {
        return chatWithHistory(systemPrompt, List.of(), userMessage);
    }

    /** GLM-4V：图片 + 文字多模态识别与问答 */
    public String multimodalChat(String text, List<String> imageBase64List) {
        ArrayNode content = objectMapper.createArrayNode();
        ObjectNode textPart = objectMapper.createObjectNode();
        textPart.put("type", "text");
        textPart.put("text", text);
        content.add(textPart);

        if (imageBase64List != null) {
            for (String imageBase64 : imageBase64List) {
                if (!StringUtils.hasText(imageBase64)) {
                    continue;
                }
                ObjectNode imagePart = objectMapper.createObjectNode();
                imagePart.put("type", "image_url");
                ObjectNode imageUrl = objectMapper.createObjectNode();
                String url = normalizeImageUrl(imageBase64.trim());
                imageUrl.put("url", url);
                imagePart.set("image_url", imageUrl);
                content.add(imagePart);
            }
        }

        ZhipuChatMessage userMsg = new ZhipuChatMessage();
        userMsg.setRole("user");
        userMsg.setContent(content);
        return chat(properties.getVisionModel(), List.of(userMsg), 800, 0.2);
    }

    private String chat(String model, List<ZhipuChatMessage> messages, int maxTokens, double temperature) {
        if (!isAvailable()) {
            throw new ServiceException("智谱 AI 未配置，请设置 ai.zhipu.api-key");
        }

        ObjectNode body = objectMapper.createObjectNode();
        body.put("model", model);
        body.set("messages", objectMapper.valueToTree(messages));
        body.put("max_tokens", maxTokens);
        body.put("temperature", temperature);

        Request request = new Request.Builder()
            .url(properties.getApiUrl())
            .addHeader("Authorization", "Bearer " + properties.getApiKey())
            .addHeader("Content-Type", "application/json")
            .post(RequestBody.create(body.toString(), JSON))
            .build();

        try (Response response = zhipuOkHttpClient.newCall(request).execute()) {
            String responseBody = response.body() != null ? response.body().string() : "";
            if (!response.isSuccessful()) {
                log.error("智谱AI调用失败: code={}, body={}", response.code(), responseBody);
                throw new ServiceException("智谱AI调用失败: " + response.code());
            }
            JsonNode root = objectMapper.readTree(responseBody);
            JsonNode choices = root.path("choices");
            if (!choices.isArray() || choices.isEmpty()) {
                throw new ServiceException("智谱AI返回为空");
            }
            String content = choices.get(0).path("message").path("content").asText("");
            if (!StringUtils.hasText(content)) {
                throw new ServiceException("智谱AI未生成有效回答");
            }
            return content.trim();
        } catch (IOException e) {
            log.error("智谱AI调用异常", e);
            throw new ServiceException("智谱AI调用异常: " + e.getMessage());
        }
    }

    private String normalizeImageUrl(String imageBase64) {
        if (imageBase64.startsWith("data:")) {
            return imageBase64;
        }
        return "data:image/jpeg;base64," + imageBase64;
    }
}
