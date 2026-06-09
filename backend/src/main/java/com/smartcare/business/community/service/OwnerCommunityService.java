package com.smartcare.business.community.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.smartcare.business.community.domain.*;
import com.smartcare.business.community.mapper.*;
import com.smartcare.business.elder.domain.ElAlert;
import com.smartcare.business.elder.mapper.ElAlertMapper;
import com.smartcare.business.finance.domain.FnBill;
import com.smartcare.business.finance.domain.FnFeeItem;
import com.smartcare.business.finance.domain.FnPayment;
import com.smartcare.business.finance.mapper.FnBillMapper;
import com.smartcare.business.finance.mapper.FnFeeItemMapper;
import com.smartcare.business.finance.mapper.FnPaymentMapper;
import com.smartcare.business.property.domain.CmHouse;
import com.smartcare.business.property.domain.CmResident;
import com.smartcare.business.property.mapper.CmHouseMapper;
import com.smartcare.business.property.mapper.CmResidentMapper;
import com.smartcare.business.property.mapper.CmBuildingMapper;
import com.smartcare.business.property.domain.CmBuilding;
import com.smartcare.common.exception.ServiceException;
import com.smartcare.framework.security.SecurityUtils;
import com.smartcare.system.domain.SysUser;
import com.smartcare.system.mapper.SysUserMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class OwnerCommunityService {

    private final CsActivityMapper activityMapper;
    private final CsActivityRegMapper regMapper;
    private final CsFamilyBindMapper familyBindMapper;
    private final CsVisitorMapper visitorMapper;
    private final CsForumPostMapper postMapper;
    private final CsForumCommentMapper commentMapper;
    private final CsVenueMapper venueMapper;
    private final CsVenueBookingMapper bookingMapper;
    private final CsVoteMapper voteMapper;
    private final CsVoteRecordMapper voteRecordMapper;
    private final CsNoticeMapper noticeMapper;
    private final CsNoticeReadMapper noticeReadMapper;
    private final CsComplaintMapper complaintMapper;
    private final CmResidentMapper residentMapper;
    private final CmHouseMapper houseMapper;
    private final CmBuildingMapper buildingMapper;
    private final FnBillMapper billMapper;
    private final FnFeeItemMapper feeItemMapper;
    private final FnPaymentMapper paymentMapper;
    private final ElAlertMapper alertMapper;
    private final SysUserMapper userMapper;

    private Long currentUserId() {
        Long id = SecurityUtils.getUserId();
        if (id == null) throw new ServiceException("未登录");
        return id;
    }

    // ---------- 公告 ----------
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

    // ---------- 活动 ----------
    public List<Map<String, Object>> activityList() {
        List<CsActivity> list = activityMapper.selectList(new LambdaQueryWrapper<CsActivity>()
            .eq(CsActivity::getStatus, "1")
            .orderByDesc(CsActivity::getStartTime));
        return list.stream().map(this::activityVo).collect(Collectors.toList());
    }

    public Map<String, Object> activityDetail(Long activityId) {
        CsActivity a = activityMapper.selectById(activityId);
        if (a == null) throw new ServiceException("活动不存在");
        return activityVo(a);
    }

    private Map<String, Object> activityVo(CsActivity a) {
        long regCount = regMapper.selectCount(new LambdaQueryWrapper<CsActivityReg>()
            .eq(CsActivityReg::getActivityId, a.getActivityId())
            .ne(CsActivityReg::getStatus, "cancelled"));
        int remain = a.getMaxCount() != null && a.getMaxCount() > 0
            ? Math.max(0, a.getMaxCount() - (int) regCount) : -1;
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("activityId", a.getActivityId());
        m.put("title", a.getTitle());
        m.put("content", a.getContent());
        m.put("location", a.getLocation());
        m.put("startTime", a.getStartTime());
        m.put("deadline", a.getDeadline());
        m.put("maxCount", a.getMaxCount());
        m.put("regCount", regCount);
        m.put("remainCount", remain);
        return m;
    }

    @Transactional
    public Map<String, Object> registerActivity(CsActivityReg reg) {
        CsActivity a = activityMapper.selectById(reg.getActivityId());
        if (a == null || !"1".equals(a.getStatus())) throw new ServiceException("活动不可用");
        if (a.getDeadline() != null && LocalDateTime.now().isAfter(a.getDeadline())) {
            throw new ServiceException("报名已截止");
        }
        if (a.getStartTime() != null && LocalDateTime.now().isAfter(a.getStartTime())) {
            throw new ServiceException("活动已开始，无法报名");
        }
        long exists = regMapper.selectCount(new LambdaQueryWrapper<CsActivityReg>()
            .eq(CsActivityReg::getActivityId, reg.getActivityId())
            .eq(CsActivityReg::getUserId, currentUserId())
            .ne(CsActivityReg::getStatus, "cancelled"));
        if (exists > 0) throw new ServiceException("您已报名该活动");
        long regCount = regMapper.selectCount(new LambdaQueryWrapper<CsActivityReg>()
            .eq(CsActivityReg::getActivityId, reg.getActivityId())
            .ne(CsActivityReg::getStatus, "cancelled"));
        if (a.getMaxCount() != null && a.getMaxCount() > 0 && regCount >= a.getMaxCount()) {
            throw new ServiceException("名额已满");
        }
        reg.setUserId(currentUserId());
        reg.setStatus("pending");
        reg.setVoucherNo("ACT" + LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMddHHmmss"))
            + String.format("%04d", new Random().nextInt(10000)));
        regMapper.insert(reg);
        Map<String, Object> vo = new LinkedHashMap<>();
        vo.put("regId", reg.getRegId());
        vo.put("voucherNo", reg.getVoucherNo());
        return vo;
    }

    public List<CsActivityReg> myActivityRegs() {
        return regMapper.selectList(new LambdaQueryWrapper<CsActivityReg>()
            .eq(CsActivityReg::getUserId, currentUserId())
            .orderByDesc(CsActivityReg::getCreateTime));
    }

    @Transactional
    public void cancelActivityReg(Long regId) {
        CsActivityReg reg = regMapper.selectById(regId);
        if (reg == null || !reg.getUserId().equals(currentUserId())) throw new ServiceException("记录不存在");
        CsActivity a = activityMapper.selectById(reg.getActivityId());
        if (a == null) throw new ServiceException("活动不存在");
        if (a.getDeadline() != null && LocalDateTime.now().isAfter(a.getDeadline())) {
            throw new ServiceException("已过报名截止时间");
        }
        if (a.getStartTime() != null && LocalDateTime.now().isAfter(a.getStartTime())) {
            throw new ServiceException("活动已开始，无法取消");
        }
        reg.setStatus("cancelled");
        regMapper.updateById(reg);
    }

    // ---------- 亲情绑定 ----------
    public List<CsFamilyBind> familyList() {
        return familyBindMapper.selectList(new LambdaQueryWrapper<CsFamilyBind>()
            .eq(CsFamilyBind::getOwnerId, currentUserId())
            .orderByDesc(CsFamilyBind::getCreateTime));
    }

    public void addFamily(CsFamilyBind bind) {
        bind.setOwnerId(currentUserId());
        if (bind.getShareOrder() == null) bind.setShareOrder(1);
        if (bind.getShareAlert() == null) bind.setShareAlert(0);
        familyBindMapper.insert(bind);
    }

    public void updateFamilyAlert(Long bindId, Integer shareAlert) {
        CsFamilyBind bind = familyBindMapper.selectById(bindId);
        if (bind == null || !bind.getOwnerId().equals(currentUserId())) throw new ServiceException("记录不存在");
        bind.setShareAlert(shareAlert);
        familyBindMapper.updateById(bind);
    }

    public void removeFamily(Long bindId) {
        CsFamilyBind bind = familyBindMapper.selectById(bindId);
        if (bind == null || !bind.getOwnerId().equals(currentUserId())) throw new ServiceException("记录不存在");
        familyBindMapper.deleteById(bindId);
    }

    public List<ElAlert> sharedAlerts() {
        Long userId = currentUserId();
        SysUser user = userMapper.selectById(userId);
        if (user == null || user.getPhone() == null) return List.of();
        List<CsFamilyBind> binds = familyBindMapper.selectList(new LambdaQueryWrapper<CsFamilyBind>()
            .eq(CsFamilyBind::getFamilyPhone, user.getPhone())
            .eq(CsFamilyBind::getShareAlert, 1));
        if (binds.isEmpty()) return List.of();
        Set<Long> ownerIds = binds.stream().map(CsFamilyBind::getOwnerId).collect(Collectors.toSet());
        List<CmResident> residents = residentMapper.selectList(new LambdaQueryWrapper<CmResident>()
            .in(CmResident::getUserId, ownerIds)
            .eq(CmResident::getDelFlag, "0"));
        if (residents.isEmpty()) return List.of();
        Set<Long> residentIds = residents.stream().map(CmResident::getResidentId).collect(Collectors.toSet());
        return alertMapper.selectList(new LambdaQueryWrapper<ElAlert>()
            .in(ElAlert::getResidentId, residentIds)
            .orderByDesc(ElAlert::getCreateTime));
    }

    // ---------- 访客 ----------
    public CsVisitor addVisitor(CsVisitor v) {
        v.setOwnerId(currentUserId());
        v.setQrcode("VIS:" + UUID.randomUUID().toString().replace("-", ""));
        v.setStatus("1");
        visitorMapper.insert(v);
        return v;
    }

    public List<CsVisitor> visitorList() {
        return visitorMapper.selectList(new LambdaQueryWrapper<CsVisitor>()
            .eq(CsVisitor::getOwnerId, currentUserId())
            .orderByDesc(CsVisitor::getVisitStart));
    }

    public void updateVisitor(CsVisitor v) {
        CsVisitor old = visitorMapper.selectById(v.getVisitorId());
        if (old == null || !old.getOwnerId().equals(currentUserId())) throw new ServiceException("记录不存在");
        if (old.getVisitEnd() != null && LocalDateTime.now().isAfter(old.getVisitEnd())) {
            throw new ServiceException("预约已过期，无法修改");
        }
        v.setOwnerId(old.getOwnerId());
        v.setQrcode(old.getQrcode());
        visitorMapper.updateById(v);
    }

    // ---------- 论坛 ----------
    public Page<CsForumPost> forumPosts(int pageNum, int pageSize) {
        return postMapper.selectPage(new Page<>(pageNum, pageSize),
            new LambdaQueryWrapper<CsForumPost>()
                .eq(CsForumPost::getAuditStatus, "1")
                .orderByDesc(CsForumPost::getCreateTime));
    }

    public void addPost(CsForumPost post) {
        post.setUserId(currentUserId());
        post.setAuditStatus("0");
        postMapper.insert(post);
    }

    public void addComment(CsForumComment comment) {
        comment.setUserId(currentUserId());
        comment.setAuditStatus("1");
        commentMapper.insert(comment);
    }

    public List<CsForumComment> postComments(Long postId) {
        return commentMapper.selectList(new LambdaQueryWrapper<CsForumComment>()
            .eq(CsForumComment::getPostId, postId)
            .eq(CsForumComment::getAuditStatus, "1")
            .orderByAsc(CsForumComment::getCreateTime));
    }

    public List<CsForumPost> myPosts() {
        return postMapper.selectList(new LambdaQueryWrapper<CsForumPost>()
            .eq(CsForumPost::getUserId, currentUserId())
            .orderByDesc(CsForumPost::getCreateTime));
    }

    @Transactional
    public void deletePost(Long postId) {
        CsForumPost post = postMapper.selectById(postId);
        if (post == null || !post.getUserId().equals(currentUserId())) throw new ServiceException("帖子不存在");
        long comments = commentMapper.selectCount(new LambdaQueryWrapper<CsForumComment>()
            .eq(CsForumComment::getPostId, postId));
        boolean notApproved = !"1".equals(post.getAuditStatus());
        if (!notApproved && comments > 0) {
            throw new ServiceException("已审核通过且已有留言的帖子不可删除");
        }
        postMapper.deleteById(postId);
    }

    public void editPost(Long postId, String content, String images) {
        CsForumPost post = postMapper.selectById(postId);
        if (post == null || !post.getUserId().equals(currentUserId())) throw new ServiceException("帖子不存在");
        if (post.getCreateTime().plusMinutes(30).isBefore(LocalDateTime.now())) {
            throw new ServiceException("已超过30分钟，不可编辑");
        }
        post.setContent(content);
        post.setImages(images);
        postMapper.updateById(post);
    }

    @Transactional
    public void deleteComment(Long commentId) {
        CsForumComment c = commentMapper.selectById(commentId);
        if (c == null || !c.getUserId().equals(currentUserId())) throw new ServiceException("留言不存在");
        if ("1".equals(c.getAuditStatus())) {
            throw new ServiceException("已审核通过的留言不可删除");
        }
        commentMapper.deleteById(commentId);
    }

    public void editComment(Long commentId, String content) {
        CsForumComment c = commentMapper.selectById(commentId);
        if (c == null || !c.getUserId().equals(currentUserId())) throw new ServiceException("留言不存在");
        if (c.getCreateTime().plusMinutes(30).isBefore(LocalDateTime.now())) {
            throw new ServiceException("已超过30分钟，不可编辑");
        }
        c.setContent(content);
        commentMapper.updateById(c);
    }

    // ---------- 场地 ----------
    public List<CsVenue> venueList() {
        return venueMapper.selectList(null);
    }

    public List<Map<String, Object>> venueSlots(Long venueId, LocalDate bookDate) {
        CsVenue venue = venueMapper.selectById(venueId);
        if (venue == null) throw new ServiceException("场地不存在");
        String[] slots = {"09:00-12:00", "14:00-17:00", "18:00-21:00"};
        List<CsVenueBooking> booked = bookingMapper.selectList(new LambdaQueryWrapper<CsVenueBooking>()
            .eq(CsVenueBooking::getVenueId, venueId)
            .eq(CsVenueBooking::getBookDate, bookDate)
            .in(CsVenueBooking::getStatus, "0", "1"));
        Set<String> taken = booked.stream().map(CsVenueBooking::getTimeSlot).collect(Collectors.toSet());
        List<Map<String, Object>> result = new ArrayList<>();
        for (String slot : slots) {
            Map<String, Object> m = new LinkedHashMap<>();
            m.put("timeSlot", slot);
            m.put("available", !taken.contains(slot));
            m.put("feeStandard", venue.getFeeStandard());
            result.add(m);
        }
        return result;
    }

    public void bookVenue(CsVenueBooking booking) {
        booking.setUserId(currentUserId());
        booking.setStatus("1");
        long conflict = bookingMapper.selectCount(new LambdaQueryWrapper<CsVenueBooking>()
            .eq(CsVenueBooking::getVenueId, booking.getVenueId())
            .eq(CsVenueBooking::getBookDate, booking.getBookDate())
            .eq(CsVenueBooking::getTimeSlot, booking.getTimeSlot())
            .in(CsVenueBooking::getStatus, "0", "1"));
        if (conflict > 0) throw new ServiceException("该时段已被预约");
        bookingMapper.insert(booking);
    }

    public List<CsVenueBooking> myBookings() {
        return bookingMapper.selectList(new LambdaQueryWrapper<CsVenueBooking>()
            .eq(CsVenueBooking::getUserId, currentUserId())
            .orderByDesc(CsVenueBooking::getBookDate));
    }

    @Transactional
    public void cancelBooking(Long bookingId) {
        CsVenueBooking b = bookingMapper.selectById(bookingId);
        if (b == null || !b.getUserId().equals(currentUserId())) throw new ServiceException("预约不存在");
        if (!"1".equals(b.getStatus())) throw new ServiceException("仅已审核通过的预约可取消");
        LocalDateTime start = LocalDateTime.of(b.getBookDate(), java.time.LocalTime.parse(b.getTimeSlot().split("-")[0]));
        if (start.minusHours(24).isBefore(LocalDateTime.now())) {
            throw new ServiceException("需提前24小时取消");
        }
        b.setStatus("2");
        bookingMapper.updateById(b);
    }

    public void updateBooking(CsVenueBooking booking) {
        CsVenueBooking old = bookingMapper.selectById(booking.getBookingId());
        if (old == null || !old.getUserId().equals(currentUserId())) throw new ServiceException("预约不存在");
        LocalDateTime start = LocalDateTime.of(old.getBookDate(), java.time.LocalTime.parse(old.getTimeSlot().split("-")[0]));
        if (start.minusHours(2).isBefore(LocalDateTime.now())) {
            throw new ServiceException("预约开始前2小时内不可修改");
        }
        booking.setUserId(old.getUserId());
        booking.setStatus(old.getStatus());
        bookingMapper.updateById(booking);
    }

    // ---------- 投票 ----------
    public List<Map<String, Object>> voteList() {
        List<CsVote> votes = voteMapper.selectList(new LambdaQueryWrapper<CsVote>()
            .orderByDesc(CsVote::getEndTime));
        Long userId = currentUserId();
        return votes.stream().map(v -> voteVo(v, userId)).collect(Collectors.toList());
    }

    public Map<String, Object> voteDetail(Long voteId) {
        CsVote v = voteMapper.selectById(voteId);
        if (v == null) throw new ServiceException("议题不存在");
        return voteVo(v, currentUserId());
    }

    private Map<String, Object> voteVo(CsVote v, Long userId) {
        List<CsVoteRecord> records = voteRecordMapper.selectList(
            new LambdaQueryWrapper<CsVoteRecord>().eq(CsVoteRecord::getVoteId, v.getVoteId()));
        Map<String, Long> stats = new LinkedHashMap<>();
        if (StringUtils.hasText(v.getOptions())) {
            for (String opt : v.getOptions().split(",")) {
                stats.put(opt.trim(), 0L);
            }
        }
        for (CsVoteRecord r : records) {
            stats.merge(r.getVoteOption(), 1L, Long::sum);
        }
        boolean voted = records.stream().anyMatch(r -> r.getUserId().equals(userId));
        boolean ended = "0".equals(v.getStatus()) || LocalDateTime.now().isAfter(v.getEndTime());
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("voteId", v.getVoteId());
        m.put("title", v.getTitle());
        m.put("content", v.getContent());
        m.put("options", v.getOptions() != null ? Arrays.asList(v.getOptions().split(",")) : List.of());
        m.put("anonymous", v.getAnonymous());
        m.put("endTime", v.getEndTime());
        m.put("status", v.getStatus());
        m.put("ended", ended);
        m.put("voted", voted);
        m.put("stats", stats);
        m.put("totalVotes", records.size());
        return m;
    }

    @Transactional
    public void castVote(Long voteId, String option) {
        CsVote v = voteMapper.selectById(voteId);
        if (v == null) throw new ServiceException("议题不存在");
        if ("0".equals(v.getStatus()) || LocalDateTime.now().isAfter(v.getEndTime())) {
            throw new ServiceException("投票已结束");
        }
        long exists = voteRecordMapper.selectCount(new LambdaQueryWrapper<CsVoteRecord>()
            .eq(CsVoteRecord::getVoteId, voteId)
            .eq(CsVoteRecord::getUserId, currentUserId()));
        if (exists > 0) throw new ServiceException("您已投票");
        CsVoteRecord r = new CsVoteRecord();
        r.setVoteId(voteId);
        r.setUserId(currentUserId());
        r.setVoteOption(option.trim());
        voteRecordMapper.insert(r);
    }

    // ---------- 住户档案 ----------
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
        vo.put("familyList", familyList());
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

    // ---------- 账单 ----------
    public List<Map<String, Object>> billList(String period, String feeType) {
        SysUser user = userMapper.selectById(currentUserId());
        if (user == null || user.getHouseId() == null) {
            throw new ServiceException("未绑定房屋，无法查询账单");
        }
        LambdaQueryWrapper<FnBill> qw = new LambdaQueryWrapper<FnBill>()
            .eq(FnBill::getHouseId, user.getHouseId())
            .orderByDesc(FnBill::getPeriod);
        if (StringUtils.hasText(period)) qw.like(FnBill::getPeriod, period);
        List<FnBill> bills = billMapper.selectList(qw);
        Map<Long, FnFeeItem> items = feeItemMapper.selectList(null).stream()
            .collect(Collectors.toMap(FnFeeItem::getItemId, i -> i));
        return bills.stream().map(b -> {
            FnFeeItem item = items.get(b.getItemId());
            if (feeType != null && item != null && !feeType.equals(item.getFeeType())) return null;
            Map<String, Object> m = new LinkedHashMap<>();
            m.put("billId", b.getBillId());
            m.put("period", b.getPeriod());
            m.put("amount", b.getAmount());
            m.put("paidAmount", b.getPaidAmount());
            m.put("status", b.getStatus());
            m.put("dueDate", b.getDueDate());
            m.put("itemName", item != null ? item.getItemName() : "");
            m.put("feeType", item != null ? item.getFeeType() : "");
            return m;
        }).filter(Objects::nonNull).collect(Collectors.toList());
    }

    public List<FnPayment> paymentHistory() {
        return paymentMapper.selectList(new LambdaQueryWrapper<FnPayment>()
            .eq(FnPayment::getUserId, currentUserId())
            .orderByDesc(FnPayment::getPayTime));
    }

    // ---------- 投诉增强 ----------
    public List<Map<String, Object>> complaintList() {
        List<CsComplaint> list = complaintMapper.selectList(new LambdaQueryWrapper<CsComplaint>()
            .eq(CsComplaint::getUserId, currentUserId())
            .orderByDesc(CsComplaint::getCreateTime));
        return list.stream().map(c -> {
            Map<String, Object> m = new LinkedHashMap<>();
            m.put("complaintId", c.getComplaintId());
            m.put("complaintNo", c.getComplaintNo());
            m.put("title", c.getTitle());
            m.put("content", c.getContent());
            m.put("images", c.getImages());
            m.put("anonymous", c.getAnonymous());
            m.put("status", c.getStatus());
            m.put("reply", c.getReply());
            m.put("replyTime", c.getReplyTime());
            m.put("createTime", c.getCreateTime());
            if (c.getHandlerId() != null) {
                SysUser handler = userMapper.selectById(c.getHandlerId());
                m.put("handlerName", handler != null ? handler.getNickName() : "");
            } else {
                m.put("handlerName", "");
            }
            return m;
        }).collect(Collectors.toList());
    }
}
