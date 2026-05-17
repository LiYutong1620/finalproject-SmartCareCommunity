/*
 Navicat Premium Dump SQL

 Source Server         : my-mysql
 Source Server Type    : MySQL
 Source Server Version : 80404 (8.4.4)
 Source Host           : localhost:3306
 Source Schema         : smart_care_community

 Target Server Type    : MySQL
 Target Server Version : 80404 (8.4.4)
 File Encoding         : 65001

 Date: 17/05/2026 18:48:31
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for cm_building
-- ----------------------------
DROP TABLE IF EXISTS `cm_building`;
CREATE TABLE `cm_building`  (
  `building_id` bigint NOT NULL AUTO_INCREMENT COMMENT '楼栋主键',
  `building_no` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '楼栋编号',
  `total_floors` int NULL DEFAULT 0 COMMENT '总层数',
  `units_per_floor` int NULL DEFAULT 0 COMMENT '每层户数',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`building_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '楼栋信息表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of cm_building
-- ----------------------------
INSERT INTO `cm_building` VALUES (1, '1栋', 18, 4, '2026-05-17 18:16:04', '2026-05-17 18:25:08');

-- ----------------------------
-- Table structure for cm_equipment
-- ----------------------------
DROP TABLE IF EXISTS `cm_equipment`;
CREATE TABLE `cm_equipment`  (
  `equipment_id` bigint NOT NULL AUTO_INCREMENT COMMENT '设备主键',
  `equip_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '类型：elevator/door/light',
  `equip_no` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '设备编号',
  `location` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '安装位置',
  `iot_status` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'normal' COMMENT '物联网状态',
  `next_maintain` date NULL DEFAULT NULL COMMENT '下次维保日期',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`equipment_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '小区公共设备表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of cm_equipment
-- ----------------------------

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
  `rent_status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '租赁：0空置 1已租 2待退租',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`house_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '房屋信息表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of cm_house
-- ----------------------------
INSERT INTO `cm_house` VALUES (1, 1, '101', 89.50, '三室两厅', '张三', '1', '2026-05-17 18:16:04');

-- ----------------------------
-- Table structure for cm_move_apply
-- ----------------------------
DROP TABLE IF EXISTS `cm_move_apply`;
CREATE TABLE `cm_move_apply`  (
  `apply_id` bigint NOT NULL AUTO_INCREMENT COMMENT '申请主键',
  `resident_id` bigint NULL DEFAULT NULL COMMENT '住户ID',
  `house_id` bigint NOT NULL COMMENT '房屋ID',
  `apply_type` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '类型：0入住 1迁出',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '状态：0待审 1通过 2驳回',
  `reject_reason` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '驳回原因',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '申请时间',
  PRIMARY KEY (`apply_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '入住迁出申请表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of cm_move_apply
-- ----------------------------

-- ----------------------------
-- Table structure for cm_parking
-- ----------------------------
DROP TABLE IF EXISTS `cm_parking`;
CREATE TABLE `cm_parking`  (
  `parking_id` bigint NOT NULL AUTO_INCREMENT COMMENT '车位主键',
  `parking_no` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '车位编号',
  `monthly_fee` decimal(10, 2) NULL DEFAULT 0.00 COMMENT '月租费',
  `yearly_fee` decimal(10, 2) NULL DEFAULT 0.00 COMMENT '年租费',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '状态：0空闲 1已绑定',
  PRIMARY KEY (`parking_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '车位资源表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of cm_parking
-- ----------------------------

-- ----------------------------
-- Table structure for cm_parking_bind
-- ----------------------------
DROP TABLE IF EXISTS `cm_parking_bind`;
CREATE TABLE `cm_parking_bind`  (
  `bind_id` bigint NOT NULL AUTO_INCREMENT COMMENT '绑定主键',
  `parking_id` bigint NOT NULL COMMENT '车位ID',
  `resident_id` bigint NOT NULL COMMENT '住户ID',
  `bind_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '绑定时间',
  PRIMARY KEY (`bind_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '车位绑定表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of cm_parking_bind
-- ----------------------------

-- ----------------------------
-- Table structure for cm_resident
-- ----------------------------
DROP TABLE IF EXISTS `cm_resident`;
CREATE TABLE `cm_resident`  (
  `resident_id` bigint NOT NULL AUTO_INCREMENT COMMENT '住户主键',
  `user_id` bigint NULL DEFAULT NULL COMMENT '绑定用户ID',
  `house_id` bigint NOT NULL COMMENT '房屋ID',
  `name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '姓名',
  `id_card` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '身份证号',
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '电话',
  `resident_type` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '类型：0业主 1租客',
  `move_in_date` date NULL DEFAULT NULL COMMENT '入住日期',
  `emergency_contact` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '紧急联系人',
  `del_flag` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '删除：0存在 2删除',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`resident_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '住户档案表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of cm_resident
-- ----------------------------
INSERT INTO `cm_resident` VALUES (1, 2, 1, '张三', '', '13800000001', '0', '2024-01-01', '', '0', '2026-05-17 18:16:04', '2026-05-17 18:25:08');

-- ----------------------------
-- Table structure for cm_resident_tag
-- ----------------------------
DROP TABLE IF EXISTS `cm_resident_tag`;
CREATE TABLE `cm_resident_tag`  (
  `tag_id` bigint NOT NULL AUTO_INCREMENT COMMENT '标签主键',
  `tag_name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '标签名称',
  `tag_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'custom' COMMENT '类型：elder/disabled/custom等',
  PRIMARY KEY (`tag_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '住户标签定义表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of cm_resident_tag
-- ----------------------------

-- ----------------------------
-- Table structure for cm_resident_tag_rel
-- ----------------------------
DROP TABLE IF EXISTS `cm_resident_tag_rel`;
CREATE TABLE `cm_resident_tag_rel`  (
  `resident_id` bigint NOT NULL COMMENT '住户ID',
  `tag_id` bigint NOT NULL COMMENT '标签ID',
  PRIMARY KEY (`resident_id`, `tag_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '住户标签关联表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of cm_resident_tag_rel
-- ----------------------------

-- ----------------------------
-- Table structure for cm_violation
-- ----------------------------
DROP TABLE IF EXISTS `cm_violation`;
CREATE TABLE `cm_violation`  (
  `violation_id` bigint NOT NULL AUTO_INCREMENT COMMENT '违规主键',
  `resident_id` bigint NOT NULL COMMENT '住户ID',
  `violation_type` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '违规类型',
  `measure` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '处理措施',
  `unlock_date` date NULL DEFAULT NULL COMMENT '解封日期',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '1' COMMENT '状态：1黑名单 0已解除',
  PRIMARY KEY (`violation_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '违规住户记录表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of cm_violation
-- ----------------------------

-- ----------------------------
-- Table structure for cs_activity
-- ----------------------------
DROP TABLE IF EXISTS `cs_activity`;
CREATE TABLE `cs_activity`  (
  `activity_id` bigint NOT NULL AUTO_INCREMENT COMMENT '活动主键',
  `title` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '活动标题',
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '活动内容',
  `location` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '活动地点',
  `start_time` datetime NOT NULL COMMENT '开始时间',
  `deadline` datetime NULL DEFAULT NULL COMMENT '报名截止',
  `max_count` int NULL DEFAULT 0 COMMENT '人数上限',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '1' COMMENT '状态：1有效 0下架',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`activity_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '社区活动表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of cs_activity
-- ----------------------------

-- ----------------------------
-- Table structure for cs_activity_reg
-- ----------------------------
DROP TABLE IF EXISTS `cs_activity_reg`;
CREATE TABLE `cs_activity_reg`  (
  `reg_id` bigint NOT NULL AUTO_INCREMENT COMMENT '报名主键',
  `activity_id` bigint NOT NULL COMMENT '活动ID',
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '报名姓名',
  `house_no` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '房号',
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '电话',
  `status` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'pending' COMMENT '状态：pending/joined/cancelled',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '报名时间',
  PRIMARY KEY (`reg_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '活动报名表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of cs_activity_reg
-- ----------------------------

-- ----------------------------
-- Table structure for cs_complaint
-- ----------------------------
DROP TABLE IF EXISTS `cs_complaint`;
CREATE TABLE `cs_complaint`  (
  `complaint_id` bigint NOT NULL AUTO_INCREMENT COMMENT '投诉主键',
  `complaint_no` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '投诉编号',
  `user_id` bigint NOT NULL COMMENT '提交人ID',
  `category` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'other' COMMENT '分类',
  `title` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '标题',
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '内容',
  `anonymous` tinyint NULL DEFAULT 0 COMMENT '匿名：0否 1是',
  `status` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'pending' COMMENT '状态',
  `handler_id` bigint NULL DEFAULT NULL COMMENT '处理人ID',
  `reply` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '回复内容',
  `reply_time` datetime NULL DEFAULT NULL COMMENT '回复时间',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '提交时间',
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`complaint_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '投诉建议表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of cs_complaint
-- ----------------------------

-- ----------------------------
-- Table structure for cs_family_bind
-- ----------------------------
DROP TABLE IF EXISTS `cs_family_bind`;
CREATE TABLE `cs_family_bind`  (
  `bind_id` bigint NOT NULL AUTO_INCREMENT COMMENT '绑定主键',
  `owner_id` bigint NOT NULL COMMENT '业主用户ID',
  `family_phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '亲属手机',
  `share_order` tinyint NULL DEFAULT 1 COMMENT '共享工单：0否 1是',
  `share_alert` tinyint NULL DEFAULT 0 COMMENT '共享预警：0否 1是',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '绑定时间',
  PRIMARY KEY (`bind_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '亲情账号绑定表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of cs_family_bind
-- ----------------------------

-- ----------------------------
-- Table structure for cs_forum_comment
-- ----------------------------
DROP TABLE IF EXISTS `cs_forum_comment`;
CREATE TABLE `cs_forum_comment`  (
  `comment_id` bigint NOT NULL AUTO_INCREMENT COMMENT '留言主键',
  `post_id` bigint NOT NULL COMMENT '帖子ID',
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `content` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '留言内容',
  `audit_status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '1' COMMENT '审核状态',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '留言时间',
  PRIMARY KEY (`comment_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '帖子留言表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of cs_forum_comment
-- ----------------------------

-- ----------------------------
-- Table structure for cs_forum_post
-- ----------------------------
DROP TABLE IF EXISTS `cs_forum_post`;
CREATE TABLE `cs_forum_post`  (
  `post_id` bigint NOT NULL AUTO_INCREMENT COMMENT '帖子主键',
  `user_id` bigint NOT NULL COMMENT '发帖用户ID',
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '帖子内容',
  `audit_status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '审核：0待审 1通过 2驳回',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '发帖时间',
  PRIMARY KEY (`post_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '邻里论坛帖子表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of cs_forum_post
-- ----------------------------

-- ----------------------------
-- Table structure for cs_housekeeping
-- ----------------------------
DROP TABLE IF EXISTS `cs_housekeeping`;
CREATE TABLE `cs_housekeeping`  (
  `provider_id` bigint NOT NULL AUTO_INCREMENT COMMENT '服务商主键',
  `name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '服务商名称',
  `service_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '服务类型',
  `license_no` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '营业执照号',
  `avg_score` decimal(3, 2) NULL DEFAULT 5.00 COMMENT '平均评分',
  PRIMARY KEY (`provider_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '家政服务商表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of cs_housekeeping
-- ----------------------------

-- ----------------------------
-- Table structure for cs_housekeeping_order
-- ----------------------------
DROP TABLE IF EXISTS `cs_housekeeping_order`;
CREATE TABLE `cs_housekeeping_order`  (
  `order_id` bigint NOT NULL AUTO_INCREMENT COMMENT '预约主键',
  `user_id` bigint NOT NULL COMMENT '业主用户ID',
  `provider_id` bigint NOT NULL COMMENT '服务商ID',
  `book_time` datetime NOT NULL COMMENT '预约时间',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '状态：0待确认 1已完成 2取消',
  PRIMARY KEY (`order_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '家政服务预约表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of cs_housekeeping_order
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
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '1' COMMENT '状态：1上架 0下架',
  `create_by` bigint NULL DEFAULT NULL COMMENT '发布人',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '发布时间',
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`notice_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '社区公告通知表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of cs_notice
-- ----------------------------

-- ----------------------------
-- Table structure for cs_notice_read
-- ----------------------------
DROP TABLE IF EXISTS `cs_notice_read`;
CREATE TABLE `cs_notice_read`  (
  `notice_id` bigint NOT NULL COMMENT '公告ID',
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `read_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '阅读时间',
  PRIMARY KEY (`notice_id`, `user_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '公告已读记录表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of cs_notice_read
-- ----------------------------

-- ----------------------------
-- Table structure for cs_secondhand
-- ----------------------------
DROP TABLE IF EXISTS `cs_secondhand`;
CREATE TABLE `cs_secondhand`  (
  `item_id` bigint NOT NULL AUTO_INCREMENT COMMENT '闲置主键',
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `item_type` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '类型：0出售 1求购',
  `title` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '标题',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '描述',
  `price` decimal(10, 2) NULL DEFAULT 0.00 COMMENT '价格',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '1' COMMENT '状态：1上架 0下架',
  PRIMARY KEY (`item_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '二手闲置表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of cs_secondhand
-- ----------------------------

-- ----------------------------
-- Table structure for cs_venue
-- ----------------------------
DROP TABLE IF EXISTS `cs_venue`;
CREATE TABLE `cs_venue`  (
  `venue_id` bigint NOT NULL AUTO_INCREMENT COMMENT '场地主键',
  `venue_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '场地名称',
  `fee_standard` decimal(10, 2) NULL DEFAULT 0.00 COMMENT '收费标准',
  PRIMARY KEY (`venue_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '公共场地表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of cs_venue
-- ----------------------------

-- ----------------------------
-- Table structure for cs_venue_booking
-- ----------------------------
DROP TABLE IF EXISTS `cs_venue_booking`;
CREATE TABLE `cs_venue_booking`  (
  `booking_id` bigint NOT NULL AUTO_INCREMENT COMMENT '预约主键',
  `venue_id` bigint NOT NULL COMMENT '场地ID',
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `book_date` date NOT NULL COMMENT '预约日期',
  `time_slot` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '时段',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '状态：0待审 1通过 2取消',
  PRIMARY KEY (`booking_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '场地预约表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of cs_venue_booking
-- ----------------------------

-- ----------------------------
-- Table structure for cs_visitor
-- ----------------------------
DROP TABLE IF EXISTS `cs_visitor`;
CREATE TABLE `cs_visitor`  (
  `visitor_id` bigint NOT NULL AUTO_INCREMENT COMMENT '访客主键',
  `owner_id` bigint NOT NULL COMMENT '业主用户ID',
  `visitor_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '访客姓名',
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '访客手机',
  `visit_start` datetime NOT NULL COMMENT '来访开始',
  `visit_end` datetime NULL DEFAULT NULL COMMENT '来访结束',
  `plate_no` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '车牌号',
  `qrcode` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '通行二维码',
  PRIMARY KEY (`visitor_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '访客预约表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of cs_visitor
-- ----------------------------

-- ----------------------------
-- Table structure for cs_vote
-- ----------------------------
DROP TABLE IF EXISTS `cs_vote`;
CREATE TABLE `cs_vote`  (
  `vote_id` bigint NOT NULL AUTO_INCREMENT COMMENT '投票主键',
  `title` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '议题标题',
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '议题说明',
  `anonymous` tinyint NULL DEFAULT 1 COMMENT '匿名：0否 1是',
  `end_time` datetime NOT NULL COMMENT '截止时间',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '1' COMMENT '状态：1进行中 0结束',
  PRIMARY KEY (`vote_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '业主投票议题表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of cs_vote
-- ----------------------------

-- ----------------------------
-- Table structure for cs_vote_record
-- ----------------------------
DROP TABLE IF EXISTS `cs_vote_record`;
CREATE TABLE `cs_vote_record`  (
  `record_id` bigint NOT NULL AUTO_INCREMENT COMMENT '投票记录主键',
  `vote_id` bigint NOT NULL COMMENT '议题ID',
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `option` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '选项',
  PRIMARY KEY (`record_id`) USING BTREE,
  UNIQUE INDEX `uk_vote_user`(`vote_id` ASC, `user_id` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '业主投票记录表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of cs_vote_record
-- ----------------------------

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
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '老人异常预警表' ROW_FORMAT = Dynamic;

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
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '独居老人关怀工单表' ROW_FORMAT = Dynamic;

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
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '关怀人员台账表' ROW_FORMAT = Dynamic;

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
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '老人紧急求助设备表' ROW_FORMAT = Dynamic;

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
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '异常事件分级处置预案表' ROW_FORMAT = Dynamic;

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
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '老人健康数据记录表' ROW_FORMAT = Dynamic;

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
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '健康数据告警阈值表' ROW_FORMAT = Dynamic;

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
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '定期关怀回访计划表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of el_visit_plan
-- ----------------------------

-- ----------------------------
-- Table structure for fn_bill
-- ----------------------------
DROP TABLE IF EXISTS `fn_bill`;
CREATE TABLE `fn_bill`  (
  `bill_id` bigint NOT NULL AUTO_INCREMENT COMMENT '账单主键',
  `house_id` bigint NOT NULL COMMENT '房屋ID',
  `item_id` bigint NOT NULL COMMENT '收费项ID',
  `period` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '账期',
  `amount` decimal(10, 2) NOT NULL COMMENT '应缴金额',
  `paid_amount` decimal(10, 2) NULL DEFAULT 0.00 COMMENT '已缴金额',
  `late_fee` decimal(10, 2) NULL DEFAULT 0.00 COMMENT '滞纳金',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '状态：0未缴 1已缴 2部分',
  `due_date` date NULL DEFAULT NULL COMMENT '截止日期',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '出账时间',
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`bill_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '费用账单表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of fn_bill
-- ----------------------------

-- ----------------------------
-- Table structure for fn_fee_item
-- ----------------------------
DROP TABLE IF EXISTS `fn_fee_item`;
CREATE TABLE `fn_fee_item`  (
  `item_id` bigint NOT NULL AUTO_INCREMENT COMMENT '收费项主键',
  `item_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '项目名称',
  `unit_price` decimal(10, 2) NULL DEFAULT 0.00 COMMENT '单价',
  `fee_type` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'property' COMMENT '类型：property/utility/parking/other',
  PRIMARY KEY (`item_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '收费项目表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of fn_fee_item
-- ----------------------------
INSERT INTO `fn_fee_item` VALUES (1, '物业费', 500.00, 'property');
INSERT INTO `fn_fee_item` VALUES (2, '水费', 50.00, 'utility');
INSERT INTO `fn_fee_item` VALUES (3, '电费', 80.00, 'utility');

-- ----------------------------
-- Table structure for fn_invoice
-- ----------------------------
DROP TABLE IF EXISTS `fn_invoice`;
CREATE TABLE `fn_invoice`  (
  `invoice_id` bigint NOT NULL AUTO_INCREMENT COMMENT '发票主键',
  `user_id` bigint NOT NULL COMMENT '申请用户ID',
  `bill_ids` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '关联账单ID',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '状态：0待开 1已开',
  `pdf_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT 'PDF地址',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '申请时间',
  PRIMARY KEY (`invoice_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '电子发票申请表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of fn_invoice
-- ----------------------------

-- ----------------------------
-- Table structure for fn_payment
-- ----------------------------
DROP TABLE IF EXISTS `fn_payment`;
CREATE TABLE `fn_payment`  (
  `payment_id` bigint NOT NULL AUTO_INCREMENT COMMENT '流水主键',
  `bill_id` bigint NOT NULL COMMENT '账单ID',
  `user_id` bigint NOT NULL COMMENT '缴费用户ID',
  `amount` decimal(10, 2) NOT NULL COMMENT '实缴金额',
  `pay_channel` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'online' COMMENT '渠道：online/offline',
  `trade_no` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '交易号',
  `pay_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '缴费时间',
  PRIMARY KEY (`payment_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '缴费流水表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of fn_payment
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
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '维修知识库文章表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of kb_article
-- ----------------------------

-- ----------------------------
-- Table structure for mt_plan
-- ----------------------------
DROP TABLE IF EXISTS `mt_plan`;
CREATE TABLE `mt_plan`  (
  `plan_id` bigint NOT NULL AUTO_INCREMENT COMMENT '计划主键',
  `equipment_id` bigint NOT NULL COMMENT '设备ID',
  `cycle_type` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '周期类型',
  `worker_id` bigint NULL DEFAULT NULL COMMENT '维保人员ID',
  `advance_days` int NULL DEFAULT 7 COMMENT '提前天数',
  `next_date` date NOT NULL COMMENT '下次维保日期',
  PRIMARY KEY (`plan_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '设备维保计划表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of mt_plan
-- ----------------------------

-- ----------------------------
-- Table structure for mt_record
-- ----------------------------
DROP TABLE IF EXISTS `mt_record`;
CREATE TABLE `mt_record`  (
  `record_id` bigint NOT NULL AUTO_INCREMENT COMMENT '记录主键',
  `equipment_id` bigint NOT NULL COMMENT '设备ID',
  `plan_id` bigint NULL DEFAULT NULL COMMENT '计划ID',
  `parts` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '更换零件',
  `test_data` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '测试数据',
  `suggestion` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '维保建议',
  `maintain_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '维保时间',
  PRIMARY KEY (`record_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '设备维保记录表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of mt_record
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
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '工单耗材登记表' ROW_FORMAT = Dynamic;

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
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '物料领用申请表' ROW_FORMAT = Dynamic;

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
  `sign_image` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '验收签名图',
  `reject_reason` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '拒单原因',
  `assign_reason` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '派单原因',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`order_id`) USING BTREE,
  UNIQUE INDEX `uk_order_no`(`order_no` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '报修工单表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of rp_order
-- ----------------------------

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
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '工单服务评价表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of rp_order_eval
-- ----------------------------

-- ----------------------------
-- Table structure for rp_order_image
-- ----------------------------
DROP TABLE IF EXISTS `rp_order_image`;
CREATE TABLE `rp_order_image`  (
  `image_id` bigint NOT NULL AUTO_INCREMENT COMMENT '图片主键',
  `order_id` bigint NOT NULL COMMENT '工单ID',
  `image_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '图片地址',
  PRIMARY KEY (`image_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '报修现场图片表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of rp_order_image
-- ----------------------------

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
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '工单进度节点表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of rp_order_progress
-- ----------------------------

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
) ENGINE = InnoDB AUTO_INCREMENT = 5 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '报修故障类型表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of rp_repair_type
-- ----------------------------
INSERT INTO `rp_repair_type` VALUES (1, 0, '水电', 1);
INSERT INTO `rp_repair_type` VALUES (2, 1, '水管漏水', 1);
INSERT INTO `rp_repair_type` VALUES (3, 0, '电路', 2);
INSERT INTO `rp_repair_type` VALUES (4, 3, '跳闸', 1);

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
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '维修工时打卡表' ROW_FORMAT = Dynamic;

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
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '维修工差评申诉表' ROW_FORMAT = Dynamic;

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
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '维修工档案表' ROW_FORMAT = Dynamic;

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
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '异常登录记录表' ROW_FORMAT = Dynamic;

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
) ENGINE = InnoDB AUTO_INCREMENT = 5 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '系统参数配置表' ROW_FORMAT = Dynamic;

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
) ENGINE = InnoDB AUTO_INCREMENT = 11 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '通用字典数据表' ROW_FORMAT = Dynamic;

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
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '通用字典类型表' ROW_FORMAT = Dynamic;

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
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '业务流程开关表' ROW_FORMAT = Dynamic;

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
) ENGINE = InnoDB AUTO_INCREMENT = 9 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '用户登录日志表' ROW_FORMAT = Dynamic;

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
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '菜单权限' ROW_FORMAT = Dynamic;

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
  PRIMARY KEY (`message_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '统一消息表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_message
-- ----------------------------

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
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '用户消息已读状态表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_message_user
-- ----------------------------

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
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '系统操作日志表' ROW_FORMAT = Dynamic;

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
) ENGINE = InnoDB AUTO_INCREMENT = 5 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '角色' ROW_FORMAT = Dynamic;

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
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

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
) ENGINE = InnoDB AUTO_INCREMENT = 6 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '系统用户表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_user
-- ----------------------------
INSERT INTO `sys_user` VALUES (2, 'owner01', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '张三', '13800000001', '', '', '0', NULL, 1, '0', '0', '2026-05-17 18:16:04', '2026-05-17 18:16:04');
INSERT INTO `sys_user` VALUES (3, 'worker01', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '李师傅', '13800000002', '', '', '1', NULL, NULL, '0', '0', '2026-05-17 18:16:04', '2026-05-17 18:16:04');
INSERT INTO `sys_user` VALUES (4, 'property01', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '王管家', '13800000003', '', '', '2', NULL, NULL, '0', '0', '2026-05-17 18:16:04', '2026-05-17 18:16:04');
INSERT INTO `sys_user` VALUES (5, 'owner02', '$2a$10$BAztWWzXjDxqUs05A7C5DuW3vucHZdeXB1TGn6kqgarg6OOz2J6HC', 'Amy', '13123234455', '', '', '0', NULL, NULL, '0', '0', '2026-05-17 18:35:15', '2026-05-17 18:35:15');

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
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '用户登录设备表' ROW_FORMAT = Dynamic;

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
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_user_role
-- ----------------------------
INSERT INTO `sys_user_role` VALUES (1, 1);
INSERT INTO `sys_user_role` VALUES (2, 2);
INSERT INTO `sys_user_role` VALUES (3, 3);
INSERT INTO `sys_user_role` VALUES (4, 4);

SET FOREIGN_KEY_CHECKS = 1;
