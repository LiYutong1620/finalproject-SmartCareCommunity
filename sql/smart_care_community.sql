/*
 Smart Care Community - 完整数据库脚本
 用途：全新导入（会先 DROP 再 CREATE 全部表）
 数据库：smart_care_community
 生成日期：2026-06-27
*/

CREATE DATABASE IF NOT EXISTS `smart_care_community` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE `smart_care_community`;

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
  `remark` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '备注',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`building_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 11 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '楼栋信息表' ROW_FORMAT = Dynamic;

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
) ENGINE = InnoDB AUTO_INCREMENT = 101 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '房屋信息表' ROW_FORMAT = Dynamic;

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
-- 备注数据升级（已有库可单独执行以下语句刷新楼栋/房屋备注）
-- ----------------------------
UPDATE `cm_building` SET `remark` = '临近小区东门，设有独立快递柜与非机动车棚，物业值班室在一层' WHERE `building_id` = 1;
UPDATE `cm_building` SET `remark` = '中庭景观楼，南北双电梯，一层为架空活动区，适合亲子活动' WHERE `building_id` = 2;
UPDATE `cm_building` SET `remark` = '靠西侧河道，低楼层视野开阔，噪音较小，绿化覆盖率高' WHERE `building_id` = 3;
UPDATE `cm_building` SET `remark` = '超高层塔楼，配备高速电梯与避难层，每层8户，视野极佳' WHERE `building_id` = 4;
UPDATE `cm_building` SET `remark` = '小型精品楼栋，总户数少，管理更精细，门禁系统独立' WHERE `building_id` = 5;
UPDATE `cm_building` SET `remark` = '标准板式楼，楼间距大，采光充足，南北通透户型较多' WHERE `building_id` = 6;
UPDATE `cm_building` SET `remark` = '临近社区会所与游泳池，夏季活动方便，周末人流略多' WHERE `building_id` = 7;
UPDATE `cm_building` SET `remark` = '安静内侧楼座，远离主干道，适合居家休息，夜间较静' WHERE `building_id` = 8;
UPDATE `cm_building` SET `remark` = '靠近社区北门与商超，生活采购便利，早市步行5分钟' WHERE `building_id` = 9;
UPDATE `cm_building` SET `remark` = '南侧楼座，冬季日照时间长，适合老人居住，暖气供应稳定' WHERE `building_id` = 10;
UPDATE `cm_house` SET `remark` = '1栋101，一室一厅，建筑面积约58.00㎡；张三业主已登记入住，档案与系统账号已绑定，日常联系优先使用系统消息' WHERE `house_id` = 1;
UPDATE `cm_house` SET `remark` = '1栋102，两室一厅，建筑面积约64.50㎡；孙浩业主已登记入住，档案与系统账号已绑定，日常联系优先使用系统消息' WHERE `house_id` = 2;
UPDATE `cm_house` SET `remark` = '1栋201，两室两厅，建筑面积约71.00㎡；样板展示房，展示现代简约风格，供新业主参考' WHERE `house_id` = 3;
UPDATE `cm_house` SET `remark` = '1栋202，三室一厅，建筑面积约70.00㎡；当前空置，已做深度保洁，可拎包入住' WHERE `house_id` = 4;
UPDATE `cm_house` SET `remark` = '1栋301，三室两厅，建筑面积约76.50㎡；样板展示房，展示现代简约风格，供新业主参考' WHERE `house_id` = 5;
UPDATE `cm_house` SET `remark` = '1栋302，四室两厅，建筑面积约83.00㎡；当前空置，已做深度保洁，可拎包入住' WHERE `house_id` = 6;
UPDATE `cm_house` SET `remark` = '1栋401，复式loft，建筑面积约82.00㎡；当前空置，南向采光好，曾做过短期租赁' WHERE `house_id` = 7;
UPDATE `cm_house` SET `remark` = '1栋501，跃层三居，建筑面积约88.50㎡；当前空置，南向采光好，曾做过短期租赁' WHERE `house_id` = 8;
UPDATE `cm_house` SET `remark` = '1栋502，精装两居，建筑面积约95.00㎡；当前空置，已做深度保洁，可拎包入住' WHERE `house_id` = 9;
UPDATE `cm_house` SET `remark` = '1栋601，阔景四居，建筑面积约94.00㎡；当前空置，南向采光好，曾做过短期租赁' WHERE `house_id` = 10;
UPDATE `cm_house` SET `remark` = '2栋101，一室一厅，建筑面积约61.00㎡；李芳业主已登记入住，档案与系统账号已绑定，日常联系优先使用系统消息' WHERE `house_id` = 11;
UPDATE `cm_house` SET `remark` = '2栋102，两室一厅，建筑面积约67.50㎡；马超业主已登记入住，档案与系统账号已绑定，日常联系优先使用系统消息' WHERE `house_id` = 12;
UPDATE `cm_house` SET `remark` = '2栋201，两室两厅，建筑面积约74.00㎡；样板展示房，展示现代简约风格，供新业主参考' WHERE `house_id` = 13;
UPDATE `cm_house` SET `remark` = '2栋202，三室一厅，建筑面积约73.00㎡；当前空置，已做深度保洁，可拎包入住' WHERE `house_id` = 14;
UPDATE `cm_house` SET `remark` = '2栋301，三室两厅，建筑面积约79.50㎡；样板展示房，展示现代简约风格，供新业主参考' WHERE `house_id` = 15;
UPDATE `cm_house` SET `remark` = '2栋302，四室两厅，建筑面积约86.00㎡；当前空置，已做深度保洁，可拎包入住' WHERE `house_id` = 16;
UPDATE `cm_house` SET `remark` = '2栋401，复式loft，建筑面积约85.00㎡；当前空置，南向采光好，曾做过短期租赁' WHERE `house_id` = 17;
UPDATE `cm_house` SET `remark` = '2栋501，跃层三居，建筑面积约91.50㎡；当前空置，南向采光好，曾做过短期租赁' WHERE `house_id` = 18;
UPDATE `cm_house` SET `remark` = '2栋502，精装两居，建筑面积约98.00㎡；当前空置，已做深度保洁，可拎包入住' WHERE `house_id` = 19;
UPDATE `cm_house` SET `remark` = '2栋601，阔景四居，建筑面积约97.00㎡；当前空置，南向采光好，曾做过短期租赁' WHERE `house_id` = 20;
UPDATE `cm_house` SET `remark` = '3栋101，一室一厅，建筑面积约64.00㎡；王磊业主已登记入住，档案与系统账号已绑定，日常联系优先使用系统消息' WHERE `house_id` = 21;
UPDATE `cm_house` SET `remark` = '3栋102，两室一厅，建筑面积约70.50㎡；朱琳业主已登记入住，档案与系统账号已绑定，日常联系优先使用系统消息' WHERE `house_id` = 22;
UPDATE `cm_house` SET `remark` = '3栋201，两室两厅，建筑面积约77.00㎡；样板展示房，展示现代简约风格，供新业主参考' WHERE `house_id` = 23;
UPDATE `cm_house` SET `remark` = '3栋202，三室一厅，建筑面积约76.00㎡；当前空置，已做深度保洁，可拎包入住' WHERE `house_id` = 24;
UPDATE `cm_house` SET `remark` = '3栋301，三室两厅，建筑面积约82.50㎡；样板展示房，展示现代简约风格，供新业主参考' WHERE `house_id` = 25;
UPDATE `cm_house` SET `remark` = '3栋302，四室两厅，建筑面积约89.00㎡；当前空置，已做深度保洁，可拎包入住' WHERE `house_id` = 26;
UPDATE `cm_house` SET `remark` = '3栋401，复式loft，建筑面积约88.00㎡；当前空置，南向采光好，曾做过短期租赁' WHERE `house_id` = 27;
UPDATE `cm_house` SET `remark` = '3栋501，跃层三居，建筑面积约94.50㎡；当前空置，南向采光好，曾做过短期租赁' WHERE `house_id` = 28;
UPDATE `cm_house` SET `remark` = '3栋502，精装两居，建筑面积约101.00㎡；当前空置，已做深度保洁，可拎包入住' WHERE `house_id` = 29;
UPDATE `cm_house` SET `remark` = '3栋601，阔景四居，建筑面积约100.00㎡；当前空置，南向采光好，曾做过短期租赁' WHERE `house_id` = 30;
UPDATE `cm_house` SET `remark` = '4栋101，一室一厅，建筑面积约67.00㎡；赵敏业主已登记入住，档案与系统账号已绑定，日常联系优先使用系统消息' WHERE `house_id` = 31;
UPDATE `cm_house` SET `remark` = '4栋102，两室一厅，建筑面积约73.50㎡；胡军业主已登记入住，档案与系统账号已绑定，日常联系优先使用系统消息' WHERE `house_id` = 32;
UPDATE `cm_house` SET `remark` = '4栋201，两室两厅，建筑面积约80.00㎡；样板展示房，展示现代简约风格，供新业主参考' WHERE `house_id` = 33;
UPDATE `cm_house` SET `remark` = '4栋202，三室一厅，建筑面积约79.00㎡；当前空置，已做深度保洁，可拎包入住' WHERE `house_id` = 34;
UPDATE `cm_house` SET `remark` = '4栋301，三室两厅，建筑面积约85.50㎡；样板展示房，展示现代简约风格，供新业主参考' WHERE `house_id` = 35;
UPDATE `cm_house` SET `remark` = '4栋302，四室两厅，建筑面积约92.00㎡；当前空置，已做深度保洁，可拎包入住' WHERE `house_id` = 36;
UPDATE `cm_house` SET `remark` = '4栋401，复式loft，建筑面积约91.00㎡；当前空置，南向采光好，曾做过短期租赁' WHERE `house_id` = 37;
UPDATE `cm_house` SET `remark` = '4栋501，跃层三居，建筑面积约97.50㎡；当前空置，南向采光好，曾做过短期租赁' WHERE `house_id` = 38;
UPDATE `cm_house` SET `remark` = '4栋502，精装两居，建筑面积约104.00㎡；当前空置，已做深度保洁，可拎包入住' WHERE `house_id` = 39;
UPDATE `cm_house` SET `remark` = '4栋601，阔景四居，建筑面积约103.00㎡；当前空置，南向采光好，曾做过短期租赁' WHERE `house_id` = 40;
UPDATE `cm_house` SET `remark` = '5栋101，一室一厅，建筑面积约70.00㎡；刘洋业主已登记入住，档案与系统账号已绑定，日常联系优先使用系统消息' WHERE `house_id` = 41;
UPDATE `cm_house` SET `remark` = '5栋102，两室一厅，建筑面积约76.50㎡；林雪业主已登记入住，档案与系统账号已绑定，日常联系优先使用系统消息' WHERE `house_id` = 42;
UPDATE `cm_house` SET `remark` = '5栋201，两室两厅，建筑面积约83.00㎡；样板展示房，展示现代简约风格，供新业主参考' WHERE `house_id` = 43;
UPDATE `cm_house` SET `remark` = '5栋202，三室一厅，建筑面积约82.00㎡；当前空置，已做深度保洁，可拎包入住' WHERE `house_id` = 44;
UPDATE `cm_house` SET `remark` = '5栋301，三室两厅，建筑面积约88.50㎡；样板展示房，展示现代简约风格，供新业主参考' WHERE `house_id` = 45;
UPDATE `cm_house` SET `remark` = '5栋302，四室两厅，建筑面积约95.00㎡；当前空置，已做深度保洁，可拎包入住' WHERE `house_id` = 46;
UPDATE `cm_house` SET `remark` = '5栋401，复式loft，建筑面积约94.00㎡；当前空置，南向采光好，曾做过短期租赁' WHERE `house_id` = 47;
UPDATE `cm_house` SET `remark` = '5栋501，跃层三居，建筑面积约100.50㎡；当前空置，南向采光好，曾做过短期租赁' WHERE `house_id` = 48;
UPDATE `cm_house` SET `remark` = '5栋502，精装两居，建筑面积约107.00㎡；当前空置，已做深度保洁，可拎包入住' WHERE `house_id` = 49;
UPDATE `cm_house` SET `remark` = '5栋601，阔景四居，建筑面积约106.00㎡；当前空置，南向采光好，曾做过短期租赁' WHERE `house_id` = 50;
UPDATE `cm_house` SET `remark` = '6栋101，一室一厅，建筑面积约73.00㎡；陈静业主已登记入住，档案与系统账号已绑定，日常联系优先使用系统消息' WHERE `house_id` = 51;
UPDATE `cm_house` SET `remark` = '6栋102，两室一厅，建筑面积约79.50㎡；当前空置，已做深度保洁，可拎包入住' WHERE `house_id` = 52;
UPDATE `cm_house` SET `remark` = '6栋201，两室两厅，建筑面积约86.00㎡；样板展示房，展示现代简约风格，供新业主参考' WHERE `house_id` = 53;
UPDATE `cm_house` SET `remark` = '6栋202，三室一厅，建筑面积约85.00㎡；当前空置，已做深度保洁，可拎包入住' WHERE `house_id` = 54;
UPDATE `cm_house` SET `remark` = '6栋301，三室两厅，建筑面积约91.50㎡；样板展示房，展示现代简约风格，供新业主参考' WHERE `house_id` = 55;
UPDATE `cm_house` SET `remark` = '6栋302，四室两厅，建筑面积约98.00㎡；当前空置，已做深度保洁，可拎包入住' WHERE `house_id` = 56;
UPDATE `cm_house` SET `remark` = '6栋401，复式loft，建筑面积约97.00㎡；当前空置，南向采光好，曾做过短期租赁' WHERE `house_id` = 57;
UPDATE `cm_house` SET `remark` = '6栋501，跃层三居，建筑面积约103.50㎡；当前空置，南向采光好，曾做过短期租赁' WHERE `house_id` = 58;
UPDATE `cm_house` SET `remark` = '6栋502，精装两居，建筑面积约110.00㎡；当前空置，已做深度保洁，可拎包入住' WHERE `house_id` = 59;
UPDATE `cm_house` SET `remark` = '6栋601，阔景四居，建筑面积约109.00㎡；当前空置，南向采光好，曾做过短期租赁' WHERE `house_id` = 60;
UPDATE `cm_house` SET `remark` = '7栋101，一室一厅，建筑面积约76.00㎡；杨帆业主已登记入住，档案与系统账号已绑定，日常联系优先使用系统消息' WHERE `house_id` = 61;
UPDATE `cm_house` SET `remark` = '7栋102，两室一厅，建筑面积约82.50㎡；当前空置，已做深度保洁，可拎包入住' WHERE `house_id` = 62;
UPDATE `cm_house` SET `remark` = '7栋201，两室两厅，建筑面积约89.00㎡；样板展示房，展示现代简约风格，供新业主参考' WHERE `house_id` = 63;
UPDATE `cm_house` SET `remark` = '7栋202，三室一厅，建筑面积约88.00㎡；当前空置，已做深度保洁，可拎包入住' WHERE `house_id` = 64;
UPDATE `cm_house` SET `remark` = '7栋301，三室两厅，建筑面积约94.50㎡；样板展示房，展示现代简约风格，供新业主参考' WHERE `house_id` = 65;
UPDATE `cm_house` SET `remark` = '7栋302，四室两厅，建筑面积约101.00㎡；当前空置，已做深度保洁，可拎包入住' WHERE `house_id` = 66;
UPDATE `cm_house` SET `remark` = '7栋401，复式loft，建筑面积约100.00㎡；当前空置，南向采光好，曾做过短期租赁' WHERE `house_id` = 67;
UPDATE `cm_house` SET `remark` = '7栋501，跃层三居，建筑面积约106.50㎡；当前空置，南向采光好，曾做过短期租赁' WHERE `house_id` = 68;
UPDATE `cm_house` SET `remark` = '7栋502，精装两居，建筑面积约113.00㎡；当前空置，已做深度保洁，可拎包入住' WHERE `house_id` = 69;
UPDATE `cm_house` SET `remark` = '7栋601，阔景四居，建筑面积约112.00㎡；当前空置，南向采光好，曾做过短期租赁' WHERE `house_id` = 70;
UPDATE `cm_house` SET `remark` = '8栋101，一室一厅，建筑面积约79.00㎡；周婷业主已登记入住，档案与系统账号已绑定，日常联系优先使用系统消息' WHERE `house_id` = 71;
UPDATE `cm_house` SET `remark` = '8栋102，两室一厅，建筑面积约85.50㎡；当前空置，已做深度保洁，可拎包入住' WHERE `house_id` = 72;
UPDATE `cm_house` SET `remark` = '8栋201，两室两厅，建筑面积约92.00㎡；样板展示房，展示现代简约风格，供新业主参考' WHERE `house_id` = 73;
UPDATE `cm_house` SET `remark` = '8栋202，三室一厅，建筑面积约91.00㎡；当前空置，已做深度保洁，可拎包入住' WHERE `house_id` = 74;
UPDATE `cm_house` SET `remark` = '8栋301，三室两厅，建筑面积约97.50㎡；样板展示房，展示现代简约风格，供新业主参考' WHERE `house_id` = 75;
UPDATE `cm_house` SET `remark` = '8栋302，四室两厅，建筑面积约104.00㎡；当前空置，已做深度保洁，可拎包入住' WHERE `house_id` = 76;
UPDATE `cm_house` SET `remark` = '8栋401，复式loft，建筑面积约103.00㎡；当前空置，南向采光好，曾做过短期租赁' WHERE `house_id` = 77;
UPDATE `cm_house` SET `remark` = '8栋501，跃层三居，建筑面积约109.50㎡；当前空置，南向采光好，曾做过短期租赁' WHERE `house_id` = 78;
UPDATE `cm_house` SET `remark` = '8栋502，精装两居，建筑面积约116.00㎡；当前空置，已做深度保洁，可拎包入住' WHERE `house_id` = 79;
UPDATE `cm_house` SET `remark` = '8栋601，阔景四居，建筑面积约115.00㎡；当前空置，南向采光好，曾做过短期租赁' WHERE `house_id` = 80;
UPDATE `cm_house` SET `remark` = '9栋101，一室一厅，建筑面积约82.00㎡；吴刚业主已登记入住，档案与系统账号已绑定，日常联系优先使用系统消息' WHERE `house_id` = 81;
UPDATE `cm_house` SET `remark` = '9栋102，两室一厅，建筑面积约88.50㎡；当前空置，已做深度保洁，可拎包入住' WHERE `house_id` = 82;
UPDATE `cm_house` SET `remark` = '9栋201，两室两厅，建筑面积约95.00㎡；样板展示房，展示现代简约风格，供新业主参考' WHERE `house_id` = 83;
UPDATE `cm_house` SET `remark` = '9栋202，三室一厅，建筑面积约94.00㎡；当前空置，已做深度保洁，可拎包入住' WHERE `house_id` = 84;
UPDATE `cm_house` SET `remark` = '9栋301，三室两厅，建筑面积约100.50㎡；样板展示房，展示现代简约风格，供新业主参考' WHERE `house_id` = 85;
UPDATE `cm_house` SET `remark` = '9栋302，四室两厅，建筑面积约107.00㎡；当前空置，已做深度保洁，可拎包入住' WHERE `house_id` = 86;
UPDATE `cm_house` SET `remark` = '9栋401，复式loft，建筑面积约106.00㎡；当前空置，南向采光好，曾做过短期租赁' WHERE `house_id` = 87;
UPDATE `cm_house` SET `remark` = '9栋501，跃层三居，建筑面积约112.50㎡；当前空置，南向采光好，曾做过短期租赁' WHERE `house_id` = 88;
UPDATE `cm_house` SET `remark` = '9栋502，精装两居，建筑面积约119.00㎡；当前空置，已做深度保洁，可拎包入住' WHERE `house_id` = 89;
UPDATE `cm_house` SET `remark` = '9栋601，阔景四居，建筑面积约118.00㎡；当前空置，南向采光好，曾做过短期租赁' WHERE `house_id` = 90;
UPDATE `cm_house` SET `remark` = '10栋101，一室一厅，建筑面积约85.00㎡；郑丽业主已登记入住，档案与系统账号已绑定，日常联系优先使用系统消息' WHERE `house_id` = 91;
UPDATE `cm_house` SET `remark` = '10栋102，两室一厅，建筑面积约91.50㎡；当前空置，已做深度保洁，可拎包入住' WHERE `house_id` = 92;
UPDATE `cm_house` SET `remark` = '10栋201，两室两厅，建筑面积约98.00㎡；样板展示房，展示现代简约风格，供新业主参考' WHERE `house_id` = 93;
UPDATE `cm_house` SET `remark` = '10栋202，三室一厅，建筑面积约97.00㎡；当前空置，已做深度保洁，可拎包入住' WHERE `house_id` = 94;
UPDATE `cm_house` SET `remark` = '10栋301，三室两厅，建筑面积约103.50㎡；样板展示房，展示现代简约风格，供新业主参考' WHERE `house_id` = 95;
UPDATE `cm_house` SET `remark` = '10栋302，四室两厅，建筑面积约110.00㎡；当前空置，已做深度保洁，可拎包入住' WHERE `house_id` = 96;
UPDATE `cm_house` SET `remark` = '10栋401，复式loft，建筑面积约109.00㎡；当前空置，南向采光好，曾做过短期租赁' WHERE `house_id` = 97;
UPDATE `cm_house` SET `remark` = '10栋501，跃层三居，建筑面积约115.50㎡；当前空置，南向采光好，曾做过短期租赁' WHERE `house_id` = 98;
UPDATE `cm_house` SET `remark` = '10栋502，精装两居，建筑面积约122.00㎡；当前空置，已做深度保洁，可拎包入住' WHERE `house_id` = 99;
UPDATE `cm_house` SET `remark` = '10栋601，阔景四居，建筑面积约121.00㎡；当前空置，南向采光好，曾做过短期租赁' WHERE `house_id` = 100;

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
  `family_members` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '家庭成员JSON',
  `del_flag` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '删除：0存在 2删除',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`resident_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 16 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '住户档案表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of cm_resident
