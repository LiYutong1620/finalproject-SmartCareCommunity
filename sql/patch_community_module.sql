-- 社区与个人服务模块补丁（在 smart_care_community 库执行）
USE smart_care_community;

ALTER TABLE cs_activity_reg ADD COLUMN voucher_no varchar(32) NULL DEFAULT '' COMMENT '报名凭证号' AFTER status;
ALTER TABLE cs_forum_post ADD COLUMN images text NULL COMMENT '图片URL列表JSON' AFTER content;
ALTER TABLE cs_complaint ADD COLUMN images text NULL COMMENT '图片URL列表JSON' AFTER content;
ALTER TABLE cs_vote ADD COLUMN options varchar(512) NULL DEFAULT '同意,反对,弃权' COMMENT '投票选项逗号分隔' AFTER content;
ALTER TABLE cs_visitor ADD COLUMN status char(1) NULL DEFAULT '1' COMMENT '状态：1有效 0过期' AFTER qrcode;
ALTER TABLE cs_visitor ADD COLUMN create_time datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间' AFTER status;

-- 演示数据
INSERT INTO cs_notice (notice_type, title, content, pinned, status, create_by) VALUES
('announce', '端午节社区活动通知', '社区将于端午节举办包粽子活动，欢迎报名。', 1, '1', 4),
('outage', '1栋停水通知', '因管道检修，1栋将于5月20日9:00-17:00停水。', 0, '1', 4);

UPDATE cs_notice SET scope = '1栋全体住户', restore_time = '2026-05-20 17:00:00' WHERE notice_type = 'outage' LIMIT 1;

INSERT INTO cs_activity (title, content, location, start_time, deadline, max_count, status) VALUES
('端午包粽子', '欢迎业主报名参加包粽子体验活动', '社区活动中心', '2026-06-10 14:00:00', '2026-06-08 18:00:00', 50, '1');

INSERT INTO cs_venue (venue_name, fee_standard) VALUES
('多功能厅', 200.00), ('篮球场', 100.00), ('棋牌室', 50.00);

INSERT INTO cs_vote (title, content, options, anonymous, end_time, status) VALUES
('是否增设电动车充电桩', '拟在地下车库B区增设10组充电桩，请业主表决。', '同意,反对,弃权', 1, '2026-06-30 23:59:59', '1');

INSERT INTO fn_bill (house_id, item_id, period, amount, paid_amount, status, due_date) VALUES
(1, 1, '2026-05', 500.00, 0.00, '0', '2026-05-31'),
(1, 2, '2026-05', 68.50, 68.50, '1', '2026-05-31'),
(1, 3, '2026-05', 120.00, 0.00, '0', '2026-05-31');

INSERT INTO fn_payment (bill_id, user_id, amount, pay_channel, trade_no) VALUES
(2, 2, 68.50, 'online', 'PAY20260517001');
