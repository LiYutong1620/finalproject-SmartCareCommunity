package com.smartcare.business.repair.controller;

import com.smartcare.business.repair.service.RepairAiEngineService;
import com.smartcare.business.repair.service.RepairDispatchConfigService;
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
    private final RepairDispatchConfigService dispatchConfigService;

    @GetMapping("/auto-dispatch/config")
    public AjaxResult getAutoDispatchConfig() {
        return AjaxResult.success(Map.of("enabled", dispatchConfigService.isAutoDispatchEnabled()));
    }

    @PutMapping("/auto-dispatch/config")
    public AjaxResult setAutoDispatchConfig(@RequestBody Map<String, Object> body) {
        boolean enabled = Boolean.TRUE.equals(body.get("enabled"));
        dispatchConfigService.setAutoDispatchEnabled(enabled);
        return AjaxResult.success();
    }

    @PostMapping("/auto-dispatch/{orderId}")
    public AjaxResult autoDispatch(@PathVariable Long orderId) {
        Map<String, Object> result = aiEngineService.autoDispatch(orderId);
        return result == null ? AjaxResult.error("暂无可派单维修工或工单状态不可派单") : AjaxResult.success(result);
    }

    @PostMapping("/batch-dispatch")
    public AjaxResult batchAutoDispatch() {
        return AjaxResult.success(aiEngineService.batchAutoDispatch());
    }

    @PostMapping("/reanalyze/{orderId}")
    public AjaxResult reanalyze(@PathVariable Long orderId) {
        aiEngineService.reanalyzeOrder(orderId);
        return AjaxResult.success();
    }

    @GetMapping("/recommend/{orderId}")
    public AjaxResult recommend(@PathVariable Long orderId) {
        return AjaxResult.success(aiEngineService.recommendWorker(orderId));
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
}
