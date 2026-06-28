package com.smartcare.framework.ai;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;

@Data
@ConfigurationProperties(prefix = "ai.zhipu")
public class ZhipuAiProperties {

    private String apiKey = "";
    private String apiUrl = "https://open.bigmodel.cn/api/paas/v4/chat/completions";
    private String textModel = "glm-4-plus";
    private String visionModel = "glm-4v";
    /** 知识库抽取专用模型（更快） */
    private String extractModel = "glm-4-flash";
    private boolean enabled = true;
    private int maxTokens = 1000;
    private int extractMaxTokens = 512;
    private double temperature = 0.3;
    private double extractTemperature = 0.1;
}