-- ----------------------------
INSERT INTO `cm_resident` VALUES (1, 2, 1, '张三', '', '13810000001', '0', '2023-01-15', '', '', '0', '2026-05-01 08:00:00', '2026-05-01 08:00:00');
INSERT INTO `cm_resident` VALUES (2, 5, 11, '李芳', '', '13810000002', '0', '2023-02-15', '', '', '0', '2026-05-01 08:00:00', '2026-05-01 08:00:00');
INSERT INTO `cm_resident` VALUES (3, 6, 21, '王磊', '', '13810000003', '0', '2023-03-15', '', '', '0', '2026-05-01 08:00:00', '2026-05-01 08:00:00');
INSERT INTO `cm_resident` VALUES (4, 7, 31, '赵敏', '', '13810000004', '0', '2023-04-15', '', '', '0', '2026-05-01 08:00:00', '2026-05-01 08:00:00');
INSERT INTO `cm_resident` VALUES (5, 8, 41, '刘洋', '', '13810000005', '0', '2023-05-15', '', '', '0', '2026-05-01 08:00:00', '2026-05-01 08:00:00');
INSERT INTO `cm_resident` VALUES (6, 9, 51, '陈静', '', '13810000006', '0', '2023-06-15', '', '', '0', '2026-05-01 08:00:00', '2026-05-01 08:00:00');
INSERT INTO `cm_resident` VALUES (7, 10, 61, '杨帆', '', '13810000007', '0', '2023-07-15', '', '', '0', '2026-05-01 08:00:00', '2026-05-01 08:00:00');
INSERT INTO `cm_resident` VALUES (8, 11, 71, '周婷', '', '13810000008', '0', '2023-08-15', '', '', '0', '2026-05-01 08:00:00', '2026-05-01 08:00:00');
INSERT INTO `cm_resident` VALUES (9, 12, 81, '吴刚', '', '13810000009', '0', '2023-09-15', '', '', '0', '2026-05-01 08:00:00', '2026-05-01 08:00:00');
INSERT INTO `cm_resident` VALUES (10, 13, 91, '郑丽', '', '13810000010', '0', '2023-10-15', '', '', '0', '2026-05-01 08:00:00', '2026-05-01 08:00:00');
INSERT INTO `cm_resident` VALUES (11, 14, 2, '孙浩', '', '13810000011', '0', '2023-11-15', '', '', '0', '2026-05-01 08:00:00', '2026-05-01 08:00:00');
INSERT INTO `cm_resident` VALUES (12, 15, 12, '马超', '', '13810000012', '0', '2023-12-15', '', '', '0', '2026-05-01 08:00:00', '2026-05-01 08:00:00');
INSERT INTO `cm_resident` VALUES (13, 16, 22, '朱琳', '', '13810000013', '0', '2023-01-15', '', '', '0', '2026-05-01 08:00:00', '2026-05-01 08:00:00');
INSERT INTO `cm_resident` VALUES (14, 17, 32, '胡军', '', '13810000014', '0', '2023-02-15', '', '', '0', '2026-05-01 08:00:00', '2026-05-01 08:00:00');
INSERT INTO `cm_resident` VALUES (15, 18, 42, '林雪', '', '13810000015', '0', '2023-03-15', '', '', '0', '2026-05-01 08:00:00', '2026-05-01 08:00:00');

