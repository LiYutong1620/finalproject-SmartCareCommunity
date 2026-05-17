package com.smartcare.business.repair.controller;

import com.smartcare.business.repair.service.RpOrderService;
import com.smartcare.common.core.domain.AjaxResult;
import com.smartcare.common.core.page.TableDataInfo;
import com.smartcare.framework.security.SecurityUtils;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/property/repair")
@RequiredArgsConstructor
public class PropertyRepairController {

    private final RpOrderService orderService;

    @GetMapping("/list")
    public AjaxResult list(@RequestParam(defaultValue = "1") int pageNum,
                           @RequestParam(defaultValue = "10") int pageSize,
                           @RequestParam(required = false) String status,
                           @RequestParam(required = false) String urgency) {
        var page = orderService.pageAll(pageNum, pageSize, status, urgency);
        return AjaxResult.success(new TableDataInfo(page.getTotal(), page.getRecords()));
    }

    @GetMapping("/{orderId}")
    public AjaxResult detail(@PathVariable Long orderId) {
        return AjaxResult.success(orderService.getById(orderId));
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
}
