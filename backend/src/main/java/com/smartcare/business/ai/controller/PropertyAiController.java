package com.smartcare.business.ai.controller;

import com.smartcare.business.ai.domain.KbArticle;
import com.smartcare.business.ai.domain.KbLearnDraft;
import com.smartcare.business.ai.service.KbLearnService;
import com.smartcare.business.ai.service.PropertyAiService;
import com.smartcare.common.core.domain.AjaxResult;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.Map;

@RestController
@RequestMapping("/property/ai")
@RequiredArgsConstructor
public class PropertyAiController {

    private final PropertyAiService propertyAiService;
    private final KbLearnService kbLearnService;

    @GetMapping("/knowledge/list")
    public AjaxResult knowledgeList(@RequestParam(defaultValue = "1") int pageNum,
                                    @RequestParam(defaultValue = "10") int pageSize,
                                    @RequestParam(required = false) String title,
                                    @RequestParam(required = false) String keywords,
                                    @RequestParam(required = false) String content) {
        return AjaxResult.success(propertyAiService.listArticles(pageNum, pageSize, title, keywords, content));
    }

    @GetMapping("/knowledge/{articleId}")
    public AjaxResult knowledgeDetail(@PathVariable Long articleId) {
        return AjaxResult.success(propertyAiService.getArticle(articleId));
    }

    @PostMapping("/knowledge")
    public AjaxResult addKnowledge(@RequestBody KbArticle article) {
        propertyAiService.addArticle(article);
        return AjaxResult.success();
    }

    @PutMapping("/knowledge")
    public AjaxResult updateKnowledge(@RequestBody KbArticle article) {
        propertyAiService.updateArticle(article);
        return AjaxResult.success();
    }

    @DeleteMapping("/knowledge/{articleId}")
    public AjaxResult deleteKnowledge(@PathVariable Long articleId) {
        propertyAiService.deleteArticle(articleId);
        return AjaxResult.success();
    }

    @GetMapping("/chat/sessions")
    public AjaxResult sessions(@RequestParam(defaultValue = "1") int pageNum,
                               @RequestParam(defaultValue = "20") int pageSize,
                               @RequestParam String scope,
                               @RequestParam(required = false) String title,
                               @RequestParam(required = false) String sessionType) {
        return AjaxResult.success(propertyAiService.listSessions(pageNum, pageSize, scope, title, sessionType));
    }

    @GetMapping("/chat/session/{sessionId}")
    public AjaxResult sessionDetail(@PathVariable Long sessionId) {
        return AjaxResult.success(propertyAiService.getSession(sessionId));
    }

    @GetMapping("/chat/session/{sessionId}/messages")
    public AjaxResult sessionMessages(@PathVariable Long sessionId) {
        return AjaxResult.success(propertyAiService.listSessionMessages(sessionId));
    }

    @PostMapping("/chat/session/{sessionId}/send")
    public AjaxResult sendStaffMessage(@PathVariable Long sessionId, @RequestBody Map<String, String> body) {
        return AjaxResult.success(propertyAiService.sendStaffMessage(sessionId, body.get("content")));
    }

    @PutMapping("/chat/session/{sessionId}/close")
    public AjaxResult closeSession(@PathVariable Long sessionId) {
        propertyAiService.closeHumanSession(sessionId);
        return AjaxResult.success();
    }

    @GetMapping("/learn/drafts")
    public AjaxResult learnDrafts(@RequestParam(defaultValue = "1") int pageNum,
                                  @RequestParam(defaultValue = "10") int pageSize,
                                  @RequestParam(required = false) String status,
                                  @RequestParam(required = false) String title,
                                  @RequestParam(required = false) String sourceType) {
        return AjaxResult.success(kbLearnService.listDrafts(pageNum, pageSize, status, title, sourceType));
    }

    @PostMapping("/learn/sync-notices")
    public AjaxResult syncNotices() {
        int count = kbLearnService.syncFromNotices();
        return AjaxResult.success(Map.of("count", count));
    }

    @PostMapping("/learn/from-notice/{noticeId}")
    public AjaxResult extractFromNotice(@PathVariable Long noticeId,
                                        @RequestParam(defaultValue = "false") boolean force) {
        int count = kbLearnService.extractFromNotice(noticeId, force);
        return AjaxResult.success(Map.of("count", count));
    }

    @PostMapping("/learn/mine-chats")
    public AjaxResult mineChats() {
        int count = kbLearnService.mineFromChats();
        return AjaxResult.success(Map.of("count", count));
    }

    @PostMapping("/learn/import-docs")
    public AjaxResult importDocs(@RequestParam("files") MultipartFile[] files) {
        int count = kbLearnService.importDocuments(files);
        return AjaxResult.success(Map.of("count", count));
    }

    @PutMapping("/learn/draft/{draftId}/approve")
    public AjaxResult approveDraft(@PathVariable Long draftId) {
        kbLearnService.approveDraft(draftId);
        return AjaxResult.success();
    }

    @PutMapping("/learn/draft/{draftId}/reject")
    public AjaxResult rejectDraft(@PathVariable Long draftId) {
        kbLearnService.rejectDraft(draftId);
        return AjaxResult.success();
    }

    @PutMapping("/learn/draft")
    public AjaxResult updateDraft(@RequestBody KbLearnDraft draft) {
        kbLearnService.updateDraft(draft);
        return AjaxResult.success();
    }

    @DeleteMapping("/learn/draft/{draftId}")
    public AjaxResult deleteDraft(@PathVariable Long draftId) {
        kbLearnService.deleteDraft(draftId);
        return AjaxResult.success();
    }
}
