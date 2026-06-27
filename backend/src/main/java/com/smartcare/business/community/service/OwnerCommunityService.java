package com.smartcare.business.community.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.smartcare.business.community.domain.CsNotice;
import com.smartcare.business.community.mapper.CsNoticeMapper;
import com.smartcare.business.community.mapper.CsNoticeReadMapper;
import com.smartcare.business.property.domain.CmBuilding;
import com.smartcare.business.property.domain.CmHouse;
import com.smartcare.business.property.domain.CmResident;
import com.smartcare.business.property.mapper.CmBuildingMapper;
import com.smartcare.business.property.mapper.CmHouseMapper;
import com.smartcare.business.property.mapper.CmResidentMapper;
import com.smartcare.common.exception.ServiceException;
import com.smartcare.framework.security.SecurityUtils;
import com.smartcare.system.domain.SysUser;
import com.smartcare.system.mapper.SysUserMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class OwnerCommunityService {

    private final CsNoticeMapper noticeMapper;
    private final CsNoticeReadMapper noticeReadMapper;
    private final CmResidentMapper residentMapper;
    private final CmHouseMapper houseMapper;
    private final CmBuildingMapper buildingMapper;
    private final SysUserMapper userMapper;

    private Long currentUserId() {
        Long id = SecurityUtils.getUserId();
        if (id == null) throw new ServiceException("未登录");
        return id;
    }

    public List<Map<String, Object>> noticeList(String noticeType) {
        Long userId = currentUserId();
        List<CsNotice> notices = noticeMapper.selectList(new LambdaQueryWrapper<CsNotice>()
            .eq(CsNotice::getStatus, "1")
            .eq(StringUtils.hasText(noticeType), CsNotice::getNoticeType, noticeType)
            .orderByDesc(CsNotice::getPinned)
            .orderByDesc(CsNotice::getCreateTime));
        Set<Long> readIds = new HashSet<>(noticeReadMapper.selectReadNoticeIds(userId));
        return notices.stream().map(n -> {
            Map<String, Object> m = new LinkedHashMap<>();
            m.put("noticeId", n.getNoticeId());
            m.put("noticeType", n.getNoticeType());
            m.put("title", n.getTitle());
            m.put("content", n.getContent());
            m.put("pinned", n.getPinned());
            m.put("scope", n.getScope());
            m.put("restoreTime", n.getRestoreTime());
            m.put("createTime", n.getCreateTime());
            m.put("read", readIds.contains(n.getNoticeId()));
            return m;
        }).collect(Collectors.toList());
    }

    public Map<String, Object> noticeDetail(Long noticeId) {
        CsNotice n = noticeMapper.selectById(noticeId);
        if (n == null) throw new ServiceException("公告不存在");
        noticeReadMapper.markRead(noticeId, currentUserId());
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("noticeId", n.getNoticeId());
        m.put("noticeType", n.getNoticeType());
        m.put("title", n.getTitle());
        m.put("content", n.getContent());
        m.put("pinned", n.getPinned());
        m.put("scope", n.getScope());
        m.put("restoreTime", n.getRestoreTime());
        m.put("createTime", n.getCreateTime());
        m.put("read", true);
        return m;
    }

    public void markNoticeRead(Long noticeId) {
        noticeReadMapper.markRead(noticeId, currentUserId());
    }

    public Map<String, Object> residentProfile() {
        Long userId = currentUserId();
        CmResident r = residentMapper.selectOne(new LambdaQueryWrapper<CmResident>()
            .eq(CmResident::getUserId, userId)
            .eq(CmResident::getDelFlag, "0")
            .last("LIMIT 1"));
        SysUser user = userMapper.selectById(userId);
        Map<String, Object> vo = new LinkedHashMap<>();
        if (r != null) {
            vo.put("name", r.getName());
            vo.put("phone", r.getPhone());
            vo.put("emergencyContact", r.getEmergencyContact());
            vo.put("houseId", r.getHouseId());
            CmHouse house = houseMapper.selectById(r.getHouseId());
            if (house != null) {
                vo.put("houseNo", house.getHouseNo());
                CmBuilding b = buildingMapper.selectById(house.getBuildingId());
                vo.put("buildingNo", b != null ? b.getBuildingNo() : "");
            }
        } else if (user != null) {
            vo.put("name", user.getNickName());
            vo.put("phone", user.getPhone());
            vo.put("houseId", user.getHouseId());
        }
        return vo;
    }

    public void updateEmergencyContact(String emergencyContact) {
        Long userId = currentUserId();
        CmResident r = residentMapper.selectOne(new LambdaQueryWrapper<CmResident>()
            .eq(CmResident::getUserId, userId)
            .eq(CmResident::getDelFlag, "0")
            .last("LIMIT 1"));
        if (r == null) throw new ServiceException("未找到住户档案，请联系物业登记");
        r.setEmergencyContact(emergencyContact);
        residentMapper.updateById(r);
    }
}
