package com.smartcare.business.repair.controller;

import com.smartcare.business.repair.domain.RpOrder;
import com.smartcare.business.repair.domain.RpRepairType;
import com.smartcare.business.repair.service.RpOrderService;
import com.smartcare.business.repair.service.RpRepairTypeService;
import com.smartcare.common.core.domain.AjaxResult;
import com.smartcare.common.core.page.TableDataInfo;
import com.smartcare.framework.security.SecurityUtils;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/property/repair")
@RequiredArgsConstructor
public class PropertyRepairController {

    private final RpOrderService orderService;
    private final RpRepairTypeService repairTypeService;

    @GetMapping("/list")
    public AjaxResult list(@RequestParam(defaultValue = "1") int pageNum,
                           @RequestParam(defaultValue = "10") int pageSize,
                           @RequestParam(required = false) String status,
                           @RequestParam(required = false) String urgency,
                           @RequestParam(required = false) String keyword,
                           @RequestParam(required = false) Long typeId,
                           @RequestParam(required = false) String startDate,
                           @RequestParam(required = false) String endDate) {
        var page = orderService.pageAll(pageNum, pageSize, status, urgency, keyword, typeId, startDate, endDate);
        return AjaxResult.success(new TableDataInfo(page.getTotal(), page.getRecords()));
    }

    @GetMapping("/{orderId}")
    public AjaxResult detail(@PathVariable Long orderId) {
        return AjaxResult.success(orderService.detail(orderId));
    }

    @GetMapping("/types")
    public AjaxResult types() {
        return AjaxResult.success(repairTypeService.listTree());
    }

    @PostMapping("/types")
    public AjaxResult addType(@RequestBody RpRepairType type) {
        repairTypeService.save(type);
        return AjaxResult.success();
    }

    @PutMapping("/types")
    public AjaxResult editType(@RequestBody RpRepairType type) {
        repairTypeService.update(type);
        return AjaxResult.success();
    }

    @DeleteMapping("/types/{typeId}")
    public AjaxResult deleteType(@PathVariable Long typeId) {
        repairTypeService.delete(typeId);
        return AjaxResult.success();
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
        orderService.adjust(
            Long.parseLong(body.get("orderId").toString()),
            (String) body.get("urgency"),
            body.get("typeId") == null ? null : Long.parseLong(body.get("typeId").toString()),
            SecurityUtils.getUserId().toString(),
            (String) body.get("reason"));
        return AjaxResult.success();
    }
}
