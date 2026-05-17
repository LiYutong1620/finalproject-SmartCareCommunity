package com.smartcare.system.controller;

import com.smartcare.common.core.domain.AjaxResult;
import com.smartcare.common.core.page.TableDataInfo;
import com.smartcare.framework.security.SecurityUtils;
import com.smartcare.system.domain.SysMessage;
import com.smartcare.system.service.SysMessageService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

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

    @PostMapping("/send")
    public AjaxResult send(@RequestBody Map<String, Object> body) {
        SysMessage msg = new SysMessage();
        msg.setMsgType((String) body.get("msgType"));
        msg.setTitle((String) body.get("title"));
        msg.setContent((String) body.get("content"));
        msg.setPriority(body.getOrDefault("priority", "normal").toString());
        msg.setSenderId(SecurityUtils.getUserId());
        @SuppressWarnings("unchecked")
        List<Long> userIds = (List<Long>) body.get("userIds");
        messageService.send(msg, userIds);
        return AjaxResult.success();
    }

    @PutMapping("/read/{messageId}")
    public AjaxResult markRead(@PathVariable Long messageId) {
        messageService.markRead(messageId, SecurityUtils.getUserId());
        return AjaxResult.success();
    }

    @PutMapping("/recall/{messageId}")
    public AjaxResult recall(@PathVariable Long messageId) {
        messageService.recall(messageId, SecurityUtils.getUserId());
        return AjaxResult.success();
    }

    @PutMapping("/priority")
    public AjaxResult updatePriority(@RequestBody Map<String, String> body) {
        messageService.updatePriority(Long.parseLong(body.get("messageId")), body.get("priority"));
        return AjaxResult.success();
    }
}
