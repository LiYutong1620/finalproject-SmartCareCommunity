package com.smartcare.business.elder.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.smartcare.business.elder.domain.ElAlert;
import com.smartcare.business.elder.mapper.ElAlertMapper;
import com.smartcare.common.core.domain.AjaxResult;
import com.smartcare.common.core.page.TableDataInfo;
import com.smartcare.framework.security.SecurityUtils;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;

@RestController
@RequestMapping("/property/elder")
@RequiredArgsConstructor
public class ElderCareController {

    private final ElAlertMapper alertMapper;

    @GetMapping("/alert/list")
    public AjaxResult alertList(@RequestParam(defaultValue = "1") int pageNum,
                                @RequestParam(defaultValue = "10") int pageSize,
                                @RequestParam(required = false) String alertType) {
        Page<ElAlert> page = alertMapper.selectPage(new Page<>(pageNum, pageSize),
            new LambdaQueryWrapper<ElAlert>()
                .eq(alertType != null, ElAlert::getAlertType, alertType)
                .orderByDesc(ElAlert::getCreateTime));
        return AjaxResult.success(new TableDataInfo(page.getTotal(), page.getRecords()));
    }

    @PostMapping("/alert")
    public AjaxResult createAlert(@RequestBody ElAlert alert) {
        alert.setStatus("pending");
        alert.setCreateTime(LocalDateTime.now());
        alertMapper.insert(alert);
        return AjaxResult.success();
    }

    @PutMapping("/alert/handle")
    public AjaxResult handle(@RequestBody ElAlert alert) {
        alert.setHandlerId(SecurityUtils.getUserId());
        alert.setHandleTime(LocalDateTime.now());
        alert.setStatus("handled");
        alertMapper.updateById(alert);
        return AjaxResult.success();
    }
}
