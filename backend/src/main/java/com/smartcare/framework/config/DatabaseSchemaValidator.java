package com.smartcare.framework.config;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Component;

import java.util.List;

/**
 * 启动时检查合并 SQL 后的关键字段，避免登录时报模糊的系统异常。
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class DatabaseSchemaValidator implements ApplicationRunner {

    private final JdbcTemplate jdbcTemplate;

    private static final List<String> REQUIRED_COLUMNS = List.of(
        "sys_property_account.permission_code",
        "cm_resident.living_status",
        "el_care_order.check_result",
        "rp_order.expected_time"
    );

    @Override
    public void run(ApplicationArguments args) {
        for (String item : REQUIRED_COLUMNS) {
            String[] parts = item.split("\\.", 2);
            Integer count = jdbcTemplate.queryForObject(
                "SELECT COUNT(*) FROM information_schema.COLUMNS " +
                    "WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = ? AND COLUMN_NAME = ?",
                Integer.class, parts[0], parts[1]);
            if (count == null || count == 0) {
                log.error("缺少数据库字段 {}.{}，请执行 sql/smart_care_community.sql 整库导入，或 sql/upgrade_after_merge.sql 增量升级",
                    parts[0], parts[1]);
            }
        }
    }
}
