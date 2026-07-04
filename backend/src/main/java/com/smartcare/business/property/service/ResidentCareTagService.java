package com.smartcare.business.property.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.smartcare.business.property.domain.CmResident;
import com.smartcare.business.property.domain.CmResidentTag;
import com.smartcare.business.property.mapper.CmResidentMapper;
import com.smartcare.business.property.mapper.CmResidentTagMapper;
import com.smartcare.business.property.mapper.CmResidentTagRelMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ResidentCareTagService {

    public static final long TAG_ALONE_ELDER = 1L;
    public static final long TAG_HIGH_AGE_ELDER = 2L;
    public static final long TAG_FOCUS = 3L;

    private static final int ALONE_MIN_AGE = 60;
    private static final int HIGH_AGE_MIN = 80;

    private final CmResidentMapper residentMapper;
    private final CmResidentTagRelMapper tagRelMapper;
    private final CmResidentTagMapper tagMapper;

    public boolean isLivingIn(CmResident r) {
        if (r == null || "2".equals(r.getDelFlag())) {
            return false;
        }
        String status = r.getLivingStatus();
        return !StringUtils.hasText(status) || "1".equals(status);
    }

    public Integer resolveAge(CmResident r) {
        if (r == null || r.getAge() == null) {
            return null;
        }
        return r.getAge();
    }

    public int countLivingInHouse(Long houseId) {
        if (houseId == null) {
            return 0;
        }
        return (int) residentMapper.selectList(
            new LambdaQueryWrapper<CmResident>()
                .eq(CmResident::getHouseId, houseId)
                .eq(CmResident::getDelFlag, "0")
        ).stream().filter(this::isLivingIn).count();
    }

    public boolean isAloneElder(CmResident r) {
        Integer age = resolveAge(r);
        return age != null && age >= ALONE_MIN_AGE && isLivingIn(r)
            && countLivingInHouse(r.getHouseId()) <= 1;
    }

    public boolean isHighAgeElder(CmResident r) {
        Integer age = resolveAge(r);
        return age != null && age >= HIGH_AGE_MIN && isLivingIn(r);
    }

    public boolean hasFocusTag(Long residentId) {
        if (residentId == null) {
            return false;
        }
        return tagRelMapper.selectTagIdsByResident(residentId).contains(TAG_FOCUS);
    }

    public boolean isElderCareTarget(CmResident r) {
        return isAiMonitorTarget(r);
    }

    /** 老人关怀 / AI 监测对象：仅独居或高龄老人，不含「重点关注」 */
    public boolean isAiMonitorTarget(CmResident r) {
        if (r == null || !isLivingIn(r)) {
            return false;
        }
        return isAloneElder(r) || isHighAgeElder(r);
    }

    /** 重点关注适用于非独居且非高龄的住户（如残障人士等） */
    public boolean canApplyFocusTag(CmResident r) {
        if (r == null) {
            return false;
        }
        return !isAloneElder(r) && !isHighAgeElder(r);
    }

    /** 系统自动标签（不存库） */
    public List<String> computeAutoTagNames(CmResident r) {
        List<String> labels = new ArrayList<>();
        if (isAloneElder(r)) {
            labels.add("独居老人");
        }
        if (isHighAgeElder(r)) {
            labels.add("高龄老人");
        }
        return labels;
    }

    public List<String> computeManualTagNames(Long residentId) {
        if (residentId == null) {
            return List.of();
        }
        List<Long> ids = tagRelMapper.selectTagIdsByResident(residentId);
        if (ids.isEmpty()) {
            return List.of();
        }
        Map<Long, String> nameMap = tagMapper.selectList(
            new LambdaQueryWrapper<CmResidentTag>().in(CmResidentTag::getTagId, ids)
        ).stream().collect(Collectors.toMap(CmResidentTag::getTagId, CmResidentTag::getTagName, (a, b) -> a));
        List<String> names = new ArrayList<>();
        for (Long id : ids) {
            CmResidentTag tag = tagMapper.selectById(id);
            if (tag != null && "manual".equals(tag.getTagType()) && nameMap.containsKey(id)) {
                names.add(nameMap.get(id));
            }
        }
        return names;
    }

    public List<String> computeAllDisplayTags(CmResident r) {
        List<String> all = new ArrayList<>(computeAutoTagNames(r));
        all.addAll(computeManualTagNames(r.getResidentId()));
        return all;
    }

    public List<Long> filterManualTagIds(List<Long> tagIds) {
        if (tagIds == null || tagIds.isEmpty()) {
            return List.of();
        }
        Set<Long> manualIds = tagMapper.selectList(
            new LambdaQueryWrapper<CmResidentTag>().eq(CmResidentTag::getTagType, "manual")
        ).stream().map(CmResidentTag::getTagId).collect(Collectors.toSet());
        return tagIds.stream()
            .filter(id -> id != null && manualIds.contains(id))
            .distinct()
            .collect(Collectors.toList());
    }

    public void saveManualTags(Long residentId, List<Long> manualTagIds) {
        if (residentId == null) {
            return;
        }
        tagRelMapper.deleteByResident(residentId);
        List<Long> manual = filterManualTagIds(manualTagIds);
        for (Long tagId : manual) {
            tagRelMapper.insertRel(residentId, tagId);
        }
    }

    public List<CmResident> listElderArchive() {
        return residentMapper.selectList(
            new LambdaQueryWrapper<CmResident>()
                .eq(CmResident::getDelFlag, "0")
                .orderByAsc(CmResident::getResidentId)
        ).stream().filter(this::isAiMonitorTarget).toList();
    }

    public List<CmResident> listAiMonitorTargets() {
        return listElderArchive();
    }

    public long countLivingAloneElders() {
        return residentMapper.selectList(
            new LambdaQueryWrapper<CmResident>().eq(CmResident::getDelFlag, "0")
        ).stream().filter(this::isAloneElder).count();
    }
}
