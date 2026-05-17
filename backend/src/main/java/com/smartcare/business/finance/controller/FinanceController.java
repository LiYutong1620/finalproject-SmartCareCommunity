package com.smartcare.business.finance.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.smartcare.business.finance.domain.FnBill;
import com.smartcare.business.finance.mapper.FnBillMapper;
import com.smartcare.common.core.domain.AjaxResult;
import com.smartcare.common.core.page.TableDataInfo;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;

@RestController
@RequiredArgsConstructor
public class FinanceController {

    private final FnBillMapper billMapper;

    @GetMapping("/owner/bill/list")
    public AjaxResult ownerBills(@RequestParam Long houseId,
                                 @RequestParam(defaultValue = "1") int pageNum,
                                 @RequestParam(defaultValue = "10") int pageSize) {
        Page<FnBill> page = billMapper.selectPage(new Page<>(pageNum, pageSize),
            new LambdaQueryWrapper<FnBill>()
                .eq(FnBill::getHouseId, houseId)
                .orderByDesc(FnBill::getCreateTime));
        return AjaxResult.success(new TableDataInfo(page.getTotal(), page.getRecords()));
    }

    @GetMapping("/property/bill/list")
    public AjaxResult propertyBills(@RequestParam(defaultValue = "1") int pageNum,
                                    @RequestParam(defaultValue = "10") int pageSize,
                                    @RequestParam(required = false) String status) {
        Page<FnBill> page = billMapper.selectPage(new Page<>(pageNum, pageSize),
            new LambdaQueryWrapper<FnBill>()
                .eq(status != null, FnBill::getStatus, status));
        return AjaxResult.success(new TableDataInfo(page.getTotal(), page.getRecords()));
    }

    @PostMapping("/property/bill")
    public AjaxResult createBill(@RequestBody FnBill bill) {
        bill.setPaidAmount(BigDecimal.ZERO);
        bill.setLateFee(BigDecimal.ZERO);
        bill.setStatus("0");
        billMapper.insert(bill);
        return AjaxResult.success();
    }
}
