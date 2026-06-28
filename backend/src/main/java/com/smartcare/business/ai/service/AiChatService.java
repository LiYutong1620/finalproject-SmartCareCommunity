package com.smartcare.business.ai.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.smartcare.business.ai.domain.*;
import com.smartcare.business.ai.mapper.*;
import com.smartcare.common.core.page.TableDataInfo;
import com.smartcare.common.exception.ServiceException;
import com.smartcare.framework.security.SecurityUtils;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class AiChatService {

    private static final int CONTEXT_MESSAGE_LIMIT = 10;
    private static final int MAX_IMAGES = 3;
    private static final List<String> TRANSFER_KEYWORDS = List.of(
        "转人工", "人工客服", "人工服务", "找客服", "联系客服", "投诉", "举报",
        "纠纷", "起诉", "律师", "法院", "报警", "维权", "赔偿"
    );

    private final AiChatSessionMapper sessionMapper;
    private final AiChatMessageMapper messageMapper;
    private final CsServiceTicketMapper ticketMapper;
    private final RagService ragService;

    @Transactional
    public Map<String, Object> ask(Long sessionId, String question, String inputType, List<String> images) {
        Long userId = requireUserId();
        List<String> imageList = normalizeImages(images);
        String q = requireQuestion(question, imageList);
        String type = resolveInputType(inputType, imageList);

        AiChatSession session = resolveSession(sessionId, userId, q);

        // 已转人工：进入人工对话模式，不再走 AI、不再新建工单
        if ("1".equals(session.getStatus())) {
            if (!imageList.isEmpty()) {
                throw new ServiceException("人工对话中请使用文字消息，如需识图请新建对话");
            }
            saveUserMessage(session.getSessionId(), q, type);
            touchSession(session);
            markTicketPending(session.getSessionId());

            Map<String, Object> result = new LinkedHashMap<>();
            result.put("sessionId", session.getSessionId());
            result.put("humanMode", true);
            result.put("transferHuman", false);
            result.put("ticketId", findTicketId(session.getSessionId()));
            result.put("message", null);
            return result;
        }

        // 人工对话已结束，不可继续发送
        if ("2".equals(session.getStatus())) {
            throw new ServiceException("该对话已结束，请点击「新对话」开始新的咨询");
        }

        List<AiChatMessage> priorMessages = loadPriorMessages(session.getSessionId());
        String contextHint = extractLastUserQuestion(priorMessages);

        saveUserMessage(session.getSessionId(), q, type);

        boolean transfer = shouldTransferHuman(q, contextHint);

        Map<String, Object> result = new LinkedHashMap<>();
        result.put("sessionId", session.getSessionId());

        if (transfer) {
            CsServiceTicket ticket = getOrCreateTicket(userId, session.getSessionId(), q, contextHint);
            session.setStatus("1");
            sessionMapper.updateById(session);

            String reply = "已为您接入人工客服，请在此对话中继续留言，物业人员将实时回复，请保持信号畅通。";
            AiChatMessage assistant = saveAssistantMessage(session.getSessionId(), reply, true,
                ticket.getTicketId(), null);

            result.put("transferHuman", true);
            result.put("ticketId", ticket.getTicketId());
            result.put("humanMode", true);
            result.put("message", toMessageMap(assistant));
            return result;
        }

        List<KbArticle> articles = ragService.search(q, contextHint);
        if (articles.isEmpty() && q.length() > 40 && imageList.isEmpty()) {
            CsServiceTicket ticket = getOrCreateTicket(userId, session.getSessionId(), q, contextHint);
            session.setStatus("1");
            sessionMapper.updateById(session);

            String reply = "您的问题较为复杂，已为您接入人工客服。请在此对话中继续留言，物业人员将实时回复，请保持信号畅通。";
            AiChatMessage assistant = saveAssistantMessage(session.getSessionId(), reply, true,
                ticket.getTicketId(), null);

            result.put("transferHuman", true);
            result.put("ticketId", ticket.getTicketId());
            result.put("humanMode", true);
            result.put("message", toMessageMap(assistant));
            return result;
        }

        String answer;
        if (!imageList.isEmpty()) {
            answer = ragService.generateAnswerWithVision(q, articles, imageList);
        } else {
            answer = ragService.generateAnswer(q, articles, priorMessages);
        }

        String refIds = articles.stream()
            .map(a -> String.valueOf(a.getArticleId()))
            .collect(Collectors.joining(","));
        AiChatMessage assistant = saveAssistantMessage(session.getSessionId(), answer, false, null, refIds);

        result.put("transferHuman", false);
        result.put("ticketId", null);
        result.put("message", toMessageMap(assistant));
        result.put("refArticles", articles.stream().map(this::toArticleBrief).collect(Collectors.toList()));
        return result;
    }

    public TableDataInfo listSessions(int pageNum, int pageSize) {
        Long userId = requireUserId();
        Page<AiChatSession> page = sessionMapper.selectPage(new Page<>(pageNum, pageSize),
            new LambdaQueryWrapper<AiChatSession>()
                .eq(AiChatSession::getUserId, userId)
                .orderByDesc(AiChatSession::getUpdateTime)
                .orderByDesc(AiChatSession::getCreateTime));

        List<Map<String, Object>> rows = new ArrayList<>();
        for (AiChatSession session : page.getRecords()) {
            Map<String, Object> row = new LinkedHashMap<>();
            row.put("sessionId", session.getSessionId());
            row.put("title", session.getTitle());
            row.put("status", session.getStatus());
            row.put("createTime", session.getCreateTime());
            row.put("updateTime", session.getUpdateTime());

            AiChatMessage last = messageMapper.selectOne(new LambdaQueryWrapper<AiChatMessage>()
                .eq(AiChatMessage::getSessionId, session.getSessionId())
                .orderByDesc(AiChatMessage::getCreateTime)
                .last("LIMIT 1"));
            if (last != null) {
                row.put("lastMessage", abbreviate(last.getContent(), 80));
                row.put("lastTime", last.getCreateTime());
            }
            rows.add(row);
        }
        return new TableDataInfo(page.getTotal(), rows);
    }

    public List<Map<String, Object>> listMessages(Long sessionId) {
        Long userId = requireUserId();
        AiChatSession session = sessionMapper.selectById(sessionId);
        if (session == null || !userId.equals(session.getUserId())) {
            throw new ServiceException("会话不存在");
        }
        List<AiChatMessage> messages = messageMapper.selectList(new LambdaQueryWrapper<AiChatMessage>()
            .eq(AiChatMessage::getSessionId, sessionId)
            .orderByAsc(AiChatMessage::getCreateTime));
        return messages.stream().map(this::toMessageMap).collect(Collectors.toList());
    }

    @Transactional
    public void closeSession(Long sessionId) {
        Long userId = requireUserId();
        AiChatSession session = sessionMapper.selectById(sessionId);
        if (session == null || !userId.equals(session.getUserId())) {
            throw new ServiceException("会话不存在");
        }
        if (!"1".equals(session.getStatus())) {
            throw new ServiceException("当前对话无法结束");
        }
        session.setStatus("2");
        session.setUpdateTime(LocalDateTime.now());
        sessionMapper.updateById(session);

        CsServiceTicket ticket = ticketMapper.selectOne(new LambdaQueryWrapper<CsServiceTicket>()
            .eq(CsServiceTicket::getSessionId, sessionId)
            .orderByDesc(CsServiceTicket::getCreateTime)
            .last("LIMIT 1"));
        if (ticket != null) {
            ticket.setStatus("2");
            ticketMapper.updateById(ticket);
        }
    }

    private Long requireUserId() {
        Long id = SecurityUtils.getUserId();
        if (id == null) {
            throw new ServiceException("未登录");
        }
        return id;
    }

    private String requireQuestion(String question, List<String> images) {
        if (!StringUtils.hasText(question)) {
            if (images != null && !images.isEmpty()) {
                return "请帮我看看图片中的问题";
            }
            throw new ServiceException("请输入问题");
        }
        String q = question.trim();
        if (q.length() > 2000) {
            throw new ServiceException("问题过长，请精简后重试");
        }
        return q;
    }

    private List<String> normalizeImages(List<String> images) {
        if (images == null || images.isEmpty()) {
            return List.of();
        }
        List<String> list = images.stream()
            .filter(StringUtils::hasText)
            .map(String::trim)
            .limit(MAX_IMAGES)
            .collect(Collectors.toList());
        if (list.size() > MAX_IMAGES) {
            throw new ServiceException("最多上传" + MAX_IMAGES + "张图片");
        }
        return list;
    }

    private String resolveInputType(String inputType, List<String> imageList) {
        if (!imageList.isEmpty()) {
            return "image";
        }
        return "voice".equalsIgnoreCase(inputType) ? "voice" : "text";
    }

    private AiChatSession resolveSession(Long sessionId, Long userId, String question) {
        if (sessionId != null) {
            AiChatSession session = sessionMapper.selectById(sessionId);
            if (session == null || !userId.equals(session.getUserId())) {
                throw new ServiceException("会话不存在");
            }
            session.setUpdateTime(LocalDateTime.now());
            sessionMapper.updateById(session);
            return session;
        }
        AiChatSession session = new AiChatSession();
        session.setUserId(userId);
        session.setTitle(abbreviate(question, 30));
        session.setStatus("0");
        sessionMapper.insert(session);
        return session;
    }

    private List<AiChatMessage> loadPriorMessages(Long sessionId) {
        if (sessionId == null) {
            return List.of();
        }
        return messageMapper.selectList(new LambdaQueryWrapper<AiChatMessage>()
            .eq(AiChatMessage::getSessionId, sessionId)
            .orderByAsc(AiChatMessage::getCreateTime)
            .last("LIMIT " + CONTEXT_MESSAGE_LIMIT));
    }

    private String extractLastUserQuestion(List<AiChatMessage> priorMessages) {
        for (int i = priorMessages.size() - 1; i >= 0; i--) {
            AiChatMessage m = priorMessages.get(i);
            if ("user".equals(m.getRole()) && StringUtils.hasText(m.getContent())) {
                return m.getContent().trim();
            }
        }
        return "";
    }

    private void saveUserMessage(Long sessionId, String content, String inputType) {
        AiChatMessage msg = new AiChatMessage();
        msg.setSessionId(sessionId);
        msg.setRole("user");
        msg.setContent(content);
        msg.setInputType(inputType);
        msg.setTransferHuman("0");
        messageMapper.insert(msg);
    }

    private AiChatMessage saveAssistantMessage(Long sessionId, String content, boolean transfer,
                                               Long ticketId, String refArticles) {
        AiChatMessage msg = new AiChatMessage();
        msg.setSessionId(sessionId);
        msg.setRole("assistant");
        msg.setContent(content);
        msg.setInputType("text");
        msg.setTransferHuman(transfer ? "1" : "0");
        msg.setTicketId(ticketId);
        msg.setRefArticles(refArticles != null ? refArticles : "");
        messageMapper.insert(msg);
        return msg;
    }

    private boolean shouldTransferHuman(String question, String contextHint) {
        String combined = (contextHint + " " + question).toLowerCase();
        for (String kw : TRANSFER_KEYWORDS) {
            if (combined.contains(kw.toLowerCase())) {
                return true;
            }
        }
        return false;
    }

    private CsServiceTicket getOrCreateTicket(Long userId, Long sessionId, String question, String contextHint) {
        CsServiceTicket existing = ticketMapper.selectOne(new LambdaQueryWrapper<CsServiceTicket>()
            .eq(CsServiceTicket::getSessionId, sessionId)
            .orderByDesc(CsServiceTicket::getCreateTime)
            .last("LIMIT 1"));
        if (existing != null) {
            return existing;
        }
        CsServiceTicket ticket = new CsServiceTicket();
        ticket.setUserId(userId);
        ticket.setSessionId(sessionId);
        String summary = StringUtils.hasText(contextHint) && !contextHint.equals(question)
            ? contextHint + " / " + question
            : question;
        ticket.setQuestion(abbreviate(summary, 500));
        ticket.setStatus("0");
        ticketMapper.insert(ticket);
        return ticket;
    }

    private void touchSession(AiChatSession session) {
        session.setUpdateTime(LocalDateTime.now());
        sessionMapper.updateById(session);
    }

    private void markTicketPending(Long sessionId) {
        CsServiceTicket ticket = ticketMapper.selectOne(new LambdaQueryWrapper<CsServiceTicket>()
            .eq(CsServiceTicket::getSessionId, sessionId)
            .orderByDesc(CsServiceTicket::getCreateTime)
            .last("LIMIT 1"));
        if (ticket != null && !"2".equals(ticket.getStatus())) {
            ticket.setStatus("0");
            ticketMapper.updateById(ticket);
        }
    }

    private Long findTicketId(Long sessionId) {
        CsServiceTicket ticket = ticketMapper.selectOne(new LambdaQueryWrapper<CsServiceTicket>()
            .eq(CsServiceTicket::getSessionId, sessionId)
            .orderByDesc(CsServiceTicket::getCreateTime)
            .last("LIMIT 1"));
        return ticket != null ? ticket.getTicketId() : null;
    }

    private Map<String, Object> toMessageMap(AiChatMessage m) {
        Map<String, Object> map = new LinkedHashMap<>();
        map.put("messageId", m.getMessageId());
        map.put("sessionId", m.getSessionId());
        map.put("role", m.getRole());
        map.put("senderName", m.getSenderName());
        map.put("content", m.getContent());
        map.put("inputType", m.getInputType());
        map.put("transferHuman", "1".equals(m.getTransferHuman()));
        map.put("ticketId", m.getTicketId());
        map.put("refArticles", m.getRefArticles());
        map.put("createTime", m.getCreateTime());
        return map;
    }

    private Map<String, Object> toArticleBrief(KbArticle a) {
        Map<String, Object> map = new LinkedHashMap<>();
        map.put("articleId", a.getArticleId());
        map.put("title", a.getTitle());
        return map;
    }

    private String abbreviate(String text, int max) {
        if (!StringUtils.hasText(text)) {
            return "";
        }
        String t = text.trim().replaceAll("\\s+", " ");
        return t.length() <= max ? t : t.substring(0, max) + "...";
    }
}
