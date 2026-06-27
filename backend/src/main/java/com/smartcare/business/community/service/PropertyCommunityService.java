package com.smartcare.business.community.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.smartcare.business.community.domain.CsNotice;
import com.smartcare.business.community.mapper.CsNoticeMapper;
import com.smartcare.business.community.mapper.CsNoticeReadMapper;
import com.smartcare.common.core.page.TableDataInfo;
import com.smartcare.common.exception.ServiceException;
import com.smartcare.framework.security.SecurityUtils;
import com.smartcare.system.domain.SysUser;
import com.smartcare.system.mapper.SysUserMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.util.*;

@Service
@RequiredArgsConstructor
public class PropertyCommunityService {

    private final CsNoticeMapper noticeMapper;
    private final CsNoticeReadMapper noticeReadMapper;
    private final SysUserMapper userMapper;

    private Long operatorId() {
        Long id = SecurityUtils.getUserId();
        if (id == null) throw new ServiceException("未登录");
        return id;
    }

    public TableDataInfo noticeManageList(int pageNum, int pageSize, String noticeType, String status) {
        Page<CsNotice> page = noticeMapper.selectPage(new Page<>(pageNum, pageSize),
            new LambdaQueryWrapper<CsNotice>()
                .eq(StringUtils.hasText(noticeType), CsNotice::getNoticeType, noticeType)
                .eq(StringUtils.hasText(status), CsNotice::getStatus, status)
                .orderByDesc(CsNotice::getPinned)
                .orderByDesc(CsNotice::getCreateTime));
        return new TableDataInfo(page.getTotal(), page.getRecords());
    }

    public void publishNotice(CsNotice notice) {
        notice.setCreateBy(operatorId());
        notice.setStatus("1");
        noticeMapper.insert(notice);
    }

    public void updateNotice(CsNotice notice) {
        noticeMapper.updateById(notice);
    }

    public void offlineNotice(Long noticeId) {
        CsNotice n = new CsNotice();
        n.setNoticeId(noticeId);
        n.setStatus("0");
        noticeMapper.updateById(n);
    }

    public Map<String, Object> noticeReadStats(Long noticeId) {
        List<SysUser> owners = userMapper.selectList(new LambdaQueryWrapper<SysUser>()
            .eq(SysUser::getUserType, "0")
            .eq(SysUser::getDelFlag, "0"));
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
}
