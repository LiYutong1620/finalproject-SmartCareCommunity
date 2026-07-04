package com.smartcare.business.repair.controller;

import com.smartcare.business.repair.service.RepairSupervisionService;
import com.smartcare.business.repair.service.RpOrderService;
import com.smartcare.common.core.domain.AjaxResult;
import com.smartcare.common.core.page.TableDataInfo;
import com.smartcare.framework.security.SecurityUtils;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.Map;

@RestController
@RequestMapping("/property/repair")
@RequiredArgsConstructor
public class PropertyRepairController {

    private final RpOrderService orderService;
    private final RepairSupervisionService supervisionService;

    @GetMapping("/supervision/stats")
    public AjaxResult stats() {
        return AjaxResult.success(supervisionService.stats());
    }

    @GetMapping("/list")
    public AjaxResult list(@RequestParam(defaultValue = "1") int pageNum,
                           @RequestParam(defaultValue = "10") int pageSize,
                           @RequestParam(required = false) String status,
                           @RequestParam(required = false) String urgency,
                           @RequestParam(required = false) Long typeId,
                           @RequestParam(required = false) Integer highRisk,
                           @RequestParam(required = false) Integer duplicateFlag,
                           @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime startTime,
                           @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime endTime) {
        var page = supervisionService.pageEnriched(pageNum, pageSize, status, urgency, typeId,
            highRisk, duplicateFlag, startTime, endTime);
        return AjaxResult.success(new TableDataInfo(page.getTotal(), page.getRecords()));
    }

    @GetMapping("/{orderId}")
    public AjaxResult detail(@PathVariable Long orderId) {
        return AjaxResult.success(orderService.buildDetail(orderId, SecurityUtils.getUserId(), "property"));
    }

    @PutMapping("/assign")
    public AjaxResult assign(@RequestBody Map<String, Object> body) {
        orderService.assign(
            Long.parseLong(body.get("orderId").toString()),
            Long.parseLong(body.get("workerId").toString()),
            (String) body.get("reason"),
            SecurityUtils.getUserId().toString());
        return AjaxResult.success();
    }

    @PutMapping("/status")
    public AjaxResult forceStatus(@RequestBody Map<String, String> body) {
        orderService.updateStatus(Long.parseLong(body.get("orderId")),
            body.get("status"), SecurityUtils.getUserId().toString(), body.get("reason"));
        return AjaxResult.success();
    }

    @PutMapping("/adjust")
    public AjaxResult adjust(@RequestBody Map<String, Object> body) {
        orderService.updateUrgencyAndType(
            Long.parseLong(body.get("orderId").toString()),
            (String) body.get("urgency"),
            body.get("typeId") == null ? null : Long.parseLong(body.get("typeId").toString()),
            (String) body.get("reason"),
            SecurityUtils.getUserId().toString());
        return AjaxResult.success();
    }
}
