package com.smartcare.business.community.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.smartcare.business.community.domain.CsNotice;
import com.smartcare.business.community.mapper.CsNoticeMapper;
import com.smartcare.business.community.mapper.CsNoticeReadMapper;
import com.smartcare.business.ai.service.KbLearnService;
import com.smartcare.common.core.page.TableDataInfo;
import com.smartcare.common.exception.ServiceException;
import com.smartcare.framework.security.SecurityUtils;
import com.smartcare.system.domain.SysUser;
import com.smartcare.system.service.UserAccountService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.time.LocalDateTime;
import java.util.*;

@Service
@RequiredArgsConstructor
public class PropertyCommunityService {

    private final CsNoticeMapper noticeMapper;
    private final CsNoticeReadMapper noticeReadMapper;
    private final UserAccountService accountService;
    private final NoticePublishScheduler publishScheduler;
    private final KbLearnService kbLearnService;

    private Long operatorId() {
        Long id = SecurityUtils.getUserId();
        if (id == null) throw new ServiceException("未登录");
        return id;
    }

    public TableDataInfo noticeManageList(int pageNum, int pageSize, String noticeType, String status,
                                          String title, LocalDateTime publishTimeStart,
                                          LocalDateTime publishTimeEnd) {
        publishScheduler.processScheduledTasks();
        Page<CsNotice> page = noticeMapper.selectPage(new Page<>(pageNum, pageSize),
            listQueryWrapper(noticeType, status, title, publishTimeStart, publishTimeEnd));
        return new TableDataInfo(page.getTotal(), page.getRecords());
    }

    public void publishNotice(CsNotice notice) {
        notice.setCreateBy(operatorId());
        validateNoticeTimes(notice, null);
        applyPublishStatus(notice);
        noticeMapper.insert(notice);
        if ("1".equals(notice.getStatus())) {
            kbLearnService.onNoticePublished(notice.getNoticeId());
        }
    }

    public void updateNotice(CsNotice notice) {
        if (notice.getNoticeId() == null) throw new ServiceException("公告ID不能为空");
        CsNotice existing = noticeMapper.selectById(notice.getNoticeId());
        if (existing == null) throw new ServiceException("公告不存在");
        if ("0".equals(existing.getStatus())) {
            throw new ServiceException("已下架的公告不支持编辑");
        }
        validateNoticeTimes(notice, existing);
        applyPublishStatus(notice);
        noticeMapper.updateById(notice);
    }

    public void offlineNotice(Long noticeId) {
        noticeMapper.update(null, new LambdaUpdateWrapper<CsNotice>()
            .set(CsNotice::getStatus, "0")
            .set(CsNotice::getPinned, 0)
            .eq(CsNotice::getNoticeId, noticeId));
    }

    public Map<String, Object> noticeReadStats(Long noticeId) {
        List<SysUser> owners = accountService.listByUserType("0");
        List<Long> readIds = noticeReadMapper.selectReadUserIdsByNotice(noticeId);
        Set<Long> readSet = new HashSet<>(readIds);
        List<Map<String, Object>> readList = new ArrayList<>();
        List<Map<String, Object>> unreadList = new ArrayList<>();
        for (SysUser u : owners) {
            Map<String, Object> item = new LinkedHashMap<>();
            item.put("userId", u.getUserId());
            item.put("nickName", u.getNickName());
            item.put("phone", u.getPhone());
            if (readSet.contains(u.getUserId())) readList.add(item);
            else unreadList.add(item);
        }
        int total = owners.size();
        Map<String, Object> vo = new LinkedHashMap<>();
        vo.put("totalOwners", total);
        vo.put("readCount", readList.size());
        vo.put("unreadCount", unreadList.size());
        vo.put("readRate", total == 0 ? 0 : Math.round(readList.size() * 1000.0 / total) / 10.0);
        vo.put("readList", readList);
        vo.put("unreadList", unreadList);
        return vo;
    }

    public void forceNoticeRead(Long noticeId, Long userId) {
        noticeReadMapper.markRead(noticeId, userId);
    }

    private LambdaQueryWrapper<CsNotice> listQueryWrapper(String noticeType, String status, String title,
                                                          LocalDateTime publishTimeStart,
                                                          LocalDateTime publishTimeEnd) {
        return new LambdaQueryWrapper<CsNotice>()
            .select(CsNotice::getNoticeId, CsNotice::getNoticeType, CsNotice::getTitle,
                CsNotice::getContent, CsNotice::getAttachment, CsNotice::getPinned, CsNotice::getScope,
                CsNotice::getRestoreTime, CsNotice::getOfflineTime, CsNotice::getStatus,
                CsNotice::getCreateBy, CsNotice::getCreateTime, CsNotice::getUpdateTime)
            .eq(StringUtils.hasText(noticeType), CsNotice::getNoticeType, noticeType)
            .eq(StringUtils.hasText(status), CsNotice::getStatus, status)
            .like(StringUtils.hasText(title), CsNotice::getTitle, title)
            .ge(publishTimeStart != null, CsNotice::getCreateTime, publishTimeStart)
            .le(publishTimeEnd != null, CsNotice::getCreateTime, publishTimeEnd)
            .orderByDesc(CsNotice::getPinned)
            .orderByDesc(CsNotice::getCreateTime);
    }

    private void validateNoticeTimes(CsNotice notice, CsNotice existing) {
        LocalDateTime now = LocalDateTime.now();
        LocalDateTime publishTime = notice.getCreateTime();
        if (publishTime == null) {
            publishTime = now;
            notice.setCreateTime(publishTime);
        }
        if (existing == null) {
            if (publishTime.isBefore(now.minusSeconds(1))) {
                throw new ServiceException("发布时间不能早于当前时间");
            }
        } else if (existing.getCreateTime() != null && publishTime.isBefore(existing.getCreateTime())) {
            throw new ServiceException("发布时间不能早于原发布时间");
        }
        if ("outage".equals(notice.getNoticeType()) && notice.getRestoreTime() != null) {
            if (notice.getRestoreTime().isBefore(now)) {
                throw new ServiceException("预计恢复时间不能早于当前时间");
            }
            if (notice.getRestoreTime().isBefore(publishTime)) {
                throw new ServiceException("预计恢复时间不能早于发布时间");
            }
        }
        if (notice.getOfflineTime() != null) {
            if (notice.getOfflineTime().isBefore(now.minusSeconds(1))) {
                throw new ServiceException("下架时间不能早于当前时间");
            }
            if (notice.getOfflineTime().isBefore(publishTime)) {
                throw new ServiceException("下架时间不能早于发布时间");
            }
            if ("outage".equals(notice.getNoticeType()) && notice.getRestoreTime() != null
                && notice.getOfflineTime().isBefore(notice.getRestoreTime())) {
                throw new ServiceException("下架时间不能早于预计恢复时间");
            }
        }
    }

    /** status: 0下架 1已发布 2待发布（定时） */
    private void applyPublishStatus(CsNotice notice) {
        if (notice.getCreateTime().isAfter(LocalDateTime.now())) {
            notice.setStatus("2");
        } else {
            notice.setStatus("1");
        }
    }
}
