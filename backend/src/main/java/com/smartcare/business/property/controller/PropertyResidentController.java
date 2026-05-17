package com.smartcare.business.property.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.smartcare.business.property.domain.CmBuilding;
import com.smartcare.business.property.domain.CmResident;
import com.smartcare.business.property.mapper.CmBuildingMapper;
import com.smartcare.business.property.mapper.CmResidentMapper;
import com.smartcare.common.core.domain.AjaxResult;
import com.smartcare.common.core.page.TableDataInfo;
import lombok.RequiredArgsConstructor;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/property")
@RequiredArgsConstructor
public class PropertyResidentController {

    private final CmBuildingMapper buildingMapper;
    private final CmResidentMapper residentMapper;

    @GetMapping("/building/list")
    public AjaxResult buildingList() {
        return AjaxResult.success(buildingMapper.selectList(null));
    }

    @PostMapping("/building")
    public AjaxResult addBuilding(@RequestBody CmBuilding building) {
        buildingMapper.insert(building);
        return AjaxResult.success();
    }

    @GetMapping("/resident/list")
    public AjaxResult residentList(@RequestParam(defaultValue = "1") int pageNum,
                                   @RequestParam(defaultValue = "10") int pageSize,
                                   @RequestParam(required = false) String name) {
        Page<CmResident> page = residentMapper.selectPage(new Page<>(pageNum, pageSize),
            new LambdaQueryWrapper<CmResident>()
                .eq(CmResident::getDelFlag, "0")
                .like(StringUtils.hasText(name), CmResident::getName, name));
        return AjaxResult.success(new TableDataInfo(page.getTotal(), page.getRecords()));
    }

    @PostMapping("/resident")
    public AjaxResult addResident(@RequestBody CmResident resident) {
        resident.setDelFlag("0");
        residentMapper.insert(resident);
        return AjaxResult.success();
    }

    @PutMapping("/resident")
    public AjaxResult editResident(@RequestBody CmResident resident) {
        residentMapper.updateById(resident);
        return AjaxResult.success();
    }

    @DeleteMapping("/resident/{residentId}")
    public AjaxResult deleteResident(@PathVariable Long residentId) {
        CmResident r = new CmResident();
        r.setResidentId(residentId);
        r.setDelFlag("2");
        residentMapper.updateById(r);
        return AjaxResult.success();
    }
}
