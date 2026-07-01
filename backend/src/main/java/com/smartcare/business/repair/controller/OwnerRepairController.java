package com.smartcare.business.repair.controller;

import com.smartcare.business.repair.domain.RpOrder;
import com.smartcare.business.repair.domain.RpOrderProgress;
import com.smartcare.business.repair.mapper.RpOrderProgressMapper;
import com.smartcare.business.repair.service.RpOrderService;
import com.smartcare.common.core.domain.AjaxResult;
import com.smartcare.common.core.page.TableDataInfo;
import com.smartcare.framework.security.SecurityUtils;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/owner/repair")
@RequiredArgsConstructor
public class OwnerRepairController {

    private final RpOrderService orderService;
    private final RpOrderProgressMapper progressMapper;

    @PostMapping
    public AjaxResult submit(@RequestBody RpOrder order) {
        order.setOwnerId(SecurityUtils.getUserId());
        return AjaxResult.success(orderService.submit(order));
    }

    @GetMapping("/list")
    public AjaxResult list(@RequestParam(defaultValue = "1") int pageNum,
                           @RequestParam(defaultValue = "10") int pageSize,
                           @RequestParam(required = false) String status) {
        var page = orderService.pageByOwner(SecurityUtils.getUserId(), pageNum, pageSize, status);
        return AjaxResult.success(new TableDataInfo(page.getTotal(), page.getRecords()));
    }

    @GetMapping("/{orderId}")
    public AjaxResult detail(@PathVariable Long orderId) {
        RpOrder order = orderService.getById(orderId);
        var progress = progressMapper.selectList(
            new LambdaQueryWrapper<RpOrderProgress>()
                .eq(RpOrderProgress::getOrderId, orderId)
                .orderByAsc(RpOrderProgress::getCreateTime));
        return AjaxResult.success(Map.of("order", order, "progress", progress));
    }

    @PutMapping("/cancel/{orderId}")
    public AjaxResult cancel(@PathVariable Long orderId) {
        orderService.cancel(orderId, SecurityUtils.getUserId());
        return AjaxResult.success();
    }

    @PutMapping("/urge/{orderId}")
    public AjaxResult urge(@PathVariable Long orderId) {
        orderService.urge(orderId, SecurityUtils.getUserId());
        return AjaxResult.success();
    }

    @PostMapping("/copy/{orderId}")
    public AjaxResult copy(@PathVariable Long orderId) {
        return AjaxResult.success(orderService.copyOrder(orderId, SecurityUtils.getUserId()));
    }

    @PutMapping("/accept/{orderId}")
    public AjaxResult accept(@PathVariable Long orderId, @RequestBody Map<String, Object> body) {
        orderService.ownerAccept(orderId,
            (String) body.get("signImage"),
            (Integer) body.get("score"),
            (String) body.get("tags"));
        return AjaxResult.success();
    }
}
