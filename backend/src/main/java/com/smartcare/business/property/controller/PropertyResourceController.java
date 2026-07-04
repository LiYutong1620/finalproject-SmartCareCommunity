package com.smartcare.business.property.controller;

import com.smartcare.business.property.domain.*;
import com.smartcare.business.property.service.PropertyResourceService;
import com.smartcare.common.core.domain.AjaxResult;
import com.smartcare.common.core.page.TableDataInfo;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/property")
@RequiredArgsConstructor
public class PropertyResourceController {

    private final PropertyResourceService resourceService;

    @GetMapping("/building/list")
    public AjaxResult buildingList(@RequestParam(defaultValue = "1") int pageNum,
                                   @RequestParam(defaultValue = "10") int pageSize,
                                   @RequestParam(required = false) String buildingNo,
                                   @RequestParam(required = false) Integer totalFloors) {
        TableDataInfo data = resourceService.searchBuildings(pageNum, pageSize, buildingNo, totalFloors);
        return AjaxResult.success(data);
    }

    @PostMapping("/building")
    public AjaxResult addBuilding(@RequestBody CmBuilding building) {
        resourceService.addBuilding(building);
        return AjaxResult.success();
    }

    @PutMapping("/building")
    public AjaxResult updateBuilding(@RequestBody CmBuilding building) {
        resourceService.updateBuilding(building);
        return AjaxResult.success();
    }

    @DeleteMapping("/building/{buildingId}")
    public AjaxResult deleteBuilding(@PathVariable Long buildingId) {
        resourceService.deleteBuilding(buildingId);
        return AjaxResult.success();
    }

    @GetMapping("/building/all")
    public AjaxResult buildingAll() {
        return AjaxResult.success(resourceService.listBuildings());
    }

    @GetMapping("/house/list")
    public AjaxResult houseList(@RequestParam(defaultValue = "1") int pageNum,
                                @RequestParam(defaultValue = "10") int pageSize,
                                @RequestParam(required = false) Long buildingId,
                                @RequestParam(required = false) String houseNo,
                                @RequestParam(required = false) String layout) {
        TableDataInfo data = resourceService.searchHouses(pageNum, pageSize, buildingId, houseNo, layout);
        return AjaxResult.success(data);
    }

    @PostMapping("/house")
    public AjaxResult addHouse(@RequestBody CmHouse house) {
        resourceService.addHouse(house);
        return AjaxResult.success();
    }

    @PutMapping("/house")
    public AjaxResult updateHouse(@RequestBody CmHouse house) {
        resourceService.updateHouse(house);
        return AjaxResult.success();
    }

    @DeleteMapping("/house/{houseId}")
    public AjaxResult deleteHouse(@PathVariable Long houseId) {
        resourceService.deleteHouse(houseId);
        return AjaxResult.success();
    }

    @GetMapping("/tag/list")
    public AjaxResult tagList() {
        return AjaxResult.success(resourceService.listTags());
    }

    @PostMapping("/tag")
    public AjaxResult addTag(@RequestBody CmResidentTag tag) {
        resourceService.addTag(tag);
        return AjaxResult.success();
    }

    @DeleteMapping("/tag/{tagId}")
    public AjaxResult deleteTag(@PathVariable Long tagId) {
        resourceService.deleteTag(tagId);
        return AjaxResult.success();
    }

    @GetMapping("/resident/list")
    public AjaxResult residentList(@RequestParam(defaultValue = "1") int pageNum,
                                   @RequestParam(defaultValue = "10") int pageSize,
                                   @RequestParam(required = false) Long buildingId,
                                   @RequestParam(required = false) Long tagId,
                                   @RequestParam(required = false) String name,
                                   @RequestParam(required = false) String gender,
                                   @RequestParam(required = false) Integer ageMin,
                                   @RequestParam(required = false) Integer ageMax) {
        TableDataInfo data = resourceService.searchResidents(pageNum, pageSize, buildingId, tagId, name, gender, ageMin, ageMax);
        return AjaxResult.success(data);
    }

    @PostMapping("/resident")
    public AjaxResult addResident(@RequestBody CmResident resident) {
        resourceService.addResident(resident);
        return AjaxResult.success();
    }

    @PutMapping("/resident")
    public AjaxResult editResident(@RequestBody CmResident resident) {
        resourceService.updateResident(resident);
        return AjaxResult.success();
    }

    @GetMapping("/resident/{residentId}")
    public AjaxResult residentDetail(@PathVariable Long residentId) {
        return AjaxResult.success(resourceService.getResidentDetail(residentId));
    }

    @GetMapping("/resident/owner-options")
    public AjaxResult ownerBindOptions(@RequestParam(required = false) Long excludeResidentId) {
        return AjaxResult.success(resourceService.listOwnerBindOptions(excludeResidentId));
    }

    @DeleteMapping("/resident/{residentId}")
    public AjaxResult deleteResident(@PathVariable Long residentId) {
        resourceService.deleteResident(residentId);
        return AjaxResult.success();
    }

    @GetMapping("/resident/occupied-houses")
    public AjaxResult occupiedHouseIds(@RequestParam(required = false) Long excludeResidentId) {
        return AjaxResult.success(resourceService.listOccupiedHouseIds(excludeResidentId));
    }
}
