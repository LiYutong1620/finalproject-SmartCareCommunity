package com.smartcare.business.elder.task;

import com.smartcare.business.elder.service.ElAiMonitorService;
import com.smartcare.business.property.domain.CmResident;
import com.smartcare.business.property.service.ResidentCareTagService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.util.List;

/**
 * 独居老人定时监测任务
 * 每小时自动对全部独居老人执行一次AI安全检查
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class ElderMonitorTask {

    private final ElAiMonitorService aiMonitorService;
    private final ResidentCareTagService careTagService;

    /**
     * 每小时执行一次，对全部 AI 监测对象进行安全检查
     */
    @Scheduled(fixedRate = 3600000)
    public void monitorAloneElders() {
        List<CmResident> aloneElders = careTagService.listAiMonitorTargets();

        if (aloneElders.isEmpty()) {
            log.debug("暂无 AI 监测对象需要检查");
            return;
        }

        log.info("开始定时监测关怀对象，共{}人", aloneElders.size());
        int alertCount = 0;
        for (CmResident elder : aloneElders) {
            try {
                var result = aiMonitorService.performFullCheck(elder.getResidentId());
                String riskLevel = (String) result.get("riskLevel");
                if ("yellow".equals(riskLevel) || "red".equals(riskLevel)) {
                    alertCount++;
                    log.warn("关怀对象[{}]风险等级：{}，预警ID：{}，工单ID：{}",
                        elder.getName(), riskLevel, result.get("alertId"), result.get("careOrderId"));
                }
            } catch (Exception e) {
                log.error("监测关怀对象[{}]失败：{}", elder.getName(), e.getMessage(), e);
            }
        }
        log.info("定时监测完成，共检查{}人，产生预警{}条", aloneElders.size(), alertCount);
    }
}
