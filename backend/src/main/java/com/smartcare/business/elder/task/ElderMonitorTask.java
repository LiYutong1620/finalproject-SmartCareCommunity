package com.smartcare.business.elder.task;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.smartcare.business.elder.service.ElAiMonitorService;
import com.smartcare.business.elder.service.ElUtilityMonitorService;
import com.smartcare.business.property.domain.CmResident;
import com.smartcare.business.property.mapper.CmResidentMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.util.List;
import java.util.Map;

/**
 * 独居老人定时监测任务
 * 每小时自动对全部独居老人执行一次AI安全检查
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class ElderMonitorTask {

    private final ElAiMonitorService aiMonitorService;
    private final ElUtilityMonitorService utilityMonitorService;
    private final CmResidentMapper residentMapper;

    /**
     * 每小时执行一次，对全部独居老人进行安全检查
     */
    @Scheduled(fixedRate = 3600000)
    public void monitorAloneElders() {
        List<CmResident> aloneElders = residentMapper.selectList(
            new LambdaQueryWrapper<CmResident>()
                .eq(CmResident::getIsAloneLiving, 1)
                .eq(CmResident::getDelFlag, "0")
        );

        if (aloneElders.isEmpty()) {
            log.debug("暂无独居老人需要监测");
            return;
        }

        log.info("开始定时监测独居老人，共{}人", aloneElders.size());
        int alertCount = 0;
        int utilityAlertCount = 0;
        for (CmResident elder : aloneElders) {
            try {
                var result = aiMonitorService.performFullCheck(elder.getResidentId());
                String riskLevel = (String) result.get("riskLevel");
                if ("yellow".equals(riskLevel) || "red".equals(riskLevel)) {
                    alertCount++;
                    log.warn("独居老人[{}]风险等级：{}，原因：{}",
                        elder.getName(), riskLevel, result.get("reason"));
                }
            } catch (Exception e) {
                log.error("监测独居老人[{}]失败：{}", elder.getName(), e.getMessage(), e);
            }

            // 水电异常独立检测（包含自动生成预警+工单）
            try {
                Map<String, Object> utilityResult = utilityMonitorService.performUtilityCheck(elder.getResidentId());
                if ("alert_created".equals(utilityResult.get("status"))) {
                    utilityAlertCount++;
                    log.warn("独居老人[{}]水电异常预警已创建，异常数：{}",
                        elder.getName(), utilityResult.get("anomalyCount"));
                }
            } catch (Exception e) {
                log.error("水电监测独居老人[{}]失败：{}", elder.getName(), e.getMessage(), e);
            }
        }
        log.info("定时监测完成，共检查{}人，规则+AI预警{}人，水电异常预警{}人", aloneElders.size(), alertCount, utilityAlertCount);
    }
}
