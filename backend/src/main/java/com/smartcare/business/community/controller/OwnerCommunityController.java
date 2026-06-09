package com.smartcare.business.community.controller;

import com.smartcare.business.community.domain.*;
import com.smartcare.business.community.service.OwnerCommunityService;
import com.smartcare.business.community.service.PropertyCommunityService;
import com.smartcare.common.core.domain.AjaxResult;
import com.smartcare.common.core.page.TableDataInfo;
import com.smartcare.framework.security.SecurityUtils;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Map;
import java.util.concurrent.ThreadLocalRandom;

@RestController
@RequiredArgsConstructor
public class OwnerCommunityController {

    private final OwnerCommunityService communityService;
    private final com.smartcare.business.community.mapper.CsComplaintMapper complaintMapper;
    private final PropertyCommunityService propertyCommunityService;

    // 公告
    @GetMapping("/owner/notice/list/v2")
    public AjaxResult noticeList(@RequestParam(required = false) String noticeType) {
        return AjaxResult.success(communityService.noticeList(noticeType));
    }

    @GetMapping("/owner/notice/{noticeId}")
    public AjaxResult noticeDetail(@PathVariable Long noticeId) {
        return AjaxResult.success(communityService.noticeDetail(noticeId));
    }

    @PostMapping("/owner/notice/read/{noticeId}")
    public AjaxResult markNoticeRead(@PathVariable Long noticeId) {
        communityService.markNoticeRead(noticeId);
        return AjaxResult.success();
    }

    // 活动
    @GetMapping("/owner/activity/list")
    public AjaxResult activityList() {
        return AjaxResult.success(communityService.activityList());
    }

    @GetMapping("/owner/activity/{activityId}")
    public AjaxResult activityDetail(@PathVariable Long activityId) {
        return AjaxResult.success(communityService.activityDetail(activityId));
    }

    @PostMapping("/owner/activity/register")
    public AjaxResult registerActivity(@RequestBody CsActivityReg reg) {
        return AjaxResult.success(communityService.registerActivity(reg));
    }

    @GetMapping("/owner/activity/reg/list")
    public AjaxResult myRegs() {
        return AjaxResult.success(communityService.myActivityRegs());
    }

    @PutMapping("/owner/activity/reg/cancel/{regId}")
    public AjaxResult cancelReg(@PathVariable Long regId) {
        communityService.cancelActivityReg(regId);
        return AjaxResult.success();
    }

    // 亲情
    @GetMapping("/owner/family/list")
    public AjaxResult familyList() {
        return AjaxResult.success(communityService.familyList());
    }

    @PostMapping("/owner/family")
    public AjaxResult addFamily(@RequestBody CsFamilyBind bind) {
        communityService.addFamily(bind);
        return AjaxResult.success();
    }

    @PutMapping("/owner/family/{bindId}/alert")
    public AjaxResult updateFamilyAlert(@PathVariable Long bindId, @RequestBody Map<String, Integer> body) {
        communityService.updateFamilyAlert(bindId, body.get("shareAlert"));
        return AjaxResult.success();
    }

    @DeleteMapping("/owner/family/{bindId}")
    public AjaxResult removeFamily(@PathVariable Long bindId) {
        communityService.removeFamily(bindId);
        return AjaxResult.success();
    }

    @GetMapping("/owner/family/alerts")
    public AjaxResult sharedAlerts() {
        return AjaxResult.success(communityService.sharedAlerts());
    }

    // 访客
    @GetMapping("/owner/visitor/list")
    public AjaxResult visitorList() {
        return AjaxResult.success(communityService.visitorList());
    }

    @PostMapping("/owner/visitor")
    public AjaxResult addVisitor(@RequestBody CsVisitor visitor) {
        return AjaxResult.success(communityService.addVisitor(visitor));
    }

    @PutMapping("/owner/visitor")
    public AjaxResult updateVisitor(@RequestBody CsVisitor visitor) {
        communityService.updateVisitor(visitor);
        return AjaxResult.success();
    }

    // 论坛
    @GetMapping("/owner/forum/post/list")
    public AjaxResult forumPosts(@RequestParam(defaultValue = "1") int pageNum,
                                 @RequestParam(defaultValue = "10") int pageSize) {
        var page = communityService.forumPosts(pageNum, pageSize);
        return AjaxResult.success(new TableDataInfo(page.getTotal(), page.getRecords()));
    }

    @GetMapping("/owner/forum/post/mine")
    public AjaxResult myPosts() {
        return AjaxResult.success(communityService.myPosts());
    }

