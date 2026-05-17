package com.smartcare.system.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.smartcare.common.core.domain.AjaxResult;
import com.smartcare.system.domain.SysConfig;
import com.smartcare.system.mapper.SysConfigMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/system/config")
@RequiredArgsConstructor
public class SysConfigController {

    private final SysConfigMapper configMapper;

    @GetMapping("/list")
    public AjaxResult list(@RequestParam(required = false) String configName) {
        return AjaxResult.success(configMapper.selectList(
            new LambdaQueryWrapper<SysConfig>()
                .like(configName != null, SysConfig::getConfigName, configName)));
    }

    @PostMapping
    public AjaxResult add(@RequestBody SysConfig config) {
        configMapper.insert(config);
        return AjaxResult.success();
    }

    @PutMapping
    public AjaxResult edit(@RequestBody SysConfig config) {
        configMapper.updateById(config);
        return AjaxResult.success();
    }

    @DeleteMapping("/{configId}")
    public AjaxResult remove(@PathVariable Integer configId) {
        configMapper.deleteById(configId);
        return AjaxResult.success();
    }
}
