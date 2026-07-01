package com.smartcare.business.repair.controller;

import com.smartcare.business.repair.service.RepairAiEngineService;
import com.smartcare.business.repair.service.RepairAnalyticsService;
import com.smartcare.business.repair.service.RepairReportService;
import com.smartcare.common.core.domain.AjaxResult;
import com.smartcare.common.core.page.TableDataInfo;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.Map;

@RestController
@RequestMapping("/property/repair/ai")
@RequiredArgsConstructor
public class PropertyRepairAiController {

    private final RepairAiEngineService aiEngineService;
    private final RepairReportService reportService;
    private final RepairAnalyticsService analyticsService;

    @PostMapping("/auto-dispatch/{orderId}")
    public AjaxResult autoDispatch(@PathVariable Long orderId) {
        Long workerId = aiEngineService.autoDispatch(orderId);
        return workerId == null ? AjaxResult.error("暂无可派单维修工") : AjaxResult.success(Map.of("workerId", workerId));
    }

    @GetMapping("/analyze")
    public AjaxResult analyze(@RequestParam String description,
                              @RequestParam(required = false) Long typeId) {
        return AjaxResult.success(aiEngineService.analyzePreview(description, typeId));
    }

    @GetMapping("/reports")
    public AjaxResult reports(@RequestParam(defaultValue = "1") int pageNum,
                              @RequestParam(defaultValue = "10") int pageSize) {
        var page = reportService.pageReports(pageNum, pageSize);
        return AjaxResult.success(new TableDataInfo(page.getTotal(), page.getRecords()));
    }

    @PostMapping("/reports/generate")
    public AjaxResult generateReport(@RequestParam(required = false) String weekStart) {
        LocalDate start = weekStart == null ? null : LocalDate.parse(weekStart);
        return AjaxResult.success(reportService.generateWeeklyReport(start));
    }

    @GetMapping("/trend")
    public AjaxResult trend(@RequestParam(defaultValue = "6") int months) {
        return AjaxResult.success(analyticsService.monthlyTrend(months));
    }
}
