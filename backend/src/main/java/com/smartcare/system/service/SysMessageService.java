package com.smartcare.system.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.smartcare.common.exception.ServiceException;
import com.smartcare.system.domain.SysMessage;
import com.smartcare.system.domain.SysMessageUser;
import com.smartcare.system.mapper.SysMessageMapper;
import com.smartcare.system.mapper.SysMessageUserMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

@Service
@RequiredArgsConstructor
public class SysMessageService {

    private final SysMessageMapper messageMapper;
    private final SysMessageUserMapper messageUserMapper;

    @Value("${smartcare.msg-recall-minutes:2}")
    private int recallMinutes;

    @Transactional
    public void send(SysMessage message, List<Long> userIds) {
        message.setRecalled(0);
        messageMapper.insert(message);
        for (Long uid : userIds) {
            SysMessageUser mu = new SysMessageUser();
            mu.setMessageId(message.getMessageId());
            mu.setUserId(uid);
            mu.setReadFlag(0);
            messageUserMapper.insert(mu);
        }
    }

    public Page<SysMessage> listForUser(Long userId, int pageNum, int pageSize, String msgType) {
        List<Long> msgIds = messageUserMapper.selectList(
            new LambdaQueryWrapper<SysMessageUser>().eq(SysMessageUser::getUserId, userId))
            .stream().map(SysMessageUser::getMessageId).toList();
        if (msgIds.isEmpty()) {
            return new Page<>(pageNum, pageSize, 0);
        }
        LambdaQueryWrapper<SysMessage> qw = new LambdaQueryWrapper<SysMessage>()
            .in(SysMessage::getMessageId, msgIds)
            .eq(StringUtils.hasText(msgType), SysMessage::getMsgType, msgType)
            .orderByDesc(SysMessage::getCreateTime);
        return messageMapper.selectPage(new Page<>(pageNum, pageSize), qw);
    }

    public void markRead(Long messageId, Long userId) {
        SysMessageUser mu = messageUserMapper.selectOne(
            new LambdaQueryWrapper<SysMessageUser>()
                .eq(SysMessageUser::getMessageId, messageId)
                .eq(SysMessageUser::getUserId, userId));
        if (mu != null && mu.getReadFlag() == 0) {
            mu.setReadFlag(1);
            mu.setReadTime(LocalDateTime.now());
            messageUserMapper.updateById(mu);
        }
    }

    @Transactional
    public void markReadByBizId(Long userId, String bizId, String title) {
        if (!StringUtils.hasText(bizId)) {
            return;
        }
        List<SysMessage> messages = messageMapper.selectList(new LambdaQueryWrapper<SysMessage>()
            .eq(SysMessage::getBizId, bizId)
            .eq(StringUtils.hasText(title), SysMessage::getTitle, title));
        for (SysMessage msg : messages) {
            markRead(msg.getMessageId(), userId);
        }
    }

    public void recall(Long messageId, Long senderId) {
        SysMessage msg = messageMapper.selectById(messageId);
        if (msg == null) throw new ServiceException("消息不存在");
        if (!senderId.equals(msg.getSenderId())) throw new ServiceException("无权撤回");
        long minutes = ChronoUnit.MINUTES.between(msg.getCreateTime(), LocalDateTime.now());
        if (minutes > recallMinutes) throw new ServiceException("已超过撤回时限");
        msg.setRecalled(1);
        msg.setRecallTime(LocalDateTime.now());
        messageMapper.updateById(msg);
    }

    public long unreadCount(Long userId) {
        return unreadCount(userId, null);
    }

    public long unreadCount(Long userId, String msgType) {
        List<Long> msgIds = messageUserMapper.selectList(
            new LambdaQueryWrapper<SysMessageUser>()
                .eq(SysMessageUser::getUserId, userId)
                .eq(SysMessageUser::getReadFlag, 0))
            .stream().map(SysMessageUser::getMessageId).toList();
        if (msgIds.isEmpty()) {
            return 0;
        }
        LambdaQueryWrapper<SysMessage> qw = new LambdaQueryWrapper<SysMessage>()
            .in(SysMessage::getMessageId, msgIds)
            .eq(SysMessage::getRecalled, 0);
        if (StringUtils.hasText(msgType)) {
            qw.eq(SysMessage::getMsgType, msgType);
        }
        return messageMapper.selectCount(qw);
    }

