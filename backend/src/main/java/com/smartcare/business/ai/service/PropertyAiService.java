package com.smartcare.business.ai.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.smartcare.business.ai.domain.AiChatMessage;
import com.smartcare.business.ai.domain.AiChatSession;
import com.smartcare.business.ai.domain.CsServiceTicket;
import com.smartcare.business.ai.domain.KbArticle;
import com.smartcare.business.ai.mapper.AiChatMessageMapper;
import com.smartcare.business.ai.mapper.AiChatSessionMapper;
import com.smartcare.business.ai.mapper.CsServiceTicketMapper;
import com.smartcare.business.ai.mapper.KbArticleMapper;
import com.smartcare.common.core.page.TableDataInfo;
import com.smartcare.common.exception.ServiceException;
import com.smartcare.framework.security.SecurityUtils;
import com.smartcare.system.domain.SysUser;
import com.smartcare.system.service.UserAccountService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class PropertyAiService {

    private final KbArticleMapper articleMapper;
    private final CsServiceTicketMapper ticketMapper;
    private final AiChatSessionMapper sessionMapper;
    private final AiChatMessageMapper messageMapper;
    private final UserAccountService accountService;

    public TableDataInfo listArticles(int pageNum, int pageSize, String title, String keywords, String content) {
        Page<KbArticle> page = articleMapper.selectPage(new Page<>(pageNum, pageSize),
            new LambdaQueryWrapper<KbArticle>()
                .like(StringUtils.hasText(title), KbArticle::getTitle, title)
                .like(StringUtils.hasText(keywords), KbArticle::getKeywords, keywords)
                .like(StringUtils.hasText(content), KbArticle::getContent, content)
                .orderByDesc(KbArticle::getCreateTime));
        return new TableDataInfo(page.getTotal(), page.getRecords());
    }

    public KbArticle getArticle(Long articleId) {
        KbArticle article = articleMapper.selectById(articleId);
        if (article == null) {
            throw new ServiceException("知识库文章不存在");
        }
        return article;
    }

    public void addArticle(KbArticle article) {
        validateArticle(article);
        article.setArticleId(null);
        articleMapper.insert(article);
    }

    public void updateArticle(KbArticle article) {
        if (article.getArticleId() == null) {
            throw new ServiceException("文章ID不能为空");
        }
        getArticle(article.getArticleId());
        validateArticle(article);
        articleMapper.updateById(article);
    }

    public void deleteArticle(Long articleId) {
        getArticle(articleId);
        articleMapper.deleteById(articleId);
    }

    /**
     * 对话列表。
     * scope=active：待处理（status=1）；scope=history：历史（status=0 AI / status=2 人工已结束）。
     * title、sessionType 可与 scope 组合筛选。
     */
    public TableDataInfo listSessions(int pageNum, int pageSize, String scope, String title, String sessionType) {
        LambdaQueryWrapper<AiChatSession> wrapper = new LambdaQueryWrapper<>();
        if ("active".equals(scope)) {
            wrapper.eq(AiChatSession::getStatus, "1");
        } else if ("history".equals(scope)) {
            if ("ai".equals(sessionType)) {
                wrapper.eq(AiChatSession::getStatus, "0");
            } else if ("human".equals(sessionType)) {
                wrapper.eq(AiChatSession::getStatus, "2");
            } else {
                wrapper.in(AiChatSession::getStatus, "0", "2");
            }
        } else {
            throw new ServiceException("无效的查询范围");
        }
        wrapper.like(StringUtils.hasText(title), AiChatSession::getTitle, title)
            .orderByDesc(AiChatSession::getUpdateTime)
            .orderByDesc(AiChatSession::getCreateTime);
        Page<AiChatSession> page = sessionMapper.selectPage(new Page<>(pageNum, pageSize), wrapper);

        Set<Long> userIds = page.getRecords().stream()
            .map(AiChatSession::getUserId)
            .filter(Objects::nonNull)
            .collect(Collectors.toSet());
        Map<Long, SysUser> userMap = loadUserMap(userIds);

        List<Map<String, Object>> rows = new ArrayList<>();
        for (AiChatSession session : page.getRecords()) {
            Map<String, Object> row = buildSessionRow(session, userMap.get(session.getUserId()));
            rows.add(row);
        }
        return new TableDataInfo(page.getTotal(), rows);
    }

    public Map<String, Object> getSession(Long sessionId) {
        AiChatSession session = requireViewableSession(sessionId);
        SysUser user = accountService.findById(session.getUserId());
        return buildSessionRow(session, user);
    }

    public List<Map<String, Object>> listSessionMessages(Long sessionId) {
        requireViewableSession(sessionId);
        List<AiChatMessage> messages = messageMapper.selectList(new LambdaQueryWrapper<AiChatMessage>()
            .eq(AiChatMessage::getSessionId, sessionId)
            .orderByAsc(AiChatMessage::getCreateTime));
        return messages.stream().map(this::toMessageMap).collect(Collectors.toList());
    }

    @Transactional
    public Map<String, Object> sendStaffMessage(Long sessionId, String content) {
        AiChatSession session = requireActiveHumanSession(sessionId);
        if (!StringUtils.hasText(content)) {
            throw new ServiceException("请输入回复内容");
        }
        String replyText = content.trim();
        session.setStatus("1");
        session.setUpdateTime(LocalDateTime.now());
        sessionMapper.updateById(session);

        CsServiceTicket ticket = findTicketBySession(sessionId);
        if (ticket != null) {
            ticket.setReply(replyText);
            ticket.setStatus("1");
            ticketMapper.updateById(ticket);
        }

        AiChatMessage msg = buildStaffMessage(sessionId, replyText, ticket != null ? ticket.getTicketId() : null);
        messageMapper.insert(msg);
        return toMessageMap(msg);
    }

    @Transactional
    public void closeHumanSession(Long sessionId) {
        AiChatSession session = requireHumanSession(sessionId);
        session.setStatus("2");
        session.setUpdateTime(LocalDateTime.now());
        sessionMapper.updateById(session);

        CsServiceTicket ticket = findTicketBySession(sessionId);
        if (ticket != null) {
            ticket.setStatus("2");
            ticketMapper.updateById(ticket);
        }
    }

    private Map<String, Object> buildSessionRow(AiChatSession session, SysUser user) {
        Map<String, Object> row = new LinkedHashMap<>();
        row.put("sessionId", session.getSessionId());
        row.put("userId", session.getUserId());
        row.put("title", session.getTitle());
        row.put("status", session.getStatus());
        row.put("sessionType", resolveSessionType(session.getStatus()));
        row.put("createTime", session.getCreateTime());
        row.put("updateTime", session.getUpdateTime());
        if (user != null) {
            row.put("username", user.getUsername());
            row.put("nickName", user.getNickName());
            row.put("phone", user.getPhone());
        }
        CsServiceTicket ticket = findTicketBySession(session.getSessionId());
        if (ticket != null) {
            row.put("ticketId", ticket.getTicketId());
        }
        AiChatMessage last = messageMapper.selectOne(new LambdaQueryWrapper<AiChatMessage>()
            .eq(AiChatMessage::getSessionId, session.getSessionId())
            .orderByDesc(AiChatMessage::getCreateTime)
            .last("LIMIT 1"));
        if (last != null) {
            row.put("lastMessage", abbreviate(last.getContent(), 80));
            row.put("lastTime", last.getCreateTime());
        }
        row.put("unreadCount", "1".equals(session.getStatus())
            ? countUnreadUserMessages(session.getSessionId()) : 0);
        return row;
    }

    private int countUnreadUserMessages(Long sessionId) {
        AiChatMessage lastStaff = messageMapper.selectOne(new LambdaQueryWrapper<AiChatMessage>()
            .eq(AiChatMessage::getSessionId, sessionId)
            .eq(AiChatMessage::getRole, "staff")
            .orderByDesc(AiChatMessage::getCreateTime)
            .last("LIMIT 1"));
        LocalDateTime since = lastStaff != null ? lastStaff.getCreateTime() : LocalDateTime.of(1970, 1, 1, 0, 0);
        Long count = messageMapper.selectCount(new LambdaQueryWrapper<AiChatMessage>()
            .eq(AiChatMessage::getSessionId, sessionId)
            .eq(AiChatMessage::getRole, "user")
            .gt(AiChatMessage::getCreateTime, since));
        return count != null ? count.intValue() : 0;
    }

    private AiChatSession requireActiveHumanSession(Long sessionId) {
        AiChatSession session = sessionMapper.selectById(sessionId);
        if (session == null || !"1".equals(session.getStatus())) {
            throw new ServiceException("对话不存在或已结束");
        }
        return session;
    }

    private AiChatSession requireViewableSession(Long sessionId) {
        AiChatSession session = sessionMapper.selectById(sessionId);
        if (session == null) {
            throw new ServiceException("对话不存在");
        }
        return session;
    }

    private AiChatSession requireHumanSession(Long sessionId) {
        AiChatSession session = sessionMapper.selectById(sessionId);
        if (session == null || (!"1".equals(session.getStatus()) && !"2".equals(session.getStatus()))) {
            throw new ServiceException("人工对话不存在");
        }
        return session;
    }

    private String resolveSessionType(String status) {
        if ("0".equals(status)) {
            return "ai";
        }
        if ("1".equals(status)) {
            return "human_active";
        }
        if ("2".equals(status)) {
            return "human_closed";
        }
        return "unknown";
    }

    private CsServiceTicket findTicketBySession(Long sessionId) {
        if (sessionId == null) {
            return null;
        }
        return ticketMapper.selectOne(new LambdaQueryWrapper<CsServiceTicket>()
            .eq(CsServiceTicket::getSessionId, sessionId)
            .orderByDesc(CsServiceTicket::getCreateTime)
            .last("LIMIT 1"));
    }

    private AiChatMessage buildStaffMessage(Long sessionId, String content, Long ticketId) {
        AiChatMessage msg = new AiChatMessage();
        msg.setSessionId(sessionId);
        msg.setRole("staff");
        msg.setContent(content);
        msg.setSenderName(resolveStaffDisplayName());
        msg.setInputType("text");
        msg.setTransferHuman("0");
        msg.setTicketId(ticketId);
        msg.setRefArticles("");
        return msg;
    }

    private String resolveStaffDisplayName() {
        SysUser user = SecurityUtils.getUser();
        if (user != null && StringUtils.hasText(user.getNickName())) {
            return user.getNickName().trim();
        }
        if (user != null && StringUtils.hasText(user.getUsername())) {
            return user.getUsername().trim();
        }
        return "物业客服";
    }

    private Map<String, Object> toMessageMap(AiChatMessage msg) {
        Map<String, Object> row = new LinkedHashMap<>();
        row.put("messageId", msg.getMessageId());
        row.put("sessionId", msg.getSessionId());
        row.put("role", msg.getRole());
        row.put("senderName", msg.getSenderName());
        row.put("content", msg.getContent());
        row.put("inputType", msg.getInputType());
        row.put("transferHuman", "1".equals(msg.getTransferHuman()));
        row.put("ticketId", msg.getTicketId());
        row.put("createTime", msg.getCreateTime());
        return row;
    }

    private void validateArticle(KbArticle article) {
        if (!StringUtils.hasText(article.getTitle())) {
            throw new ServiceException("标题不能为空");
        }
        if (!StringUtils.hasText(article.getContent())) {
            throw new ServiceException("正文不能为空");
        }
        if (article.getKeywords() == null) {
            article.setKeywords("");
        }
    }

    private Map<Long, SysUser> loadUserMap(Set<Long> userIds) {
        if (userIds.isEmpty()) {
            return Map.of();
        }
        List<SysUser> users = accountService.findByIds(new ArrayList<>(userIds));
        Map<Long, SysUser> map = new HashMap<>();
        for (SysUser user : users) {
            map.put(user.getUserId(), user);
        }
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
