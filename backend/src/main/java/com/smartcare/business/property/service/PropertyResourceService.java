package com.smartcare.business.property.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.smartcare.business.property.domain.*;
import com.smartcare.business.property.mapper.*;
import com.smartcare.business.repair.domain.RpOrder;
import com.smartcare.business.repair.mapper.RpOrderMapper;
import com.smartcare.common.core.page.TableDataInfo;
import com.smartcare.common.exception.ServiceException;
import com.smartcare.system.service.UserAccountService;
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
    private final ResidentCareTagService careTagService;
    private final UserAccountService accountService;

    public TableDataInfo searchBuildings(int pageNum, int pageSize, String buildingNo, Integer totalFloors) {
        LambdaQueryWrapper<CmBuilding> qw = new LambdaQueryWrapper<CmBuilding>()
            .like(StringUtils.hasText(buildingNo), CmBuilding::getBuildingNo, buildingNo)
            .eq(totalFloors != null, CmBuilding::getTotalFloors, totalFloors)
            .last("ORDER BY CAST(REPLACE(building_no, '栋', '') AS UNSIGNED) ASC");
        Page<CmBuilding> page = buildingMapper.selectPage(new Page<>(pageNum, pageSize), qw);
        for (CmBuilding b : page.getRecords()) {
            long hc = houseMapper.selectCount(new LambdaQueryWrapper<CmHouse>().eq(CmHouse::getBuildingId, b.getBuildingId()));
            b.setHouseCount(Math.toIntExact(hc));
            List<Long> houseIds = houseMapper.selectList(new LambdaQueryWrapper<CmHouse>()
                .eq(CmHouse::getBuildingId, b.getBuildingId())
                .select(CmHouse::getHouseId)).stream().map(CmHouse::getHouseId).toList();
            if (houseIds.isEmpty()) {
                b.setResidentCount(0);
            } else {
                b.setResidentCount(residentMapper.selectCount(new LambdaQueryWrapper<CmResident>()
                    .in(CmResident::getHouseId, houseIds)
                    .eq(CmResident::getDelFlag, "0")).intValue());
            }
        }
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

    public TableDataInfo searchHouses(int pageNum, int pageSize, Long buildingId, String houseNo, String layout) {
        LambdaQueryWrapper<CmHouse> qw = new LambdaQueryWrapper<CmHouse>()
            .eq(buildingId != null, CmHouse::getBuildingId, buildingId)
            .like(StringUtils.hasText(houseNo), CmHouse::getHouseNo, houseNo)
            .like(StringUtils.hasText(layout), CmHouse::getLayout, layout);
        if (buildingId != null) {
            qw.last("ORDER BY CAST(house_no AS UNSIGNED) ASC");
        } else {
            qw.last("ORDER BY building_id ASC, CAST(house_no AS UNSIGNED) ASC");
        }
        Page<CmHouse> page = houseMapper.selectPage(new Page<>(pageNum, pageSize), qw);
        Map<Long, String> buildingNoMap = buildingMapper.selectList(null).stream()
            .collect(Collectors.toMap(CmBuilding::getBuildingId, CmBuilding::getBuildingNo, (a, b) -> a));
        for (CmHouse h : page.getRecords()) {
            h.setBuildingNo(buildingNoMap.getOrDefault(h.getBuildingId(), ""));
            attachHouseResident(h);
        }
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
        if (!StringUtils.hasText(tag.getTagName())) {
            throw new ServiceException("标签名称不能为空");
        }
        if ("auto".equals(tag.getTagType())) {
            throw new ServiceException("系统标签不可手动创建");
        }
        if (!StringUtils.hasText(tag.getTagType())) {
            tag.setTagType("manual");
        }
        tagMapper.insert(tag);
    }

    @Transactional
    public void deleteTag(Long tagId) {
        CmResidentTag tag = tagMapper.selectById(tagId);
        if (tag == null) throw new ServiceException("标签不存在");
        if ("auto".equals(tag.getTagType())) {
            throw new ServiceException("系统标签不可删除");
        }
        List<Long> residentIds = tagRelMapper.selectResidentIdsByTag(tagId);
        if (!residentIds.isEmpty()) {
            throw new ServiceException("该标签仍有关联住户，请先在住户档案中解除后再删除");
        }
        tagMapper.deleteById(tagId);
    }

    public TableDataInfo searchResidents(int pageNum, int pageSize, Long buildingId, Long tagId, String keyword,
                                         String gender, Integer ageMin, Integer ageMax) {
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
            .eq(StringUtils.hasText(gender), CmResident::getGender, gender)
            .ge(ageMin != null, CmResident::getAge, ageMin)
            .le(ageMax != null, CmResident::getAge, ageMax)
            .in(houseIds != null, CmResident::getHouseId, houseIds != null ? houseIds : Set.of())
            .last("ORDER BY (SELECT h.building_id FROM cm_house h WHERE h.house_id = cm_resident.house_id) ASC, " +
                "(SELECT CAST(h.house_no AS UNSIGNED) FROM cm_house h WHERE h.house_id = cm_resident.house_id) ASC");
        List<CmResident> all = residentMapper.selectList(qw);
        if (tagId != null) {
            all = all.stream().filter(r -> matchCareTag(r, tagId)).collect(Collectors.toList());
        }
        long total = all.size();
        int from = Math.max(0, (pageNum - 1) * pageSize);
        int to = Math.min(all.size(), from + pageSize);
        List<Map<String, Object>> rows = (from >= all.size() ? List.<CmResident>of() : all.subList(from, to))
            .stream().map(this::residentVo).collect(Collectors.toList());
        return new TableDataInfo(total, rows);
    }

    public Map<String, Object> getResidentDetail(Long residentId) {
        CmResident r = residentMapper.selectById(residentId);
        if (r == null || "2".equals(r.getDelFlag())) {
            throw new ServiceException("住户档案不存在");
        }
        return residentVo(r);
    }

    private void attachHouseResident(CmHouse h) {
        CmResident r = residentMapper.selectOne(new LambdaQueryWrapper<CmResident>()
            .eq(CmResident::getHouseId, h.getHouseId())
            .eq(CmResident::getDelFlag, "0")
            .last("LIMIT 1"));
        if (r != null) {
            h.setResidentId(r.getResidentId());
            h.setResidentName(r.getName());
            h.setLivingStatus(StringUtils.hasText(r.getLivingStatus()) ? r.getLivingStatus() : "1");
            h.setLivingStatusLabel(livingStatusLabel(h.getLivingStatus()));
            if (StringUtils.hasText(r.getName())) {
                h.setOwnerName(r.getName());
            }
        }
    }

    private String livingStatusLabel(String status) {
        if ("2".equals(status)) return "空置";
        if ("3".equals(status)) return "出租";
        return "在住";
    }

    private boolean matchCareTag(CmResident r, Long tagId) {
        if (tagId == 1L) {
            return careTagService.isAloneElder(r);
        }
        if (tagId == 2L) {
            return careTagService.isHighAgeElder(r);
        }
        if (tagId == 3L) {
            return careTagService.hasFocusTag(r.getResidentId());
        }
        if (tagId > 3L) {
            return tagRelMapper.selectTagIdsByResident(r.getResidentId()).contains(tagId);
        }
        return true;
    }

    private Map<String, Object> residentVo(CmResident r) {
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("residentId", r.getResidentId());
        m.put("userId", r.getUserId());
        if (r.getUserId() != null) {
            var owner = accountService.findById(r.getUserId());
            if (owner != null) {
                m.put("ownerUsername", owner.getUsername());
            }
        }
        m.put("houseId", r.getHouseId());
        m.put("name", r.getName());
        m.put("gender", r.getGender());
        m.put("age", r.getAge());
        m.put("phone", r.getPhone());
        m.put("idCard", r.getIdCard());
        m.put("moveInDate", r.getMoveInDate());
        m.put("remark", r.getRemark());
        m.put("livingStatus", StringUtils.hasText(r.getLivingStatus()) ? r.getLivingStatus() : "1");
        m.put("isOwner", r.getIsOwner() != null ? r.getIsOwner() : 1);
        m.put("ownerName", r.getOwnerName());
        m.put("ownerPhone", r.getOwnerPhone());
        m.put("ownerRelation", r.getOwnerRelation());
        m.put("emergencyName", r.getEmergencyName());
        m.put("emergencyPhone", r.getEmergencyPhone());
        m.put("emergencyRelation", r.getEmergencyRelation());
        m.put("emergencyName", r.getEmergencyName());
        m.put("emergencyPhone", r.getEmergencyPhone());
        m.put("emergencyRelation", r.getEmergencyRelation());
        m.put("livingStatusLabel", livingStatusLabel(StringUtils.hasText(r.getLivingStatus()) ? r.getLivingStatus() : "1"));
        m.put("emergencyContact", formatEmergencyDisplay(r));
        m.put("isAloneLiving", careTagService.isAloneElder(r) ? 1 : 0);
        List<String> systemTags = careTagService.computeAutoTagNames(r);
        List<String> manualTags = careTagService.computeManualTagNames(r.getResidentId());
        m.put("systemTags", systemTags);
        m.put("manualTags", manualTags);
        List<String> allTags = new ArrayList<>(systemTags);
        allTags.addAll(manualTags);
        m.put("careTags", allTags);
        m.put("tagIds", tagRelMapper.selectTagIdsByResident(r.getResidentId()));
        m.put("manualTagIds", careTagService.filterManualTagIds(
            tagRelMapper.selectTagIdsByResident(r.getResidentId())));
        m.put("elderCareTarget", careTagService.isAiMonitorTarget(r));
        CmHouse h = houseMapper.selectById(r.getHouseId());
        if (h != null) {
            m.put("houseNo", h.getHouseNo());
            CmBuilding b = buildingMapper.selectById(h.getBuildingId());
            m.put("buildingNo", b != null ? b.getBuildingNo() : "");
        }
        return m;
    }

    private String formatEmergencyDisplay(CmResident r) {
        if (StringUtils.hasText(r.getEmergencyName()) || StringUtils.hasText(r.getEmergencyPhone())) {
            String rel = StringUtils.hasText(r.getEmergencyRelation()) ? "（" + r.getEmergencyRelation() + "）" : "";
            return (r.getEmergencyName() != null ? r.getEmergencyName() : "")
                + rel
                + (StringUtils.hasText(r.getEmergencyPhone()) ? " " + r.getEmergencyPhone() : "");
        }
        return r.getEmergencyContact();
    }

    @Transactional
    public void addResident(CmResident resident) {
        validateResident(resident);
        applyDefaults(resident);
        assertHouseUnique(resident.getHouseId(), null);
        resolveAndBindOwner(resident);
        validateManualTags(resident);
        residentMapper.insert(resident);
        careTagService.saveManualTags(resident.getResidentId(), resident.getTagIds());
        accountService.bindOwnerResident(resident.getUserId(), resident.getResidentId(),
            resident.getName(), resident.getPhone());
        syncHouseFromResident(resident);
    }

    @Transactional
    public void updateResident(CmResident resident) {
        validateResident(resident);
        applyDefaults(resident);
        assertHouseUnique(resident.getHouseId(), resident.getResidentId());
        resolveAndBindOwner(resident);
        validateManualTags(resident);
        residentMapper.updateById(resident);
        careTagService.saveManualTags(resident.getResidentId(), resident.getTagIds());
        accountService.bindOwnerResident(resident.getUserId(), resident.getResidentId(),
            resident.getName(), resident.getPhone());
        syncHouseFromResident(resident);
    }

    public List<Map<String, Object>> listOwnerBindOptions(Long excludeResidentId) {
        return accountService.listOwnerBindOptions(excludeResidentId);
    }

    private void resolveAndBindOwner(CmResident resident) {
        Long userId = accountService.resolveOwnerAccountId(
            resident.getPhone(), resident.getName(), resident.getResidentId());
        resident.setUserId(userId);
    }

    private void validateManualTags(CmResident resident) {
        List<Long> tagIds = resident.getTagIds();
        if (tagIds == null || !tagIds.contains(ResidentCareTagService.TAG_FOCUS)) {
            return;
        }
        if (!careTagService.canApplyFocusTag(resident)) {
            throw new ServiceException("独居或高龄老人已自动纳入老人关怀，无需设置「重点关注」");
        }
    }

    private void syncHouseFromResident(CmResident resident) {
        if (resident.getHouseId() == null) {
            return;
        }
        CmHouse upd = new CmHouse();
        upd.setHouseId(resident.getHouseId());
        upd.setOwnerName(resident.getName());
        houseMapper.updateById(upd);
    }

    private void clearHouseOwner(Long houseId) {
        if (houseId == null) {
            return;
        }
        CmHouse upd = new CmHouse();
        upd.setHouseId(houseId);
        upd.setOwnerName("");
        houseMapper.updateById(upd);
    }

    private void applyDefaults(CmResident resident) {
        resident.setDelFlag("0");
        if (!StringUtils.hasText(resident.getLivingStatus())) {
            resident.setLivingStatus("1");
        }
        if (resident.getIsOwner() == null) {
            resident.setIsOwner(1);
        }
        if (resident.getIsOwner() == 1) {
            resident.setOwnerName(null);
            resident.setOwnerPhone(null);
            resident.setOwnerRelation("本人");
        }
        Integer age = resident.getAge();
        if (age != null) {
            resident.setAge(age);
        }
        if (!StringUtils.hasText(resident.getResidentType())) {
            resident.setResidentType(resident.getIsOwner() != null && resident.getIsOwner() == 0 ? "1" : "0");
        }
        resident.setIsAloneLiving(careTagService.isAloneElder(resident) ? 1 : 0);
    }

    private void validateResident(CmResident resident) {
        if (!StringUtils.hasText(resident.getName())) {
            throw new ServiceException("姓名不能为空");
        }
        if (resident.getName().trim().length() < 2 || resident.getName().trim().length() > 20) {
            throw new ServiceException("姓名长度应为2-20个字符");
        }
        if (!StringUtils.hasText(resident.getGender())) {
            throw new ServiceException("请选择性别");
        }
        if (resident.getAge() == null) {
            throw new ServiceException("请填写年龄");
        }
        if (!StringUtils.hasText(resident.getPhone())) {
            throw new ServiceException("电话不能为空");
        }
        if (!resident.getPhone().matches("^1\\d{10}$")) {
            throw new ServiceException("手机号格式不正确");
        }
        if (resident.getHouseId() == null) {
            throw new ServiceException("请选择房屋");
        }
        if (StringUtils.hasText(resident.getRemark()) && resident.getRemark().length() > 512) {
            throw new ServiceException("备注不能超过512个字符");
        }
        validateGenderAge(resident.getGender(), resident.getAge());
        assertPhoneUnique(resident.getPhone(), resident.getResidentId());
        if (!StringUtils.hasText(resident.getLivingStatus())) {
            resident.setLivingStatus("1");
        } else if (!Set.of("1", "2", "3").contains(resident.getLivingStatus())) {
            throw new ServiceException("居住状态无效");
        }
        int isOwner = resident.getIsOwner() != null ? resident.getIsOwner() : 1;
        if (isOwner == 0) {
            if (!StringUtils.hasText(resident.getOwnerName())) {
                throw new ServiceException("非产权人须填写产权人姓名");
            }
            if (!StringUtils.hasText(resident.getOwnerPhone()) || !resident.getOwnerPhone().matches("^1\\d{10}$")) {
                throw new ServiceException("请填写正确的产权人电话");
            }
            if (!StringUtils.hasText(resident.getOwnerRelation())) {
                throw new ServiceException("请选择与产权人关系");
            }
        }
        if (StringUtils.hasText(resident.getEmergencyName()) || StringUtils.hasText(resident.getEmergencyPhone())) {
            if (!StringUtils.hasText(resident.getEmergencyName())) {
                throw new ServiceException("请填写紧急联系人姓名");
            }
            if (!StringUtils.hasText(resident.getEmergencyPhone()) || !resident.getEmergencyPhone().matches("^1\\d{10}$")) {
                throw new ServiceException("请填写正确的紧急联系人电话");
            }
            if (!StringUtils.hasText(resident.getEmergencyRelation())) {
                throw new ServiceException("请选择与紧急联系人关系");
            }
        }
    }

    private void assertHouseUnique(Long houseId, Long excludeResidentId) {
        LambdaQueryWrapper<CmResident> qw = new LambdaQueryWrapper<CmResident>()
            .eq(CmResident::getHouseId, houseId)
            .eq(CmResident::getDelFlag, "0");
        if (excludeResidentId != null) {
            qw.ne(CmResident::getResidentId, excludeResidentId);
        }
        if (residentMapper.selectCount(qw) > 0) {
            throw new ServiceException("该房屋已有住户档案，一个房屋仅允许一条档案");
        }
    }

    private void validateGenderAge(String gender, Integer age) {
        if (StringUtils.hasText(gender) && !"0".equals(gender) && !"1".equals(gender)) {
            throw new ServiceException("性别格式不正确");
        }
        if (age != null && (age < 1 || age > 120)) {
            throw new ServiceException("年龄应在1-120之间");
        }
    }

    private void assertPhoneUnique(String phone, Long excludeResidentId) {
        LambdaQueryWrapper<CmResident> qw = new LambdaQueryWrapper<CmResident>()
            .eq(CmResident::getDelFlag, "0")
            .eq(CmResident::getPhone, phone);
        if (excludeResidentId != null) {
            qw.ne(CmResident::getResidentId, excludeResidentId);
        }
        if (residentMapper.selectCount(qw) > 0) {
            throw new ServiceException("该手机号已被其他住户档案使用");
        }
    }

    /** 已有住户档案的房屋 ID（一屋一条档案） */
    public List<Long> listOccupiedHouseIds(Long excludeResidentId) {
        LambdaQueryWrapper<CmResident> qw = new LambdaQueryWrapper<CmResident>()
            .eq(CmResident::getDelFlag, "0")
            .select(CmResident::getHouseId);
        if (excludeResidentId != null) {
            qw.ne(CmResident::getResidentId, excludeResidentId);
        }
        return residentMapper.selectList(qw).stream()
            .map(CmResident::getHouseId)
            .filter(Objects::nonNull)
            .distinct()
            .collect(Collectors.toList());
    }

    @Transactional
    public void deleteResident(Long residentId) {
        CmResident r = residentMapper.selectById(residentId);
        if (r == null || "2".equals(r.getDelFlag())) throw new ServiceException("住户不存在");
        Long houseId = r.getHouseId();
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
        clearHouseOwner(houseId);
    }
}