-- ----------------------------
-- Table structure for cm_resident_tag
-- ----------------------------
DROP TABLE IF EXISTS `cm_resident_tag`;
CREATE TABLE `cm_resident_tag`  (
  `tag_id` bigint NOT NULL AUTO_INCREMENT COMMENT '标签主键',
  `tag_name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '标签名称',
  `tag_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'custom' COMMENT '类型：elder/disabled/custom等',
  PRIMARY KEY (`tag_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 7 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '住户标签定义表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of cm_resident_tag
-- ----------------------------
INSERT INTO `cm_resident_tag` VALUES (1, '独居老人', 'elder');
INSERT INTO `cm_resident_tag` VALUES (2, '高龄老人', 'elder');
INSERT INTO `cm_resident_tag` VALUES (3, '残疾人', 'disabled');
INSERT INTO `cm_resident_tag` VALUES (4, '党员', 'custom');
INSERT INTO `cm_resident_tag` VALUES (5, '志愿者', 'custom');
INSERT INTO `cm_resident_tag` VALUES (6, '宠物家庭', 'custom');

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
  INDEX `idx_notice_list`(`status`, `notice_type`, `create_time`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 31 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '社区公告通知表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of cs_notice
-- ----------------------------
INSERT INTO `cs_notice` VALUES (1, 'announce', '清明节文明祭扫倡议', '清明将至，倡导鲜花祭扫、网络祭扫等文明方式。请勿在楼道、阳台堆放纸钱等易燃物，祭扫后确认火源完全熄灭。', '', 1, NULL, NULL, '', NULL, NULL, '1', 4, '2026-04-02 09:00:00', '2026-04-02 09:00:00');
INSERT INTO `cs_notice` VALUES (2, 'announce', '春季绿化补种通知', '4月10日至15日，物业将在中心花园及主干道两侧补种灌木与草坪。作业期间请勿进入围挡区域，如有宠物请牵绳绕行。', '', 0, NULL, NULL, '', NULL, '2026-06-15 23:59:59', '1', 4, '2026-04-08 10:00:00', '2026-04-08 10:00:00');
INSERT INTO `cs_notice` VALUES (3, 'announce', '五一劳动节放假安排', '5月1日至5月3日放假，物业服务中心5月1日9:00-12:00值班，5月2日起正常办公。紧急报修请拨打24小时热线。', '', 0, NULL, NULL, '', NULL, NULL, '0', 4, '2026-04-20 08:30:00', '2026-04-25 18:00:00');
INSERT INTO `cs_notice` VALUES (4, 'announce', '端午节包粽子活动通知', '社区将于6月9日14:00在活动中心举办包粽子活动，限40组家庭，额满即止。报名请联系楼栋管家或至物业前台登记。', '', 1, NULL, NULL, '', NULL, NULL, '2', 4, '2026-06-05 09:00:00', '2026-06-05 09:00:00');
INSERT INTO `cs_notice` VALUES (5, 'announce', '夏季消防安全演练安排', '定于5月18日15:00在中心广场进行消防疏散演练，请各楼栋配合物业工作人员指引。演练期间请勿围观堵塞通道。', '', 0, NULL, NULL, '', NULL, NULL, '1', 4, '2026-05-10 14:00:00', '2026-05-10 14:00:00');
INSERT INTO `cs_notice` VALUES (6, 'announce', '小区绿化修剪公告', '5月22日至24日将进行绿化修剪，作业时间8:30-17:30。请勿在作业区域停放车辆，修剪期间可能有轻微噪音，敬请谅解。', '', 0, NULL, NULL, '', NULL, '2026-05-31 23:59:59', '1', 4, '2026-05-12 08:00:00', '2026-05-12 08:00:00');
INSERT INTO `cs_notice` VALUES (7, 'announce', '亲子运动会报名开启', '6月15日举办亲子运动会，设跳绳、接力等项目。线上报名截止6月8日，可在业主群或物业前台填写报名表。', '', 0, NULL, NULL, '', NULL, NULL, '2', 4, '2026-06-01 10:00:00', '2026-06-01 10:00:00');
INSERT INTO `cs_notice` VALUES (8, 'announce', '电梯年度检修告知', '5月25日起分批检修各栋电梯，单次停梯约2-4小时。具体时段见各单元门口张贴通知，检修期间请优先步行或错峰乘梯。', '', 0, NULL, NULL, '', NULL, NULL, '1', 4, '2026-05-15 11:00:00', '2026-05-15 11:00:00');
INSERT INTO `cs_notice` VALUES (9, 'announce', '宠物文明饲养倡议', '请遛宠时使用牵引绳，及时清理宠物排泄物。禁止在公共区域放养，避免犬吠扰民。违反规定者将按公约劝导处理。', '', 0, NULL, NULL, '', NULL, NULL, '0', 4, '2026-04-05 09:00:00', '2026-04-10 09:00:00');
INSERT INTO `cs_notice` VALUES (10, 'announce', '地下车库清洗通知', '6月6日清洗B1、B2层车库，当日8:00-18:00请尽量驶离或配合移位。清洗后地面湿滑，请注意行车安全。', '', 0, NULL, NULL, '', NULL, NULL, '1', 4, '2026-05-28 16:00:00', '2026-05-28 16:00:00');
INSERT INTO `cs_notice` VALUES (11, 'announce', '业主大会表决事项预告', '关于增设新能源充电桩方案，定于6月20日19:00在社区会议室召开业主大会表决。材料已张贴于各栋公告栏，欢迎查阅。', '', 1, NULL, NULL, '', NULL, NULL, '2', 4, '2026-06-10 09:00:00', '2026-06-10 09:00:00');
INSERT INTO `cs_notice` VALUES (12, 'announce', '蚊虫消杀作业公告', '6月3日晚20:00-22:00全小区消杀，请关好门窗，收好食品。消杀后30分钟内避免开窗，儿童宠物请勿接触药剂喷洒区域。', '', 0, NULL, NULL, '', NULL, NULL, '1', 4, '2026-05-30 08:00:00', '2026-05-30 08:00:00');
INSERT INTO `cs_notice` VALUES (13, 'announce', '快递柜系统升级说明', '5月16日22:00-24:00升级快递柜系统，期间可能无法取件。请提前取走重要快件，升级完成后需重新验证手机号。', '', 0, NULL, NULL, '', NULL, '2026-05-20 08:00:00', '1', 4, '2026-05-14 09:30:00', '2026-05-14 09:30:00');
INSERT INTO `cs_notice` VALUES (14, 'announce', '儿童节礼品领取通知', '6月1日9:00-17:00在一层大堂领取儿童节礼品，每户限领一份。请携带业主身份证明，代领需出示授权信息。', '', 0, NULL, NULL, '', NULL, NULL, '1', 4, '2026-05-25 10:00:00', '2026-05-25 10:00:00');
INSERT INTO `cs_notice` VALUES (15, 'announce', '高温防暑温馨提示', '6月起进入高温季节，请注意防暑补水。建议老人儿童减少11:00-15:00户外活动，室内空调温度不宜过低，避免室内外温差过大。', '', 0, NULL, NULL, '', NULL, NULL, '1', 4, '2026-06-01 07:30:00', '2026-06-01 07:30:00');
INSERT INTO `cs_notice` VALUES (16, 'outage', '1栋停水检修通知', '因主管道阀门更换，1栋将于5月12日9:00-17:00暂停供水。请提前储水，恢复供水初期水质可能短暂浑浊，放水后即可正常使用。', '', 1, NULL, NULL, '1栋全体住户', '2026-05-12 17:00:00', NULL, '1', 4, '2026-05-11 08:00:00', '2026-05-11 08:00:00');
INSERT INTO `cs_notice` VALUES (17, 'outage', '2栋配电室停电检修', '2栋配电室设备检修，5月14日8:30-11:30全栋停电。请提前保存电脑数据，电梯将暂停运行，高层住户请合理安排出行。', '', 0, NULL, NULL, '2栋', '2026-05-14 11:30:00', NULL, '1', 4, '2026-05-13 09:00:00', '2026-05-13 09:00:00');
INSERT INTO `cs_notice` VALUES (18, 'outage', '3栋水泵更换停水', '3栋二次供水水泵更换，5月20日14:00-18:00低区停水。请关闭热水器进水阀，恢复供水后再开启，防止空烧损坏设备。', '', 0, NULL, NULL, '3栋低区', '2026-05-20 18:00:00', NULL, '2', 4, '2026-06-08 14:00:00', '2026-06-08 14:00:00');
INSERT INTO `cs_notice` VALUES (19, 'outage', '4栋电梯机房停电', '4栋电梯机房维护，5月22日13:00-15:00电梯全部暂停。请提前规划上下楼路线，老人及行动不便住户可联系物业协助。', '', 0, NULL, NULL, '4栋', '2026-05-22 15:00:00', NULL, '1', 4, '2026-05-21 10:00:00', '2026-05-21 10:00:00');
INSERT INTO `cs_notice` VALUES (20, 'outage', '5栋燃气安全检查停气', '5栋5月25日9:00-12:00停气检修。请提前关闭灶具阀门，恢复通气后先开窗通风再点火，确保安全。', '', 0, NULL, NULL, '5栋', '2026-05-25 12:00:00', NULL, '1', 4, '2026-05-24 08:30:00', '2026-05-24 08:30:00');
INSERT INTO `cs_notice` VALUES (21, 'outage', '6栋水箱清洗停水', '6栋水箱清洗消毒，4月18日10:00-16:00停水。清洗完成后水质符合标准再恢复供水，如有疑问请联系物业工程部。', '', 0, NULL, NULL, '6栋', '2026-04-18 16:00:00', NULL, '0', 4, '2026-04-15 09:00:00', '2026-04-20 10:00:00');
INSERT INTO `cs_notice` VALUES (22, 'outage', '7栋线路改造停电', '7栋供电线路改造，6月12日0:00-6:00全栋停电。请提前为手机、应急灯充电，凌晨时段请注意出行安全。', '', 1, NULL, NULL, '7栋', '2026-06-12 06:00:00', NULL, '1', 4, '2026-06-10 12:00:00', '2026-06-10 12:00:00');
INSERT INTO `cs_notice` VALUES (23, 'outage', '8栋主水管维修停水', '8栋主水管维修，6月18日8:00-12:00停水。工程车可能占用临时车位，请配合现场疏导，带来不便敬请谅解。', '', 0, NULL, NULL, '8栋', '2026-06-18 12:00:00', NULL, '2', 4, '2026-06-15 08:00:00', '2026-06-15 08:00:00');
INSERT INTO `cs_notice` VALUES (24, 'outage', '9栋公区照明改造停电', '9栋大堂及走廊照明改造，5月28日19:00-22:00公区停电。请使用手机照明，注意台阶安全，改造完成后照明将更加节能明亮。', '', 0, NULL, NULL, '9栋公区', '2026-05-28 22:00:00', NULL, '1', 4, '2026-05-27 15:00:00', '2026-05-27 15:00:00');
INSERT INTO `cs_notice` VALUES (25, 'outage', '10栋阀门更换停水', '10栋总阀更换，6月2日9:00-11:00停水。停水时间较短，请提前储少量生活用水，恢复后请先放清管道存水。', '', 0, NULL, NULL, '10栋', '2026-06-02 11:00:00', NULL, '1', 4, '2026-06-01 09:00:00', '2026-06-01 09:00:00');
INSERT INTO `cs_notice` VALUES (26, 'outage', '中心广场活动临时停电', '广场端午活动用电调试，6月8日18:00-20:00周边路灯及景观灯关闭。调试结束后立即恢复，请夜间出行注意瞭望。', '', 0, NULL, NULL, '中心广场周边', '2026-06-08 20:00:00', NULL, '1', 4, '2026-06-07 10:00:00', '2026-06-07 10:00:00');
INSERT INTO `cs_notice` VALUES (27, 'outage', '地下车库B1消防测试停水', 'B1层消防管道测试，4月25日15:00-17:00临时停水。测试期间可能有警报声，属正常现象，请勿恐慌。', '', 0, NULL, NULL, 'B1车库', '2026-04-25 17:00:00', NULL, '0', 4, '2026-04-22 11:00:00', '2026-04-26 09:00:00');
INSERT INTO `cs_notice` VALUES (28, 'outage', '1-3栋联动检修停水', '6月25日8:00-18:00，1至3栋低区联动停水检修。影响范围较大，请提前储备24小时用水，物业将在大堂提供应急供水。', '', 0, NULL, NULL, '1-3栋低区', '2026-06-25 18:00:00', NULL, '2', 4, '2026-06-20 09:00:00', '2026-06-20 09:00:00');
INSERT INTO `cs_notice` VALUES (29, 'outage', '全小区消防联动测试停电', '6月30日10:00-10:30消防联动测试，全小区电梯可能短暂停运，门禁系统切换备用电源。测试结束后自动恢复正常。', '', 0, NULL, NULL, '全小区', '2026-06-30 10:30:00', NULL, '1', 4, '2026-06-28 08:00:00', '2026-06-28 08:00:00');
INSERT INTO `cs_notice` VALUES (30, 'outage', '4栋计划停水（待发布）', '4栋主供水管计划7月5日8:00-14:00停水检修，具体以现场条件为准。本通知待工程方案确认后正式发布，请提前关注后续更新。', '', 0, NULL, NULL, '4栋', '2026-07-05 14:00:00', NULL, '2', 4, '2026-06-22 09:00:00', '2026-06-22 09:00:00');

-- ----------------------------
-- Table structure for cs_notice_read
-- ----------------------------
DROP TABLE IF EXISTS `cs_notice_read`;
CREATE TABLE `cs_notice_read`  (
  `notice_id` bigint NOT NULL COMMENT '公告ID',
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `read_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '阅读时间',
  PRIMARY KEY (`notice_id`, `user_id`) USING BTREE,
  INDEX `idx_user`(`user_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '公告已读记录表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of cs_notice_read
-- ----------------------------
INSERT INTO `cs_notice_read` VALUES (1, 2, '2026-05-02 10:00:00'), (3, 2, '2026-05-06 09:00:00'), (16, 2, '2026-05-12 08:30:00');

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
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '老人异常预警表' ROW_FORMAT = Dynamic;

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
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '独居老人关怀工单表' ROW_FORMAT = Dynamic;

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
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '关怀人员台账表' ROW_FORMAT = Dynamic;

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
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '异常事件分级处置预案表' ROW_FORMAT = Dynamic;

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
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '老人健康数据记录表' ROW_FORMAT = Dynamic;

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
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '健康数据告警阈值表' ROW_FORMAT = Dynamic;

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
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '定期关怀回访计划表' ROW_FORMAT = Dynamic;

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
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '维修知识库文章表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of kb_article
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
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '工单耗材登记表' ROW_FORMAT = Dynamic;

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
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '物料领用申请表' ROW_FORMAT = Dynamic;

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
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '报修工单表' ROW_FORMAT = Dynamic;

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
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '工单服务评价表' ROW_FORMAT = Dynamic;

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
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '报修现场图片表' ROW_FORMAT = Dynamic;

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
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '工单进度节点表' ROW_FORMAT = Dynamic;

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
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '维修工时打卡表' ROW_FORMAT = Dynamic;

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
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '维修工差评申诉表' ROW_FORMAT = Dynamic;

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
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '异常登录记录表' ROW_FORMAT = Dynamic;

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
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '业务流程开关表' ROW_FORMAT = Dynamic;

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
) ENGINE = InnoDB AUTO_INCREMENT = 13 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '用户登录日志表' ROW_FORMAT = Dynamic;

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
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '菜单权限' ROW_FORMAT = Dynamic;

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
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '统一消息表' ROW_FORMAT = Dynamic;

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
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '用户消息已读状态表' ROW_FORMAT = Dynamic;

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
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '系统操作日志表' ROW_FORMAT = Dynamic;

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
) ENGINE = InnoDB AUTO_INCREMENT = 19 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '系统用户表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_user
-- ----------------------------
INSERT INTO `sys_user` VALUES (2, 'owner01', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '张三', '13810000001', '', '', '0', NULL, 1, '0', '0', '2026-05-01 08:00:00', '2026-05-01 08:00:00');
INSERT INTO `sys_user` VALUES (3, 'worker01', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '李师傅', '13800000002', '', '', '1', NULL, NULL, '0', '0', '2026-05-17 18:16:04', '2026-05-17 18:16:04');
INSERT INTO `sys_user` VALUES (4, 'property01', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '王管家', '13800000003', '', '', '2', NULL, NULL, '0', '0', '2026-05-17 18:16:04', '2026-05-17 18:16:04');
INSERT INTO `sys_user` VALUES (5, 'owner02', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '李芳', '13810000002', '', '', '0', NULL, 11, '0', '0', '2026-05-01 08:00:00', '2026-05-01 08:00:00');
INSERT INTO `sys_user` VALUES (6, 'owner03', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '王磊', '13810000003', '', '', '0', NULL, 21, '0', '0', '2026-05-01 08:00:00', '2026-05-01 08:00:00');
INSERT INTO `sys_user` VALUES (7, 'owner04', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '赵敏', '13810000004', '', '', '0', NULL, 31, '0', '0', '2026-05-01 08:00:00', '2026-05-01 08:00:00');
INSERT INTO `sys_user` VALUES (8, 'owner05', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '刘洋', '13810000005', '', '', '0', NULL, 41, '0', '0', '2026-05-01 08:00:00', '2026-05-01 08:00:00');
INSERT INTO `sys_user` VALUES (9, 'owner06', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '陈静', '13810000006', '', '', '0', NULL, 51, '0', '0', '2026-05-01 08:00:00', '2026-05-01 08:00:00');
INSERT INTO `sys_user` VALUES (10, 'owner07', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '杨帆', '13810000007', '', '', '0', NULL, 61, '0', '0', '2026-05-01 08:00:00', '2026-05-01 08:00:00');
INSERT INTO `sys_user` VALUES (11, 'owner08', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '周婷', '13810000008', '', '', '0', NULL, 71, '0', '0', '2026-05-01 08:00:00', '2026-05-01 08:00:00');
INSERT INTO `sys_user` VALUES (12, 'owner09', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '吴刚', '13810000009', '', '', '0', NULL, 81, '0', '0', '2026-05-01 08:00:00', '2026-05-01 08:00:00');
INSERT INTO `sys_user` VALUES (13, 'owner10', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '郑丽', '13810000010', '', '', '0', NULL, 91, '0', '0', '2026-05-01 08:00:00', '2026-05-01 08:00:00');
INSERT INTO `sys_user` VALUES (14, 'owner11', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '孙浩', '13810000011', '', '', '0', NULL, 2, '0', '0', '2026-05-01 08:00:00', '2026-05-01 08:00:00');
INSERT INTO `sys_user` VALUES (15, 'owner12', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '马超', '13810000012', '', '', '0', NULL, 12, '0', '0', '2026-05-01 08:00:00', '2026-05-01 08:00:00');
INSERT INTO `sys_user` VALUES (16, 'owner13', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '朱琳', '13810000013', '', '', '0', NULL, 22, '0', '0', '2026-05-01 08:00:00', '2026-05-01 08:00:00');
INSERT INTO `sys_user` VALUES (17, 'owner14', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '胡军', '13810000014', '', '', '0', NULL, 32, '0', '0', '2026-05-01 08:00:00', '2026-05-01 08:00:00');
INSERT INTO `sys_user` VALUES (18, 'owner15', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '林雪', '13810000015', '', '', '0', NULL, 42, '0', '0', '2026-05-01 08:00:00', '2026-05-01 08:00:00');

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
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '用户登录设备表' ROW_FORMAT = Dynamic;

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
INSERT INTO `sys_user_role` VALUES (2, 2);
INSERT INTO `sys_user_role` VALUES (3, 3);
INSERT INTO `sys_user_role` VALUES (4, 4);
INSERT INTO `sys_user_role` VALUES (5, 2), (6, 2), (7, 2), (8, 2), (9, 2), (10, 2), (11, 2), (12, 2), (13, 2), (14, 2), (15, 2), (16, 2), (17, 2), (18, 2);
