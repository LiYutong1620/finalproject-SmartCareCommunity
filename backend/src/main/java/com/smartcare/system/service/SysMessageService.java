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
import java.util.List;

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

    public long unreadCount(Long userId) {
        return messageUserMapper.selectCount(
            new LambdaQueryWrapper<SysMessageUser>()
                .eq(SysMessageUser::getUserId, userId)
                .eq(SysMessageUser::getReadFlag, 0));
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

    public void updatePriority(Long messageId, String priority) {
        SysMessage msg = new SysMessage();
        msg.setMessageId(messageId);
        msg.setPriority(priority);
        messageMapper.updateById(msg);
    }
}
