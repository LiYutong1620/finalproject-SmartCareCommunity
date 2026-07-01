package com.smartcare.business.elder.controller;

import com.smartcare.business.elder.service.ElAiMonitorService;
import com.smartcare.common.core.domain.AjaxResult;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

/**
 * 独居老人AI安全监测控制器
 */
@RestController
@RequestMapping("/property/elder/ai-monitor")
@RequiredArgsConstructor
public class ElAiMonitorController {

    private final ElAiMonitorService aiMonitorService;

    /** 监测状态概览 */
    @GetMapping("/status")
    public AjaxResult status() {
        return AjaxResult.success(aiMonitorService.getMonitorStatus());
    }

    /** AI分析日志列表（分页） */
    @GetMapping("/logs")
    public AjaxResult logs(@RequestParam(defaultValue = "1") int pageNum,
                           @RequestParam(defaultValue = "10") int pageSize) {
        return AjaxResult.success(aiMonitorService.listMonitorLogs(pageNum, pageSize));
    }

    /** 手动触发检查 */
    @PostMapping("/manual-check/{residentId}")
    public AjaxResult manualCheck(@PathVariable Long residentId) {
        return AjaxResult.success(aiMonitorService.performFullCheck(residentId));
    }

    /** 获取独居老人列表 */
    @GetMapping("/alone-elders")
    public AjaxResult aloneElders() {
        return AjaxResult.success(aiMonitorService.listAloneElders());
    }
}
