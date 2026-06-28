package com.smartcare.business.community.task;

import com.smartcare.business.community.service.NoticePublishScheduler;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

@Slf4j
@Component
@RequiredArgsConstructor
public class NoticeScheduleTask {

    private final NoticePublishScheduler publishScheduler;

    @Scheduled(fixedRate = 5000)
    public void runScheduledNoticeTasks() {
        int published = publishScheduler.activateDueNotices();
        int offlined = publishScheduler.offlineDueNotices();
        if (published > 0) {
            log.info("定时发布公告 {} 条", published);
        }
        if (offlined > 0) {
            log.info("定时下架公告 {} 条", offlined);
        }
    }
}
