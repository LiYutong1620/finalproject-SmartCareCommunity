-- 增量升级脚本（已有旧库时执行，无需整库重建）
-- 用法：mysql -uroot -p smart_care_community < sql/upgrade_after_merge.sql

USE smart_care_community;

-- 报修工单：期望上门时间
SET @col_exists = (
  SELECT COUNT(*) FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'rp_order' AND COLUMN_NAME = 'expected_time'
);
SET @sql = IF(@col_exists = 0,
  'ALTER TABLE rp_order ADD COLUMN expected_time datetime NULL DEFAULT NULL COMMENT ''期望上门时间'' AFTER duplicate_flag',
  'SELECT ''rp_order.expected_time already exists'' AS info');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- 统一消息表：与 BaseEntity 自动填充对齐（追加报修通知等依赖消息写入）
SET @col_exists = (
  SELECT COUNT(*) FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'sys_message' AND COLUMN_NAME = 'update_time'
);
SET @sql = IF(@col_exists = 0,
  'ALTER TABLE sys_message ADD COLUMN update_time datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT ''更新时间'' AFTER create_time',
  'SELECT ''sys_message.update_time already exists'' AS info');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- 维修工现场记录（到场/多次上门）
CREATE TABLE IF NOT EXISTS `rp_order_field_record` (
  `record_id` bigint NOT NULL AUTO_INCREMENT COMMENT '现场记录主键',
  `order_id` bigint NOT NULL COMMENT '工单ID',
  `worker_id` bigint NOT NULL COMMENT '维修工用户ID',
  `content` varchar(1024) NULL DEFAULT '' COMMENT '现场说明',
  `status` char(1) NOT NULL DEFAULT '0' COMMENT '0到场中 1已保存未完工 2已提交完工',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '到场时间',
  `submit_time` datetime NULL DEFAULT NULL COMMENT '提交完工时间',
  PRIMARY KEY (`record_id`),
  KEY `idx_order_id` (`order_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='维修工现场记录表';

CREATE TABLE IF NOT EXISTS `rp_order_field_image` (
  `image_id` bigint NOT NULL AUTO_INCREMENT COMMENT '图片主键',
  `record_id` bigint NOT NULL COMMENT '现场记录ID',
  `image_url` varchar(255) NOT NULL COMMENT '图片地址',
  PRIMARY KEY (`image_id`),
  KEY `idx_record_id` (`record_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='维修工现场记录图片表';

-- 工单号统一为短格式：RP + yyyyMMdd + 4位当日序号（14 字符）
-- 将旧长格式（20 位）按报修日期重新编号
UPDATE rp_order o
INNER JOIN (
  SELECT order_id,
         CONCAT('RP', DATE_FORMAT(create_time, '%Y%m%d'),
                LPAD(ROW_NUMBER() OVER (
                  PARTITION BY DATE(create_time)
                  ORDER BY create_time, order_id
                ), 4, '0')) AS new_no
  FROM rp_order
  WHERE CHAR_LENGTH(order_no) > 14
) m ON o.order_id = m.order_id
SET o.order_no = m.new_no;

-- 维修工资质：职级、证书审核、技能审核
SET @col_exists = (
  SELECT COUNT(*) FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'rp_worker_profile' AND COLUMN_NAME = 'worker_level'
);
SET @sql = IF(@col_exists = 0,
  'ALTER TABLE rp_worker_profile ADD COLUMN worker_level varchar(16) NULL DEFAULT ''初级'' COMMENT ''职级'' AFTER work_status',
  'SELECT ''rp_worker_profile.worker_level exists'' AS info');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @col_exists = (
  SELECT COUNT(*) FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'rp_worker_profile' AND COLUMN_NAME = 'cert_audit_status'
);
SET @sql = IF(@col_exists = 0,
  'ALTER TABLE rp_worker_profile ADD COLUMN cert_audit_status char(1) NULL DEFAULT ''1'' COMMENT ''证书审核'' AFTER cert_expire',
  'SELECT ''rp_worker_profile.cert_audit_status exists'' AS info');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @col_exists = (
  SELECT COUNT(*) FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'rp_worker_skill' AND COLUMN_NAME = 'audit_status'
);
SET @sql = IF(@col_exists = 0,
  'ALTER TABLE rp_worker_skill ADD COLUMN audit_status char(1) NULL DEFAULT ''1'' COMMENT ''审核状态'' AFTER skill_level',
  'SELECT ''rp_worker_skill.audit_status exists'' AS info');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

UPDATE rp_worker_profile SET worker_level = '初级' WHERE worker_level IS NULL OR worker_level = '';
UPDATE rp_worker_profile SET cert_audit_status = '1' WHERE cert_audit_status IS NULL;
UPDATE rp_worker_skill SET audit_status = '1' WHERE audit_status IS NULL;
UPDATE rp_worker_profile SET work_status = 'available' WHERE work_status = 'offline';

-- 技能申请说明
SET @col_exists = (
  SELECT COUNT(*) FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'rp_worker_skill' AND COLUMN_NAME = 'apply_remark'
);
SET @sql = IF(@col_exists = 0,
  'ALTER TABLE rp_worker_skill ADD COLUMN apply_remark varchar(512) NULL DEFAULT '''' COMMENT ''申请说明'' AFTER audit_status',
  'SELECT ''rp_worker_skill.apply_remark exists'' AS info');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- 多证书表
CREATE TABLE IF NOT EXISTS `rp_worker_certificate` (
  `cert_id` bigint NOT NULL AUTO_INCREMENT COMMENT '证书主键',
  `worker_id` bigint NOT NULL COMMENT '维修工用户ID',
  `cert_name` varchar(64) NOT NULL COMMENT '证书名称',
  `cert_expire` date NULL DEFAULT NULL COMMENT '有效期',
  `related_skill` varchar(64) NULL DEFAULT '' COMMENT '关联技能',
  `apply_remark` varchar(512) NULL DEFAULT '' COMMENT '申请说明',
  `audit_status` char(1) NULL DEFAULT '1' COMMENT '审核状态',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '提交时间',
  PRIMARY KEY (`cert_id`),
  KEY `idx_worker_cert` (`worker_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='维修工证书表';

-- 从档案表迁移已有证书（仅当证书表为空时）
INSERT INTO rp_worker_certificate (worker_id, cert_name, cert_expire, related_skill, apply_remark, audit_status, create_time)
SELECT p.worker_id, p.cert_name, p.cert_expire, '', '历史数据迁移', IFNULL(p.cert_audit_status, '1'), NOW()
FROM rp_worker_profile p
WHERE p.cert_name IS NOT NULL AND p.cert_name != ''
  AND NOT EXISTS (SELECT 1 FROM rp_worker_certificate c WHERE c.worker_id = p.worker_id LIMIT 1);

-- ========== 老人关怀：居住状态 + 标签精简 ==========

SET @col_exists = (
  SELECT COUNT(*) FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'cm_resident' AND COLUMN_NAME = 'living_status'
);
SET @sql = IF(@col_exists = 0,
  'ALTER TABLE cm_resident ADD COLUMN living_status char(1) NULL DEFAULT ''1'' COMMENT ''居住状态：1在住 2搬离 3临时外出'' AFTER del_flag',
  'SELECT ''cm_resident.living_status exists'' AS info');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @col_exists = (
  SELECT COUNT(*) FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'cm_resident' AND COLUMN_NAME = 'is_primary_resident'
);
SET @sql = IF(@col_exists = 0,
  'ALTER TABLE cm_resident ADD COLUMN is_primary_resident tinyint NULL DEFAULT 1 COMMENT ''是否实际居住人：1是 0否'' AFTER living_status',
  'SELECT ''cm_resident.is_primary_resident exists'' AS info');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

UPDATE cm_resident SET living_status = '1' WHERE living_status IS NULL OR living_status = '';
UPDATE cm_resident SET is_primary_resident = 1 WHERE is_primary_resident IS NULL;

-- 精简标签：仅保留独居老人/高龄老人/重点关注
UPDATE cm_resident_tag_rel SET tag_id = 3 WHERE tag_id = 5;
DELETE FROM cm_resident_tag_rel WHERE tag_id NOT IN (1, 2, 3);
DELETE FROM cm_resident_tag WHERE tag_id NOT IN (1, 2, 3);
UPDATE cm_resident_tag SET tag_name = '独居老人', tag_type = 'auto' WHERE tag_id = 1;
UPDATE cm_resident_tag SET tag_name = '高龄老人', tag_type = 'auto' WHERE tag_id = 2;
INSERT IGNORE INTO cm_resident_tag (tag_id, tag_name, tag_type) VALUES (3, '重点关注', 'manual');

CREATE TABLE IF NOT EXISTS `el_temp_guardian` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `resident_id` bigint NOT NULL COMMENT '老人住户ID',
  `guardian_name` varchar(64) NOT NULL COMMENT '临时监护人姓名',
  `guardian_phone` varchar(20) NOT NULL COMMENT '临时监护人电话',
  `start_time` datetime NOT NULL COMMENT '监护开始时间',
  `end_time` datetime NOT NULL COMMENT '监护结束时间',
  `status` char(1) DEFAULT '1' COMMENT '状态：1有效 0已失效',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_resident` (`resident_id`),
  KEY `idx_time` (`start_time`, `end_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='老人临时监护登记表';

-- ========== 三端账号分表（从 sys_user 迁移）==========
-- 已有库执行：将统一 sys_user 拆为业主/维修工/物业账号表
-- 全新安装请直接执行 smart_care_community.sql

SET @has_sys_user = (
  SELECT COUNT(*) FROM information_schema.TABLES
  WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'sys_user'
);
SET @has_owner_acct = (
  SELECT COUNT(*) FROM information_schema.TABLES
  WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'sys_owner_account'
);

-- 维修工档案扩展字段
SET @col_exists = (
  SELECT COUNT(*) FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'rp_worker_profile' AND COLUMN_NAME = 'real_name'
);
SET @sql = IF(@col_exists = 0,
  'ALTER TABLE rp_worker_profile ADD COLUMN real_name varchar(64) NULL DEFAULT '''' COMMENT ''姓名'' AFTER worker_id, ADD COLUMN phone varchar(20) NULL DEFAULT '''' COMMENT ''手机号'' AFTER real_name, ADD COLUMN gender char(1) NULL DEFAULT '''' COMMENT ''性别'' AFTER phone, ADD COLUMN age int NULL DEFAULT NULL COMMENT ''年龄'' AFTER gender, ADD COLUMN avatar varchar(255) NULL DEFAULT '''' COMMENT ''头像'' AFTER age',
  'SELECT ''rp_worker_profile profile cols exist'' AS info');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- 从旧 sys_user 回填维修工档案姓名/电话（仅空值时）
UPDATE rp_worker_profile p
JOIN sys_user u ON u.user_id = p.worker_id AND u.user_type IN ('1')
SET p.real_name = IFNULL(NULLIF(p.real_name, ''), u.nick_name),
    p.phone = IFNULL(NULLIF(p.phone, ''), u.phone),
    p.gender = IFNULL(NULLIF(p.gender, ''), u.gender),
    p.age = IFNULL(p.age, u.age),
    p.avatar = IFNULL(NULLIF(p.avatar, ''), u.avatar)
WHERE @has_sys_user > 0;

CREATE TABLE IF NOT EXISTS `pm_staff` (
  `staff_id` bigint NOT NULL AUTO_INCREMENT COMMENT '物业人员ID',
  `name` varchar(64) NOT NULL COMMENT '姓名',
  `gender` char(1) DEFAULT '' COMMENT '性别',
  `age` int DEFAULT NULL COMMENT '年龄',
  `phone` varchar(20) DEFAULT '' COMMENT '手机号',
  `avatar` varchar(255) DEFAULT '' COMMENT '头像',
  `dept` varchar(64) DEFAULT '' COMMENT '部门',
  `del_flag` char(1) DEFAULT '0' COMMENT '删除：0存在 2删除',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`staff_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='物业人员档案表';

CREATE TABLE IF NOT EXISTS `sys_owner_account` (
  `account_id` bigint NOT NULL AUTO_INCREMENT COMMENT '业主账号ID',
  `username` varchar(64) NOT NULL COMMENT '登录账号',
  `password` varchar(128) NOT NULL COMMENT 'BCrypt密码',
  `resident_id` bigint DEFAULT NULL COMMENT '关联住户档案ID',
  `status` char(1) DEFAULT '0' COMMENT '0正常 1停用',
  `del_flag` char(1) DEFAULT '0' COMMENT '0存在 2删除',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`account_id`),
  UNIQUE KEY `uk_owner_username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='业主登录账号表';

CREATE TABLE IF NOT EXISTS `sys_worker_account` (
  `account_id` bigint NOT NULL AUTO_INCREMENT COMMENT '维修工账号ID',
  `username` varchar(64) NOT NULL COMMENT '登录账号',
  `password` varchar(128) NOT NULL COMMENT 'BCrypt密码',
  `status` char(1) DEFAULT '0' COMMENT '0正常 1停用',
  `del_flag` char(1) DEFAULT '0' COMMENT '0存在 2删除',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`account_id`),
  UNIQUE KEY `uk_worker_username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='维修工登录账号表';

CREATE TABLE IF NOT EXISTS `sys_property_account` (
  `account_id` bigint NOT NULL AUTO_INCREMENT COMMENT '物业账号ID',
  `username` varchar(64) NOT NULL COMMENT '登录账号',
  `password` varchar(128) NOT NULL COMMENT 'BCrypt密码',
  `staff_id` bigint DEFAULT NULL COMMENT '关联物业人员档案',
  `permission_code` varchar(512) DEFAULT NULL COMMENT '权限码',
  `status` char(1) DEFAULT '0' COMMENT '0正常 1停用',
  `del_flag` char(1) DEFAULT '0' COMMENT '0存在 2删除',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`account_id`),
  UNIQUE KEY `uk_property_username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='物业登录账号表';

-- 迁移数据（仅当 sys_user 存在且分表为空）
INSERT INTO pm_staff (staff_id, name, gender, age, phone, avatar, dept, del_flag, create_time, update_time)
SELECT u.user_id, u.nick_name, IFNULL(u.gender,''), u.age, IFNULL(u.phone,''), IFNULL(u.avatar,''), '物业管理部', IFNULL(u.del_flag,'0'), u.create_time, u.update_time
FROM sys_user u
WHERE u.user_type IN ('2','3') AND u.del_flag = '0'
  AND @has_sys_user > 0 AND @has_owner_acct = 0
  AND NOT EXISTS (SELECT 1 FROM pm_staff s WHERE s.staff_id = u.user_id);

INSERT INTO sys_owner_account (account_id, username, password, resident_id, status, del_flag, create_time, update_time)
SELECT u.user_id, u.username, u.password,
       (SELECT r.resident_id FROM cm_resident r WHERE r.user_id = u.user_id AND r.del_flag = '0' LIMIT 1),
       IFNULL(u.status,'0'), IFNULL(u.del_flag,'0'), u.create_time, u.update_time
FROM sys_user u
WHERE u.user_type = '0' AND u.del_flag = '0'
  AND @has_sys_user > 0 AND @has_owner_acct = 0
  AND NOT EXISTS (SELECT 1 FROM sys_owner_account o WHERE o.account_id = u.user_id);

INSERT INTO sys_worker_account (account_id, username, password, status, del_flag, create_time, update_time)
SELECT u.user_id, u.username, u.password, IFNULL(u.status,'0'), IFNULL(u.del_flag,'0'), u.create_time, u.update_time
FROM sys_user u
WHERE u.user_type = '1' AND u.del_flag = '0'
  AND @has_sys_user > 0 AND @has_owner_acct = 0
  AND NOT EXISTS (SELECT 1 FROM sys_worker_account w WHERE w.account_id = u.user_id);

INSERT INTO sys_property_account (account_id, username, password, staff_id, permission_code, status, del_flag, create_time, update_time)
SELECT u.user_id, u.username, u.password, u.user_id, u.permission_code, IFNULL(u.status,'0'), IFNULL(u.del_flag,'0'), u.create_time, u.update_time
FROM sys_user u
WHERE u.user_type IN ('2','3') AND u.del_flag = '0'
  AND @has_sys_user > 0 AND @has_owner_acct = 0
  AND NOT EXISTS (SELECT 1 FROM sys_property_account p WHERE p.account_id = u.user_id);

-- 迁移完成后可手动 DROP sys_user（保留以便回滚时可对照）
-- DROP TABLE IF EXISTS sys_user;

-- 清理未使用的历史表（代码中无引用，可安全删除）
DROP TABLE IF EXISTS `el_device`;
DROP TABLE IF EXISTS `el_visit_plan`;
DROP TABLE IF EXISTS `sys_dict_data`;
DROP TABLE IF EXISTS `sys_dict_type`;
DROP TABLE IF EXISTS `sys_flow_switch`;
DROP TABLE IF EXISTS `sys_abnormal_login`;
DROP TABLE IF EXISTS `sys_user_device`;
DROP TABLE IF EXISTS `sys_oper_log`;
DROP TABLE IF EXISTS `rp_worker_appeal`;
DROP TABLE IF EXISTS `rp_work_hour`;
DROP TABLE IF EXISTS `rp_material`;
-- ========== 住户档案：产权人 + 紧急联系人拆分 ==========
SET @col_exists = (SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='cm_resident' AND COLUMN_NAME='is_owner');
SET @sql = IF(@col_exists=0,
  'ALTER TABLE cm_resident
    ADD COLUMN is_owner tinyint NULL DEFAULT 1 COMMENT ''是否产权人'' AFTER living_status,
    ADD COLUMN owner_name varchar(64) NULL DEFAULT '''' COMMENT ''产权人姓名'' AFTER is_owner,
    ADD COLUMN owner_phone varchar(20) NULL DEFAULT '''' COMMENT ''产权人电话'' AFTER owner_name,
    ADD COLUMN owner_relation varchar(16) NULL DEFAULT '''' COMMENT ''与产权人关系'' AFTER owner_phone,
    ADD COLUMN emergency_name varchar(64) NULL DEFAULT '''' COMMENT ''紧急联系人姓名'' AFTER owner_relation,
    ADD COLUMN emergency_phone varchar(20) NULL DEFAULT '''' COMMENT ''紧急联系人电话'' AFTER emergency_name,
    ADD COLUMN emergency_relation varchar(16) NULL DEFAULT '''' COMMENT ''与住户关系'' AFTER emergency_phone,
    MODIFY COLUMN living_status char(1) NULL DEFAULT ''1'' COMMENT ''1在住 2空置 3出租'',
    MODIFY COLUMN emergency_contact varchar(64) NULL DEFAULT '''' COMMENT ''遗留合并字段''',
  'SELECT ''cm_resident owner/emergency cols exist'' AS info');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

UPDATE cm_resident SET is_owner=1, owner_relation='本人' WHERE is_owner IS NULL;
UPDATE cm_resident SET emergency_name=TRIM(SUBSTRING_INDEX(emergency_contact,' ',1)), emergency_phone=TRIM(SUBSTRING_INDEX(emergency_contact,' ',-1))
  WHERE (emergency_name IS NULL OR emergency_name='') AND emergency_contact LIKE '% %' AND LENGTH(emergency_contact)>11;

-- ========== 住户标签：重点关注改为手动标签 ==========
UPDATE cm_resident_tag SET tag_name='重点关注', tag_type='manual' WHERE tag_id=3;
INSERT IGNORE INTO cm_resident_tag_rel (resident_id, tag_id) VALUES (10, 3);

-- ========== 老人演示数据：补业主账号并绑定住户档案（account_id 29-38） ==========
INSERT IGNORE INTO sys_owner_account (account_id, username, password, resident_id, status, del_flag, create_time, update_time)
VALUES
(29, 'owner16', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', 16, '0', '0', '2026-06-01 08:00:00', '2026-06-01 08:00:00'),
(30, 'owner17', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', 17, '0', '0', '2026-06-01 08:00:00', '2026-06-01 08:00:00'),
(31, 'owner18', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', 18, '0', '0', '2026-06-01 08:00:00', '2026-06-01 08:00:00'),
(32, 'owner19', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', 19, '0', '0', '2026-06-01 08:00:00', '2026-06-01 08:00:00'),
(33, 'owner20', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', 20, '0', '0', '2026-06-01 08:00:00', '2026-06-01 08:00:00'),
(34, 'owner21', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', 21, '0', '0', '2026-06-01 08:00:00', '2026-06-01 08:00:00'),
(35, 'owner22', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', 22, '0', '0', '2026-06-01 08:00:00', '2026-06-01 08:00:00'),
(36, 'owner23', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', 23, '0', '0', '2026-06-01 08:00:00', '2026-06-01 08:00:00'),
(37, 'owner24', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', 24, '0', '0', '2026-06-01 08:00:00', '2026-06-01 08:00:00'),
(38, 'owner25', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', 25, '0', '0', '2026-06-01 08:00:00', '2026-06-01 08:00:00');

UPDATE cm_resident SET user_id=29 WHERE resident_id=16 AND user_id IS NULL;
UPDATE cm_resident SET user_id=30 WHERE resident_id=17 AND user_id IS NULL;
UPDATE cm_resident SET user_id=31 WHERE resident_id=18 AND user_id IS NULL;
UPDATE cm_resident SET user_id=32 WHERE resident_id=19 AND user_id IS NULL;
UPDATE cm_resident SET user_id=33 WHERE resident_id=20 AND user_id IS NULL;
UPDATE cm_resident SET user_id=34 WHERE resident_id=21 AND user_id IS NULL;
UPDATE cm_resident SET user_id=35 WHERE resident_id=22 AND user_id IS NULL;
UPDATE cm_resident SET user_id=36 WHERE resident_id=23 AND user_id IS NULL;
UPDATE cm_resident SET user_id=37 WHERE resident_id=24 AND user_id IS NULL;
UPDATE cm_resident SET user_id=38 WHERE resident_id=25 AND user_id IS NULL;

INSERT IGNORE INTO sys_user_role (user_id, role_id) VALUES
(29, 2), (30, 2), (31, 2), (32, 2), (33, 2), (34, 2), (35, 2), (36, 2), (37, 2), (38, 2);

-- ========== 业主账号：待绑定姓名/手机号（与业主管理、住户档案自动关联） ==========
SET @col_exists = (SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='sys_owner_account' AND COLUMN_NAME='bind_phone');
SET @sql = IF(@col_exists=0,
  'ALTER TABLE sys_owner_account
    ADD COLUMN bind_name varchar(64) NULL DEFAULT NULL COMMENT ''待绑定姓名'' AFTER resident_id,
    ADD COLUMN bind_phone varchar(20) NULL DEFAULT NULL COMMENT ''待绑定手机号'' AFTER bind_name',
  'SELECT ''sys_owner_account.bind_phone exists'' AS info');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

UPDATE sys_owner_account o
INNER JOIN cm_resident r ON r.resident_id = o.resident_id AND r.del_flag = '0'
SET o.bind_name = NULL, o.bind_phone = NULL
WHERE o.resident_id IS NOT NULL;

UPDATE sys_owner_account o
INNER JOIN cm_resident r ON r.user_id = o.account_id AND r.del_flag = '0'
SET o.resident_id = r.resident_id, o.bind_name = NULL, o.bind_phone = NULL
WHERE o.resident_id IS NULL;

-- 业主账号：待绑定性别/年龄（个人中心，未关联住户档案时使用）
SET @col_exists = (SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='sys_owner_account' AND COLUMN_NAME='bind_gender');
SET @sql = IF(@col_exists=0,
  'ALTER TABLE sys_owner_account
    ADD COLUMN bind_gender char(1) NULL DEFAULT NULL COMMENT ''待绑定性别'' AFTER bind_phone,
    ADD COLUMN bind_age int NULL DEFAULT NULL COMMENT ''待绑定年龄'' AFTER bind_gender',
  'SELECT ''sys_owner_account.bind_gender exists'' AS info');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

UPDATE cm_house h
INNER JOIN cm_resident r ON r.house_id = h.house_id AND r.del_flag = '0'
SET h.owner_name = r.name
WHERE r.name IS NOT NULL AND r.name != '';

DELETE tr FROM cm_resident_tag_rel tr
INNER JOIN cm_resident r ON r.resident_id = tr.resident_id AND tr.tag_id = 3
WHERE r.del_flag = '0' AND r.age >= 60 AND IFNULL(r.living_status, '1') = '1';

-- ========== 关怀人员类型表 ==========
CREATE TABLE IF NOT EXISTS `el_care_staff_type` (
  `type_id` bigint NOT NULL AUTO_INCREMENT COMMENT '类型主键',
  `type_name` varchar(32) NOT NULL COMMENT '类型名称',
  `sort_order` int NULL DEFAULT 0 COMMENT '排序',
  PRIMARY KEY (`type_id`),
  UNIQUE KEY `uk_type_name` (`type_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='关怀人员类型表';

INSERT IGNORE INTO `el_care_staff_type` (`type_id`, `type_name`, `sort_order`) VALUES
(1, '网格员', 1),
(2, '安保', 2),
(3, '志愿者', 3),
(4, '物业', 4),
(5, '护理员', 5),
(6, '医生', 6),
(7, '护士', 7),
(8, '康复师', 8);

SET @col_exists = (
  SELECT COUNT(*) FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'el_care_staff' AND COLUMN_NAME = 'staff_type'
    AND CHARACTER_MAXIMUM_LENGTH < 32
);
SET @sql = IF(@col_exists > 0,
  'ALTER TABLE el_care_staff MODIFY COLUMN staff_type varchar(32) NULL DEFAULT ''网格员'' COMMENT ''人员类型名称''',
  'SELECT ''el_care_staff.staff_type already widened'' AS info');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

UPDATE el_care_staff SET staff_type = '网格员' WHERE staff_type = 'grid';
UPDATE el_care_staff SET staff_type = '安保' WHERE staff_type = 'security';
UPDATE el_care_staff SET staff_type = '志愿者' WHERE staff_type = 'volunteer';
UPDATE el_care_staff SET staff_type = '物业' WHERE staff_type = 'property';

INSERT IGNORE INTO el_care_staff_type (type_name, sort_order)
SELECT DISTINCT staff_type, 99 FROM el_care_staff
WHERE staff_type IS NOT NULL AND staff_type != ''
  AND staff_type NOT IN (SELECT type_name FROM el_care_staff_type);

-- 关怀工单关联预警（一预警一工单）
SET @col_exists = (
  SELECT COUNT(*) FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'el_care_order' AND COLUMN_NAME = 'alert_id'
);
SET @sql = IF(@col_exists = 0,
  'ALTER TABLE el_care_order ADD COLUMN alert_id bigint NULL DEFAULT NULL COMMENT ''关联预警ID'' AFTER level',
  'SELECT ''el_care_order.alert_id already exists'' AS info');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- 预警开始处理时间
SET @col_exists = (
  SELECT COUNT(*) FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'el_alert' AND COLUMN_NAME = 'process_start_time'
);
SET @sql = IF(@col_exists = 0,
  'ALTER TABLE el_alert ADD COLUMN process_start_time datetime NULL DEFAULT NULL COMMENT ''开始处理时间'' AFTER handler_id',
  'SELECT ''el_alert.process_start_time already exists'' AS info');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- ============================================================
-- 清空旧版 AI 监测 / demo 预警数据（方案 B 水电监测上线后执行一次）
-- 含：跌倒/心率/活动监测种子、定时任务重复产生的 utility_anomaly 等
-- ============================================================
DELETE FROM el_disposal_record WHERE alert_id IS NOT NULL OR care_id IS NOT NULL;
DELETE FROM el_ai_monitor_log;
DELETE FROM el_care_order;
DELETE FROM el_alert;
ALTER TABLE el_alert AUTO_INCREMENT = 1;
ALTER TABLE el_care_order AUTO_INCREMENT = 1;
ALTER TABLE el_ai_monitor_log AUTO_INCREMENT = 1;

-- ============================================================
-- 维修工技能/证书审核意见（驳回原因）
-- ============================================================
SET @col_exists = (
  SELECT COUNT(*) FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'rp_worker_skill' AND COLUMN_NAME = 'audit_remark'
);
SET @sql = IF(@col_exists = 0,
  'ALTER TABLE rp_worker_skill ADD COLUMN audit_remark varchar(512) NULL DEFAULT '''' COMMENT ''审核意见'' AFTER apply_remark',
  'SELECT ''rp_worker_skill.audit_remark exists'' AS info');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @col_exists = (
  SELECT COUNT(*) FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'rp_worker_certificate' AND COLUMN_NAME = 'audit_remark'
);
SET @sql = IF(@col_exists = 0,
  'ALTER TABLE rp_worker_certificate ADD COLUMN audit_remark varchar(512) NULL DEFAULT '''' COMMENT ''审核意见'' AFTER audit_status',
  'SELECT ''rp_worker_certificate.audit_remark exists'' AS info');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- ============================================================
-- 报修类型：典型关键词 + 五级分类体系（便于 AI 识别）
-- ============================================================
SET @col_exists = (
  SELECT COUNT(*) FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'rp_repair_type' AND COLUMN_NAME = 'keywords'
);
SET @sql = IF(@col_exists = 0,
  'ALTER TABLE rp_repair_type ADD COLUMN keywords varchar(512) NULL DEFAULT '''' COMMENT ''典型关键词'' AFTER order_num',
  'SELECT ''rp_repair_type.keywords exists'' AS info');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

UPDATE rp_order SET type_id = 8 WHERE type_id = 4 AND description LIKE '%跳闸%';
UPDATE rp_order SET type_id = 12 WHERE type_id = 4 AND (description LIKE '%短路%' OR description LIKE '%烧焦%');
UPDATE rp_order SET type_id = 14 WHERE type_id = 4 AND description LIKE '%空调%';
UPDATE rp_order SET type_id = 28 WHERE type_id = 4 AND description LIKE '%灯%';
UPDATE rp_order SET type_id = 9 WHERE type_id = 4 AND description LIKE '%插座%';
UPDATE rp_order SET type_id = 8 WHERE type_id = 4;

DELETE FROM rp_repair_type;

INSERT INTO rp_repair_type (type_id, parent_id, type_name, order_num, keywords) VALUES
(1, 0, '水管问题', 1, '漏水,滴水,堵塞,下水慢,冒水,关不紧,不出水'),
(2, 1, '水管漏水', 1, ''),
(3, 1, '下水道堵塞', 2, ''),
(4, 1, '水龙头/阀门损坏', 3, ''),
(5, 1, '马桶/洁具故障', 4, ''),
(6, 1, '热水器故障', 5, ''),
(7, 0, '电路问题', 2, '跳闸,断电,没电,冒火花,烧焦味,接触不良'),
(8, 7, '电路跳闸', 1, ''),
(9, 7, '插座/开关损坏', 2, ''),
(10, 7, '灯具照明故障', 3, ''),
(11, 7, '配电箱/电表异常', 4, ''),
(12, 7, '线路老化/烧焦', 5, ''),
(13, 0, '家电问题', 3, '不制冷,不启动,噪音大,门打不开,无法联网'),
(14, 13, '空调故障', 1, ''),
(15, 13, '冰箱/冰柜故障', 2, ''),
(16, 13, '洗衣机/烘干机故障', 3, ''),
(17, 13, '烟机/灶具故障', 4, ''),
(18, 13, '智能门锁/门禁故障', 5, ''),
(19, 0, '房屋问题', 4, '关不上,打不开,裂缝,空鼓,掉皮,发霉'),
(20, 19, '门窗/锁具损坏', 1, ''),
(21, 19, '墙面/地面破损', 2, ''),
(22, 19, '吊顶/柜子松动', 3, ''),
(23, 19, '防水层渗漏', 4, ''),
(24, 0, '公共问题', 5, '电梯异响,停机,网连不上,没信号,灯不亮'),
(25, 24, '电梯故障', 1, ''),
(26, 24, '网络/电视/信号故障', 2, ''),
(27, 24, '监控/道闸故障', 3, ''),
(28, 24, '公区照明故障', 4, '');

ALTER TABLE rp_repair_type AUTO_INCREMENT = 29;

INSERT INTO sys_config (config_name, config_key, config_value, remark)
SELECT '报修自动派单', 'repair.auto.dispatch', 'false', '业主提交报修后，AI分析完成时是否自动派单（false=待物业分配）'
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM sys_config WHERE config_key = 'repair.auto.dispatch' LIMIT 1);

UPDATE sys_config SET config_value = 'false',
  remark = '业主提交报修后，AI分析完成时是否自动派单（false=待物业分配）'
WHERE config_key = 'repair.auto.dispatch';

-- ============================================================
-- 工单复盘周报表
-- ============================================================
CREATE TABLE IF NOT EXISTS `rp_repair_weekly_report` (
  `report_id` bigint NOT NULL AUTO_INCREMENT COMMENT '周报主键',
  `week_start` date NOT NULL COMMENT '周起始日期',
  `week_end` date NOT NULL COMMENT '周结束日期',
  `total_orders` int NULL DEFAULT 0 COMMENT '工单总数',
  `avg_complete_hours` decimal(10, 2) NULL DEFAULT 0.00 COMMENT '平均完成时长(小时)',
  `overtime_rate` decimal(10, 2) NULL DEFAULT 0.00 COMMENT '超时率(%)',
  `duplicate_rate` decimal(10, 2) NULL DEFAULT 0.00 COMMENT '重复报修率(%)',
  `good_rate` decimal(10, 2) NULL DEFAULT 0.00 COMMENT '好评率(%)',
  `type_stats` text NULL COMMENT '类型统计JSON',
  `worker_stats` text NULL COMMENT '维修工统计JSON',
  `suggestions` text NULL COMMENT '优化建议',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '生成时间',
  PRIMARY KEY (`report_id`),
  INDEX `idx_week_start`(`week_start`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='工单复盘周报';

