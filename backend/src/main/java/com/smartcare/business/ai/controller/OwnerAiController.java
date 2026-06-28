package com.smartcare.business.ai.controller;

import com.smartcare.business.ai.service.AiChatService;
import com.smartcare.common.core.domain.AjaxResult;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.Objects;

@RestController
@RequiredArgsConstructor
public class OwnerAiController {

    private final AiChatService aiChatService;

    @PostMapping("/owner/ai/ask")
    public AjaxResult ask(@RequestBody Map<String, Object> body) {
        Long sessionId = body.get("sessionId") != null
            ? Long.valueOf(body.get("sessionId").toString()) : null;
        String question = body.get("question") != null ? body.get("question").toString() : null;
        String inputType = body.get("inputType") != null ? body.get("inputType").toString() : "text";
        List<String> images = extractImages(body.get("images"));
        return AjaxResult.success(aiChatService.ask(sessionId, question, inputType, images));
    }

    @SuppressWarnings("unchecked")
    private List<String> extractImages(Object raw) {
        if (!(raw instanceof List<?> list)) {
            return List.of();
        }
        return list.stream()
            .filter(Objects::nonNull)
            .map(Object::toString)
            .filter(s -> !s.isBlank())
            .toList();
    }

    @GetMapping("/owner/ai/sessions")
    public AjaxResult sessions(@RequestParam(defaultValue = "1") int pageNum,
                               @RequestParam(defaultValue = "20") int pageSize) {
        return AjaxResult.success(aiChatService.listSessions(pageNum, pageSize));
    }

    @GetMapping("/owner/ai/session/{sessionId}/messages")
    public AjaxResult messages(@PathVariable Long sessionId) {
        return AjaxResult.success(aiChatService.listMessages(sessionId));
    }

    @PutMapping("/owner/ai/session/{sessionId}/close")
    public AjaxResult closeSession(@PathVariable Long sessionId) {
        aiChatService.closeSession(sessionId);
        return AjaxResult.success();
    }
}
