-- =============================================
-- 数据大屏与权限管理模块 - 演示数据
-- 导入方式: mysql -u root -p smart_care_community --default-character-set=utf8mb4 < sql/dashboard_permission_demo.sql
-- =============================================
SET NAMES utf8mb4;
SET CHARACTER SET utf8mb4;

-- =============================================
-- 1. 维修工技能标签表
-- =============================================
CREATE TABLE IF NOT EXISTS `rp_worker_skill` (
  `skill_id` bigint NOT NULL AUTO_INCREMENT COMMENT '技能主键',
  `worker_id` bigint NOT NULL COMMENT '维修工用户ID',
  `skill_name` varchar(64) NOT NULL COMMENT '技能名称',
  `skill_level` varchar(16) DEFAULT '初级' COMMENT '技能等级：初级/中级/高级/专家',
  PRIMARY KEY (`skill_id`),
  KEY `idx_worker` (`worker_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='维修工技能标签表';

-- =============================================
-- 2. 补充角色数据（新增客服、安保、网格员角色）
-- =============================================
INSERT INTO `sys_role` (`role_name`, `role_key`, `data_scope`, `status`, `remark`, `create_time`)
VALUES
  ('客服', 'service', '1', '0', '["elder_view","repair_manage","dashboard_view"]', NOW()),
  ('安保', 'security', '1', '0', '["elder_view","elder_manage","ai_monitor_view"]', NOW()),
  ('网格员', 'grid_worker', '2', '0', '["elder_view","elder_manage","elder_staff_manage","dashboard_view"]', NOW())
ON DUPLICATE KEY UPDATE role_name=VALUES(role_name);

-- =============================================
-- 3. 维修工技能标签演示数据
-- =============================================
INSERT INTO `rp_worker_skill` (`worker_id`, `skill_name`, `skill_level`) VALUES
  (3, '水电维修', '高级'),
  (3, '管道疏通', '中级'),
  (3, '电路检修', '专家'),
  (3, '空调维修', '初级');

-- =============================================
-- 4. 补充报修工单数据（确保大屏图表有内容）
-- =============================================
INSERT INTO `rp_order` (`order_no`, `owner_id`, `house_id`, `type_id`, `description`, `urgency`, `status`, `worker_id`, `create_time`) VALUES
  ('RP202606010001', 2, 1, 2, '厨房水龙头漏水严重', 'high', 'completed', 3, DATE_SUB(NOW(), INTERVAL 25 DAY)),
  ('RP202606020001', 5, 11, 4, '客厅跳闸无法恢复', 'high', 'completed', 3, DATE_SUB(NOW(), INTERVAL 22 DAY)),
  ('RP202606030001', 6, 21, 2, '卫生间水管渗漏', 'normal', 'completed', 3, DATE_SUB(NOW(), INTERVAL 20 DAY)),
  ('RP202606040001', 7, 31, 4, '卧室电路跳闸', 'normal', 'completed', 3, DATE_SUB(NOW(), INTERVAL 18 DAY)),
  ('RP202606050001', 8, 41, 2, '阳台水管破裂', 'urgent', 'completed', 3, DATE_SUB(NOW(), INTERVAL 15 DAY)),
  ('RP202606060001', 9, 51, 4, '厨房电路短路', 'high', 'processing', 3, DATE_SUB(NOW(), INTERVAL 12 DAY)),
  ('RP202606070001', 10, 61, 2, '浴室花洒漏水', 'normal', 'assigned', 3, DATE_SUB(NOW(), INTERVAL 10 DAY)),
  ('RP202606080001', 11, 71, 4, '楼道灯不亮', 'low', 'pending', NULL, DATE_SUB(NOW(), INTERVAL 8 DAY)),
  ('RP202606090001', 12, 81, 2, '地下室水管爆裂', 'urgent', 'completed', 3, DATE_SUB(NOW(), INTERVAL 5 DAY)),
  ('RP202606100001', 2, 1, 4, '空调外机异响', 'normal', 'pending', NULL, DATE_SUB(NOW(), INTERVAL 3 DAY)),
  ('RP202606110001', 5, 11, 2, '热水器水管漏水', 'high', 'assigned', 3, DATE_SUB(NOW(), INTERVAL 2 DAY)),
  ('RP202606120001', 6, 21, 4, '插座烧焦', 'urgent', 'processing', 3, DATE_SUB(NOW(), INTERVAL 1 DAY));

-- =============================================
-- 5. 补充预警数据（确保大屏预警趋势有内容，含设备预警）
-- =============================================
INSERT INTO `el_alert` (`resident_id`, `alert_type`, `alert_level`, `content`, `status`, `handler_id`, `handle_time`, `handle_result`, `create_time`) VALUES
  (6, 'device_offline', 2, '智能手环离线超过24小时', 'handled', 3, DATE_SUB(NOW(), INTERVAL 24 DAY), '设备重启恢复', DATE_SUB(NOW(), INTERVAL 25 DAY)),
  (10, 'device_fault', 1, '烟感报警器异常触发', 'handled', 3, DATE_SUB(NOW(), INTERVAL 19 DAY), '更换电池', DATE_SUB(NOW(), INTERVAL 20 DAY)),
  (6, 'device_battery_low', 2, '紧急呼叫器电量低于10%', 'handled', 3, DATE_SUB(NOW(), INTERVAL 14 DAY), '已更换电池', DATE_SUB(NOW(), INTERVAL 15 DAY)),
  (11, 'device_offline', 2, '门磁传感器离线', 'pending', NULL, NULL, NULL, DATE_SUB(NOW(), INTERVAL 10 DAY)),
  (6, 'no_activity', 1, '超过12小时无活动记录', 'handled', 3, DATE_SUB(NOW(), INTERVAL 7 DAY), '上门确认老人安全', DATE_SUB(NOW(), INTERVAL 8 DAY)),
  (10, 'fall_detected', 1, '疑似跌倒报警', 'handled', 3, DATE_SUB(NOW(), INTERVAL 4 DAY), '误报已确认', DATE_SUB(NOW(), INTERVAL 5 DAY)),
  (11, 'device_fault', 2, 'GPS定位设备故障', 'pending', NULL, NULL, NULL, DATE_SUB(NOW(), INTERVAL 2 DAY)),
  (6, 'no_activity', 1, '超过8小时无活动记录', 'pending', NULL, NULL, NULL, DATE_SUB(NOW(), INTERVAL 1 DAY));
