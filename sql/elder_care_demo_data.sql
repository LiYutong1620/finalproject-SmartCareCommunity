-- ============================================
-- 老人安全关怀模块 - 表结构变更 + 演示数据
-- 使用方法：mysql -u root -p20051003xxSGX smart_care_community --default-character-set=utf8mb4 -e "source D:/daima2/finalproject-SmartCareCommunity-main/finalproject-SmartCareCommunity-main/sql/elder_care_demo_data.sql"
-- ============================================

SET NAMES utf8mb4;
SET CHARACTER SET utf8mb4;

-- ========== 1. 表结构变更（首次运行必须执行，重复运行会报Duplicate column错误可忽略） ==========

-- 处置预案表增加字段
ALTER TABLE `el_disposal_plan` ADD COLUMN `plan_name` varchar(128) NULL DEFAULT '' COMMENT '预案名称' AFTER `plan_id`;
ALTER TABLE `el_disposal_plan` ADD COLUMN `trigger_condition` text NULL COMMENT '触发条件' AFTER `plan_name`;
ALTER TABLE `el_disposal_plan` ADD COLUMN `response_action` text NULL COMMENT '响应动作' AFTER `level`;

-- 关怀工单表增加结构化完成字段
ALTER TABLE `el_care_order` ADD COLUMN `check_result` text NULL COMMENT '核查结果' AFTER `result`;
ALTER TABLE `el_care_order` ADD COLUMN `support_measure` text NULL COMMENT '帮扶措施' AFTER `check_result`;
ALTER TABLE `el_care_order` ADD COLUMN `disposal_result` text NULL COMMENT '处置结果' AFTER `support_measure`;

-- 关怀人员表增加状态字段（前端有用到）
ALTER TABLE `el_care_staff` ADD COLUMN `status` varchar(16) NULL DEFAULT '在岗' COMMENT '状态：在岗/休假/离职';
ALTER TABLE `el_care_staff` ADD COLUMN `building_id` bigint NULL DEFAULT NULL COMMENT '负责楼栋ID';

-- ========== 2. 关怀人员数据 ==========

INSERT INTO `el_care_staff` (`staff_id`, `name`, `phone`, `staff_type`, `building_ids`, `building_id`, `status`) VALUES
(1, '张护工', '13900001001', '护理员', '1,2,3', 1, '在岗'),
(2, '王医生', '13900001002', '医生', '1,2,3,4,5', 1, '在岗'),
(3, '李护士', '13900001003', '护士', '4,5,6', 4, '在岗'),
(4, '赵康复师', '13900001004', '康复师', '7,8,9', 7, '在岗'),
(5, '陈护工', '13900001005', '护理员', '6,7,8', 6, '休假');

-- ========== 3. 处置预案数据（一级/二级写死） ==========

INSERT INTO `el_disposal_plan` (`plan_id`, `plan_name`, `trigger_condition`, `level`, `response_action`) VALUES
(1, '一级紧急处置预案-跌倒', '老人跌倒报警、紧急呼叫按钮触发', 1, '立即安排关怀人员上门核查，确认老人安全状况，必要时拨打120'),
(2, '一级紧急处置预案-心率异常', '心率持续超过120bpm或低于50bpm超过5分钟', 1, '立即上门查看老人身体状况，携带急救包，同步通知家属'),
(3, '二级确认处置预案-长时间未活动', '老人超过8小时无活动记录', 2, '先电话联系老人确认情况，若无法接通则30分钟内安排上门探访'),
(4, '二级确认处置预案-血压异常', '血压收缩压超过160mmHg或低于90mmHg', 2, '电话联系老人了解身体感受，建议就医，必要时安排上门陪同就医');

-- ========== 4. 预警数据 ==========

