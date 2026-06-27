package com.smartcare.business.property.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.smartcare.business.property.domain.*;
import com.smartcare.business.property.mapper.*;
import com.smartcare.business.repair.domain.RpOrder;
import com.smartcare.business.repair.mapper.RpOrderMapper;
import com.smartcare.common.core.page.TableDataInfo;
import com.smartcare.common.exception.ServiceException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class PropertyResourceService {

    private final CmBuildingMapper buildingMapper;
    private final CmHouseMapper houseMapper;
    private final CmEquipmentMapper equipmentMapper;
    private final CmResidentMapper residentMapper;
    private final CmResidentTagMapper tagMapper;
    private final CmResidentTagRelMapper tagRelMapper;
    private final CmParkingMapper parkingMapper;
    private final CmParkingBindMapper parkingBindMapper;
    private final CmViolationMapper violationMapper;
    private final CmMoveApplyMapper moveApplyMapper;
    private final RpOrderMapper orderMapper;

    // ---------- 楼栋 ----------
    public List<CmBuilding> listBuildings() {
        return buildingMapper.selectList(new LambdaQueryWrapper<CmBuilding>().orderByAsc(CmBuilding::getBuildingNo));
    }

    public void addBuilding(CmBuilding b) {
        buildingMapper.insert(b);
    }

    public void updateBuilding(CmBuilding b) {
        buildingMapper.updateById(b);
    }

    // ---------- 房屋 ----------
    public List<CmHouse> listHouses(Long buildingId) {
        return houseMapper.selectList(new LambdaQueryWrapper<CmHouse>()
            .eq(buildingId != null, CmHouse::getBuildingId, buildingId)
            .orderByAsc(CmHouse::getHouseNo));
    }

    public List<Map<String, Object>> listRentHouses(String rentStatus) {
        List<CmHouse> houses = houseMapper.selectList(new LambdaQueryWrapper<CmHouse>()
            .eq(StringUtils.hasText(rentStatus), CmHouse::getRentStatus, rentStatus)
            .orderByDesc(CmHouse::getHouseId));
        return houses.stream().map(this::houseVo).collect(Collectors.toList());
    }

    public void addHouse(CmHouse h) {
        if (!StringUtils.hasText(h.getRentStatus())) h.setRentStatus("0");
        houseMapper.insert(h);
    }

    public void updateHouse(CmHouse h) {
        houseMapper.updateById(h);
    }

    private Map<String, Object> houseVo(CmHouse h) {
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("houseId", h.getHouseId());
        m.put("buildingId", h.getBuildingId());
        CmBuilding b = buildingMapper.selectById(h.getBuildingId());
        m.put("buildingNo", b != null ? b.getBuildingNo() : "");
        m.put("houseNo", h.getHouseNo());
        m.put("area", h.getArea());
        m.put("layout", h.getLayout());
        m.put("ownerName", h.getOwnerName());
        m.put("rentStatus", h.getRentStatus());
        m.put("tenantName", h.getTenantName());
        m.put("tenantPhone", h.getTenantPhone());
        m.put("leaseStart", h.getLeaseStart());
        m.put("leaseEnd", h.getLeaseEnd());
        m.put("rentAmount", h.getRentAmount());
        return m;
    }

    // ---------- 设备 ----------
    public List<CmEquipment> listEquipment(String equipType) {
        return equipmentMapper.selectList(new LambdaQueryWrapper<CmEquipment>()
            .eq(StringUtils.hasText(equipType), CmEquipment::getEquipType, equipType)
            .orderByAsc(CmEquipment::getEquipNo));
    }

    public void addEquipment(CmEquipment e) {
        if (!StringUtils.hasText(e.getIotStatus())) e.setIotStatus("normal");
        equipmentMapper.insert(e);
    }

    public void updateEquipment(CmEquipment e) {
        equipmentMapper.updateById(e);
    }

    public void deleteEquipment(Long id) {
        equipmentMapper.deleteById(id);
    }

    // ---------- 标签 ----------
    public List<CmResidentTag> listTags() {
        return tagMapper.selectList(null);
    }

    public void addTag(CmResidentTag tag) {
        tagMapper.insert(tag);
    }

    // ---------- 住户 ----------
    public TableDataInfo searchResidents(int pageNum, int pageSize, Long buildingId, Long tagId, String keyword) {
        Set<Long> residentFilter = null;
        if (tagId != null) {
            residentFilter = new HashSet<>(tagRelMapper.selectResidentIdsByTag(tagId));
            if (residentFilter.isEmpty()) {
                return new TableDataInfo(0L, List.of());
            }
        }
        Set<Long> houseIds = null;
        if (buildingId != null) {
            houseIds = houseMapper.selectList(new LambdaQueryWrapper<CmHouse>().eq(CmHouse::getBuildingId, buildingId))
                .stream().map(CmHouse::getHouseId).collect(Collectors.toSet());
            if (houseIds.isEmpty()) {
                return new TableDataInfo(0L, List.of());
            }
        }
        LambdaQueryWrapper<CmResident> qw = new LambdaQueryWrapper<CmResident>()
            .eq(CmResident::getDelFlag, "0")
            .like(StringUtils.hasText(keyword), CmResident::getName, keyword)
            .in(residentFilter != null, CmResident::getResidentId, residentFilter != null ? residentFilter : Set.of())
            .in(houseIds != null, CmResident::getHouseId, houseIds != null ? houseIds : Set.of())
            .orderByDesc(CmResident::getResidentId);
        Page<CmResident> page = residentMapper.selectPage(new Page<>(pageNum, pageSize), qw);
        List<Map<String, Object>> rows = page.getRecords().stream().map(this::residentVo).collect(Collectors.toList());
        return new TableDataInfo(page.getTotal(), rows);
    }

    private Map<String, Object> residentVo(CmResident r) {
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("residentId", r.getResidentId());
        m.put("userId", r.getUserId());
        m.put("houseId", r.getHouseId());
        m.put("name", r.getName());
        m.put("idCard", r.getIdCard());
        m.put("phone", r.getPhone());
        m.put("residentType", r.getResidentType());
        m.put("moveInDate", r.getMoveInDate());
        m.put("emergencyContact", r.getEmergencyContact());
        m.put("familyMembers", r.getFamilyMembers());
        m.put("tagIds", tagRelMapper.selectTagIdsByResident(r.getResidentId()));
        CmHouse h = houseMapper.selectById(r.getHouseId());
        if (h != null) {
            m.put("houseNo", h.getHouseNo());
            CmBuilding b = buildingMapper.selectById(h.getBuildingId());
            m.put("buildingNo", b != null ? b.getBuildingNo() : "");
        }
        long violation = violationMapper.selectCount(new LambdaQueryWrapper<CmViolation>()
            .eq(CmViolation::getResidentId, r.getResidentId()).eq(CmViolation::getStatus, "1"));
        m.put("blacklisted", violation > 0);
        return m;
    }

    @Transactional
    public void addResident(CmResident resident, List<Long> tagIds) {
        resident.setDelFlag("0");
        residentMapper.insert(resident);
        saveTags(resident.getResidentId(), tagIds);
    }

    @Transactional
    public void updateResident(CmResident resident, List<Long> tagIds) {
        residentMapper.updateById(resident);
        if (tagIds != null) {
            saveTags(resident.getResidentId(), tagIds);
        }
    }

    private void saveTags(Long residentId, List<Long> tagIds) {
        tagRelMapper.deleteByResident(residentId);
        if (tagIds == null) return;
        for (Long tagId : tagIds) {
            tagRelMapper.insertRel(residentId, tagId);
        }
    }

    @Transactional
    public void deleteResident(Long residentId) {
        CmResident r = residentMapper.selectById(residentId);
        if (r == null || "2".equals(r.getDelFlag())) throw new ServiceException("住户不存在");
        long parking = parkingBindMapper.selectCount(new LambdaQueryWrapper<CmParkingBind>()
            .eq(CmParkingBind::getResidentId, residentId));
        if (parking > 0) throw new ServiceException("请先解除车位绑定");
        if (r.getUserId() != null) {
            long orders = orderMapper.selectCount(new LambdaQueryWrapper<RpOrder>()
                .eq(RpOrder::getOwnerId, r.getUserId())
                .notIn(RpOrder::getStatus, "completed", "cancelled", "closed"));
            if (orders > 0) throw new ServiceException("存在未完结报修工单，无法删除");
        }
        CmResident upd = new CmResident();
        upd.setResidentId(residentId);
        upd.setDelFlag("2");
        residentMapper.updateById(upd);
        tagRelMapper.deleteByResident(residentId);
    }

    // ---------- 车位 ----------
    public List<Map<String, Object>> listParking() {
        List<CmParking> list = parkingMapper.selectList(new LambdaQueryWrapper<CmParking>().orderByAsc(CmParking::getParkingNo));
        return list.stream().map(p -> {
            Map<String, Object> m = new LinkedHashMap<>();
            m.put("parkingId", p.getParkingId());
            m.put("parkingNo", p.getParkingNo());
            m.put("status", p.getStatus());
            CmParkingBind bind = parkingBindMapper.selectOne(new LambdaQueryWrapper<CmParkingBind>()
                .eq(CmParkingBind::getParkingId, p.getParkingId()).last("LIMIT 1"));
            if (bind != null) {
                m.put("residentId", bind.getResidentId());
                m.put("bindTime", bind.getBindTime());
                CmResident res = residentMapper.selectById(bind.getResidentId());
                m.put("residentName", res != null ? res.getName() : "");
            }
            return m;
        }).collect(Collectors.toList());
    }

    public void addParking(CmParking p) {
        if (!StringUtils.hasText(p.getStatus())) p.setStatus("0");
        parkingMapper.insert(p);
    }

    public void updateParking(CmParking p) {
        parkingMapper.updateById(p);
    }

    @Transactional
    public void bindParking(Long parkingId, Long residentId) {
        CmParking p = parkingMapper.selectById(parkingId);
        if (p == null) throw new ServiceException("车位不存在");
        if ("1".equals(p.getStatus())) throw new ServiceException("车位已绑定");
        CmParkingBind bind = new CmParkingBind();
        bind.setParkingId(parkingId);
        bind.setResidentId(residentId);
        bind.setBindTime(LocalDateTime.now());
        parkingBindMapper.insert(bind);
        p.setStatus("1");
        parkingMapper.updateById(p);
    }

    @Transactional
    public void unbindParking(Long parkingId) {
        CmParking p = parkingMapper.selectById(parkingId);
        if (p == null) throw new ServiceException("车位不存在");
        parkingBindMapper.delete(new LambdaQueryWrapper<CmParkingBind>().eq(CmParkingBind::getParkingId, parkingId));
        p.setStatus("0");
        parkingMapper.updateById(p);
    }

    // ---------- 违规 ----------
    public List<Map<String, Object>> listViolations(String status) {
        List<CmViolation> list = violationMapper.selectList(new LambdaQueryWrapper<CmViolation>()
            .eq(StringUtils.hasText(status), CmViolation::getStatus, status)
            .orderByDesc(CmViolation::getViolationId));
        return list.stream().map(v -> {
            Map<String, Object> m = new LinkedHashMap<>();
            m.put("violationId", v.getViolationId());
            m.put("residentId", v.getResidentId());
            m.put("violationType", v.getViolationType());
            m.put("measure", v.getMeasure());
            m.put("unlockDate", v.getUnlockDate());
            m.put("status", v.getStatus());
            CmResident r = residentMapper.selectById(v.getResidentId());
            m.put("residentName", r != null ? r.getName() : "");
            return m;
        }).collect(Collectors.toList());
    }

    public void addViolation(CmViolation v) {
        if (!StringUtils.hasText(v.getStatus())) v.setStatus("1");
        violationMapper.insert(v);
    }

    public void updateViolation(CmViolation v) {
        violationMapper.updateById(v);
    }

    @Transactional
    public void removeViolation(Long violationId) {
        CmViolation v = violationMapper.selectById(violationId);
        if (v == null) throw new ServiceException("记录不存在");
        v.setStatus("0");
        violationMapper.updateById(v);
    }

    // ---------- 入住迁出 ----------
    public List<Map<String, Object>> listMoveApply(String status) {
        List<CmMoveApply> list = moveApplyMapper.selectList(new LambdaQueryWrapper<CmMoveApply>()
            .eq(StringUtils.hasText(status), CmMoveApply::getStatus, status)
            .orderByDesc(CmMoveApply::getCreateTime));
        return list.stream().map(a -> {
            Map<String, Object> m = new LinkedHashMap<>();
            m.put("applyId", a.getApplyId());
            m.put("applyType", a.getApplyType());
            m.put("status", a.getStatus());
            m.put("applicantName", a.getApplicantName());
            m.put("applicantPhone", a.getApplicantPhone());
            m.put("houseId", a.getHouseId());
            m.put("rejectReason", a.getRejectReason());
            m.put("createTime", a.getCreateTime());
            CmHouse h = houseMapper.selectById(a.getHouseId());
            if (h != null) {
                m.put("houseNo", h.getHouseNo());
                CmBuilding b = buildingMapper.selectById(h.getBuildingId());
                m.put("buildingNo", b != null ? b.getBuildingNo() : "");
            }
            return m;
        }).collect(Collectors.toList());
    }

    public void addMoveApply(CmMoveApply apply) {
        if (!StringUtils.hasText(apply.getStatus())) apply.setStatus("0");
        moveApplyMapper.insert(apply);
    }

    @Transactional
    public void auditMoveApply(Long applyId, boolean pass, String rejectReason) {
        CmMoveApply apply = moveApplyMapper.selectById(applyId);
        if (apply == null) throw new ServiceException("申请不存在");
        if (!"0".equals(apply.getStatus())) throw new ServiceException("申请已处理");
        if (pass) {
            apply.setStatus("1");
            apply.setRejectReason("");
            if ("0".equals(apply.getApplyType()) && apply.getResidentId() == null) {
                CmResident r = new CmResident();
                r.setHouseId(apply.getHouseId());
                r.setName(apply.getApplicantName());
                r.setPhone(apply.getApplicantPhone());
                r.setUserId(apply.getUserId());
                r.setResidentType("0");
                r.setMoveInDate(LocalDate.now());
                r.setDelFlag("0");
                residentMapper.insert(r);
                apply.setResidentId(r.getResidentId());
            }
            if ("1".equals(apply.getApplyType()) && apply.getResidentId() != null) {
                CmResident r = new CmResident();
                r.setResidentId(apply.getResidentId());
                r.setDelFlag("2");
                residentMapper.updateById(r);
            }
        } else {
            if (!StringUtils.hasText(rejectReason)) throw new ServiceException("驳回须填写理由");
            apply.setStatus("2");
            apply.setRejectReason(rejectReason);
        }
        moveApplyMapper.updateById(apply);
    }
}
