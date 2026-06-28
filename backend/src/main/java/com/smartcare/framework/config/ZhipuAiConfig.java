package com.smartcare.framework.config;

import com.smartcare.framework.ai.ZhipuAiProperties;
import okhttp3.OkHttpClient;
import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.util.concurrent.TimeUnit;

@Configuration
@EnableConfigurationProperties(ZhipuAiProperties.class)
public class ZhipuAiConfig {

    @Bean
    public OkHttpClient zhipuOkHttpClient() {
        return new OkHttpClient.Builder()
            .connectTimeout(60, TimeUnit.SECONDS)
            .readTimeout(120, TimeUnit.SECONDS)
            .writeTimeout(60, TimeUnit.SECONDS)
            .build();
    }
}
