package com.smartcare.business.dashboard.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.smartcare.business.elder.domain.ElAlert;
import com.smartcare.business.elder.mapper.ElAlertMapper;
import com.smartcare.business.finance.domain.FnBill;
import com.smartcare.business.finance.mapper.FnBillMapper;
import com.smartcare.business.repair.domain.RpOrder;
import com.smartcare.business.repair.mapper.RpOrderMapper;
import com.smartcare.common.core.domain.AjaxResult;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/property/dashboard")
@RequiredArgsConstructor
public class DashboardController {

    private final RpOrderMapper orderMapper;
    private final ElAlertMapper alertMapper;
    private final FnBillMapper billMapper;

    @GetMapping("/stats")
    public AjaxResult stats() {
        long totalOrders = orderMapper.selectCount(null);
        long completedOrders = orderMapper.selectCount(
            new LambdaQueryWrapper<RpOrder>().eq(RpOrder::getStatus, "completed"));
        long pendingAlerts = alertMapper.selectCount(
            new LambdaQueryWrapper<ElAlert>().eq(ElAlert::getStatus, "pending"));
        long unpaidBills = billMapper.selectCount(
            new LambdaQueryWrapper<FnBill>().eq(FnBill::getStatus, "0"));

        Map<String, Object> data = new HashMap<>();
        data.put("totalOrders", totalOrders);
        data.put("completedOrders", completedOrders);
        data.put("completionRate", totalOrders == 0 ? 0 :
            Math.round(completedOrders * 10000.0 / totalOrders) / 100.0);
        data.put("pendingAlerts", pendingAlerts);
        data.put("unpaidBills", unpaidBills);
        return AjaxResult.success(data);
    }
}
