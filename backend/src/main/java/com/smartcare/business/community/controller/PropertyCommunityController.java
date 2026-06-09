package com.smartcare.business.community.controller;

import com.smartcare.business.community.domain.*;
import com.smartcare.business.community.service.PropertyCommunityService;
import com.smartcare.common.core.domain.AjaxResult;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.Map;

@RestController
@RequestMapping("/property/content")
@RequiredArgsConstructor
public class PropertyCommunityController {

    private final PropertyCommunityService communityService;

    // 公告/停水停电
    @GetMapping("/notice/list")
    public AjaxResult noticeList(@RequestParam(defaultValue = "1") int pageNum,
                                 @RequestParam(defaultValue = "10") int pageSize,
                                 @RequestParam(required = false) String noticeType,
                                 @RequestParam(required = false) String status) {
        return AjaxResult.success(communityService.noticeManageList(pageNum, pageSize, noticeType, status));
    }

    @PostMapping("/notice")
    public AjaxResult publishNotice(@RequestBody CsNotice notice) {
        communityService.publishNotice(notice);
        return AjaxResult.success();
    }

    @PutMapping("/notice")
    public AjaxResult updateNotice(@RequestBody CsNotice notice) {
        communityService.updateNotice(notice);
        return AjaxResult.success();
    }

    @PutMapping("/notice/offline/{noticeId}")
    public AjaxResult offlineNotice(@PathVariable Long noticeId) {
        communityService.offlineNotice(noticeId);
        return AjaxResult.success();
    }

    @GetMapping("/notice/{noticeId}/read-stats")
    public AjaxResult noticeReadStats(@PathVariable Long noticeId) {
        return AjaxResult.success(communityService.noticeReadStats(noticeId));
    }

    @PostMapping("/notice/{noticeId}/force-read/{userId}")
    public AjaxResult forceRead(@PathVariable Long noticeId, @PathVariable Long userId) {
        communityService.forceNoticeRead(noticeId, userId);
        return AjaxResult.success();
    }

    // 活动
    @GetMapping("/activity/list")
    public AjaxResult activityList() {
        return AjaxResult.success(communityService.activityManageList());
    }

    @PostMapping("/activity")
    public AjaxResult publishActivity(@RequestBody CsActivity activity) {
        communityService.publishActivity(activity);
        return AjaxResult.success();
    }

    @PutMapping("/activity")
    public AjaxResult updateActivity(@RequestBody CsActivity activity) {
        communityService.updateActivity(activity);
        return AjaxResult.success();
    }

    @PutMapping("/activity/offline/{activityId}")
    public AjaxResult offlineActivity(@PathVariable Long activityId) {
        communityService.offlineActivity(activityId);
        return AjaxResult.success();
    }

    @GetMapping("/activity/{activityId}/regs")
    public AjaxResult activityRegs(@PathVariable Long activityId) {
        return AjaxResult.success(communityService.activityRegList(activityId));
    }

    @GetMapping("/activity/{activityId}/export")
    public void exportRegs(@PathVariable Long activityId, HttpServletResponse response) throws Exception {
        communityService.exportActivityRegs(activityId, response);
    }

    // 投诉
    @GetMapping("/complaint/list")
    public AjaxResult complaintList(@RequestParam(defaultValue = "1") int pageNum,
                                    @RequestParam(defaultValue = "10") int pageSize,
                                    @RequestParam(required = false) String status,
                                    @RequestParam(required = false) String category,
                                    @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime start,
                                    @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime end) {
        return AjaxResult.success(communityService.complaintList(pageNum, pageSize, status, category, start, end));
    }

    @GetMapping("/complaint/{complaintId}")
    public AjaxResult complaintDetail(@PathVariable Long complaintId) {
        return AjaxResult.success(communityService.complaintDetail(complaintId));
    }

    @GetMapping("/complaint/stats")
    public AjaxResult complaintStats(
        @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime start,
        @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime end) {
        return AjaxResult.success(communityService.complaintStats(start, end));
    }

    @PutMapping("/complaint/accept")
    public AjaxResult acceptComplaint(@RequestBody Map<String, Long> body) {
        communityService.acceptComplaint(body.get("complaintId"), body.get("handlerId"));
        return AjaxResult.success();
    }

    @PutMapping("/complaint/reply")
    public AjaxResult replyComplaint(@RequestBody Map<String, Object> body) {
        Long complaintId = Long.valueOf(body.get("complaintId").toString());
        String reply = body.get("reply").toString();
        communityService.replyComplaint(complaintId, reply);
        return AjaxResult.success();
    }

    // 论坛
    @GetMapping("/forum/post/pending")
    public AjaxResult pendingPosts() {
        return AjaxResult.success(communityService.pendingPosts());
    }

    @GetMapping("/forum/comment/pending")
    public AjaxResult pendingComments() {
        return AjaxResult.success(communityService.pendingComments());
    }

    @PutMapping("/forum/post/audit")
    public AjaxResult auditPost(@RequestBody Map<String, String> body) {
        communityService.auditPost(Long.valueOf(body.get("postId")), body.get("auditStatus"));
        return AjaxResult.success();
    }

    @PutMapping("/forum/comment/audit")
    public AjaxResult auditComment(@RequestBody Map<String, String> body) {
        communityService.auditComment(Long.valueOf(body.get("commentId")), body.get("auditStatus"));
        return AjaxResult.success();
    }

    @DeleteMapping("/forum/post/{postId}")
    public AjaxResult deletePost(@PathVariable Long postId) {
        communityService.deletePost(postId);
        return AjaxResult.success();
    }

    @DeleteMapping("/forum/comment/{commentId}")
    public AjaxResult deleteComment(@PathVariable Long commentId) {
        communityService.deleteComment(commentId);
        return AjaxResult.success();
    }
}
