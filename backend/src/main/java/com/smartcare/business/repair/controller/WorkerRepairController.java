package com.smartcare.business.repair.controller;

import com.smartcare.business.repair.service.RpOrderService;
import com.smartcare.common.core.domain.AjaxResult;
import com.smartcare.common.core.page.TableDataInfo;
import com.smartcare.framework.security.SecurityUtils;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/worker/repair")
@RequiredArgsConstructor
public class WorkerRepairController {

    private final RpOrderService orderService;

    @GetMapping("/list")
    public AjaxResult list(@RequestParam(defaultValue = "1") int pageNum,
                           @RequestParam(defaultValue = "10") int pageSize,
                           @RequestParam(required = false) String status) {
        var page = orderService.pageByWorker(SecurityUtils.getUserId(), pageNum, pageSize, status);
        return AjaxResult.success(new TableDataInfo(page.getTotal(), page.getRecords()));
    }

    @PutMapping("/accept/{orderId}")
    public AjaxResult accept(@PathVariable Long orderId) {
        orderService.accept(orderId, SecurityUtils.getUserId());
        return AjaxResult.success();
    }

    @PutMapping("/status")
    public AjaxResult updateStatus(@RequestBody Map<String, String> body) {
        orderService.updateStatus(Long.parseLong(body.get("orderId")),
            body.get("status"), SecurityUtils.getUserId().toString(), body.get("remark"));
        return AjaxResult.success();
    }

    @PutMapping("/complete/{orderId}")
    public AjaxResult complete(@PathVariable Long orderId) {
        orderService.complete(orderId);
        return AjaxResult.success();
    }
}