INSERT INTO `el_alert` (`alert_id`, `resident_id`, `alert_type`, `alert_level`, `content`, `status`, `handler_id`, `handle_time`, `handle_result`, `create_time`) VALUES
(1, 10, '跌倒', 1, '郑丽老人卧室红外感应检测到异常跌倒信号', 'handled', 4, '2026-06-28 09:30:00', '上门核查：老人起床时不慎绊倒，已扶起并检查无外伤，建议家属安装床边扶手', '2026-06-28 09:15:00'),
(2, 10, '心率异常', 1, '郑丽老人心率监测数据持续偏高（128bpm），已超过5分钟', 'handled', 4, '2026-06-25 15:45:00', '立即上门查看，老人因午睡后突然起身导致心率偏高，已恢复正常，建议缓慢起身', '2026-06-25 15:30:00'),
(3, 5, '长时间未活动', 2, '刘洋住户超过10小时未检测到活动信号', 'handled', 1, '2026-06-26 10:20:00', '电话确认：老人外出就医未携带设备，已平安返回，提醒外出携带设备', '2026-06-26 08:00:00'),
(4, 1, '血压异常', 2, '张三住户血压监测：收缩压172mmHg，超出正常范围', 'handled', 1, '2026-06-27 16:00:00', '电话确认老人感觉头晕，建议前往社区医院复查，次日随访血压已恢复正常', '2026-06-27 14:30:00'),
(5, 10, '紧急呼叫', 1, '郑丽老人按下紧急呼叫按钮', 'pending', NULL, NULL, NULL, '2026-06-30 08:20:00'),
(6, 5, '心率异常', 1, '刘洋住户心率监测数据偏低（48bpm），持续10分钟', 'pending', NULL, NULL, NULL, '2026-06-30 10:00:00'),
(7, 9, '长时间未活动', 2, '吴刚住户超过12小时未检测到活动信号', 'pending', NULL, NULL, NULL, '2026-07-01 06:30:00'),
(8, 15, '跌倒', 1, '林雪住户家中老人（同住）卫生间跌倒报警', 'pending', NULL, NULL, NULL, '2026-07-01 07:45:00');

-- ========== 5. 关怀工单数据 ==========

INSERT INTO `el_care_order` (`care_id`, `resident_id`, `care_item`, `assignee_id`, `status`, `result`, `check_result`, `support_measure`, `disposal_result`, `create_time`) VALUES
(1, 10, '郑丽老人跌倒后康复回访，检查居家安全设施', 1, 'completed', '核查结果：老人恢复良好，无后遗症状 | 帮扶措施：协助安装卧室床边扶手和卫生间防滑垫 | 处置结果：已安装安全设施，老人表示满意', '老人恢复良好，无后遗症状', '协助安装卧室床边扶手和卫生间防滑垫', '已安装安全设施，老人表示满意', '2026-06-28 10:00:00'),
(2, 10, '郑丽老人日常健康关怀，测量血压和心率', 3, 'completed', '核查结果：血压135/85mmHg正常，心率72bpm正常 | 帮扶措施：指导老人每日定时测量并记录 | 处置结果：发放健康记录本，约定每周回访一次', '血压135/85mmHg正常，心率72bpm正常', '指导老人每日定时测量并记录', '发放健康记录本，约定每周回访一次', '2026-06-26 14:00:00'),
(3, 5, '刘洋住户长时间未活动后回访确认', 1, 'completed', '核查结果：老人确认外出就医已返回 | 帮扶措施：为老人配备便携式定位设备 | 处置结果：设备已配发，教会老人使用', '老人确认外出就医已返回', '为老人配备便携式定位设备', '设备已配发，教会老人使用', '2026-06-26 11:00:00'),
(4, 10, '郑丽老人紧急呼叫响应-上门探访', NULL, 'pending', NULL, NULL, NULL, NULL, '2026-06-30 08:25:00'),
(5, 9, '吴刚住户长时间未活动-上门核查', 1, 'assigned', NULL, NULL, NULL, NULL, '2026-07-01 07:00:00');

-- ========== 6. 健康监测数据 ==========

INSERT INTO `el_health_record` (`resident_id`, `heart_rate`, `blood_pressure`, `steps`, `record_time`) VALUES
(10, 72, '135/85', 3200, '2026-06-30 08:00:00'),
(10, 78, '140/90', 1500, '2026-06-29 08:00:00'),
(10, 68, '130/82', 4100, '2026-06-28 08:00:00'),
(5, 65, '125/80', 5600, '2026-06-30 08:00:00'),
(5, 48, '120/78', 200, '2026-06-30 10:00:00'),
(9, 75, '138/88', 2800, '2026-06-30 08:00:00'),
(1, 80, '172/95', 1200, '2026-06-27 14:00:00'),
(1, 76, '135/85', 3500, '2026-06-28 08:00:00');

-- ========== 7. 健康阈值配置 ==========

INSERT INTO `el_health_threshold` (`metric`, `min_value`, `max_value`) VALUES
('heart_rate', 50.00, 120.00),
('blood_pressure_high', 90.00, 160.00),
('blood_pressure_low', 60.00, 100.00);

-- ========== 完成 ==========
SELECT '老人安全关怀模块演示数据导入完成！' AS message;
