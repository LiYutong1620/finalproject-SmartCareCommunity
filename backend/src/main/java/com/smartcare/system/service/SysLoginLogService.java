package com.smartcare.system.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.smartcare.system.domain.SysLoginLog;
import com.smartcare.system.mapper.SysLoginLogMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor
public class SysLoginLogService {

    private final SysLoginLogMapper loginLogMapper;

    public void save(SysLoginLog log) {
        if (log.getLoginTime() == null) {
            log.setLoginTime(LocalDateTime.now());
        }
        loginLogMapper.insert(log);
    }

    public Page<SysLoginLog> pageList(int pageNum, int pageSize, String username) {
        return loginLogMapper.selectPage(new Page<>(pageNum, pageSize),
            new LambdaQueryWrapper<SysLoginLog>()
                .like(StringUtils.hasText(username), SysLoginLog::getUsername, username)
                .orderByDesc(SysLoginLog::getLoginTime));
    }
}
