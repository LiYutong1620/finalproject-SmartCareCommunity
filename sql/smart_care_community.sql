/*
 Smart Care Community - 完整数据库脚本（基于现网导出 2026-07-04 清理）
 用途：全新导入（会先 DROP 再 CREATE 全部表）
 数据库：smart_care_community
 说明：
   - 数据来源：smart_care_community（2）.sql（Navicat 现网导出）
   - 已移除废弃表：sys_user、el_device、el_health_*、el_disposal_plan、cs_housekeeping*、cs_secondhand
   - 已精简 cm_resident 废弃字段：family_members、is_primary_resident、is_alone_living、last_activity_time
   - 保留三端账号分表及全部在用的业务数据
 导入：mysql -uroot -p < sql/smart_care_community.sql
*/

CREATE DATABASE IF NOT EXISTS `smart_care_community` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE `smart_care_community`;

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS `cs_housekeeping_order`;
DROP TABLE IF EXISTS `cs_housekeeping`;
DROP TABLE IF EXISTS `cs_secondhand`;
DROP TABLE IF EXISTS `sys_user`;
DROP TABLE IF EXISTS `el_device`;
DROP TABLE IF EXISTS `sys_user_role`;
DROP TABLE IF EXISTS `sys_property_account`;
DROP TABLE IF EXISTS `sys_worker_account`;
DROP TABLE IF EXISTS `sys_owner_account`;
DROP TABLE IF EXISTS `pm_staff`;
DROP TABLE IF EXISTS `sys_role_menu`;
DROP TABLE IF EXISTS `sys_role`;
DROP TABLE IF EXISTS `sys_message_user`;
DROP TABLE IF EXISTS `sys_message`;
DROP TABLE IF EXISTS `sys_menu`;
DROP TABLE IF EXISTS `sys_login_log`;
DROP TABLE IF EXISTS `sys_config`;
DROP TABLE IF EXISTS `rp_worker_certificate`;
DROP TABLE IF EXISTS `rp_worker_skill`;
DROP TABLE IF EXISTS `rp_worker_profile`;
DROP TABLE IF EXISTS `rp_repair_weekly_report`;
DROP TABLE IF EXISTS `rp_repair_type`;
DROP TABLE IF EXISTS `rp_order_progress`;
DROP TABLE IF EXISTS `rp_order_field_image`;
DROP TABLE IF EXISTS `rp_order_field_record`;
DROP TABLE IF EXISTS `rp_order_image`;
DROP TABLE IF EXISTS `rp_order_eval`;
DROP TABLE IF EXISTS `rp_order`;
DROP TABLE IF EXISTS `cs_service_ticket`;
DROP TABLE IF EXISTS `ai_chat_message`;
DROP TABLE IF EXISTS `ai_chat_session`;
DROP TABLE IF EXISTS `kb_learn_draft`;
DROP TABLE IF EXISTS `kb_article`;
DROP TABLE IF EXISTS `el_utility_data`;
DROP TABLE IF EXISTS `el_temp_guardian`;
DROP TABLE IF EXISTS `el_ai_monitor_log`;
DROP TABLE IF EXISTS `el_health_threshold`;
DROP TABLE IF EXISTS `el_health_record`;
DROP TABLE IF EXISTS `el_disposal_plan`;
DROP TABLE IF EXISTS `el_care_staff_type`;
DROP TABLE IF EXISTS `el_care_staff`;
DROP TABLE IF EXISTS `el_disposal_record`;
DROP TABLE IF EXISTS `el_care_order`;
DROP TABLE IF EXISTS `el_alert`;
DROP TABLE IF EXISTS `cs_notice_read`;
DROP TABLE IF EXISTS `cs_notice`;
DROP TABLE IF EXISTS `cm_resident_tag_rel`;
DROP TABLE IF EXISTS `cm_resident_tag`;
DROP TABLE IF EXISTS `cm_resident`;
DROP TABLE IF EXISTS `cm_house`;
DROP TABLE IF EXISTS `cm_building`;





-- ----------------------------
-- Table structure for ai_chat_message
-- ----------------------------
DROP TABLE IF EXISTS `ai_chat_message`;
CREATE TABLE `ai_chat_message`  (
  `message_id` bigint NOT NULL AUTO_INCREMENT COMMENT '消息主键',
  `session_id` bigint NOT NULL COMMENT '会话ID',
  `role` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '角色：user/assistant/staff',
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '消息内容',
  `sender_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '发送者显示名（物业人工回复）',
  `input_type` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'text' COMMENT '输入方式：text/voice',
  `transfer_human` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '是否转人工：0否 1是',
  `ticket_id` bigint NULL DEFAULT NULL COMMENT '关联客服工单ID',
  `ref_articles` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '引用知识库文章ID',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`message_id`) USING BTREE,
  INDEX `idx_ai_message_session`(`session_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 25 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'AI问答消息表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of ai_chat_message
-- ----------------------------
INSERT INTO `ai_chat_message` VALUES (1, 1, 'user', '小区停车有什么规定？', '', 'text', '0', NULL, '', '2026-05-18 10:00:00');
INSERT INTO `ai_chat_message` VALUES (2, 1, 'assistant', '业主车辆需登记后进出；地下车库请减速慢行，按位停车，勿占消防通道与他人车位。访客车辆可在门岗登记临时进入。', '', 'text', '0', NULL, '15', '2026-05-18 10:01:00');
INSERT INTO `ai_chat_message` VALUES (3, 1, 'user', '地下车库可以安装充电桩吗？', '', 'text', '0', NULL, '', '2026-05-18 10:05:00');
INSERT INTO `ai_chat_message` VALUES (4, 1, 'assistant', '关于增设新能源充电桩方案，社区将召开业主大会表决，具体安排请关注社区公告。如需个人车位安装，请先向物业报备。', '', 'text', '0', NULL, '15', '2026-05-18 10:05:30');
INSERT INTO `ai_chat_message` VALUES (5, 2, 'user', '我们楼道有人长期堆放杂物，影响通行', '', 'text', '0', NULL, '', '2026-05-19 14:20:00');
INSERT INTO `ai_chat_message` VALUES (6, 2, 'assistant', '大堂、走廊、楼梯间为公共疏散空间，不得长期堆放私人物品。', '', 'text', '0', NULL, '16', '2026-05-19 14:21:00');
INSERT INTO `ai_chat_message` VALUES (7, 2, 'user', '转人工', '', 'text', '1', NULL, '', '2026-05-19 14:22:00');
INSERT INTO `ai_chat_message` VALUES (8, 2, 'assistant', '已为您接入人工客服，请在此对话中继续留言，物业人员将实时回复，请保持信号畅通。', '', 'text', '1', 1, '', '2026-05-19 14:22:01');
INSERT INTO `ai_chat_message` VALUES (9, 2, 'staff', '您好，我是王管家。已记录您反映的楼道杂物问题，我们将安排人员今日下午上门查看并协调清理。', '王管家', 'text', '0', 1, '', '2026-05-19 14:30:00');
INSERT INTO `ai_chat_message` VALUES (10, 2, 'user', '好的，大概几点能过来？', '', 'text', '0', NULL, '', '2026-05-19 15:10:00');
INSERT INTO `ai_chat_message` VALUES (11, 3, 'user', '物业费怎么交？', '', 'text', '0', NULL, '', '2026-05-17 09:30:00');
INSERT INTO `ai_chat_message` VALUES (12, 3, 'assistant', '本系统当前版本暂未开放在线缴费。如需咨询物业费，请携带房本到物业服务中心办理，或拨打物业前台电话。', '', 'text', '0', NULL, '5', '2026-05-17 09:31:00');
INSERT INTO `ai_chat_message` VALUES (13, 3, 'user', '转人工', '', 'text', '1', NULL, '', '2026-05-17 09:35:00');
INSERT INTO `ai_chat_message` VALUES (14, 3, 'assistant', '已为您接入人工客服，请在此对话中继续留言。', '', 'text', '1', 2, '', '2026-05-17 09:35:01');
INSERT INTO `ai_chat_message` VALUES (15, 3, 'staff', '您好，物业费可至物业中心缴纳，工作日 9:00-17:30。', '王管家', 'text', '0', 2, '', '2026-05-17 09:40:00');
INSERT INTO `ai_chat_message` VALUES (16, 3, 'user', '好的，谢谢', '', 'text', '0', NULL, '', '2026-05-17 09:55:00');
INSERT INTO `ai_chat_message` VALUES (17, 3, 'staff', '不客气，如有其他问题随时留言。', '王管家', 'text', '0', 2, '', '2026-05-17 10:00:00');
INSERT INTO `ai_chat_message` VALUES (18, 4, 'user', '怎么在线提交报修？', '', 'text', '0', NULL, '', '2026-05-20 11:00:00');
INSERT INTO `ai_chat_message` VALUES (19, 4, 'assistant', '登录业主端后进入「报修工单」，点击「提交报修」，选择报修类型，填写问题描述并上传现场照片，提交后可在列表查看进度。', '', 'text', '0', NULL, '1', '2026-05-20 11:03:00');
INSERT INTO `ai_chat_message` VALUES (20, 5, 'user', '咱们楼栋有关门时间吗', '', 'text', '0', NULL, '', '2026-07-02 21:56:15');
INSERT INTO `ai_chat_message` VALUES (21, 5, 'assistant', '您好！关于楼栋关门时间，我们社区没有统一的规定。如果您需要了解具体信息，建议您联系物业服务中心确认，或者我可以帮您转人工咨询。', '', 'text', '0', NULL, '6,17,2', '2026-07-02 21:56:16');
INSERT INTO `ai_chat_message` VALUES (22, 2, 'staff', '明天下午三点，您看可以吗', '王管家', 'text', '0', 1, '', '2026-07-03 20:06:15');
INSERT INTO `ai_chat_message` VALUES (23, 6, 'user', '如何提交报修工单？', '', 'text', '0', NULL, '', '2026-07-03 23:54:53');
INSERT INTO `ai_chat_message` VALUES (24, 6, 'assistant', '您好！提交报修工单的步骤如下：\n\n1. 登录业主端后进入「报修工单」页面\n2. 点击「提交报修」按钮\n3. 选择报修类型（如水电、门窗、公共设施等）\n4. 填写详细的问题描述\n5. 上传现场照片\n6. 提交后可在列表查看进度\n\n如果是紧急问题，请备注「紧急」并拨打物业值班电话。', '', 'text', '0', NULL, '1,2,3', '2026-07-03 23:54:57');

-- ----------------------------
-- Table structure for ai_chat_session
-- ----------------------------
DROP TABLE IF EXISTS `ai_chat_session`;
CREATE TABLE `ai_chat_session`  (
  `session_id` bigint NOT NULL AUTO_INCREMENT COMMENT '会话主键',
  `user_id` bigint NOT NULL COMMENT '业主用户ID',
  `title` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '会话标题',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '状态：0AI对话 1人工对话中 2人工已结束',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`session_id`) USING BTREE,
  INDEX `idx_ai_session_user`(`user_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 7 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'AI问答会话表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of ai_chat_session
-- ----------------------------
INSERT INTO `ai_chat_session` VALUES (1, 2, '停车管理规定咨询', '0', '2026-05-18 10:00:00', '2026-05-18 10:05:00');
INSERT INTO `ai_chat_session` VALUES (2, 5, '投诉楼道杂物堆放', '1', '2026-05-19 14:20:00', '2026-07-03 20:06:15');
INSERT INTO `ai_chat_session` VALUES (3, 2, '物业费缴纳咨询', '2', '2026-05-17 09:30:00', '2026-05-17 10:00:00');
INSERT INTO `ai_chat_session` VALUES (4, 6, '如何在线提交报修', '0', '2026-05-20 11:00:00', '2026-05-20 11:03:00');
INSERT INTO `ai_chat_session` VALUES (5, 2, '咱们楼栋有关门时间吗', '0', '2026-07-02 21:56:15', '2026-07-02 21:56:15');
INSERT INTO `ai_chat_session` VALUES (6, 39, '如何提交报修工单？', '0', '2026-07-03 23:54:53', '2026-07-03 23:54:53');

-- ----------------------------
-- Table structure for cm_building
-- ----------------------------
DROP TABLE IF EXISTS `cm_building`;
CREATE TABLE `cm_building`  (
  `building_id` bigint NOT NULL AUTO_INCREMENT COMMENT '楼栋主键',
  `building_no` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '楼栋编号',
  `total_floors` int NULL DEFAULT 0 COMMENT '总层数',
  `units_per_floor` int NULL DEFAULT 0 COMMENT '每层户数',
  `remark` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '备注',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`building_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 12 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '楼栋信息表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cm_building
-- ----------------------------
INSERT INTO `cm_building` VALUES (1, '1栋', 18, 4, '临近小区东门，设有独立快递柜与非机动车棚，物业值班室在一层', '2026-05-01 08:00:00', '2026-05-01 08:00:00');
INSERT INTO `cm_building` VALUES (2, '2栋', 22, 6, '中庭景观楼，南北双电梯，一层为架空活动区，适合亲子活动', '2026-05-01 08:00:00', '2026-05-01 08:00:00');
INSERT INTO `cm_building` VALUES (3, '3栋', 15, 3, '靠西侧河道，低楼层视野开阔，噪音较小，绿化覆盖率高', '2026-05-01 08:00:00', '2026-05-01 08:00:00');
INSERT INTO `cm_building` VALUES (4, '4栋', 33, 8, '超高层塔楼，配备高速电梯与避难层，每层8户，视野极佳', '2026-05-01 08:00:00', '2026-05-01 08:00:00');
INSERT INTO `cm_building` VALUES (5, '5栋', 12, 2, '小型精品楼栋，总户数少，管理更精细，门禁系统独立', '2026-05-01 08:00:00', '2026-05-01 08:00:00');
INSERT INTO `cm_building` VALUES (6, '6栋', 20, 5, '标准板式楼，楼间距大，采光充足，南北通透户型较多', '2026-05-01 08:00:00', '2026-05-01 08:00:00');
INSERT INTO `cm_building` VALUES (7, '7栋', 25, 4, '临近社区会所与游泳池，夏季活动方便，周末人流略多', '2026-05-01 08:00:00', '2026-05-01 08:00:00');
INSERT INTO `cm_building` VALUES (8, '8栋', 16, 3, '安静内侧楼座，远离主干道，适合居家休息，夜间较静', '2026-05-01 08:00:00', '2026-05-01 08:00:00');
INSERT INTO `cm_building` VALUES (9, '9栋', 28, 6, '靠近社区北门与商超，生活采购便利，早市步行5分钟', '2026-05-01 08:00:00', '2026-05-01 08:00:00');
INSERT INTO `cm_building` VALUES (10, '10栋', 11, 2, '南侧楼座，冬季日照时间长，适合老人居住，暖气供应稳定', '2026-05-01 08:00:00', '2026-05-01 08:00:00');
INSERT INTO `cm_building` VALUES (11, '11栋', 18, 4, '', '2026-07-04 00:00:49', '2026-07-04 00:00:49');

-- ----------------------------
-- Table structure for cm_house
-- ----------------------------
DROP TABLE IF EXISTS `cm_house`;
CREATE TABLE `cm_house`  (
  `house_id` bigint NOT NULL AUTO_INCREMENT COMMENT '房屋主键',
  `building_id` bigint NOT NULL COMMENT '楼栋ID',
  `house_no` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '房号',
  `area` decimal(10, 2) NULL DEFAULT 0.00 COMMENT '建筑面积',
  `layout` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '户型',
  `owner_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '业主姓名',
  `remark` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '备注',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`house_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 102 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '房屋信息表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cm_house
-- ----------------------------
INSERT INTO `cm_house` VALUES (1, 1, '101', 58.00, '一室一厅', '张三', '1栋101，一室一厅，建筑面积约58.00㎡；张三业主已登记入住，档案与系统账号已绑定，日常联系优先使用系统消息', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (2, 1, '102', 64.50, '两室一厅', '孙浩', '1栋102，两室一厅，建筑面积约64.50㎡；孙浩业主已登记入住，档案与系统账号已绑定，日常联系优先使用系统消息', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (3, 1, '201', 71.00, '两室两厅', '王奶奶', '1栋201，两室两厅，建筑面积约71.00㎡；样板展示房，展示现代简约风格，供新业主参考', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (4, 1, '202', 70.00, '三室一厅', '李爷爷', '1栋202，三室一厅，建筑面积约70.00㎡；当前空置，已做深度保洁，可拎包入住', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (5, 1, '301', 76.50, '三室两厅', '', '1栋301，三室两厅，建筑面积约76.50㎡；样板展示房，展示现代简约风格，供新业主参考', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (6, 1, '302', 83.00, '四室两厅', '', '1栋302，四室两厅，建筑面积约83.00㎡；当前空置，已做深度保洁，可拎包入住', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (7, 1, '401', 82.00, '复式loft', '', '1栋401，复式loft，建筑面积约82.00㎡；当前空置，南向采光好，曾做过短期租赁', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (8, 1, '501', 88.50, '跃层三居', '', '1栋501，跃层三居，建筑面积约88.50㎡；当前空置，南向采光好，曾做过短期租赁', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (9, 1, '502', 95.00, '精装两居', '', '1栋502，精装两居，建筑面积约95.00㎡；当前空置，已做深度保洁，可拎包入住', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (10, 1, '601', 94.00, '阔景四居', '', '1栋601，阔景四居，建筑面积约94.00㎡；当前空置，南向采光好，曾做过短期租赁', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (11, 2, '101', 61.00, '一室一厅', '李芳', '2栋101，一室一厅，建筑面积约61.00㎡；李芳业主已登记入住，档案与系统账号已绑定，日常联系优先使用系统消息', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (12, 2, '102', 67.50, '两室一厅', '马超', '2栋102，两室一厅，建筑面积约67.50㎡；马超业主已登记入住，档案与系统账号已绑定，日常联系优先使用系统消息', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (13, 2, '201', 74.00, '两室两厅', '赵大爷', '2栋201，两室两厅，建筑面积约74.00㎡；样板展示房，展示现代简约风格，供新业主参考', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (14, 2, '202', 73.00, '三室一厅', '', '2栋202，三室一厅，建筑面积约73.00㎡；当前空置，已做深度保洁，可拎包入住', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (15, 2, '301', 79.50, '三室两厅', '', '2栋301，三室两厅，建筑面积约79.50㎡；样板展示房，展示现代简约风格，供新业主参考', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (16, 2, '302', 86.00, '四室两厅', '', '2栋302，四室两厅，建筑面积约86.00㎡；当前空置，已做深度保洁，可拎包入住', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (17, 2, '401', 85.00, '复式loft', '', '2栋401，复式loft，建筑面积约85.00㎡；当前空置，南向采光好，曾做过短期租赁', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (18, 2, '501', 91.50, '跃层三居', '', '2栋501，跃层三居，建筑面积约91.50㎡；当前空置，南向采光好，曾做过短期租赁', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (19, 2, '502', 98.00, '精装两居', '', '2栋502，精装两居，建筑面积约98.00㎡；当前空置，已做深度保洁，可拎包入住', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (20, 2, '601', 97.00, '阔景四居', '', '2栋601，阔景四居，建筑面积约97.00㎡；当前空置，南向采光好，曾做过短期租赁', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (21, 3, '101', 64.00, '一室一厅', '王磊', '3栋101，一室一厅，建筑面积约64.00㎡；王磊业主已登记入住，档案与系统账号已绑定，日常联系优先使用系统消息', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (22, 3, '102', 70.50, '两室一厅', '朱琳', '3栋102，两室一厅，建筑面积约70.50㎡；朱琳业主已登记入住，档案与系统账号已绑定，日常联系优先使用系统消息', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (23, 3, '201', 77.00, '两室两厅', '陈阿姨', '3栋201，两室两厅，建筑面积约77.00㎡；样板展示房，展示现代简约风格，供新业主参考', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (24, 3, '202', 76.00, '三室一厅', '', '3栋202，三室一厅，建筑面积约76.00㎡；当前空置，已做深度保洁，可拎包入住', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (25, 3, '301', 82.50, '三室两厅', '', '3栋301，三室两厅，建筑面积约82.50㎡；样板展示房，展示现代简约风格，供新业主参考', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (26, 3, '302', 89.00, '四室两厅', '', '3栋302，四室两厅，建筑面积约89.00㎡；当前空置，已做深度保洁，可拎包入住', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (27, 3, '401', 88.00, '复式loft', '', '3栋401，复式loft，建筑面积约88.00㎡；当前空置，南向采光好，曾做过短期租赁', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (28, 3, '501', 94.50, '跃层三居', '', '3栋501，跃层三居，建筑面积约94.50㎡；当前空置，南向采光好，曾做过短期租赁', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (29, 3, '502', 101.00, '精装两居', '', '3栋502，精装两居，建筑面积约101.00㎡；当前空置，已做深度保洁，可拎包入住', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (30, 3, '601', 100.00, '阔景四居', '', '3栋601，阔景四居，建筑面积约100.00㎡；当前空置，南向采光好，曾做过短期租赁', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (31, 4, '101', 67.00, '一室一厅', '赵敏', '4栋101，一室一厅，建筑面积约67.00㎡；赵敏业主已登记入住，档案与系统账号已绑定，日常联系优先使用系统消息', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (32, 4, '102', 73.50, '两室一厅', '胡军', '4栋102，两室一厅，建筑面积约73.50㎡；胡军业主已登记入住，档案与系统账号已绑定，日常联系优先使用系统消息', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (33, 4, '201', 80.00, '两室两厅', '孙大爷', '4栋201，两室两厅，建筑面积约80.00㎡；样板展示房，展示现代简约风格，供新业主参考', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (34, 4, '202', 79.00, '三室一厅', '', '4栋202，三室一厅，建筑面积约79.00㎡；当前空置，已做深度保洁，可拎包入住', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (35, 4, '301', 85.50, '三室两厅', '', '4栋301，三室两厅，建筑面积约85.50㎡；样板展示房，展示现代简约风格，供新业主参考', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (36, 4, '302', 92.00, '四室两厅', '', '4栋302，四室两厅，建筑面积约92.00㎡；当前空置，已做深度保洁，可拎包入住', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (37, 4, '401', 91.00, '复式loft', '', '4栋401，复式loft，建筑面积约91.00㎡；当前空置，南向采光好，曾做过短期租赁', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (38, 4, '501', 97.50, '跃层三居', '', '4栋501，跃层三居，建筑面积约97.50㎡；当前空置，南向采光好，曾做过短期租赁', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (39, 4, '502', 104.00, '精装两居', '', '4栋502，精装两居，建筑面积约104.00㎡；当前空置，已做深度保洁，可拎包入住', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (40, 4, '601', 103.00, '阔景四居', '', '4栋601，阔景四居，建筑面积约103.00㎡；当前空置，南向采光好，曾做过短期租赁', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (41, 5, '101', 70.00, '一室一厅', '刘洋', '5栋101，一室一厅，建筑面积约70.00㎡；刘洋业主已登记入住，档案与系统账号已绑定，日常联系优先使用系统消息', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (42, 5, '102', 76.50, '两室一厅', '林雪', '5栋102，两室一厅，建筑面积约76.50㎡；林雪业主已登记入住，档案与系统账号已绑定，日常联系优先使用系统消息', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (43, 5, '201', 83.00, '两室两厅', '周奶奶', '5栋201，两室两厅，建筑面积约83.00㎡；样板展示房，展示现代简约风格，供新业主参考', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (44, 5, '202', 82.00, '三室一厅', '', '5栋202，三室一厅，建筑面积约82.00㎡；当前空置，已做深度保洁，可拎包入住', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (45, 5, '301', 88.50, '三室两厅', '', '5栋301，三室两厅，建筑面积约88.50㎡；样板展示房，展示现代简约风格，供新业主参考', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (46, 5, '302', 95.00, '四室两厅', '', '5栋302，四室两厅，建筑面积约95.00㎡；当前空置，已做深度保洁，可拎包入住', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (47, 5, '401', 94.00, '复式loft', '', '5栋401，复式loft，建筑面积约94.00㎡；当前空置，南向采光好，曾做过短期租赁', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (48, 5, '501', 100.50, '跃层三居', '', '5栋501，跃层三居，建筑面积约100.50㎡；当前空置，南向采光好，曾做过短期租赁', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (49, 5, '502', 107.00, '精装两居', '', '5栋502，精装两居，建筑面积约107.00㎡；当前空置，已做深度保洁，可拎包入住', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (50, 5, '601', 106.00, '阔景四居', '', '5栋601，阔景四居，建筑面积约106.00㎡；当前空置，南向采光好，曾做过短期租赁', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (51, 6, '101', 73.00, '一室一厅', '陈静', '6栋101，一室一厅，建筑面积约73.00㎡；陈静业主已登记入住，档案与系统账号已绑定，日常联系优先使用系统消息', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (52, 6, '102', 79.50, '两室一厅', '', '6栋102，两室一厅，建筑面积约79.50㎡；当前空置，已做深度保洁，可拎包入住', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (53, 6, '201', 86.00, '两室两厅', '钱爷爷', '6栋201，两室两厅，建筑面积约86.00㎡；样板展示房，展示现代简约风格，供新业主参考', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (54, 6, '202', 85.00, '三室一厅', '', '6栋202，三室一厅，建筑面积约85.00㎡；当前空置，已做深度保洁，可拎包入住', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (55, 6, '301', 91.50, '三室两厅', '', '6栋301，三室两厅，建筑面积约91.50㎡；样板展示房，展示现代简约风格，供新业主参考', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (56, 6, '302', 98.00, '四室两厅', '', '6栋302，四室两厅，建筑面积约98.00㎡；当前空置，已做深度保洁，可拎包入住', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (57, 6, '401', 97.00, '复式loft', '', '6栋401，复式loft，建筑面积约97.00㎡；当前空置，南向采光好，曾做过短期租赁', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (58, 6, '501', 103.50, '跃层三居', '', '6栋501，跃层三居，建筑面积约103.50㎡；当前空置，南向采光好，曾做过短期租赁', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (59, 6, '502', 110.00, '精装两居', '', '6栋502，精装两居，建筑面积约110.00㎡；当前空置，已做深度保洁，可拎包入住', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (60, 6, '601', 109.00, '阔景四居', '', '6栋601，阔景四居，建筑面积约109.00㎡；当前空置，南向采光好，曾做过短期租赁', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (61, 7, '101', 76.00, '一室一厅', '杨帆', '7栋101，一室一厅，建筑面积约76.00㎡；杨帆业主已登记入住，档案与系统账号已绑定，日常联系优先使用系统消息', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (62, 7, '102', 82.50, '两室一厅', '', '7栋102，两室一厅，建筑面积约82.50㎡；当前空置，已做深度保洁，可拎包入住', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (63, 7, '201', 89.00, '两室两厅', '吴奶奶', '7栋201，两室两厅，建筑面积约89.00㎡；样板展示房，展示现代简约风格，供新业主参考', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (64, 7, '202', 88.00, '三室一厅', '', '7栋202，三室一厅，建筑面积约88.00㎡；当前空置，已做深度保洁，可拎包入住', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (65, 7, '301', 94.50, '三室两厅', '', '7栋301，三室两厅，建筑面积约94.50㎡；样板展示房，展示现代简约风格，供新业主参考', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (66, 7, '302', 101.00, '四室两厅', '', '7栋302，四室两厅，建筑面积约101.00㎡；当前空置，已做深度保洁，可拎包入住', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (67, 7, '401', 100.00, '复式loft', '', '7栋401，复式loft，建筑面积约100.00㎡；当前空置，南向采光好，曾做过短期租赁', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (68, 7, '501', 106.50, '跃层三居', '', '7栋501，跃层三居，建筑面积约106.50㎡；当前空置，南向采光好，曾做过短期租赁', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (69, 7, '502', 113.00, '精装两居', '', '7栋502，精装两居，建筑面积约113.00㎡；当前空置，已做深度保洁，可拎包入住', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (70, 7, '601', 112.00, '阔景四居', '', '7栋601，阔景四居，建筑面积约112.00㎡；当前空置，南向采光好，曾做过短期租赁', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (71, 8, '101', 79.00, '一室一厅', '周婷', '8栋101，一室一厅，建筑面积约79.00㎡；周婷业主已登记入住，档案与系统账号已绑定，日常联系优先使用系统消息', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (72, 8, '102', 85.50, '两室一厅', '', '8栋102，两室一厅，建筑面积约85.50㎡；当前空置，已做深度保洁，可拎包入住', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (73, 8, '201', 92.00, '两室两厅', '郑大爷', '8栋201，两室两厅，建筑面积约92.00㎡；样板展示房，展示现代简约风格，供新业主参考', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (74, 8, '202', 91.00, '三室一厅', '', '8栋202，三室一厅，建筑面积约91.00㎡；当前空置，已做深度保洁，可拎包入住', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (75, 8, '301', 97.50, '三室两厅', '', '8栋301，三室两厅，建筑面积约97.50㎡；样板展示房，展示现代简约风格，供新业主参考', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (76, 8, '302', 104.00, '四室两厅', '', '8栋302，四室两厅，建筑面积约104.00㎡；当前空置，已做深度保洁，可拎包入住', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (77, 8, '401', 103.00, '复式loft', '', '8栋401，复式loft，建筑面积约103.00㎡；当前空置，南向采光好，曾做过短期租赁', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (78, 8, '501', 109.50, '跃层三居', '', '8栋501，跃层三居，建筑面积约109.50㎡；当前空置，南向采光好，曾做过短期租赁', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (79, 8, '502', 116.00, '精装两居', '', '8栋502，精装两居，建筑面积约116.00㎡；当前空置，已做深度保洁，可拎包入住', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (80, 8, '601', 115.00, '阔景四居', '', '8栋601，阔景四居，建筑面积约115.00㎡；当前空置，南向采光好，曾做过短期租赁', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (81, 9, '101', 82.00, '一室一厅', '吴刚', '9栋101，一室一厅，建筑面积约82.00㎡；吴刚业主已登记入住，档案与系统账号已绑定，日常联系优先使用系统消息', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (82, 9, '102', 88.50, '两室一厅', '', '9栋102，两室一厅，建筑面积约88.50㎡；当前空置，已做深度保洁，可拎包入住', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (83, 9, '201', 95.00, '两室两厅', '', '9栋201，两室两厅，建筑面积约95.00㎡；样板展示房，展示现代简约风格，供新业主参考', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (84, 9, '202', 94.00, '三室一厅', '', '9栋202，三室一厅，建筑面积约94.00㎡；当前空置，已做深度保洁，可拎包入住', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (85, 9, '301', 100.50, '三室两厅', '', '9栋301，三室两厅，建筑面积约100.50㎡；样板展示房，展示现代简约风格，供新业主参考', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (86, 9, '302', 107.00, '四室两厅', '', '9栋302，四室两厅，建筑面积约107.00㎡；当前空置，已做深度保洁，可拎包入住', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (87, 9, '401', 106.00, '复式loft', '', '9栋401，复式loft，建筑面积约106.00㎡；当前空置，南向采光好，曾做过短期租赁', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (88, 9, '501', 112.50, '跃层三居', '', '9栋501，跃层三居，建筑面积约112.50㎡；当前空置，南向采光好，曾做过短期租赁', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (89, 9, '502', 119.00, '精装两居', '', '9栋502，精装两居，建筑面积约119.00㎡；当前空置，已做深度保洁，可拎包入住', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (90, 9, '601', 118.00, '阔景四居', '', '9栋601，阔景四居，建筑面积约118.00㎡；当前空置，南向采光好，曾做过短期租赁', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (91, 10, '101', 85.00, '一室一厅', '郑丽', '10栋101，一室一厅，建筑面积约85.00㎡；郑丽业主已登记入住，档案与系统账号已绑定，日常联系优先使用系统消息', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (92, 10, '102', 91.50, '两室一厅', '', '10栋102，两室一厅，建筑面积约91.50㎡；当前空置，已做深度保洁，可拎包入住', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (93, 10, '201', 98.00, '两室两厅', '', '10栋201，两室两厅，建筑面积约98.00㎡；样板展示房，展示现代简约风格，供新业主参考', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (94, 10, '202', 97.00, '三室一厅', '', '10栋202，三室一厅，建筑面积约97.00㎡；当前空置，已做深度保洁，可拎包入住', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (95, 10, '301', 103.50, '三室两厅', '', '10栋301，三室两厅，建筑面积约103.50㎡；样板展示房，展示现代简约风格，供新业主参考', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (96, 10, '302', 110.00, '四室两厅', '', '10栋302，四室两厅，建筑面积约110.00㎡；当前空置，已做深度保洁，可拎包入住', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (97, 10, '401', 109.00, '复式loft', '', '10栋401，复式loft，建筑面积约109.00㎡；当前空置，南向采光好，曾做过短期租赁', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (98, 10, '501', 115.50, '跃层三居', '', '10栋501，跃层三居，建筑面积约115.50㎡；当前空置，南向采光好，曾做过短期租赁', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (99, 10, '502', 122.00, '精装两居', '', '10栋502，精装两居，建筑面积约122.00㎡；当前空置，已做深度保洁，可拎包入住', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (100, 10, '601', 121.00, '阔景四居', '冯奶奶', '10栋601，阔景四居，建筑面积约121.00㎡；当前空置，南向采光好，曾做过短期租赁', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (101, 11, '101', 89.00, '三室两厅', '', '采光好', '2026-07-04 00:01:33');

-- ----------------------------
-- Table structure for cm_resident
-- ----------------------------
DROP TABLE IF EXISTS `cm_resident`;
CREATE TABLE `cm_resident`  (
  `resident_id` bigint NOT NULL AUTO_INCREMENT COMMENT '住户主键',
  `user_id` bigint NULL DEFAULT NULL COMMENT '绑定业主账号ID',
  `house_id` bigint NOT NULL COMMENT '房屋ID（一屋一条档案）',
  `name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '实际居住人姓名',
  `gender` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '性别：0男 1女',
  `age` int NULL DEFAULT NULL COMMENT '年龄',
  `id_card` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '身份证号',
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '联系电话',
  `resident_type` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '遗留：0业主 1租客',
  `move_in_date` date NULL DEFAULT NULL COMMENT '入住日期',
  `emergency_contact` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '遗留合并字段',
  `remark` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '备注',
  `del_flag` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '删除：0存在 2删除',
  `living_status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '1' COMMENT '居住状态：1在住 2空置 3出租',
  `is_owner` tinyint NULL DEFAULT 1 COMMENT '是否产权人：1是 0否',
  `owner_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '产权人姓名',
  `owner_phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '产权人电话',
  `owner_relation` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '与产权人关系',
  `emergency_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '紧急联系人姓名',
  `emergency_phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '紧急联系人电话',
  `emergency_relation` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '与住户关系',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`resident_id`) USING BTREE,
  UNIQUE INDEX `uk_house_resident`(`house_id` ASC, `del_flag` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 26 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '住户档案表（一屋一条）' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cm_resident
-- ----------------------------
INSERT INTO `cm_resident` VALUES (1, 2, 1, '张三', '0', 35, '', '13810000001', '0', '2023-01-15', '', '主业主，系统账号已绑定', '0', '1', 1, '', '', '本人', '张大哥', '13133332223', '兄弟姐妹', '2026-05-01 08:00:00', '2026-07-03 17:34:12');
INSERT INTO `cm_resident` VALUES (2, 5, 11, '李芳', '1', 42, '', '13810000002', '0', '2023-02-15', '', '日常在家', '0', '1', 1, '', '', '本人', '李强', '13900000002', '配偶', '2026-05-01 08:00:00', '2026-07-03 12:12:58');
INSERT INTO `cm_resident` VALUES (3, 6, 21, '王磊', '0', 38, '', '13810000003', '0', '2023-03-15', '', '工作日晚归', '0', '1', 1, '', '', '本人', '', '', '', '2026-05-01 08:00:00', '2026-07-03 12:12:58');
INSERT INTO `cm_resident` VALUES (4, 7, 31, '赵敏', '1', 36, '', '13810000004', '0', '2023-04-15', '', '', '0', '1', 1, '', '', '本人', '赵刚', '13900000004', '配偶', '2026-05-01 08:00:00', '2026-07-03 12:12:58');
INSERT INTO `cm_resident` VALUES (5, 8, 41, '刘洋', '0', 45, '', '13810000005', '0', '2023-05-15', '', '长期出差', '0', '1', 1, '', '', '本人', '刘梅', '13900000005', '配偶', '2026-05-01 08:00:00', '2026-07-03 12:12:57');
INSERT INTO `cm_resident` VALUES (6, 9, 51, '陈静', '1', 33, '', '13810000006', '0', '2023-06-15', '', '家有宠物', '0', '1', 1, '', '', '本人', '', '', '', '2026-05-01 08:00:00', '2026-07-03 12:12:58');
INSERT INTO `cm_resident` VALUES (7, 10, 61, '杨帆', '0', 29, '', '13810000007', '0', '2023-07-15', '', '', '0', '1', 1, '', '', '本人', '', '', '', '2026-05-01 08:00:00', '2026-07-03 12:12:58');
INSERT INTO `cm_resident` VALUES (8, 11, 71, '周婷', '1', 31, '', '13810000008', '0', '2023-08-15', '', '偏好短信通知', '0', '1', 1, '', '', '本人', '', '', '', '2026-05-01 08:00:00', '2026-07-03 12:12:57');
INSERT INTO `cm_resident` VALUES (9, 12, 81, '吴刚', '0', 50, '', '13810000009', '0', '2023-09-15', '', '', '0', '1', 1, '', '', '本人', '吴芳', '13900000009', '配偶', '2026-05-01 08:00:00', '2026-07-03 12:12:58');
INSERT INTO `cm_resident` VALUES (10, 13, 91, '郑丽', '1', 72, '', '13810000010', '0', '2023-10-15', '', '独居老人，纳入关怀', '0', '1', 1, '', '', '本人', '郑明', '13900000010', '子女', '2026-05-01 08:00:00', '2026-07-03 12:12:58');
INSERT INTO `cm_resident` VALUES (11, 14, 2, '孙浩', '0', 28, '', '13810000011', '0', '2023-11-15', '', '身体残疾，生活不便', '0', '1', 1, '', '', '本人', '', '', '', '2026-05-01 08:00:00', '2026-07-03 16:47:36');
INSERT INTO `cm_resident` VALUES (12, 15, 12, '马超', '0', 26, '', '13810000012', '0', '2023-12-15', '', '', '0', '1', 1, '', '', '本人', '', '', '', '2026-05-01 08:00:00', '2026-07-03 12:12:58');
INSERT INTO `cm_resident` VALUES (13, 16, 22, '朱琳', '1', 34, '', '13810000013', '0', '2023-01-15', '', '', '0', '1', 1, '', '', '本人', '', '', '', '2026-05-01 08:00:00', '2026-07-03 12:12:58');
INSERT INTO `cm_resident` VALUES (14, 17, 32, '胡军', '0', 55, '', '13810000014', '0', '2023-02-15', '', '', '0', '1', 1, '', '', '本人', '', '', '', '2026-05-01 08:00:00', '2026-07-03 12:12:57');
INSERT INTO `cm_resident` VALUES (15, 18, 42, '林雪', '1', 40, '', '13810000015', '0', '2023-03-15', '', '与母亲同住', '0', '1', 1, '', '', '本人', '林涛', '13900000015', '配偶', '2026-05-01 08:00:00', '2026-07-03 12:12:57');
INSERT INTO `cm_resident` VALUES (16, 29, 3, '王奶奶', '1', 82, '', '13810000016', '0', '2020-06-01', '', '高龄独居', '0', '1', 1, '', '', '本人', '王强', '13900000016', '子女', '2026-06-01 08:00:00', '2026-07-03 16:56:49');
INSERT INTO `cm_resident` VALUES (17, 30, 4, '李爷爷', '0', 85, '', '13810000017', '0', '2019-03-10', '', '高龄独居', '0', '1', 1, '', '', '本人', '李娟', '13900000017', '子女', '2026-06-01 08:00:00', '2026-07-03 16:56:49');
INSERT INTO `cm_resident` VALUES (18, 31, 13, '赵大爷', '0', 68, '', '13810000018', '0', '2021-08-20', '', '独居老人', '0', '1', 1, '', '', '本人', '赵敏', '13810000004', '子女', '2026-06-01 08:00:00', '2026-07-03 16:56:49');
INSERT INTO `cm_resident` VALUES (19, 32, 23, '陈阿姨', '1', 63, '', '13810000019', '0', '2022-01-05', '', '独居老人', '0', '1', 1, '', '', '本人', '陈亮', '13900000019', '子女', '2026-06-01 08:00:00', '2026-07-03 16:56:49');
INSERT INTO `cm_resident` VALUES (20, 33, 33, '孙大爷', '0', 78, '', '13810000020', '0', '2018-11-12', '', '高龄老人', '0', '1', 1, '', '', '本人', '孙丽', '13900000020', '子女', '2026-06-01 08:00:00', '2026-07-03 16:56:49');
INSERT INTO `cm_resident` VALUES (21, 34, 43, '周奶奶', '1', 81, '', '13810000021', '0', '2017-05-18', '', '高龄独居', '0', '1', 1, '', '', '本人', '周明', '13900000021', '子女', '2026-06-01 08:00:00', '2026-07-03 16:56:49');
INSERT INTO `cm_resident` VALUES (22, 35, 53, '钱爷爷', '0', 67, '', '13810000022', '0', '2020-09-01', '', '独居老人', '0', '1', 1, '', '', '本人', '钱芳', '13900000022', '子女', '2026-06-01 08:00:00', '2026-07-03 16:56:49');
INSERT INTO `cm_resident` VALUES (23, 36, 63, '吴奶奶', '1', 86, '', '13810000023', '1', '2016-04-22', '', '高龄独居', '0', '1', 0, '吴刚', '13810000009', '子女', '吴刚', '13810000009', '子女', '2026-06-01 08:00:00', '2026-07-03 17:22:43');
INSERT INTO `cm_resident` VALUES (24, 37, 73, '郑大爷', '0', 74, '', '13810000024', '0', '2019-07-30', '', '独居+高龄', '0', '1', 1, '', '', '本人', '郑丽', '13810000010', '子女', '2026-06-01 08:00:00', '2026-07-03 16:56:49');
INSERT INTO `cm_resident` VALUES (25, 38, 100, '冯奶奶', '1', 88, '', '13810000025', '0', '2015-12-01', '', '10栋601高龄独居', '0', '1', 1, '', '', '本人', '冯强', '13900000025', '子女', '2026-06-01 08:00:00', '2026-07-03 16:56:49');

-- ----------------------------
-- Table structure for cm_resident_tag
-- ----------------------------
DROP TABLE IF EXISTS `cm_resident_tag`;
CREATE TABLE `cm_resident_tag`  (
  `tag_id` bigint NOT NULL AUTO_INCREMENT COMMENT '标签ID',
  `tag_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '标签名称',
  `tag_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '标签类型',
  PRIMARY KEY (`tag_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 7 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '住户标签表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cm_resident_tag
-- ----------------------------
INSERT INTO `cm_resident_tag` VALUES (1, '独居老人', 'auto');
INSERT INTO `cm_resident_tag` VALUES (2, '高龄老人', 'auto');
INSERT INTO `cm_resident_tag` VALUES (3, '重点关注', 'manual');

-- ----------------------------
-- Table structure for cm_resident_tag_rel
-- ----------------------------
DROP TABLE IF EXISTS `cm_resident_tag_rel`;
CREATE TABLE `cm_resident_tag_rel`  (
  `resident_id` bigint NOT NULL COMMENT '住户ID',
  `tag_id` bigint NOT NULL COMMENT '标签ID',
  PRIMARY KEY (`resident_id`, `tag_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '住户标签关联表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cm_resident_tag_rel
-- ----------------------------

-- ----------------------------
-- Table structure for cs_notice
-- ----------------------------
DROP TABLE IF EXISTS `cs_notice`;
CREATE TABLE `cs_notice`  (
  `notice_id` bigint NOT NULL AUTO_INCREMENT COMMENT '公告主键',
  `notice_type` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'announce' COMMENT '类型：announce/outage',
  `title` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '标题',
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '内容',
  `attachment` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '附件',
  `pinned` tinyint NULL DEFAULT 0 COMMENT '置顶：0否 1是',
  `valid_start` datetime NULL DEFAULT NULL COMMENT '有效开始',
  `valid_end` datetime NULL DEFAULT NULL COMMENT '有效结束',
  `scope` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '影响范围',
  `restore_time` datetime NULL DEFAULT NULL COMMENT '恢复时间',
  `offline_time` datetime NULL DEFAULT NULL COMMENT '定时下架时间',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '1' COMMENT '状态：0下架 1已发布 2待发布',
  `create_by` bigint NULL DEFAULT NULL COMMENT '发布人',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '发布时间',
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`notice_id`) USING BTREE,
  INDEX `idx_notice_list`(`status` ASC, `notice_type` ASC, `create_time` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 39 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '社区公告通知表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cs_notice
-- ----------------------------
INSERT INTO `cs_notice` VALUES (1, 'announce', '清明节文明祭扫倡议', '清明将至，倡导鲜花祭扫、网络祭扫等文明方式。请勿在楼道、阳台堆放纸钱等易燃物，祭扫后确认火源完全熄灭。', '', 1, NULL, NULL, '', NULL, NULL, '1', 4, '2026-04-02 09:00:00', '2026-04-02 09:00:00');
INSERT INTO `cs_notice` VALUES (2, 'announce', '春季绿化补种通知', '4月10日至15日，物业将在中心花园及主干道两侧补种灌木与草坪。作业期间请勿进入围挡区域，如有宠物请牵绳绕行。', '', 0, NULL, NULL, '', NULL, '2026-06-15 23:59:59', '0', 4, '2026-04-08 10:00:00', '2026-07-02 20:09:08');
INSERT INTO `cs_notice` VALUES (3, 'announce', '五一劳动节放假安排', '5月1日至5月3日放假，物业服务中心5月1日9:00-12:00值班，5月2日起正常办公。紧急报修请拨打24小时热线。', '', 0, NULL, NULL, '', NULL, NULL, '0', 4, '2026-04-20 08:30:00', '2026-04-25 18:00:00');
INSERT INTO `cs_notice` VALUES (4, 'announce', '端午节包粽子活动通知', '社区将于6月9日14:00在活动中心举办包粽子活动，限40组家庭，额满即止。报名请联系楼栋管家或至物业前台登记。', '', 1, NULL, NULL, '', NULL, NULL, '1', 4, '2026-06-05 09:00:00', '2026-07-02 20:09:08');
INSERT INTO `cs_notice` VALUES (5, 'announce', '夏季消防安全演练安排', '定于5月18日15:00在中心广场进行消防疏散演练，请各楼栋配合物业工作人员指引。演练期间请勿围观堵塞通道。', '', 0, NULL, NULL, '', NULL, NULL, '1', 4, '2026-05-10 14:00:00', '2026-05-10 14:00:00');
INSERT INTO `cs_notice` VALUES (6, 'announce', '小区绿化修剪公告', '5月22日至24日将进行绿化修剪，作业时间8:30-17:30。请勿在作业区域停放车辆，修剪期间可能有轻微噪音，敬请谅解。', '', 0, NULL, NULL, '', NULL, '2026-05-31 23:59:59', '0', 4, '2026-05-12 08:00:00', '2026-07-02 20:09:08');
INSERT INTO `cs_notice` VALUES (7, 'announce', '亲子运动会报名开启', '6月15日举办亲子运动会，设跳绳、接力等项目。线上报名截止6月8日，可在业主群或物业前台填写报名表。', '', 0, NULL, NULL, '', NULL, NULL, '1', 4, '2026-06-01 10:00:00', '2026-07-02 20:09:08');
INSERT INTO `cs_notice` VALUES (8, 'announce', '电梯年度检修告知', '5月25日起分批检修各栋电梯，单次停梯约2-4小时。具体时段见各单元门口张贴通知，检修期间请优先步行或错峰乘梯。', '', 0, NULL, NULL, '', NULL, NULL, '1', 4, '2026-05-15 11:00:00', '2026-05-15 11:00:00');
INSERT INTO `cs_notice` VALUES (9, 'announce', '宠物文明饲养倡议', '请遛宠时使用牵引绳，及时清理宠物排泄物。禁止在公共区域放养，避免犬吠扰民。违反规定者将按公约劝导处理。', '', 0, NULL, NULL, '', NULL, NULL, '0', 4, '2026-04-05 09:00:00', '2026-04-10 09:00:00');
INSERT INTO `cs_notice` VALUES (10, 'announce', '地下车库清洗通知', '6月6日清洗B1、B2层车库，当日8:00-18:00请尽量驶离或配合移位。清洗后地面湿滑，请注意行车安全。', '', 0, NULL, NULL, '', NULL, NULL, '1', 4, '2026-05-28 16:00:00', '2026-05-28 16:00:00');
INSERT INTO `cs_notice` VALUES (11, 'announce', '业主大会表决事项预告', '关于增设新能源充电桩方案，定于6月20日19:00在社区会议室召开业主大会表决。材料已张贴于各栋公告栏，欢迎查阅。', '', 0, NULL, NULL, '', NULL, '2026-07-04 19:59:13', '1', 4, '2026-06-10 09:00:00', '2026-07-02 20:09:08');
INSERT INTO `cs_notice` VALUES (12, 'announce', '蚊虫消杀作业公告', '6月3日晚20:00-22:00全小区消杀，请关好门窗，收好食品。消杀后30分钟内避免开窗，儿童宠物请勿接触药剂喷洒区域。', '', 0, NULL, NULL, '', NULL, NULL, '1', 4, '2026-05-30 08:00:00', '2026-05-30 08:00:00');
INSERT INTO `cs_notice` VALUES (13, 'announce', '快递柜系统升级说明', '5月16日22:00-24:00升级快递柜系统，期间可能无法取件。请提前取走重要快件，升级完成后需重新验证手机号。', '', 0, NULL, NULL, '', NULL, '2026-05-20 08:00:00', '0', 4, '2026-05-14 09:30:00', '2026-07-02 20:09:08');
INSERT INTO `cs_notice` VALUES (14, 'announce', '儿童节礼品领取通知', '6月1日9:00-17:00在一层大堂领取儿童节礼品，每户限领一份。请携带业主身份证明，代领需出示授权信息。', '', 0, NULL, NULL, '', NULL, NULL, '1', 4, '2026-05-25 10:00:00', '2026-05-25 10:00:00');
INSERT INTO `cs_notice` VALUES (15, 'announce', '高温防暑温馨提示', '6月起进入高温季节，请注意防暑补水。建议老人儿童减少11:00-15:00户外活动，室内空调温度不宜过低，避免室内外温差过大。', '', 0, NULL, NULL, '', NULL, NULL, '1', 4, '2026-06-01 07:30:00', '2026-06-01 07:30:00');
INSERT INTO `cs_notice` VALUES (16, 'outage', '1栋停水检修通知', '因主管道阀门更换，1栋将于5月12日9:00-17:00暂停供水。请提前储水，恢复供水初期水质可能短暂浑浊，放水后即可正常使用。', '', 1, NULL, NULL, '1栋全体住户', '2026-05-12 17:00:00', NULL, '1', 4, '2026-05-11 08:00:00', '2026-05-11 08:00:00');
INSERT INTO `cs_notice` VALUES (17, 'outage', '2栋配电室停电检修', '2栋配电室设备检修，5月14日8:30-11:30全栋停电。请提前保存电脑数据，电梯将暂停运行，高层住户请合理安排出行。', '', 0, NULL, NULL, '2栋', '2026-05-14 11:30:00', NULL, '1', 4, '2026-05-13 09:00:00', '2026-05-13 09:00:00');
INSERT INTO `cs_notice` VALUES (18, 'outage', '3栋水泵更换停水', '3栋二次供水水泵更换，5月20日14:00-18:00低区停水。请关闭热水器进水阀，恢复供水后再开启，防止空烧损坏设备。', '', 0, NULL, NULL, '3栋低区', '2026-05-20 18:00:00', NULL, '1', 4, '2026-06-08 14:00:00', '2026-07-02 20:09:08');
INSERT INTO `cs_notice` VALUES (19, 'outage', '4栋电梯机房停电', '4栋电梯机房维护，5月22日13:00-15:00电梯全部暂停。请提前规划上下楼路线，老人及行动不便住户可联系物业协助。', '', 0, NULL, NULL, '4栋', '2026-05-22 15:00:00', NULL, '1', 4, '2026-05-21 10:00:00', '2026-05-21 10:00:00');
INSERT INTO `cs_notice` VALUES (20, 'outage', '5栋燃气安全检查停气', '5栋5月25日9:00-12:00停气检修。请提前关闭灶具阀门，恢复通气后先开窗通风再点火，确保安全。', '', 0, NULL, NULL, '5栋', '2026-05-25 12:00:00', NULL, '1', 4, '2026-05-24 08:30:00', '2026-05-24 08:30:00');
INSERT INTO `cs_notice` VALUES (21, 'outage', '6栋水箱清洗停水', '6栋水箱清洗消毒，4月18日10:00-16:00停水。清洗完成后水质符合标准再恢复供水，如有疑问请联系物业工程部。', '', 0, NULL, NULL, '6栋', '2026-04-18 16:00:00', NULL, '0', 4, '2026-04-15 09:00:00', '2026-04-20 10:00:00');
INSERT INTO `cs_notice` VALUES (22, 'outage', '7栋线路改造停电', '7栋供电线路改造，6月12日0:00-6:00全栋停电。请提前为手机、应急灯充电，凌晨时段请注意出行安全。', '', 1, NULL, NULL, '7栋', '2026-06-12 06:00:00', NULL, '1', 4, '2026-06-10 12:00:00', '2026-06-10 12:00:00');
INSERT INTO `cs_notice` VALUES (23, 'outage', '8栋主水管维修停水', '8栋主水管维修，6月18日8:00-12:00停水。工程车可能占用临时车位，请配合现场疏导，带来不便敬请谅解。', '', 0, NULL, NULL, '8栋', '2026-06-18 12:00:00', NULL, '1', 4, '2026-06-15 08:00:00', '2026-07-02 20:09:08');
INSERT INTO `cs_notice` VALUES (24, 'outage', '9栋公区照明改造停电', '9栋大堂及走廊照明改造，5月28日19:00-22:00公区停电。请使用手机照明，注意台阶安全，改造完成后照明将更加节能明亮。', '', 0, NULL, NULL, '9栋公区', '2026-05-28 22:00:00', NULL, '1', 4, '2026-05-27 15:00:00', '2026-05-27 15:00:00');
INSERT INTO `cs_notice` VALUES (25, 'outage', '10栋阀门更换停水', '10栋总阀更换，6月2日9:00-11:00停水。停水时间较短，请提前储少量生活用水，恢复后请先放清管道存水。', '', 0, NULL, NULL, '10栋', '2026-06-02 11:00:00', NULL, '1', 4, '2026-06-01 09:00:00', '2026-06-01 09:00:00');
INSERT INTO `cs_notice` VALUES (26, 'outage', '中心广场活动临时停电', '广场端午活动用电调试，6月8日18:00-20:00周边路灯及景观灯关闭。调试结束后立即恢复，请夜间出行注意瞭望。', '', 0, NULL, NULL, '中心广场周边', '2026-06-08 20:00:00', NULL, '1', 4, '2026-06-07 10:00:00', '2026-06-07 10:00:00');
INSERT INTO `cs_notice` VALUES (27, 'outage', '地下车库B1消防测试停水', 'B1层消防管道测试，4月25日15:00-17:00临时停水。测试期间可能有警报声，属正常现象，请勿恐慌。', '', 0, NULL, NULL, 'B1车库', '2026-04-25 17:00:00', NULL, '0', 4, '2026-04-22 11:00:00', '2026-04-26 09:00:00');
INSERT INTO `cs_notice` VALUES (28, 'outage', '1-3栋联动检修停水', '6月25日8:00-18:00，1至3栋低区联动停水检修。影响范围较大，请提前储备24小时用水，物业将在大堂提供应急供水。', '', 0, NULL, NULL, '1-3栋低区', '2026-06-25 18:00:00', NULL, '1', 4, '2026-06-20 09:00:00', '2026-07-02 20:09:08');
INSERT INTO `cs_notice` VALUES (29, 'outage', '全小区消防联动测试停电', '6月30日10:00-10:30消防联动测试，全小区电梯可能短暂停运，门禁系统切换备用电源。测试结束后自动恢复正常。', '', 0, NULL, NULL, '全小区', '2026-06-30 10:30:00', NULL, '1', 4, '2026-06-28 08:00:00', '2026-06-28 08:00:00');
INSERT INTO `cs_notice` VALUES (30, 'outage', '4栋计划停水（待发布）', '4栋主供水管计划7月5日8:00-14:00停水检修，具体以现场条件为准。本通知待工程方案确认后正式发布，请提前关注后续更新。', '', 0, NULL, NULL, '4栋', '2026-07-05 14:00:00', NULL, '1', 4, '2026-06-22 09:00:00', '2026-07-02 20:09:08');
INSERT INTO `cs_notice` VALUES (31, 'announce', '社区大扫除', '明天下午将进行社区大扫除，如有打扰请多包涵', '', 0, NULL, NULL, '', NULL, '2026-07-04 21:00:00', '0', 4, '2026-07-04 00:03:30', '2026-07-04 00:03:40');
INSERT INTO `cs_notice` VALUES (32, 'announce', '社区大扫除', '明天下午将进行社区大扫除，如有打扰请多包涵', '', 1, NULL, NULL, '', NULL, '2026-07-04 21:00:00', '1', 4, '2026-07-04 00:03:32', '2026-07-04 00:03:33');
INSERT INTO `cs_notice` VALUES (33, 'outage', '5栋停水通知', '5栋将于2026/7/5日停水，预计停水持续一天，请广大居民朋友屯好水源', '', 0, NULL, NULL, '5栋', '2026-07-06 00:00:00', '2026-07-06 05:00:00', '0', 4, '2026-07-04 00:05:27', '2026-07-04 00:05:37');
INSERT INTO `cs_notice` VALUES (34, 'outage', '5栋停水通知', '5栋将于2026/7/5日停水，预计停水持续一天，请广大居民朋友屯好水源', '', 1, NULL, NULL, '5栋', '2026-07-06 00:00:00', '2026-07-06 05:00:00', '1', 4, '2026-07-04 00:05:28', '2026-07-04 00:05:29');
INSERT INTO `cs_notice` VALUES (35, 'announce', 'test', 'test测试', '', 0, NULL, NULL, '', NULL, NULL, '0', 4, '2026-07-04 00:14:33', '2026-07-04 00:21:10');
INSERT INTO `cs_notice` VALUES (36, 'announce', 'test', 'test测试', '', 0, NULL, NULL, '', NULL, NULL, '0', 4, '2026-07-04 00:14:35', '2026-07-04 00:21:08');
INSERT INTO `cs_notice` VALUES (37, 'announce', 'test', 'test测试', '', 0, NULL, NULL, '', NULL, NULL, '1', 4, '2026-07-04 00:21:23', '2026-07-04 00:21:24');
INSERT INTO `cs_notice` VALUES (38, 'outage', '特踏实', 'test', '', 0, NULL, NULL, '', '2026-07-04 00:22:54', NULL, '1', 4, '2026-07-04 00:22:01', '2026-07-04 00:22:02');

-- ----------------------------
-- Table structure for cs_notice_read
-- ----------------------------
DROP TABLE IF EXISTS `cs_notice_read`;
CREATE TABLE `cs_notice_read`  (
  `notice_id` bigint NOT NULL COMMENT '公告ID',
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `read_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '阅读时间',
  PRIMARY KEY (`notice_id`, `user_id`) USING BTREE,
  INDEX `idx_user`(`user_id` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '公告已读记录表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cs_notice_read
-- ----------------------------
INSERT INTO `cs_notice_read` VALUES (1, 2, '2026-05-02 10:00:00');
INSERT INTO `cs_notice_read` VALUES (3, 2, '2026-05-06 09:00:00');
INSERT INTO `cs_notice_read` VALUES (4, 2, '2026-07-02 21:44:08');
INSERT INTO `cs_notice_read` VALUES (5, 2, '2026-07-02 21:36:20');
INSERT INTO `cs_notice_read` VALUES (11, 2, '2026-07-02 21:44:02');
INSERT INTO `cs_notice_read` VALUES (11, 5, '2026-07-03 19:59:25');
INSERT INTO `cs_notice_read` VALUES (11, 6, '2026-07-03 19:59:32');
INSERT INTO `cs_notice_read` VALUES (11, 7, '2026-07-03 19:59:25');
INSERT INTO `cs_notice_read` VALUES (11, 8, '2026-07-03 19:59:26');
INSERT INTO `cs_notice_read` VALUES (11, 9, '2026-07-03 19:59:26');
INSERT INTO `cs_notice_read` VALUES (11, 10, '2026-07-03 19:59:26');
INSERT INTO `cs_notice_read` VALUES (11, 11, '2026-07-03 19:59:26');
INSERT INTO `cs_notice_read` VALUES (11, 12, '2026-07-03 19:59:26');
INSERT INTO `cs_notice_read` VALUES (11, 13, '2026-07-03 19:59:27');
INSERT INTO `cs_notice_read` VALUES (11, 14, '2026-07-03 19:59:27');
INSERT INTO `cs_notice_read` VALUES (11, 15, '2026-07-03 19:59:27');
INSERT INTO `cs_notice_read` VALUES (11, 16, '2026-07-03 19:59:27');
INSERT INTO `cs_notice_read` VALUES (11, 17, '2026-07-03 19:59:27');
INSERT INTO `cs_notice_read` VALUES (11, 18, '2026-07-03 19:59:27');
INSERT INTO `cs_notice_read` VALUES (11, 29, '2026-07-03 19:59:28');
INSERT INTO `cs_notice_read` VALUES (11, 30, '2026-07-03 19:59:29');
INSERT INTO `cs_notice_read` VALUES (11, 31, '2026-07-03 19:59:29');
INSERT INTO `cs_notice_read` VALUES (11, 32, '2026-07-03 19:59:29');
INSERT INTO `cs_notice_read` VALUES (11, 33, '2026-07-03 19:59:29');
INSERT INTO `cs_notice_read` VALUES (11, 34, '2026-07-03 19:59:30');
INSERT INTO `cs_notice_read` VALUES (11, 35, '2026-07-03 19:59:30');
INSERT INTO `cs_notice_read` VALUES (11, 36, '2026-07-03 19:59:30');
INSERT INTO `cs_notice_read` VALUES (11, 37, '2026-07-03 19:59:30');
INSERT INTO `cs_notice_read` VALUES (11, 38, '2026-07-03 19:59:30');
INSERT INTO `cs_notice_read` VALUES (11, 39, '2026-07-03 23:33:22');
INSERT INTO `cs_notice_read` VALUES (16, 2, '2026-07-02 21:46:02');
INSERT INTO `cs_notice_read` VALUES (22, 2, '2026-07-02 21:45:51');
INSERT INTO `cs_notice_read` VALUES (22, 39, '2026-07-03 23:54:48');
INSERT INTO `cs_notice_read` VALUES (23, 2, '2026-07-02 21:46:04');

-- ----------------------------
-- Table structure for cs_service_ticket
-- ----------------------------
DROP TABLE IF EXISTS `cs_service_ticket`;
CREATE TABLE `cs_service_ticket`  (
  `ticket_id` bigint NOT NULL AUTO_INCREMENT COMMENT '工单主键',
  `user_id` bigint NOT NULL COMMENT '业主用户ID',
  `session_id` bigint NULL DEFAULT NULL COMMENT '来源会话ID',
  `question` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '用户问题摘要',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '状态：0待处理 1处理中 2已完成',
  `reply` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '客服回复',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`ticket_id`) USING BTREE,
  INDEX `idx_cs_ticket_user`(`user_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '人工客服工单表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cs_service_ticket
-- ----------------------------
INSERT INTO `cs_service_ticket` VALUES (1, 5, 2, '楼道杂物堆放投诉', '1', '明天下午三点，您看可以吗', '2026-05-19 14:22:00', '2026-05-19 14:30:00');
INSERT INTO `cs_service_ticket` VALUES (2, 2, 3, '物业费缴纳咨询', '2', '物业费可至物业中心缴纳，工作日 9:00-17:30。', '2026-05-17 09:35:00', '2026-05-17 10:00:00');

-- ----------------------------
-- Table structure for el_ai_monitor_log
-- ----------------------------
DROP TABLE IF EXISTS `el_ai_monitor_log`;
CREATE TABLE `el_ai_monitor_log`  (
  `log_id` bigint NOT NULL AUTO_INCREMENT COMMENT '日志ID',
  `resident_id` bigint NOT NULL COMMENT '老人住户ID',
  `check_time` datetime NOT NULL COMMENT '检测时间',
  `risk_level` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '风险等级: green/yellow/red',
  `reason` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '风险原因',
  `ai_response` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT 'AI原始回复',
  `alert_id` bigint NULL DEFAULT NULL COMMENT '关联预警ID',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`log_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 45 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '独居老人AI监测日志' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of el_ai_monitor_log
-- ----------------------------
INSERT INTO `el_ai_monitor_log` VALUES (1, 10, '2026-07-04 00:29:06', 'green', '水电与生活迹象正常', NULL, NULL, '2026-07-04 00:29:06');
INSERT INTO `el_ai_monitor_log` VALUES (2, 16, '2026-07-04 00:29:06', 'green', '水电与生活迹象正常', NULL, NULL, '2026-07-04 00:29:06');
INSERT INTO `el_ai_monitor_log` VALUES (3, 17, '2026-07-04 00:29:06', 'green', '水电与生活迹象正常', NULL, NULL, '2026-07-04 00:29:06');
INSERT INTO `el_ai_monitor_log` VALUES (4, 18, '2026-07-04 00:29:06', 'yellow', '【用量异常】出现单小时尖峰用量（超7日基线300%）：2026-07-03T19:00 用电1.28kWh', '风险判断：赵大爷7月3日19:00用电量异常激增(1.28kWh)，远超基线300%，可能存在用电设备故障或紧急情况。\n\n关怀措施：建议物业人员电话联系确认情况，询问是否需要帮助；如无人接听，可安排上门查看。\n\n紧急程度：中等。用电尖峰虽不直接危及生命，但需尽快确认原因，防止设备故障引发安全隐患。', 1, '2026-07-04 00:29:06');
INSERT INTO `el_ai_monitor_log` VALUES (5, 19, '2026-07-04 00:29:16', 'green', '水电与生活迹象正常', NULL, NULL, '2026-07-04 00:29:16');
INSERT INTO `el_ai_monitor_log` VALUES (6, 20, '2026-07-04 00:29:16', 'yellow', '【用量异常】出现单小时尖峰用量（超7日基线300%）：2026-07-03T19:00 用水27.87L', '风险判断：孙大爷7月3日19点用水量异常激增(27.87L)，远超日常水平，可能存在用水设备故障或突发状况。\n\n关怀措施：建议物业人员电话询问情况，检查用水设备是否正常，提醒老人注意用水安全。\n\n紧急程度：中等。虽无直接健康风险，但异常用水模式需关注，建议24小时内跟进。', 2, '2026-07-04 00:29:16');
INSERT INTO `el_ai_monitor_log` VALUES (7, 21, '2026-07-04 00:29:18', 'green', '水电与生活迹象正常', NULL, NULL, '2026-07-04 00:29:18');
INSERT INTO `el_ai_monitor_log` VALUES (8, 22, '2026-07-04 00:29:18', 'green', '水电与生活迹象正常', NULL, NULL, '2026-07-04 00:29:18');
INSERT INTO `el_ai_monitor_log` VALUES (9, 23, '2026-07-04 00:29:18', 'yellow', '【用量异常】出现单小时尖峰用量（超7日基线300%）：2026-07-03T18:00 用电3.39kWh', '风险判断：吴奶奶7月3日18点用电量异常激增(3.39kWh)，远超基线300%，可能存在电器故障或紧急情况。\n\n关怀措施：建议物业人员上门查看，确认老人安全状态，检查是否有电器故障。\n\n紧急程度：中等。需尽快确认老人状况，但暂无生命危险迹象。', 3, '2026-07-04 00:29:18');
INSERT INTO `el_ai_monitor_log` VALUES (10, 24, '2026-07-04 00:29:21', 'green', '水电与生活迹象正常', NULL, NULL, '2026-07-04 00:29:21');
INSERT INTO `el_ai_monitor_log` VALUES (11, 25, '2026-07-04 00:29:21', 'green', '水电与生活迹象正常', NULL, NULL, '2026-07-04 00:29:21');
INSERT INTO `el_ai_monitor_log` VALUES (12, 10, '2026-07-04 00:34:56', 'green', '水电与生活迹象正常', NULL, NULL, '2026-07-04 00:34:56');
INSERT INTO `el_ai_monitor_log` VALUES (13, 16, '2026-07-04 00:34:56', 'green', '水电与生活迹象正常', NULL, NULL, '2026-07-04 00:34:56');
INSERT INTO `el_ai_monitor_log` VALUES (14, 17, '2026-07-04 00:34:56', 'green', '水电与生活迹象正常', NULL, NULL, '2026-07-04 00:34:56');
INSERT INTO `el_ai_monitor_log` VALUES (15, 18, '2026-07-04 00:34:56', 'yellow', '【用量异常】出现单小时尖峰用量（超7日基线300%）：2026-07-03T19:00 用电1.28kWh', '该老人已有未处理预警（ID：1），本次监测未重复生成。', 1, '2026-07-04 00:34:56');
INSERT INTO `el_ai_monitor_log` VALUES (16, 19, '2026-07-04 00:34:56', 'green', '水电与生活迹象正常', NULL, NULL, '2026-07-04 00:34:56');
INSERT INTO `el_ai_monitor_log` VALUES (17, 20, '2026-07-04 00:34:56', 'yellow', '【用量异常】出现单小时尖峰用量（超7日基线300%）：2026-07-03T19:00 用水27.87L', '该老人已有未处理预警（ID：2），本次监测未重复生成。', 2, '2026-07-04 00:34:56');
INSERT INTO `el_ai_monitor_log` VALUES (18, 21, '2026-07-04 00:34:56', 'green', '水电与生活迹象正常', NULL, NULL, '2026-07-04 00:34:56');
INSERT INTO `el_ai_monitor_log` VALUES (19, 22, '2026-07-04 00:34:56', 'green', '水电与生活迹象正常', NULL, NULL, '2026-07-04 00:34:56');
INSERT INTO `el_ai_monitor_log` VALUES (20, 23, '2026-07-04 00:34:56', 'yellow', '【用量异常】出现单小时尖峰用量（超7日基线300%）：2026-07-03T18:00 用电3.39kWh', '该老人已有未处理预警（ID：3），本次监测未重复生成。', 3, '2026-07-04 00:34:56');
INSERT INTO `el_ai_monitor_log` VALUES (21, 24, '2026-07-04 00:34:56', 'green', '水电与生活迹象正常', NULL, NULL, '2026-07-04 00:34:56');
INSERT INTO `el_ai_monitor_log` VALUES (22, 25, '2026-07-04 00:34:56', 'green', '水电与生活迹象正常', NULL, NULL, '2026-07-04 00:34:56');
INSERT INTO `el_ai_monitor_log` VALUES (23, 10, '2026-07-04 10:42:18', 'yellow', '【数据缺失】近24小时仅上报12条水电记录（正常应≥18条/小时级），数据稀疏可能影响监测准确性', '风险判断：数据稀疏，无法准确评估老人生活状态，但近期水电使用模式显示正常生活迹象。\n\n关怀措施：建议增加设备检查，确认传感器工作正常；安排社区人员电话问候，确认老人安全。\n\n紧急程度：低，但需持续监测数据恢复情况。', 4, '2026-07-04 10:42:18');
INSERT INTO `el_ai_monitor_log` VALUES (24, 16, '2026-07-04 10:42:20', 'yellow', '【数据缺失】近24小时仅上报12条水电记录（正常应≥18条/小时级），数据稀疏可能影响监测准确性；【用量异常】出现单小时尖峰用量（超7日基线300%）：2026-07-03T19:00 用电3.07kWh', '风险判断：数据稀疏且出现用电尖峰，可能存在设备异常或临时用电设备使用。关怀措施：建议电话确认老人状况，检查用电设备是否正常。紧急程度：中等，需关注但非立即危险。', 5, '2026-07-04 10:42:20');
INSERT INTO `el_ai_monitor_log` VALUES (25, 17, '2026-07-04 10:42:22', 'yellow', '【数据缺失】近24小时仅上报12条水电记录（正常应≥18条/小时级），数据稀疏可能影响监测准确性', '风险判断：数据稀疏，无法准确评估老人生活状态，但近期水电使用模式显示正常生活规律。\n\n关怀措施建议：建议物业工作人员上门探访确认老人状况，检查设备是否正常工作。\n\n紧急程度：中等。数据缺失可能影响监测，但需实地确认老人安全。', 6, '2026-07-04 10:42:22');
INSERT INTO `el_ai_monitor_log` VALUES (26, 18, '2026-07-04 10:42:23', 'yellow', '【数据缺失】近24小时仅上报12条水电记录（正常应≥18条/小时级），数据稀疏可能影响监测准确性；【用量异常】出现单小时尖峰用量（超7日基线300%）：2026-07-03T19:00 用电1.28kWh', '该老人已有未处理预警（ID：1），本次监测未重复生成。', 1, '2026-07-04 10:42:23');
INSERT INTO `el_ai_monitor_log` VALUES (27, 19, '2026-07-04 10:42:23', 'yellow', '【数据缺失】近24小时仅上报12条水电记录（正常应≥18条/小时级），数据稀疏可能影响监测准确性', '风险判断：数据稀疏无法准确评估陈阿姨生活状态，但近期水电使用模式显示夜间活动减少。\n\n关怀措施：建议社区工作人员电话问候确认状况，检查设备是否正常工作。\n\n紧急程度：低，但需尽快确认数据缺失原因。', 7, '2026-07-04 10:42:23');
INSERT INTO `el_ai_monitor_log` VALUES (28, 20, '2026-07-04 10:42:24', 'yellow', '【数据缺失】近24小时仅上报12条水电记录（正常应≥18条/小时级），数据稀疏可能影响监测准确性；【用量异常】出现单小时尖峰用量（超7日基线300%）：2026-07-03T19:00 用水27.87L', '该老人已有未处理预警（ID：2），本次监测未重复生成。', 2, '2026-07-04 10:42:24');
INSERT INTO `el_ai_monitor_log` VALUES (29, 21, '2026-07-04 10:42:24', 'yellow', '【数据缺失】近24小时仅上报12条水电记录（正常应≥18条/小时级），数据稀疏可能影响监测准确性', '风险判断：数据稀疏，监测准确性受限，无法确认周奶奶生活状态。\n\n关怀措施：建议社区工作人员电话问候确认老人状况，检查水电设备是否正常工作。\n\n紧急程度：中等，需尽快确认老人安全，排除设备故障可能。', 8, '2026-07-04 10:42:24');
INSERT INTO `el_ai_monitor_log` VALUES (30, 22, '2026-07-04 10:42:26', 'yellow', '【数据缺失】近24小时仅上报12条水电记录（正常应≥18条/小时级），数据稀疏可能影响监测准确性；【用量异常】出现单小时尖峰用量（超7日基线300%）：2026-07-03T17:00 用水12.55L', '风险判断：数据稀疏且17:00用水量异常激增，可能存在用水设备故障或突发情况。\n\n关怀措施：建议物业人员电话确认老人状况，检查用水设备是否正常，必要时上门查看。\n\n紧急程度：中等。数据异常明显但无连续异常，需尽快确认情况。', 9, '2026-07-04 10:42:26');
INSERT INTO `el_ai_monitor_log` VALUES (31, 23, '2026-07-04 10:42:28', 'yellow', '【数据缺失】近24小时仅上报12条水电记录（正常应≥18条/小时级），数据稀疏可能影响监测准确性；【用量异常】出现单小时尖峰用量（超7日基线300%）：2026-07-03T18:00 用电3.39kWh', '该老人已有未处理预警（ID：3），本次监测未重复生成。', 3, '2026-07-04 10:42:28');
INSERT INTO `el_ai_monitor_log` VALUES (32, 24, '2026-07-04 10:42:28', 'yellow', '【数据缺失】近24小时仅上报12条水电记录（正常应≥18条/小时级），数据稀疏可能影响监测准确性', '风险判断：数据稀疏，无法准确判断郑大爷生活状态，可能存在设备故障或记录缺失。\n\n关怀措施建议：建议物业人员上门查看设备运行状况，确认老人是否正常生活。\n\n紧急程度：中等。需尽快确认数据缺失原因，确保老人安全。', 10, '2026-07-04 10:42:28');
INSERT INTO `el_ai_monitor_log` VALUES (33, 25, '2026-07-04 10:42:29', 'yellow', '【数据缺失】近24小时仅上报12条水电记录（正常应≥18条/小时级），数据稀疏可能影响监测准确性', '风险判断：数据稀疏，无法准确判断冯奶奶生活状态，但近期水电记录显示有基本活动迹象。\n\n关怀措施：建议社区工作人员电话问候确认老人状况，检查水电设备是否正常工作。\n\n紧急程度：中等。需尽快确认数据缺失原因，排除设备故障或老人异常情况。', 11, '2026-07-04 10:42:29');
INSERT INTO `el_ai_monitor_log` VALUES (34, 10, '2026-07-04 10:57:05', 'yellow', '【数据缺失】近24小时仅上报12条水电记录（正常应≥18条/小时级），数据稀疏可能影响监测准确性', '该老人已有未处理预警（ID：4），本次监测未重复生成。', 4, '2026-07-04 10:57:05');
INSERT INTO `el_ai_monitor_log` VALUES (35, 16, '2026-07-04 10:57:05', 'yellow', '【数据缺失】近24小时仅上报12条水电记录（正常应≥18条/小时级），数据稀疏可能影响监测准确性；【用量异常】出现单小时尖峰用量（超7日基线300%）：2026-07-03T19:00 用电3.07kWh', '该老人已有未处理预警（ID：5），本次监测未重复生成。', 5, '2026-07-04 10:57:05');
INSERT INTO `el_ai_monitor_log` VALUES (36, 17, '2026-07-04 10:57:05', 'yellow', '【数据缺失】近24小时仅上报12条水电记录（正常应≥18条/小时级），数据稀疏可能影响监测准确性', '该老人已有未处理预警（ID：6），本次监测未重复生成。', 6, '2026-07-04 10:57:05');
INSERT INTO `el_ai_monitor_log` VALUES (37, 18, '2026-07-04 10:57:05', 'yellow', '【数据缺失】近24小时仅上报12条水电记录（正常应≥18条/小时级），数据稀疏可能影响监测准确性；【用量异常】出现单小时尖峰用量（超7日基线300%）：2026-07-03T19:00 用电1.28kWh', '该老人已有未处理预警（ID：1），本次监测未重复生成。', 1, '2026-07-04 10:57:05');
INSERT INTO `el_ai_monitor_log` VALUES (38, 19, '2026-07-04 10:57:05', 'yellow', '【数据缺失】近24小时仅上报12条水电记录（正常应≥18条/小时级），数据稀疏可能影响监测准确性', '该老人已有未处理预警（ID：7），本次监测未重复生成。', 7, '2026-07-04 10:57:05');
INSERT INTO `el_ai_monitor_log` VALUES (39, 20, '2026-07-04 10:57:05', 'yellow', '【数据缺失】近24小时仅上报12条水电记录（正常应≥18条/小时级），数据稀疏可能影响监测准确性；【用量异常】出现单小时尖峰用量（超7日基线300%）：2026-07-03T19:00 用水27.87L', '该老人已有未处理预警（ID：2），本次监测未重复生成。', 2, '2026-07-04 10:57:05');
INSERT INTO `el_ai_monitor_log` VALUES (40, 21, '2026-07-04 10:57:05', 'yellow', '【数据缺失】近24小时仅上报12条水电记录（正常应≥18条/小时级），数据稀疏可能影响监测准确性', '该老人已有未处理预警（ID：8），本次监测未重复生成。', 8, '2026-07-04 10:57:05');
INSERT INTO `el_ai_monitor_log` VALUES (41, 22, '2026-07-04 10:57:05', 'yellow', '【数据缺失】近24小时仅上报12条水电记录（正常应≥18条/小时级），数据稀疏可能影响监测准确性；【用量异常】出现单小时尖峰用量（超7日基线300%）：2026-07-03T17:00 用水12.55L', '该老人已有未处理预警（ID：9），本次监测未重复生成。', 9, '2026-07-04 10:57:05');
INSERT INTO `el_ai_monitor_log` VALUES (42, 23, '2026-07-04 10:57:05', 'yellow', '【数据缺失】近24小时仅上报12条水电记录（正常应≥18条/小时级），数据稀疏可能影响监测准确性；【用量异常】出现单小时尖峰用量（超7日基线300%）：2026-07-03T18:00 用电3.39kWh', '该老人已有未处理预警（ID：3），本次监测未重复生成。', 3, '2026-07-04 10:57:05');
INSERT INTO `el_ai_monitor_log` VALUES (43, 24, '2026-07-04 10:57:05', 'yellow', '【数据缺失】近24小时仅上报12条水电记录（正常应≥18条/小时级），数据稀疏可能影响监测准确性', '该老人已有未处理预警（ID：10），本次监测未重复生成。', 10, '2026-07-04 10:57:05');
INSERT INTO `el_ai_monitor_log` VALUES (44, 25, '2026-07-04 10:57:05', 'yellow', '【数据缺失】近24小时仅上报12条水电记录（正常应≥18条/小时级），数据稀疏可能影响监测准确性', '该老人已有未处理预警（ID：11），本次监测未重复生成。', 11, '2026-07-04 10:57:05');

-- ----------------------------
-- Table structure for el_alert
-- ----------------------------
DROP TABLE IF EXISTS `el_alert`;
CREATE TABLE `el_alert`  (
  `alert_id` bigint NOT NULL AUTO_INCREMENT COMMENT '预警主键',
  `resident_id` bigint NOT NULL COMMENT '老人住户ID',
  `alert_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '预警类型',
  `alert_level` int NULL DEFAULT 2 COMMENT '等级：1高 2中 3低',
  `content` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '预警内容',
  `status` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'pending' COMMENT '状态',
  `handler_id` bigint NULL DEFAULT NULL COMMENT '处置人ID',
  `process_start_time` datetime NULL DEFAULT NULL COMMENT '开始处理时间',
  `handle_time` datetime NULL DEFAULT NULL COMMENT '处置时间',
  `handle_result` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '处置结果',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '预警时间',
  PRIMARY KEY (`alert_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 12 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '老人异常预警表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of el_alert
-- ----------------------------
INSERT INTO `el_alert` VALUES (1, 18, 'utility_anomaly', 2, '【用量异常】出现单小时尖峰用量（超7日基线300%）：2026-07-03T19:00 用电1.28kWh', 'pending', NULL, NULL, NULL, NULL, '2026-07-04 00:29:06');
INSERT INTO `el_alert` VALUES (2, 20, 'utility_anomaly', 2, '【用量异常】出现单小时尖峰用量（超7日基线300%）：2026-07-03T19:00 用水27.87L', 'pending', NULL, NULL, NULL, NULL, '2026-07-04 00:29:16');
INSERT INTO `el_alert` VALUES (3, 23, 'utility_anomaly', 2, '【用量异常】出现单小时尖峰用量（超7日基线300%）：2026-07-03T18:00 用电3.39kWh', 'pending', NULL, NULL, NULL, NULL, '2026-07-04 00:29:18');
INSERT INTO `el_alert` VALUES (4, 10, 'utility_anomaly', 2, '【数据缺失】近24小时仅上报12条水电记录（正常应≥18条/小时级），数据稀疏可能影响监测准确性', 'pending', NULL, NULL, NULL, NULL, '2026-07-04 10:42:18');
INSERT INTO `el_alert` VALUES (5, 16, 'utility_anomaly', 2, '【数据缺失】近24小时仅上报12条水电记录（正常应≥18条/小时级），数据稀疏可能影响监测准确性；【用量异常】出现单小时尖峰用量（超7日基线300%）：2026-07-03T19:00 用电3.07kWh', 'pending', NULL, NULL, NULL, NULL, '2026-07-04 10:42:20');
INSERT INTO `el_alert` VALUES (6, 17, 'utility_anomaly', 2, '【数据缺失】近24小时仅上报12条水电记录（正常应≥18条/小时级），数据稀疏可能影响监测准确性', 'pending', NULL, NULL, NULL, NULL, '2026-07-04 10:42:22');
INSERT INTO `el_alert` VALUES (7, 19, 'utility_anomaly', 2, '【数据缺失】近24小时仅上报12条水电记录（正常应≥18条/小时级），数据稀疏可能影响监测准确性', 'closed', 4, '2026-07-04 11:05:39', '2026-07-04 11:05:56', '老人无碍', '2026-07-04 10:42:23');
INSERT INTO `el_alert` VALUES (8, 21, 'utility_anomaly', 2, '【数据缺失】近24小时仅上报12条水电记录（正常应≥18条/小时级），数据稀疏可能影响监测准确性', 'closed', 4, '2026-07-04 11:05:06', '2026-07-04 11:05:28', '风险解除', '2026-07-04 10:42:24');
INSERT INTO `el_alert` VALUES (9, 22, 'utility_anomaly', 2, '【数据缺失】近24小时仅上报12条水电记录（正常应≥18条/小时级），数据稀疏可能影响监测准确性；【用量异常】出现单小时尖峰用量（超7日基线300%）：2026-07-03T17:00 用水12.55L', 'closed', 4, '2026-07-04 11:04:46', '2026-07-04 11:04:58', '无问题', '2026-07-04 10:42:26');
INSERT INTO `el_alert` VALUES (10, 24, 'utility_anomaly', 2, '【数据缺失】近24小时仅上报12条水电记录（正常应≥18条/小时级），数据稀疏可能影响监测准确性', 'closed', 4, '2026-07-04 11:04:21', '2026-07-04 11:04:33', '无问题', '2026-07-04 10:42:28');
INSERT INTO `el_alert` VALUES (11, 25, 'utility_anomaly', 2, '【数据缺失】近24小时仅上报12条水电记录（正常应≥18条/小时级），数据稀疏可能影响监测准确性', 'closed', 4, '2026-07-04 11:03:55', '2026-07-04 11:04:15', '已更新设备', '2026-07-04 10:42:29');

-- ----------------------------
-- Table structure for el_care_order
-- ----------------------------
DROP TABLE IF EXISTS `el_care_order`;
CREATE TABLE `el_care_order`  (
  `care_id` bigint NOT NULL AUTO_INCREMENT COMMENT '关怀工单主键',
  `resident_id` bigint NOT NULL COMMENT '老人住户ID',
  `care_item` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '关怀事项',
  `assignee_id` bigint NULL DEFAULT NULL COMMENT '指派人员ID（el_care_staff.staff_id）',
  `status` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'pending' COMMENT '状态',
  `result` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '处置结果摘要',
  `check_result` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '核查结果',
  `support_measure` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '帮扶措施',
  `disposal_result` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '处置结果',
  `level` int NULL DEFAULT NULL COMMENT '处置等级1/2',
  `alert_id` bigint NULL DEFAULT NULL COMMENT '关联预警ID',
  `complete_time` datetime NULL DEFAULT NULL COMMENT '完成时间',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`care_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 12 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '独居老人关怀工单表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of el_care_order
-- ----------------------------
INSERT INTO `el_care_order` VALUES (1, 18, '[AI监测] 【用量异常】出现单小时尖峰用量（超7日基线300%）：2026-07-03T19:00 用电1.28kWh', NULL, 'pending', NULL, NULL, NULL, NULL, 2, 1, NULL, '2026-07-04 00:29:16');
INSERT INTO `el_care_order` VALUES (2, 20, '[AI监测] 【用量异常】出现单小时尖峰用量（超7日基线300%）：2026-07-03T19:00 用水27.87L', NULL, 'pending', NULL, NULL, NULL, NULL, 2, 2, NULL, '2026-07-04 00:29:18');
INSERT INTO `el_care_order` VALUES (3, 23, '[AI监测] 【用量异常】出现单小时尖峰用量（超7日基线300%）：2026-07-03T18:00 用电3.39kWh', NULL, 'pending', NULL, NULL, NULL, NULL, 2, 3, NULL, '2026-07-04 00:29:21');
INSERT INTO `el_care_order` VALUES (4, 10, '[AI监测] 【数据缺失】近24小时仅上报12条水电记录（正常应≥18条/小时级），数据稀疏可能影响监测准确性', NULL, 'pending', NULL, NULL, NULL, NULL, 2, 4, NULL, '2026-07-04 10:42:20');
INSERT INTO `el_care_order` VALUES (5, 16, '[AI监测] 【数据缺失】近24小时仅上报12条水电记录（正常应≥18条/小时级），数据稀疏可能影响监测准确性；【用量异常】出现单小时尖峰用量（超7日基线300%）：2026-07-03T19:00 用电3.07kWh', NULL, 'pending', NULL, NULL, NULL, NULL, 2, 5, NULL, '2026-07-04 10:42:22');
INSERT INTO `el_care_order` VALUES (6, 17, '[AI监测] 【数据缺失】近24小时仅上报12条水电记录（正常应≥18条/小时级），数据稀疏可能影响监测准确性', NULL, 'pending', NULL, NULL, NULL, NULL, 2, 6, NULL, '2026-07-04 10:42:23');
INSERT INTO `el_care_order` VALUES (7, 19, '[AI监测] 【数据缺失】近24小时仅上报12条水电记录（正常应≥18条/小时级），数据稀疏可能影响监测准确性', 8, 'completed', '上门核查：与家属沟通 | 处理结果：老人无碍', '与家属沟通', NULL, '老人无碍', 2, 7, '2026-07-04 11:05:56', '2026-07-04 10:42:24');
INSERT INTO `el_care_order` VALUES (8, 21, '[AI监测] 【数据缺失】近24小时仅上报12条水电记录（正常应≥18条/小时级），数据稀疏可能影响监测准确性', 7, 'completed', '上门核查：已与家属电话沟通 | 处理结果：风险解除', '已与家属电话沟通', NULL, '风险解除', 2, 8, '2026-07-04 11:05:28', '2026-07-04 10:42:26');
INSERT INTO `el_care_order` VALUES (9, 22, '[AI监测] 【数据缺失】近24小时仅上报12条水电记录（正常应≥18条/小时级），数据稀疏可能影响监测准确性；【用量异常】出现单小时尖峰用量（超7日基线300%）：2026-07-03T17:00 用水12.55L', 10, 'completed', '上门核查：老人情况正常 | 处理结果：无问题', '老人情况正常', NULL, '无问题', 2, 9, '2026-07-04 11:04:58', '2026-07-04 10:42:28');
INSERT INTO `el_care_order` VALUES (10, 24, '[AI监测] 【数据缺失】近24小时仅上报12条水电记录（正常应≥18条/小时级），数据稀疏可能影响监测准确性', 3, 'completed', '上门核查：老人情况正常 | 处理结果：无问题', '老人情况正常', NULL, '无问题', 2, 10, '2026-07-04 11:04:33', '2026-07-04 10:42:29');
INSERT INTO `el_care_order` VALUES (11, 25, '[AI监测] 【数据缺失】近24小时仅上报12条水电记录（正常应≥18条/小时级），数据稀疏可能影响监测准确性', 9, 'completed', '上门核查：设备损坏 | 处理结果：已更新设备', '设备损坏', NULL, '已更新设备', 2, 11, '2026-07-04 11:04:15', '2026-07-04 10:42:31');

-- ----------------------------
-- Table structure for el_care_staff
-- ----------------------------
DROP TABLE IF EXISTS `el_care_staff`;
CREATE TABLE `el_care_staff`  (
  `staff_id` bigint NOT NULL AUTO_INCREMENT COMMENT '人员主键',
  `name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '姓名',
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '电话',
  `staff_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '网格员' COMMENT '人员类型名称',
  `building_ids` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '负责楼栋ID列表',
  `building_id` bigint NULL DEFAULT NULL COMMENT '主负责楼栋ID',
  `status` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '在岗' COMMENT '状态：在岗/休假/离职',
  PRIMARY KEY (`staff_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 12 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '关怀人员台账表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of el_care_staff
-- ----------------------------
INSERT INTO `el_care_staff` VALUES (1, '张护工', '13900001001', '护理员', '1,2,3', 1, '在岗');
INSERT INTO `el_care_staff` VALUES (2, '王医生', '13900001002', '医生', '2,4,6,8,10', 1, '在岗');
INSERT INTO `el_care_staff` VALUES (3, '李护士', '13900001003', '护士', '7,8,9,10', 4, '在岗');
INSERT INTO `el_care_staff` VALUES (4, '赵康复师', '13900001004', '康复师', '9,5,2,7', 7, '在岗');
INSERT INTO `el_care_staff` VALUES (5, '陈护工', '13900001005', '护理员', '4,5,7,6', 6, '休假');
INSERT INTO `el_care_staff` VALUES (6, '王管家', '13800000003', '物业', '3,4,1,6', NULL, '在岗');
INSERT INTO `el_care_staff` VALUES (7, '郑志愿', '13135356767', '志愿者', '7,5,9', NULL, '在岗');
INSERT INTO `el_care_staff` VALUES (8, '刘医生', '13267566789', '医生', '1,3,5,7,9', NULL, '在岗');
INSERT INTO `el_care_staff` VALUES (9, '艾护工', '13523452323', '护理员', '8,9,10', NULL, '在岗');
INSERT INTO `el_care_staff` VALUES (10, '冯护士', '13765389090', '护士', '4,5,6', NULL, '在岗');
INSERT INTO `el_care_staff` VALUES (11, '王护士', '13345786789', '护士', '1,2,3', NULL, '在岗');

-- ----------------------------
-- Table structure for el_care_staff_type
-- ----------------------------
DROP TABLE IF EXISTS `el_care_staff_type`;
CREATE TABLE `el_care_staff_type`  (
  `type_id` bigint NOT NULL AUTO_INCREMENT COMMENT '类型主键',
  `type_name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '类型名称',
  `sort_order` int NULL DEFAULT 0 COMMENT '排序',
  PRIMARY KEY (`type_id`) USING BTREE,
  UNIQUE INDEX `uk_type_name`(`type_name` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 9 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '关怀人员类型表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of el_care_staff_type
-- ----------------------------
INSERT INTO `el_care_staff_type` VALUES (1, '网格员', 1);
INSERT INTO `el_care_staff_type` VALUES (2, '安保', 2);
INSERT INTO `el_care_staff_type` VALUES (3, '志愿者', 3);
INSERT INTO `el_care_staff_type` VALUES (4, '物业', 4);
INSERT INTO `el_care_staff_type` VALUES (5, '护理员', 5);
INSERT INTO `el_care_staff_type` VALUES (6, '医生', 6);
INSERT INTO `el_care_staff_type` VALUES (7, '护士', 7);
INSERT INTO `el_care_staff_type` VALUES (8, '康复师', 8);

-- ----------------------------
-- Table structure for el_disposal_record
-- ----------------------------
DROP TABLE IF EXISTS `el_disposal_record`;
CREATE TABLE `el_disposal_record`  (
  `record_id` bigint NOT NULL AUTO_INCREMENT COMMENT '记录主键',
  `care_id` bigint NULL DEFAULT NULL COMMENT '关联工单ID',
  `alert_id` bigint NULL DEFAULT NULL COMMENT '关联预警ID',
  `handler_id` bigint NULL DEFAULT NULL COMMENT '处理人用户ID',
  `handle_time` datetime NULL DEFAULT NULL COMMENT '处理时间',
  `check_result` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '核查结果',
  `support_measure` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '帮扶措施',
  `disposal_result` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '处置结果',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`record_id`) USING BTREE,
  INDEX `idx_care_id`(`care_id` ASC) USING BTREE,
  INDEX `idx_alert_id`(`alert_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 14 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '处置记录表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of el_disposal_record
-- ----------------------------
INSERT INTO `el_disposal_record` VALUES (9, 11, 11, 4, '2026-07-04 11:03:55', '设备损坏', NULL, '已更新设备', '2026-07-04 11:04:15');
INSERT INTO `el_disposal_record` VALUES (10, 10, 10, 4, '2026-07-04 11:04:21', '老人情况正常', NULL, '无问题', '2026-07-04 11:04:33');
INSERT INTO `el_disposal_record` VALUES (11, 9, 9, 4, '2026-07-04 11:04:45', '老人情况正常', NULL, '无问题', '2026-07-04 11:04:58');
INSERT INTO `el_disposal_record` VALUES (12, 8, 8, 4, '2026-07-04 11:05:06', '已与家属电话沟通', NULL, '风险解除', '2026-07-04 11:05:28');
INSERT INTO `el_disposal_record` VALUES (13, 7, 7, 4, '2026-07-04 11:05:38', '与家属沟通', NULL, '老人无碍', '2026-07-04 11:05:56');

-- ----------------------------
-- Table structure for el_temp_guardian
-- ----------------------------
DROP TABLE IF EXISTS `el_temp_guardian`;
CREATE TABLE `el_temp_guardian`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `resident_id` bigint NOT NULL COMMENT '老人住户ID',
  `guardian_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '临时监护人姓名',
  `guardian_phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '临时监护人电话',
  `start_time` datetime NOT NULL COMMENT '监护开始时间',
  `end_time` datetime NOT NULL COMMENT '监护结束时间',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '1' COMMENT '状态：1有效 0已失效',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_resident`(`resident_id` ASC) USING BTREE,
  INDEX `idx_time`(`start_time` ASC, `end_time` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '老人临时监护登记表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of el_temp_guardian
-- ----------------------------

-- ----------------------------
-- Table structure for el_utility_data
-- ----------------------------
DROP TABLE IF EXISTS `el_utility_data`;
CREATE TABLE `el_utility_data`  (
  `data_id` bigint NOT NULL AUTO_INCREMENT COMMENT '数据主键',
  `resident_id` bigint NOT NULL COMMENT '老人住户ID',
  `record_time` datetime NOT NULL COMMENT '数据时间（小时级）',
  `water_usage` decimal(10, 2) NULL DEFAULT 0.00 COMMENT '用水量（升）',
  `electric_usage` decimal(10, 2) NULL DEFAULT 0.00 COMMENT '用电量（千瓦时）',
  `source` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'real' COMMENT '数据来源：real/simulated',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`data_id`) USING BTREE,
  INDEX `idx_resident_time`(`resident_id` ASC, `record_time` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 6334 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '独居老人水电使用数据表（小时级）' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of el_utility_data
-- ----------------------------
INSERT INTO `el_utility_data` VALUES (7, 9, '2026-06-28 08:00:00', 9.20, 0.70, 'simulated', '2026-07-02 20:09:05');
INSERT INTO `el_utility_data` VALUES (8, 9, '2026-06-28 18:00:00', 13.50, 1.40, 'simulated', '2026-07-02 20:09:05');
INSERT INTO `el_utility_data` VALUES (9, 9, '2026-06-29 08:00:00', 8.80, 0.65, 'simulated', '2026-07-02 20:09:05');
INSERT INTO `el_utility_data` VALUES (10, 9, '2026-06-29 18:00:00', 12.90, 1.30, 'simulated', '2026-07-02 20:09:05');
INSERT INTO `el_utility_data` VALUES (11, 9, '2026-06-30 08:00:00', 9.50, 0.75, 'simulated', '2026-07-02 20:09:05');
INSERT INTO `el_utility_data` VALUES (12, 9, '2026-06-30 18:00:00', 14.20, 1.45, 'simulated', '2026-07-02 20:09:05');
INSERT INTO `el_utility_data` VALUES (13, 14, '2026-06-28 08:00:00', 8.50, 0.60, 'simulated', '2026-07-02 20:09:05');
INSERT INTO `el_utility_data` VALUES (14, 14, '2026-06-28 18:00:00', 12.80, 1.20, 'simulated', '2026-07-02 20:09:05');
INSERT INTO `el_utility_data` VALUES (15, 14, '2026-06-29 08:00:00', 9.00, 0.68, 'simulated', '2026-07-02 20:09:05');
INSERT INTO `el_utility_data` VALUES (16, 14, '2026-06-29 18:00:00', 13.20, 1.35, 'simulated', '2026-07-02 20:09:05');
INSERT INTO `el_utility_data` VALUES (17, 14, '2026-06-30 08:00:00', 8.90, 0.62, 'simulated', '2026-07-02 20:09:05');
INSERT INTO `el_utility_data` VALUES (18, 14, '2026-06-30 18:00:00', 13.60, 1.28, 'simulated', '2026-07-02 20:09:05');
INSERT INTO `el_utility_data` VALUES (3799, 21, '2026-06-26 22:00:00', 1.69, 0.20, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3800, 21, '2026-06-26 23:00:00', 2.27, 0.09, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3801, 21, '2026-06-27 00:00:00', 0.12, 0.17, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3802, 21, '2026-06-27 01:00:00', 0.87, 0.21, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3803, 21, '2026-06-27 02:00:00', 2.59, 0.25, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3804, 21, '2026-06-27 03:00:00', 0.98, 0.10, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3805, 21, '2026-06-27 04:00:00', 2.61, 0.17, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3806, 21, '2026-06-27 05:00:00', 3.28, 0.43, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3807, 21, '2026-06-27 06:00:00', 17.85, 0.88, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3808, 21, '2026-06-27 07:00:00', 26.99, 0.41, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3809, 21, '2026-06-27 08:00:00', 19.30, 0.68, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3810, 21, '2026-06-27 09:00:00', 23.92, 0.85, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3811, 21, '2026-06-27 10:00:00', 4.51, 0.25, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3812, 21, '2026-06-27 11:00:00', 10.55, 0.43, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3813, 21, '2026-06-27 12:00:00', 14.97, 0.68, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3814, 21, '2026-06-27 13:00:00', 18.01, 0.96, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3815, 21, '2026-06-27 14:00:00', 7.93, 0.35, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3816, 21, '2026-06-27 15:00:00', 6.60, 0.62, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3817, 21, '2026-06-27 16:00:00', 3.21, 0.37, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3818, 21, '2026-06-27 17:00:00', 15.55, 1.72, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3819, 21, '2026-06-27 18:00:00', 34.04, 1.47, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3820, 21, '2026-06-27 19:00:00', 35.57, 0.63, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3821, 21, '2026-06-27 20:00:00', 20.40, 0.59, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3822, 21, '2026-06-27 21:00:00', 5.74, 0.21, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3823, 21, '2026-06-27 22:00:00', 0.63, 0.26, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3824, 21, '2026-06-27 23:00:00', 1.19, 0.23, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3825, 21, '2026-06-28 00:00:00', 2.01, 0.20, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3826, 21, '2026-06-28 01:00:00', 2.32, 0.23, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3827, 21, '2026-06-28 02:00:00', 2.06, 0.20, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3828, 21, '2026-06-28 03:00:00', 2.06, 0.14, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3829, 21, '2026-06-28 04:00:00', 1.86, 0.29, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3830, 21, '2026-06-28 05:00:00', 4.25, 0.28, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3831, 21, '2026-06-28 06:00:00', 24.34, 1.12, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3832, 21, '2026-06-28 07:00:00', 12.43, 0.61, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3833, 21, '2026-06-28 08:00:00', 14.57, 0.71, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3834, 21, '2026-06-28 09:00:00', 26.87, 0.58, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3835, 21, '2026-06-28 10:00:00', 7.17, 0.64, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3836, 21, '2026-06-28 11:00:00', 10.64, 0.42, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3837, 21, '2026-06-28 12:00:00', 10.82, 0.96, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3838, 21, '2026-06-28 13:00:00', 20.55, 0.85, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3839, 21, '2026-06-28 14:00:00', 8.89, 0.37, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3840, 21, '2026-06-28 15:00:00', 5.61, 0.20, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3841, 21, '2026-06-28 16:00:00', 8.87, 0.67, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3842, 21, '2026-06-28 17:00:00', 16.40, 1.62, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3843, 21, '2026-06-28 18:00:00', 33.06, 2.04, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3844, 21, '2026-06-28 19:00:00', 35.53, 1.99, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3845, 21, '2026-06-28 20:00:00', 28.91, 1.49, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3846, 21, '2026-06-28 21:00:00', 4.25, 0.29, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3847, 21, '2026-06-28 22:00:00', 1.98, 0.27, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3848, 21, '2026-06-28 23:00:00', 0.03, 0.24, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3849, 21, '2026-06-29 00:00:00', 2.34, 0.08, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3850, 21, '2026-06-29 01:00:00', 0.24, 0.27, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3851, 21, '2026-06-29 02:00:00', 2.80, 0.12, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3852, 21, '2026-06-29 03:00:00', 1.71, 0.25, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3853, 21, '2026-06-29 04:00:00', 0.31, 0.13, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3854, 21, '2026-06-29 05:00:00', 5.14, 0.58, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3855, 21, '2026-06-29 06:00:00', 27.15, 1.01, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3856, 21, '2026-06-29 07:00:00', 18.10, 1.09, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3857, 21, '2026-06-29 08:00:00', 16.03, 0.92, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3858, 21, '2026-06-29 09:00:00', 20.08, 1.27, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3859, 21, '2026-06-29 10:00:00', 5.84, 0.43, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3860, 21, '2026-06-29 11:00:00', 18.06, 0.90, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3861, 21, '2026-06-29 12:00:00', 10.79, 1.02, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3862, 21, '2026-06-29 13:00:00', 17.46, 1.17, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3863, 21, '2026-06-29 14:00:00', 7.87, 0.56, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3864, 21, '2026-06-29 15:00:00', 5.46, 0.15, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3865, 21, '2026-06-29 16:00:00', 3.12, 0.69, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3866, 21, '2026-06-29 17:00:00', 27.64, 1.74, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3867, 21, '2026-06-29 18:00:00', 20.20, 1.69, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3868, 21, '2026-06-29 19:00:00', 29.29, 1.79, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3869, 21, '2026-06-29 20:00:00', 35.35, 1.31, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3870, 21, '2026-06-29 21:00:00', 2.93, 0.40, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3871, 21, '2026-06-29 22:00:00', 2.50, 0.17, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3872, 21, '2026-06-29 23:00:00', 2.13, 0.11, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3873, 21, '2026-06-30 00:00:00', 1.18, 0.24, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3874, 21, '2026-06-30 01:00:00', 0.16, 0.11, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3875, 21, '2026-06-30 02:00:00', 2.56, 0.24, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3876, 21, '2026-06-30 03:00:00', 2.41, 0.18, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3877, 21, '2026-06-30 04:00:00', 0.60, 0.12, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3878, 21, '2026-06-30 05:00:00', 6.06, 0.41, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3879, 21, '2026-06-30 06:00:00', 16.69, 1.11, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3880, 21, '2026-06-30 07:00:00', 15.89, 1.05, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3881, 21, '2026-06-30 08:00:00', 17.02, 0.81, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3882, 21, '2026-06-30 09:00:00', 12.73, 1.13, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3883, 21, '2026-06-30 10:00:00', 4.11, 0.62, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3884, 21, '2026-06-30 11:00:00', 10.59, 1.17, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3885, 21, '2026-06-30 12:00:00', 16.04, 1.10, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3886, 21, '2026-06-30 13:00:00', 9.66, 0.86, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3887, 21, '2026-06-30 14:00:00', 4.38, 0.66, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3888, 21, '2026-06-30 15:00:00', 6.16, 0.48, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3889, 21, '2026-06-30 16:00:00', 6.92, 0.41, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3890, 21, '2026-06-30 17:00:00', 33.87, 1.52, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3891, 21, '2026-06-30 18:00:00', 14.41, 0.85, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3892, 21, '2026-06-30 19:00:00', 16.68, 0.99, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3893, 21, '2026-06-30 20:00:00', 24.99, 1.21, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3894, 21, '2026-06-30 21:00:00', 8.71, 0.25, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3895, 21, '2026-06-30 22:00:00', 2.42, 0.08, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3896, 21, '2026-06-30 23:00:00', 0.28, 0.10, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3897, 21, '2026-07-01 00:00:00', 1.53, 0.12, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3898, 21, '2026-07-01 01:00:00', 2.03, 0.21, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3899, 21, '2026-07-01 02:00:00', 0.89, 0.16, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3900, 21, '2026-07-01 03:00:00', 0.31, 0.18, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3901, 21, '2026-07-01 04:00:00', 1.28, 0.13, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3902, 21, '2026-07-01 05:00:00', 8.94, 0.15, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3903, 21, '2026-07-01 06:00:00', 11.97, 1.00, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3904, 21, '2026-07-01 07:00:00', 18.61, 0.40, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3905, 21, '2026-07-01 08:00:00', 27.92, 0.67, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3906, 21, '2026-07-01 09:00:00', 20.30, 0.63, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3907, 21, '2026-07-01 10:00:00', 4.62, 0.30, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3908, 21, '2026-07-01 11:00:00', 18.49, 0.62, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3909, 21, '2026-07-01 12:00:00', 11.53, 0.68, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3910, 21, '2026-07-01 13:00:00', 11.65, 0.45, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3911, 21, '2026-07-01 14:00:00', 3.80, 0.43, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3912, 21, '2026-07-01 15:00:00', 9.07, 0.24, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3913, 21, '2026-07-01 16:00:00', 3.68, 0.30, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3914, 21, '2026-07-01 17:00:00', 31.78, 1.00, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3915, 21, '2026-07-01 18:00:00', 14.40, 1.59, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3916, 21, '2026-07-01 19:00:00', 30.42, 1.43, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3917, 21, '2026-07-01 20:00:00', 31.55, 0.68, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3918, 21, '2026-07-01 21:00:00', 5.37, 0.71, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3919, 21, '2026-07-01 22:00:00', 2.41, 0.11, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3920, 21, '2026-07-01 23:00:00', 2.34, 0.16, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3921, 21, '2026-07-02 00:00:00', 0.28, 0.26, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3922, 21, '2026-07-02 01:00:00', 0.42, 0.25, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3923, 21, '2026-07-02 02:00:00', 2.19, 0.13, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3924, 21, '2026-07-02 03:00:00', 2.74, 0.22, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3925, 21, '2026-07-02 04:00:00', 1.42, 0.27, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3926, 21, '2026-07-02 05:00:00', 2.98, 0.24, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3927, 21, '2026-07-02 06:00:00', 18.26, 1.08, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3928, 21, '2026-07-02 07:00:00', 22.94, 0.52, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3929, 21, '2026-07-02 08:00:00', 20.92, 1.12, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3930, 21, '2026-07-02 09:00:00', 16.88, 1.30, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3931, 21, '2026-07-02 10:00:00', 4.73, 0.61, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3932, 21, '2026-07-02 11:00:00', 18.67, 1.12, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3933, 21, '2026-07-02 12:00:00', 13.84, 0.30, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3934, 21, '2026-07-02 13:00:00', 20.92, 0.40, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3935, 21, '2026-07-02 14:00:00', 7.40, 0.48, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3936, 21, '2026-07-02 15:00:00', 9.29, 0.55, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3937, 21, '2026-07-02 16:00:00', 5.64, 0.63, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3938, 21, '2026-07-02 17:00:00', 27.45, 1.89, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3939, 21, '2026-07-02 18:00:00', 24.73, 0.88, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3940, 21, '2026-07-02 19:00:00', 20.71, 1.39, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3941, 21, '2026-07-02 20:00:00', 19.32, 1.87, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3942, 21, '2026-07-02 21:00:00', 5.57, 0.73, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3943, 21, '2026-07-02 22:00:00', 1.30, 0.15, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3944, 21, '2026-07-02 23:00:00', 1.67, 0.25, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3945, 21, '2026-07-03 00:00:00', 0.24, 0.29, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3946, 21, '2026-07-03 01:00:00', 1.83, 0.07, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3947, 21, '2026-07-03 02:00:00', 0.03, 0.25, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3948, 21, '2026-07-03 03:00:00', 2.86, 0.23, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3949, 21, '2026-07-03 04:00:00', 1.31, 0.28, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3950, 21, '2026-07-03 05:00:00', 8.73, 0.59, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3951, 21, '2026-07-03 06:00:00', 14.28, 0.83, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3952, 21, '2026-07-03 07:00:00', 26.06, 0.52, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3953, 21, '2026-07-03 08:00:00', 27.16, 0.62, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3954, 21, '2026-07-03 09:00:00', 15.18, 1.28, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3955, 21, '2026-07-03 10:00:00', 6.22, 0.64, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3956, 21, '2026-07-03 11:00:00', 8.77, 0.80, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3957, 21, '2026-07-03 12:00:00', 19.84, 0.92, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3958, 21, '2026-07-03 13:00:00', 11.04, 0.62, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3959, 21, '2026-07-03 14:00:00', 3.99, 0.36, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3960, 21, '2026-07-03 15:00:00', 8.11, 0.29, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3961, 21, '2026-07-03 16:00:00', 7.81, 0.49, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3962, 21, '2026-07-03 17:00:00', 31.52, 0.79, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3963, 21, '2026-07-03 18:00:00', 27.45, 0.78, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3964, 21, '2026-07-03 19:00:00', 20.42, 0.86, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3965, 21, '2026-07-03 20:00:00', 15.11, 1.87, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3966, 21, '2026-07-03 21:00:00', 3.58, 0.58, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (3967, 21, '2026-07-03 22:00:00', 1.52, 0.11, 'simulated', '2026-07-03 22:11:37');
INSERT INTO `el_utility_data` VALUES (4644, 10, '2026-06-27 11:00:00', 17.02, 0.62, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4645, 10, '2026-06-27 12:00:00', 14.71, 0.51, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4646, 10, '2026-06-27 13:00:00', 8.91, 0.44, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4647, 10, '2026-06-27 14:00:00', 8.32, 0.19, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4648, 10, '2026-06-27 15:00:00', 6.20, 0.13, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4649, 10, '2026-06-27 16:00:00', 7.71, 0.29, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4650, 10, '2026-06-27 17:00:00', 27.00, 0.73, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4651, 10, '2026-06-27 18:00:00', 19.34, 0.46, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4652, 10, '2026-06-27 19:00:00', 28.34, 0.34, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4653, 10, '2026-06-27 20:00:00', 13.09, 1.02, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4654, 10, '2026-06-27 21:00:00', 5.28, 0.18, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4655, 10, '2026-06-27 22:00:00', 2.25, 0.10, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4656, 10, '2026-06-27 23:00:00', 1.14, 0.13, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4657, 10, '2026-06-28 00:00:00', 2.27, 0.13, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4658, 10, '2026-06-28 01:00:00', 1.60, 0.06, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4659, 10, '2026-06-28 02:00:00', 1.61, 0.11, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4660, 10, '2026-06-28 03:00:00', 0.23, 0.09, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4661, 10, '2026-06-28 04:00:00', 1.94, 0.11, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4662, 10, '2026-06-28 05:00:00', 3.00, 0.24, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4663, 10, '2026-06-28 06:00:00', 23.72, 0.32, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4664, 10, '2026-06-28 07:00:00', 20.96, 0.67, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4665, 10, '2026-06-28 08:00:00', 23.61, 0.49, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4666, 10, '2026-06-28 09:00:00', 21.28, 0.72, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4667, 10, '2026-06-28 10:00:00', 5.08, 0.19, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4668, 10, '2026-06-28 11:00:00', 14.28, 0.36, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4669, 10, '2026-06-28 12:00:00', 9.98, 0.31, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4670, 10, '2026-06-28 13:00:00', 8.11, 0.18, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4671, 10, '2026-06-28 14:00:00', 6.03, 0.37, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4672, 10, '2026-06-28 15:00:00', 8.54, 0.29, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4673, 10, '2026-06-28 16:00:00', 4.10, 0.15, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4674, 10, '2026-06-28 17:00:00', 21.53, 0.96, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4675, 10, '2026-06-28 18:00:00', 21.54, 0.64, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4676, 10, '2026-06-28 19:00:00', 26.77, 0.71, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4677, 10, '2026-06-28 20:00:00', 29.74, 1.06, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4678, 10, '2026-06-28 21:00:00', 4.73, 0.31, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4679, 10, '2026-06-28 22:00:00', 1.83, 0.09, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4680, 10, '2026-06-28 23:00:00', 0.00, 0.09, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4681, 10, '2026-06-29 00:00:00', 1.54, 0.11, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4682, 10, '2026-06-29 01:00:00', 2.28, 0.13, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4683, 10, '2026-06-29 02:00:00', 1.93, 0.07, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4684, 10, '2026-06-29 03:00:00', 1.51, 0.17, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4685, 10, '2026-06-29 04:00:00', 0.75, 0.15, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4686, 10, '2026-06-29 05:00:00', 4.89, 0.37, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4687, 10, '2026-06-29 06:00:00', 10.05, 0.63, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4688, 10, '2026-06-29 07:00:00', 24.24, 0.33, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4689, 10, '2026-06-29 08:00:00', 24.39, 0.54, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4690, 10, '2026-06-29 09:00:00', 21.54, 0.61, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4691, 10, '2026-06-29 10:00:00', 6.14, 0.29, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4692, 10, '2026-06-29 11:00:00', 7.76, 0.44, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4693, 10, '2026-06-29 12:00:00', 13.66, 0.55, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4694, 10, '2026-06-29 13:00:00', 17.88, 0.40, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4695, 10, '2026-06-29 14:00:00', 5.80, 0.27, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4696, 10, '2026-06-29 15:00:00', 7.10, 0.22, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4697, 10, '2026-06-29 16:00:00', 7.16, 0.37, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4698, 10, '2026-06-29 17:00:00', 18.24, 0.34, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4699, 10, '2026-06-29 18:00:00', 26.30, 0.98, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4700, 10, '2026-06-29 19:00:00', 23.99, 0.99, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4701, 10, '2026-06-29 20:00:00', 18.02, 0.37, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4702, 10, '2026-06-29 21:00:00', 3.01, 0.28, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4703, 10, '2026-06-29 22:00:00', 2.46, 0.09, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4704, 10, '2026-06-29 23:00:00', 0.45, 0.13, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4705, 10, '2026-06-30 00:00:00', 1.74, 0.09, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4706, 10, '2026-06-30 01:00:00', 1.52, 0.09, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4707, 10, '2026-06-30 02:00:00', 2.44, 0.11, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4708, 10, '2026-06-30 03:00:00', 0.86, 0.05, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4709, 10, '2026-06-30 04:00:00', 1.86, 0.09, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4710, 10, '2026-06-30 05:00:00', 4.02, 0.29, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4711, 10, '2026-06-30 06:00:00', 10.85, 0.52, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4712, 10, '2026-06-30 07:00:00', 20.05, 0.35, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4713, 10, '2026-06-30 08:00:00', 22.85, 0.54, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4714, 10, '2026-06-30 09:00:00', 24.48, 0.21, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4715, 10, '2026-06-30 10:00:00', 3.44, 0.30, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4716, 10, '2026-06-30 11:00:00', 14.95, 0.56, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4717, 10, '2026-06-30 12:00:00', 9.08, 0.41, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4718, 10, '2026-06-30 13:00:00', 12.69, 0.45, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4719, 10, '2026-06-30 14:00:00', 8.58, 0.20, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4720, 10, '2026-06-30 15:00:00', 6.95, 0.10, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4721, 10, '2026-06-30 16:00:00', 4.66, 0.26, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4722, 10, '2026-06-30 17:00:00', 26.52, 0.53, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4723, 10, '2026-06-30 18:00:00', 26.17, 0.54, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4724, 10, '2026-06-30 19:00:00', 24.51, 0.36, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4725, 10, '2026-06-30 20:00:00', 29.84, 0.73, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4726, 10, '2026-06-30 21:00:00', 6.65, 0.33, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4727, 10, '2026-06-30 22:00:00', 1.62, 0.10, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4728, 10, '2026-06-30 23:00:00', 1.65, 0.09, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4729, 10, '2026-07-01 00:00:00', 0.32, 0.17, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4730, 10, '2026-07-01 01:00:00', 0.40, 0.06, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4731, 10, '2026-07-01 02:00:00', 0.42, 0.14, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4732, 10, '2026-07-01 03:00:00', 1.51, 0.08, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4733, 10, '2026-07-01 04:00:00', 0.93, 0.10, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4734, 10, '2026-07-01 05:00:00', 4.86, 0.27, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4735, 10, '2026-07-01 06:00:00', 21.10, 0.22, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4736, 10, '2026-07-01 07:00:00', 17.08, 0.25, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4737, 10, '2026-07-01 08:00:00', 19.40, 0.60, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4738, 10, '2026-07-01 09:00:00', 18.12, 0.35, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4739, 10, '2026-07-01 10:00:00', 5.00, 0.27, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4740, 10, '2026-07-01 11:00:00', 13.08, 0.53, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4741, 10, '2026-07-01 12:00:00', 14.53, 0.57, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4742, 10, '2026-07-01 13:00:00', 9.40, 0.58, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4743, 10, '2026-07-01 14:00:00', 5.44, 0.20, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4744, 10, '2026-07-01 15:00:00', 7.43, 0.40, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4745, 10, '2026-07-01 16:00:00', 5.52, 0.18, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4746, 10, '2026-07-01 17:00:00', 27.04, 1.00, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4747, 10, '2026-07-01 18:00:00', 19.50, 1.08, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4748, 10, '2026-07-01 19:00:00', 25.81, 0.81, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4749, 10, '2026-07-01 20:00:00', 18.98, 0.93, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4750, 10, '2026-07-01 21:00:00', 2.78, 0.42, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4751, 10, '2026-07-01 22:00:00', 0.64, 0.06, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4752, 10, '2026-07-01 23:00:00', 2.11, 0.12, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4753, 10, '2026-07-02 00:00:00', 2.15, 0.06, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4754, 10, '2026-07-02 01:00:00', 2.41, 0.15, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4755, 10, '2026-07-02 02:00:00', 1.72, 0.09, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4756, 10, '2026-07-02 03:00:00', 0.93, 0.05, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4757, 10, '2026-07-02 04:00:00', 0.01, 0.08, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4758, 10, '2026-07-02 05:00:00', 6.30, 0.10, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4759, 10, '2026-07-02 06:00:00', 10.87, 0.27, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4760, 10, '2026-07-02 07:00:00', 21.07, 0.59, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4761, 10, '2026-07-02 08:00:00', 11.63, 0.81, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4762, 10, '2026-07-02 09:00:00', 13.57, 0.50, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4763, 10, '2026-07-02 10:00:00', 3.18, 0.12, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4764, 10, '2026-07-02 11:00:00', 9.13, 0.34, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4765, 10, '2026-07-02 12:00:00', 10.64, 0.27, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4766, 10, '2026-07-02 13:00:00', 8.10, 0.34, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4767, 10, '2026-07-02 14:00:00', 7.25, 0.40, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4768, 10, '2026-07-02 15:00:00', 6.65, 0.28, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4769, 10, '2026-07-02 16:00:00', 8.51, 0.34, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4770, 10, '2026-07-02 17:00:00', 13.10, 0.91, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4771, 10, '2026-07-02 18:00:00', 20.12, 0.43, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4772, 10, '2026-07-02 19:00:00', 12.59, 0.43, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4773, 10, '2026-07-02 20:00:00', 19.21, 0.82, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4774, 10, '2026-07-02 21:00:00', 3.18, 0.39, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4775, 10, '2026-07-02 22:00:00', 0.09, 0.11, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4776, 10, '2026-07-02 23:00:00', 0.87, 0.13, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4777, 10, '2026-07-03 00:00:00', 0.07, 0.13, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4778, 10, '2026-07-03 01:00:00', 0.83, 0.05, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4779, 10, '2026-07-03 02:00:00', 2.43, 0.09, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4780, 10, '2026-07-03 03:00:00', 1.29, 0.06, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4781, 10, '2026-07-03 04:00:00', 1.52, 0.11, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4782, 10, '2026-07-03 05:00:00', 4.94, 0.37, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4783, 10, '2026-07-03 06:00:00', 13.95, 0.32, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4784, 10, '2026-07-03 07:00:00', 16.88, 0.34, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4785, 10, '2026-07-03 08:00:00', 21.73, 0.76, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4786, 10, '2026-07-03 09:00:00', 15.81, 0.50, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4787, 10, '2026-07-03 10:00:00', 6.82, 0.14, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4788, 10, '2026-07-03 11:00:00', 18.14, 0.36, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4789, 10, '2026-07-03 12:00:00', 14.93, 0.23, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4790, 10, '2026-07-03 13:00:00', 9.70, 0.35, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4791, 10, '2026-07-03 14:00:00', 3.28, 0.25, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4792, 10, '2026-07-03 15:00:00', 5.04, 0.41, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4793, 10, '2026-07-03 16:00:00', 2.62, 0.34, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4794, 10, '2026-07-03 17:00:00', 21.99, 0.90, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4795, 10, '2026-07-03 18:00:00', 25.73, 0.76, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4796, 10, '2026-07-03 19:00:00', 26.80, 0.68, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4797, 10, '2026-07-03 20:00:00', 14.17, 0.77, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4798, 10, '2026-07-03 21:00:00', 6.06, 0.24, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4799, 10, '2026-07-03 22:00:00', 0.16, 0.06, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4800, 10, '2026-07-03 23:00:00', 2.17, 0.13, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4801, 10, '2026-07-04 00:00:00', 1.56, 0.09, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4802, 10, '2026-07-04 01:00:00', 0.52, 0.07, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4803, 10, '2026-07-04 02:00:00', 1.03, 0.07, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4804, 10, '2026-07-04 03:00:00', 1.51, 0.05, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4805, 10, '2026-07-04 04:00:00', 1.96, 0.05, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4806, 10, '2026-07-04 05:00:00', 5.71, 0.28, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4807, 10, '2026-07-04 06:00:00', 16.41, 0.73, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4808, 10, '2026-07-04 07:00:00', 22.25, 0.23, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4809, 10, '2026-07-04 08:00:00', 22.35, 0.34, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4810, 10, '2026-07-04 09:00:00', 16.18, 0.37, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4811, 10, '2026-07-04 10:00:00', 4.02, 0.39, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4812, 10, '2026-07-04 11:00:00', 17.69, 0.18, 'simulated', '2026-07-04 11:05:59');
INSERT INTO `el_utility_data` VALUES (4813, 16, '2026-06-27 11:00:00', 8.94, 0.90, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4814, 16, '2026-06-27 12:00:00', 6.44, 1.67, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4815, 16, '2026-06-27 13:00:00', 12.88, 1.94, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4816, 16, '2026-06-27 14:00:00', 2.70, 1.11, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4817, 16, '2026-06-27 15:00:00', 3.54, 0.37, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4818, 16, '2026-06-27 16:00:00', 4.00, 1.08, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4819, 16, '2026-06-27 17:00:00', 23.37, 3.37, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4820, 16, '2026-06-27 18:00:00', 17.26, 1.02, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4821, 16, '2026-06-27 19:00:00', 13.33, 3.12, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4822, 16, '2026-06-27 20:00:00', 14.75, 2.47, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4823, 16, '2026-06-27 21:00:00', 4.29, 0.87, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4824, 16, '2026-06-27 22:00:00', 1.18, 0.31, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4825, 16, '2026-06-27 23:00:00', 1.50, 0.39, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4826, 16, '2026-06-28 00:00:00', 0.86, 0.42, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4827, 16, '2026-06-28 01:00:00', 0.40, 0.13, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4828, 16, '2026-06-28 02:00:00', 0.87, 0.27, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4829, 16, '2026-06-28 03:00:00', 1.54, 0.20, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4830, 16, '2026-06-28 04:00:00', 0.02, 0.32, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4831, 16, '2026-06-28 05:00:00', 3.42, 1.14, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4832, 16, '2026-06-28 06:00:00', 9.43, 1.42, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4833, 16, '2026-06-28 07:00:00', 12.20, 2.12, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4834, 16, '2026-06-28 08:00:00', 18.61, 2.23, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4835, 16, '2026-06-28 09:00:00', 15.80, 0.85, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4836, 16, '2026-06-28 10:00:00', 2.91, 0.93, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4837, 16, '2026-06-28 11:00:00', 13.39, 1.20, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4838, 16, '2026-06-28 12:00:00', 13.68, 1.71, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4839, 16, '2026-06-28 13:00:00', 5.58, 0.59, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4840, 16, '2026-06-28 14:00:00', 5.83, 0.40, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4841, 16, '2026-06-28 15:00:00', 5.97, 1.13, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4842, 16, '2026-06-28 16:00:00', 3.28, 1.04, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4843, 16, '2026-06-28 17:00:00', 11.34, 1.01, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4844, 16, '2026-06-28 18:00:00', 12.04, 2.53, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4845, 16, '2026-06-28 19:00:00', 17.90, 3.34, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4846, 16, '2026-06-28 20:00:00', 16.85, 1.70, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4847, 16, '2026-06-28 21:00:00', 3.40, 0.25, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4848, 16, '2026-06-28 22:00:00', 0.03, 0.39, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4849, 16, '2026-06-28 23:00:00', 1.27, 0.24, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4850, 16, '2026-06-29 00:00:00', 0.13, 0.47, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4851, 16, '2026-06-29 01:00:00', 0.12, 0.15, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4852, 16, '2026-06-29 02:00:00', 0.11, 0.30, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4853, 16, '2026-06-29 03:00:00', 0.94, 0.19, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4854, 16, '2026-06-29 04:00:00', 1.61, 0.36, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4855, 16, '2026-06-29 05:00:00', 2.79, 0.76, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4856, 16, '2026-06-29 06:00:00', 8.08, 0.72, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4857, 16, '2026-06-29 07:00:00', 15.16, 2.08, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4858, 16, '2026-06-29 08:00:00', 13.93, 1.15, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4859, 16, '2026-06-29 09:00:00', 17.86, 1.02, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4860, 16, '2026-06-29 10:00:00', 4.03, 0.63, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4861, 16, '2026-06-29 11:00:00', 14.13, 0.80, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4862, 16, '2026-06-29 12:00:00', 13.13, 1.81, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4863, 16, '2026-06-29 13:00:00', 13.08, 0.95, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4864, 16, '2026-06-29 14:00:00', 3.11, 1.13, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4865, 16, '2026-06-29 15:00:00', 3.35, 0.46, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4866, 16, '2026-06-29 16:00:00', 2.82, 1.08, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4867, 16, '2026-06-29 17:00:00', 11.39, 2.75, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4868, 16, '2026-06-29 18:00:00', 12.41, 2.46, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4869, 16, '2026-06-29 19:00:00', 15.27, 2.66, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4870, 16, '2026-06-29 20:00:00', 10.70, 1.30, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4871, 16, '2026-06-29 21:00:00', 4.94, 0.57, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4872, 16, '2026-06-29 22:00:00', 0.75, 0.14, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4873, 16, '2026-06-29 23:00:00', 1.18, 0.32, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4874, 16, '2026-06-30 00:00:00', 0.09, 0.37, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4875, 16, '2026-06-30 01:00:00', 1.79, 0.40, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4876, 16, '2026-06-30 02:00:00', 0.61, 0.20, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4877, 16, '2026-06-30 03:00:00', 0.28, 0.19, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4878, 16, '2026-06-30 04:00:00', 0.27, 0.32, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4879, 16, '2026-06-30 05:00:00', 3.41, 0.30, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4880, 16, '2026-06-30 06:00:00', 13.79, 0.84, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4881, 16, '2026-06-30 07:00:00', 18.64, 0.92, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4882, 16, '2026-06-30 08:00:00', 12.01, 1.13, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4883, 16, '2026-06-30 09:00:00', 9.55, 2.36, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4884, 16, '2026-06-30 10:00:00', 4.91, 0.99, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4885, 16, '2026-06-30 11:00:00', 13.10, 0.82, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4886, 16, '2026-06-30 12:00:00', 6.28, 1.77, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4887, 16, '2026-06-30 13:00:00', 10.54, 0.67, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4888, 16, '2026-06-30 14:00:00', 2.80, 0.90, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4889, 16, '2026-06-30 15:00:00', 3.20, 0.48, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4890, 16, '2026-06-30 16:00:00', 2.27, 1.12, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4891, 16, '2026-06-30 17:00:00', 17.13, 2.86, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4892, 16, '2026-06-30 18:00:00', 22.47, 1.67, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4893, 16, '2026-06-30 19:00:00', 15.34, 2.24, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4894, 16, '2026-06-30 20:00:00', 22.00, 1.04, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4895, 16, '2026-06-30 21:00:00', 5.11, 1.00, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4896, 16, '2026-06-30 22:00:00', 0.07, 0.42, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4897, 16, '2026-06-30 23:00:00', 0.63, 0.31, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4898, 16, '2026-07-01 00:00:00', 0.61, 0.46, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4899, 16, '2026-07-01 01:00:00', 0.56, 0.37, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4900, 16, '2026-07-01 02:00:00', 1.66, 0.22, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4901, 16, '2026-07-01 03:00:00', 1.73, 0.13, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4902, 16, '2026-07-01 04:00:00', 0.77, 0.16, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4903, 16, '2026-07-01 05:00:00', 4.85, 0.93, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4904, 16, '2026-07-01 06:00:00', 17.45, 0.79, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4905, 16, '2026-07-01 07:00:00', 12.42, 0.95, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4906, 16, '2026-07-01 08:00:00', 7.93, 1.12, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4907, 16, '2026-07-01 09:00:00', 8.98, 1.07, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4908, 16, '2026-07-01 10:00:00', 4.86, 0.37, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4909, 16, '2026-07-01 11:00:00', 11.54, 0.74, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4910, 16, '2026-07-01 12:00:00', 5.27, 1.26, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4911, 16, '2026-07-01 13:00:00', 7.36, 1.64, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4912, 16, '2026-07-01 14:00:00', 1.99, 0.39, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4913, 16, '2026-07-01 15:00:00', 6.43, 0.40, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4914, 16, '2026-07-01 16:00:00', 4.63, 1.18, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4915, 16, '2026-07-01 17:00:00', 15.65, 1.27, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4916, 16, '2026-07-01 18:00:00', 22.27, 1.96, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4917, 16, '2026-07-01 19:00:00', 14.69, 3.20, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4918, 16, '2026-07-01 20:00:00', 17.27, 3.03, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4919, 16, '2026-07-01 21:00:00', 5.75, 0.35, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4920, 16, '2026-07-01 22:00:00', 0.37, 0.23, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4921, 16, '2026-07-01 23:00:00', 1.08, 0.26, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4922, 16, '2026-07-02 00:00:00', 0.49, 0.31, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4923, 16, '2026-07-02 01:00:00', 1.70, 0.40, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4924, 16, '2026-07-02 02:00:00', 1.44, 0.35, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4925, 16, '2026-07-02 03:00:00', 0.75, 0.44, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4926, 16, '2026-07-02 04:00:00', 0.64, 0.26, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4927, 16, '2026-07-02 05:00:00', 5.13, 1.16, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4928, 16, '2026-07-02 06:00:00', 15.42, 2.41, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4929, 16, '2026-07-02 07:00:00', 10.09, 1.78, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4930, 16, '2026-07-02 08:00:00', 8.51, 1.95, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4931, 16, '2026-07-02 09:00:00', 13.18, 1.08, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4932, 16, '2026-07-02 10:00:00', 3.02, 1.17, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4933, 16, '2026-07-02 11:00:00', 7.53, 0.99, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4934, 16, '2026-07-02 12:00:00', 9.33, 1.27, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4935, 16, '2026-07-02 13:00:00', 8.80, 1.90, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4936, 16, '2026-07-02 14:00:00', 5.89, 0.65, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4937, 16, '2026-07-02 15:00:00', 4.80, 0.52, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4938, 16, '2026-07-02 16:00:00', 2.99, 0.34, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4939, 16, '2026-07-02 17:00:00', 18.34, 2.66, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4940, 16, '2026-07-02 18:00:00', 12.90, 1.54, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4941, 16, '2026-07-02 19:00:00', 11.70, 2.29, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4942, 16, '2026-07-02 20:00:00', 15.58, 1.50, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4943, 16, '2026-07-02 21:00:00', 5.62, 0.74, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4944, 16, '2026-07-02 22:00:00', 0.45, 0.39, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4945, 16, '2026-07-02 23:00:00', 1.37, 0.32, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4946, 16, '2026-07-03 00:00:00', 1.72, 0.37, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4947, 16, '2026-07-03 01:00:00', 1.61, 0.38, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4948, 16, '2026-07-03 02:00:00', 0.86, 0.16, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4949, 16, '2026-07-03 03:00:00', 1.10, 0.30, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4950, 16, '2026-07-03 04:00:00', 0.74, 0.36, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4951, 16, '2026-07-03 05:00:00', 4.84, 0.27, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4952, 16, '2026-07-03 06:00:00', 18.21, 1.52, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4953, 16, '2026-07-03 07:00:00', 15.62, 1.99, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4954, 16, '2026-07-03 08:00:00', 17.45, 1.94, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4955, 16, '2026-07-03 09:00:00', 15.63, 1.69, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4956, 16, '2026-07-03 10:00:00', 4.94, 0.64, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4957, 16, '2026-07-03 11:00:00', 7.27, 0.80, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4958, 16, '2026-07-03 12:00:00', 12.17, 1.09, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4959, 16, '2026-07-03 13:00:00', 6.87, 1.17, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4960, 16, '2026-07-03 14:00:00', 3.25, 0.98, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4961, 16, '2026-07-03 15:00:00', 5.48, 0.34, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4962, 16, '2026-07-03 16:00:00', 3.00, 0.79, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4963, 16, '2026-07-03 17:00:00', 10.03, 2.51, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4964, 16, '2026-07-03 18:00:00', 20.09, 2.36, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4965, 16, '2026-07-03 19:00:00', 20.69, 2.69, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4966, 16, '2026-07-03 20:00:00', 9.75, 3.02, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4967, 16, '2026-07-03 21:00:00', 3.92, 0.30, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4968, 16, '2026-07-03 22:00:00', 0.23, 0.25, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4969, 16, '2026-07-03 23:00:00', 0.89, 0.24, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4970, 16, '2026-07-04 00:00:00', 0.29, 0.23, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4971, 16, '2026-07-04 01:00:00', 1.00, 0.44, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4972, 16, '2026-07-04 02:00:00', 0.91, 0.27, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4973, 16, '2026-07-04 03:00:00', 0.15, 0.13, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4974, 16, '2026-07-04 04:00:00', 1.04, 0.36, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4975, 16, '2026-07-04 05:00:00', 1.97, 1.10, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4976, 16, '2026-07-04 06:00:00', 11.66, 2.14, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4977, 16, '2026-07-04 07:00:00', 9.02, 0.63, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4978, 16, '2026-07-04 08:00:00', 14.68, 2.18, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4979, 16, '2026-07-04 09:00:00', 15.55, 0.83, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4980, 16, '2026-07-04 10:00:00', 5.82, 1.08, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4981, 16, '2026-07-04 11:00:00', 6.86, 0.78, 'simulated', '2026-07-04 11:06:02');
INSERT INTO `el_utility_data` VALUES (4982, 17, '2026-06-27 11:00:00', 8.86, 2.10, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (4983, 17, '2026-06-27 12:00:00', 17.36, 2.35, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (4984, 17, '2026-06-27 13:00:00', 16.34, 1.99, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (4985, 17, '2026-06-27 14:00:00', 5.47, 0.58, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (4986, 17, '2026-06-27 15:00:00', 3.29, 1.00, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (4987, 17, '2026-06-27 16:00:00', 8.38, 1.19, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (4988, 17, '2026-06-27 17:00:00', 29.66, 1.51, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (4989, 17, '2026-06-27 18:00:00', 12.76, 1.43, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (4990, 17, '2026-06-27 19:00:00', 19.84, 3.39, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (4991, 17, '2026-06-27 20:00:00', 26.05, 2.74, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (4992, 17, '2026-06-27 21:00:00', 7.98, 0.87, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (4993, 17, '2026-06-27 22:00:00', 2.34, 0.32, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (4994, 17, '2026-06-27 23:00:00', 0.74, 0.33, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (4995, 17, '2026-06-28 00:00:00', 2.03, 0.39, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (4996, 17, '2026-06-28 01:00:00', 2.08, 0.45, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (4997, 17, '2026-06-28 02:00:00', 1.04, 0.58, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (4998, 17, '2026-06-28 03:00:00', 1.80, 0.55, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (4999, 17, '2026-06-28 04:00:00', 0.95, 0.55, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (5000, 17, '2026-06-28 05:00:00', 3.33, 1.17, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (5001, 17, '2026-06-28 06:00:00', 16.56, 2.89, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (5002, 17, '2026-06-28 07:00:00', 19.76, 1.92, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (5003, 17, '2026-06-28 08:00:00', 17.68, 1.80, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (5004, 17, '2026-06-28 09:00:00', 10.09, 2.32, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (5005, 17, '2026-06-28 10:00:00', 2.67, 1.32, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (5006, 17, '2026-06-28 11:00:00', 17.48, 1.81, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (5007, 17, '2026-06-28 12:00:00', 14.73, 1.90, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (5008, 17, '2026-06-28 13:00:00', 17.74, 1.72, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (5009, 17, '2026-06-28 14:00:00', 5.64, 1.50, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (5010, 17, '2026-06-28 15:00:00', 6.78, 0.83, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (5011, 17, '2026-06-28 16:00:00', 5.29, 1.33, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (5012, 17, '2026-06-28 17:00:00', 27.03, 3.63, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (5013, 17, '2026-06-28 18:00:00', 13.21, 2.77, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (5014, 17, '2026-06-28 19:00:00', 15.64, 3.90, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (5015, 17, '2026-06-28 20:00:00', 28.92, 2.42, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (5016, 17, '2026-06-28 21:00:00', 2.89, 0.32, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (5017, 17, '2026-06-28 22:00:00', 2.17, 0.58, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (5018, 17, '2026-06-28 23:00:00', 0.99, 0.24, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (5019, 17, '2026-06-29 00:00:00', 1.23, 0.45, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (5020, 17, '2026-06-29 01:00:00', 1.94, 0.32, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (5021, 17, '2026-06-29 02:00:00', 1.40, 0.30, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (5022, 17, '2026-06-29 03:00:00', 0.69, 0.48, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (5023, 17, '2026-06-29 04:00:00', 0.88, 0.52, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (5024, 17, '2026-06-29 05:00:00', 4.08, 1.24, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (5025, 17, '2026-06-29 06:00:00', 22.56, 0.92, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (5026, 17, '2026-06-29 07:00:00', 20.30, 2.96, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (5027, 17, '2026-06-29 08:00:00', 11.50, 1.14, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (5028, 17, '2026-06-29 09:00:00', 11.94, 1.56, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (5029, 17, '2026-06-29 10:00:00', 5.54, 1.05, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (5030, 17, '2026-06-29 11:00:00', 7.61, 2.41, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (5031, 17, '2026-06-29 12:00:00', 14.08, 2.15, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (5032, 17, '2026-06-29 13:00:00', 15.06, 1.06, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (5033, 17, '2026-06-29 14:00:00', 3.21, 1.16, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (5034, 17, '2026-06-29 15:00:00', 4.98, 1.33, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (5035, 17, '2026-06-29 16:00:00', 7.68, 0.90, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (5036, 17, '2026-06-29 17:00:00', 27.47, 2.98, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (5037, 17, '2026-06-29 18:00:00', 16.31, 4.16, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (5038, 17, '2026-06-29 19:00:00', 29.23, 3.66, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (5039, 17, '2026-06-29 20:00:00', 27.05, 1.75, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (5040, 17, '2026-06-29 21:00:00', 2.94, 0.99, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (5041, 17, '2026-06-29 22:00:00', 0.16, 0.53, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (5042, 17, '2026-06-29 23:00:00', 1.40, 0.46, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (5043, 17, '2026-06-30 00:00:00', 2.10, 0.39, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (5044, 17, '2026-06-30 01:00:00', 1.79, 0.17, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (5045, 17, '2026-06-30 02:00:00', 0.52, 0.23, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (5046, 17, '2026-06-30 03:00:00', 1.48, 0.38, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (5047, 17, '2026-06-30 04:00:00', 0.73, 0.38, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (5048, 17, '2026-06-30 05:00:00', 6.09, 0.32, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (5049, 17, '2026-06-30 06:00:00', 23.57, 1.53, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (5050, 17, '2026-06-30 07:00:00', 22.05, 1.10, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (5051, 17, '2026-06-30 08:00:00', 21.35, 2.43, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (5052, 17, '2026-06-30 09:00:00', 13.15, 2.30, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (5053, 17, '2026-06-30 10:00:00', 4.88, 0.39, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (5054, 17, '2026-06-30 11:00:00', 13.67, 0.68, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (5055, 17, '2026-06-30 12:00:00', 17.37, 0.68, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (5056, 17, '2026-06-30 13:00:00', 13.18, 1.16, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (5057, 17, '2026-06-30 14:00:00', 7.10, 1.22, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (5058, 17, '2026-06-30 15:00:00', 5.74, 1.10, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (5059, 17, '2026-06-30 16:00:00', 8.37, 0.98, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (5060, 17, '2026-06-30 17:00:00', 14.45, 1.22, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (5061, 17, '2026-06-30 18:00:00', 25.03, 1.33, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (5062, 17, '2026-06-30 19:00:00', 20.92, 3.02, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (5063, 17, '2026-06-30 20:00:00', 17.23, 3.62, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (5064, 17, '2026-06-30 21:00:00', 6.69, 1.37, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (5065, 17, '2026-06-30 22:00:00', 0.76, 0.40, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (5066, 17, '2026-06-30 23:00:00', 0.21, 0.44, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (5067, 17, '2026-07-01 00:00:00', 1.95, 0.35, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (5068, 17, '2026-07-01 01:00:00', 2.09, 0.35, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (5069, 17, '2026-07-01 02:00:00', 0.19, 0.35, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (5070, 17, '2026-07-01 03:00:00', 1.19, 0.44, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (5071, 17, '2026-07-01 04:00:00', 1.04, 0.48, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (5072, 17, '2026-07-01 05:00:00', 4.55, 0.42, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (5073, 17, '2026-07-01 06:00:00', 14.61, 2.66, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (5074, 17, '2026-07-01 07:00:00', 16.57, 2.27, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (5075, 17, '2026-07-01 08:00:00', 14.01, 1.94, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (5076, 17, '2026-07-01 09:00:00', 23.94, 1.53, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (5077, 17, '2026-07-01 10:00:00', 6.38, 1.05, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (5078, 17, '2026-07-01 11:00:00', 17.07, 1.07, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (5079, 17, '2026-07-01 12:00:00', 9.23, 2.10, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (5080, 17, '2026-07-01 13:00:00', 9.12, 1.62, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (5081, 17, '2026-07-01 14:00:00', 3.08, 1.36, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (5082, 17, '2026-07-01 15:00:00', 4.16, 0.31, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (5083, 17, '2026-07-01 16:00:00', 3.38, 0.34, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (5084, 17, '2026-07-01 17:00:00', 13.78, 3.64, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (5085, 17, '2026-07-01 18:00:00', 25.88, 1.35, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (5086, 17, '2026-07-01 19:00:00', 27.11, 3.99, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (5087, 17, '2026-07-01 20:00:00', 20.44, 1.84, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (5088, 17, '2026-07-01 21:00:00', 7.98, 0.49, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (5089, 17, '2026-07-01 22:00:00', 1.56, 0.51, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (5090, 17, '2026-07-01 23:00:00', 0.97, 0.54, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (5091, 17, '2026-07-02 00:00:00', 1.81, 0.29, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (5092, 17, '2026-07-02 01:00:00', 2.03, 0.20, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (5093, 17, '2026-07-02 02:00:00', 1.92, 0.51, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (5094, 17, '2026-07-02 03:00:00', 0.23, 0.35, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (5095, 17, '2026-07-02 04:00:00', 1.62, 0.58, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (5096, 17, '2026-07-02 05:00:00', 4.83, 0.77, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (5097, 17, '2026-07-02 06:00:00', 17.20, 1.10, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (5098, 17, '2026-07-02 07:00:00', 14.54, 0.81, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (5099, 17, '2026-07-02 08:00:00', 19.15, 1.85, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (5100, 17, '2026-07-02 09:00:00', 18.12, 2.94, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (5101, 17, '2026-07-02 10:00:00', 7.40, 0.55, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (5102, 17, '2026-07-02 11:00:00', 6.07, 1.61, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (5103, 17, '2026-07-02 12:00:00', 11.76, 2.42, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (5104, 17, '2026-07-02 13:00:00', 15.81, 1.26, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (5105, 17, '2026-07-02 14:00:00', 5.29, 1.22, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (5106, 17, '2026-07-02 15:00:00', 5.44, 0.95, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (5107, 17, '2026-07-02 16:00:00', 3.82, 1.32, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (5108, 17, '2026-07-02 17:00:00', 12.53, 2.50, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (5109, 17, '2026-07-02 18:00:00', 19.53, 1.41, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (5110, 17, '2026-07-02 19:00:00', 16.70, 2.68, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (5111, 17, '2026-07-02 20:00:00', 23.79, 3.66, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (5112, 17, '2026-07-02 21:00:00', 4.13, 0.33, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (5113, 17, '2026-07-02 22:00:00', 0.92, 0.27, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (5114, 17, '2026-07-02 23:00:00', 1.97, 0.33, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (5115, 17, '2026-07-03 00:00:00', 1.43, 0.54, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (5116, 17, '2026-07-03 01:00:00', 1.03, 0.40, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (5117, 17, '2026-07-03 02:00:00', 2.17, 0.49, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (5118, 17, '2026-07-03 03:00:00', 1.16, 0.25, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (5119, 17, '2026-07-03 04:00:00', 0.31, 0.21, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (5120, 17, '2026-07-03 05:00:00', 6.12, 0.46, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (5121, 17, '2026-07-03 06:00:00', 11.19, 0.88, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (5122, 17, '2026-07-03 07:00:00', 14.62, 1.60, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (5123, 17, '2026-07-03 08:00:00', 19.80, 2.47, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (5124, 17, '2026-07-03 09:00:00', 23.12, 2.67, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (5125, 17, '2026-07-03 10:00:00', 8.11, 1.50, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (5126, 17, '2026-07-03 11:00:00', 6.04, 2.06, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (5127, 17, '2026-07-03 12:00:00', 8.62, 1.40, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (5128, 17, '2026-07-03 13:00:00', 9.87, 1.36, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (5129, 17, '2026-07-03 14:00:00', 7.32, 0.31, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (5130, 17, '2026-07-03 15:00:00', 4.53, 0.33, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (5131, 17, '2026-07-03 16:00:00', 7.92, 0.32, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (5132, 17, '2026-07-03 17:00:00', 20.06, 1.87, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (5133, 17, '2026-07-03 18:00:00', 23.95, 2.99, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (5134, 17, '2026-07-03 19:00:00', 17.61, 2.09, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (5135, 17, '2026-07-03 20:00:00', 23.05, 2.81, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (5136, 17, '2026-07-03 21:00:00', 5.09, 0.89, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (5137, 17, '2026-07-03 22:00:00', 0.14, 0.31, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (5138, 17, '2026-07-03 23:00:00', 0.68, 0.45, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (5139, 17, '2026-07-04 00:00:00', 1.23, 0.24, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (5140, 17, '2026-07-04 01:00:00', 1.23, 0.16, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (5141, 17, '2026-07-04 02:00:00', 2.00, 0.50, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (5142, 17, '2026-07-04 03:00:00', 1.73, 0.50, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (5143, 17, '2026-07-04 04:00:00', 1.51, 0.50, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (5144, 17, '2026-07-04 05:00:00', 6.82, 1.47, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (5145, 17, '2026-07-04 06:00:00', 13.37, 1.87, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (5146, 17, '2026-07-04 07:00:00', 12.44, 1.98, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (5147, 17, '2026-07-04 08:00:00', 20.34, 2.40, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (5148, 17, '2026-07-04 09:00:00', 21.83, 1.55, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (5149, 17, '2026-07-04 10:00:00', 7.40, 0.90, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (5150, 17, '2026-07-04 11:00:00', 14.38, 2.37, 'simulated', '2026-07-04 11:06:04');
INSERT INTO `el_utility_data` VALUES (5151, 18, '2026-06-27 11:00:00', 9.22, 0.67, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5152, 18, '2026-06-27 12:00:00', 9.17, 0.47, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5153, 18, '2026-06-27 13:00:00', 12.22, 0.43, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5154, 18, '2026-06-27 14:00:00', 8.96, 0.38, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5155, 18, '2026-06-27 15:00:00', 3.00, 0.25, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5156, 18, '2026-06-27 16:00:00', 8.04, 0.20, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5157, 18, '2026-06-27 17:00:00', 32.15, 1.25, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5158, 18, '2026-06-27 18:00:00', 34.45, 1.24, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5159, 18, '2026-06-27 19:00:00', 20.10, 0.54, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5160, 18, '2026-06-27 20:00:00', 27.72, 0.96, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5161, 18, '2026-06-27 21:00:00', 4.70, 0.30, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5162, 18, '2026-06-27 22:00:00', 0.17, 0.11, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5163, 18, '2026-06-27 23:00:00', 2.68, 0.07, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5164, 18, '2026-06-28 00:00:00', 1.17, 0.06, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5165, 18, '2026-06-28 01:00:00', 0.84, 0.17, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5166, 18, '2026-06-28 02:00:00', 1.35, 0.05, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5167, 18, '2026-06-28 03:00:00', 0.86, 0.16, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5168, 18, '2026-06-28 04:00:00', 0.33, 0.14, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5169, 18, '2026-06-28 05:00:00', 8.32, 0.36, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5170, 18, '2026-06-28 06:00:00', 15.71, 0.69, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5171, 18, '2026-06-28 07:00:00', 19.72, 0.60, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5172, 18, '2026-06-28 08:00:00', 20.66, 0.25, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5173, 18, '2026-06-28 09:00:00', 14.79, 0.88, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5174, 18, '2026-06-28 10:00:00', 9.38, 0.37, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5175, 18, '2026-06-28 11:00:00', 16.12, 0.65, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5176, 18, '2026-06-28 12:00:00', 10.53, 0.45, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5177, 18, '2026-06-28 13:00:00', 17.96, 0.49, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5178, 18, '2026-06-28 14:00:00', 3.58, 0.47, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5179, 18, '2026-06-28 15:00:00', 9.02, 0.46, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5180, 18, '2026-06-28 16:00:00', 7.03, 0.40, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5181, 18, '2026-06-28 17:00:00', 21.19, 0.95, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5182, 18, '2026-06-28 18:00:00', 22.33, 0.70, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5183, 18, '2026-06-28 19:00:00', 19.68, 0.37, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5184, 18, '2026-06-28 20:00:00', 20.47, 0.86, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5185, 18, '2026-06-28 21:00:00', 8.75, 0.46, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5186, 18, '2026-06-28 22:00:00', 1.17, 0.18, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5187, 18, '2026-06-28 23:00:00', 1.19, 0.11, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5188, 18, '2026-06-29 00:00:00', 1.76, 0.10, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5189, 18, '2026-06-29 01:00:00', 0.26, 0.09, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5190, 18, '2026-06-29 02:00:00', 1.38, 0.09, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5191, 18, '2026-06-29 03:00:00', 2.63, 0.05, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5192, 18, '2026-06-29 04:00:00', 1.71, 0.15, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5193, 18, '2026-06-29 05:00:00', 8.55, 0.37, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5194, 18, '2026-06-29 06:00:00', 23.56, 0.67, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5195, 18, '2026-06-29 07:00:00', 12.88, 0.67, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5196, 18, '2026-06-29 08:00:00', 15.31, 0.83, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5197, 18, '2026-06-29 09:00:00', 27.54, 0.58, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5198, 18, '2026-06-29 10:00:00', 4.14, 0.35, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5199, 18, '2026-06-29 11:00:00', 13.14, 0.56, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5200, 18, '2026-06-29 12:00:00', 21.30, 0.26, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5201, 18, '2026-06-29 13:00:00', 13.11, 0.50, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5202, 18, '2026-06-29 14:00:00', 9.19, 0.22, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5203, 18, '2026-06-29 15:00:00', 5.32, 0.31, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5204, 18, '2026-06-29 16:00:00', 3.03, 0.23, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5205, 18, '2026-06-29 17:00:00', 29.29, 1.06, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5206, 18, '2026-06-29 18:00:00', 31.62, 0.45, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5207, 18, '2026-06-29 19:00:00', 14.82, 0.88, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5208, 18, '2026-06-29 20:00:00', 34.01, 0.95, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5209, 18, '2026-06-29 21:00:00', 7.71, 0.42, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5210, 18, '2026-06-29 22:00:00', 1.29, 0.09, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5211, 18, '2026-06-29 23:00:00', 1.94, 0.15, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5212, 18, '2026-06-30 00:00:00', 1.07, 0.10, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5213, 18, '2026-06-30 01:00:00', 1.35, 0.14, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5214, 18, '2026-06-30 02:00:00', 2.32, 0.08, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5215, 18, '2026-06-30 03:00:00', 1.13, 0.12, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5216, 18, '2026-06-30 04:00:00', 0.45, 0.07, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5217, 18, '2026-06-30 05:00:00', 3.96, 0.24, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5218, 18, '2026-06-30 06:00:00', 20.74, 0.38, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5219, 18, '2026-06-30 07:00:00', 22.19, 0.34, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5220, 18, '2026-06-30 08:00:00', 19.36, 0.61, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5221, 18, '2026-06-30 09:00:00', 18.42, 0.69, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5222, 18, '2026-06-30 10:00:00', 9.08, 0.26, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5223, 18, '2026-06-30 11:00:00', 14.04, 0.65, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5224, 18, '2026-06-30 12:00:00', 10.67, 0.38, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5225, 18, '2026-06-30 13:00:00', 9.00, 0.20, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5226, 18, '2026-06-30 14:00:00', 4.41, 0.37, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5227, 18, '2026-06-30 15:00:00', 2.98, 0.37, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5228, 18, '2026-06-30 16:00:00', 6.27, 0.19, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5229, 18, '2026-06-30 17:00:00', 21.97, 1.15, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5230, 18, '2026-06-30 18:00:00', 19.97, 0.99, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5231, 18, '2026-06-30 19:00:00', 31.83, 1.29, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5232, 18, '2026-06-30 20:00:00', 34.15, 0.45, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5233, 18, '2026-06-30 21:00:00', 7.45, 0.39, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5234, 18, '2026-06-30 22:00:00', 0.21, 0.06, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5235, 18, '2026-06-30 23:00:00', 0.55, 0.08, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5236, 18, '2026-07-01 00:00:00', 1.38, 0.13, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5237, 18, '2026-07-01 01:00:00', 0.43, 0.09, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5238, 18, '2026-07-01 02:00:00', 2.45, 0.07, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5239, 18, '2026-07-01 03:00:00', 2.68, 0.07, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5240, 18, '2026-07-01 04:00:00', 2.12, 0.16, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5241, 18, '2026-07-01 05:00:00', 4.58, 0.13, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5242, 18, '2026-07-01 06:00:00', 28.11, 0.40, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5243, 18, '2026-07-01 07:00:00', 14.08, 0.87, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5244, 18, '2026-07-01 08:00:00', 14.37, 0.27, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5245, 18, '2026-07-01 09:00:00', 21.80, 0.33, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5246, 18, '2026-07-01 10:00:00', 6.09, 0.14, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5247, 18, '2026-07-01 11:00:00', 11.26, 0.43, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5248, 18, '2026-07-01 12:00:00', 20.63, 0.24, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5249, 18, '2026-07-01 13:00:00', 20.76, 0.61, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5250, 18, '2026-07-01 14:00:00', 7.22, 0.35, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5251, 18, '2026-07-01 15:00:00', 7.22, 0.17, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5252, 18, '2026-07-01 16:00:00', 4.01, 0.36, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5253, 18, '2026-07-01 17:00:00', 28.80, 0.62, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5254, 18, '2026-07-01 18:00:00', 24.49, 1.19, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5255, 18, '2026-07-01 19:00:00', 35.13, 1.03, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5256, 18, '2026-07-01 20:00:00', 31.50, 0.65, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5257, 18, '2026-07-01 21:00:00', 6.89, 0.34, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5258, 18, '2026-07-01 22:00:00', 2.89, 0.12, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5259, 18, '2026-07-01 23:00:00', 0.83, 0.17, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5260, 18, '2026-07-02 00:00:00', 1.50, 0.05, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5261, 18, '2026-07-02 01:00:00', 2.59, 0.08, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5262, 18, '2026-07-02 02:00:00', 0.67, 0.14, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5263, 18, '2026-07-02 03:00:00', 0.02, 0.08, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5264, 18, '2026-07-02 04:00:00', 1.92, 0.17, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5265, 18, '2026-07-02 05:00:00', 5.93, 0.17, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5266, 18, '2026-07-02 06:00:00', 17.48, 0.83, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5267, 18, '2026-07-02 07:00:00', 28.94, 0.29, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5268, 18, '2026-07-02 08:00:00', 23.34, 0.41, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5269, 18, '2026-07-02 09:00:00', 27.64, 0.33, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5270, 18, '2026-07-02 10:00:00', 6.90, 0.19, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5271, 18, '2026-07-02 11:00:00', 20.90, 0.61, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5272, 18, '2026-07-02 12:00:00', 16.55, 0.57, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5273, 18, '2026-07-02 13:00:00', 14.61, 0.73, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5274, 18, '2026-07-02 14:00:00', 7.12, 0.12, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5275, 18, '2026-07-02 15:00:00', 7.98, 0.20, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5276, 18, '2026-07-02 16:00:00', 5.69, 0.27, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5277, 18, '2026-07-02 17:00:00', 33.05, 1.10, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5278, 18, '2026-07-02 18:00:00', 30.81, 0.86, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5279, 18, '2026-07-02 19:00:00', 20.02, 1.02, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5280, 18, '2026-07-02 20:00:00', 24.19, 0.42, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5281, 18, '2026-07-02 21:00:00', 8.49, 0.36, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5282, 18, '2026-07-02 22:00:00', 2.58, 0.06, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5283, 18, '2026-07-02 23:00:00', 1.96, 0.14, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5284, 18, '2026-07-03 00:00:00', 1.13, 0.18, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5285, 18, '2026-07-03 01:00:00', 0.44, 0.13, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5286, 18, '2026-07-03 02:00:00', 0.25, 0.05, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5287, 18, '2026-07-03 03:00:00', 1.27, 0.12, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5288, 18, '2026-07-03 04:00:00', 0.79, 0.14, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5289, 18, '2026-07-03 05:00:00', 3.34, 0.17, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5290, 18, '2026-07-03 06:00:00', 20.27, 0.62, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5291, 18, '2026-07-03 07:00:00', 23.07, 0.71, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5292, 18, '2026-07-03 08:00:00', 28.79, 0.61, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5293, 18, '2026-07-03 09:00:00', 17.29, 0.72, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5294, 18, '2026-07-03 10:00:00', 8.91, 0.18, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5295, 18, '2026-07-03 11:00:00', 9.83, 0.24, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5296, 18, '2026-07-03 12:00:00', 20.08, 0.35, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5297, 18, '2026-07-03 13:00:00', 10.25, 0.44, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5298, 18, '2026-07-03 14:00:00', 6.51, 0.43, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5299, 18, '2026-07-03 15:00:00', 8.52, 0.12, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5300, 18, '2026-07-03 16:00:00', 3.90, 0.13, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5301, 18, '2026-07-03 17:00:00', 33.54, 0.78, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5302, 18, '2026-07-03 18:00:00', 21.14, 0.82, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5303, 18, '2026-07-03 19:00:00', 27.59, 1.21, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5304, 18, '2026-07-03 20:00:00', 23.35, 0.73, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5305, 18, '2026-07-03 21:00:00', 7.34, 0.09, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5306, 18, '2026-07-03 22:00:00', 0.21, 0.13, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5307, 18, '2026-07-03 23:00:00', 2.34, 0.16, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5308, 18, '2026-07-04 00:00:00', 2.37, 0.05, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5309, 18, '2026-07-04 01:00:00', 0.70, 0.09, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5310, 18, '2026-07-04 02:00:00', 2.63, 0.11, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5311, 18, '2026-07-04 03:00:00', 0.13, 0.11, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5312, 18, '2026-07-04 04:00:00', 1.74, 0.11, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5313, 18, '2026-07-04 05:00:00', 3.30, 0.20, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5314, 18, '2026-07-04 06:00:00', 23.24, 0.25, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5315, 18, '2026-07-04 07:00:00', 13.25, 0.73, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5316, 18, '2026-07-04 08:00:00', 23.03, 0.91, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5317, 18, '2026-07-04 09:00:00', 13.87, 0.43, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5318, 18, '2026-07-04 10:00:00', 3.36, 0.45, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5319, 18, '2026-07-04 11:00:00', 19.96, 0.54, 'simulated', '2026-07-04 11:06:07');
INSERT INTO `el_utility_data` VALUES (5320, 19, '2026-06-27 11:00:00', 15.89, 0.46, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5321, 19, '2026-06-27 12:00:00', 19.10, 0.69, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5322, 19, '2026-06-27 13:00:00', 23.91, 0.31, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5323, 19, '2026-06-27 14:00:00', 4.78, 0.33, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5324, 19, '2026-06-27 15:00:00', 11.95, 0.24, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5325, 19, '2026-06-27 16:00:00', 10.77, 0.43, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5326, 19, '2026-06-27 17:00:00', 36.86, 1.50, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5327, 19, '2026-06-27 18:00:00', 34.32, 0.86, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5328, 19, '2026-06-27 19:00:00', 24.80, 0.56, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5329, 19, '2026-06-27 20:00:00', 25.51, 1.71, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5330, 19, '2026-06-27 21:00:00', 3.66, 0.58, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5331, 19, '2026-06-27 22:00:00', 1.55, 0.25, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5332, 19, '2026-06-27 23:00:00', 0.63, 0.25, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5333, 19, '2026-06-28 00:00:00', 3.39, 0.14, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5334, 19, '2026-06-28 01:00:00', 2.31, 0.10, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5335, 19, '2026-06-28 02:00:00', 0.17, 0.21, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5336, 19, '2026-06-28 03:00:00', 3.13, 0.13, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5337, 19, '2026-06-28 04:00:00', 2.22, 0.13, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5338, 19, '2026-06-28 05:00:00', 7.84, 0.57, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5339, 19, '2026-06-28 06:00:00', 28.50, 1.15, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5340, 19, '2026-06-28 07:00:00', 33.23, 0.98, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5341, 19, '2026-06-28 08:00:00', 17.51, 0.65, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5342, 19, '2026-06-28 09:00:00', 27.46, 0.99, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5343, 19, '2026-06-28 10:00:00', 11.29, 0.43, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5344, 19, '2026-06-28 11:00:00', 8.85, 0.71, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5345, 19, '2026-06-28 12:00:00', 14.69, 0.74, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5346, 19, '2026-06-28 13:00:00', 26.15, 0.52, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5347, 19, '2026-06-28 14:00:00', 10.61, 0.61, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5348, 19, '2026-06-28 15:00:00', 11.66, 0.47, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5349, 19, '2026-06-28 16:00:00', 3.91, 0.36, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5350, 19, '2026-06-28 17:00:00', 33.83, 1.62, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5351, 19, '2026-06-28 18:00:00', 19.87, 1.88, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5352, 19, '2026-06-28 19:00:00', 36.46, 1.09, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5353, 19, '2026-06-28 20:00:00', 39.18, 1.18, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5354, 19, '2026-06-28 21:00:00', 3.69, 0.60, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5355, 19, '2026-06-28 22:00:00', 1.02, 0.19, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5356, 19, '2026-06-28 23:00:00', 2.58, 0.25, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5357, 19, '2026-06-29 00:00:00', 2.83, 0.13, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5358, 19, '2026-06-29 01:00:00', 1.86, 0.19, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5359, 19, '2026-06-29 02:00:00', 1.09, 0.24, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5360, 19, '2026-06-29 03:00:00', 2.86, 0.10, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5361, 19, '2026-06-29 04:00:00', 2.48, 0.24, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5362, 19, '2026-06-29 05:00:00', 6.64, 0.29, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5363, 19, '2026-06-29 06:00:00', 19.08, 0.69, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5364, 19, '2026-06-29 07:00:00', 16.84, 0.52, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5365, 19, '2026-06-29 08:00:00', 20.38, 0.89, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5366, 19, '2026-06-29 09:00:00', 14.35, 0.46, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5367, 19, '2026-06-29 10:00:00', 8.42, 0.66, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5368, 19, '2026-06-29 11:00:00', 21.20, 0.43, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5369, 19, '2026-06-29 12:00:00', 18.77, 0.61, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5370, 19, '2026-06-29 13:00:00', 11.79, 0.38, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5371, 19, '2026-06-29 14:00:00', 9.77, 0.49, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5372, 19, '2026-06-29 15:00:00', 9.08, 0.60, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5373, 19, '2026-06-29 16:00:00', 8.21, 0.15, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5374, 19, '2026-06-29 17:00:00', 20.80, 0.75, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5375, 19, '2026-06-29 18:00:00', 27.00, 0.88, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5376, 19, '2026-06-29 19:00:00', 29.40, 0.97, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5377, 19, '2026-06-29 20:00:00', 26.07, 1.62, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5378, 19, '2026-06-29 21:00:00', 7.36, 0.20, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5379, 19, '2026-06-29 22:00:00', 3.09, 0.23, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5380, 19, '2026-06-29 23:00:00', 0.83, 0.10, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5381, 19, '2026-06-30 00:00:00', 0.30, 0.25, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5382, 19, '2026-06-30 01:00:00', 1.80, 0.24, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5383, 19, '2026-06-30 02:00:00', 3.45, 0.27, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5384, 19, '2026-06-30 03:00:00', 1.33, 0.15, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5385, 19, '2026-06-30 04:00:00', 2.71, 0.15, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5386, 19, '2026-06-30 05:00:00', 3.75, 0.47, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5387, 19, '2026-06-30 06:00:00', 22.99, 0.64, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5388, 19, '2026-06-30 07:00:00', 14.95, 1.22, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5389, 19, '2026-06-30 08:00:00', 33.18, 0.92, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5390, 19, '2026-06-30 09:00:00', 26.57, 0.57, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5391, 19, '2026-06-30 10:00:00', 5.25, 0.64, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5392, 19, '2026-06-30 11:00:00', 23.48, 0.68, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5393, 19, '2026-06-30 12:00:00', 23.27, 0.97, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5394, 19, '2026-06-30 13:00:00', 9.50, 0.68, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5395, 19, '2026-06-30 14:00:00', 10.12, 0.23, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5396, 19, '2026-06-30 15:00:00', 5.31, 0.54, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5397, 19, '2026-06-30 16:00:00', 4.09, 0.28, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5398, 19, '2026-06-30 17:00:00', 21.82, 1.04, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5399, 19, '2026-06-30 18:00:00', 18.63, 0.83, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5400, 19, '2026-06-30 19:00:00', 30.51, 1.53, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5401, 19, '2026-06-30 20:00:00', 40.22, 1.59, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5402, 19, '2026-06-30 21:00:00', 11.06, 0.60, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5403, 19, '2026-06-30 22:00:00', 1.69, 0.19, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5404, 19, '2026-06-30 23:00:00', 2.65, 0.24, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5405, 19, '2026-07-01 00:00:00', 3.10, 0.22, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5406, 19, '2026-07-01 01:00:00', 3.49, 0.23, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5407, 19, '2026-07-01 02:00:00', 0.51, 0.17, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5408, 19, '2026-07-01 03:00:00', 2.68, 0.12, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5409, 19, '2026-07-01 04:00:00', 2.67, 0.13, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5410, 19, '2026-07-01 05:00:00', 7.16, 0.16, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5411, 19, '2026-07-01 06:00:00', 29.24, 0.80, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5412, 19, '2026-07-01 07:00:00', 29.81, 1.00, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5413, 19, '2026-07-01 08:00:00', 34.52, 0.74, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5414, 19, '2026-07-01 09:00:00', 33.55, 0.79, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5415, 19, '2026-07-01 10:00:00', 4.35, 0.59, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5416, 19, '2026-07-01 11:00:00', 23.51, 0.43, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5417, 19, '2026-07-01 12:00:00', 10.66, 0.47, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5418, 19, '2026-07-01 13:00:00', 12.21, 0.91, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5419, 19, '2026-07-01 14:00:00', 8.92, 0.50, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5420, 19, '2026-07-01 15:00:00', 5.92, 0.46, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5421, 19, '2026-07-01 16:00:00', 9.69, 0.47, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5422, 19, '2026-07-01 17:00:00', 40.96, 1.55, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5423, 19, '2026-07-01 18:00:00', 25.83, 1.23, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5424, 19, '2026-07-01 19:00:00', 38.47, 1.46, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5425, 19, '2026-07-01 20:00:00', 18.31, 1.36, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5426, 19, '2026-07-01 21:00:00', 7.52, 0.31, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5427, 19, '2026-07-01 22:00:00', 2.50, 0.26, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5428, 19, '2026-07-01 23:00:00', 2.86, 0.25, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5429, 19, '2026-07-02 00:00:00', 2.05, 0.18, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5430, 19, '2026-07-02 01:00:00', 1.53, 0.13, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5431, 19, '2026-07-02 02:00:00', 3.46, 0.24, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5432, 19, '2026-07-02 03:00:00', 1.05, 0.20, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5433, 19, '2026-07-02 04:00:00', 0.73, 0.23, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5434, 19, '2026-07-02 05:00:00', 4.96, 0.59, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5435, 19, '2026-07-02 06:00:00', 26.04, 0.88, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5436, 19, '2026-07-02 07:00:00', 23.14, 0.76, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5437, 19, '2026-07-02 08:00:00', 14.40, 0.49, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5438, 19, '2026-07-02 09:00:00', 19.03, 1.29, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5439, 19, '2026-07-02 10:00:00', 8.06, 0.17, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5440, 19, '2026-07-02 11:00:00', 16.64, 1.09, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5441, 19, '2026-07-02 12:00:00', 18.76, 0.52, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5442, 19, '2026-07-02 13:00:00', 11.67, 1.04, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5443, 19, '2026-07-02 14:00:00', 5.14, 0.29, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5444, 19, '2026-07-02 15:00:00', 6.39, 0.27, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5445, 19, '2026-07-02 16:00:00', 3.57, 0.39, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5446, 19, '2026-07-02 17:00:00', 18.21, 1.73, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5447, 19, '2026-07-02 18:00:00', 18.67, 1.70, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5448, 19, '2026-07-02 19:00:00', 21.31, 1.16, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5449, 19, '2026-07-02 20:00:00', 19.75, 0.92, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5450, 19, '2026-07-02 21:00:00', 4.07, 0.24, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5451, 19, '2026-07-02 22:00:00', 2.45, 0.26, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5452, 19, '2026-07-02 23:00:00', 0.83, 0.26, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5453, 19, '2026-07-03 00:00:00', 0.88, 0.14, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5454, 19, '2026-07-03 01:00:00', 1.93, 0.20, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5455, 19, '2026-07-03 02:00:00', 1.53, 0.08, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5456, 19, '2026-07-03 03:00:00', 2.18, 0.18, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5457, 19, '2026-07-03 04:00:00', 1.02, 0.08, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5458, 19, '2026-07-03 05:00:00', 6.54, 0.69, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5459, 19, '2026-07-03 06:00:00', 32.12, 0.75, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5460, 19, '2026-07-03 07:00:00', 17.67, 0.79, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5461, 19, '2026-07-03 08:00:00', 17.27, 0.72, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5462, 19, '2026-07-03 09:00:00', 34.66, 0.48, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5463, 19, '2026-07-03 10:00:00', 6.95, 0.26, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5464, 19, '2026-07-03 11:00:00', 18.60, 0.81, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5465, 19, '2026-07-03 12:00:00', 25.26, 1.04, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5466, 19, '2026-07-03 13:00:00', 12.19, 0.56, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5467, 19, '2026-07-03 14:00:00', 10.65, 0.43, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5468, 19, '2026-07-03 15:00:00', 3.55, 0.21, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5469, 19, '2026-07-03 16:00:00', 5.63, 0.27, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5470, 19, '2026-07-03 17:00:00', 24.72, 0.70, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5471, 19, '2026-07-03 18:00:00', 17.98, 0.84, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5472, 19, '2026-07-03 19:00:00', 24.43, 1.79, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5473, 19, '2026-07-03 20:00:00', 25.00, 1.78, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5474, 19, '2026-07-03 21:00:00', 8.45, 0.62, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5475, 19, '2026-07-03 22:00:00', 2.32, 0.25, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5476, 19, '2026-07-03 23:00:00', 1.48, 0.10, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5477, 19, '2026-07-04 00:00:00', 1.75, 0.14, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5478, 19, '2026-07-04 01:00:00', 0.18, 0.08, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5479, 19, '2026-07-04 02:00:00', 1.65, 0.17, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5480, 19, '2026-07-04 03:00:00', 1.66, 0.10, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5481, 19, '2026-07-04 04:00:00', 2.05, 0.17, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5482, 19, '2026-07-04 05:00:00', 11.73, 0.65, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5483, 19, '2026-07-04 06:00:00', 19.96, 0.90, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5484, 19, '2026-07-04 07:00:00', 28.70, 1.19, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5485, 19, '2026-07-04 08:00:00', 16.31, 1.02, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5486, 19, '2026-07-04 09:00:00', 22.95, 0.86, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5487, 19, '2026-07-04 10:00:00', 4.66, 0.56, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5488, 19, '2026-07-04 11:00:00', 13.67, 0.42, 'simulated', '2026-07-04 11:06:09');
INSERT INTO `el_utility_data` VALUES (5489, 20, '2026-06-27 11:00:00', 9.42, 0.76, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5490, 20, '2026-06-27 12:00:00', 14.63, 0.71, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5491, 20, '2026-06-27 13:00:00', 12.19, 0.50, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5492, 20, '2026-06-27 14:00:00', 4.35, 0.28, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5493, 20, '2026-06-27 15:00:00', 4.66, 0.15, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5494, 20, '2026-06-27 16:00:00', 3.66, 0.16, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5495, 20, '2026-06-27 17:00:00', 25.31, 1.28, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5496, 20, '2026-06-27 18:00:00', 24.88, 1.19, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5497, 20, '2026-06-27 19:00:00', 27.16, 0.82, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5498, 20, '2026-06-27 20:00:00', 19.44, 1.40, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5499, 20, '2026-06-27 21:00:00', 2.57, 0.31, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5500, 20, '2026-06-27 22:00:00', 0.63, 0.16, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5501, 20, '2026-06-27 23:00:00', 1.27, 0.06, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5502, 20, '2026-06-28 00:00:00', 0.06, 0.17, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5503, 20, '2026-06-28 01:00:00', 1.44, 0.09, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5504, 20, '2026-06-28 02:00:00', 0.02, 0.11, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5505, 20, '2026-06-28 03:00:00', 1.72, 0.17, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5506, 20, '2026-06-28 04:00:00', 0.65, 0.19, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5507, 20, '2026-06-28 05:00:00', 2.73, 0.17, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5508, 20, '2026-06-28 06:00:00', 11.36, 0.88, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5509, 20, '2026-06-28 07:00:00', 20.01, 0.72, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5510, 20, '2026-06-28 08:00:00', 10.79, 0.95, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5511, 20, '2026-06-28 09:00:00', 20.64, 0.97, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5512, 20, '2026-06-28 10:00:00', 5.28, 0.37, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5513, 20, '2026-06-28 11:00:00', 7.09, 0.34, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5514, 20, '2026-06-28 12:00:00', 17.22, 0.32, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5515, 20, '2026-06-28 13:00:00', 9.63, 0.47, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5516, 20, '2026-06-28 14:00:00', 3.52, 0.40, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5517, 20, '2026-06-28 15:00:00', 7.32, 0.38, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5518, 20, '2026-06-28 16:00:00', 3.67, 0.18, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5519, 20, '2026-06-28 17:00:00', 21.88, 0.57, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5520, 20, '2026-06-28 18:00:00', 13.90, 0.79, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5521, 20, '2026-06-28 19:00:00', 13.55, 1.06, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5522, 20, '2026-06-28 20:00:00', 27.70, 1.32, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5523, 20, '2026-06-28 21:00:00', 3.39, 0.48, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5524, 20, '2026-06-28 22:00:00', 0.54, 0.10, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5525, 20, '2026-06-28 23:00:00', 1.86, 0.12, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5526, 20, '2026-06-29 00:00:00', 0.25, 0.08, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5527, 20, '2026-06-29 01:00:00', 0.69, 0.19, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5528, 20, '2026-06-29 02:00:00', 1.84, 0.06, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5529, 20, '2026-06-29 03:00:00', 0.75, 0.06, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5530, 20, '2026-06-29 04:00:00', 0.03, 0.05, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5531, 20, '2026-06-29 05:00:00', 4.75, 0.22, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5532, 20, '2026-06-29 06:00:00', 12.81, 0.37, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5533, 20, '2026-06-29 07:00:00', 9.81, 0.28, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5534, 20, '2026-06-29 08:00:00', 18.21, 0.67, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5535, 20, '2026-06-29 09:00:00', 17.84, 0.29, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5536, 20, '2026-06-29 10:00:00', 3.88, 0.28, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5537, 20, '2026-06-29 11:00:00', 9.58, 0.61, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5538, 20, '2026-06-29 12:00:00', 15.78, 0.24, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5539, 20, '2026-06-29 13:00:00', 11.93, 0.23, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5540, 20, '2026-06-29 14:00:00', 2.45, 0.27, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5541, 20, '2026-06-29 15:00:00', 7.69, 0.43, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5542, 20, '2026-06-29 16:00:00', 6.35, 0.52, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5543, 20, '2026-06-29 17:00:00', 21.57, 1.00, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5544, 20, '2026-06-29 18:00:00', 11.84, 1.21, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5545, 20, '2026-06-29 19:00:00', 23.02, 1.31, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5546, 20, '2026-06-29 20:00:00', 24.31, 0.65, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5547, 20, '2026-06-29 21:00:00', 2.37, 0.34, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5548, 20, '2026-06-29 22:00:00', 1.91, 0.06, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5549, 20, '2026-06-29 23:00:00', 1.83, 0.21, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5550, 20, '2026-06-30 00:00:00', 1.61, 0.07, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5551, 20, '2026-06-30 01:00:00', 1.73, 0.19, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5552, 20, '2026-06-30 02:00:00', 1.37, 0.06, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5553, 20, '2026-06-30 03:00:00', 1.45, 0.12, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5554, 20, '2026-06-30 04:00:00', 1.28, 0.21, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5555, 20, '2026-06-30 05:00:00', 3.28, 0.29, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5556, 20, '2026-06-30 06:00:00', 11.33, 0.49, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5557, 20, '2026-06-30 07:00:00', 10.87, 0.39, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5558, 20, '2026-06-30 08:00:00', 20.24, 0.88, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5559, 20, '2026-06-30 09:00:00', 13.14, 1.05, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5560, 20, '2026-06-30 10:00:00', 3.29, 0.21, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5561, 20, '2026-06-30 11:00:00', 11.79, 0.25, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5562, 20, '2026-06-30 12:00:00', 14.20, 0.45, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5563, 20, '2026-06-30 13:00:00', 16.95, 0.31, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5564, 20, '2026-06-30 14:00:00', 6.05, 0.27, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5565, 20, '2026-06-30 15:00:00', 4.83, 0.24, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5566, 20, '2026-06-30 16:00:00', 7.68, 0.24, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5567, 20, '2026-06-30 17:00:00', 14.85, 0.61, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5568, 20, '2026-06-30 18:00:00', 22.24, 0.48, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5569, 20, '2026-06-30 19:00:00', 24.54, 1.20, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5570, 20, '2026-06-30 20:00:00', 14.16, 0.87, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5571, 20, '2026-06-30 21:00:00', 4.51, 0.12, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5572, 20, '2026-06-30 22:00:00', 2.23, 0.16, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5573, 20, '2026-06-30 23:00:00', 0.71, 0.09, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5574, 20, '2026-07-01 00:00:00', 0.89, 0.12, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5575, 20, '2026-07-01 01:00:00', 0.92, 0.06, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5576, 20, '2026-07-01 02:00:00', 1.55, 0.18, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5577, 20, '2026-07-01 03:00:00', 0.78, 0.16, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5578, 20, '2026-07-01 04:00:00', 2.05, 0.13, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5579, 20, '2026-07-01 05:00:00', 6.73, 0.30, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5580, 20, '2026-07-01 06:00:00', 21.54, 0.80, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5581, 20, '2026-07-01 07:00:00', 22.71, 0.81, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5582, 20, '2026-07-01 08:00:00', 13.02, 1.01, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5583, 20, '2026-07-01 09:00:00', 10.19, 0.38, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5584, 20, '2026-07-01 10:00:00', 6.21, 0.21, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5585, 20, '2026-07-01 11:00:00', 9.71, 0.37, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5586, 20, '2026-07-01 12:00:00', 6.92, 0.54, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5587, 20, '2026-07-01 13:00:00', 14.46, 0.54, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5588, 20, '2026-07-01 14:00:00', 4.09, 0.15, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5589, 20, '2026-07-01 15:00:00', 3.12, 0.27, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5590, 20, '2026-07-01 16:00:00', 5.10, 0.15, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5591, 20, '2026-07-01 17:00:00', 23.33, 1.10, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5592, 20, '2026-07-01 18:00:00', 19.03, 1.34, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5593, 20, '2026-07-01 19:00:00', 22.46, 1.38, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5594, 20, '2026-07-01 20:00:00', 23.05, 1.10, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5595, 20, '2026-07-01 21:00:00', 3.28, 0.42, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5596, 20, '2026-07-01 22:00:00', 1.28, 0.12, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5597, 20, '2026-07-01 23:00:00', 0.98, 0.06, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5598, 20, '2026-07-02 00:00:00', 1.39, 0.18, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5599, 20, '2026-07-02 01:00:00', 0.94, 0.16, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5600, 20, '2026-07-02 02:00:00', 1.38, 0.14, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5601, 20, '2026-07-02 03:00:00', 1.39, 0.16, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5602, 20, '2026-07-02 04:00:00', 2.29, 0.09, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5603, 20, '2026-07-02 05:00:00', 4.97, 0.28, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5604, 20, '2026-07-02 06:00:00', 16.33, 0.98, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5605, 20, '2026-07-02 07:00:00', 22.02, 0.63, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5606, 20, '2026-07-02 08:00:00', 13.05, 0.60, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5607, 20, '2026-07-02 09:00:00', 12.58, 1.02, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5608, 20, '2026-07-02 10:00:00', 3.38, 0.41, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5609, 20, '2026-07-02 11:00:00', 8.71, 0.62, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5610, 20, '2026-07-02 12:00:00', 12.27, 0.41, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5611, 20, '2026-07-02 13:00:00', 7.64, 0.73, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5612, 20, '2026-07-02 14:00:00', 3.01, 0.33, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5613, 20, '2026-07-02 15:00:00', 4.82, 0.15, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5614, 20, '2026-07-02 16:00:00', 5.35, 0.33, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5615, 20, '2026-07-02 17:00:00', 18.27, 1.21, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5616, 20, '2026-07-02 18:00:00', 22.91, 0.86, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5617, 20, '2026-07-02 19:00:00', 14.77, 0.73, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5618, 20, '2026-07-02 20:00:00', 23.11, 1.40, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5619, 20, '2026-07-02 21:00:00', 7.21, 0.21, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5620, 20, '2026-07-02 22:00:00', 1.55, 0.09, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5621, 20, '2026-07-02 23:00:00', 1.94, 0.08, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5622, 20, '2026-07-03 00:00:00', 1.26, 0.08, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5623, 20, '2026-07-03 01:00:00', 1.03, 0.08, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5624, 20, '2026-07-03 02:00:00', 0.14, 0.11, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5625, 20, '2026-07-03 03:00:00', 2.21, 0.16, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5626, 20, '2026-07-03 04:00:00', 1.97, 0.11, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5627, 20, '2026-07-03 05:00:00', 3.13, 0.47, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5628, 20, '2026-07-03 06:00:00', 15.24, 1.01, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5629, 20, '2026-07-03 07:00:00', 10.65, 0.31, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5630, 20, '2026-07-03 08:00:00', 15.16, 0.95, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5631, 20, '2026-07-03 09:00:00', 20.84, 0.57, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5632, 20, '2026-07-03 10:00:00', 6.86, 0.51, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5633, 20, '2026-07-03 11:00:00', 10.04, 0.32, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5634, 20, '2026-07-03 12:00:00', 12.47, 0.52, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5635, 20, '2026-07-03 13:00:00', 8.32, 0.32, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5636, 20, '2026-07-03 14:00:00', 3.17, 0.23, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5637, 20, '2026-07-03 15:00:00', 4.77, 0.23, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5638, 20, '2026-07-03 16:00:00', 4.36, 0.43, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5639, 20, '2026-07-03 17:00:00', 11.96, 1.47, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5640, 20, '2026-07-03 18:00:00', 18.50, 1.20, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5641, 20, '2026-07-03 19:00:00', 13.90, 1.23, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5642, 20, '2026-07-03 20:00:00', 21.44, 1.38, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5643, 20, '2026-07-03 21:00:00', 4.31, 0.36, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5644, 20, '2026-07-03 22:00:00', 1.90, 0.16, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5645, 20, '2026-07-03 23:00:00', 0.16, 0.18, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5646, 20, '2026-07-04 00:00:00', 1.76, 0.19, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5647, 20, '2026-07-04 01:00:00', 2.27, 0.10, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5648, 20, '2026-07-04 02:00:00', 0.06, 0.08, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5649, 20, '2026-07-04 03:00:00', 1.01, 0.11, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5650, 20, '2026-07-04 04:00:00', 0.91, 0.10, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5651, 20, '2026-07-04 05:00:00', 7.61, 0.36, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5652, 20, '2026-07-04 06:00:00', 14.11, 0.44, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5653, 20, '2026-07-04 07:00:00', 13.02, 0.69, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5654, 20, '2026-07-04 08:00:00', 22.29, 0.68, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5655, 20, '2026-07-04 09:00:00', 15.44, 0.28, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5656, 20, '2026-07-04 10:00:00', 7.26, 0.50, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5657, 20, '2026-07-04 11:00:00', 15.93, 0.35, 'simulated', '2026-07-04 11:06:11');
INSERT INTO `el_utility_data` VALUES (5658, 22, '2026-06-27 11:00:00', 5.45, 0.66, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5659, 22, '2026-06-27 12:00:00', 8.00, 0.79, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5660, 22, '2026-06-27 13:00:00', 6.74, 1.40, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5661, 22, '2026-06-27 14:00:00', 2.48, 0.73, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5662, 22, '2026-06-27 15:00:00', 2.04, 0.78, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5663, 22, '2026-06-27 16:00:00', 3.13, 0.74, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5664, 22, '2026-06-27 17:00:00', 13.38, 1.88, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5665, 22, '2026-06-27 18:00:00', 7.01, 2.69, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5666, 22, '2026-06-27 19:00:00', 13.59, 2.41, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5667, 22, '2026-06-27 20:00:00', 5.90, 1.03, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5668, 22, '2026-06-27 21:00:00', 2.40, 0.95, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5669, 22, '2026-06-27 22:00:00', 0.60, 0.17, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5670, 22, '2026-06-27 23:00:00', 0.66, 0.19, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5671, 22, '2026-06-28 00:00:00', 0.32, 0.25, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5672, 22, '2026-06-28 01:00:00', 0.56, 0.24, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5673, 22, '2026-06-28 02:00:00', 0.78, 0.24, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5674, 22, '2026-06-28 03:00:00', 0.61, 0.32, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5675, 22, '2026-06-28 04:00:00', 0.18, 0.21, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5676, 22, '2026-06-28 05:00:00', 2.80, 0.78, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5677, 22, '2026-06-28 06:00:00', 7.78, 1.62, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5678, 22, '2026-06-28 07:00:00', 9.47, 1.31, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5679, 22, '2026-06-28 08:00:00', 10.46, 1.37, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5680, 22, '2026-06-28 09:00:00', 7.42, 0.89, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5681, 22, '2026-06-28 10:00:00', 1.18, 0.36, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5682, 22, '2026-06-28 11:00:00', 4.53, 1.03, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5683, 22, '2026-06-28 12:00:00', 3.10, 0.75, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5684, 22, '2026-06-28 13:00:00', 2.98, 1.22, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5685, 22, '2026-06-28 14:00:00', 1.66, 0.65, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5686, 22, '2026-06-28 15:00:00', 2.89, 0.68, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5687, 22, '2026-06-28 16:00:00', 3.56, 0.26, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5688, 22, '2026-06-28 17:00:00', 10.58, 1.46, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5689, 22, '2026-06-28 18:00:00', 7.42, 1.98, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5690, 22, '2026-06-28 19:00:00', 6.64, 2.54, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5691, 22, '2026-06-28 20:00:00', 6.83, 1.98, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5692, 22, '2026-06-28 21:00:00', 2.03, 0.49, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5693, 22, '2026-06-28 22:00:00', 0.91, 0.37, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5694, 22, '2026-06-28 23:00:00', 0.73, 0.22, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5695, 22, '2026-06-29 00:00:00', 0.59, 0.11, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5696, 22, '2026-06-29 01:00:00', 0.02, 0.11, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5697, 22, '2026-06-29 02:00:00', 0.46, 0.34, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5698, 22, '2026-06-29 03:00:00', 0.38, 0.18, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5699, 22, '2026-06-29 04:00:00', 0.75, 0.17, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5700, 22, '2026-06-29 05:00:00', 3.55, 0.88, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5701, 22, '2026-06-29 06:00:00', 5.11, 1.23, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5702, 22, '2026-06-29 07:00:00', 9.44, 1.71, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5703, 22, '2026-06-29 08:00:00', 6.52, 1.88, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5704, 22, '2026-06-29 09:00:00', 6.21, 1.28, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5705, 22, '2026-06-29 10:00:00', 3.56, 0.77, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5706, 22, '2026-06-29 11:00:00', 4.43, 0.82, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5707, 22, '2026-06-29 12:00:00', 4.41, 0.82, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5708, 22, '2026-06-29 13:00:00', 3.70, 1.47, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5709, 22, '2026-06-29 14:00:00', 2.17, 0.70, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5710, 22, '2026-06-29 15:00:00', 1.83, 0.33, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5711, 22, '2026-06-29 16:00:00', 3.16, 0.78, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5712, 22, '2026-06-29 17:00:00', 10.05, 2.02, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5713, 22, '2026-06-29 18:00:00', 13.41, 1.27, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5714, 22, '2026-06-29 19:00:00', 6.46, 1.04, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5715, 22, '2026-06-29 20:00:00', 11.98, 0.99, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5716, 22, '2026-06-29 21:00:00', 3.37, 0.93, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5717, 22, '2026-06-29 22:00:00', 0.49, 0.14, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5718, 22, '2026-06-29 23:00:00', 1.06, 0.19, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5719, 22, '2026-06-30 00:00:00', 0.41, 0.36, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5720, 22, '2026-06-30 01:00:00', 0.53, 0.34, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5721, 22, '2026-06-30 02:00:00', 0.36, 0.12, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5722, 22, '2026-06-30 03:00:00', 1.03, 0.32, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5723, 22, '2026-06-30 04:00:00', 0.16, 0.27, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5724, 22, '2026-06-30 05:00:00', 1.57, 0.79, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5725, 22, '2026-06-30 06:00:00', 6.61, 1.63, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5726, 22, '2026-06-30 07:00:00', 6.63, 0.60, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5727, 22, '2026-06-30 08:00:00', 8.16, 0.56, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5728, 22, '2026-06-30 09:00:00', 8.69, 0.89, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5729, 22, '2026-06-30 10:00:00', 3.76, 0.80, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5730, 22, '2026-06-30 11:00:00', 5.75, 0.42, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5731, 22, '2026-06-30 12:00:00', 6.26, 1.23, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5732, 22, '2026-06-30 13:00:00', 4.56, 0.92, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5733, 22, '2026-06-30 14:00:00', 3.69, 0.52, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5734, 22, '2026-06-30 15:00:00', 1.42, 0.46, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5735, 22, '2026-06-30 16:00:00', 3.00, 0.63, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5736, 22, '2026-06-30 17:00:00', 7.41, 0.83, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5737, 22, '2026-06-30 18:00:00', 5.62, 1.40, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5738, 22, '2026-06-30 19:00:00', 10.04, 2.14, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5739, 22, '2026-06-30 20:00:00', 9.92, 1.34, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5740, 22, '2026-06-30 21:00:00', 3.39, 0.67, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5741, 22, '2026-06-30 22:00:00', 0.61, 0.33, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5742, 22, '2026-06-30 23:00:00', 0.79, 0.17, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5743, 22, '2026-07-01 00:00:00', 0.81, 0.31, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5744, 22, '2026-07-01 01:00:00', 0.03, 0.14, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5745, 22, '2026-07-01 02:00:00', 0.76, 0.38, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5746, 22, '2026-07-01 03:00:00', 0.86, 0.20, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5747, 22, '2026-07-01 04:00:00', 0.64, 0.32, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5748, 22, '2026-07-01 05:00:00', 3.58, 0.88, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5749, 22, '2026-07-01 06:00:00', 4.85, 1.76, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5750, 22, '2026-07-01 07:00:00', 5.85, 0.83, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5751, 22, '2026-07-01 08:00:00', 7.05, 1.70, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5752, 22, '2026-07-01 09:00:00', 8.53, 0.70, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5753, 22, '2026-07-01 10:00:00', 2.16, 0.66, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5754, 22, '2026-07-01 11:00:00', 4.60, 0.47, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5755, 22, '2026-07-01 12:00:00', 3.23, 0.84, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5756, 22, '2026-07-01 13:00:00', 3.22, 1.51, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5757, 22, '2026-07-01 14:00:00', 2.18, 0.25, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5758, 22, '2026-07-01 15:00:00', 1.57, 0.36, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5759, 22, '2026-07-01 16:00:00', 3.51, 0.95, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5760, 22, '2026-07-01 17:00:00', 7.41, 1.17, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5761, 22, '2026-07-01 18:00:00', 13.32, 1.54, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5762, 22, '2026-07-01 19:00:00', 12.52, 2.40, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5763, 22, '2026-07-01 20:00:00', 5.86, 0.96, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5764, 22, '2026-07-01 21:00:00', 2.90, 0.75, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5765, 22, '2026-07-01 22:00:00', 0.39, 0.31, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5766, 22, '2026-07-01 23:00:00', 0.93, 0.23, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5767, 22, '2026-07-02 00:00:00', 0.88, 0.28, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5768, 22, '2026-07-02 01:00:00', 0.30, 0.33, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5769, 22, '2026-07-02 02:00:00', 1.01, 0.37, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5770, 22, '2026-07-02 03:00:00', 0.47, 0.26, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5771, 22, '2026-07-02 04:00:00', 0.70, 0.28, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5772, 22, '2026-07-02 05:00:00', 2.21, 0.86, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5773, 22, '2026-07-02 06:00:00', 9.28, 1.46, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5774, 22, '2026-07-02 07:00:00', 7.59, 1.57, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5775, 22, '2026-07-02 08:00:00', 4.39, 1.75, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5776, 22, '2026-07-02 09:00:00', 9.61, 0.65, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5777, 22, '2026-07-02 10:00:00', 1.14, 0.69, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5778, 22, '2026-07-02 11:00:00', 6.25, 1.38, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5779, 22, '2026-07-02 12:00:00', 7.14, 0.85, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5780, 22, '2026-07-02 13:00:00', 3.25, 1.26, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5781, 22, '2026-07-02 14:00:00', 1.31, 0.25, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5782, 22, '2026-07-02 15:00:00', 3.46, 0.31, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5783, 22, '2026-07-02 16:00:00', 2.39, 0.75, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5784, 22, '2026-07-02 17:00:00', 12.46, 2.34, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5785, 22, '2026-07-02 18:00:00', 10.59, 2.23, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5786, 22, '2026-07-02 19:00:00', 9.03, 1.76, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5787, 22, '2026-07-02 20:00:00', 7.49, 2.33, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5788, 22, '2026-07-02 21:00:00', 1.99, 0.78, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5789, 22, '2026-07-02 22:00:00', 0.31, 0.14, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5790, 22, '2026-07-02 23:00:00', 0.94, 0.11, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5791, 22, '2026-07-03 00:00:00', 0.11, 0.32, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5792, 22, '2026-07-03 01:00:00', 0.39, 0.27, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5793, 22, '2026-07-03 02:00:00', 0.63, 0.23, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5794, 22, '2026-07-03 03:00:00', 1.05, 0.30, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5795, 22, '2026-07-03 04:00:00', 0.50, 0.11, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5796, 22, '2026-07-03 05:00:00', 1.59, 0.73, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5797, 22, '2026-07-03 06:00:00', 5.57, 1.15, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5798, 22, '2026-07-03 07:00:00', 7.05, 1.71, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5799, 22, '2026-07-03 08:00:00', 8.09, 0.57, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5800, 22, '2026-07-03 09:00:00', 4.96, 0.67, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5801, 22, '2026-07-03 10:00:00', 3.20, 0.78, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5802, 22, '2026-07-03 11:00:00', 4.17, 1.39, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5803, 22, '2026-07-03 12:00:00', 3.95, 0.82, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5804, 22, '2026-07-03 13:00:00', 3.33, 1.34, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5805, 22, '2026-07-03 14:00:00', 3.75, 0.79, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5806, 22, '2026-07-03 15:00:00', 2.27, 0.96, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5807, 22, '2026-07-03 16:00:00', 1.39, 0.40, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5808, 22, '2026-07-03 17:00:00', 7.15, 2.42, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5809, 22, '2026-07-03 18:00:00', 7.10, 1.34, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5810, 22, '2026-07-03 19:00:00', 5.77, 1.36, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5811, 22, '2026-07-03 20:00:00', 6.56, 1.09, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5812, 22, '2026-07-03 21:00:00', 2.98, 0.95, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5813, 22, '2026-07-03 22:00:00', 0.41, 0.29, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5814, 22, '2026-07-03 23:00:00', 0.13, 0.24, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5815, 22, '2026-07-04 00:00:00', 0.41, 0.12, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5816, 22, '2026-07-04 01:00:00', 0.88, 0.37, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5817, 22, '2026-07-04 02:00:00', 0.90, 0.10, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5818, 22, '2026-07-04 03:00:00', 0.13, 0.25, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5819, 22, '2026-07-04 04:00:00', 0.59, 0.12, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5820, 22, '2026-07-04 05:00:00', 2.92, 0.40, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5821, 22, '2026-07-04 06:00:00', 10.04, 1.69, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5822, 22, '2026-07-04 07:00:00', 5.58, 1.73, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5823, 22, '2026-07-04 08:00:00', 5.12, 0.58, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5824, 22, '2026-07-04 09:00:00', 4.76, 1.08, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5825, 22, '2026-07-04 10:00:00', 3.34, 0.91, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5826, 22, '2026-07-04 11:00:00', 3.44, 0.64, 'simulated', '2026-07-04 11:06:15');
INSERT INTO `el_utility_data` VALUES (5827, 23, '2026-06-27 11:00:00', 9.34, 1.39, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5828, 23, '2026-06-27 12:00:00', 6.81, 1.02, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5829, 23, '2026-06-27 13:00:00', 5.60, 1.20, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5830, 23, '2026-06-27 14:00:00', 4.52, 0.52, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5831, 23, '2026-06-27 15:00:00', 2.56, 0.74, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5832, 23, '2026-06-27 16:00:00', 4.68, 1.18, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5833, 23, '2026-06-27 17:00:00', 17.28, 1.79, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5834, 23, '2026-06-27 18:00:00', 17.50, 1.70, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5835, 23, '2026-06-27 19:00:00', 7.57, 2.68, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5836, 23, '2026-06-27 20:00:00', 15.69, 1.84, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5837, 23, '2026-06-27 21:00:00', 2.41, 0.47, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5838, 23, '2026-06-27 22:00:00', 1.37, 0.38, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5839, 23, '2026-06-27 23:00:00', 1.27, 0.14, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5840, 23, '2026-06-28 00:00:00', 1.27, 0.43, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5841, 23, '2026-06-28 01:00:00', 1.29, 0.40, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5842, 23, '2026-06-28 02:00:00', 0.44, 0.18, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5843, 23, '2026-06-28 03:00:00', 0.23, 0.21, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5844, 23, '2026-06-28 04:00:00', 1.01, 0.14, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5845, 23, '2026-06-28 05:00:00', 2.87, 1.06, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5846, 23, '2026-06-28 06:00:00', 14.49, 2.31, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5847, 23, '2026-06-28 07:00:00', 7.94, 1.85, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5848, 23, '2026-06-28 08:00:00', 11.04, 2.28, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5849, 23, '2026-06-28 09:00:00', 14.02, 2.44, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5850, 23, '2026-06-28 10:00:00', 1.59, 0.26, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5851, 23, '2026-06-28 11:00:00', 9.04, 0.87, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5852, 23, '2026-06-28 12:00:00', 5.03, 1.11, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5853, 23, '2026-06-28 13:00:00', 5.92, 1.20, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5854, 23, '2026-06-28 14:00:00', 4.87, 0.70, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5855, 23, '2026-06-28 15:00:00', 4.23, 0.49, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5856, 23, '2026-06-28 16:00:00', 2.90, 0.90, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5857, 23, '2026-06-28 17:00:00', 17.73, 2.27, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5858, 23, '2026-06-28 18:00:00', 18.08, 1.58, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5859, 23, '2026-06-28 19:00:00', 14.28, 1.75, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5860, 23, '2026-06-28 20:00:00', 15.27, 2.38, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5861, 23, '2026-06-28 21:00:00', 3.56, 0.49, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5862, 23, '2026-06-28 22:00:00', 1.07, 0.33, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5863, 23, '2026-06-28 23:00:00', 1.46, 0.43, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5864, 23, '2026-06-29 00:00:00', 1.09, 0.47, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5865, 23, '2026-06-29 01:00:00', 0.68, 0.26, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5866, 23, '2026-06-29 02:00:00', 0.38, 0.26, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5867, 23, '2026-06-29 03:00:00', 0.39, 0.26, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5868, 23, '2026-06-29 04:00:00', 1.19, 0.26, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5869, 23, '2026-06-29 05:00:00', 3.27, 0.67, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5870, 23, '2026-06-29 06:00:00', 11.83, 1.03, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5871, 23, '2026-06-29 07:00:00', 13.28, 1.34, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5872, 23, '2026-06-29 08:00:00', 9.61, 1.80, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5873, 23, '2026-06-29 09:00:00', 9.35, 0.92, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5874, 23, '2026-06-29 10:00:00', 2.56, 1.23, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5875, 23, '2026-06-29 11:00:00', 8.22, 1.81, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5876, 23, '2026-06-29 12:00:00', 10.43, 1.47, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5877, 23, '2026-06-29 13:00:00', 10.65, 1.24, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5878, 23, '2026-06-29 14:00:00', 2.39, 1.19, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5879, 23, '2026-06-29 15:00:00', 3.59, 0.68, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5880, 23, '2026-06-29 16:00:00', 2.49, 0.65, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5881, 23, '2026-06-29 17:00:00', 7.54, 1.13, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5882, 23, '2026-06-29 18:00:00', 13.48, 2.01, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5883, 23, '2026-06-29 19:00:00', 13.53, 3.24, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5884, 23, '2026-06-29 20:00:00', 9.96, 1.65, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5885, 23, '2026-06-29 21:00:00', 3.75, 0.43, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5886, 23, '2026-06-29 22:00:00', 1.30, 0.35, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5887, 23, '2026-06-29 23:00:00', 0.80, 0.40, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5888, 23, '2026-06-30 00:00:00', 0.14, 0.29, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5889, 23, '2026-06-30 01:00:00', 0.79, 0.13, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5890, 23, '2026-06-30 02:00:00', 0.75, 0.43, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5891, 23, '2026-06-30 03:00:00', 1.37, 0.35, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5892, 23, '2026-06-30 04:00:00', 1.11, 0.42, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5893, 23, '2026-06-30 05:00:00', 1.69, 1.24, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5894, 23, '2026-06-30 06:00:00', 8.10, 2.22, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5895, 23, '2026-06-30 07:00:00', 12.83, 2.07, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5896, 23, '2026-06-30 08:00:00', 6.33, 0.75, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5897, 23, '2026-06-30 09:00:00', 13.56, 2.18, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5898, 23, '2026-06-30 10:00:00', 2.70, 0.48, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5899, 23, '2026-06-30 11:00:00', 10.50, 1.53, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5900, 23, '2026-06-30 12:00:00', 5.45, 0.81, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5901, 23, '2026-06-30 13:00:00', 5.60, 1.87, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5902, 23, '2026-06-30 14:00:00', 3.31, 1.07, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5903, 23, '2026-06-30 15:00:00', 2.64, 0.59, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5904, 23, '2026-06-30 16:00:00', 2.61, 0.82, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5905, 23, '2026-06-30 17:00:00', 8.07, 2.37, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5906, 23, '2026-06-30 18:00:00', 16.33, 3.11, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5907, 23, '2026-06-30 19:00:00', 10.29, 2.09, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5908, 23, '2026-06-30 20:00:00', 13.03, 3.40, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5909, 23, '2026-06-30 21:00:00', 1.78, 0.89, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5910, 23, '2026-06-30 22:00:00', 1.42, 0.24, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5911, 23, '2026-06-30 23:00:00', 0.43, 0.45, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5912, 23, '2026-07-01 00:00:00', 0.22, 0.44, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5913, 23, '2026-07-01 01:00:00', 1.28, 0.36, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5914, 23, '2026-07-01 02:00:00', 0.01, 0.24, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5915, 23, '2026-07-01 03:00:00', 0.93, 0.28, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5916, 23, '2026-07-01 04:00:00', 0.91, 0.21, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5917, 23, '2026-07-01 05:00:00', 1.84, 1.07, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5918, 23, '2026-07-01 06:00:00', 13.44, 0.78, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5919, 23, '2026-07-01 07:00:00', 13.24, 2.43, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5920, 23, '2026-07-01 08:00:00', 7.89, 0.93, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5921, 23, '2026-07-01 09:00:00', 14.56, 1.46, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5922, 23, '2026-07-01 10:00:00', 1.68, 0.53, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5923, 23, '2026-07-01 11:00:00', 10.35, 1.74, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5924, 23, '2026-07-01 12:00:00', 5.79, 1.29, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5925, 23, '2026-07-01 13:00:00', 6.36, 1.95, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5926, 23, '2026-07-01 14:00:00', 3.04, 0.29, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5927, 23, '2026-07-01 15:00:00', 4.62, 0.84, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5928, 23, '2026-07-01 16:00:00', 3.09, 1.11, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5929, 23, '2026-07-01 17:00:00', 12.63, 2.65, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5930, 23, '2026-07-01 18:00:00', 16.44, 1.02, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5931, 23, '2026-07-01 19:00:00', 15.31, 2.97, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5932, 23, '2026-07-01 20:00:00', 10.75, 1.94, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5933, 23, '2026-07-01 21:00:00', 3.59, 0.60, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5934, 23, '2026-07-01 22:00:00', 0.12, 0.18, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5935, 23, '2026-07-01 23:00:00', 0.57, 0.29, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5936, 23, '2026-07-02 00:00:00', 1.29, 0.18, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5937, 23, '2026-07-02 01:00:00', 1.21, 0.44, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5938, 23, '2026-07-02 02:00:00', 0.99, 0.17, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5939, 23, '2026-07-02 03:00:00', 1.06, 0.48, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5940, 23, '2026-07-02 04:00:00', 0.29, 0.31, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5941, 23, '2026-07-02 05:00:00', 2.07, 0.73, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5942, 23, '2026-07-02 06:00:00', 14.60, 1.26, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5943, 23, '2026-07-02 07:00:00', 14.17, 0.75, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5944, 23, '2026-07-02 08:00:00', 9.03, 2.02, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5945, 23, '2026-07-02 09:00:00', 7.04, 2.28, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5946, 23, '2026-07-02 10:00:00', 5.09, 0.68, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5947, 23, '2026-07-02 11:00:00', 4.89, 0.62, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5948, 23, '2026-07-02 12:00:00', 9.15, 0.51, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5949, 23, '2026-07-02 13:00:00', 9.26, 1.53, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5950, 23, '2026-07-02 14:00:00', 4.01, 0.53, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5951, 23, '2026-07-02 15:00:00', 3.33, 0.35, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5952, 23, '2026-07-02 16:00:00', 1.85, 0.97, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5953, 23, '2026-07-02 17:00:00', 7.82, 3.20, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5954, 23, '2026-07-02 18:00:00', 17.60, 1.15, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5955, 23, '2026-07-02 19:00:00', 11.01, 1.63, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5956, 23, '2026-07-02 20:00:00', 17.20, 1.05, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5957, 23, '2026-07-02 21:00:00', 3.80, 0.49, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5958, 23, '2026-07-02 22:00:00', 0.15, 0.49, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5959, 23, '2026-07-02 23:00:00', 0.63, 0.23, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5960, 23, '2026-07-03 00:00:00', 1.41, 0.17, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5961, 23, '2026-07-03 01:00:00', 1.11, 0.36, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5962, 23, '2026-07-03 02:00:00', 1.36, 0.29, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5963, 23, '2026-07-03 03:00:00', 0.22, 0.39, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5964, 23, '2026-07-03 04:00:00', 0.70, 0.28, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5965, 23, '2026-07-03 05:00:00', 3.19, 0.74, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5966, 23, '2026-07-03 06:00:00', 10.74, 1.18, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5967, 23, '2026-07-03 07:00:00', 14.10, 1.72, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5968, 23, '2026-07-03 08:00:00', 12.47, 2.27, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5969, 23, '2026-07-03 09:00:00', 12.46, 1.68, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5970, 23, '2026-07-03 10:00:00', 2.74, 0.97, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5971, 23, '2026-07-03 11:00:00', 8.45, 1.11, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5972, 23, '2026-07-03 12:00:00', 5.80, 0.50, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5973, 23, '2026-07-03 13:00:00', 4.44, 1.56, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5974, 23, '2026-07-03 14:00:00', 2.56, 0.65, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5975, 23, '2026-07-03 15:00:00', 3.93, 0.29, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5976, 23, '2026-07-03 16:00:00', 2.27, 0.64, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5977, 23, '2026-07-03 17:00:00', 14.14, 2.27, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5978, 23, '2026-07-03 18:00:00', 17.46, 1.03, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5979, 23, '2026-07-03 19:00:00', 15.12, 1.75, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5980, 23, '2026-07-03 20:00:00', 7.56, 2.67, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5981, 23, '2026-07-03 21:00:00', 3.86, 1.09, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5982, 23, '2026-07-03 22:00:00', 1.41, 0.49, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5983, 23, '2026-07-03 23:00:00', 1.08, 0.43, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5984, 23, '2026-07-04 00:00:00', 0.10, 0.28, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5985, 23, '2026-07-04 01:00:00', 0.91, 0.39, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5986, 23, '2026-07-04 02:00:00', 0.58, 0.14, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5987, 23, '2026-07-04 03:00:00', 0.80, 0.22, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5988, 23, '2026-07-04 04:00:00', 0.78, 0.18, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5989, 23, '2026-07-04 05:00:00', 3.50, 1.16, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5990, 23, '2026-07-04 06:00:00', 10.20, 1.26, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5991, 23, '2026-07-04 07:00:00', 12.84, 2.42, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5992, 23, '2026-07-04 08:00:00', 10.97, 2.02, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5993, 23, '2026-07-04 09:00:00', 9.03, 1.78, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5994, 23, '2026-07-04 10:00:00', 4.75, 0.97, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5995, 23, '2026-07-04 11:00:00', 7.67, 1.64, 'simulated', '2026-07-04 11:06:18');
INSERT INTO `el_utility_data` VALUES (5996, 25, '2026-06-27 11:00:00', 6.58, 0.87, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (5997, 25, '2026-06-27 12:00:00', 4.20, 1.36, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (5998, 25, '2026-06-27 13:00:00', 4.17, 0.57, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (5999, 25, '2026-06-27 14:00:00', 4.22, 0.29, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6000, 25, '2026-06-27 15:00:00', 2.58, 1.05, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6001, 25, '2026-06-27 16:00:00', 4.42, 0.55, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6002, 25, '2026-06-27 17:00:00', 9.31, 1.05, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6003, 25, '2026-06-27 18:00:00', 10.10, 0.95, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6004, 25, '2026-06-27 19:00:00', 7.12, 2.66, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6005, 25, '2026-06-27 20:00:00', 10.38, 2.27, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6006, 25, '2026-06-27 21:00:00', 1.93, 0.67, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6007, 25, '2026-06-27 22:00:00', 1.12, 0.13, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6008, 25, '2026-06-27 23:00:00', 0.14, 0.16, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6009, 25, '2026-06-28 00:00:00', 1.01, 0.19, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6010, 25, '2026-06-28 01:00:00', 0.43, 0.27, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6011, 25, '2026-06-28 02:00:00', 0.80, 0.29, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6012, 25, '2026-06-28 03:00:00', 0.65, 0.33, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6013, 25, '2026-06-28 04:00:00', 1.11, 0.35, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6014, 25, '2026-06-28 05:00:00', 4.40, 0.44, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6015, 25, '2026-06-28 06:00:00', 13.18, 2.00, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6016, 25, '2026-06-28 07:00:00', 10.69, 1.37, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6017, 25, '2026-06-28 08:00:00', 7.44, 1.36, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6018, 25, '2026-06-28 09:00:00', 8.84, 0.80, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6019, 25, '2026-06-28 10:00:00', 4.55, 0.64, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6020, 25, '2026-06-28 11:00:00', 3.89, 0.80, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6021, 25, '2026-06-28 12:00:00', 6.03, 0.57, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6022, 25, '2026-06-28 13:00:00', 4.13, 0.92, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6023, 25, '2026-06-28 14:00:00', 3.10, 0.61, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6024, 25, '2026-06-28 15:00:00', 3.18, 0.62, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6025, 25, '2026-06-28 16:00:00', 3.95, 0.36, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6026, 25, '2026-06-28 17:00:00', 13.60, 2.90, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6027, 25, '2026-06-28 18:00:00', 12.99, 1.75, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6028, 25, '2026-06-28 19:00:00', 7.38, 2.29, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6029, 25, '2026-06-28 20:00:00', 16.46, 1.55, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6030, 25, '2026-06-28 21:00:00', 2.79, 0.27, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6031, 25, '2026-06-28 22:00:00', 0.66, 0.26, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6032, 25, '2026-06-28 23:00:00', 1.26, 0.20, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6033, 25, '2026-06-29 00:00:00', 1.02, 0.16, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6034, 25, '2026-06-29 01:00:00', 1.21, 0.34, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6035, 25, '2026-06-29 02:00:00', 0.13, 0.16, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6036, 25, '2026-06-29 03:00:00', 0.25, 0.34, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6037, 25, '2026-06-29 04:00:00', 0.87, 0.37, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6038, 25, '2026-06-29 05:00:00', 2.50, 0.45, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6039, 25, '2026-06-29 06:00:00', 9.01, 1.41, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6040, 25, '2026-06-29 07:00:00', 11.57, 1.57, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6041, 25, '2026-06-29 08:00:00', 8.42, 1.16, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6042, 25, '2026-06-29 09:00:00', 9.34, 1.00, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6043, 25, '2026-06-29 10:00:00', 4.56, 0.51, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6044, 25, '2026-06-29 11:00:00', 4.62, 0.52, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6045, 25, '2026-06-29 12:00:00', 9.26, 1.06, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6046, 25, '2026-06-29 13:00:00', 4.44, 1.25, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6047, 25, '2026-06-29 14:00:00', 3.47, 0.75, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6048, 25, '2026-06-29 15:00:00', 1.52, 0.44, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6049, 25, '2026-06-29 16:00:00', 3.44, 0.54, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6050, 25, '2026-06-29 17:00:00', 15.70, 1.29, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6051, 25, '2026-06-29 18:00:00', 10.60, 2.84, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6052, 25, '2026-06-29 19:00:00', 7.72, 2.22, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6053, 25, '2026-06-29 20:00:00', 12.41, 2.16, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6054, 25, '2026-06-29 21:00:00', 3.90, 1.04, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6055, 25, '2026-06-29 22:00:00', 0.77, 0.28, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6056, 25, '2026-06-29 23:00:00', 1.16, 0.23, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6057, 25, '2026-06-30 00:00:00', 0.24, 0.20, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6058, 25, '2026-06-30 01:00:00', 1.04, 0.14, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6059, 25, '2026-06-30 02:00:00', 0.37, 0.14, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6060, 25, '2026-06-30 03:00:00', 0.45, 0.17, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6061, 25, '2026-06-30 04:00:00', 1.25, 0.12, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6062, 25, '2026-06-30 05:00:00', 3.25, 0.81, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6063, 25, '2026-06-30 06:00:00', 6.83, 1.04, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6064, 25, '2026-06-30 07:00:00', 12.79, 1.30, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6065, 25, '2026-06-30 08:00:00', 10.55, 1.58, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6066, 25, '2026-06-30 09:00:00', 10.96, 1.39, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6067, 25, '2026-06-30 10:00:00', 1.87, 1.05, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6068, 25, '2026-06-30 11:00:00', 6.60, 0.64, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6069, 25, '2026-06-30 12:00:00', 5.10, 1.30, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6070, 25, '2026-06-30 13:00:00', 4.07, 0.59, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6071, 25, '2026-06-30 14:00:00', 3.18, 0.78, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6072, 25, '2026-06-30 15:00:00', 4.01, 0.65, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6073, 25, '2026-06-30 16:00:00', 4.29, 0.69, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6074, 25, '2026-06-30 17:00:00', 15.88, 2.11, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6075, 25, '2026-06-30 18:00:00', 7.67, 2.92, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6076, 25, '2026-06-30 19:00:00', 9.05, 2.40, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6077, 25, '2026-06-30 20:00:00', 13.54, 1.52, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6078, 25, '2026-06-30 21:00:00', 4.16, 0.72, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6079, 25, '2026-06-30 22:00:00', 1.26, 0.13, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6080, 25, '2026-06-30 23:00:00', 0.54, 0.31, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6081, 25, '2026-07-01 00:00:00', 0.51, 0.23, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6082, 25, '2026-07-01 01:00:00', 0.50, 0.38, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6083, 25, '2026-07-01 02:00:00', 1.28, 0.37, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6084, 25, '2026-07-01 03:00:00', 0.92, 0.14, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6085, 25, '2026-07-01 04:00:00', 0.84, 0.28, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6086, 25, '2026-07-01 05:00:00', 3.83, 0.58, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6087, 25, '2026-07-01 06:00:00', 10.03, 0.57, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6088, 25, '2026-07-01 07:00:00', 8.92, 1.28, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6089, 25, '2026-07-01 08:00:00', 11.23, 2.04, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6090, 25, '2026-07-01 09:00:00', 10.94, 1.11, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6091, 25, '2026-07-01 10:00:00', 3.92, 0.36, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6092, 25, '2026-07-01 11:00:00', 9.29, 1.63, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6093, 25, '2026-07-01 12:00:00', 5.27, 0.87, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6094, 25, '2026-07-01 13:00:00', 9.29, 1.44, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6095, 25, '2026-07-01 14:00:00', 3.79, 0.23, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6096, 25, '2026-07-01 15:00:00', 1.82, 0.80, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6097, 25, '2026-07-01 16:00:00', 3.12, 0.66, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6098, 25, '2026-07-01 17:00:00', 15.12, 2.03, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6099, 25, '2026-07-01 18:00:00', 12.97, 2.89, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6100, 25, '2026-07-01 19:00:00', 15.45, 1.33, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6101, 25, '2026-07-01 20:00:00', 15.75, 1.73, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6102, 25, '2026-07-01 21:00:00', 4.41, 0.48, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6103, 25, '2026-07-01 22:00:00', 0.58, 0.30, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6104, 25, '2026-07-01 23:00:00', 0.90, 0.18, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6105, 25, '2026-07-02 00:00:00', 1.23, 0.41, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6106, 25, '2026-07-02 01:00:00', 0.50, 0.28, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6107, 25, '2026-07-02 02:00:00', 0.64, 0.23, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6108, 25, '2026-07-02 03:00:00', 1.02, 0.11, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6109, 25, '2026-07-02 04:00:00', 0.07, 0.22, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6110, 25, '2026-07-02 05:00:00', 3.33, 0.72, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6111, 25, '2026-07-02 06:00:00', 9.72, 0.70, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6112, 25, '2026-07-02 07:00:00', 5.70, 1.92, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6113, 25, '2026-07-02 08:00:00', 11.17, 1.66, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6114, 25, '2026-07-02 09:00:00', 7.97, 1.11, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6115, 25, '2026-07-02 10:00:00', 3.00, 0.68, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6116, 25, '2026-07-02 11:00:00', 6.15, 1.38, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6117, 25, '2026-07-02 12:00:00', 6.48, 1.24, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6118, 25, '2026-07-02 13:00:00', 3.81, 1.23, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6119, 25, '2026-07-02 14:00:00', 3.43, 0.72, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6120, 25, '2026-07-02 15:00:00', 3.84, 0.51, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6121, 25, '2026-07-02 16:00:00', 2.76, 0.28, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6122, 25, '2026-07-02 17:00:00', 8.07, 1.27, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6123, 25, '2026-07-02 18:00:00', 11.80, 2.39, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6124, 25, '2026-07-02 19:00:00', 9.11, 2.17, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6125, 25, '2026-07-02 20:00:00', 9.81, 1.51, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6126, 25, '2026-07-02 21:00:00', 2.48, 1.04, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6127, 25, '2026-07-02 22:00:00', 1.20, 0.25, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6128, 25, '2026-07-02 23:00:00', 0.97, 0.38, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6129, 25, '2026-07-03 00:00:00', 0.52, 0.21, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6130, 25, '2026-07-03 01:00:00', 1.01, 0.11, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6131, 25, '2026-07-03 02:00:00', 1.08, 0.24, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6132, 25, '2026-07-03 03:00:00', 0.59, 0.16, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6133, 25, '2026-07-03 04:00:00', 0.94, 0.28, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6134, 25, '2026-07-03 05:00:00', 2.81, 0.89, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6135, 25, '2026-07-03 06:00:00', 6.07, 0.60, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6136, 25, '2026-07-03 07:00:00', 6.12, 0.92, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6137, 25, '2026-07-03 08:00:00', 6.37, 0.53, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6138, 25, '2026-07-03 09:00:00', 12.57, 1.88, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6139, 25, '2026-07-03 10:00:00', 1.35, 0.94, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6140, 25, '2026-07-03 11:00:00', 6.04, 0.46, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6141, 25, '2026-07-03 12:00:00', 7.48, 1.60, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6142, 25, '2026-07-03 13:00:00', 8.31, 1.48, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6143, 25, '2026-07-03 14:00:00', 3.02, 0.34, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6144, 25, '2026-07-03 15:00:00', 2.42, 0.44, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6145, 25, '2026-07-03 16:00:00', 4.27, 0.25, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6146, 25, '2026-07-03 17:00:00', 13.62, 2.56, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6147, 25, '2026-07-03 18:00:00', 11.17, 1.65, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6148, 25, '2026-07-03 19:00:00', 13.53, 1.20, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6149, 25, '2026-07-03 20:00:00', 10.10, 1.95, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6150, 25, '2026-07-03 21:00:00', 1.49, 0.24, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6151, 25, '2026-07-03 22:00:00', 1.10, 0.27, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6152, 25, '2026-07-03 23:00:00', 0.13, 0.37, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6153, 25, '2026-07-04 00:00:00', 0.08, 0.20, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6154, 25, '2026-07-04 01:00:00', 0.25, 0.24, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6155, 25, '2026-07-04 02:00:00', 0.83, 0.20, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6156, 25, '2026-07-04 03:00:00', 1.30, 0.11, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6157, 25, '2026-07-04 04:00:00', 0.05, 0.34, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6158, 25, '2026-07-04 05:00:00', 3.71, 0.49, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6159, 25, '2026-07-04 06:00:00', 6.78, 0.63, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6160, 25, '2026-07-04 07:00:00', 9.55, 0.96, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6161, 25, '2026-07-04 08:00:00', 5.64, 1.40, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6162, 25, '2026-07-04 09:00:00', 8.41, 1.82, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6163, 25, '2026-07-04 10:00:00', 4.48, 0.73, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6164, 25, '2026-07-04 11:00:00', 7.84, 1.68, 'simulated', '2026-07-04 11:06:20');
INSERT INTO `el_utility_data` VALUES (6165, 24, '2026-06-27 11:00:00', 11.25, 1.08, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6166, 24, '2026-06-27 12:00:00', 10.52, 1.80, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6167, 24, '2026-06-27 13:00:00', 13.83, 2.28, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6168, 24, '2026-06-27 14:00:00', 2.10, 0.72, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6169, 24, '2026-06-27 15:00:00', 5.43, 0.84, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6170, 24, '2026-06-27 16:00:00', 3.25, 0.97, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6171, 24, '2026-06-27 17:00:00', 23.25, 2.64, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6172, 24, '2026-06-27 18:00:00', 10.33, 3.70, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6173, 24, '2026-06-27 19:00:00', 18.71, 1.39, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6174, 24, '2026-06-27 20:00:00', 22.50, 2.57, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6175, 24, '2026-06-27 21:00:00', 3.24, 1.43, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6176, 24, '2026-06-27 22:00:00', 1.45, 0.39, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6177, 24, '2026-06-27 23:00:00', 0.45, 0.25, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6178, 24, '2026-06-28 00:00:00', 1.76, 0.24, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6179, 24, '2026-06-28 01:00:00', 1.61, 0.53, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6180, 24, '2026-06-28 02:00:00', 0.50, 0.56, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6181, 24, '2026-06-28 03:00:00', 0.01, 0.46, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6182, 24, '2026-06-28 04:00:00', 0.64, 0.44, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6183, 24, '2026-06-28 05:00:00', 6.47, 0.55, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6184, 24, '2026-06-28 06:00:00', 12.70, 2.90, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6185, 24, '2026-06-28 07:00:00', 8.78, 2.21, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6186, 24, '2026-06-28 08:00:00', 13.70, 1.85, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6187, 24, '2026-06-28 09:00:00', 8.91, 1.35, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6188, 24, '2026-06-28 10:00:00', 5.05, 0.45, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6189, 24, '2026-06-28 11:00:00', 12.74, 2.36, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6190, 24, '2026-06-28 12:00:00', 12.71, 0.65, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6191, 24, '2026-06-28 13:00:00', 10.93, 1.70, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6192, 24, '2026-06-28 14:00:00', 3.47, 0.68, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6193, 24, '2026-06-28 15:00:00', 5.20, 0.67, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6194, 24, '2026-06-28 16:00:00', 4.65, 0.85, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6195, 24, '2026-06-28 17:00:00', 22.65, 3.98, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6196, 24, '2026-06-28 18:00:00', 9.86, 3.17, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6197, 24, '2026-06-28 19:00:00', 9.95, 2.86, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6198, 24, '2026-06-28 20:00:00', 21.36, 4.21, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6199, 24, '2026-06-28 21:00:00', 5.40, 0.69, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6200, 24, '2026-06-28 22:00:00', 1.28, 0.30, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6201, 24, '2026-06-28 23:00:00', 0.13, 0.35, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6202, 24, '2026-06-29 00:00:00', 0.09, 0.54, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6203, 24, '2026-06-29 01:00:00', 0.43, 0.46, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6204, 24, '2026-06-29 02:00:00', 1.41, 0.41, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6205, 24, '2026-06-29 03:00:00', 1.47, 0.28, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6206, 24, '2026-06-29 04:00:00', 0.23, 0.40, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6207, 24, '2026-06-29 05:00:00', 4.54, 0.82, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6208, 24, '2026-06-29 06:00:00', 15.53, 0.83, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6209, 24, '2026-06-29 07:00:00', 16.14, 1.32, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6210, 24, '2026-06-29 08:00:00', 16.38, 2.23, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6211, 24, '2026-06-29 09:00:00', 7.63, 0.97, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6212, 24, '2026-06-29 10:00:00', 1.96, 0.89, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6213, 24, '2026-06-29 11:00:00', 7.06, 1.25, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6214, 24, '2026-06-29 12:00:00', 6.84, 1.14, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6215, 24, '2026-06-29 13:00:00', 7.73, 1.38, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6216, 24, '2026-06-29 14:00:00', 4.58, 1.18, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6217, 24, '2026-06-29 15:00:00', 6.06, 0.78, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6218, 24, '2026-06-29 16:00:00', 4.01, 0.77, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6219, 24, '2026-06-29 17:00:00', 16.25, 2.66, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6220, 24, '2026-06-29 18:00:00', 12.60, 4.11, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6221, 24, '2026-06-29 19:00:00', 20.53, 2.63, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6222, 24, '2026-06-29 20:00:00', 18.78, 3.45, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6223, 24, '2026-06-29 21:00:00', 2.83, 1.08, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6224, 24, '2026-06-29 22:00:00', 1.59, 0.58, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6225, 24, '2026-06-29 23:00:00', 0.19, 0.41, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6226, 24, '2026-06-30 00:00:00', 1.34, 0.46, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6227, 24, '2026-06-30 01:00:00', 1.47, 0.16, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6228, 24, '2026-06-30 02:00:00', 0.24, 0.58, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6229, 24, '2026-06-30 03:00:00', 0.35, 0.46, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6230, 24, '2026-06-30 04:00:00', 1.03, 0.33, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6231, 24, '2026-06-30 05:00:00', 2.86, 1.34, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6232, 24, '2026-06-30 06:00:00', 18.75, 2.76, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6233, 24, '2026-06-30 07:00:00', 17.46, 1.00, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6234, 24, '2026-06-30 08:00:00', 18.28, 1.47, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6235, 24, '2026-06-30 09:00:00', 13.99, 2.20, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6236, 24, '2026-06-30 10:00:00', 3.36, 1.02, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6237, 24, '2026-06-30 11:00:00', 10.60, 1.12, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6238, 24, '2026-06-30 12:00:00', 6.16, 2.02, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6239, 24, '2026-06-30 13:00:00', 6.54, 1.71, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6240, 24, '2026-06-30 14:00:00', 3.79, 0.39, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6241, 24, '2026-06-30 15:00:00', 4.50, 1.46, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6242, 24, '2026-06-30 16:00:00', 2.74, 1.09, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6243, 24, '2026-06-30 17:00:00', 10.86, 2.41, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6244, 24, '2026-06-30 18:00:00', 15.11, 3.45, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6245, 24, '2026-06-30 19:00:00', 17.00, 2.69, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6246, 24, '2026-06-30 20:00:00', 21.01, 3.22, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6247, 24, '2026-06-30 21:00:00', 4.78, 1.35, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6248, 24, '2026-06-30 22:00:00', 0.86, 0.34, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6249, 24, '2026-06-30 23:00:00', 1.60, 0.30, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6250, 24, '2026-07-01 00:00:00', 1.25, 0.41, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6251, 24, '2026-07-01 01:00:00', 0.53, 0.55, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6252, 24, '2026-07-01 02:00:00', 1.01, 0.45, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6253, 24, '2026-07-01 03:00:00', 0.40, 0.56, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6254, 24, '2026-07-01 04:00:00', 1.42, 0.35, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6255, 24, '2026-07-01 05:00:00', 4.05, 0.61, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6256, 24, '2026-07-01 06:00:00', 7.92, 1.52, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6257, 24, '2026-07-01 07:00:00', 8.32, 0.84, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6258, 24, '2026-07-01 08:00:00', 13.65, 2.46, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6259, 24, '2026-07-01 09:00:00', 9.10, 1.17, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6260, 24, '2026-07-01 10:00:00', 4.92, 1.19, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6261, 24, '2026-07-01 11:00:00', 8.69, 2.28, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6262, 24, '2026-07-01 12:00:00', 7.43, 2.14, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6263, 24, '2026-07-01 13:00:00', 13.51, 1.97, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6264, 24, '2026-07-01 14:00:00', 2.48, 0.91, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6265, 24, '2026-07-01 15:00:00', 5.35, 0.81, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6266, 24, '2026-07-01 16:00:00', 2.96, 0.77, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6267, 24, '2026-07-01 17:00:00', 13.40, 3.06, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6268, 24, '2026-07-01 18:00:00', 22.94, 2.47, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6269, 24, '2026-07-01 19:00:00', 17.49, 1.40, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6270, 24, '2026-07-01 20:00:00', 22.94, 2.62, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6271, 24, '2026-07-01 21:00:00', 3.28, 1.29, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6272, 24, '2026-07-01 22:00:00', 1.75, 0.45, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6273, 24, '2026-07-01 23:00:00', 1.89, 0.45, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6274, 24, '2026-07-02 00:00:00', 1.70, 0.34, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6275, 24, '2026-07-02 01:00:00', 1.51, 0.24, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6276, 24, '2026-07-02 02:00:00', 0.55, 0.56, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6277, 24, '2026-07-02 03:00:00', 0.04, 0.17, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6278, 24, '2026-07-02 04:00:00', 1.86, 0.60, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6279, 24, '2026-07-02 05:00:00', 4.09, 0.40, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6280, 24, '2026-07-02 06:00:00', 18.24, 2.48, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6281, 24, '2026-07-02 07:00:00', 12.56, 1.07, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6282, 24, '2026-07-02 08:00:00', 14.61, 0.87, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6283, 24, '2026-07-02 09:00:00', 9.17, 2.97, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6284, 24, '2026-07-02 10:00:00', 5.02, 0.44, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6285, 24, '2026-07-02 11:00:00', 13.98, 2.01, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6286, 24, '2026-07-02 12:00:00', 11.79, 0.67, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6287, 24, '2026-07-02 13:00:00', 11.95, 1.72, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6288, 24, '2026-07-02 14:00:00', 4.89, 0.98, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6289, 24, '2026-07-02 15:00:00', 4.82, 1.52, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6290, 24, '2026-07-02 16:00:00', 4.86, 1.30, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6291, 24, '2026-07-02 17:00:00', 15.28, 3.67, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6292, 24, '2026-07-02 18:00:00', 17.28, 3.24, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6293, 24, '2026-07-02 19:00:00', 14.88, 1.60, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6294, 24, '2026-07-02 20:00:00', 16.35, 3.36, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6295, 24, '2026-07-02 21:00:00', 3.89, 0.69, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6296, 24, '2026-07-02 22:00:00', 0.15, 0.28, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6297, 24, '2026-07-02 23:00:00', 0.06, 0.40, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6298, 24, '2026-07-03 00:00:00', 0.49, 0.60, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6299, 24, '2026-07-03 01:00:00', 1.24, 0.25, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6300, 24, '2026-07-03 02:00:00', 1.05, 0.52, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6301, 24, '2026-07-03 03:00:00', 0.92, 0.55, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6302, 24, '2026-07-03 04:00:00', 0.08, 0.51, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6303, 24, '2026-07-03 05:00:00', 3.17, 0.76, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6304, 24, '2026-07-03 06:00:00', 9.08, 2.79, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6305, 24, '2026-07-03 07:00:00', 17.45, 1.30, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6306, 24, '2026-07-03 08:00:00', 7.89, 1.69, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6307, 24, '2026-07-03 09:00:00', 14.54, 2.68, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6308, 24, '2026-07-03 10:00:00', 5.43, 0.91, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6309, 24, '2026-07-03 11:00:00', 9.14, 2.35, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6310, 24, '2026-07-03 12:00:00', 13.59, 1.70, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6311, 24, '2026-07-03 13:00:00', 6.00, 1.64, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6312, 24, '2026-07-03 14:00:00', 4.91, 0.52, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6313, 24, '2026-07-03 15:00:00', 2.34, 0.57, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6314, 24, '2026-07-03 16:00:00', 3.48, 1.45, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6315, 24, '2026-07-03 17:00:00', 14.78, 2.49, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6316, 24, '2026-07-03 18:00:00', 13.85, 2.93, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6317, 24, '2026-07-03 19:00:00', 17.80, 1.80, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6318, 24, '2026-07-03 20:00:00', 13.90, 3.41, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6319, 24, '2026-07-03 21:00:00', 3.98, 1.04, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6320, 24, '2026-07-03 22:00:00', 0.24, 0.53, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6321, 24, '2026-07-03 23:00:00', 0.73, 0.37, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6322, 24, '2026-07-04 00:00:00', 0.63, 0.58, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6323, 24, '2026-07-04 01:00:00', 1.05, 0.59, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6324, 24, '2026-07-04 02:00:00', 1.82, 0.48, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6325, 24, '2026-07-04 03:00:00', 0.97, 0.36, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6326, 24, '2026-07-04 04:00:00', 0.65, 0.62, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6327, 24, '2026-07-04 05:00:00', 4.45, 1.04, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6328, 24, '2026-07-04 06:00:00', 14.00, 0.84, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6329, 24, '2026-07-04 07:00:00', 11.83, 2.37, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6330, 24, '2026-07-04 08:00:00', 12.31, 2.23, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6331, 24, '2026-07-04 09:00:00', 11.97, 1.12, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6332, 24, '2026-07-04 10:00:00', 4.85, 1.43, 'simulated', '2026-07-04 11:06:23');
INSERT INTO `el_utility_data` VALUES (6333, 24, '2026-07-04 11:00:00', 6.15, 2.13, 'simulated', '2026-07-04 11:06:23');

-- ----------------------------
-- Table structure for kb_article
-- ----------------------------
DROP TABLE IF EXISTS `kb_article`;
CREATE TABLE `kb_article`  (
  `article_id` bigint NOT NULL AUTO_INCREMENT COMMENT '文章主键',
  `title` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '标题',
  `keywords` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '关键词',
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '正文',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`article_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 22 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '维修知识库文章表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of kb_article
-- ----------------------------
INSERT INTO `kb_article` VALUES (1, '如何在线提交报修工单', '报修,工单,提交,维修', '登录业主端后进入「报修工单」，点击「提交报修」，选择报修类型（如水电、门窗、公共设施），填写问题描述并上传现场照片，提交后可在列表查看进度。紧急问题请备注「紧急」并拨打物业值班电话。', '2026-05-01 08:00:00');
INSERT INTO `kb_article` VALUES (2, '报修工单状态说明', '报修,状态,进度,待接单', '工单状态包括：待接单、已派单、处理中、待验收、已完成、已取消。您可在工单详情查看维修进度时间线，处理完成后请进行验收评价。', '2026-05-01 08:00:00');
INSERT INTO `kb_article` VALUES (3, '如何查看社区公告与停水停电通知', '公告,停水,停电,通知', '业主端「社区公告」可查看物业发布的通知；「停水停电」专门展示水电检修类通知。支持按标题、已读状态和发布时间筛选，点击详情可标记已读。', '2026-05-01 08:00:00');
INSERT INTO `kb_article` VALUES (4, '住户档案与紧急联系人维护', '住户,档案,紧急联系人', '在「住户档案」可查看物业登记的姓名、房号、电话等信息；紧急联系人可自行修改保存，便于物业在紧急情况下联系家属。', '2026-05-01 08:00:00');
INSERT INTO `kb_article` VALUES (5, '物业费与缴费常见问题', '物业,缴费,费用,账单', '本系统当前版本暂未开放在线缴费。如需咨询物业费、停车费等，请携带房本到物业服务中心办理，或在工作日拨打物业前台电话咨询。', '2026-05-01 08:00:00');
INSERT INTO `kb_article` VALUES (6, '装修报备与施工时间规定', '装修,报备,施工,噪音', '室内装修需提前到物业办理装修报备，施工时间一般为工作日 8:00-12:00、14:00-18:00，周末及节假日禁止有噪音施工。违规施工将被要求停工整改。', '2026-05-01 08:00:00');
INSERT INTO `kb_article` VALUES (7, '快递与外卖进出管理', '快递,外卖,门禁,访客', '小区实行门禁管理，快递员、外卖员可登记后进入指定区域。大件物品进入电梯需做好防护，建议在物业允许时段内搬运。', '2026-05-01 08:00:00');
INSERT INTO `kb_article` VALUES (8, '宠物饲养管理规定', '宠物,犬,猫,遛狗', '饲养宠物需登记并遵守社区文明公约：遛狗须牵绳、及时清理排泄物、避免犬吠扰民。禁养烈性犬，违规将按公约处理。', '2026-05-01 08:00:00');
INSERT INTO `kb_article` VALUES (9, '老人关怀与紧急求助', '老人,关怀,预警,求助', '社区对独居、高龄老人提供关怀服务。如遇老人健康预警或紧急情况，请立即联系物业或拨打120，同时可在系统中查看相关通知。', '2026-05-01 08:00:00');
INSERT INTO `kb_article` VALUES (10, '如何联系人工客服', '人工,客服,转人工,投诉', '若智能助手无法解答您的问题，可在问答中说「转人工」或描述复杂投诉、法律纠纷等，系统将为您接入人工客服，请在此对话中继续留言，物业人员将实时回复。', '2026-05-01 08:00:00');
INSERT INTO `kb_article` VALUES (11, '问候与礼貌用语回复', '你好,您好,谢谢,感谢,辛苦了,再见', '您好！我是智慧社区智能助手，很高兴为您服务。如有报修、公告、缴费、装修等问题，请随时提问。若问题已解决，也欢迎您礼貌道谢；如需人工帮助，可说「转人工」。祝您生活愉快！', '2026-05-01 08:00:00');
INSERT INTO `kb_article` VALUES (12, '社区文明公约', '文明,公约,邻里,和谐,规范', '社区倡导邻里互助、文明礼让：公共区域不堆放杂物、不高空抛物、不占用消防通道；夜间保持安静，控制装修与生活噪音；养宠牵绳、及时清便；爱护绿化与公共设施。违反公约者，物业将依据管理规定协调处理。', '2026-05-01 08:00:00');
INSERT INTO `kb_article` VALUES (13, '消防安全与应急疏散', '消防,安全,火灾,疏散,灭火器', '请勿在楼道、疏散通道停放电动车或堆放物品；不私拉电线、不飞线充电。熟悉楼栋安全出口与疏散路线，发现火情立即拨打119并联系物业。小区定期组织消防演练，请业主积极参与。', '2026-05-01 08:00:00');
INSERT INTO `kb_article` VALUES (14, '垃圾分类投放指南', '垃圾,分类,投放,回收,环保', '请按「可回收物、有害垃圾、厨余垃圾、其他垃圾」四类投放。大件垃圾请预约清运，勿随意丢弃在小区公共区域。具体投放时段与点位见社区公告或单元门张贴说明。', '2026-05-01 08:00:00');
INSERT INTO `kb_article` VALUES (15, '车辆与停车管理规定', '停车,车辆,车库,车位,违停', '业主车辆需登记后进出；地下车库请减速慢行，按位停车，勿占消防通道与他人车位。访客车辆可在门岗登记临时进入。长期违停或占用车位，物业将联系车主并依规处理。', '2026-05-01 08:00:00');
INSERT INTO `kb_article` VALUES (16, '公共区域使用规范', '公共,区域,电梯,大堂,杂物', '电梯内禁止吸烟、蹦跳、阻挡关门；大堂、走廊、楼梯间为公共疏散空间，不得长期堆放私人物品。使用健身器材、儿童游乐设施请注意安全，照看好儿童。', '2026-05-01 08:00:00');
INSERT INTO `kb_article` VALUES (17, '噪音与邻里安宁管理', '噪音,安静,扰民,装修,时间', '每日22:00至次日8:00为安静时段，请避免产生明显生活噪音。装修施工须遵守物业规定时段。如遇持续噪音扰民，可先友好沟通，必要时联系物业协调。', '2026-05-01 08:00:00');
INSERT INTO `kb_article` VALUES (18, '智能问答助手使用说明', '智能,问答,助手,使用,帮助', '您可在「智能问答」中文字、语音或上传图片咨询社区问题。支持多轮追问，如「那具体怎么操作？」。复杂问题将接入人工客服，接入后请在本对话继续留言，物业会实时回复；您也可主动结束对话。', '2026-05-01 08:00:00');
INSERT INTO `kb_article` VALUES (19, '访客登记与门禁使用', '访客,门禁,登记,二维码,进出', '亲友来访可在业主端或门岗登记访客信息；部分小区支持临时通行码。请提醒访客遵守社区管理规定，离开时及时注销登记，保障小区安全。', '2026-05-01 08:00:00');
INSERT INTO `kb_article` VALUES (20, '节假日社区服务安排', '节假日,服务,值班,安排,春节', '法定节假日期间物业服务中心可能调整营业时间，值班人员保持电话畅通，处理紧急报修与安全巡查。具体安排以社区公告为准，建议提前关注「社区公告」栏目。', '2026-05-01 08:00:00');
INSERT INTO `kb_article` VALUES (21, '业主大会表决事项预告', '业主大会,表决,充电桩,公告', '关于增设新能源充电桩方案，定于6月20日19:00在社区会议室召开业主大会表决。材料已张贴于各栋公告栏，欢迎查阅。', '2026-07-03 20:00:41');

-- ----------------------------
-- Table structure for kb_learn_draft
-- ----------------------------
DROP TABLE IF EXISTS `kb_learn_draft`;
CREATE TABLE `kb_learn_draft`  (
  `draft_id` bigint NOT NULL AUTO_INCREMENT COMMENT '草稿主键',
  `source_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '来源：notice/chat/document',
  `source_id` bigint NULL DEFAULT NULL COMMENT '来源业务ID',
  `source_ref` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '来源说明',
  `title` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '标题',
  `keywords` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '关键词',
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '正文',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '0待审核 1已采纳 2已拒绝',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`draft_id`) USING BTREE,
  INDEX `idx_kb_draft_source`(`source_type` ASC, `source_id` ASC) USING BTREE,
  INDEX `idx_kb_draft_status`(`status` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 32 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '知识库学习草稿表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of kb_learn_draft
-- ----------------------------
INSERT INTO `kb_learn_draft` VALUES (1, 'notice', 8, '电梯年度检修告知', '电梯年度检修告知', '电梯,检修,停梯,通知', '5月25日起分批检修各栋电梯，单次停梯约2-4小时。具体时段见各单元门口张贴通知，检修期间请优先步行或错峰乘梯。', '0', '2026-07-03 19:59:52');
INSERT INTO `kb_learn_draft` VALUES (2, 'notice', 28, '1-3栋联动检修停水', '1-3栋联动检修停水通知', '停水,检修,通知,应急供水', '6月25日8:00-18:00，1至3栋低区将进行联动停水检修。由于影响范围较大，请业主提前储备24小时用水。物业将在大堂提供应急供水，以备不时之需。', '0', '2026-07-03 19:59:52');
INSERT INTO `kb_learn_draft` VALUES (3, 'notice', 24, '9栋公区照明改造停电', '9栋公区照明改造停电通知', '停电,照明改造,9栋,公区', '9栋大堂及走廊照明改造，5月28日19:00-22:00公区停电。请使用手机照明，注意台阶安全，改造完成后照明将更加节能明亮。', '0', '2026-07-03 19:59:52');
INSERT INTO `kb_learn_draft` VALUES (4, 'notice', 1, '清明节文明祭扫倡议', '清明节文明祭扫倡议', '清明节,文明祭扫,倡议', '清明将至，倡导鲜花祭扫、网络祭扫等文明方式。请勿在楼道、阳台堆放纸钱等易燃物，祭扫后确认火源完全熄灭。', '0', '2026-07-03 19:59:52');
INSERT INTO `kb_learn_draft` VALUES (5, 'notice', 16, '1栋停水检修通知', '1栋停水检修通知', '停水,检修,通知,1栋,供水', '因主管道阀门更换，1栋将于5月12日9:00-17:00暂停供水。请提前储水，恢复供水初期水质可能短暂浑浊，放水后即可正常使用。', '0', '2026-07-03 19:59:52');
INSERT INTO `kb_learn_draft` VALUES (6, 'notice', 30, '4栋计划停水（待发布）', '4栋计划停水通知', '停水,检修,4栋,通知', '4栋主供水管计划7月5日8:00-14:00停水检修，具体以现场条件为准。本通知待工程方案确认后正式发布，请提前关注后续更新。', '0', '2026-07-03 19:59:52');
INSERT INTO `kb_learn_draft` VALUES (7, 'notice', 29, '全小区消防联动测试停电', '全小区消防联动测试停电通知', '消防联动测试, 停电, 电梯停运, 门禁系统', '6月30日10:00-10:30将进行全小区消防联动测试，期间电梯可能短暂停运，门禁系统将切换至备用电源。测试结束后，系统将自动恢复正常。请各位业主注意，并做好相关准备。', '0', '2026-07-03 19:59:53');
INSERT INTO `kb_learn_draft` VALUES (8, 'notice', 5, '夏季消防安全演练安排', '夏季消防安全演练安排', '消防,演练,疏散,安全', '定于5月18日15:00在中心广场进行消防疏散演练，请各楼栋配合物业工作人员指引。演练期间请勿围观堵塞通道。', '0', '2026-07-03 19:59:54');
INSERT INTO `kb_learn_draft` VALUES (9, 'notice', 18, '3栋水泵更换停水', '3栋水泵更换停水通知', '停水,水泵更换,3栋,通知', '3栋二次供水水泵更换，5月20日14:00-18:00低区停水。请关闭热水器进水阀，恢复供水后再开启，防止空烧损坏设备。', '0', '2026-07-03 19:59:54');
INSERT INTO `kb_learn_draft` VALUES (10, 'notice', 22, '7栋线路改造停电', '7栋线路改造停电通知', '停电,线路改造,7栋,通知', '7栋供电线路改造，6月12日0:00-6:00全栋停电。请提前为手机、应急灯充电，凌晨时段请注意出行安全。', '0', '2026-07-03 19:59:56');
INSERT INTO `kb_learn_draft` VALUES (11, 'notice', 17, '2栋配电室停电检修', '2栋配电室停电检修通知', '停电,检修,配电室,2栋', '2栋配电室设备检修，5月14日8:30-11:30全栋停电。请提前保存电脑数据，电梯将暂停运行，高层住户请合理安排出行。', '0', '2026-07-03 19:59:56');
INSERT INTO `kb_learn_draft` VALUES (12, 'notice', 20, '5栋燃气安全检查停气', '5栋燃气安全检查停气通知', '燃气,停气,检修,安全', '5栋将于5月25日9:00-12:00进行燃气安全检查，届时将停气检修。请业主提前关闭灶具阀门，恢复通气后先开窗通风再点火，确保安全。', '0', '2026-07-03 19:59:56');
INSERT INTO `kb_learn_draft` VALUES (13, 'notice', 23, '8栋主水管维修停水', '8栋主水管维修停水通知', '停水,维修,8栋,通知', '8栋主水管维修，6月18日8:00-12:00停水。工程车可能占用临时车位，请配合现场疏导，带来不便敬请谅解。', '0', '2026-07-03 19:59:56');
INSERT INTO `kb_learn_draft` VALUES (14, 'notice', 19, '4栋电梯机房停电', '4栋电梯机房停电处理措施', '电梯,停电,机房,处理,协助', '4栋电梯机房将于5月22日13:00-15:00进行维护，期间电梯将全部暂停。请业主提前规划好上下楼路线。对于老人及行动不便的住户，可联系物业寻求协助。', '0', '2026-07-03 19:59:56');
INSERT INTO `kb_learn_draft` VALUES (15, 'notice', 12, '蚊虫消杀作业公告', '蚊虫消杀作业公告', '蚊虫,消杀,公告,小区,作业', '6月3日晚20:00-22:00全小区进行蚊虫消杀作业，请业主关好门窗，收好食品。消杀后30分钟内请避免开窗，儿童和宠物请勿接触药剂喷洒区域。', '0', '2026-07-03 19:59:56');
INSERT INTO `kb_learn_draft` VALUES (16, 'notice', 26, '中心广场活动临时停电', '中心广场活动临时停电通知', '停电,活动,广场,路灯,景观灯', '广场端午活动用电调试，6月8日18:00-20:00周边路灯及景观灯关闭。调试结束后立即恢复，请夜间出行注意瞭望。', '0', '2026-07-03 19:59:58');
INSERT INTO `kb_learn_draft` VALUES (17, 'notice', 15, '高温防暑温馨提示', '高温防暑温馨提示', '高温,防暑,补水,空调温度', '6月起进入高温季节，请注意防暑补水。建议老人儿童减少11:00-15:00户外活动，室内空调温度不宜过低，避免室内外温差过大。', '0', '2026-07-03 19:59:59');
INSERT INTO `kb_learn_draft` VALUES (18, 'notice', 14, '儿童节礼品领取通知', '儿童节礼品领取通知', '儿童节,礼品,领取,通知', '6月1日9:00-17:00在一层大堂领取儿童节礼品，每户限领一份。请携带业主身份证明，代领需出示授权信息。', '0', '2026-07-03 19:59:59');
INSERT INTO `kb_learn_draft` VALUES (19, 'notice', 7, '亲子运动会报名开启', '亲子运动会报名开启', '亲子运动会, 报名, 时间, 项目', '6月15日将举办亲子运动会，包括跳绳、接力等项目。线上报名截止日期为6月8日，业主可通过业主群或物业前台填写报名表。', '0', '2026-07-03 19:59:59');
INSERT INTO `kb_learn_draft` VALUES (20, 'notice', 10, '地下车库清洗通知', '地下车库清洗通知', '地下车库,清洗,通知', '6月6日清洗B1、B2层车库，当日8:00-18:00请尽量驶离或配合移位。清洗后地面湿滑，请注意行车安全。', '0', '2026-07-03 20:00:00');
INSERT INTO `kb_learn_draft` VALUES (21, 'notice', 25, '10栋阀门更换停水', '10栋阀门更换停水通知', '停水,阀门更换,10栋,通知', '10栋总阀更换，6月2日9:00-11:00停水。停水时间较短，请提前储少量生活用水，恢复后请先放清管道存水。', '0', '2026-07-03 20:00:00');
INSERT INTO `kb_learn_draft` VALUES (22, 'notice', 4, '端午节包粽子活动通知', '端午节包粽子活动通知', '端午节,包粽子,活动,报名', '社区将于6月9日14:00在活动中心举办包粽子活动，限40组家庭，额满即止。报名请联系楼栋管家或至物业前台登记。', '2', '2026-07-03 20:00:01');
INSERT INTO `kb_learn_draft` VALUES (23, 'notice', 11, '业主大会表决事项预告', '业主大会表决事项预告', '业主大会,表决,充电桩,公告', '关于增设新能源充电桩方案，定于6月20日19:00在社区会议室召开业主大会表决。材料已张贴于各栋公告栏，欢迎查阅。', '1', '2026-07-03 20:00:02');
INSERT INTO `kb_learn_draft` VALUES (24, 'notice', 31, '社区大扫除', '社区大扫除通知', '社区,大扫除,通知', '明天下午将进行社区大扫除，如有打扰请多包涵。', '0', '2026-07-04 00:03:34');
INSERT INTO `kb_learn_draft` VALUES (25, 'notice', 32, '社区大扫除', '__AUTO_SKIP__', '', '与现有知识库相比无新增知识点，已自动跳过。', '2', '2026-07-04 00:03:34');
INSERT INTO `kb_learn_draft` VALUES (26, 'notice', 33, '5栋停水通知', '5栋停水通知', '停水, 5栋, 通知, 屯水', '5栋将于2026年7月5日停水，预计停水持续一天，请广大居民朋友提前屯好水源。', '0', '2026-07-04 00:05:32');
INSERT INTO `kb_learn_draft` VALUES (27, 'notice', 34, '5栋停水通知', '__AUTO_SKIP__', '', '与现有知识库相比无新增知识点，已自动跳过。', '2', '2026-07-04 00:05:32');
INSERT INTO `kb_learn_draft` VALUES (28, 'notice', 35, 'test', '__AUTO_SKIP__', '', '与现有知识库相比无新增知识点，已自动跳过。', '2', '2026-07-04 00:14:35');
INSERT INTO `kb_learn_draft` VALUES (29, 'notice', 36, 'test', '__AUTO_SKIP__', '', '与现有知识库相比无新增知识点，已自动跳过。', '2', '2026-07-04 00:14:36');
INSERT INTO `kb_learn_draft` VALUES (30, 'notice', 37, 'test', '__AUTO_SKIP__', '', '与现有知识库相比无新增知识点，已自动跳过。', '2', '2026-07-04 00:21:25');
INSERT INTO `kb_learn_draft` VALUES (31, 'notice', 38, '特踏实', '__AUTO_SKIP__', '', '与现有知识库相比无新增知识点，已自动跳过。', '2', '2026-07-04 00:22:02');

-- ----------------------------
-- Table structure for pm_staff
-- ----------------------------
DROP TABLE IF EXISTS `pm_staff`;
CREATE TABLE `pm_staff`  (
  `staff_id` bigint NOT NULL AUTO_INCREMENT COMMENT '物业人员ID',
  `name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '姓名',
  `gender` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '性别',
  `age` int NULL DEFAULT NULL COMMENT '年龄',
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '手机号',
  `avatar` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '头像',
  `dept` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '部门',
  `del_flag` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '删除：0存在 2删除',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`staff_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 5 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '物业人员档案表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of pm_staff
-- ----------------------------
INSERT INTO `pm_staff` VALUES (4, '王管家', '1', 37, '13800000003', '/upload/avatar/27561c64154c486a862f03502acc706a.jpg', '物业管理部', '0', '2026-05-17 18:16:04', '2026-07-03 23:32:12');

-- ----------------------------
-- Table structure for rp_order
-- ----------------------------
DROP TABLE IF EXISTS `rp_order`;
CREATE TABLE `rp_order`  (
  `order_id` bigint NOT NULL AUTO_INCREMENT COMMENT '工单主键',
  `order_no` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '工单编号',
  `owner_id` bigint NOT NULL COMMENT '业主用户ID',
  `house_id` bigint NULL DEFAULT NULL COMMENT '房屋ID',
  `type_id` bigint NULL DEFAULT NULL COMMENT '报修类型ID',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '故障描述',
  `urgency` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'normal' COMMENT '紧急程度',
  `status` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'pending' COMMENT '工单状态',
  `worker_id` bigint NULL DEFAULT NULL COMMENT '维修工ID',
  `urge_count` int NULL DEFAULT 0 COMMENT '催单次数',
  `promise_hours` int NULL DEFAULT 24 COMMENT '承诺时长(小时)',
  `material_fee` decimal(10, 2) NULL DEFAULT 0.00 COMMENT '材料费',
  `labor_fee` decimal(10, 2) NULL DEFAULT 0.00 COMMENT '人工费',
  `frozen` tinyint NULL DEFAULT 0 COMMENT '冻结：0否 1是',
  `sign_image` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '验收签名图',
  `reject_reason` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '拒单原因',
  `assign_reason` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '派单原因',
  `ai_type_label` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT 'AI归类标签',
  `high_risk` tinyint NULL DEFAULT 0 COMMENT '高风险标注：0否 1是',
  `duplicate_flag` tinyint NULL DEFAULT 0 COMMENT '重复报修标记：0否 1是',
  `expected_time` datetime NULL DEFAULT NULL COMMENT '期望上门时间',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`order_id`) USING BTREE,
  UNIQUE INDEX `uk_order_no`(`order_no` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 30 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '报修工单表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of rp_order
-- ----------------------------
INSERT INTO `rp_order` VALUES (13, 'RP202606060001', 2, 1, 2, '厨房水龙头漏水严重', 'urgent', 'completed', 3, 0, 24, 0.00, 0.00, 0, '', '', '', '', 0, 0, NULL, '2026-06-06 09:00:00', '2026-07-03 10:54:28');
INSERT INTO `rp_order` VALUES (14, 'RP202606090001', 5, 11, 8, '客厅跳闸无法恢复', 'urgent', 'completed', 3, 0, 24, 0.00, 0.00, 0, '', '', '', '', 0, 0, NULL, '2026-06-09 09:00:00', '2026-07-03 21:24:19');
INSERT INTO `rp_order` VALUES (15, 'RP202606110001', 6, 21, 2, '卫生间水管渗漏', 'normal', 'completed', 3, 0, 24, 0.00, 0.00, 0, '', '', '', '', 0, 0, NULL, '2026-06-11 09:00:00', '2026-07-03 10:54:28');
INSERT INTO `rp_order` VALUES (16, 'RP202606130001', 7, 31, 8, '卧室电路跳闸', 'normal', 'completed', 3, 0, 24, 0.00, 0.00, 0, '', '', '', '', 0, 0, NULL, '2026-06-13 09:00:00', '2026-07-03 21:24:19');
INSERT INTO `rp_order` VALUES (17, 'RP202606160001', 8, 41, 2, '阳台水管破裂', 'urgent', 'completed', 3, 0, 24, 0.00, 0.00, 0, '', '', '', '', 0, 0, NULL, '2026-06-16 09:00:00', '2026-07-03 10:54:28');
INSERT INTO `rp_order` VALUES (18, 'RP202606190001', 9, 51, 12, '厨房电路短路', 'urgent', 'processing', 3, 0, 24, 0.00, 0.00, 0, '', '', '', '', 0, 0, NULL, '2026-06-19 09:00:00', '2026-07-03 21:24:19');
INSERT INTO `rp_order` VALUES (19, 'RP202606210001', 10, 61, 2, '浴室花洒漏水', 'normal', 'processing', 3, 0, 24, 0.00, 0.00, 0, '', '', '', '', 0, 0, NULL, '2026-06-21 09:00:00', '2026-07-03 10:54:28');
INSERT INTO `rp_order` VALUES (20, 'RP202606230001', 11, 71, 28, '楼道灯不亮', 'normal', 'processing', 20, 0, 24, 0.00, 0.00, 0, '', '', '', '', 0, 0, NULL, '2026-06-23 09:00:00', '2026-07-03 21:24:19');
INSERT INTO `rp_order` VALUES (21, 'RP202606260001', 12, 81, 2, '地下室水管爆裂', 'normal', 'completed', 3, 0, 24, 0.00, 0.00, 0, '', '', '', '', 0, 0, NULL, '2026-06-26 09:00:00', '2026-07-03 10:54:28');
INSERT INTO `rp_order` VALUES (22, 'RP202606280001', 2, 1, 14, '空调外机异响\n[追加] 故障加重', 'normal', 'processing', 19, 0, 24, 0.00, 0.00, 0, '', '', '', '', 0, 0, NULL, '2026-06-28 09:00:00', '2026-07-03 21:24:19');
INSERT INTO `rp_order` VALUES (23, 'RP202606290001', 5, 11, 2, '热水器水管漏水', 'urgent', 'completed', 3, 0, 24, 0.00, 0.00, 0, '/upload/repair/20260703/sign/c39035019ca944f1afc19a3dfd77f265.png', '', '', '', 0, 0, NULL, '2026-06-29 09:00:00', '2026-07-03 10:54:28');
INSERT INTO `rp_order` VALUES (24, 'RP202606300001', 6, 21, 12, '插座烧焦', 'urgent', 'wait_accept', 3, 0, 24, 0.00, 0.00, 0, '', '', '', '', 0, 0, NULL, '2026-06-30 09:00:00', '2026-07-03 21:24:19');
INSERT INTO `rp_order` VALUES (25, 'RP202607020001', 2, 1, 2, '房子顶部漏水', 'urgent', 'completed', 3, 0, 24, 0.00, 0.00, 0, '/upload/repair/20260702/sign/556ac157e47342eca5a9af08c99e6afd.png', '', '', '水管漏水', 0, 0, '2026-07-02 20:16:55', '2026-07-02 20:10:56', '2026-07-03 10:54:28');
INSERT INTO `rp_order` VALUES (26, 'RP202607020002', 2, 1, 2, 'aaa', 'urgent', 'cancelled', NULL, 0, 24, 0.00, 0.00, 0, '', '', '', '水管问题/水管漏水', 0, 1, NULL, '2026-07-02 20:26:48', '2026-07-03 10:54:28');
INSERT INTO `rp_order` VALUES (27, 'RP202607020003', 2, 1, NULL, '房间钥匙卡在门锁中', 'normal', 'assigned', 20, 0, 24, 0.00, 0.00, 0, '', '当前工单已满：aaa', 'AI拒单后自动改派', '其他故障', 0, 1, '2026-07-02 23:24:12', '2026-07-02 23:24:14', '2026-07-04 00:43:24');
INSERT INTO `rp_order` VALUES (28, 'RP202607030001', 39, NULL, 8, '家里突然停电了，但是电费还有，怀疑是电路跳闸,请尽快维修', 'urgent', 'wait_accept', 3, 0, 24, 0.00, 0.00, 0, '', '', 'AI系统自动派单', '电路问题/电路跳闸', 0, 0, '2026-07-03 23:54:06', '2026-07-03 23:34:36', '2026-07-03 23:34:36');
INSERT INTO `rp_order` VALUES (29, 'RP202607040001', 2, 1, 12, '电路老化，好像有问题，请派人来检查', 'normal', 'assigned', 3, 0, 24, 0.00, 0.00, 0, '', '', 'AI系统自动派单', '电路问题/线路老化/烧焦', 0, 1, '2026-07-04 11:02:31', '2026-07-04 11:02:33', '2026-07-04 11:02:33');

-- ----------------------------
-- Table structure for rp_order_eval
-- ----------------------------
DROP TABLE IF EXISTS `rp_order_eval`;
CREATE TABLE `rp_order_eval`  (
  `eval_id` bigint NOT NULL AUTO_INCREMENT COMMENT '评价主键',
  `order_id` bigint NOT NULL COMMENT '工单ID',
  `score` int NULL DEFAULT 5 COMMENT '评分1-5',
  `tags` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '评价标签',
  `content` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '评价内容',
  `appeal_status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '申诉：0无 1中 2通过 3驳回',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '评价时间',
  PRIMARY KEY (`eval_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '工单服务评价表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of rp_order_eval
-- ----------------------------
INSERT INTO `rp_order_eval` VALUES (1, 25, 5, '态度好,技术专业', '师傅很专业，并且来得很快', '0', '2026-07-02 20:33:15');
INSERT INTO `rp_order_eval` VALUES (2, 23, 3, '需要改进', '热水器水管漏水维修技术有待精进', '0', '2026-07-03 09:45:20');

-- ----------------------------
-- Table structure for rp_order_field_image
-- ----------------------------
DROP TABLE IF EXISTS `rp_order_field_image`;
CREATE TABLE `rp_order_field_image`  (
  `image_id` bigint NOT NULL AUTO_INCREMENT COMMENT '图片主键',
  `record_id` bigint NOT NULL COMMENT '现场记录ID',
  `image_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '图片地址',
  PRIMARY KEY (`image_id`) USING BTREE,
  INDEX `idx_record_id`(`record_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '维修工现场记录图片表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of rp_order_field_image
-- ----------------------------
INSERT INTO `rp_order_field_image` VALUES (1, 1, '/upload/repair/20260702/9efbe9b093274bf8994a0a793ff261dd.jpg');
INSERT INTO `rp_order_field_image` VALUES (2, 2, '/upload/repair/20260704/9d63ed0299ea47c2a11a0aad55e31be8.jpg');

-- ----------------------------
-- Table structure for rp_order_field_record
-- ----------------------------
DROP TABLE IF EXISTS `rp_order_field_record`;
CREATE TABLE `rp_order_field_record`  (
  `record_id` bigint NOT NULL AUTO_INCREMENT COMMENT '现场记录主键',
  `order_id` bigint NOT NULL COMMENT '工单ID',
  `worker_id` bigint NOT NULL COMMENT '维修工用户ID',
  `content` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '现场说明',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '0' COMMENT '0到场中 1已保存未完工 2已提交完工',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '到场时间',
  `submit_time` datetime NULL DEFAULT NULL COMMENT '提交完工时间',
  PRIMARY KEY (`record_id`) USING BTREE,
  INDEX `idx_order_id`(`order_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '维修工现场记录表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of rp_order_field_record
-- ----------------------------
INSERT INTO `rp_order_field_record` VALUES (1, 23, 3, '已完成维修', '2', '2026-07-02 23:23:01', '2026-07-02 23:28:10');
INSERT INTO `rp_order_field_record` VALUES (2, 28, 3, '已按步骤检查电源并修复', '2', '2026-07-04 00:06:24', '2026-07-04 00:07:19');

-- ----------------------------
-- Table structure for rp_order_image
-- ----------------------------
DROP TABLE IF EXISTS `rp_order_image`;
CREATE TABLE `rp_order_image`  (
  `image_id` bigint NOT NULL AUTO_INCREMENT COMMENT '图片主键',
  `order_id` bigint NOT NULL COMMENT '工单ID',
  `image_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '图片地址',
  PRIMARY KEY (`image_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '报修现场图片表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of rp_order_image
-- ----------------------------
INSERT INTO `rp_order_image` VALUES (1, 25, '/upload/repair/20260702/3c54e37d9ac84bec9114f08ea5d20cc3.jpg');
INSERT INTO `rp_order_image` VALUES (2, 26, '/upload/repair/20260702/d5481e5a202440b7ab457b2bcff1231b.jpg');
INSERT INTO `rp_order_image` VALUES (3, 29, '/upload/repair/20260704/fdfeaa7f1c624d42b3ccc192e98005c0.jpg');

-- ----------------------------
-- Table structure for rp_order_progress
-- ----------------------------
DROP TABLE IF EXISTS `rp_order_progress`;
CREATE TABLE `rp_order_progress`  (
  `progress_id` bigint NOT NULL AUTO_INCREMENT COMMENT '进度主键',
  `order_id` bigint NOT NULL COMMENT '工单ID',
  `node_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '节点名称',
  `operator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '操作人',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '备注',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '记录时间',
  PRIMARY KEY (`progress_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 105 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '工单进度节点表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of rp_order_progress
-- ----------------------------
INSERT INTO `rp_order_progress` VALUES (1, 1, '提交报修', '张三', '业主提交报修单', '2026-06-06 09:00:00');
INSERT INTO `rp_order_progress` VALUES (2, 1, 'AI智能分析', '智能引擎', '系统已自动分析故障类型与紧急程度', '2026-06-06 09:01:00');
INSERT INTO `rp_order_progress` VALUES (3, 1, '派单', '物业派单', '指派维修工：李师傅', '2026-06-06 10:00:00');
INSERT INTO `rp_order_progress` VALUES (4, 1, '完成维修', '李师傅', '维修完成待验收', '2026-06-06 14:00:00');
INSERT INTO `rp_order_progress` VALUES (5, 1, '验收完成', '张三', '业主已验收', '2026-06-06 15:00:00');
INSERT INTO `rp_order_progress` VALUES (6, 2, '提交报修', '李芳', '业主提交报修单', '2026-06-09 09:00:00');
INSERT INTO `rp_order_progress` VALUES (7, 2, 'AI智能分析', '智能引擎', '系统已自动分析故障类型与紧急程度', '2026-06-09 09:01:00');
INSERT INTO `rp_order_progress` VALUES (8, 2, '派单', '物业派单', '指派维修工：李师傅', '2026-06-09 10:00:00');
INSERT INTO `rp_order_progress` VALUES (9, 2, '完成维修', '李师傅', '维修完成待验收', '2026-06-09 14:00:00');
INSERT INTO `rp_order_progress` VALUES (10, 2, '验收完成', '李芳', '业主已验收', '2026-06-09 15:00:00');
INSERT INTO `rp_order_progress` VALUES (11, 10, '提交报修', '张三', '业主提交报修单', '2026-06-28 09:00:00');
INSERT INTO `rp_order_progress` VALUES (12, 10, 'AI智能分析', '智能引擎', '系统已自动分析故障类型与紧急程度', '2026-06-28 09:01:00');
INSERT INTO `rp_order_progress` VALUES (13, 10, '派单', '物业派单', '指派维修工：赵师傅', '2026-06-28 10:00:00');
INSERT INTO `rp_order_progress` VALUES (14, 22, '提交报修', '张三', '业主提交报修单', '2026-06-28 09:00:00');
INSERT INTO `rp_order_progress` VALUES (15, 22, 'AI智能分析', '智能引擎', '系统已自动分析故障类型与紧急程度', '2026-06-28 09:01:00');
INSERT INTO `rp_order_progress` VALUES (16, 22, '派单', '物业派单', '指派维修工：赵师傅', '2026-06-28 10:00:00');
INSERT INTO `rp_order_progress` VALUES (18, 25, '提交报修', '张三', '业主提交报修单', '2026-07-02 20:10:56');
INSERT INTO `rp_order_progress` VALUES (19, 25, 'AI智能分析', 'AI', 'AI识别：水管漏水，紧急程度=普通，重复报修', '2026-07-02 20:10:56');
INSERT INTO `rp_order_progress` VALUES (20, 22, '追加信息', '张三', '故障加重', '2026-07-02 20:16:29');
INSERT INTO `rp_order_progress` VALUES (21, 13, '提交报修', '张三', '业主提交报修单', '2026-06-06 09:00:00');
INSERT INTO `rp_order_progress` VALUES (22, 13, 'AI智能分析', '智能引擎', '系统已自动分析故障类型与紧急程度', '2026-06-06 09:01:00');
INSERT INTO `rp_order_progress` VALUES (23, 13, '派单', '物业派单', '指派维修工：李师傅', '2026-06-06 10:00:00');
INSERT INTO `rp_order_progress` VALUES (24, 13, '完成维修', '李师傅', '维修完成待验收', '2026-06-06 13:00:00');
INSERT INTO `rp_order_progress` VALUES (25, 13, '验收完成', '张三', '业主已验收', '2026-06-06 15:00:00');
INSERT INTO `rp_order_progress` VALUES (26, 25, '编辑报修', '张三', '业主修改报修信息', '2026-07-02 20:16:56');
INSERT INTO `rp_order_progress` VALUES (27, 25, 'AI智能分析', 'AI', 'AI识别：水管漏水，紧急程度=较急', '2026-07-02 20:16:56');
INSERT INTO `rp_order_progress` VALUES (28, 24, '提交报修', '王磊', '业主提交报修单', '2026-06-30 09:00:00');
INSERT INTO `rp_order_progress` VALUES (29, 24, 'AI智能分析', '智能引擎', '系统已自动分析故障类型与紧急程度', '2026-06-30 09:01:00');
INSERT INTO `rp_order_progress` VALUES (30, 24, '派单', '物业派单', '指派维修工：李师傅', '2026-06-30 10:00:00');
INSERT INTO `rp_order_progress` VALUES (31, 23, '提交报修', '李芳', '业主提交报修单', '2026-06-29 09:00:00');
INSERT INTO `rp_order_progress` VALUES (32, 23, 'AI智能分析', '智能引擎', '系统已自动分析故障类型与紧急程度', '2026-06-29 09:01:00');
INSERT INTO `rp_order_progress` VALUES (33, 23, '派单', '物业派单', '指派维修工：李师傅', '2026-06-29 10:00:00');
INSERT INTO `rp_order_progress` VALUES (34, 25, '接单', '李师傅', '维修工接单', '2026-07-02 20:18:16');
INSERT INTO `rp_order_progress` VALUES (35, 25, '完成维修', '李师傅', '维修完成待验收', '2026-07-02 20:18:25');
INSERT INTO `rp_order_progress` VALUES (36, 26, '提交报修', '张三', '业主提交报修单', '2026-07-02 20:26:48');
INSERT INTO `rp_order_progress` VALUES (37, 26, 'AI智能分析', 'AI', 'AI识别：其他故障，紧急程度=普通，重复报修', '2026-07-02 20:26:48');
INSERT INTO `rp_order_progress` VALUES (38, 25, '验收完成', '张三', '评分:5', '2026-07-02 20:33:15');
INSERT INTO `rp_order_progress` VALUES (39, 26, '取消报修', '张三', '业主取消', '2026-07-02 20:34:48');
INSERT INTO `rp_order_progress` VALUES (40, 24, '处理中', '3', '维修工已到场', '2026-07-02 22:40:20');
INSERT INTO `rp_order_progress` VALUES (41, 24, '完成维修', '李师傅', '维修完成待验收', '2026-07-02 22:41:49');
INSERT INTO `rp_order_progress` VALUES (42, 23, '处理中', '3', '维修工已到场', '2026-07-02 22:47:11');
INSERT INTO `rp_order_progress` VALUES (43, 18, '提交报修', '陈静', '业主提交报修单', '2026-06-19 09:00:00');
INSERT INTO `rp_order_progress` VALUES (44, 18, 'AI智能分析', '智能引擎', '系统已自动分析故障类型与紧急程度', '2026-06-19 09:01:00');
INSERT INTO `rp_order_progress` VALUES (45, 18, '派单', '物业派单', '指派维修工：李师傅', '2026-06-19 10:00:00');
INSERT INTO `rp_order_progress` VALUES (46, 23, '处理中', '3', '维修工已到场', '2026-07-02 22:52:43');
INSERT INTO `rp_order_progress` VALUES (47, 21, '提交报修', '吴刚', '业主提交报修单', '2026-06-26 09:00:00');
INSERT INTO `rp_order_progress` VALUES (48, 21, 'AI智能分析', '智能引擎', '系统已自动分析故障类型与紧急程度', '2026-06-26 09:01:00');
INSERT INTO `rp_order_progress` VALUES (49, 21, '派单', '物业派单', '指派维修工：李师傅', '2026-06-26 10:00:00');
INSERT INTO `rp_order_progress` VALUES (50, 21, '完成维修', '李师傅', '维修完成待验收', '2026-06-26 13:00:00');
INSERT INTO `rp_order_progress` VALUES (51, 21, '验收完成', '吴刚', '业主已验收', '2026-06-26 15:00:00');
INSERT INTO `rp_order_progress` VALUES (52, 17, '提交报修', '刘洋', '业主提交报修单', '2026-06-16 09:00:00');
INSERT INTO `rp_order_progress` VALUES (53, 17, 'AI智能分析', '智能引擎', '系统已自动分析故障类型与紧急程度', '2026-06-16 09:01:00');
INSERT INTO `rp_order_progress` VALUES (54, 17, '派单', '物业派单', '指派维修工：李师傅', '2026-06-16 10:00:00');
INSERT INTO `rp_order_progress` VALUES (55, 17, '完成维修', '李师傅', '维修完成待验收', '2026-06-16 13:00:00');
INSERT INTO `rp_order_progress` VALUES (56, 17, '验收完成', '刘洋', '业主已验收', '2026-06-16 15:00:00');
INSERT INTO `rp_order_progress` VALUES (57, 16, '提交报修', '赵敏', '业主提交报修单', '2026-06-13 09:00:00');
INSERT INTO `rp_order_progress` VALUES (58, 16, 'AI智能分析', '智能引擎', '系统已自动分析故障类型与紧急程度', '2026-06-13 09:01:00');
INSERT INTO `rp_order_progress` VALUES (59, 16, '派单', '物业派单', '指派维修工：李师傅', '2026-06-13 10:00:00');
INSERT INTO `rp_order_progress` VALUES (60, 16, '完成维修', '李师傅', '维修完成待验收', '2026-06-13 13:00:00');
INSERT INTO `rp_order_progress` VALUES (61, 16, '验收完成', '赵敏', '业主已验收', '2026-06-13 15:00:00');
INSERT INTO `rp_order_progress` VALUES (62, 23, '到场检查', '李师傅', '维修工已到达现场', '2026-07-02 23:23:01');
INSERT INTO `rp_order_progress` VALUES (63, 27, '提交报修', '张三', '业主提交报修单', '2026-07-02 23:24:13');
INSERT INTO `rp_order_progress` VALUES (64, 27, 'AI智能分析', 'AI', 'AI识别：其他故障，紧急程度=普通，重复报修', '2026-07-02 23:24:13');
INSERT INTO `rp_order_progress` VALUES (65, 27, '派单', 'AI', '指派维修工：孙师傅，原因：AI手动触发自动派单', '2026-07-02 23:24:50');
INSERT INTO `rp_order_progress` VALUES (66, 27, '待分配', '4', '重新分配', '2026-07-02 23:25:09');
INSERT INTO `rp_order_progress` VALUES (67, 27, '派单', '4', '指派维修工：李师傅', '2026-07-02 23:25:51');
INSERT INTO `rp_order_progress` VALUES (68, 23, '完成维修', '李师傅', '已完成维修', '2026-07-02 23:28:10');
INSERT INTO `rp_order_progress` VALUES (69, 19, '提交报修', '杨帆', '业主提交报修单', '2026-06-21 09:00:00');
INSERT INTO `rp_order_progress` VALUES (70, 19, 'AI智能分析', '智能引擎', '系统已自动分析故障类型与紧急程度', '2026-06-21 09:01:00');
INSERT INTO `rp_order_progress` VALUES (71, 19, '派单', '物业派单', '指派维修工：李师傅', '2026-06-21 10:00:00');
INSERT INTO `rp_order_progress` VALUES (72, 14, '提交报修', '李芳', '业主提交报修单', '2026-06-09 09:00:00');
INSERT INTO `rp_order_progress` VALUES (73, 14, 'AI智能分析', '智能引擎', '系统已自动分析故障类型与紧急程度', '2026-06-09 09:01:00');
INSERT INTO `rp_order_progress` VALUES (74, 14, '派单', '物业派单', '指派维修工：李师傅', '2026-06-09 10:00:00');
INSERT INTO `rp_order_progress` VALUES (75, 14, '完成维修', '李师傅', '维修完成待验收', '2026-06-09 13:00:00');
INSERT INTO `rp_order_progress` VALUES (76, 14, '验收完成', '李芳', '业主已验收', '2026-06-09 15:00:00');
INSERT INTO `rp_order_progress` VALUES (77, 23, '验收完成', '李芳', '评分:3', '2026-07-03 09:45:20');
INSERT INTO `rp_order_progress` VALUES (78, 15, '提交报修', '王磊', '业主提交报修单', '2026-06-11 09:00:00');
INSERT INTO `rp_order_progress` VALUES (79, 15, 'AI智能分析', '智能引擎', '系统已自动分析故障类型与紧急程度', '2026-06-11 09:01:00');
INSERT INTO `rp_order_progress` VALUES (80, 15, '派单', '物业派单', '指派维修工：李师傅', '2026-06-11 10:00:00');
INSERT INTO `rp_order_progress` VALUES (81, 15, '完成维修', '李师傅', '维修完成待验收', '2026-06-11 13:00:00');
INSERT INTO `rp_order_progress` VALUES (82, 15, '验收完成', '王磊', '业主已验收', '2026-06-11 15:00:00');
INSERT INTO `rp_order_progress` VALUES (83, 26, 'AI智能分析', 'AI', 'AI识别：水管问题/水管漏水，紧急程度=较急，重复报修', '2026-07-03 21:48:00');
INSERT INTO `rp_order_progress` VALUES (84, 20, '提交报修', '周婷', '业主提交报修单', '2026-06-23 09:00:00');
INSERT INTO `rp_order_progress` VALUES (85, 20, 'AI智能分析', '智能引擎', '系统已自动分析故障类型与紧急程度', '2026-06-23 09:01:00');
INSERT INTO `rp_order_progress` VALUES (86, 20, '派单', '物业派单', '指派维修工：孙师傅', '2026-06-23 10:00:00');
INSERT INTO `rp_order_progress` VALUES (87, 21, '调整工单', '4', '普通', '2026-07-03 22:05:57');
INSERT INTO `rp_order_progress` VALUES (88, 28, '提交报修', 'test01', '业主提交报修单', '2026-07-03 23:34:36');
INSERT INTO `rp_order_progress` VALUES (89, 28, 'AI智能分析', 'AI', 'AI识别：电路问题/电路跳闸，紧急程度=较急', '2026-07-03 23:34:36');
INSERT INTO `rp_order_progress` VALUES (90, 28, '派单', 'AI', '指派维修工：李师傅，原因：AI系统自动派单', '2026-07-03 23:34:36');
INSERT INTO `rp_order_progress` VALUES (91, 28, '编辑报修', 'test01', '业主修改报修信息', '2026-07-03 23:54:07');
INSERT INTO `rp_order_progress` VALUES (92, 28, 'AI智能分析', 'AI', 'AI识别：电路问题/电路跳闸，紧急程度=较急', '2026-07-03 23:54:07');
INSERT INTO `rp_order_progress` VALUES (93, 28, '接单', '李师傅', '维修工确认接单', '2026-07-04 00:06:04');
INSERT INTO `rp_order_progress` VALUES (94, 28, '到场检查', '李师傅', '维修工已到达现场', '2026-07-04 00:06:23');
INSERT INTO `rp_order_progress` VALUES (95, 28, '完成维修', '李师傅', '已按步骤检查电源并修复', '2026-07-04 00:07:19');
INSERT INTO `rp_order_progress` VALUES (96, 27, '拒单', '李师傅', '距离太远：离当前住户距离太远，请重新安排他人维修', '2026-07-04 00:08:12');
INSERT INTO `rp_order_progress` VALUES (97, 27, '派单', '4', '指派维修工：李师傅，原因：物业审核后改派', '2026-07-04 00:22:44');
INSERT INTO `rp_order_progress` VALUES (98, 27, '拒单', '李师傅', 'REJECT_WID:3|技能不匹配：技能不匹配', '2026-07-04 00:31:14');
INSERT INTO `rp_order_progress` VALUES (99, 27, '派单', '4', '指派维修工：李师傅，原因：测试', '2026-07-04 00:35:39');
INSERT INTO `rp_order_progress` VALUES (100, 27, '拒单', '李师傅', 'REJECT_WID:3|当前工单已满：aaa', '2026-07-04 00:43:24');
INSERT INTO `rp_order_progress` VALUES (101, 27, '派单', 'AI', '指派维修工：孙师傅，原因：AI拒单后自动改派', '2026-07-04 00:43:24');
INSERT INTO `rp_order_progress` VALUES (102, 29, '提交报修', '张三', '业主提交报修单', '2026-07-04 11:02:32');
INSERT INTO `rp_order_progress` VALUES (103, 29, 'AI智能分析', 'AI', 'AI识别：电路问题/线路老化/烧焦，紧急程度=普通，重复报修', '2026-07-04 11:02:32');
INSERT INTO `rp_order_progress` VALUES (104, 29, '派单', 'AI', '指派维修工：李师傅，原因：AI系统自动派单', '2026-07-04 11:02:32');

-- ----------------------------
-- Table structure for rp_repair_type
-- ----------------------------
DROP TABLE IF EXISTS `rp_repair_type`;
CREATE TABLE `rp_repair_type`  (
  `type_id` bigint NOT NULL AUTO_INCREMENT COMMENT '类型主键',
  `parent_id` bigint NULL DEFAULT 0 COMMENT '父级ID',
  `type_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '类型名称',
  `order_num` int NULL DEFAULT 0 COMMENT '排序',
  `keywords` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '典型关键词',
  PRIMARY KEY (`type_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 29 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '报修故障类型表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of rp_repair_type
-- ----------------------------
INSERT INTO `rp_repair_type` VALUES (1, 0, '水管问题', 1, '漏水,滴水,堵塞,下水慢,冒水,关不紧,不出水');
INSERT INTO `rp_repair_type` VALUES (2, 1, '水管漏水', 1, '');
INSERT INTO `rp_repair_type` VALUES (3, 1, '下水道堵塞', 2, '');
INSERT INTO `rp_repair_type` VALUES (4, 1, '水龙头/阀门损坏', 3, '');
INSERT INTO `rp_repair_type` VALUES (5, 1, '马桶/洁具故障', 4, '');
INSERT INTO `rp_repair_type` VALUES (6, 1, '热水器故障', 5, '');
INSERT INTO `rp_repair_type` VALUES (7, 0, '电路问题', 2, '跳闸,断电,没电,冒火花,烧焦味,接触不良');
INSERT INTO `rp_repair_type` VALUES (8, 7, '电路跳闸', 1, '');
INSERT INTO `rp_repair_type` VALUES (9, 7, '插座/开关损坏', 2, '');
INSERT INTO `rp_repair_type` VALUES (10, 7, '灯具照明故障', 3, '');
INSERT INTO `rp_repair_type` VALUES (11, 7, '配电箱/电表异常', 4, '');
INSERT INTO `rp_repair_type` VALUES (12, 7, '线路老化/烧焦', 5, '');
INSERT INTO `rp_repair_type` VALUES (13, 0, '家电问题', 3, '不制冷,不启动,噪音大,门打不开,无法联网');
INSERT INTO `rp_repair_type` VALUES (14, 13, '空调故障', 1, '');
INSERT INTO `rp_repair_type` VALUES (15, 13, '冰箱/冰柜故障', 2, '');
INSERT INTO `rp_repair_type` VALUES (16, 13, '洗衣机/烘干机故障', 3, '');
INSERT INTO `rp_repair_type` VALUES (17, 13, '烟机/灶具故障', 4, '');
INSERT INTO `rp_repair_type` VALUES (18, 13, '智能门锁/门禁故障', 5, '');
INSERT INTO `rp_repair_type` VALUES (19, 0, '房屋问题', 4, '关不上,打不开,裂缝,空鼓,掉皮,发霉');
INSERT INTO `rp_repair_type` VALUES (20, 19, '门窗/锁具损坏', 1, '');
INSERT INTO `rp_repair_type` VALUES (21, 19, '墙面/地面破损', 2, '');
INSERT INTO `rp_repair_type` VALUES (22, 19, '吊顶/柜子松动', 3, '');
INSERT INTO `rp_repair_type` VALUES (23, 19, '防水层渗漏', 4, '');
INSERT INTO `rp_repair_type` VALUES (24, 0, '公共问题', 5, '电梯异响,停机,网连不上,没信号,灯不亮');
INSERT INTO `rp_repair_type` VALUES (25, 24, '电梯故障', 1, '');
INSERT INTO `rp_repair_type` VALUES (26, 24, '网络/电视/信号故障', 2, '');
INSERT INTO `rp_repair_type` VALUES (27, 24, '监控/道闸故障', 3, '');
INSERT INTO `rp_repair_type` VALUES (28, 24, '公区照明故障', 4, '');

-- ----------------------------
-- Table structure for rp_repair_weekly_report
-- ----------------------------
DROP TABLE IF EXISTS `rp_repair_weekly_report`;
CREATE TABLE `rp_repair_weekly_report`  (
  `report_id` bigint NOT NULL AUTO_INCREMENT,
  `week_start` date NOT NULL,
  `week_end` date NOT NULL,
  `total_orders` int NULL DEFAULT 0,
  `avg_complete_hours` decimal(10, 2) NULL DEFAULT 0.00,
  `overtime_rate` decimal(10, 2) NULL DEFAULT 0.00,
  `duplicate_rate` decimal(10, 2) NULL DEFAULT 0.00,
  `good_rate` decimal(10, 2) NULL DEFAULT 0.00,
  `type_stats` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL,
  `worker_stats` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL,
  `suggestions` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL,
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`report_id`) USING BTREE,
  INDEX `idx_week_start`(`week_start` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '工单复盘周报' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of rp_repair_weekly_report
-- ----------------------------
INSERT INTO `rp_repair_weekly_report` VALUES (1, '2026-06-22', '2026-06-28', 3, 6.00, 0.00, 0.00, 0.00, '[{\"name\":\"公区照明故障\",\"total\":1,\"completed\":0,\"avgHours\":null},{\"name\":\"水管漏水\",\"total\":1,\"completed\":1,\"avgHours\":6.00},{\"name\":\"空调故障\",\"total\":1,\"completed\":0,\"avgHours\":null}]', '[{\"workerId\":20,\"name\":\"孙师傅\",\"assigned\":1,\"completed\":0,\"avgHours\":null},{\"workerId\":3,\"name\":\"李师傅\",\"assigned\":1,\"completed\":1,\"avgHours\":6.00},{\"workerId\":19,\"name\":\"赵师傅\",\"assigned\":1,\"completed\":0,\"avgHours\":null}]', '{\"highlights\":[\"维修工负载均衡，每位师傅均接单1单，工作分配合理\",\"无超时工单和重复报修，维修质量稳定\"],\"issues\":[\"工单完成率低，仅为33.33%，需提高工作效率\",\"好评率为0%，表明服务体验有待提升\"],\"suggestions\":[\"建立工单优先级机制，将紧急故障如水管漏水优先处理\",\"增加维修人员或优化排班制度，提高工单处理能力\",\"实施维修后回访制度，收集业主反馈并提高好评率\",\"建立维修知识库，针对常见故障提供标准化解决方案，减少处理时间\"]}', '2026-07-03 22:36:02');
INSERT INTO `rp_repair_weekly_report` VALUES (2, '2026-06-29', '2026-07-05', 5, 48.56, 50.00, 40.00, 50.00, '[{\"name\":\"水管漏水\",\"total\":2,\"completed\":2,\"avgHours\":48.56},{\"name\":\"线路老化/烧焦\",\"total\":1,\"completed\":0,\"avgHours\":null},{\"name\":\"水管问题/水管漏水\",\"total\":1,\"completed\":0,\"avgHours\":null},{\"name\":\"其他故障\",\"total\":1,\"completed\":0,\"avgHours\":null}]', '[{\"workerId\":3,\"name\":\"李师傅\",\"assigned\":4,\"completed\":2,\"avgHours\":48.56}]', '{\"highlights\":[\"维修工李师傅工作积极，承担了80%的工单量\",\"平均完成时长48.56小时在可接受范围内\"],\"issues\":[\"工单完成率仅为40%，效率有待提高\",\"超时率高达50%，严重影响业主满意度\",\"重复报修率40%，表明维修质量存在问题\",\"好评率仅50%，业主体验不佳\"],\"suggestions\":[\"建立维修工轮班制度，避免单一维修工过载\",\"优化工单分配机制，根据维修工专长分配相应类型工单\",\"加强维修后质量检查，降低重复报修率\",\"设置维修时限预警系统，提前提醒即将超时的工单\",\"建立维修工绩效考核机制，将完成率、超时率和好评率纳入考核\",\"定期组织维修技能培训，特别是针对水管漏水等高频问题\"]}', '2026-07-03 22:36:16');

-- ----------------------------
-- Table structure for rp_worker_certificate
-- ----------------------------
DROP TABLE IF EXISTS `rp_worker_certificate`;
CREATE TABLE `rp_worker_certificate`  (
  `cert_id` bigint NOT NULL AUTO_INCREMENT COMMENT '证书主键',
  `worker_id` bigint NOT NULL COMMENT '维修工用户ID',
  `cert_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '证书名称',
  `cert_expire` date NULL DEFAULT NULL COMMENT '有效期',
  `related_skill` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '关联技能',
  `apply_remark` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '申请说明',
  `audit_status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '1' COMMENT '审核状态',
  `audit_remark` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '审核意见',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '提交时间',
  PRIMARY KEY (`cert_id`) USING BTREE,
  INDEX `idx_worker_cert`(`worker_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 9 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '维修工证书表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of rp_worker_certificate
-- ----------------------------
INSERT INTO `rp_worker_certificate` VALUES (1, 3, '电工操作证', '2030-08-08', '', '历史数据迁移', '1', '', '2026-07-03 11:10:58');
INSERT INTO `rp_worker_certificate` VALUES (2, 19, '管道工证', NULL, '', '历史数据迁移', '1', '', '2026-07-03 11:10:58');
INSERT INTO `rp_worker_certificate` VALUES (3, 20, '家电维修证', NULL, '', '历史数据迁移', '1', '', '2026-07-03 11:10:58');
INSERT INTO `rp_worker_certificate` VALUES (4, 21, '弱电工程师证', NULL, '', '历史数据迁移', '1', '', '2026-07-03 11:10:58');
INSERT INTO `rp_worker_certificate` VALUES (5, 22, '综合维修证', NULL, '', '历史数据迁移', '1', '', '2026-07-03 11:10:58');
INSERT INTO `rp_worker_certificate` VALUES (8, 3, '管道工证', '2028-07-14', '管道疏通', '已于一年前成功获得管道工证书', '1', '', '2026-07-03 21:07:28');

-- ----------------------------
-- Table structure for rp_worker_profile
-- ----------------------------
DROP TABLE IF EXISTS `rp_worker_profile`;
CREATE TABLE `rp_worker_profile`  (
  `worker_id` bigint NOT NULL COMMENT '维修工用户ID',
  `real_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '姓名',
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '手机号',
  `gender` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '性别',
  `age` int NULL DEFAULT NULL COMMENT '年龄',
  `avatar` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '头像',
  `work_status` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'available' COMMENT '状态：available/busy/rest',
  `worker_level` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '初级' COMMENT '职级',
  `cert_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '证书名称',
  `cert_expire` date NULL DEFAULT NULL COMMENT '证书有效期',
  `cert_audit_status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '1' COMMENT '证书审核',
  `avg_score` decimal(3, 2) NULL DEFAULT 5.00 COMMENT '平均评分',
  `eval_count` int NULL DEFAULT 0 COMMENT '评价数',
  PRIMARY KEY (`worker_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '维修工档案表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of rp_worker_profile
-- ----------------------------
INSERT INTO `rp_worker_profile` VALUES (3, '李师傅', '13800000002', '0', 42, '', 'available', '高级', '电工操作证', '2028-07-20', '0', 4.85, 12);
INSERT INTO `rp_worker_profile` VALUES (19, '赵师傅', '13820000001', '0', 38, '', 'busy', '中级', '管道工证', NULL, '1', 4.72, 8);
INSERT INTO `rp_worker_profile` VALUES (20, '孙师傅', '13820000002', '0', 45, '', 'available', '中级', '家电维修证', NULL, '1', 4.90, 15);
INSERT INTO `rp_worker_profile` VALUES (21, '周师傅', '13820000003', '1', 36, '', 'available', '初级', '弱电工程师证', NULL, '1', 4.68, 6);
INSERT INTO `rp_worker_profile` VALUES (22, '吴师傅', '13820000004', '0', 50, '', 'available', '初级', '综合维修证', NULL, '1', 4.55, 4);
INSERT INTO `rp_worker_profile` VALUES (23, '冯师傅', '13122675566', '', NULL, '', 'available', '初级', '', NULL, '1', 5.00, 0);

-- ----------------------------
-- Table structure for rp_worker_skill
-- ----------------------------
DROP TABLE IF EXISTS `rp_worker_skill`;
CREATE TABLE `rp_worker_skill`  (
  `skill_id` bigint NOT NULL AUTO_INCREMENT COMMENT '技能主键',
  `worker_id` bigint NOT NULL COMMENT '维修工用户ID',
  `skill_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '技能名称',
  `skill_level` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '初级' COMMENT '技能等级：初级/中级/高级/专家',
  `audit_status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '1' COMMENT '审核状态',
  `apply_remark` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '申请说明',
  `audit_remark` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '审核意见',
  PRIMARY KEY (`skill_id`) USING BTREE,
  INDEX `idx_worker`(`worker_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 18 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '维修工技能标签表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of rp_worker_skill
-- ----------------------------
INSERT INTO `rp_worker_skill` VALUES (5, 3, '水电维修', '高级', '1', '', '');
INSERT INTO `rp_worker_skill` VALUES (6, 3, '管道疏通', '中级', '1', '', '');
INSERT INTO `rp_worker_skill` VALUES (7, 3, '电路检修', '专家', '1', '', '');
INSERT INTO `rp_worker_skill` VALUES (8, 3, '空调维修', '初级', '1', '', '');
INSERT INTO `rp_worker_skill` VALUES (9, 19, '管道疏通', '高级', '1', '', '');
INSERT INTO `rp_worker_skill` VALUES (10, 19, '卫浴安装', '中级', '1', '', '');
INSERT INTO `rp_worker_skill` VALUES (11, 20, '家电维修', '专家', '1', '', '');
INSERT INTO `rp_worker_skill` VALUES (12, 20, '空调维修', '高级', '1', '', '');
INSERT INTO `rp_worker_skill` VALUES (13, 21, '网络布线', '高级', '1', '', '');
INSERT INTO `rp_worker_skill` VALUES (14, 21, '监控安装', '中级', '1', '', '');
INSERT INTO `rp_worker_skill` VALUES (15, 22, '门窗维修', '中级', '1', '', '');
INSERT INTO `rp_worker_skill` VALUES (16, 22, '综合维保', '初级', '1', '', '');
INSERT INTO `rp_worker_skill` VALUES (17, 3, '水管维修', '中级', '1', '', '');

-- ----------------------------
-- Table structure for sys_config
-- ----------------------------
DROP TABLE IF EXISTS `sys_config`;
CREATE TABLE `sys_config`  (
  `config_id` int NOT NULL AUTO_INCREMENT COMMENT '参数主键',
  `config_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '参数名称',
  `config_key` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '参数键',
  `config_value` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '参数值',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '备注',
  PRIMARY KEY (`config_id`) USING BTREE,
  UNIQUE INDEX `uk_config_key`(`config_key` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 6 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '系统参数配置表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_config
-- ----------------------------
INSERT INTO `sys_config` VALUES (1, '消息撤回时长(分钟)', 'msg.recall.minutes', '2', '消息撤回有效时长');
INSERT INTO `sys_config` VALUES (2, '日志保留天数', 'log.retain.days', '90', '自动清理历史日志');
INSERT INTO `sys_config` VALUES (3, '催单升级次数', 'order.urge.max', '3', '累计催单触发升级');
INSERT INTO `sys_config` VALUES (4, '工单超时小时', 'order.timeout.hours', '24', '工单未处理超时小时');
INSERT INTO `sys_config` VALUES (5, '报修自动派单', 'repair.auto.dispatch', 'true', '业主提交报修后，AI分析完成时是否自动派单（false=待物业分配）');

-- ----------------------------
-- Table structure for sys_login_log
-- ----------------------------
DROP TABLE IF EXISTS `sys_login_log`;
CREATE TABLE `sys_login_log`  (
  `log_id` bigint NOT NULL AUTO_INCREMENT COMMENT '日志主键',
  `username` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '登录账号',
  `ipaddr` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '登录IP',
  `device` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '设备标识',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '结果：0成功 1失败',
  `msg` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '提示信息',
  `login_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '登录时间',
  PRIMARY KEY (`log_id`) USING BTREE,
  INDEX `idx_username_time`(`username` ASC, `login_time` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 56 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '用户登录日志表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_login_log
-- ----------------------------
INSERT INTO `sys_login_log` VALUES (1, 'admin', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36 Edg/145.0.0.0', '0', '登录成功', '2026-05-17 18:17:16');
INSERT INTO `sys_login_log` VALUES (2, 'property', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36 Edg/145.0.0.0', '1', '账号或密码错误', '2026-05-17 18:17:36');
INSERT INTO `sys_login_log` VALUES (3, 'property01', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36 Edg/145.0.0.0', '0', '登录成功', '2026-05-17 18:17:44');
INSERT INTO `sys_login_log` VALUES (4, 'owner01', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36 Edg/145.0.0.0', '0', '登录成功', '2026-05-17 18:29:17');
INSERT INTO `sys_login_log` VALUES (5, 'property01', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36 Edg/145.0.0.0', '0', '登录成功', '2026-05-17 18:32:06');
INSERT INTO `sys_login_log` VALUES (6, 'owner02', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36 Edg/145.0.0.0', '0', '登录成功', '2026-05-17 18:35:30');
INSERT INTO `sys_login_log` VALUES (7, 'property01', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36 Edg/145.0.0.0', '0', '登录成功', '2026-05-17 18:44:41');
INSERT INTO `sys_login_log` VALUES (8, 'owner02', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36 Edg/145.0.0.0', '0', '登录成功', '2026-05-17 18:46:00');
INSERT INTO `sys_login_log` VALUES (9, 'owner01', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36 Edg/145.0.0.0', '0', '登录成功', '2026-05-19 15:32:21');
INSERT INTO `sys_login_log` VALUES (10, 'property01', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36 Edg/145.0.0.0', '0', '登录成功', '2026-05-19 15:53:07');
INSERT INTO `sys_login_log` VALUES (11, 'property01', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36 Edg/145.0.0.0', '0', '登录成功', '2026-06-24 16:34:42');
INSERT INTO `sys_login_log` VALUES (12, 'owner01', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36 Edg/145.0.0.0', '0', '登录成功', '2026-06-24 16:35:36');
INSERT INTO `sys_login_log` VALUES (13, 'worker01', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36 Edg/145.0.0.0', '0', '登录成功', '2026-07-02 20:17:37');
INSERT INTO `sys_login_log` VALUES (14, 'owner01', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36 Edg/145.0.0.0', '0', '登录成功', '2026-07-02 20:18:36');
INSERT INTO `sys_login_log` VALUES (15, 'owner01', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36 Edg/145.0.0.0', '0', '登录成功', '2026-07-02 21:31:18');
INSERT INTO `sys_login_log` VALUES (16, 'worker01', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36 Edg/145.0.0.0', '0', '登录成功', '2026-07-02 22:00:15');
INSERT INTO `sys_login_log` VALUES (17, 'property01', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36 Edg/145.0.0.0', '0', '登录成功', '2026-07-02 22:49:08');
INSERT INTO `sys_login_log` VALUES (18, 'worker01', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36 Edg/145.0.0.0', '0', '登录成功', '2026-07-02 22:50:10');
INSERT INTO `sys_login_log` VALUES (19, 'owner01', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36 Edg/145.0.0.0', '0', '登录成功', '2026-07-02 23:01:49');
INSERT INTO `sys_login_log` VALUES (20, 'worker01', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36 Edg/145.0.0.0', '0', '登录成功', '2026-07-02 23:10:17');
INSERT INTO `sys_login_log` VALUES (21, 'owner01', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36 Edg/145.0.0.0', '0', '登录成功', '2026-07-02 23:23:43');
INSERT INTO `sys_login_log` VALUES (22, 'property01', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36 Edg/145.0.0.0', '0', '登录成功', '2026-07-02 23:24:32');
INSERT INTO `sys_login_log` VALUES (23, 'worker01', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36 Edg/145.0.0.0', '0', '登录成功', '2026-07-02 23:26:04');
INSERT INTO `sys_login_log` VALUES (24, 'worker01', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36 Edg/145.0.0.0', '0', '登录成功', '2026-07-03 09:39:22');
INSERT INTO `sys_login_log` VALUES (25, 'owner02', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36 Edg/145.0.0.0', '0', '登录成功', '2026-07-03 09:40:42');
INSERT INTO `sys_login_log` VALUES (26, 'worker01', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36 Edg/145.0.0.0', '0', '登录成功', '2026-07-03 09:45:37');
INSERT INTO `sys_login_log` VALUES (27, 'property01', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36 Edg/145.0.0.0', '0', '登录成功', '2026-07-03 11:18:28');
INSERT INTO `sys_login_log` VALUES (28, 'property01', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36 Edg/145.0.0.0', '0', '登录成功', '2026-07-03 11:28:37');
INSERT INTO `sys_login_log` VALUES (29, 'property01', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36 Edg/145.0.0.0', '0', '登录成功', '2026-07-03 17:45:07');
INSERT INTO `sys_login_log` VALUES (30, 'property01', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36 Edg/145.0.0.0', '0', '登录成功', '2026-07-03 19:43:07');
INSERT INTO `sys_login_log` VALUES (31, 'owner01', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36 Edg/145.0.0.0', '0', '登录成功', '2026-07-03 20:13:11');
INSERT INTO `sys_login_log` VALUES (32, 'property01', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36 Edg/145.0.0.0', '0', '登录成功', '2026-07-03 20:13:33');
INSERT INTO `sys_login_log` VALUES (33, 'property01', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36 Edg/145.0.0.0', '0', '登录成功', '2026-07-03 21:03:55');
INSERT INTO `sys_login_log` VALUES (34, 'worker01', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36 Edg/145.0.0.0', '0', '登录成功', '2026-07-03 21:06:35');
INSERT INTO `sys_login_log` VALUES (35, 'property01', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36 Edg/145.0.0.0', '0', '登录成功', '2026-07-03 21:07:41');
INSERT INTO `sys_login_log` VALUES (36, 'property01', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36 Edg/145.0.0.0', '0', '登录成功', '2026-07-03 23:09:28');
INSERT INTO `sys_login_log` VALUES (37, 'test01', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36 Edg/145.0.0.0', '0', '登录成功', '2026-07-03 23:33:16');
INSERT INTO `sys_login_log` VALUES (38, 'property01', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36 Edg/145.0.0.0', '0', '登录成功', '2026-07-03 23:44:29');
INSERT INTO `sys_login_log` VALUES (39, 'test01', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36 Edg/145.0.0.0', '0', '登录成功', '2026-07-03 23:45:48');
INSERT INTO `sys_login_log` VALUES (40, 'test01', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36 Edg/145.0.0.0', '0', '登录成功', '2026-07-03 23:55:26');
INSERT INTO `sys_login_log` VALUES (41, 'test02', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36 Edg/145.0.0.0', '0', '登录成功', '2026-07-03 23:59:18');
INSERT INTO `sys_login_log` VALUES (42, 'property01', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36 Edg/145.0.0.0', '0', '登录成功', '2026-07-04 00:00:33');
INSERT INTO `sys_login_log` VALUES (43, 'worker01', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36 Edg/145.0.0.0', '0', '登录成功', '2026-07-04 00:06:01');
INSERT INTO `sys_login_log` VALUES (44, 'property01', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36 Edg/145.0.0.0', '0', '登录成功', '2026-07-04 00:08:38');
INSERT INTO `sys_login_log` VALUES (45, 'test02', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36 Edg/145.0.0.0', '0', '登录成功', '2026-07-04 00:23:18');
INSERT INTO `sys_login_log` VALUES (46, 'test03', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36 Edg/145.0.0.0', '0', '登录成功', '2026-07-04 00:24:34');
INSERT INTO `sys_login_log` VALUES (47, 'test02', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36 Edg/145.0.0.0', '0', '登录成功', '2026-07-04 00:29:50');
INSERT INTO `sys_login_log` VALUES (48, 'worker01', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36 Edg/145.0.0.0', '0', '登录成功', '2026-07-04 00:30:42');
INSERT INTO `sys_login_log` VALUES (49, 'property01', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36 Edg/145.0.0.0', '0', '登录成功', '2026-07-04 00:31:30');
INSERT INTO `sys_login_log` VALUES (50, 'worker01', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36 Edg/145.0.0.0', '0', '登录成功', '2026-07-04 00:35:52');
INSERT INTO `sys_login_log` VALUES (51, 'property01', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36 Edg/145.0.0.0', '0', '登录成功', '2026-07-04 00:43:36');
INSERT INTO `sys_login_log` VALUES (52, 'property01', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36 Edg/145.0.0.0', '0', '登录成功', '2026-07-04 10:43:34');
INSERT INTO `sys_login_log` VALUES (53, 'owner01', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36 Edg/145.0.0.0', '0', '登录成功', '2026-07-04 11:00:26');
INSERT INTO `sys_login_log` VALUES (54, 'owner01', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36 Edg/145.0.0.0', '0', '登录成功', '2026-07-04 11:02:48');
INSERT INTO `sys_login_log` VALUES (55, 'property01', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36 Edg/145.0.0.0', '0', '登录成功', '2026-07-04 11:03:04');

-- ----------------------------
-- Table structure for sys_menu
-- ----------------------------
DROP TABLE IF EXISTS `sys_menu`;
CREATE TABLE `sys_menu`  (
  `menu_id` bigint NOT NULL AUTO_INCREMENT,
  `parent_id` bigint NULL DEFAULT 0,
  `menu_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `path` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '',
  `component` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '',
  `perms` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '',
  `menu_type` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT 'M' COMMENT 'M目录 C菜单 F按钮',
  `icon` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '',
  `order_num` int NULL DEFAULT 0,
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '0',
  PRIMARY KEY (`menu_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '菜单权限' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_menu
-- ----------------------------

-- ----------------------------
-- Table structure for sys_message
-- ----------------------------
DROP TABLE IF EXISTS `sys_message`;
CREATE TABLE `sys_message`  (
  `message_id` bigint NOT NULL AUTO_INCREMENT COMMENT '消息主键',
  `msg_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '类型：order/alert/notice/fee/system',
  `title` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '标题',
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '正文',
  `priority` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'normal' COMMENT '优先级：urgent/normal',
  `sender_id` bigint NULL DEFAULT NULL COMMENT '发送人ID',
  `biz_id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '关联业务ID',
  `valid_start` datetime NULL DEFAULT NULL COMMENT '有效开始',
  `valid_end` datetime NULL DEFAULT NULL COMMENT '有效结束',
  `recalled` tinyint NULL DEFAULT 0 COMMENT '是否撤回：0否 1是',
  `recall_time` datetime NULL DEFAULT NULL COMMENT '撤回时间',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '??????',
  PRIMARY KEY (`message_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 23 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '统一消息表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_message
-- ----------------------------
INSERT INTO `sys_message` VALUES (1, 'order', '报修信息更新', '工单RP202606100001业主追加了新情况，请及时查看', 'normal', NULL, '', NULL, NULL, 0, NULL, '2026-07-02 20:16:29', '2026-07-02 20:16:29');
INSERT INTO `sys_message` VALUES (2, 'order', '维修工已接单', '工单RP202607022010565851维修工已接单处理', 'normal', NULL, '', NULL, NULL, 0, NULL, '2026-07-02 20:18:17', '2026-07-02 20:18:16');
INSERT INTO `sys_message` VALUES (3, 'order', '待验收', '工单RP202607022010565851已完成维修，请验收评价', 'normal', NULL, '', NULL, NULL, 0, NULL, '2026-07-02 20:18:25', '2026-07-02 20:18:25');
INSERT INTO `sys_message` VALUES (4, 'order', '待验收', '工单RP202606120001已完成维修，请验收评价', 'normal', NULL, '24', NULL, NULL, 0, NULL, '2026-07-02 22:41:50', '2026-07-02 22:41:49');
INSERT INTO `sys_message` VALUES (5, 'order', '工单已派单', '工单RP202607022324132135已指派维修人员', 'normal', NULL, '27', NULL, NULL, 0, NULL, '2026-07-02 23:24:51', '2026-07-02 23:24:50');
INSERT INTO `sys_message` VALUES (6, 'order', '系统派单', '您有一个新的工单需要处理', 'normal', NULL, '27', NULL, NULL, 0, NULL, '2026-07-02 23:24:51', '2026-07-02 23:24:50');
INSERT INTO `sys_message` VALUES (7, 'order', '工单已派单', '工单RP202607022324132135已指派维修人员', 'normal', NULL, '27', NULL, NULL, 0, NULL, '2026-07-02 23:25:51', '2026-07-02 23:25:51');
INSERT INTO `sys_message` VALUES (8, 'order', '系统派单', '您有一个新的工单需要处理', 'normal', NULL, '27', NULL, NULL, 0, NULL, '2026-07-02 23:25:51', '2026-07-02 23:25:51');
INSERT INTO `sys_message` VALUES (9, 'order', '待验收', '工单RP202606110001已完成维修，请验收评价', 'normal', NULL, '23', NULL, NULL, 0, NULL, '2026-07-02 23:28:10', '2026-07-02 23:28:10');
INSERT INTO `sys_message` VALUES (10, 'order', '业主验收评价', '工单 #RP202606110001 的业主已完成验收评价，评分：3', 'normal', NULL, '23', NULL, NULL, 0, NULL, '2026-07-03 09:45:21', '2026-07-03 09:45:20');
INSERT INTO `sys_message` VALUES (11, 'order', '工单已派单', '工单RP202607030001已指派维修人员', 'normal', NULL, '28', NULL, NULL, 0, NULL, '2026-07-03 23:34:36', '2026-07-03 23:34:36');
INSERT INTO `sys_message` VALUES (12, 'order', '系统派单', '您有一个新的工单需要处理', 'normal', NULL, '28', NULL, NULL, 0, NULL, '2026-07-03 23:34:36', '2026-07-03 23:34:36');
INSERT INTO `sys_message` VALUES (13, 'order', '维修工已接单', '工单RP202607030001维修工已接单处理', 'normal', NULL, '28', NULL, NULL, 0, NULL, '2026-07-04 00:06:05', '2026-07-04 00:06:04');
INSERT INTO `sys_message` VALUES (14, 'order', '待验收', '工单RP202607030001已完成维修，请验收评价', 'normal', NULL, '28', NULL, NULL, 0, NULL, '2026-07-04 00:07:19', '2026-07-04 00:07:19');
INSERT INTO `sys_message` VALUES (15, 'order', '工单已派单', '工单RP202607020003已指派维修人员', 'normal', NULL, '27', NULL, NULL, 0, NULL, '2026-07-04 00:22:45', '2026-07-04 00:22:44');
INSERT INTO `sys_message` VALUES (16, 'order', '系统派单', '您有一个新的工单需要处理', 'normal', NULL, '27', NULL, NULL, 0, NULL, '2026-07-04 00:22:45', '2026-07-04 00:22:44');
INSERT INTO `sys_message` VALUES (17, 'order', '工单已派单', '工单RP202607020003已指派维修人员', 'normal', NULL, '27', NULL, NULL, 0, NULL, '2026-07-04 00:35:40', '2026-07-04 00:35:39');
INSERT INTO `sys_message` VALUES (18, 'order', '系统派单', '您有一个新的工单需要处理', 'normal', NULL, '27', NULL, NULL, 0, NULL, '2026-07-04 00:35:40', '2026-07-04 00:35:39');
INSERT INTO `sys_message` VALUES (19, 'order', '工单已派单', '工单RP202607020003已指派维修人员', 'normal', NULL, '27', NULL, NULL, 0, NULL, '2026-07-04 00:43:25', '2026-07-04 00:43:24');
INSERT INTO `sys_message` VALUES (20, 'order', '系统派单', '您有一个新的工单需要处理', 'normal', NULL, '27', NULL, NULL, 0, NULL, '2026-07-04 00:43:25', '2026-07-04 00:43:24');
INSERT INTO `sys_message` VALUES (21, 'order', '工单已派单', '工单RP202607040001已指派维修人员', 'normal', NULL, '29', NULL, NULL, 0, NULL, '2026-07-04 11:02:33', '2026-07-04 11:02:32');
INSERT INTO `sys_message` VALUES (22, 'order', '系统派单', '您有一个新的工单需要处理', 'normal', NULL, '29', NULL, NULL, 0, NULL, '2026-07-04 11:02:33', '2026-07-04 11:02:32');

-- ----------------------------
-- Table structure for sys_message_user
-- ----------------------------
DROP TABLE IF EXISTS `sys_message_user`;
CREATE TABLE `sys_message_user`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `message_id` bigint NOT NULL COMMENT '消息ID',
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `read_flag` tinyint NULL DEFAULT 0 COMMENT '已读：0否 1是',
  `read_time` datetime NULL DEFAULT NULL COMMENT '阅读时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_msg_user`(`message_id` ASC, `user_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 23 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '用户消息已读状态表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_message_user
-- ----------------------------
INSERT INTO `sys_message_user` VALUES (1, 1, 19, 0, NULL);
INSERT INTO `sys_message_user` VALUES (2, 2, 2, 0, NULL);
INSERT INTO `sys_message_user` VALUES (3, 3, 2, 0, NULL);
INSERT INTO `sys_message_user` VALUES (4, 4, 6, 0, NULL);
INSERT INTO `sys_message_user` VALUES (5, 5, 2, 0, NULL);
INSERT INTO `sys_message_user` VALUES (6, 6, 20, 0, NULL);
INSERT INTO `sys_message_user` VALUES (7, 7, 2, 0, NULL);
INSERT INTO `sys_message_user` VALUES (8, 8, 3, 1, '2026-07-02 23:26:05');
INSERT INTO `sys_message_user` VALUES (9, 9, 5, 0, NULL);
INSERT INTO `sys_message_user` VALUES (10, 10, 3, 1, '2026-07-03 09:45:42');
INSERT INTO `sys_message_user` VALUES (11, 11, 39, 0, NULL);
INSERT INTO `sys_message_user` VALUES (12, 12, 3, 1, '2026-07-04 00:06:03');
INSERT INTO `sys_message_user` VALUES (13, 13, 39, 0, NULL);
INSERT INTO `sys_message_user` VALUES (14, 14, 39, 0, NULL);
INSERT INTO `sys_message_user` VALUES (15, 15, 2, 0, NULL);
INSERT INTO `sys_message_user` VALUES (16, 16, 3, 1, '2026-07-04 00:30:44');
INSERT INTO `sys_message_user` VALUES (17, 17, 2, 0, NULL);
INSERT INTO `sys_message_user` VALUES (18, 18, 3, 1, '2026-07-04 00:35:54');
INSERT INTO `sys_message_user` VALUES (19, 19, 2, 0, NULL);
INSERT INTO `sys_message_user` VALUES (20, 20, 20, 0, NULL);
INSERT INTO `sys_message_user` VALUES (21, 21, 2, 0, NULL);
INSERT INTO `sys_message_user` VALUES (22, 22, 3, 0, NULL);

-- ----------------------------
-- Table structure for sys_owner_account
-- ----------------------------
DROP TABLE IF EXISTS `sys_owner_account`;
CREATE TABLE `sys_owner_account`  (
  `account_id` bigint NOT NULL AUTO_INCREMENT COMMENT '业主账号ID',
  `username` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '登录账号',
  `password` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'BCrypt密码',
  `resident_id` bigint NULL DEFAULT NULL COMMENT '关联住户档案ID',
  `bind_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '待绑定姓名',
  `bind_phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '待绑定手机号',
  `bind_gender` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '待绑定性别',
  `bind_age` int NULL DEFAULT NULL COMMENT '待绑定年龄',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '0正常 1停用',
  `del_flag` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '0存在 2删除',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`account_id`) USING BTREE,
  UNIQUE INDEX `uk_owner_username`(`username` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 42 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '业主登录账号表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_owner_account
-- ----------------------------
INSERT INTO `sys_owner_account` VALUES (2, 'owner01', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', 1, NULL, NULL, NULL, NULL, '0', '0', '2026-05-01 08:00:00', '2026-05-01 08:00:00');
INSERT INTO `sys_owner_account` VALUES (5, 'owner02', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', 2, NULL, NULL, NULL, NULL, '0', '0', '2026-05-01 08:00:00', '2026-05-01 08:00:00');
INSERT INTO `sys_owner_account` VALUES (6, 'owner03', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', 3, NULL, NULL, NULL, NULL, '0', '0', '2026-05-01 08:00:00', '2026-05-01 08:00:00');
INSERT INTO `sys_owner_account` VALUES (7, 'owner04', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', 4, NULL, NULL, NULL, NULL, '0', '0', '2026-05-01 08:00:00', '2026-05-01 08:00:00');
INSERT INTO `sys_owner_account` VALUES (8, 'owner05', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', 5, NULL, NULL, NULL, NULL, '0', '0', '2026-05-01 08:00:00', '2026-05-01 08:00:00');
INSERT INTO `sys_owner_account` VALUES (9, 'owner06', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', 6, NULL, NULL, NULL, NULL, '0', '0', '2026-05-01 08:00:00', '2026-05-01 08:00:00');
INSERT INTO `sys_owner_account` VALUES (10, 'owner07', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', 7, NULL, NULL, NULL, NULL, '0', '0', '2026-05-01 08:00:00', '2026-05-01 08:00:00');
INSERT INTO `sys_owner_account` VALUES (11, 'owner08', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', 8, NULL, NULL, NULL, NULL, '0', '0', '2026-05-01 08:00:00', '2026-05-01 08:00:00');
INSERT INTO `sys_owner_account` VALUES (12, 'owner09', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', 9, NULL, NULL, NULL, NULL, '0', '0', '2026-05-01 08:00:00', '2026-05-01 08:00:00');
INSERT INTO `sys_owner_account` VALUES (13, 'owner10', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', 10, NULL, NULL, NULL, NULL, '0', '0', '2026-05-01 08:00:00', '2026-05-01 08:00:00');
INSERT INTO `sys_owner_account` VALUES (14, 'owner11', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', 11, NULL, NULL, NULL, NULL, '0', '0', '2026-05-01 08:00:00', '2026-05-01 08:00:00');
INSERT INTO `sys_owner_account` VALUES (15, 'owner12', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', 12, NULL, NULL, NULL, NULL, '0', '0', '2026-05-01 08:00:00', '2026-05-01 08:00:00');
INSERT INTO `sys_owner_account` VALUES (16, 'owner13', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', 13, NULL, NULL, NULL, NULL, '0', '0', '2026-05-01 08:00:00', '2026-05-01 08:00:00');
INSERT INTO `sys_owner_account` VALUES (17, 'owner14', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', 14, NULL, NULL, NULL, NULL, '0', '0', '2026-05-01 08:00:00', '2026-05-01 08:00:00');
INSERT INTO `sys_owner_account` VALUES (18, 'owner15', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', 15, NULL, NULL, NULL, NULL, '0', '0', '2026-05-01 08:00:00', '2026-05-01 08:00:00');
INSERT INTO `sys_owner_account` VALUES (29, 'owner16', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', 16, NULL, NULL, NULL, NULL, '0', '0', '2026-06-01 08:00:00', '2026-06-01 08:00:00');
INSERT INTO `sys_owner_account` VALUES (30, 'owner17', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', 17, NULL, NULL, NULL, NULL, '0', '0', '2026-06-01 08:00:00', '2026-06-01 08:00:00');
INSERT INTO `sys_owner_account` VALUES (31, 'owner18', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', 18, NULL, NULL, NULL, NULL, '0', '0', '2026-06-01 08:00:00', '2026-06-01 08:00:00');
INSERT INTO `sys_owner_account` VALUES (32, 'owner19', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', 19, NULL, NULL, NULL, NULL, '0', '0', '2026-06-01 08:00:00', '2026-06-01 08:00:00');
INSERT INTO `sys_owner_account` VALUES (33, 'owner20', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', 20, NULL, NULL, NULL, NULL, '0', '0', '2026-06-01 08:00:00', '2026-06-01 08:00:00');
INSERT INTO `sys_owner_account` VALUES (34, 'owner21', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', 21, NULL, NULL, NULL, NULL, '0', '0', '2026-06-01 08:00:00', '2026-06-01 08:00:00');
INSERT INTO `sys_owner_account` VALUES (35, 'owner22', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', 22, NULL, NULL, NULL, NULL, '0', '0', '2026-06-01 08:00:00', '2026-06-01 08:00:00');
INSERT INTO `sys_owner_account` VALUES (36, 'owner23', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', 23, NULL, NULL, NULL, NULL, '0', '0', '2026-06-01 08:00:00', '2026-06-01 08:00:00');
INSERT INTO `sys_owner_account` VALUES (37, 'owner24', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', 24, NULL, NULL, NULL, NULL, '0', '0', '2026-06-01 08:00:00', '2026-06-01 08:00:00');
INSERT INTO `sys_owner_account` VALUES (38, 'owner25', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', 25, NULL, NULL, NULL, NULL, '0', '0', '2026-06-01 08:00:00', '2026-06-01 08:00:00');
INSERT INTO `sys_owner_account` VALUES (39, 'test01', '$2a$10$IgO41HyJNRAVgk8YA3WaquxfeNXtKsrsk9vWR0rdR223S8qDx8Vjy', NULL, 'AAA', '13122223333', NULL, NULL, '0', '0', '2026-07-03 23:32:59', '2026-07-03 23:58:24');
INSERT INTO `sys_owner_account` VALUES (40, 'test02', '$2a$10$pYz33WKyt9ac.UAPCSWQQuvolemm9WTYxdc58PYhVjktb7XwxebA.', NULL, 'A2', '13112122121', '1', 22, '0', '0', '2026-07-03 23:59:08', '2026-07-04 00:30:20');
INSERT INTO `sys_owner_account` VALUES (41, 'test03', '$2a$10$Oq3z6.M5UolqKg9KbLqDo.PzHOu1ASoam1oO2KHjuYSVqvU88LSB2', NULL, 'A3', '13123233333', '0', 33, '0', '0', '2026-07-04 00:24:26', '2026-07-04 00:29:16');

-- ----------------------------
-- Table structure for sys_property_account
-- ----------------------------
DROP TABLE IF EXISTS `sys_property_account`;
CREATE TABLE `sys_property_account`  (
  `account_id` bigint NOT NULL AUTO_INCREMENT COMMENT '物业账号ID',
  `username` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '登录账号',
  `password` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'BCrypt密码',
  `staff_id` bigint NULL DEFAULT NULL COMMENT '关联物业人员档案',
  `permission_code` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '权限码',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '0正常 1停用',
  `del_flag` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '0存在 2删除',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`account_id`) USING BTREE,
  UNIQUE INDEX `uk_property_username`(`username` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 5 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '物业登录账号表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_property_account
-- ----------------------------
INSERT INTO `sys_property_account` VALUES (4, 'property01', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', 4, 'elder_view,elder_manage,elder_staff_manage,dashboard_view,report_export,repair_manage,repair_assign,system_user_manage,system_permission_manage,ai_monitor_view,ai_monitor_config', '0', '0', '2026-05-17 18:16:04', '2026-07-03 23:32:12');

-- ----------------------------
-- Table structure for sys_role
-- ----------------------------
DROP TABLE IF EXISTS `sys_role`;
CREATE TABLE `sys_role`  (
  `role_id` bigint NOT NULL AUTO_INCREMENT,
  `role_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `role_key` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'owner/worker/property/admin',
  `data_scope` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '1' COMMENT '1全部 2本楼栋 3自定义',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '0',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`role_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 8 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '角色' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_role
-- ----------------------------
INSERT INTO `sys_role` VALUES (2, '业主', 'owner', '2', '0', '', '2026-05-17 17:56:16');
INSERT INTO `sys_role` VALUES (3, '维修工', 'worker', '1', '0', '', '2026-05-17 17:56:16');
INSERT INTO `sys_role` VALUES (4, '物业管理员', 'property', '2', '0', '', '2026-05-17 17:56:16');

-- ----------------------------
-- Table structure for sys_role_menu
-- ----------------------------
DROP TABLE IF EXISTS `sys_role_menu`;
CREATE TABLE `sys_role_menu`  (
  `role_id` bigint NOT NULL,
  `menu_id` bigint NOT NULL,
  PRIMARY KEY (`role_id`, `menu_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_role_menu
-- ----------------------------

-- ----------------------------
-- Table structure for sys_user_role
-- ----------------------------
DROP TABLE IF EXISTS `sys_user_role`;
CREATE TABLE `sys_user_role`  (
  `user_id` bigint NOT NULL,
  `role_id` bigint NOT NULL,
  PRIMARY KEY (`user_id`, `role_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_user_role
-- ----------------------------
INSERT INTO `sys_user_role` VALUES (2, 2);
INSERT INTO `sys_user_role` VALUES (3, 3);
INSERT INTO `sys_user_role` VALUES (4, 4);
INSERT INTO `sys_user_role` VALUES (5, 2);
INSERT INTO `sys_user_role` VALUES (6, 2);
INSERT INTO `sys_user_role` VALUES (7, 2);
INSERT INTO `sys_user_role` VALUES (8, 2);
INSERT INTO `sys_user_role` VALUES (9, 2);
INSERT INTO `sys_user_role` VALUES (10, 2);
INSERT INTO `sys_user_role` VALUES (11, 2);
INSERT INTO `sys_user_role` VALUES (12, 2);
INSERT INTO `sys_user_role` VALUES (13, 2);
INSERT INTO `sys_user_role` VALUES (14, 2);
INSERT INTO `sys_user_role` VALUES (15, 2);
INSERT INTO `sys_user_role` VALUES (16, 2);
INSERT INTO `sys_user_role` VALUES (17, 2);
INSERT INTO `sys_user_role` VALUES (18, 2);
INSERT INTO `sys_user_role` VALUES (19, 3);
INSERT INTO `sys_user_role` VALUES (20, 3);
INSERT INTO `sys_user_role` VALUES (21, 3);
INSERT INTO `sys_user_role` VALUES (22, 3);
INSERT INTO `sys_user_role` VALUES (23, 3);
INSERT INTO `sys_user_role` VALUES (29, 2);
INSERT INTO `sys_user_role` VALUES (30, 2);
INSERT INTO `sys_user_role` VALUES (31, 2);
INSERT INTO `sys_user_role` VALUES (32, 2);
INSERT INTO `sys_user_role` VALUES (33, 2);
INSERT INTO `sys_user_role` VALUES (34, 2);
INSERT INTO `sys_user_role` VALUES (35, 2);
INSERT INTO `sys_user_role` VALUES (36, 2);
INSERT INTO `sys_user_role` VALUES (37, 2);
INSERT INTO `sys_user_role` VALUES (38, 2);

-- ----------------------------
-- Table structure for sys_worker_account
-- ----------------------------
DROP TABLE IF EXISTS `sys_worker_account`;
CREATE TABLE `sys_worker_account`  (
  `account_id` bigint NOT NULL AUTO_INCREMENT COMMENT '维修工账号ID',
  `username` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '登录账号',
  `password` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'BCrypt密码',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '0正常 1停用',
  `del_flag` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '0存在 2删除',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`account_id`) USING BTREE,
  UNIQUE INDEX `uk_worker_username`(`username` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 24 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '维修工登录账号表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_worker_account
-- ----------------------------
INSERT INTO `sys_worker_account` VALUES (3, 'worker01', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '0', '0', '2026-05-17 18:16:04', '2026-05-17 18:16:04');
INSERT INTO `sys_worker_account` VALUES (19, 'worker02', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '0', '0', '2026-05-01 08:00:00', '2026-05-01 08:00:00');
INSERT INTO `sys_worker_account` VALUES (20, 'worker03', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '0', '0', '2026-05-01 08:00:00', '2026-05-01 08:00:00');
INSERT INTO `sys_worker_account` VALUES (21, 'worker04', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '0', '0', '2026-05-01 08:00:00', '2026-05-01 08:00:00');
INSERT INTO `sys_worker_account` VALUES (22, 'worker05', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '0', '0', '2026-05-01 08:00:00', '2026-05-01 08:00:00');
INSERT INTO `sys_worker_account` VALUES (23, 'woker06', '$2a$10$evp0FZLoSXDMo6Q45Iyj2u9.ZeT9v7OvjBv9dNsKijQppabQfs8Om', '0', '0', '2026-07-03 21:08:14', '2026-07-03 21:08:14');

-- ----------------------------

SET FOREIGN_KEY_CHECKS = 1;
