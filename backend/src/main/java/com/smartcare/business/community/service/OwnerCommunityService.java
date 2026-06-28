package com.smartcare.business.community.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.smartcare.business.community.domain.CsNotice;
import com.smartcare.business.community.mapper.CsNoticeMapper;
import com.smartcare.business.community.mapper.CsNoticeReadMapper;
import com.smartcare.business.property.domain.CmBuilding;
import com.smartcare.business.property.domain.CmHouse;
import com.smartcare.business.property.domain.CmResident;
import com.smartcare.business.property.mapper.CmBuildingMapper;
import com.smartcare.business.property.mapper.CmHouseMapper;
import com.smartcare.business.property.mapper.CmResidentMapper;
import com.smartcare.common.core.page.TableDataInfo;
import com.smartcare.common.exception.ServiceException;
import com.smartcare.framework.security.SecurityUtils;
import com.smartcare.system.domain.SysUser;
import com.smartcare.system.mapper.SysUserMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.time.LocalDateTime;
import java.util.*;

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

    public TableDataInfo noticeList(int pageNum, int pageSize, String noticeType, String title,
                                    LocalDateTime publishTimeStart, LocalDateTime publishTimeEnd,
                                    String readStatus) {
        Long userId = currentUserId();
        Page<Map<String, Object>> page = new Page<>(pageNum, pageSize);
        noticeMapper.selectOwnerNoticePage(page, userId, noticeType,
            StringUtils.hasText(title) ? title.trim() : null,
            publishTimeStart, publishTimeEnd,
            StringUtils.hasText(readStatus) ? readStatus : null);
        List<Map<String, Object>> rows = new ArrayList<>();
        for (Map<String, Object> record : page.getRecords()) {
            Map<String, Object> row = new LinkedHashMap<>(record);
            row.put("read", toReadFlag(row.remove("readFlag")));
            rows.add(row);
        }
        return new TableDataInfo(page.getTotal(), rows);
    }

    public Map<String, Object> noticeDetail(Long noticeId) {
        CsNotice n = noticeMapper.selectById(noticeId);
        if (n == null || !"1".equals(n.getStatus())
            || n.getCreateTime() == null || n.getCreateTime().isAfter(LocalDateTime.now())) {
            throw new ServiceException("公告不存在或未发布");
        }
        noticeReadMapper.markRead(noticeId, currentUserId());
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("noticeId", n.getNoticeId());
        m.put("noticeType", n.getNoticeType());
        m.put("title", n.getTitle());
        m.put("content", n.getContent());
        m.put("attachment", n.getAttachment());
        m.put("scope", n.getScope());
        m.put("restoreTime", n.getRestoreTime());
        m.put("createTime", n.getCreateTime());
        m.put("read", true);
        return m;
    }

    public void markNoticeRead(Long noticeId) {
        noticeReadMapper.markRead(noticeId, currentUserId());
    }

    private boolean toReadFlag(Object flag) {
        if (flag instanceof Number num) {
            return num.intValue() == 1;
        }
        if (flag instanceof Boolean bool) {
            return bool;
        }
        return false;
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
