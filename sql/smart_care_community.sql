/*
 Navicat Premium Dump SQL

 Source Server         : 本地
 Source Server Type    : MySQL
 Source Server Version : 80044 (8.0.44)
 Source Host           : 127.0.0.1:3306
 Source Schema         : smart_care_community

 Target Server Type    : MySQL
 Target Server Version : 80044 (8.0.44)
 File Encoding         : 65001

 Date: 01/07/2026 18:44:14
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

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
) ENGINE = InnoDB AUTO_INCREMENT = 20 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'AI问答消息表' ROW_FORMAT = DYNAMIC;

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
) ENGINE = InnoDB AUTO_INCREMENT = 5 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'AI问答会话表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of ai_chat_session
-- ----------------------------
INSERT INTO `ai_chat_session` VALUES (1, 2, '停车管理规定咨询', '0', '2026-05-18 10:00:00', '2026-05-18 10:05:00');
INSERT INTO `ai_chat_session` VALUES (2, 5, '投诉楼道杂物堆放', '1', '2026-05-19 14:20:00', '2026-05-19 15:10:00');
INSERT INTO `ai_chat_session` VALUES (3, 2, '物业费缴纳咨询', '2', '2026-05-17 09:30:00', '2026-05-17 10:00:00');
INSERT INTO `ai_chat_session` VALUES (4, 6, '如何在线提交报修', '0', '2026-05-20 11:00:00', '2026-05-20 11:03:00');

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
) ENGINE = InnoDB AUTO_INCREMENT = 11 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '楼栋信息表' ROW_FORMAT = DYNAMIC;

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
) ENGINE = InnoDB AUTO_INCREMENT = 101 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '房屋信息表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cm_house
-- ----------------------------
INSERT INTO `cm_house` VALUES (1, 1, '101', 58.00, '一室一厅', '张三', '1栋101，一室一厅，建筑面积约58.00㎡；张三业主已登记入住，档案与系统账号已绑定，日常联系优先使用系统消息', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (2, 1, '102', 64.50, '两室一厅', '孙浩', '1栋102，两室一厅，建筑面积约64.50㎡；孙浩业主已登记入住，档案与系统账号已绑定，日常联系优先使用系统消息', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (3, 1, '201', 71.00, '两室两厅', '', '1栋201，两室两厅，建筑面积约71.00㎡；样板展示房，展示现代简约风格，供新业主参考', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (4, 1, '202', 70.00, '三室一厅', '', '1栋202，三室一厅，建筑面积约70.00㎡；当前空置，已做深度保洁，可拎包入住', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (5, 1, '301', 76.50, '三室两厅', '', '1栋301，三室两厅，建筑面积约76.50㎡；样板展示房，展示现代简约风格，供新业主参考', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (6, 1, '302', 83.00, '四室两厅', '', '1栋302，四室两厅，建筑面积约83.00㎡；当前空置，已做深度保洁，可拎包入住', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (7, 1, '401', 82.00, '复式loft', '', '1栋401，复式loft，建筑面积约82.00㎡；当前空置，南向采光好，曾做过短期租赁', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (8, 1, '501', 88.50, '跃层三居', '', '1栋501，跃层三居，建筑面积约88.50㎡；当前空置，南向采光好，曾做过短期租赁', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (9, 1, '502', 95.00, '精装两居', '', '1栋502，精装两居，建筑面积约95.00㎡；当前空置，已做深度保洁，可拎包入住', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (10, 1, '601', 94.00, '阔景四居', '', '1栋601，阔景四居，建筑面积约94.00㎡；当前空置，南向采光好，曾做过短期租赁', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (11, 2, '101', 61.00, '一室一厅', '李芳', '2栋101，一室一厅，建筑面积约61.00㎡；李芳业主已登记入住，档案与系统账号已绑定，日常联系优先使用系统消息', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (12, 2, '102', 67.50, '两室一厅', '马超', '2栋102，两室一厅，建筑面积约67.50㎡；马超业主已登记入住，档案与系统账号已绑定，日常联系优先使用系统消息', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (13, 2, '201', 74.00, '两室两厅', '', '2栋201，两室两厅，建筑面积约74.00㎡；样板展示房，展示现代简约风格，供新业主参考', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (14, 2, '202', 73.00, '三室一厅', '', '2栋202，三室一厅，建筑面积约73.00㎡；当前空置，已做深度保洁，可拎包入住', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (15, 2, '301', 79.50, '三室两厅', '', '2栋301，三室两厅，建筑面积约79.50㎡；样板展示房，展示现代简约风格，供新业主参考', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (16, 2, '302', 86.00, '四室两厅', '', '2栋302，四室两厅，建筑面积约86.00㎡；当前空置，已做深度保洁，可拎包入住', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (17, 2, '401', 85.00, '复式loft', '', '2栋401，复式loft，建筑面积约85.00㎡；当前空置，南向采光好，曾做过短期租赁', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (18, 2, '501', 91.50, '跃层三居', '', '2栋501，跃层三居，建筑面积约91.50㎡；当前空置，南向采光好，曾做过短期租赁', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (19, 2, '502', 98.00, '精装两居', '', '2栋502，精装两居，建筑面积约98.00㎡；当前空置，已做深度保洁，可拎包入住', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (20, 2, '601', 97.00, '阔景四居', '', '2栋601，阔景四居，建筑面积约97.00㎡；当前空置，南向采光好，曾做过短期租赁', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (21, 3, '101', 64.00, '一室一厅', '王磊', '3栋101，一室一厅，建筑面积约64.00㎡；王磊业主已登记入住，档案与系统账号已绑定，日常联系优先使用系统消息', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (22, 3, '102', 70.50, '两室一厅', '朱琳', '3栋102，两室一厅，建筑面积约70.50㎡；朱琳业主已登记入住，档案与系统账号已绑定，日常联系优先使用系统消息', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (23, 3, '201', 77.00, '两室两厅', '', '3栋201，两室两厅，建筑面积约77.00㎡；样板展示房，展示现代简约风格，供新业主参考', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (24, 3, '202', 76.00, '三室一厅', '', '3栋202，三室一厅，建筑面积约76.00㎡；当前空置，已做深度保洁，可拎包入住', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (25, 3, '301', 82.50, '三室两厅', '', '3栋301，三室两厅，建筑面积约82.50㎡；样板展示房，展示现代简约风格，供新业主参考', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (26, 3, '302', 89.00, '四室两厅', '', '3栋302，四室两厅，建筑面积约89.00㎡；当前空置，已做深度保洁，可拎包入住', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (27, 3, '401', 88.00, '复式loft', '', '3栋401，复式loft，建筑面积约88.00㎡；当前空置，南向采光好，曾做过短期租赁', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (28, 3, '501', 94.50, '跃层三居', '', '3栋501，跃层三居，建筑面积约94.50㎡；当前空置，南向采光好，曾做过短期租赁', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (29, 3, '502', 101.00, '精装两居', '', '3栋502，精装两居，建筑面积约101.00㎡；当前空置，已做深度保洁，可拎包入住', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (30, 3, '601', 100.00, '阔景四居', '', '3栋601，阔景四居，建筑面积约100.00㎡；当前空置，南向采光好，曾做过短期租赁', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (31, 4, '101', 67.00, '一室一厅', '赵敏', '4栋101，一室一厅，建筑面积约67.00㎡；赵敏业主已登记入住，档案与系统账号已绑定，日常联系优先使用系统消息', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (32, 4, '102', 73.50, '两室一厅', '胡军', '4栋102，两室一厅，建筑面积约73.50㎡；胡军业主已登记入住，档案与系统账号已绑定，日常联系优先使用系统消息', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (33, 4, '201', 80.00, '两室两厅', '', '4栋201，两室两厅，建筑面积约80.00㎡；样板展示房，展示现代简约风格，供新业主参考', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (34, 4, '202', 79.00, '三室一厅', '', '4栋202，三室一厅，建筑面积约79.00㎡；当前空置，已做深度保洁，可拎包入住', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (35, 4, '301', 85.50, '三室两厅', '', '4栋301，三室两厅，建筑面积约85.50㎡；样板展示房，展示现代简约风格，供新业主参考', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (36, 4, '302', 92.00, '四室两厅', '', '4栋302，四室两厅，建筑面积约92.00㎡；当前空置，已做深度保洁，可拎包入住', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (37, 4, '401', 91.00, '复式loft', '', '4栋401，复式loft，建筑面积约91.00㎡；当前空置，南向采光好，曾做过短期租赁', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (38, 4, '501', 97.50, '跃层三居', '', '4栋501，跃层三居，建筑面积约97.50㎡；当前空置，南向采光好，曾做过短期租赁', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (39, 4, '502', 104.00, '精装两居', '', '4栋502，精装两居，建筑面积约104.00㎡；当前空置，已做深度保洁，可拎包入住', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (40, 4, '601', 103.00, '阔景四居', '', '4栋601，阔景四居，建筑面积约103.00㎡；当前空置，南向采光好，曾做过短期租赁', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (41, 5, '101', 70.00, '一室一厅', '刘洋', '5栋101，一室一厅，建筑面积约70.00㎡；刘洋业主已登记入住，档案与系统账号已绑定，日常联系优先使用系统消息', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (42, 5, '102', 76.50, '两室一厅', '林雪', '5栋102，两室一厅，建筑面积约76.50㎡；林雪业主已登记入住，档案与系统账号已绑定，日常联系优先使用系统消息', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (43, 5, '201', 83.00, '两室两厅', '', '5栋201，两室两厅，建筑面积约83.00㎡；样板展示房，展示现代简约风格，供新业主参考', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (44, 5, '202', 82.00, '三室一厅', '', '5栋202，三室一厅，建筑面积约82.00㎡；当前空置，已做深度保洁，可拎包入住', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (45, 5, '301', 88.50, '三室两厅', '', '5栋301，三室两厅，建筑面积约88.50㎡；样板展示房，展示现代简约风格，供新业主参考', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (46, 5, '302', 95.00, '四室两厅', '', '5栋302，四室两厅，建筑面积约95.00㎡；当前空置，已做深度保洁，可拎包入住', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (47, 5, '401', 94.00, '复式loft', '', '5栋401，复式loft，建筑面积约94.00㎡；当前空置，南向采光好，曾做过短期租赁', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (48, 5, '501', 100.50, '跃层三居', '', '5栋501，跃层三居，建筑面积约100.50㎡；当前空置，南向采光好，曾做过短期租赁', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (49, 5, '502', 107.00, '精装两居', '', '5栋502，精装两居，建筑面积约107.00㎡；当前空置，已做深度保洁，可拎包入住', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (50, 5, '601', 106.00, '阔景四居', '', '5栋601，阔景四居，建筑面积约106.00㎡；当前空置，南向采光好，曾做过短期租赁', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (51, 6, '101', 73.00, '一室一厅', '陈静', '6栋101，一室一厅，建筑面积约73.00㎡；陈静业主已登记入住，档案与系统账号已绑定，日常联系优先使用系统消息', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (52, 6, '102', 79.50, '两室一厅', '', '6栋102，两室一厅，建筑面积约79.50㎡；当前空置，已做深度保洁，可拎包入住', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (53, 6, '201', 86.00, '两室两厅', '', '6栋201，两室两厅，建筑面积约86.00㎡；样板展示房，展示现代简约风格，供新业主参考', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (54, 6, '202', 85.00, '三室一厅', '', '6栋202，三室一厅，建筑面积约85.00㎡；当前空置，已做深度保洁，可拎包入住', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (55, 6, '301', 91.50, '三室两厅', '', '6栋301，三室两厅，建筑面积约91.50㎡；样板展示房，展示现代简约风格，供新业主参考', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (56, 6, '302', 98.00, '四室两厅', '', '6栋302，四室两厅，建筑面积约98.00㎡；当前空置，已做深度保洁，可拎包入住', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (57, 6, '401', 97.00, '复式loft', '', '6栋401，复式loft，建筑面积约97.00㎡；当前空置，南向采光好，曾做过短期租赁', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (58, 6, '501', 103.50, '跃层三居', '', '6栋501，跃层三居，建筑面积约103.50㎡；当前空置，南向采光好，曾做过短期租赁', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (59, 6, '502', 110.00, '精装两居', '', '6栋502，精装两居，建筑面积约110.00㎡；当前空置，已做深度保洁，可拎包入住', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (60, 6, '601', 109.00, '阔景四居', '', '6栋601，阔景四居，建筑面积约109.00㎡；当前空置，南向采光好，曾做过短期租赁', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (61, 7, '101', 76.00, '一室一厅', '杨帆', '7栋101，一室一厅，建筑面积约76.00㎡；杨帆业主已登记入住，档案与系统账号已绑定，日常联系优先使用系统消息', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (62, 7, '102', 82.50, '两室一厅', '', '7栋102，两室一厅，建筑面积约82.50㎡；当前空置，已做深度保洁，可拎包入住', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (63, 7, '201', 89.00, '两室两厅', '', '7栋201，两室两厅，建筑面积约89.00㎡；样板展示房，展示现代简约风格，供新业主参考', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (64, 7, '202', 88.00, '三室一厅', '', '7栋202，三室一厅，建筑面积约88.00㎡；当前空置，已做深度保洁，可拎包入住', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (65, 7, '301', 94.50, '三室两厅', '', '7栋301，三室两厅，建筑面积约94.50㎡；样板展示房，展示现代简约风格，供新业主参考', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (66, 7, '302', 101.00, '四室两厅', '', '7栋302，四室两厅，建筑面积约101.00㎡；当前空置，已做深度保洁，可拎包入住', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (67, 7, '401', 100.00, '复式loft', '', '7栋401，复式loft，建筑面积约100.00㎡；当前空置，南向采光好，曾做过短期租赁', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (68, 7, '501', 106.50, '跃层三居', '', '7栋501，跃层三居，建筑面积约106.50㎡；当前空置，南向采光好，曾做过短期租赁', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (69, 7, '502', 113.00, '精装两居', '', '7栋502，精装两居，建筑面积约113.00㎡；当前空置，已做深度保洁，可拎包入住', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (70, 7, '601', 112.00, '阔景四居', '', '7栋601，阔景四居，建筑面积约112.00㎡；当前空置，南向采光好，曾做过短期租赁', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (71, 8, '101', 79.00, '一室一厅', '周婷', '8栋101，一室一厅，建筑面积约79.00㎡；周婷业主已登记入住，档案与系统账号已绑定，日常联系优先使用系统消息', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (72, 8, '102', 85.50, '两室一厅', '', '8栋102，两室一厅，建筑面积约85.50㎡；当前空置，已做深度保洁，可拎包入住', '2026-05-01 08:00:00');
INSERT INTO `cm_house` VALUES (73, 8, '201', 92.00, '两室两厅', '', '8栋201，两室两厅，建筑面积约92.00㎡；样板展示房，展示现代简约风格，供新业主参考', '2026-05-01 08:00:00');
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
INSERT INTO `cm_house` VALUES (100, 10, '601', 121.00, '阔景四居', '', '10栋601，阔景四居，建筑面积约121.00㎡；当前空置，南向采光好，曾做过短期租赁', '2026-05-01 08:00:00');

-- ----------------------------
-- Table structure for cm_resident
-- ----------------------------
DROP TABLE IF EXISTS `cm_resident`;
CREATE TABLE `cm_resident`  (
  `resident_id` bigint NOT NULL AUTO_INCREMENT COMMENT '住户主键',
  `user_id` bigint NULL DEFAULT NULL COMMENT '绑定用户ID',
  `house_id` bigint NOT NULL COMMENT '房屋ID',
  `name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '姓名',
  `gender` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '性别：0男 1女',
  `age` int NULL DEFAULT NULL COMMENT '年龄',
  `id_card` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '身份证号',
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '电话',
  `resident_type` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '类型：0业主 1租客',
  `move_in_date` date NULL DEFAULT NULL COMMENT '入住日期',
  `emergency_contact` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '紧急联系人',
  `family_members` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '家庭成员JSON',
  `remark` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '备注',
  `del_flag` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '删除：0存在 2删除',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`resident_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 16 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '住户档案表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cm_resident
-- ----------------------------
INSERT INTO `cm_resident` VALUES (1, 2, 1, '张三', '0', 35, '', '13810000001', '0', '2023-01-15', '', '', '主业主，系统账号已绑定', '0', '2026-05-01 08:00:00', '2026-05-01 08:00:00');
INSERT INTO `cm_resident` VALUES (2, 5, 11, '李芳', '1', 42, '', '13810000002', '0', '2023-02-15', '李强 13900000002', '', '日常在家，快递可放门口驿站', '0', '2026-05-01 08:00:00', '2026-05-01 08:00:00');
INSERT INTO `cm_resident` VALUES (3, 6, 21, '王磊', '0', 38, '', '13810000003', '0', '2023-03-15', '', '', '工作日晚归，访客需提前登记', '0', '2026-05-01 08:00:00', '2026-05-01 08:00:00');
INSERT INTO `cm_resident` VALUES (4, 7, 31, '赵敏', '1', 36, '', '13810000004', '0', '2023-04-15', '赵刚 13900000004', '', '', '0', '2026-05-01 08:00:00', '2026-05-01 08:00:00');
INSERT INTO `cm_resident` VALUES (5, 8, 41, '刘洋', '0', 45, '', '13810000005', '0', '2023-05-15', '刘梅 13900000005', '', '长期出差，紧急事项可联系配偶', '0', '2026-05-01 08:00:00', '2026-05-01 08:00:00');
INSERT INTO `cm_resident` VALUES (6, 9, 51, '陈静', '1', 33, '', '13810000006', '0', '2023-06-15', '', '', '家有宠物，遛狗请走指定路线', '0', '2026-05-01 08:00:00', '2026-05-01 08:00:00');
INSERT INTO `cm_resident` VALUES (7, 10, 61, '杨帆', '0', 29, '', '13810000007', '0', '2023-07-15', '', '', '', '0', '2026-05-01 08:00:00', '2026-05-01 08:00:00');
INSERT INTO `cm_resident` VALUES (8, 11, 71, '周婷', '1', 31, '', '13810000008', '0', '2023-08-15', '', '', '偏好短信通知，22点后请勿电话', '0', '2026-05-01 08:00:00', '2026-05-01 08:00:00');
INSERT INTO `cm_resident` VALUES (9, 12, 81, '吴刚', '0', 50, '', '13810000009', '0', '2023-09-15', '吴芳 13900000009', '', '', '0', '2026-05-01 08:00:00', '2026-05-01 08:00:00');
INSERT INTO `cm_resident` VALUES (10, 13, 91, '郑丽', '1', 72, '', '13810000010', '0', '2023-10-15', '郑明 13900000010', '', '独居，已纳入老人关怀关注', '0', '2026-05-01 08:00:00', '2026-05-01 08:00:00');
INSERT INTO `cm_resident` VALUES (11, 14, 2, '孙浩', '0', 28, '', '13810000011', '0', '2023-11-15', '', '', '', '0', '2026-05-01 08:00:00', '2026-05-01 08:00:00');
INSERT INTO `cm_resident` VALUES (12, 15, 12, '马超', '0', 26, '', '13810000012', '0', '2023-12-15', '', '', '', '0', '2026-05-01 08:00:00', '2026-05-01 08:00:00');
INSERT INTO `cm_resident` VALUES (13, 16, 22, '朱琳', '1', 34, '', '13810000013', '0', '2023-01-15', '', '', '维修前请提前沟通', '0', '2026-05-01 08:00:00', '2026-05-01 08:00:00');
INSERT INTO `cm_resident` VALUES (14, 17, 32, '胡军', '0', 55, '', '13810000014', '0', '2023-02-15', '', '', '', '0', '2026-05-01 08:00:00', '2026-05-01 08:00:00');
INSERT INTO `cm_resident` VALUES (15, 18, 42, '林雪', '1', 40, '', '13810000015', '0', '2023-03-15', '林涛 13900000015', '', '家中有老人同住，停水停电请优先通知', '0', '2026-05-01 08:00:00', '2026-05-01 08:00:00');

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
INSERT INTO `cm_resident_tag_rel` VALUES (6, 6);
INSERT INTO `cm_resident_tag_rel` VALUES (10, 1);
INSERT INTO `cm_resident_tag_rel` VALUES (10, 2);
INSERT INTO `cm_resident_tag_rel` VALUES (11, 5);
INSERT INTO `cm_resident_tag_rel` VALUES (14, 4);
INSERT INTO `cm_resident_tag_rel` VALUES (14, 5);
INSERT INTO `cm_resident_tag_rel` VALUES (15, 2);

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
) ENGINE = InnoDB AUTO_INCREMENT = 31 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '社区公告通知表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cs_notice
-- ----------------------------
INSERT INTO `cs_notice` VALUES (1, 'announce', '清明节文明祭扫倡议', '清明将至，倡导鲜花祭扫、网络祭扫等文明方式。请勿在楼道、阳台堆放纸钱等易燃物，祭扫后确认火源完全熄灭。', '', 1, NULL, NULL, '', NULL, NULL, '1', 4, '2026-04-02 09:00:00', '2026-04-02 09:00:00');
INSERT INTO `cs_notice` VALUES (2, 'announce', '春季绿化补种通知', '4月10日至15日，物业将在中心花园及主干道两侧补种灌木与草坪。作业期间请勿进入围挡区域，如有宠物请牵绳绕行。', '', 0, NULL, NULL, '', NULL, '2026-06-15 23:59:59', '0', 4, '2026-04-08 10:00:00', '2026-07-01 17:35:23');
INSERT INTO `cs_notice` VALUES (3, 'announce', '五一劳动节放假安排', '5月1日至5月3日放假，物业服务中心5月1日9:00-12:00值班，5月2日起正常办公。紧急报修请拨打24小时热线。', '', 0, NULL, NULL, '', NULL, NULL, '0', 4, '2026-04-20 08:30:00', '2026-04-25 18:00:00');
INSERT INTO `cs_notice` VALUES (4, 'announce', '端午节包粽子活动通知', '社区将于6月9日14:00在活动中心举办包粽子活动，限40组家庭，额满即止。报名请联系楼栋管家或至物业前台登记。', '', 1, NULL, NULL, '', NULL, NULL, '1', 4, '2026-06-05 09:00:00', '2026-07-01 17:35:23');
INSERT INTO `cs_notice` VALUES (5, 'announce', '夏季消防安全演练安排', '定于5月18日15:00在中心广场进行消防疏散演练，请各楼栋配合物业工作人员指引。演练期间请勿围观堵塞通道。', '', 0, NULL, NULL, '', NULL, NULL, '1', 4, '2026-05-10 14:00:00', '2026-05-10 14:00:00');
INSERT INTO `cs_notice` VALUES (6, 'announce', '小区绿化修剪公告', '5月22日至24日将进行绿化修剪，作业时间8:30-17:30。请勿在作业区域停放车辆，修剪期间可能有轻微噪音，敬请谅解。', '', 0, NULL, NULL, '', NULL, '2026-05-31 23:59:59', '0', 4, '2026-05-12 08:00:00', '2026-07-01 17:35:23');
INSERT INTO `cs_notice` VALUES (7, 'announce', '亲子运动会报名开启', '6月15日举办亲子运动会，设跳绳、接力等项目。线上报名截止6月8日，可在业主群或物业前台填写报名表。', '', 0, NULL, NULL, '', NULL, NULL, '1', 4, '2026-06-01 10:00:00', '2026-07-01 17:35:23');
INSERT INTO `cs_notice` VALUES (8, 'announce', '电梯年度检修告知', '5月25日起分批检修各栋电梯，单次停梯约2-4小时。具体时段见各单元门口张贴通知，检修期间请优先步行或错峰乘梯。', '', 0, NULL, NULL, '', NULL, NULL, '1', 4, '2026-05-15 11:00:00', '2026-05-15 11:00:00');
INSERT INTO `cs_notice` VALUES (9, 'announce', '宠物文明饲养倡议', '请遛宠时使用牵引绳，及时清理宠物排泄物。禁止在公共区域放养，避免犬吠扰民。违反规定者将按公约劝导处理。', '', 0, NULL, NULL, '', NULL, NULL, '0', 4, '2026-04-05 09:00:00', '2026-04-10 09:00:00');
INSERT INTO `cs_notice` VALUES (10, 'announce', '地下车库清洗通知', '6月6日清洗B1、B2层车库，当日8:00-18:00请尽量驶离或配合移位。清洗后地面湿滑，请注意行车安全。', '', 0, NULL, NULL, '', NULL, NULL, '1', 4, '2026-05-28 16:00:00', '2026-05-28 16:00:00');
INSERT INTO `cs_notice` VALUES (11, 'announce', '业主大会表决事项预告', '关于增设新能源充电桩方案，定于6月20日19:00在社区会议室召开业主大会表决。材料已张贴于各栋公告栏，欢迎查阅。', '', 1, NULL, NULL, '', NULL, NULL, '1', 4, '2026-06-10 09:00:00', '2026-07-01 17:35:23');
INSERT INTO `cs_notice` VALUES (12, 'announce', '蚊虫消杀作业公告', '6月3日晚20:00-22:00全小区消杀，请关好门窗，收好食品。消杀后30分钟内避免开窗，儿童宠物请勿接触药剂喷洒区域。', '', 0, NULL, NULL, '', NULL, NULL, '1', 4, '2026-05-30 08:00:00', '2026-05-30 08:00:00');
INSERT INTO `cs_notice` VALUES (13, 'announce', '快递柜系统升级说明', '5月16日22:00-24:00升级快递柜系统，期间可能无法取件。请提前取走重要快件，升级完成后需重新验证手机号。', '', 0, NULL, NULL, '', NULL, '2026-05-20 08:00:00', '0', 4, '2026-05-14 09:30:00', '2026-07-01 17:35:23');
INSERT INTO `cs_notice` VALUES (14, 'announce', '儿童节礼品领取通知', '6月1日9:00-17:00在一层大堂领取儿童节礼品，每户限领一份。请携带业主身份证明，代领需出示授权信息。', '', 0, NULL, NULL, '', NULL, NULL, '1', 4, '2026-05-25 10:00:00', '2026-05-25 10:00:00');
INSERT INTO `cs_notice` VALUES (15, 'announce', '高温防暑温馨提示', '6月起进入高温季节，请注意防暑补水。建议老人儿童减少11:00-15:00户外活动，室内空调温度不宜过低，避免室内外温差过大。', '', 0, NULL, NULL, '', NULL, NULL, '1', 4, '2026-06-01 07:30:00', '2026-06-01 07:30:00');
INSERT INTO `cs_notice` VALUES (16, 'outage', '1栋停水检修通知', '因主管道阀门更换，1栋将于5月12日9:00-17:00暂停供水。请提前储水，恢复供水初期水质可能短暂浑浊，放水后即可正常使用。', '', 1, NULL, NULL, '1栋全体住户', '2026-05-12 17:00:00', NULL, '1', 4, '2026-05-11 08:00:00', '2026-05-11 08:00:00');
INSERT INTO `cs_notice` VALUES (17, 'outage', '2栋配电室停电检修', '2栋配电室设备检修，5月14日8:30-11:30全栋停电。请提前保存电脑数据，电梯将暂停运行，高层住户请合理安排出行。', '', 0, NULL, NULL, '2栋', '2026-05-14 11:30:00', NULL, '1', 4, '2026-05-13 09:00:00', '2026-05-13 09:00:00');
INSERT INTO `cs_notice` VALUES (18, 'outage', '3栋水泵更换停水', '3栋二次供水水泵更换，5月20日14:00-18:00低区停水。请关闭热水器进水阀，恢复供水后再开启，防止空烧损坏设备。', '', 0, NULL, NULL, '3栋低区', '2026-05-20 18:00:00', NULL, '1', 4, '2026-06-08 14:00:00', '2026-07-01 17:35:23');
INSERT INTO `cs_notice` VALUES (19, 'outage', '4栋电梯机房停电', '4栋电梯机房维护，5月22日13:00-15:00电梯全部暂停。请提前规划上下楼路线，老人及行动不便住户可联系物业协助。', '', 0, NULL, NULL, '4栋', '2026-05-22 15:00:00', NULL, '1', 4, '2026-05-21 10:00:00', '2026-05-21 10:00:00');
INSERT INTO `cs_notice` VALUES (20, 'outage', '5栋燃气安全检查停气', '5栋5月25日9:00-12:00停气检修。请提前关闭灶具阀门，恢复通气后先开窗通风再点火，确保安全。', '', 0, NULL, NULL, '5栋', '2026-05-25 12:00:00', NULL, '1', 4, '2026-05-24 08:30:00', '2026-05-24 08:30:00');
INSERT INTO `cs_notice` VALUES (21, 'outage', '6栋水箱清洗停水', '6栋水箱清洗消毒，4月18日10:00-16:00停水。清洗完成后水质符合标准再恢复供水，如有疑问请联系物业工程部。', '', 0, NULL, NULL, '6栋', '2026-04-18 16:00:00', NULL, '0', 4, '2026-04-15 09:00:00', '2026-04-20 10:00:00');
INSERT INTO `cs_notice` VALUES (22, 'outage', '7栋线路改造停电', '7栋供电线路改造，6月12日0:00-6:00全栋停电。请提前为手机、应急灯充电，凌晨时段请注意出行安全。', '', 1, NULL, NULL, '7栋', '2026-06-12 06:00:00', NULL, '1', 4, '2026-06-10 12:00:00', '2026-06-10 12:00:00');
INSERT INTO `cs_notice` VALUES (23, 'outage', '8栋主水管维修停水', '8栋主水管维修，6月18日8:00-12:00停水。工程车可能占用临时车位，请配合现场疏导，带来不便敬请谅解。', '', 0, NULL, NULL, '8栋', '2026-06-18 12:00:00', NULL, '1', 4, '2026-06-15 08:00:00', '2026-07-01 17:35:23');
INSERT INTO `cs_notice` VALUES (24, 'outage', '9栋公区照明改造停电', '9栋大堂及走廊照明改造，5月28日19:00-22:00公区停电。请使用手机照明，注意台阶安全，改造完成后照明将更加节能明亮。', '', 0, NULL, NULL, '9栋公区', '2026-05-28 22:00:00', NULL, '1', 4, '2026-05-27 15:00:00', '2026-05-27 15:00:00');
INSERT INTO `cs_notice` VALUES (25, 'outage', '10栋阀门更换停水', '10栋总阀更换，6月2日9:00-11:00停水。停水时间较短，请提前储少量生活用水，恢复后请先放清管道存水。', '', 0, NULL, NULL, '10栋', '2026-06-02 11:00:00', NULL, '1', 4, '2026-06-01 09:00:00', '2026-06-01 09:00:00');
INSERT INTO `cs_notice` VALUES (26, 'outage', '中心广场活动临时停电', '广场端午活动用电调试，6月8日18:00-20:00周边路灯及景观灯关闭。调试结束后立即恢复，请夜间出行注意瞭望。', '', 0, NULL, NULL, '中心广场周边', '2026-06-08 20:00:00', NULL, '1', 4, '2026-06-07 10:00:00', '2026-06-07 10:00:00');
INSERT INTO `cs_notice` VALUES (27, 'outage', '地下车库B1消防测试停水', 'B1层消防管道测试，4月25日15:00-17:00临时停水。测试期间可能有警报声，属正常现象，请勿恐慌。', '', 0, NULL, NULL, 'B1车库', '2026-04-25 17:00:00', NULL, '0', 4, '2026-04-22 11:00:00', '2026-04-26 09:00:00');
INSERT INTO `cs_notice` VALUES (28, 'outage', '1-3栋联动检修停水', '6月25日8:00-18:00，1至3栋低区联动停水检修。影响范围较大，请提前储备24小时用水，物业将在大堂提供应急供水。', '', 0, NULL, NULL, '1-3栋低区', '2026-06-25 18:00:00', NULL, '1', 4, '2026-06-20 09:00:00', '2026-07-01 17:35:23');
INSERT INTO `cs_notice` VALUES (29, 'outage', '全小区消防联动测试停电', '6月30日10:00-10:30消防联动测试，全小区电梯可能短暂停运，门禁系统切换备用电源。测试结束后自动恢复正常。', '', 0, NULL, NULL, '全小区', '2026-06-30 10:30:00', NULL, '1', 4, '2026-06-28 08:00:00', '2026-06-28 08:00:00');
INSERT INTO `cs_notice` VALUES (30, 'outage', '4栋计划停水（待发布）', '4栋主供水管计划7月5日8:00-14:00停水检修，具体以现场条件为准。本通知待工程方案确认后正式发布，请提前关注后续更新。', '', 0, NULL, NULL, '4栋', '2026-07-05 14:00:00', NULL, '1', 4, '2026-06-22 09:00:00', '2026-07-01 17:35:23');

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
INSERT INTO `cs_notice_read` VALUES (16, 2, '2026-05-12 08:30:00');

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
INSERT INTO `cs_service_ticket` VALUES (1, 5, 2, '楼道杂物堆放投诉', '1', '已记录您反映的楼道杂物问题，我们将安排人员上门查看。', '2026-05-19 14:22:00', '2026-05-19 14:30:00');
INSERT INTO `cs_service_ticket` VALUES (2, 2, 3, '物业费缴纳咨询', '2', '物业费可至物业中心缴纳，工作日 9:00-17:30。', '2026-05-17 09:35:00', '2026-05-17 10:00:00');

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
  `handle_time` datetime NULL DEFAULT NULL COMMENT '处置时间',
  `handle_result` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '处置结果',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '预警时间',
  PRIMARY KEY (`alert_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '老人异常预警表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of el_alert
-- ----------------------------

-- ----------------------------
-- Table structure for el_care_order
-- ----------------------------
DROP TABLE IF EXISTS `el_care_order`;
CREATE TABLE `el_care_order`  (
  `care_id` bigint NOT NULL AUTO_INCREMENT COMMENT '关怀工单主键',
  `resident_id` bigint NOT NULL COMMENT '老人住户ID',
  `care_item` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '关怀事项',
  `assignee_id` bigint NULL DEFAULT NULL COMMENT '指派人员ID',
  `status` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'pending' COMMENT '状态',
  `result` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '处置结果',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`care_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '独居老人关怀工单表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of el_care_order
-- ----------------------------

-- ----------------------------
-- Table structure for el_care_staff
-- ----------------------------
DROP TABLE IF EXISTS `el_care_staff`;
CREATE TABLE `el_care_staff`  (
  `staff_id` bigint NOT NULL AUTO_INCREMENT COMMENT '人员主键',
  `name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '姓名',
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '电话',
  `staff_type` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'grid' COMMENT '类型：grid/volunteer/social',
  `building_ids` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '负责楼栋ID列表',
  PRIMARY KEY (`staff_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '关怀人员台账表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of el_care_staff
-- ----------------------------

-- ----------------------------
-- Table structure for el_device
-- ----------------------------
DROP TABLE IF EXISTS `el_device`;
CREATE TABLE `el_device`  (
  `device_id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '硬件设备ID',
  `resident_id` bigint NOT NULL COMMENT '关联老人住户ID',
  PRIMARY KEY (`device_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '老人紧急求助设备表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of el_device
-- ----------------------------

-- ----------------------------
-- Table structure for el_disposal_plan
-- ----------------------------
DROP TABLE IF EXISTS `el_disposal_plan`;
CREATE TABLE `el_disposal_plan`  (
  `plan_id` bigint NOT NULL AUTO_INCREMENT COMMENT '预案主键',
  `level` int NOT NULL COMMENT '等级：1立即上门 2电话确认',
  `rule_desc` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '规则描述',
  PRIMARY KEY (`plan_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '异常事件分级处置预案表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of el_disposal_plan
-- ----------------------------

-- ----------------------------
-- Table structure for el_health_record
-- ----------------------------
DROP TABLE IF EXISTS `el_health_record`;
CREATE TABLE `el_health_record`  (
  `record_id` bigint NOT NULL AUTO_INCREMENT COMMENT '记录主键',
  `resident_id` bigint NOT NULL COMMENT '老人住户ID',
  `heart_rate` int NULL DEFAULT NULL COMMENT '心率',
  `blood_pressure` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '血压',
  `steps` int NULL DEFAULT NULL COMMENT '步数',
  `record_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '采集时间',
  PRIMARY KEY (`record_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '老人健康数据记录表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of el_health_record
-- ----------------------------

-- ----------------------------
-- Table structure for el_health_threshold
-- ----------------------------
DROP TABLE IF EXISTS `el_health_threshold`;
CREATE TABLE `el_health_threshold`  (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键',
  `metric` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '指标名',
  `min_value` decimal(10, 2) NULL DEFAULT NULL COMMENT '最小阈值',
  `max_value` decimal(10, 2) NULL DEFAULT NULL COMMENT '最大阈值',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '健康数据告警阈值表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of el_health_threshold
-- ----------------------------

-- ----------------------------
-- Table structure for el_visit_plan
-- ----------------------------
DROP TABLE IF EXISTS `el_visit_plan`;
CREATE TABLE `el_visit_plan`  (
  `plan_id` bigint NOT NULL AUTO_INCREMENT COMMENT '计划主键',
  `resident_id` bigint NOT NULL COMMENT '老人住户ID',
  `cycle_type` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '周期：weekly/monthly',
  `cycle_value` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '周期值',
  `next_date` date NOT NULL COMMENT '下次执行日期',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '1' COMMENT '状态：1有效 0停用',
  PRIMARY KEY (`plan_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '定期关怀回访计划表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of el_visit_plan
-- ----------------------------

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
) ENGINE = InnoDB AUTO_INCREMENT = 21 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '维修知识库文章表' ROW_FORMAT = DYNAMIC;

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
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '知识库学习草稿表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of kb_learn_draft
-- ----------------------------

-- ----------------------------
-- Table structure for rp_material
-- ----------------------------
DROP TABLE IF EXISTS `rp_material`;
CREATE TABLE `rp_material`  (
  `material_id` bigint NOT NULL AUTO_INCREMENT COMMENT '物料主键',
  `order_id` bigint NOT NULL COMMENT '工单ID',
  `name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '物料名称',
  `spec` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '规格',
  `quantity` decimal(10, 2) NULL DEFAULT 0.00 COMMENT '数量',
  `unit_price` decimal(10, 2) NULL DEFAULT 0.00 COMMENT '单价',
  PRIMARY KEY (`material_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '工单耗材登记表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of rp_material
-- ----------------------------

-- ----------------------------
-- Table structure for rp_material_apply
-- ----------------------------
DROP TABLE IF EXISTS `rp_material_apply`;
CREATE TABLE `rp_material_apply`  (
  `apply_id` bigint NOT NULL AUTO_INCREMENT COMMENT '申请主键',
  `worker_id` bigint NOT NULL COMMENT '维修工ID',
  `order_id` bigint NULL DEFAULT NULL COMMENT '关联工单ID',
  `materials` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '物料JSON清单',
  `urgency` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'normal' COMMENT '紧急程度',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '状态：0待审 1通过 2驳回',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '申请时间',
  PRIMARY KEY (`apply_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '物料领用申请表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of rp_material_apply
-- ----------------------------

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
  `sign_image` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '验收签名图',
  `reject_reason` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '拒单原因',
  `assign_reason` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '派单原因',
  `ai_type_label` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT 'AI识别故障类型',
  `high_risk` tinyint NULL DEFAULT 0 COMMENT '高风险：0否 1是',
  `duplicate_flag` tinyint NULL DEFAULT 0 COMMENT '重复报修：0否 1是',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`order_id`) USING BTREE,
  UNIQUE INDEX `uk_order_no`(`order_no` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '报修工单表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of rp_order
-- ----------------------------
INSERT INTO `rp_order` VALUES (2, 'RP202607011830043335', 2, NULL, 2, '厕所水管漏水', 'urgent', 'pending', 3, 1, 24, 0.00, 0.00, 0, '', '缺少专业工具或配件', 'AI自动派单', '水管漏水', 0, 0, '2026-07-01 18:30:04', '2026-07-01 18:30:04');
INSERT INTO `rp_order` VALUES (3, 'RP202607011833447810', 2, NULL, NULL, '消防栓损坏', 'emergency', 'completed', 3, 0, 24, 0.00, 0.00, 0, 'data:image/png;base64,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/eXRRx+VFi1ayKpVq+TKlSsyefJkh+t72AOHDx82t3hS9ubNmzelWbNmonOYqkO7du1k+vTppp0UCCCAAAIIIIAAAggg4E4B3oUAAggggAACsQUsH+A8fvy4DB482PT5rbfeknTp0pljewoNNDZu3FjSpk0rK1euFM0Ajf1cSEiIDBw4MPYppxzre7UiTwlw6uJMupjQ999/b7JWFy5cKJ9//rk2kQ0BBBBAAAHPFaBlCCCAAAIIIIAAAggg4BMClg5wauZl06ZNzcJCefPmlTlz5pgMzD179sT7cXX4uQbuKlSoIIGBgVKwYEGZNWuWaD1p0qSR6tWry48//iga4Bs5cqSsWbMm3nqSe9IW4NSM0+TWldznDx48KOqhGauavbpu3TqpXbt2cqt12/MagM6ZM6dUqVJFQkNDH9hKlSoluXLlEp1HVP82zpw547Z2edKLaAsCCCCAAAIIIIAAAggggAACCFhfwMo9tHSAs0+fPrJ69WrJli2bydzcunWraBBTFxvSj6rHU6dOFZ2fU+/RAN67775rhrPrHJN6T8aMGWXo0KFy6dIlWbp0qTz//PNSp04dExTT667YbAsMpXSAU4OZ5cqVk71794oGAzdu3ChPPPGEK7rssjojIiIkKirKBKNXrFghsbft27eLBjV1kaRGjRqZYKdmzepQ/FGjRpm/Aw1uu6xxVIwAAggggAACCCCAAAKeJkB7EEAAAQS8UMCyAc7PPvtMhgwZYj5JWFiY7N+/3xxrodl6GrjUgGbz5s3lq6++knPnzukls+XJk0d0SHa/fv3M+a5du0rq1KnNNXcUtgCnBtvc8b743jF+/HipXLmynD9/Xl544QVZu3atCQDGd68nn9PM02+++UaWLVv2t23JkiXyySefSMeOHaVSpUoSEBAgR44cER2K/95775nMVZ3SIHv27PL0009LaJwMUP0dHBxsXLp16yYaEI6JifFkDtqGAAIIIICAkwSoBgEEEEAAAQQQQAABzxGwZIBT54zs3bu3UX799dflP//5jzm2FTov5+XLlyVVqlRiy5LUoGaPHj3MwkGa2fnLL7+ILkjkzsCmrX22IepBQUG2U27db9q0STSTVYN1L730kkRGRpoMWLc2wkkvy5Qpk7z22muiwci4W40aNaRLly4yfPhwE8DVLF3N+P30009FMzr1b0IXVzp79qzJBF4R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eirRTeet1BuyZMmiuwc2HbauwczatWuL9luHmhctWtQEV7XPy5Ytk+joaFm1apXoMHGd0zEmJuZ+HZrNuWPHDrOAjWZn6vygsbedO3fK+fPn5fLly5ImTRoJDg6WRo0aiWafaiD5//7v/8z1yZMniw5xZwj6fVoOEEAAAQQQQAABBBBAAAEXCVAtAggggMDDBLw+wBlfByMiIsxpXegnXbp05thZhQYJdcj3+++/b4J9ujiPLgijmZStWrUSDTrGfdesWbMkMDBQFi9ebLI6416P/TtugFMDkrqQjwZKs2TJIpop+vPPP4sGOzWDM/azsY/1fSEhIeZ+fa8GP3WzLWCjx3E3XRBo0qRJotmnV69elc2bN4u2/eOPPxbtr3r+4x//iP0ajhFAAAEEEEAAAc8QoBUIIIAAAggggAACPitgyQCnLfD36quvOvXD6nD04sWLm2HZOremZjcePXpUwsPD4w1s2l7+1FNPyQcffGB+6tD527dvm+P4CluAc8SIEaJDxZ988knRhXyWLFliskN1wSINpOp1nUdTg50aYLUFKzUgqb91qLtmac6ZM0dq1qx5fyi6bQGb0DjD0/V3kyZNRIek62JE8bWNcwgg4P0C9AABBBBAAAEEEEAAAQQQQAABqwlYLsB548YNOXz4sGimoQ4NT8IH+9sjmrWp807qcHRdTEfnqty0aZPJbowvY/NvFdw90bVrV9EFeHbv3i2ff/753TN//6+B2evXr5sLumCPDhXXftSpU0dGjRolBw8elD179ogOhX/vvffMMHHN7NQAqwYoddOgq/5m+LjwDwEEEEAAAQQQQAABBBBAAIHEBLiGAAIWEbBcgFOHdOu3KVasWKJZlXqPPdu8efPMIkW6SFDq1Kmlb9++Zui2ZmXa87ztHg04fvnll+anZmRq5qf5cbfQwKbOcZktW7a7v+7912CovuvixYuycOFCeffdd6VgwYL3LiajHD16tKlH5+dMRjU8igACCCCAAAIIIOAzAnQUAQQQQAABBBDwbAHLBTh///13I65ZluYgiYUta7N+/fpmUR6t7z//+Y98+OGHosHKpFSrw8ODgoLMUPNPPvlENLCpw97Lli0rmuGpC/xovZkzZzaZmvounUtTzzlr04WCNMN14MCBzqqSehBAAAEEVIANAQQQQAABBBBAAAEEEEAgRQQsF+DURXRUUueq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', '', 'AI自动派单', '其他故障', 0, 0, '2026-07-01 18:33:44', '2026-07-01 18:33:44');

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
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '工单服务评价表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of rp_order_eval
-- ----------------------------
INSERT INTO `rp_order_eval` VALUES (1, 3, 5, '态度好,技术专业', '好', '0', '2026-07-01 18:38:36');

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
INSERT INTO `rp_order_image` VALUES (2, 2, '/upload/repair/20260701/75f420d2dfd64e2085e987e63f208282.jpg');
INSERT INTO `rp_order_image` VALUES (3, 3, '/upload/repair/20260701/377a5620e516478d898b9a05cbf60162.jpg');

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
) ENGINE = InnoDB AUTO_INCREMENT = 15 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '工单进度节点表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of rp_order_progress
-- ----------------------------
INSERT INTO `rp_order_progress` VALUES (4, 2, '提交报修', '2', '业主提交报修单', '2026-07-01 18:30:04');
INSERT INTO `rp_order_progress` VALUES (5, 2, 'AI智能分析', 'AI', 'AI识别：水管漏水，紧急程度=较急', '2026-07-01 18:30:04');
INSERT INTO `rp_order_progress` VALUES (6, 2, '派单', 'AI', '指派维修工:3', '2026-07-01 18:30:04');
INSERT INTO `rp_order_progress` VALUES (7, 2, '催单', '2', '业主发起催单', '2026-07-01 18:31:45');
INSERT INTO `rp_order_progress` VALUES (8, 3, '提交报修', '2', '业主提交报修单', '2026-07-01 18:33:44');
INSERT INTO `rp_order_progress` VALUES (9, 3, 'AI智能分析', 'AI', 'AI识别：其他故障，紧急程度=紧急', '2026-07-01 18:33:44');
INSERT INTO `rp_order_progress` VALUES (10, 3, '派单', 'AI', '指派维修工:3', '2026-07-01 18:33:44');
INSERT INTO `rp_order_progress` VALUES (11, 2, '拒单', '3', '故障类型不在技能范围', '2026-07-01 18:35:50');
INSERT INTO `rp_order_progress` VALUES (12, 3, 'wait_accept', 'system', '维修完成待验收', '2026-07-01 18:35:51');
INSERT INTO `rp_order_progress` VALUES (13, 2, '拒单', '3', '缺少专业工具或配件', '2026-07-01 18:36:01');
INSERT INTO `rp_order_progress` VALUES (14, 3, '验收完成', '2', '评分:5 标签:态度好,技术专业', '2026-07-01 18:38:36');

-- ----------------------------
-- Table structure for rp_repair_type
-- ----------------------------
DROP TABLE IF EXISTS `rp_repair_type`;
CREATE TABLE `rp_repair_type`  (
  `type_id` bigint NOT NULL AUTO_INCREMENT COMMENT '类型主键',
  `parent_id` bigint NULL DEFAULT 0 COMMENT '父级ID',
  `type_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '类型名称',
  `order_num` int NULL DEFAULT 0 COMMENT '排序',
  PRIMARY KEY (`type_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 5 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '报修故障类型表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of rp_repair_type
-- ----------------------------
INSERT INTO `rp_repair_type` VALUES (1, 0, '水电', 1);
INSERT INTO `rp_repair_type` VALUES (2, 1, '水管漏水', 1);
INSERT INTO `rp_repair_type` VALUES (3, 0, '电路', 2);
INSERT INTO `rp_repair_type` VALUES (4, 3, '跳闸', 1);

-- ----------------------------
-- Table structure for rp_repair_weekly_report
-- ----------------------------
DROP TABLE IF EXISTS `rp_repair_weekly_report`;
CREATE TABLE `rp_repair_weekly_report`  (
  `report_id` bigint NOT NULL AUTO_INCREMENT COMMENT '周报主键',
  `week_start` date NOT NULL COMMENT '周起始日期',
  `week_end` date NOT NULL COMMENT '周结束日期',
  `total_orders` int NULL DEFAULT 0 COMMENT '总工单数',
  `avg_complete_hours` decimal(10, 2) NULL DEFAULT 0.00 COMMENT '平均完成时长(小时)',
  `overtime_rate` decimal(10, 2) NULL DEFAULT 0.00 COMMENT '超时率(%)',
  `duplicate_rate` decimal(10, 2) NULL DEFAULT 0.00 COMMENT '重复报修率(%)',
  `good_rate` decimal(10, 2) NULL DEFAULT 0.00 COMMENT '好评率(%)',
  `type_stats` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '按故障类型统计JSON',
  `worker_stats` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '按维修工统计JSON',
  `suggestions` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT 'AI优化建议',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '生成时间',
  PRIMARY KEY (`report_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '工单AI复盘周报' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of rp_repair_weekly_report
-- ----------------------------

-- ----------------------------
-- Table structure for rp_work_hour
-- ----------------------------
DROP TABLE IF EXISTS `rp_work_hour`;
CREATE TABLE `rp_work_hour`  (
  `hour_id` bigint NOT NULL AUTO_INCREMENT COMMENT '工时主键',
  `order_id` bigint NOT NULL COMMENT '工单ID',
  `worker_id` bigint NOT NULL COMMENT '维修工ID',
  `start_time` datetime NOT NULL COMMENT '开始时间',
  `end_time` datetime NULL DEFAULT NULL COMMENT '结束时间',
  `modify_status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '修改审批：0无 1待审',
  PRIMARY KEY (`hour_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '维修工时打卡表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of rp_work_hour
-- ----------------------------

-- ----------------------------
-- Table structure for rp_worker_appeal
-- ----------------------------
DROP TABLE IF EXISTS `rp_worker_appeal`;
CREATE TABLE `rp_worker_appeal`  (
  `appeal_id` bigint NOT NULL AUTO_INCREMENT COMMENT '申诉主键',
  `eval_id` bigint NOT NULL COMMENT '评价ID',
  `worker_id` bigint NOT NULL COMMENT '维修工ID',
  `reason` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '申诉理由',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '状态：0待审 1通过 2驳回',
  PRIMARY KEY (`appeal_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '维修工差评申诉表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of rp_worker_appeal
-- ----------------------------

-- ----------------------------
-- Table structure for rp_worker_profile
-- ----------------------------
DROP TABLE IF EXISTS `rp_worker_profile`;
CREATE TABLE `rp_worker_profile`  (
  `worker_id` bigint NOT NULL COMMENT '维修工用户ID',
  `work_status` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'available' COMMENT '状态：available/busy/rest',
  `cert_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '证书名称',
  `cert_expire` date NULL DEFAULT NULL COMMENT '证书有效期',
  `avg_score` decimal(3, 2) NULL DEFAULT 5.00 COMMENT '平均评分',
  `eval_count` int NULL DEFAULT 0 COMMENT '评价数',
  PRIMARY KEY (`worker_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '维修工档案表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of rp_worker_profile
-- ----------------------------
INSERT INTO `rp_worker_profile` VALUES (3, 'available', '电工操作证', NULL, 4.85, 12);

-- ----------------------------
-- Table structure for sys_abnormal_login
-- ----------------------------
DROP TABLE IF EXISTS `sys_abnormal_login`;
CREATE TABLE `sys_abnormal_login`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `login_time` datetime NOT NULL COMMENT '登录时间',
  `ipaddr` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT 'IP地址',
  `device` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '设备信息',
  `is_self` tinyint NULL DEFAULT 0 COMMENT '是否本人：0否 1是',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '异常登录记录表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_abnormal_login
-- ----------------------------

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
) ENGINE = InnoDB AUTO_INCREMENT = 5 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '系统参数配置表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_config
-- ----------------------------
INSERT INTO `sys_config` VALUES (1, '消息撤回时长(分钟)', 'msg.recall.minutes', '2', '消息撤回有效时长');
INSERT INTO `sys_config` VALUES (2, '日志保留天数', 'log.retain.days', '90', '自动清理历史日志');
INSERT INTO `sys_config` VALUES (3, '催单升级次数', 'order.urge.max', '3', '累计催单触发升级');
INSERT INTO `sys_config` VALUES (4, '工单超时小时', 'order.timeout.hours', '24', '工单未处理超时小时');

-- ----------------------------
-- Table structure for sys_dict_data
-- ----------------------------
DROP TABLE IF EXISTS `sys_dict_data`;
CREATE TABLE `sys_dict_data`  (
  `dict_code` bigint NOT NULL AUTO_INCREMENT COMMENT '字典数据主键',
  `dict_sort` int NULL DEFAULT 0 COMMENT '排序号',
  `dict_label` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '字典标签',
  `dict_value` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '字典键值',
  `dict_type` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '字典类型编码',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '状态：0正常 1停用',
  PRIMARY KEY (`dict_code`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 11 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '通用字典数据表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_dict_data
-- ----------------------------
INSERT INTO `sys_dict_data` VALUES (1, 1, '紧急', 'urgent', 'msg_priority', '0');
INSERT INTO `sys_dict_data` VALUES (2, 2, '普通', 'normal', 'msg_priority', '0');
INSERT INTO `sys_dict_data` VALUES (3, 1, '待分配', 'pending', 'order_status', '0');
INSERT INTO `sys_dict_data` VALUES (4, 2, '处理中', 'processing', 'order_status', '0');
INSERT INTO `sys_dict_data` VALUES (5, 3, '待验收', 'wait_accept', 'order_status', '0');
INSERT INTO `sys_dict_data` VALUES (6, 4, '已完成', 'completed', 'order_status', '0');
INSERT INTO `sys_dict_data` VALUES (7, 5, '已取消', 'cancelled', 'order_status', '0');
INSERT INTO `sys_dict_data` VALUES (8, 1, '普通', 'normal', 'order_urgency', '0');
INSERT INTO `sys_dict_data` VALUES (9, 2, '较急', 'urgent', 'order_urgency', '0');
INSERT INTO `sys_dict_data` VALUES (10, 3, '紧急', 'emergency', 'order_urgency', '0');

-- ----------------------------
-- Table structure for sys_dict_type
-- ----------------------------
DROP TABLE IF EXISTS `sys_dict_type`;
CREATE TABLE `sys_dict_type`  (
  `dict_id` bigint NOT NULL AUTO_INCREMENT COMMENT '字典类型主键',
  `dict_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '字典名称',
  `dict_type` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '字典类型编码',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '状态：0正常 1停用',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '备注',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`dict_id`) USING BTREE,
  UNIQUE INDEX `uk_dict_type`(`dict_type` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '通用字典类型表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_dict_type
-- ----------------------------
INSERT INTO `sys_dict_type` VALUES (1, '消息优先级', 'msg_priority', '0', '消息优先级字典', '2026-05-17 18:16:04');
INSERT INTO `sys_dict_type` VALUES (2, '工单状态', 'order_status', '0', '报修工单状态', '2026-05-17 18:16:04');
INSERT INTO `sys_dict_type` VALUES (3, '报修紧急程度', 'order_urgency', '0', '报修紧急程度', '2026-05-17 18:16:04');

-- ----------------------------
-- Table structure for sys_flow_switch
-- ----------------------------
DROP TABLE IF EXISTS `sys_flow_switch`;
CREATE TABLE `sys_flow_switch`  (
  `switch_id` bigint NOT NULL AUTO_INCREMENT COMMENT '开关主键',
  `switch_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '开关名称',
  `switch_key` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '开关键',
  `enabled` tinyint NULL DEFAULT 1 COMMENT '是否启用：1是 0否',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '备注',
  PRIMARY KEY (`switch_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '业务流程开关表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_flow_switch
-- ----------------------------

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
) ENGINE = InnoDB AUTO_INCREMENT = 18 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '用户登录日志表' ROW_FORMAT = DYNAMIC;

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
INSERT INTO `sys_login_log` VALUES (13, 'property01', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0', '0', '登录成功', '2026-07-01 17:37:09');
INSERT INTO `sys_login_log` VALUES (14, 'owner01', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0', '0', '登录成功', '2026-07-01 17:43:42');
INSERT INTO `sys_login_log` VALUES (15, 'owner01', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0', '0', '登录成功', '2026-07-01 18:27:12');
INSERT INTO `sys_login_log` VALUES (16, 'worker01', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0', '0', '登录成功', '2026-07-01 18:34:58');
INSERT INTO `sys_login_log` VALUES (17, 'owner01', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0', '0', '登录成功', '2026-07-01 18:36:30');

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
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`message_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 5 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '统一消息表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_message
-- ----------------------------
INSERT INTO `sys_message` VALUES (1, 'order', '工单已派单', '工单RP202607011830043335已指派维修人员', 'normal', NULL, '', NULL, NULL, 0, NULL, '2026-07-01 18:30:04', '2026-07-01 18:30:04');
INSERT INTO `sys_message` VALUES (2, 'order', '新工单派单', '您有新的维修工单 RP202607011830043335，请及时处理', 'normal', NULL, '', NULL, NULL, 0, NULL, '2026-07-01 18:30:04', '2026-07-01 18:30:04');
INSERT INTO `sys_message` VALUES (3, 'order', '工单已派单', '工单RP202607011833447810已指派维修人员', 'normal', NULL, '', NULL, NULL, 0, NULL, '2026-07-01 18:33:44', '2026-07-01 18:33:44');
INSERT INTO `sys_message` VALUES (4, 'order', '新工单派单', '您有新的维修工单 RP202607011833447810，请及时处理', 'normal', NULL, '', NULL, NULL, 0, NULL, '2026-07-01 18:33:44', '2026-07-01 18:33:44');

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
) ENGINE = InnoDB AUTO_INCREMENT = 5 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '用户消息已读状态表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_message_user
-- ----------------------------
INSERT INTO `sys_message_user` VALUES (1, 1, 2, 0, NULL);
INSERT INTO `sys_message_user` VALUES (2, 2, 3, 0, NULL);
INSERT INTO `sys_message_user` VALUES (3, 3, 2, 0, NULL);
INSERT INTO `sys_message_user` VALUES (4, 4, 3, 0, NULL);

-- ----------------------------
-- Table structure for sys_oper_log
-- ----------------------------
DROP TABLE IF EXISTS `sys_oper_log`;
CREATE TABLE `sys_oper_log`  (
  `oper_id` bigint NOT NULL AUTO_INCREMENT COMMENT '日志主键',
  `title` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '操作模块',
  `business_type` int NULL DEFAULT 0 COMMENT '业务类型',
  `method` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '请求方法',
  `oper_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '操作人',
  `oper_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '请求URL',
  `oper_ip` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '操作IP',
  `oper_param` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '请求参数',
  `json_result` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '返回结果',
  `status` int NULL DEFAULT 0 COMMENT '状态：0成功 1失败',
  `error_msg` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '错误信息',
  `oper_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '操作时间',
  PRIMARY KEY (`oper_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '系统操作日志表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_oper_log
-- ----------------------------

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
) ENGINE = InnoDB AUTO_INCREMENT = 5 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '角色' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_role
-- ----------------------------
INSERT INTO `sys_role` VALUES (1, '超级管理员', 'admin', '1', '0', '', '2026-05-17 17:56:16');
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
-- Table structure for sys_user
-- ----------------------------
DROP TABLE IF EXISTS `sys_user`;
CREATE TABLE `sys_user`  (
  `user_id` bigint NOT NULL AUTO_INCREMENT COMMENT '用户主键',
  `username` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '登录账号',
  `password` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '登录密码(BCrypt)',
  `nick_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '用户昵称',
  `gender` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '性别：0男 1女',
  `age` int NULL DEFAULT NULL COMMENT '年龄',
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '手机号码',
  `id_card` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '身份证号',
  `avatar` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '头像URL',
  `user_type` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '0' COMMENT '用户类型：0业主 1维修工 2物业 3管理员',
  `building_id` bigint NULL DEFAULT NULL COMMENT '数据权限-楼栋ID',
  `house_id` bigint NULL DEFAULT NULL COMMENT '关联房屋ID',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '状态：0正常 1停用',
  `del_flag` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '删除：0存在 2删除',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`user_id`) USING BTREE,
  UNIQUE INDEX `uk_username`(`username` ASC) USING BTREE,
  UNIQUE INDEX `uk_phone`(`phone` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 19 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '系统用户表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_user
-- ----------------------------
INSERT INTO `sys_user` VALUES (2, 'owner01', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '张三', '0', 35, '13810000001', '', '', '0', NULL, 1, '0', '0', '2026-05-01 08:00:00', '2026-05-01 08:00:00');
INSERT INTO `sys_user` VALUES (3, 'worker01', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '李师傅', '0', 42, '13800000002', '', '', '1', NULL, NULL, '0', '0', '2026-05-17 18:16:04', '2026-05-17 18:16:04');
INSERT INTO `sys_user` VALUES (4, 'property01', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '王管家', '1', 38, '13800000003', '', '', '2', NULL, NULL, '0', '0', '2026-05-17 18:16:04', '2026-05-17 18:16:04');
INSERT INTO `sys_user` VALUES (5, 'owner02', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '李芳', '1', 42, '13810000002', '', '', '0', NULL, 11, '0', '0', '2026-05-01 08:00:00', '2026-05-01 08:00:00');
INSERT INTO `sys_user` VALUES (6, 'owner03', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '王磊', '0', 38, '13810000003', '', '', '0', NULL, 21, '0', '0', '2026-05-01 08:00:00', '2026-05-01 08:00:00');
INSERT INTO `sys_user` VALUES (7, 'owner04', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '赵敏', '1', 36, '13810000004', '', '', '0', NULL, 31, '0', '0', '2026-05-01 08:00:00', '2026-05-01 08:00:00');
INSERT INTO `sys_user` VALUES (8, 'owner05', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '刘洋', '0', 45, '13810000005', '', '', '0', NULL, 41, '0', '0', '2026-05-01 08:00:00', '2026-05-01 08:00:00');
INSERT INTO `sys_user` VALUES (9, 'owner06', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '陈静', '1', 33, '13810000006', '', '', '0', NULL, 51, '0', '0', '2026-05-01 08:00:00', '2026-05-01 08:00:00');
INSERT INTO `sys_user` VALUES (10, 'owner07', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '杨帆', '0', 29, '13810000007', '', '', '0', NULL, 61, '0', '0', '2026-05-01 08:00:00', '2026-05-01 08:00:00');
INSERT INTO `sys_user` VALUES (11, 'owner08', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '周婷', '1', 31, '13810000008', '', '', '0', NULL, 71, '0', '0', '2026-05-01 08:00:00', '2026-05-01 08:00:00');
INSERT INTO `sys_user` VALUES (12, 'owner09', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '吴刚', '0', 50, '13810000009', '', '', '0', NULL, 81, '0', '0', '2026-05-01 08:00:00', '2026-05-01 08:00:00');
INSERT INTO `sys_user` VALUES (13, 'owner10', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '郑丽', '1', 72, '13810000010', '', '', '0', NULL, 91, '0', '0', '2026-05-01 08:00:00', '2026-05-01 08:00:00');
INSERT INTO `sys_user` VALUES (14, 'owner11', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '孙浩', '0', 28, '13810000011', '', '', '0', NULL, 2, '0', '0', '2026-05-01 08:00:00', '2026-05-01 08:00:00');
INSERT INTO `sys_user` VALUES (15, 'owner12', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '马超', '0', 26, '13810000012', '', '', '0', NULL, 12, '0', '0', '2026-05-01 08:00:00', '2026-05-01 08:00:00');
INSERT INTO `sys_user` VALUES (16, 'owner13', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '朱琳', '1', 34, '13810000013', '', '', '0', NULL, 22, '0', '0', '2026-05-01 08:00:00', '2026-05-01 08:00:00');
INSERT INTO `sys_user` VALUES (17, 'owner14', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '胡军', '0', 55, '13810000014', '', '', '0', NULL, 32, '0', '0', '2026-05-01 08:00:00', '2026-05-01 08:00:00');
INSERT INTO `sys_user` VALUES (18, 'owner15', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '林雪', '1', 40, '13810000015', '', '', '0', NULL, 42, '0', '0', '2026-05-01 08:00:00', '2026-05-01 08:00:00');

-- ----------------------------
-- Table structure for sys_user_device
-- ----------------------------
DROP TABLE IF EXISTS `sys_user_device`;
CREATE TABLE `sys_user_device`  (
  `device_id` bigint NOT NULL AUTO_INCREMENT COMMENT '设备记录主键',
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `device_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '设备类型',
  `device_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '设备名称',
  `ipaddr` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT 'IP地址',
  `trusted` tinyint NULL DEFAULT 0 COMMENT '是否信任：0否 1是',
  `login_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '最近登录时间',
  PRIMARY KEY (`device_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '用户登录设备表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_user_device
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

SET FOREIGN_KEY_CHECKS = 1;