    public Set<Long> findUnreadAppendOrderIds(Long userId) {
        Set<Long> ids = new HashSet<>();
        List<Long> msgIds = messageUserMapper.selectList(
            new LambdaQueryWrapper<SysMessageUser>()
                .eq(SysMessageUser::getUserId, userId)
                .eq(SysMessageUser::getReadFlag, 0))
            .stream().map(SysMessageUser::getMessageId).toList();
        if (msgIds.isEmpty()) {
            return ids;
        }
        List<SysMessage> messages = messageMapper.selectList(
            new LambdaQueryWrapper<SysMessage>()
                .in(SysMessage::getMessageId, msgIds)
                .eq(SysMessage::getMsgType, "order")
                .eq(SysMessage::getTitle, "业主补充信息"));
        for (SysMessage msg : messages) {
            if (StringUtils.hasText(msg.getBizId())) {
                try {
                    ids.add(Long.parseLong(msg.getBizId()));
                } catch (NumberFormatException ignored) {
                    // skip
                }
            }
        }
        return ids;
    }

    public List<Map<String, Object>> listRecentForUser(Long userId, String msgType, int limit, boolean unreadOnly) {
        List<SysMessageUser> relations = messageUserMapper.selectList(
            new LambdaQueryWrapper<SysMessageUser>()
                .eq(SysMessageUser::getUserId, userId)
                .eq(unreadOnly, SysMessageUser::getReadFlag, 0)
                .orderByDesc(SysMessageUser::getId)
                .last("LIMIT " + Math.min(limit, 50)));
        if (relations.isEmpty()) {
            return List.of();
        }
        List<Long> msgIds = relations.stream().map(SysMessageUser::getMessageId).toList();
        Map<Long, SysMessageUser> relMap = new LinkedHashMap<>();
        for (SysMessageUser rel : relations) {
            relMap.putIfAbsent(rel.getMessageId(), rel);
        }
        LambdaQueryWrapper<SysMessage> qw = new LambdaQueryWrapper<SysMessage>()
            .in(SysMessage::getMessageId, msgIds)
            .eq(SysMessage::getRecalled, 0);
        if (StringUtils.hasText(msgType)) {
            qw.eq(SysMessage::getMsgType, msgType);
        }
        List<SysMessage> messages = messageMapper.selectList(qw.orderByDesc(SysMessage::getCreateTime));
        List<Map<String, Object>> rows = new ArrayList<>();
        for (SysMessage msg : messages) {
            SysMessageUser rel = relMap.get(msg.getMessageId());
            if (rel == null) {
                continue;
            }
            Map<String, Object> row = new LinkedHashMap<>();
            row.put("messageId", msg.getMessageId());
            row.put("title", msg.getTitle());
            row.put("content", msg.getContent());
            row.put("bizId", msg.getBizId());
            row.put("createTime", msg.getCreateTime());
            row.put("readFlag", rel.getReadFlag());
            rows.add(row);
            if (rows.size() >= limit) {
                break;
            }
        }
        return rows;
    }

    public List<SysMessage> findUnreadByTitle(Long userId, String msgType, String title) {
        List<Long> msgIds = messageUserMapper.selectList(
            new LambdaQueryWrapper<SysMessageUser>()
                .eq(SysMessageUser::getUserId, userId)
                .eq(SysMessageUser::getReadFlag, 0))
            .stream().map(SysMessageUser::getMessageId).toList();
        if (msgIds.isEmpty()) {
            return List.of();
        }
        return messageMapper.selectList(new LambdaQueryWrapper<SysMessage>()
            .in(SysMessage::getMessageId, msgIds)
            .eq(SysMessage::getMsgType, msgType)
            .eq(SysMessage::getTitle, title)
            .eq(SysMessage::getRecalled, 0)
            .orderByDesc(SysMessage::getCreateTime));
    }

    public void updatePriority(Long messageId, String priority) {
        SysMessage msg = new SysMessage();
        msg.setMessageId(messageId);
        msg.setPriority(priority);
        messageMapper.updateById(msg);
    }
}
