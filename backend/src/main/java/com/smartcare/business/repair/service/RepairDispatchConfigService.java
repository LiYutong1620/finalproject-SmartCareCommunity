package com.smartcare.business.repair.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.smartcare.system.domain.SysConfig;
import com.smartcare.system.mapper.SysConfigMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

@Service
@RequiredArgsConstructor
public class RepairDispatchConfigService {

    public static final String KEY_AUTO_DISPATCH = "repair.auto.dispatch";

    private final SysConfigMapper configMapper;

    public boolean isAutoDispatchEnabled() {
        SysConfig cfg = findConfig();
        if (cfg == null || !StringUtils.hasText(cfg.getConfigValue())) {
            return false;
        }
        return "true".equalsIgnoreCase(cfg.getConfigValue().trim())
            || "1".equals(cfg.getConfigValue().trim());
    }

    public void setAutoDispatchEnabled(boolean enabled) {
        SysConfig cfg = findConfig();
        if (cfg == null) {
            cfg = new SysConfig();
            cfg.setConfigName("报修自动派单");
            cfg.setConfigKey(KEY_AUTO_DISPATCH);
            cfg.setConfigValue(enabled ? "true" : "false");
            cfg.setRemark("业主提交报修后，AI分析完成且非高风险/非重复时自动派单");
            configMapper.insert(cfg);
            return;
        }
        cfg.setConfigValue(enabled ? "true" : "false");
        configMapper.updateById(cfg);
    }

    private SysConfig findConfig() {
        return configMapper.selectOne(new LambdaQueryWrapper<SysConfig>()
            .eq(SysConfig::getConfigKey, KEY_AUTO_DISPATCH)
            .last("LIMIT 1"));
    }
}
