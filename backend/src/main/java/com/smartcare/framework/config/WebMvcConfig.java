package com.smartcare.framework.config;

import com.smartcare.framework.storage.FileStorageService;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
@RequiredArgsConstructor
public class WebMvcConfig implements WebMvcConfigurer {

    private final FileStorageService fileStorageService;

    @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {
        String location = fileStorageService.getBasePath().toUri().toString();
        registry.addResourceHandler("/upload/**")
            .addResourceLocations(location.endsWith("/") ? location : location + "/");
    }
}
