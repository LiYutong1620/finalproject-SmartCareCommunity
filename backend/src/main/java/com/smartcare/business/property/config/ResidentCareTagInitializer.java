package com.smartcare.business.property.config;

import com.smartcare.business.property.service.ResidentCareTagService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.context.event.ApplicationReadyEvent;
import org.springframework.context.event.EventListener;
import org.springframework.stereotype.Component;

/** 启动时校验老人关怀模块就绪（标签改为动态计算，无需同步） */
@Slf4j
@Component
@RequiredArgsConstructor
public class ResidentCareTagInitializer {

    private final ResidentCareTagService careTagService;

    @EventListener(ApplicationReadyEvent.class)
    public void onReady() {
        long count = careTagService.listElderArchive().size();
        log.info("老人关怀模块就绪，当前关怀对象 {} 人（动态判定）", count);
    }
}
