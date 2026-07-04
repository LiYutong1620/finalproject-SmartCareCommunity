package com.smartcare.business.repair.controller;

import com.smartcare.business.repair.domain.RpRepairType;
import com.smartcare.business.repair.service.RpRepairTypeService;
import com.smartcare.common.core.domain.AjaxResult;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/property/repair/type")
@RequiredArgsConstructor
public class RpRepairTypeController {

    private final RpRepairTypeService typeService;

    @GetMapping("/list")
    public AjaxResult list() {
        return AjaxResult.success(typeService.listAll());
    }

    @PostMapping
    public AjaxResult add(@RequestBody RpRepairType type) {
        typeService.save(type);
        return AjaxResult.success();
    }

    @PutMapping
    public AjaxResult edit(@RequestBody RpRepairType type) {
        typeService.update(type);
        return AjaxResult.success();
    }

    @DeleteMapping("/{typeId}")
    public AjaxResult remove(@PathVariable Long typeId) {
        typeService.delete(typeId);
        return AjaxResult.success();
    }
}
