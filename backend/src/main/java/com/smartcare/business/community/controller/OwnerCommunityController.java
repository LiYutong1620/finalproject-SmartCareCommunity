package com.smartcare.business.community.controller;

import com.smartcare.business.community.service.OwnerCommunityService;
import com.smartcare.common.core.domain.AjaxResult;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequiredArgsConstructor
public class OwnerCommunityController {

    private final OwnerCommunityService communityService;

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