    @PostMapping("/owner/forum/post")
    public AjaxResult addPost(@RequestBody CsForumPost post) {
        communityService.addPost(post);
        return AjaxResult.success();
    }

    @PutMapping("/owner/forum/post")
    public AjaxResult editPost(@RequestBody Map<String, Object> body) {
        communityService.editPost(
            Long.valueOf(body.get("postId").toString()),
            (String) body.get("content"),
            (String) body.get("images"));
        return AjaxResult.success();
    }

    @DeleteMapping("/owner/forum/post/{postId}")
    public AjaxResult deletePost(@PathVariable Long postId) {
        communityService.deletePost(postId);
        return AjaxResult.success();
    }

    @GetMapping("/owner/forum/comment/{postId}")
    public AjaxResult comments(@PathVariable Long postId) {
        return AjaxResult.success(communityService.postComments(postId));
    }

    @PostMapping("/owner/forum/comment")
    public AjaxResult addComment(@RequestBody CsForumComment comment) {
        communityService.addComment(comment);
        return AjaxResult.success();
    }

    @PutMapping("/owner/forum/comment")
    public AjaxResult editComment(@RequestBody CsForumComment comment) {
        communityService.editComment(comment.getCommentId(), comment.getContent());
        return AjaxResult.success();
    }

    @DeleteMapping("/owner/forum/comment/{commentId}")
    public AjaxResult deleteComment(@PathVariable Long commentId) {
        communityService.deleteComment(commentId);
        return AjaxResult.success();
    }

    // 场地
    @GetMapping("/owner/venue/list")
    public AjaxResult venueList() {
        return AjaxResult.success(communityService.venueList());
    }

    @GetMapping("/owner/venue/slots")
    public AjaxResult venueSlots(@RequestParam Long venueId, @RequestParam String bookDate) {
        return AjaxResult.success(communityService.venueSlots(venueId, LocalDate.parse(bookDate)));
    }

    @PostMapping("/owner/venue/booking")
    public AjaxResult bookVenue(@RequestBody CsVenueBooking booking) {
        communityService.bookVenue(booking);
        return AjaxResult.success();
    }

    @GetMapping("/owner/venue/booking/list")
    public AjaxResult myBookings() {
        return AjaxResult.success(communityService.myBookings());
    }

    @PutMapping("/owner/venue/booking/cancel/{bookingId}")
    public AjaxResult cancelBooking(@PathVariable Long bookingId) {
        communityService.cancelBooking(bookingId);
        return AjaxResult.success();
    }

    @PutMapping("/owner/venue/booking")
    public AjaxResult updateBooking(@RequestBody CsVenueBooking booking) {
        communityService.updateBooking(booking);
        return AjaxResult.success();
    }

    // 投票
    @GetMapping("/owner/vote/list")
    public AjaxResult voteList() {
        return AjaxResult.success(communityService.voteList());
    }

    @GetMapping("/owner/vote/{voteId}")
    public AjaxResult voteDetail(@PathVariable Long voteId) {
        return AjaxResult.success(communityService.voteDetail(voteId));
    }

    @PostMapping("/owner/vote/{voteId}")
    public AjaxResult castVote(@PathVariable Long voteId, @RequestBody Map<String, String> body) {
        communityService.castVote(voteId, body.get("option"));
        return AjaxResult.success();
    }

    // 住户档案
    @GetMapping("/owner/resident/me")
    public AjaxResult residentMe() {
        return AjaxResult.success(communityService.residentProfile());
    }

    @PutMapping("/owner/resident/emergency")
    public AjaxResult updateEmergency(@RequestBody Map<String, String> body) {
        communityService.updateEmergencyContact(body.get("emergencyContact"));
        return AjaxResult.success();
    }

    // 账单
    @GetMapping("/owner/bill/list/v2")
    public AjaxResult bills(@RequestParam(required = false) String period,
                            @RequestParam(required = false) String feeType) {
        return AjaxResult.success(communityService.billList(period, feeType));
    }

    @GetMapping("/owner/bill/payments")
    public AjaxResult payments() {
        return AjaxResult.success(communityService.paymentHistory());
    }

    // 投诉（含处理人）
    @GetMapping("/owner/complaint/list/v2")
    public AjaxResult complaintListV2() {
        return AjaxResult.success(communityService.complaintList());
    }

    @PostMapping("/owner/complaint/v2")
    public AjaxResult submitComplaint(@RequestBody CsComplaint complaint) {
        complaint.setUserId(SecurityUtils.getUserId());
        complaint.setComplaintNo(propertyCommunityService.nextComplaintNo());
        complaint.setStatus("pending");
        complaintMapper.insert(complaint);
        return AjaxResult.success();
    }
}
