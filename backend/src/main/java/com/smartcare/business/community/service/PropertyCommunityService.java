package com.smartcare.business.community.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.smartcare.business.community.domain.*;
import com.smartcare.business.community.mapper.*;
import com.smartcare.common.core.page.TableDataInfo;
import com.smartcare.common.exception.ServiceException;
import com.smartcare.framework.security.SecurityUtils;
import com.smartcare.system.domain.SysMessage;
import com.smartcare.system.domain.SysUser;
import com.smartcare.system.mapper.SysUserMapper;
import com.smartcare.system.service.SysMessageService;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.io.PrintWriter;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class PropertyCommunityService {

    private final CsNoticeMapper noticeMapper;
    private final CsNoticeReadMapper noticeReadMapper;
    private final CsActivityMapper activityMapper;
    private final CsActivityRegMapper regMapper;
    private final CsComplaintMapper complaintMapper;
    private final CsComplaintLogMapper complaintLogMapper;
    private final CsForumPostMapper postMapper;
    private final CsForumCommentMapper commentMapper;
    private final SysUserMapper userMapper;
    private final SysMessageService messageService;

    private Long operatorId() {
        Long id = SecurityUtils.getUserId();
        if (id == null) throw new ServiceException("未登录");
        return id;
    }

    // ---------- 公告/通知 ----------
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

    // ---------- 活动 ----------
    public List<CsActivity> activityManageList() {
        return activityMapper.selectList(new LambdaQueryWrapper<CsActivity>()
            .orderByDesc(CsActivity::getCreateTime));
    }

    public void publishActivity(CsActivity activity) {
        if (!StringUtils.hasText(activity.getStatus())) activity.setStatus("1");
        activityMapper.insert(activity);
    }

    public void updateActivity(CsActivity activity) {
        activityMapper.updateById(activity);
    }

    public void offlineActivity(Long activityId) {
        CsActivity a = new CsActivity();
        a.setActivityId(activityId);
        a.setStatus("0");
        activityMapper.updateById(a);
    }

    public List<CsActivityReg> activityRegList(Long activityId) {
        return regMapper.selectList(new LambdaQueryWrapper<CsActivityReg>()
            .eq(CsActivityReg::getActivityId, activityId)
            .ne(CsActivityReg::getStatus, "cancelled")
            .orderByDesc(CsActivityReg::getCreateTime));
    }

    public void exportActivityRegs(Long activityId, HttpServletResponse response) throws Exception {
        CsActivity act = activityMapper.selectById(activityId);
        String filename = URLEncoder.encode("活动报名_" + (act != null ? act.getTitle() : activityId) + ".csv",
            StandardCharsets.UTF_8).replace("+", "%20");
        response.setContentType("text/csv;charset=UTF-8");
        response.setHeader("Content-Disposition", "attachment;filename*=UTF-8''" + filename);
        response.getOutputStream().write(new byte[]{(byte) 0xEF, (byte) 0xBB, (byte) 0xBF});
        PrintWriter w = new PrintWriter(response.getOutputStream(), true, StandardCharsets.UTF_8);
        w.println("姓名,房号,手机号,报名时间");
        for (CsActivityReg r : activityRegList(activityId)) {
            w.printf("%s,%s,%s,%s%n",
                esc(r.getName()), esc(r.getHouseNo()), esc(r.getPhone()),
                r.getCreateTime() != null ? r.getCreateTime() : "");
        }
        w.flush();
    }

    private String esc(String s) {
        if (s == null) return "";
        if (s.contains(",") || s.contains("\"")) return "\"" + s.replace("\"", "\"\"") + "\"";
        return s;
    }

    // ---------- 投诉 ----------
    public TableDataInfo complaintList(int pageNum, int pageSize, String status, String category,
                                       LocalDateTime start, LocalDateTime end) {
        LambdaQueryWrapper<CsComplaint> qw = new LambdaQueryWrapper<CsComplaint>()
            .eq(StringUtils.hasText(status), CsComplaint::getStatus, status)
            .eq(StringUtils.hasText(category), CsComplaint::getCategory, category)
            .ge(start != null, CsComplaint::getCreateTime, start)
            .le(end != null, CsComplaint::getCreateTime, end)
            .orderByAsc(CsComplaint::getStatus)
            .orderByDesc(CsComplaint::getCreateTime);
        Page<CsComplaint> page = complaintMapper.selectPage(new Page<>(pageNum, pageSize), qw);
        List<Map<String, Object>> rows = page.getRecords().stream().map(this::complaintBrief).collect(Collectors.toList());
        return new TableDataInfo(page.getTotal(), rows);
    }

    public Map<String, Object> complaintDetail(Long complaintId) {
        CsComplaint c = complaintMapper.selectById(complaintId);
        if (c == null) throw new ServiceException("工单不存在");
        Map<String, Object> vo = complaintBrief(c);
        vo.put("content", c.getContent());
        vo.put("images", c.getImages());
        vo.put("anonymous", c.getAnonymous());
        vo.put("reply", c.getReply());
        vo.put("replyTime", c.getReplyTime());
        List<CsComplaintLog> logs = complaintLogMapper.selectList(new LambdaQueryWrapper<CsComplaintLog>()
            .eq(CsComplaintLog::getComplaintId, complaintId)
            .orderByAsc(CsComplaintLog::getCreateTime));
        List<Map<String, Object>> logVos = logs.stream().map(log -> {
            Map<String, Object> m = new LinkedHashMap<>();
            m.put("logId", log.getLogId());
            m.put("action", log.getAction());
            m.put("content", log.getContent());
            m.put("createTime", log.getCreateTime());
            SysUser h = log.getHandlerId() != null ? userMapper.selectById(log.getHandlerId()) : null;
            m.put("handlerName", h != null ? h.getNickName() : "");
            return m;
        }).collect(Collectors.toList());
        vo.put("logs", logVos);
        return vo;
    }

    @Transactional
    public void acceptComplaint(Long complaintId, Long handlerId) {
        CsComplaint c = complaintMapper.selectById(complaintId);
        if (c == null) throw new ServiceException("工单不存在");
        Long hid = handlerId != null ? handlerId : operatorId();
        CsComplaint upd = new CsComplaint();
        upd.setComplaintId(complaintId);
        upd.setStatus("processing");
        upd.setHandlerId(hid);
        complaintMapper.updateById(upd);
        addLog(complaintId, "accept", hid, "已受理，指派负责人处理");
    }

    @Transactional
    public void replyComplaint(Long complaintId, String reply) {
        CsComplaint c = complaintMapper.selectById(complaintId);
        if (c == null) throw new ServiceException("工单不存在");
        Long hid = operatorId();
        CsComplaint upd = new CsComplaint();
        upd.setComplaintId(complaintId);
        upd.setReply(reply);
        upd.setReplyTime(LocalDateTime.now());
        upd.setStatus("replied");
        upd.setHandlerId(hid);
        complaintMapper.updateById(upd);
        addLog(complaintId, "reply", hid, reply);
        notifyOwner(c.getUserId(), "投诉建议已回复", "您的投诉【" + c.getTitle() + "】已回复：" + reply);
    }

    private void addLog(Long complaintId, String action, Long handlerId, String content) {
        CsComplaintLog log = new CsComplaintLog();
        log.setComplaintId(complaintId);
        log.setAction(action);
        log.setHandlerId(handlerId);
        log.setContent(content);
        complaintLogMapper.insert(log);
    }

    private void notifyOwner(Long userId, String title, String content) {
        if (userId == null) return;
        SysMessage msg = new SysMessage();
        msg.setTitle(title);
        msg.setContent(content);
        msg.setMsgType("notice");
        msg.setPriority("1");
        msg.setSenderId(operatorId());
        messageService.send(msg, List.of(userId));
    }

    public List<Map<String, Object>> complaintStats(LocalDateTime start, LocalDateTime end) {
        LambdaQueryWrapper<CsComplaint> qw = new LambdaQueryWrapper<CsComplaint>()
            .ge(start != null, CsComplaint::getCreateTime, start)
            .le(end != null, CsComplaint::getCreateTime, end);
        List<CsComplaint> list = complaintMapper.selectList(qw);
        Map<String, Long> byCategory = list.stream().collect(Collectors.groupingBy(
            c -> StringUtils.hasText(c.getCategory()) ? c.getCategory() : "other",
            Collectors.counting()));
        Map<String, Long> byStatus = list.stream().collect(Collectors.groupingBy(
            c -> StringUtils.hasText(c.getStatus()) ? c.getStatus() : "pending",
            Collectors.counting()));
        List<Map<String, Object>> result = new ArrayList<>();
        byCategory.forEach((k, v) -> {
            Map<String, Object> m = new LinkedHashMap<>();
            m.put("dimension", "category");
            m.put("name", k);
            m.put("count", v);
            result.add(m);
        });
        byStatus.forEach((k, v) -> {
            Map<String, Object> m = new LinkedHashMap<>();
            m.put("dimension", "status");
            m.put("name", k);
            m.put("count", v);
            result.add(m);
        });
        return result;
    }

    private Map<String, Object> complaintBrief(CsComplaint c) {
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("complaintId", c.getComplaintId());
        m.put("complaintNo", c.getComplaintNo());
        m.put("title", c.getTitle());
        m.put("category", c.getCategory());
        m.put("status", c.getStatus());
        m.put("handlerId", c.getHandlerId());
        m.put("createTime", c.getCreateTime());
        if (c.getHandlerId() != null) {
            SysUser h = userMapper.selectById(c.getHandlerId());
            m.put("handlerName", h != null ? h.getNickName() : "");
        } else {
            m.put("handlerName", "");
        }
        SysUser submitter = userMapper.selectById(c.getUserId());
        m.put("submitterName", submitter != null ? submitter.getNickName() : "");
        return m;
    }

    // ---------- 论坛审核 ----------
    public List<CsForumPost> pendingPosts() {
        return postMapper.selectList(new LambdaQueryWrapper<CsForumPost>()
            .in(CsForumPost::getAuditStatus, "0", "2")
            .orderByDesc(CsForumPost::getCreateTime));
    }

    public List<CsForumComment> pendingComments() {
        return commentMapper.selectList(new LambdaQueryWrapper<CsForumComment>()
            .eq(CsForumComment::getAuditStatus, "0")
            .orderByDesc(CsForumComment::getCreateTime));
    }

    public void auditPost(Long postId, String auditStatus) {
        CsForumPost p = new CsForumPost();
        p.setPostId(postId);
        p.setAuditStatus(auditStatus);
        postMapper.updateById(p);
    }

    public void auditComment(Long commentId, String auditStatus) {
        CsForumComment c = new CsForumComment();
        c.setCommentId(commentId);
        c.setAuditStatus(auditStatus);
        commentMapper.updateById(c);
    }

    public void deletePost(Long postId) {
        commentMapper.delete(new LambdaQueryWrapper<CsForumComment>().eq(CsForumComment::getPostId, postId));
        postMapper.deleteById(postId);
    }

    public void deleteComment(Long commentId) {
        commentMapper.deleteById(commentId);
    }

    public String nextComplaintNo() {
        return "CP" + LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMddHHmmss"))
            + String.format("%03d", new Random().nextInt(1000));
    }
}
