package com.smartcare.business.community.controller;

import com.smartcare.business.community.domain.CsNotice;
import com.smartcare.business.community.service.PropertyCommunityService;
import com.smartcare.common.core.domain.AjaxResult;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;

@RestController
@RequestMapping("/property/content")
@RequiredArgsConstructor
public class PropertyCommunityController {

    private final PropertyCommunityService communityService;

    @GetMapping("/notice/list")
    public AjaxResult noticeList(@RequestParam(defaultValue = "1") int pageNum,
                                 @RequestParam(defaultValue = "10") int pageSize,
                                 @RequestParam(required = false) String noticeType,
                                 @RequestParam(required = false) String status,
                                 @RequestParam(required = false) String title,
                                 @RequestParam(required = false) @DateTimeFormat(pattern = "yyyy-MM-dd HH:mm:ss") LocalDateTime publishTimeStart,
                                 @RequestParam(required = false) @DateTimeFormat(pattern = "yyyy-MM-dd HH:mm:ss") LocalDateTime publishTimeEnd) {
        return AjaxResult.success(communityService.noticeManageList(
            pageNum, pageSize, noticeType, status, title, publishTimeStart, publishTimeEnd));
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
}
