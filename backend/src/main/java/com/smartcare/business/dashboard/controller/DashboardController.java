package com.smartcare.business.dashboard.controller;

import com.smartcare.business.dashboard.service.DashboardService;
import com.smartcare.common.core.domain.AjaxResult;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/property/dashboard")
@RequiredArgsConstructor
public class DashboardController {

    private final DashboardService dashboardService;

    @GetMapping("/summary")
    public AjaxResult summary() {
        return AjaxResult.success(dashboardService.getSummaryStats());
    }

    @GetMapping("/elder-stats")
    public AjaxResult elderStats() {
        return AjaxResult.success(dashboardService.getElderStats());
    }

    /** 工单完成率（按日/周/月） */
    @GetMapping("/completion-rate")
    public AjaxResult completionRate(@RequestParam(defaultValue = "month") String period) {
        return AjaxResult.success(dashboardService.getCompletionRateTrend(period));
    }

    /** 报修分布（按故障类型 + 按楼栋） */
    @GetMapping("/repair-distribution")
    public AjaxResult repairDistribution() {
        return AjaxResult.success(dashboardService.getRepairDistribution());
    }

    /** 预警趋势（按预警类型分类：老人安全预警 / 设备预警） */
    @GetMapping("/alert-trend-by-type")
    public AjaxResult alertTrendByType() {
        return AjaxResult.success(dashboardService.getAlertTrendByType());
    }

    /** 工单状态分布 */
    @GetMapping("/order-status-distribution")
    public AjaxResult orderStatusDistribution() {
        return AjaxResult.success(dashboardService.getOrderStatusDistribution());
    }

    /** 维修工负载TOP5 */
    @GetMapping("/worker-load")
    public AjaxResult workerLoad() {
        return AjaxResult.success(dashboardService.getWorkerLoad());
    }

    /** 预警处理趋势 */
    @GetMapping("/alert-process-trend")
    public AjaxResult alertProcessTrend() {
        return AjaxResult.success(dashboardService.getAlertProcessTrend());
    }

    /** 住户结构 */
    @GetMapping("/resident-structure")
    public AjaxResult residentStructure() {
        return AjaxResult.success(dashboardService.getResidentStructure());
    }

    /** 房屋结构 */
    @GetMapping("/house-structure")
    public AjaxResult houseStructure() {
        return AjaxResult.success(dashboardService.getHouseStructure());
    }

    /** AI 安全预测 */
    @GetMapping("/ai-safety-prediction")
    public AjaxResult aiSafetyPrediction() {
        return AjaxResult.success(dashboardService.getAiSafetyPrediction());
    }
}
