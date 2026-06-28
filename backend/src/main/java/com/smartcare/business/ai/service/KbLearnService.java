package com.smartcare.business.ai.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.smartcare.business.ai.domain.AiChatMessage;
import com.smartcare.business.ai.domain.AiChatSession;
import com.smartcare.business.ai.domain.KbArticle;
import com.smartcare.business.ai.domain.KbLearnDraft;
import com.smartcare.business.ai.mapper.AiChatMessageMapper;
import com.smartcare.business.ai.mapper.AiChatSessionMapper;
import com.smartcare.business.ai.mapper.KbArticleMapper;
import com.smartcare.business.ai.mapper.KbLearnDraftMapper;
import com.smartcare.business.community.domain.CsNotice;
import com.smartcare.business.community.mapper.CsNoticeMapper;
import com.smartcare.common.core.page.TableDataInfo;
import com.smartcare.common.exception.ServiceException;
import com.smartcare.framework.ai.ZhipuAiClient;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;
import org.springframework.web.multipart.MultipartFile;

import java.util.*;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class KbLearnService {

    private static final Pattern JSON_BLOCK = Pattern.compile("```(?:json)?\\s*([\\s\\S]*?)```", Pattern.CASE_INSENSITIVE);
    private static final String AUTO_SKIP_TITLE = "__AUTO_SKIP__";
    private static final double DUPLICATE_OVERLAP_THRESHOLD = 0.62;
    private static final String EXTRACT_SYSTEM = """
        你是社区物业知识库编辑。从给定材料中抽取可长期入库的新知识点或问答对。

        规则：
        1. 对照下方「已有知识库条目」，已覆盖的内容不要重复抽取
        2. 仅抽取：知识库尚未收录的新知识/新问答，或同一类问题的不同处理办法与补充说明
        3. 若与已有条目含义相同、仅措辞不同，不要抽取，返回空数组 []
        4. 跳过一次性时效通知（单次停水停电时间等）、问候寒暄、转人工提示
        5. 最多返回 2 条，格式：[{"title":"","keywords":"","content":""}]
        """;

    private final KbLearnDraftMapper draftMapper;
    private final KbArticleMapper articleMapper;
    private final CsNoticeMapper noticeMapper;
    private final AiChatSessionMapper sessionMapper;
    private final AiChatMessageMapper messageMapper;
    private final ZhipuAiClient zhipuAiClient;
    private final DocumentTextExtractor documentTextExtractor;
    private final ObjectMapper objectMapper;

    public TableDataInfo listDrafts(int pageNum, int pageSize, String status, String title, String sourceType) {
        LambdaQueryWrapper<KbLearnDraft> wrapper = new LambdaQueryWrapper<KbLearnDraft>()
            .ne(KbLearnDraft::getTitle, AUTO_SKIP_TITLE)
            .like(StringUtils.hasText(title), KbLearnDraft::getTitle, title)
            .eq(StringUtils.hasText(sourceType), KbLearnDraft::getSourceType, sourceType)
            .orderByDesc(KbLearnDraft::getCreateTime);
        if (StringUtils.hasText(status)) {
            wrapper.eq(KbLearnDraft::getStatus, status);
        }
        Page<KbLearnDraft> page = draftMapper.selectPage(new Page<>(pageNum, pageSize), wrapper);
        return new TableDataInfo(page.getTotal(), page.getRecords());
    }

    public int syncFromNotices() {
        List<CsNotice> notices = noticeMapper.selectList(new LambdaQueryWrapper<CsNotice>()
            .eq(CsNotice::getStatus, "1")
            .orderByDesc(CsNotice::getCreateTime));
        return notices.parallelStream()
            .filter(n -> !isNoticeProcessed(n.getNoticeId()))
            .mapToInt(n -> extractFromNotice(n.getNoticeId(), false))
            .sum();
    }

    public int extractFromNotice(Long noticeId, boolean force) {
        CsNotice notice = noticeMapper.selectById(noticeId);
        if (notice == null) {
            throw new ServiceException("公告不存在");
        }
        if (!"1".equals(notice.getStatus())) {
            throw new ServiceException("仅已发布的公告可抽取知识点");
        }
        if (!force && isNoticeProcessed(noticeId)) {
            return 0;
        }
        String prompt = "标题：" + nullToEmpty(notice.getTitle()) + "\n正文：" + clip(nullToEmpty(notice.getContent()), 1500);
        List<KbDraftItem> items = extractItems(EXTRACT_SYSTEM, prompt);
        int saved = saveDraftItems(items, "notice", noticeId, nullToEmpty(notice.getTitle()));
        if (saved == 0) {
            markSourceSkipped("notice", noticeId, nullToEmpty(notice.getTitle()));
        }
        return saved;
    }

    public int mineFromChats() {
        List<AiChatSession> sessions = sessionMapper.selectList(new LambdaQueryWrapper<AiChatSession>()
            .in(AiChatSession::getStatus, "0", "2")
            .orderByDesc(AiChatSession::getUpdateTime)
            .last("LIMIT 30"));
        return sessions.parallelStream()
            .filter(s -> !isChatProcessed(s.getSessionId()))
            .mapToInt(this::mineFromSession)
            .sum();
    }

    public int importDocuments(MultipartFile[] files) {
        if (files == null || files.length == 0) {
            throw new ServiceException("请选择要导入的文件");
        }
        int count = 0;
        for (MultipartFile file : files) {
            if (file == null || file.isEmpty()) {
                continue;
            }
            try {
                count += importSingleDocument(file);
            } catch (Exception e) {
                log.warn("文档导入失败: {}, {}", file.getOriginalFilename(), e.getMessage());
                throw new ServiceException("文件「" + file.getOriginalFilename() + "」解析失败：" + e.getMessage());
            }
        }
        return count;
    }

    @Transactional
    public void approveDraft(Long draftId) {
        KbLearnDraft draft = requirePendingDraft(draftId);
        KbArticle article = new KbArticle();
        article.setTitle(draft.getTitle());
        article.setKeywords(draft.getKeywords());
        article.setContent(draft.getContent());
        validateArticle(article);
        articleMapper.insert(article);
        draft.setStatus("1");
        draftMapper.updateById(draft);
    }

    @Transactional
    public void rejectDraft(Long draftId) {
        KbLearnDraft draft = requirePendingDraft(draftId);
        draft.setStatus("2");
        draftMapper.updateById(draft);
    }

    public void updateDraft(KbLearnDraft draft) {
        if (draft.getDraftId() == null) {
            throw new ServiceException("草稿ID不能为空");
        }
        KbLearnDraft existing = draftMapper.selectById(draft.getDraftId());
        if (existing == null || !"0".equals(existing.getStatus())) {
            throw new ServiceException("草稿不存在或已处理");
        }
        if (!StringUtils.hasText(draft.getTitle())) {
            throw new ServiceException("标题不能为空");
        }
        if (!StringUtils.hasText(draft.getContent())) {
            throw new ServiceException("正文不能为空");
        }
        existing.setTitle(draft.getTitle().trim());
        existing.setKeywords(draft.getKeywords() != null ? draft.getKeywords().trim() : "");
        existing.setContent(draft.getContent().trim());
        draftMapper.updateById(existing);
    }

    public void deleteDraft(Long draftId) {
        KbLearnDraft draft = draftMapper.selectById(draftId);
        if (draft == null) {
            throw new ServiceException("草稿不存在");
        }
        draftMapper.deleteById(draftId);
    }

    public void onNoticePublished(Long noticeId) {
        if (noticeId == null || isNoticeProcessed(noticeId)) {
            return;
        }
        try {
            extractFromNotice(noticeId, false);
        } catch (Exception e) {
            log.warn("公告自动抽取知识库失败 noticeId={}: {}", noticeId, e.getMessage());
        }
    }

    public void syncNewlyPublishedNotices() {
        List<CsNotice> notices = noticeMapper.selectList(new LambdaQueryWrapper<CsNotice>()
            .eq(CsNotice::getStatus, "1")
            .orderByDesc(CsNotice::getCreateTime)
            .last("LIMIT 20"));
        for (CsNotice notice : notices) {
            onNoticePublished(notice.getNoticeId());
        }
    }

    private int mineFromSession(AiChatSession session) {
        List<AiChatMessage> messages = messageMapper.selectList(new LambdaQueryWrapper<AiChatMessage>()
            .eq(AiChatMessage::getSessionId, session.getSessionId())
            .orderByAsc(AiChatMessage::getCreateTime));
        if (messages.size() < 2) {
            return 0;
        }
        String transcript = messages.stream()
            .filter(m -> "user".equals(m.getRole()) || "assistant".equals(m.getRole()) || "staff".equals(m.getRole()))
            .map(m -> {
                String role = "user".equals(m.getRole()) ? "业主" : ("staff".equals(m.getRole()) ? "物业" : "AI助手");
                return role + "：" + nullToEmpty(m.getContent());
            })
            .collect(Collectors.joining("\n"));
        if (transcript.length() < 20) {
            return 0;
        }
        String prompt = "主题：" + nullToEmpty(session.getTitle()) + "\n" + clip(transcript, 2500);
        List<KbDraftItem> items = extractItems(EXTRACT_SYSTEM, prompt);
        String ref = ("0".equals(session.getStatus()) ? "AI对话" : "人工对话") + " #" + session.getSessionId();
        int saved = saveDraftItems(items, "chat", session.getSessionId(), ref);
        if (saved == 0) {
            markSourceSkipped("chat", session.getSessionId(), ref);
        }
        return saved;
    }

    private int importSingleDocument(MultipartFile file) throws Exception {
        String text = documentTextExtractor.extract(file);
        if (!StringUtils.hasText(text)) {
            throw new ServiceException("未能从文件中提取到文字内容");
        }
        String filename = file.getOriginalFilename();
        String clipped = clip(text, 6000);
        List<KbDraftItem> items = extractItems(EXTRACT_SYSTEM, "文档：" + filename + "\n" + clipped);
        return saveDraftItems(items, "document", null, filename);
    }

    private int saveDraftItems(List<KbDraftItem> items, String sourceType, Long sourceId, String sourceRef) {
        List<KnowledgeSnapshot> existing = loadExistingKnowledge();
        List<KbDraftItem> novel = filterNovelItems(items, existing);
        int saved = 0;
        for (KbDraftItem item : novel) {
            if (!StringUtils.hasText(item.title()) || !StringUtils.hasText(item.content())) {
                continue;
            }
            if (AUTO_SKIP_TITLE.equals(item.title()) || isDuplicateOfExisting(item, existing)) {
                continue;
            }
            if (draftContentExists(sourceType, sourceId, item)) {
                continue;
            }
            KbLearnDraft draft = new KbLearnDraft();
            draft.setSourceType(sourceType);
            draft.setSourceId(sourceId);
            draft.setSourceRef(sourceRef);
            draft.setTitle(trim(item.title(), 128));
            draft.setKeywords(trim(item.keywords(), 255));
            draft.setContent(item.content().trim());
            draft.setStatus("0");
            draftMapper.insert(draft);
            existing.add(new KnowledgeSnapshot(draft.getTitle(), draft.getKeywords(), draft.getContent()));
            saved++;
        }
        return saved;
    }

    private List<KbDraftItem> filterNovelItems(List<KbDraftItem> items, List<KnowledgeSnapshot> existing) {
        if (items == null || items.isEmpty()) {
            return List.of();
        }
        List<KbDraftItem> result = new ArrayList<>();
        for (KbDraftItem item : items) {
            if (!StringUtils.hasText(item.title()) || !StringUtils.hasText(item.content())) {
                continue;
            }
            if (!isDuplicateOfExisting(item, existing)) {
                result.add(item);
            }
        }
        return result;
    }

    private List<KnowledgeSnapshot> loadExistingKnowledge() {
        List<KnowledgeSnapshot> snapshots = new ArrayList<>();
        for (KbArticle article : articleMapper.selectList(new LambdaQueryWrapper<KbArticle>()
            .orderByDesc(KbArticle::getCreateTime))) {
            snapshots.add(new KnowledgeSnapshot(article.getTitle(), article.getKeywords(), article.getContent()));
        }
        for (KbLearnDraft draft : draftMapper.selectList(new LambdaQueryWrapper<KbLearnDraft>()
            .in(KbLearnDraft::getStatus, "0", "1")
            .ne(KbLearnDraft::getTitle, AUTO_SKIP_TITLE)
            .orderByDesc(KbLearnDraft::getCreateTime))) {
            snapshots.add(new KnowledgeSnapshot(draft.getTitle(), draft.getKeywords(), draft.getContent()));
        }
        return snapshots;
    }

    private String buildExistingKnowledgeContext(List<KnowledgeSnapshot> snapshots) {
        if (snapshots.isEmpty()) {
            return "（当前知识库为空）";
        }
        StringBuilder sb = new StringBuilder();
        int idx = 1;
        for (KnowledgeSnapshot snap : snapshots) {
            if (idx > 40) {
                sb.append("...（其余条目已省略）");
                break;
            }
            sb.append(idx++).append(". 标题：").append(snap.title()).append('\n');
            if (StringUtils.hasText(snap.keywords())) {
                sb.append("   关键词：").append(snap.keywords()).append('\n');
            }
            sb.append("   摘要：").append(clip(snap.content(), 120)).append("\n\n");
        }
        return sb.toString().trim();
    }

    private boolean isDuplicateOfExisting(KbDraftItem item, List<KnowledgeSnapshot> existing) {
        if (existing.isEmpty()) {
            return false;
        }
        for (KnowledgeSnapshot snap : existing) {
            if (isTitleSimilar(item.title(), snap.title())) {
                return true;
            }
            if (contentOverlapRatio(item, snap) >= DUPLICATE_OVERLAP_THRESHOLD) {
                return true;
            }
        }
        return false;
    }

    private boolean isTitleSimilar(String a, String b) {
        if (!StringUtils.hasText(a) || !StringUtils.hasText(b)) {
            return false;
        }
        String na = normalizeCompareText(a);
        String nb = normalizeCompareText(b);
        if (na.equals(nb)) {
            return true;
        }
        if (na.length() >= 4 && nb.length() >= 4 && (na.contains(nb) || nb.contains(na))) {
            return true;
        }
        return tokenOverlapRatio(a, b) >= 0.85;
    }

    private double contentOverlapRatio(KbDraftItem item, KnowledgeSnapshot snap) {
        String candidate = buildCompareText(item.title(), item.keywords(), item.content());
        String existing = buildCompareText(snap.title(), snap.keywords(), snap.content());
        return tokenOverlapRatio(candidate, existing);
    }

    private double tokenOverlapRatio(String a, String b) {
        Set<String> ta = tokenize(a);
        Set<String> tb = tokenize(b);
        if (ta.isEmpty() || tb.isEmpty()) {
            return 0;
        }
        long overlap = ta.stream().filter(tb::contains).count();
        long base = Math.min(ta.size(), tb.size());
        return base == 0 ? 0 : (double) overlap / base;
    }

    private Set<String> tokenize(String text) {
        Set<String> tokens = new LinkedHashSet<>();
        if (!StringUtils.hasText(text)) {
            return tokens;
        }
        String normalized = text.replaceAll("[\\s，。！？、；：()\\[\\]【】\"'\\-—]", " ");
        for (String part : normalized.split("\\s+")) {
            if (part.length() >= 2) {
                tokens.add(part.toLowerCase());
            }
        }
        for (int i = 0; i < text.length(); i++) {
            if (i + 2 <= text.length()) {
                tokens.add(text.substring(i, i + 2));
            }
        }
        return tokens;
    }

    private String buildCompareText(String title, String keywords, String content) {
        return nullToEmpty(title) + " " + nullToEmpty(keywords) + " " + nullToEmpty(content);
    }

    private String normalizeCompareText(String text) {
        return nullToEmpty(text).trim()
            .replaceAll("[\\s，。！？、；：()\\[\\]【】\"'\\-—]", "")
            .toLowerCase();
    }

    private void markSourceSkipped(String sourceType, Long sourceId, String sourceRef) {
        if (sourceId == null || isSourceProcessed(sourceType, sourceId)) {
            return;
        }
        KbLearnDraft skip = new KbLearnDraft();
        skip.setSourceType(sourceType);
        skip.setSourceId(sourceId);
        skip.setSourceRef(sourceRef);
        skip.setTitle(AUTO_SKIP_TITLE);
        skip.setKeywords("");
        skip.setContent("与现有知识库相比无新增知识点，已自动跳过。");
        skip.setStatus("2");
        draftMapper.insert(skip);
    }

    private List<KbDraftItem> extractItems(String systemPrompt, String userContent) {
        if (!zhipuAiClient.isAvailable()) {
            throw new ServiceException("智谱 AI 未配置，无法进行知识抽取");
        }
        List<KnowledgeSnapshot> existing = loadExistingKnowledge();
        String fullSystem = systemPrompt + "\n\n已有知识库条目：\n" + buildExistingKnowledgeContext(existing);
        String raw = zhipuAiClient.chatForExtract(fullSystem, userContent);
        return parseItems(raw);
    }

    private List<KbDraftItem> parseItems(String raw) {
        if (!StringUtils.hasText(raw)) {
            return List.of();
        }
        String json = raw.trim();
        Matcher matcher = JSON_BLOCK.matcher(json);
        if (matcher.find()) {
            json = matcher.group(1).trim();
        }
        int start = json.indexOf('[');
        int end = json.lastIndexOf(']');
        if (start >= 0 && end > start) {
            json = json.substring(start, end + 1);
        }
        try {
            JsonNode node = objectMapper.readTree(json);
            if (node.isArray()) {
                return objectMapper.convertValue(node, new TypeReference<List<KbDraftItem>>() {});
            }
            if (node.isObject()) {
                KbDraftItem one = objectMapper.convertValue(node, KbDraftItem.class);
                return List.of(one);
            }
        } catch (Exception e) {
            log.warn("解析 AI 抽取结果失败: {}", e.getMessage());
            throw new ServiceException("AI 抽取结果解析失败，请重试");
        }
        return List.of();
    }

    private boolean isNoticeProcessed(Long noticeId) {
        return isSourceProcessed("notice", noticeId);
    }

    private boolean isChatProcessed(Long sessionId) {
        return isSourceProcessed("chat", sessionId);
    }

    private boolean isSourceProcessed(String sourceType, Long sourceId) {
        if (sourceId == null) {
            return false;
        }
        return draftMapper.selectCount(new LambdaQueryWrapper<KbLearnDraft>()
            .eq(KbLearnDraft::getSourceType, sourceType)
            .eq(KbLearnDraft::getSourceId, sourceId)) > 0;
    }

    private boolean draftContentExists(String sourceType, Long sourceId, KbDraftItem item) {
        LambdaQueryWrapper<KbLearnDraft> wrapper = new LambdaQueryWrapper<KbLearnDraft>()
            .eq(KbLearnDraft::getTitle, item.title())
            .in(KbLearnDraft::getStatus, "0", "1");
        if (sourceId != null) {
            wrapper.eq(KbLearnDraft::getSourceId, sourceId);
        }
        if (StringUtils.hasText(sourceType)) {
            wrapper.eq(KbLearnDraft::getSourceType, sourceType);
        }
        if (draftMapper.selectCount(wrapper) > 0) {
            return true;
        }
        return articleMapper.selectCount(new LambdaQueryWrapper<KbArticle>()
            .eq(KbArticle::getTitle, item.title())) > 0;
    }

    private KbLearnDraft requirePendingDraft(Long draftId) {
        KbLearnDraft draft = draftMapper.selectById(draftId);
        if (draft == null || !"0".equals(draft.getStatus())) {
            throw new ServiceException("草稿不存在或已处理");
        }
        validateArticleFields(draft.getTitle(), draft.getContent());
        return draft;
    }

    private void validateArticle(KbArticle article) {
        validateArticleFields(article.getTitle(), article.getContent());
        if (article.getKeywords() == null) {
            article.setKeywords("");
        }
    }

    private void validateArticleFields(String title, String content) {
        if (!StringUtils.hasText(title)) {
            throw new ServiceException("标题不能为空");
        }
        if (!StringUtils.hasText(content)) {
            throw new ServiceException("正文不能为空");
        }
    }

    private String nullToEmpty(String text) {
        return text != null ? text : "";
    }

    private String trim(String text, int max) {
        if (!StringUtils.hasText(text)) {
            return "";
        }
        String t = text.trim();
        return t.length() <= max ? t : t.substring(0, max);
    }

    private String clip(String text, int max) {
        return trim(text, max);
    }

    private record KbDraftItem(String title, String keywords, String content) {}

    private record KnowledgeSnapshot(String title, String keywords, String content) {}
}
