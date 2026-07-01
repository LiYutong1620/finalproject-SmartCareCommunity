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

    @GetMapping("/alert-trend")
    public AjaxResult alertTrend() {
        return AjaxResult.success(dashboardService.getAlertTrend());
    }

    @GetMapping("/order-trend")
    public AjaxResult orderTrend() {
        return AjaxResult.success(dashboardService.getOrderTrend());
    }

    @GetMapping("/staff-performance")
    public AjaxResult staffPerformance() {
        return AjaxResult.success(dashboardService.getStaffPerformance());
    }

    @GetMapping("/risk-residents")
    public AjaxResult riskResidents() {
        return AjaxResult.success(dashboardService.getRiskResidents());
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
}
