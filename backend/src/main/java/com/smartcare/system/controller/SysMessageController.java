package com.smartcare.system.controller;

import com.smartcare.common.core.domain.AjaxResult;
import com.smartcare.common.core.page.TableDataInfo;
import com.smartcare.framework.security.SecurityUtils;
import com.smartcare.system.service.SysMessageService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/system/message")
@RequiredArgsConstructor
public class SysMessageController {

    private final SysMessageService messageService;

    @GetMapping("/list")
    public AjaxResult list(@RequestParam(defaultValue = "1") int pageNum,
                           @RequestParam(defaultValue = "10") int pageSize,
                           @RequestParam(required = false) String msgType) {
        var page = messageService.listForUser(SecurityUtils.getUserId(), pageNum, pageSize, msgType);
        return AjaxResult.success(new TableDataInfo(page.getTotal(), page.getRecords()));
    }

    @GetMapping("/unreadCount")
    public AjaxResult unreadCount() {
        return AjaxResult.success(messageService.unreadCount(SecurityUtils.getUserId()));
    }

    @PutMapping("/read/{messageId}")
    public AjaxResult read(@PathVariable Long messageId) {
        messageService.markRead(messageId, SecurityUtils.getUserId());
        return AjaxResult.success();
    }
}
