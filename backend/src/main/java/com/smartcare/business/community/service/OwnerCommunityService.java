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
import com.smartcare.business.property.service.ResidentCareTagService;
import com.smartcare.common.core.page.TableDataInfo;
import com.smartcare.common.exception.ServiceException;
import com.smartcare.framework.security.SecurityUtils;
import com.smartcare.system.domain.SysUser;
import com.smartcare.system.service.UserAccountService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;
import java.util.*;

@Service
@RequiredArgsConstructor
public class OwnerCommunityService {

    private final CsNoticeMapper noticeMapper;
    private final CsNoticeReadMapper noticeReadMapper;
    private final CmResidentMapper residentMapper;
    private final CmHouseMapper houseMapper;
    private final CmBuildingMapper buildingMapper;
    private final UserAccountService accountService;
    private final ResidentCareTagService careTagService;

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
        SysUser user = accountService.findById(userId);
        Map<String, Object> vo = new LinkedHashMap<>();
        if (r != null) {
            vo.put("name", r.getName());
            vo.put("gender", r.getGender());
            vo.put("age", r.getAge());
            vo.put("phone", r.getPhone());
            vo.put("livingStatus", StringUtils.hasText(r.getLivingStatus()) ? r.getLivingStatus() : "1");
            vo.put("livingStatusLabel", livingStatusLabel(r.getLivingStatus()));
            vo.put("isOwner", r.getIsOwner() != null ? r.getIsOwner() : 1);
            vo.put("ownerName", r.getOwnerName());
            vo.put("ownerPhone", r.getOwnerPhone());
            vo.put("ownerRelation", r.getOwnerRelation());
            vo.put("emergencyName", r.getEmergencyName());
            vo.put("emergencyPhone", r.getEmergencyPhone());
            vo.put("emergencyRelation", r.getEmergencyRelation());
            vo.put("emergencyContact", formatEmergency(r));
            vo.put("remark", r.getRemark());
            vo.put("moveInDate", r.getMoveInDate());
            vo.put("residentType", r.getResidentType());
            vo.put("residentTypeLabel", r.getIsOwner() != null && r.getIsOwner() == 0 ? "非产权住户" : "产权人");
            vo.put("houseId", r.getHouseId());
            vo.put("archiveTime", r.getCreateTime());
            vo.put("careTags", careTagService.computeAllDisplayTags(r));
            vo.put("elderCareTarget", careTagService.isAiMonitorTarget(r));
            if (r.getMoveInDate() != null) {
                vo.put("stayDays", ChronoUnit.DAYS.between(r.getMoveInDate(), LocalDate.now()));
            }
            CmHouse house = houseMapper.selectById(r.getHouseId());
            if (house != null) {
                vo.put("houseNo", house.getHouseNo());
                vo.put("houseArea", house.getArea());
                vo.put("houseLayout", house.getLayout());
                vo.put("houseRemark", house.getRemark());
                CmBuilding b = buildingMapper.selectById(house.getBuildingId());
                vo.put("buildingNo", b != null ? b.getBuildingNo() : "");
            }
        } else if (user != null) {
            vo.put("name", user.getNickName());
            vo.put("phone", user.getPhone());
            vo.put("houseId", user.getHouseId());
            if (user.getHouseId() != null) {
                CmHouse house = houseMapper.selectById(user.getHouseId());
                if (house != null) {
                    vo.put("houseNo", house.getHouseNo());
                    vo.put("houseArea", house.getArea());
                    vo.put("houseLayout", house.getLayout());
                    CmBuilding b = buildingMapper.selectById(house.getBuildingId());
                    vo.put("buildingNo", b != null ? b.getBuildingNo() : "");
                }
            }
        }
        if (user != null) {
            vo.put("username", user.getUsername());
        }
        return vo;
    }

    public void updateEmergencyContact(String emergencyName, String emergencyPhone, String emergencyRelation) {
        Long userId = currentUserId();
        CmResident r = residentMapper.selectOne(new LambdaQueryWrapper<CmResident>()
            .eq(CmResident::getUserId, userId)
            .eq(CmResident::getDelFlag, "0")
            .last("LIMIT 1"));
        if (r == null) throw new ServiceException("未找到住户档案，请联系物业登记");
        if (StringUtils.hasText(emergencyName) || StringUtils.hasText(emergencyPhone)) {
            if (!StringUtils.hasText(emergencyName)) throw new ServiceException("请填写紧急联系人姓名");
            if (!StringUtils.hasText(emergencyPhone) || !emergencyPhone.matches("^1\\d{10}$")) {
                throw new ServiceException("请填写正确的紧急联系人电话");
            }
            if (!StringUtils.hasText(emergencyRelation)) throw new ServiceException("请选择与您的关系");
        }
        r.setEmergencyName(emergencyName != null ? emergencyName : "");
        r.setEmergencyPhone(emergencyPhone != null ? emergencyPhone : "");
        r.setEmergencyRelation(emergencyRelation != null ? emergencyRelation : "");
        r.setEmergencyContact(formatEmergency(r));
        residentMapper.updateById(r);
    }

    private String livingStatusLabel(String status) {
        if ("2".equals(status)) return "空置";
        if ("3".equals(status)) return "出租";
        return "在住";
    }

    private String formatEmergency(CmResident r) {
        if (StringUtils.hasText(r.getEmergencyName()) || StringUtils.hasText(r.getEmergencyPhone())) {
            String rel = StringUtils.hasText(r.getEmergencyRelation()) ? "（" + r.getEmergencyRelation() + "）" : "";
            return r.getEmergencyName() + rel + (StringUtils.hasText(r.getEmergencyPhone()) ? " " + r.getEmergencyPhone() : "");
        }
        return r.getEmergencyContact();
    }
}
