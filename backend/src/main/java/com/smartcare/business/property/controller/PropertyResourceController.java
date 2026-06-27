package com.smartcare.business.property.controller;

import com.smartcare.business.property.domain.*;
import com.smartcare.business.property.service.PropertyResourceService;
import com.smartcare.common.core.domain.AjaxResult;
import com.smartcare.common.core.page.TableDataInfo;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/property")
@RequiredArgsConstructor
public class PropertyResourceController {

    private final PropertyResourceService resourceService;

    // 楼栋
    @GetMapping("/building/list")
    public AjaxResult buildingList() {
        return AjaxResult.success(resourceService.listBuildings());
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

    // 房屋
    @GetMapping("/house/list")
    public AjaxResult houseList(@RequestParam(required = false) Long buildingId) {
        return AjaxResult.success(resourceService.listHouses(buildingId));
    }

    @GetMapping("/house/rent/list")
    public AjaxResult rentList(@RequestParam(required = false) String rentStatus) {
        return AjaxResult.success(resourceService.listRentHouses(rentStatus));
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

    // 设备
    @GetMapping("/equipment/list")
    public AjaxResult equipmentList(@RequestParam(required = false) String equipType) {
        return AjaxResult.success(resourceService.listEquipment(equipType));
    }

    @PostMapping("/equipment")
    public AjaxResult addEquipment(@RequestBody CmEquipment equipment) {
        resourceService.addEquipment(equipment);
        return AjaxResult.success();
    }

    @PutMapping("/equipment")
    public AjaxResult updateEquipment(@RequestBody CmEquipment equipment) {
        resourceService.updateEquipment(equipment);
        return AjaxResult.success();
    }

    @DeleteMapping("/equipment/{equipmentId}")
    public AjaxResult deleteEquipment(@PathVariable Long equipmentId) {
        resourceService.deleteEquipment(equipmentId);
        return AjaxResult.success();
    }

    // 标签
    @GetMapping("/tag/list")
    public AjaxResult tagList() {
        return AjaxResult.success(resourceService.listTags());
    }

    @PostMapping("/tag")
    public AjaxResult addTag(@RequestBody CmResidentTag tag) {
        resourceService.addTag(tag);
        return AjaxResult.success();
    }

    // 住户
    @GetMapping("/resident/list")
    public AjaxResult residentList(@RequestParam(defaultValue = "1") int pageNum,
                                   @RequestParam(defaultValue = "10") int pageSize,
                                   @RequestParam(required = false) Long buildingId,
                                   @RequestParam(required = false) Long tagId,
                                   @RequestParam(required = false) String name) {
        TableDataInfo data = resourceService.searchResidents(pageNum, pageSize, buildingId, tagId, name);
        return AjaxResult.success(data);
    }

    @PostMapping("/resident")
    public AjaxResult addResident(@RequestBody CmResident resident) {
        resourceService.addResident(resident, resident.getTagIds());
        return AjaxResult.success();
    }

    @PutMapping("/resident")
    public AjaxResult editResident(@RequestBody CmResident resident) {
        resourceService.updateResident(resident, resident.getTagIds());
        return AjaxResult.success();
    }

    @DeleteMapping("/resident/{residentId}")
    public AjaxResult deleteResident(@PathVariable Long residentId) {
        resourceService.deleteResident(residentId);
        return AjaxResult.success();
    }

    // 车位
    @GetMapping("/parking/list")
    public AjaxResult parkingList() {
        return AjaxResult.success(resourceService.listParking());
    }

    @PostMapping("/parking")
    public AjaxResult addParking(@RequestBody CmParking parking) {
        resourceService.addParking(parking);
        return AjaxResult.success();
    }

    @PutMapping("/parking")
    public AjaxResult updateParking(@RequestBody CmParking parking) {
        resourceService.updateParking(parking);
        return AjaxResult.success();
    }

    @PostMapping("/parking/bind")
    public AjaxResult bindParking(@RequestBody Map<String, Long> body) {
        resourceService.bindParking(body.get("parkingId"), body.get("residentId"));
        return AjaxResult.success();
    }

    @DeleteMapping("/parking/bind/{parkingId}")
    public AjaxResult unbindParking(@PathVariable Long parkingId) {
        resourceService.unbindParking(parkingId);
        return AjaxResult.success();
    }

    // 违规
    @GetMapping("/violation/list")
    public AjaxResult violationList(@RequestParam(required = false) String status) {
        return AjaxResult.success(resourceService.listViolations(status));
    }

    @PostMapping("/violation")
    public AjaxResult addViolation(@RequestBody CmViolation violation) {
        resourceService.addViolation(violation);
        return AjaxResult.success();
    }

    @PutMapping("/violation")
    public AjaxResult updateViolation(@RequestBody CmViolation violation) {
        resourceService.updateViolation(violation);
        return AjaxResult.success();
    }

    @PutMapping("/violation/remove/{violationId}")
    public AjaxResult removeViolation(@PathVariable Long violationId) {
        resourceService.removeViolation(violationId);
        return AjaxResult.success();
    }

    // 入住迁出
    @GetMapping("/move/list")
    public AjaxResult moveList(@RequestParam(required = false) String status) {
        return AjaxResult.success(resourceService.listMoveApply(status));
    }

    @PostMapping("/move")
    public AjaxResult addMove(@RequestBody CmMoveApply apply) {
        resourceService.addMoveApply(apply);
        return AjaxResult.success();
    }

    @PutMapping("/move/audit")
    public AjaxResult auditMove(@RequestBody Map<String, Object> body) {
        Long applyId = Long.valueOf(body.get("applyId").toString());
        boolean pass = Boolean.TRUE.equals(body.get("pass")) || "1".equals(String.valueOf(body.get("pass")));
        String reason = body.get("rejectReason") != null ? body.get("rejectReason").toString() : "";
        resourceService.auditMoveApply(applyId, pass, reason);
        return AjaxResult.success();
    }
}
