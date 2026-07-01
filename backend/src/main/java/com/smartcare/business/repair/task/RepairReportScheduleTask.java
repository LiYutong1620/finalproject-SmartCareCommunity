package com.smartcare.business.repair.task;

import com.smartcare.business.repair.service.RepairReportService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

@Slf4j
@Component
@RequiredArgsConstructor
public class RepairReportScheduleTask {

    private final RepairReportService reportService;

    @Scheduled(cron = "0 0 8 ? * MON")
    public void generateWeeklyReport() {
        try {
            reportService.generateWeeklyReport(null);
            log.info("工单AI复盘周报已自动生成");
        } catch (Exception e) {
            log.warn("工单AI复盘周报生成失败: {}", e.getMessage());
        }
    }
}
