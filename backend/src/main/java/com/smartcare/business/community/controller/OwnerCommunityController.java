package com.smartcare.business.community.controller;

import com.smartcare.business.community.service.OwnerCommunityService;
import com.smartcare.common.core.domain.AjaxResult;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.Map;

@RestController
@RequiredArgsConstructor
public class OwnerCommunityController {

    private final OwnerCommunityService communityService;

    @GetMapping("/owner/notice/list/v2")
    public AjaxResult noticeList(@RequestParam(defaultValue = "1") int pageNum,
                                 @RequestParam(defaultValue = "10") int pageSize,
                                 @RequestParam(required = false) String noticeType,
                                 @RequestParam(required = false) String title,
                                 @RequestParam(required = false) @DateTimeFormat(pattern = "yyyy-MM-dd HH:mm:ss") LocalDateTime publishTimeStart,
                                 @RequestParam(required = false) @DateTimeFormat(pattern = "yyyy-MM-dd HH:mm:ss") LocalDateTime publishTimeEnd,
                                 @RequestParam(required = false) String readStatus) {
        return AjaxResult.success(communityService.noticeList(
            pageNum, pageSize, noticeType, title, publishTimeStart, publishTimeEnd, readStatus));
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

    @GetMapping("/owner/resident/me")
    public AjaxResult residentMe() {
        return AjaxResult.success(communityService.residentProfile());
    }

    @PutMapping("/owner/resident/emergency")
    public AjaxResult updateEmergency(@RequestBody Map<String, String> body) {
        communityService.updateEmergencyContact(body.get("emergencyContact"));
        return AjaxResult.success();
    }
}
