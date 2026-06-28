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

import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class PropertyResourceService {

    private final CmBuildingMapper buildingMapper;
    private final CmHouseMapper houseMapper;
    private final CmResidentMapper residentMapper;
    private final CmResidentTagMapper tagMapper;
    private final CmResidentTagRelMapper tagRelMapper;
    private final RpOrderMapper orderMapper;

    public TableDataInfo searchBuildings(int pageNum, int pageSize, String buildingNo) {
        LambdaQueryWrapper<CmBuilding> qw = new LambdaQueryWrapper<CmBuilding>()
            .like(StringUtils.hasText(buildingNo), CmBuilding::getBuildingNo, buildingNo)
            .last("ORDER BY CAST(REPLACE(building_no, '栋', '') AS UNSIGNED) ASC");
        Page<CmBuilding> page = buildingMapper.selectPage(new Page<>(pageNum, pageSize), qw);
        return new TableDataInfo(page.getTotal(), page.getRecords());
    }

    /** 下拉等场景使用，返回全部楼栋 */
    public List<CmBuilding> listBuildings() {
        return buildingMapper.selectList(new LambdaQueryWrapper<CmBuilding>()
            .last("ORDER BY CAST(REPLACE(building_no, '栋', '') AS UNSIGNED) ASC"));
    }

    public void addBuilding(CmBuilding b) {
        buildingMapper.insert(b);
    }

    public void updateBuilding(CmBuilding b) {
        buildingMapper.updateById(b);
    }

    @Transactional
    public void deleteBuilding(Long buildingId) {
        long houseCount = houseMapper.selectCount(new LambdaQueryWrapper<CmHouse>().eq(CmHouse::getBuildingId, buildingId));
        if (houseCount > 0) throw new ServiceException("该楼栋下仍有房屋，请先删除或迁移房屋");
        buildingMapper.deleteById(buildingId);
    }

    public TableDataInfo searchHouses(int pageNum, int pageSize, Long buildingId, String houseNo) {
        LambdaQueryWrapper<CmHouse> qw = new LambdaQueryWrapper<CmHouse>()
            .eq(buildingId != null, CmHouse::getBuildingId, buildingId)
            .like(StringUtils.hasText(houseNo), CmHouse::getHouseNo, houseNo);
        if (buildingId != null) {
            qw.last("ORDER BY CAST(house_no AS UNSIGNED) ASC");
        } else {
            qw.last("ORDER BY building_id ASC, CAST(house_no AS UNSIGNED) ASC");
        }
        Page<CmHouse> page = houseMapper.selectPage(new Page<>(pageNum, pageSize), qw);
        return new TableDataInfo(page.getTotal(), page.getRecords());
    }

    public List<CmHouse> listHouses(Long buildingId) {
        LambdaQueryWrapper<CmHouse> qw = new LambdaQueryWrapper<CmHouse>()
            .eq(buildingId != null, CmHouse::getBuildingId, buildingId);
        if (buildingId != null) {
            qw.last("ORDER BY CAST(house_no AS UNSIGNED) ASC");
        } else {
            qw.last("ORDER BY building_id ASC, CAST(house_no AS UNSIGNED) ASC");
        }
        return houseMapper.selectList(qw);
    }

    public void addHouse(CmHouse h) {
        houseMapper.insert(h);
    }

    public void updateHouse(CmHouse h) {
        houseMapper.updateById(h);
    }

    @Transactional
    public void deleteHouse(Long houseId) {
        long residentCount = residentMapper.selectCount(new LambdaQueryWrapper<CmResident>()
            .eq(CmResident::getHouseId, houseId)
            .eq(CmResident::getDelFlag, "0"));
        if (residentCount > 0) throw new ServiceException("该房屋下仍有住户档案，请先删除住户");
        houseMapper.deleteById(houseId);
    }

    public List<CmResidentTag> listTags() {
        return tagMapper.selectList(null);
    }

    public void addTag(CmResidentTag tag) {
        tagMapper.insert(tag);
    }

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
            .last("ORDER BY (SELECT h.building_id FROM cm_house h WHERE h.house_id = cm_resident.house_id) ASC, " +
                "(SELECT CAST(h.house_no AS UNSIGNED) FROM cm_house h WHERE h.house_id = cm_resident.house_id) ASC");
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
}
