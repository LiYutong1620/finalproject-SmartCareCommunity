-- 修复社区模块缺失字段（在 smart_care_community 库执行，列已存在时会报错可忽略该行）
USE smart_care_community;

ALTER TABLE cs_activity_reg ADD COLUMN voucher_no varchar(32) NULL DEFAULT '' COMMENT '报名凭证号' AFTER status;
ALTER TABLE cs_forum_post ADD COLUMN images text NULL COMMENT '图片URL列表JSON' AFTER content;
ALTER TABLE cs_complaint ADD COLUMN images text NULL COMMENT '图片URL列表JSON' AFTER content;
ALTER TABLE cs_vote ADD COLUMN `options` varchar(512) NULL DEFAULT '同意,反对,弃权' COMMENT '投票选项' AFTER content;
ALTER TABLE cs_visitor ADD COLUMN status char(1) NULL DEFAULT '1' COMMENT '状态' AFTER qrcode;
ALTER TABLE cs_visitor ADD COLUMN create_time datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间' AFTER status;
