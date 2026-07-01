-- =============================================
-- 独居老人水电监测模块 - 建表 + 演示数据
-- 导入方式: mysql -u root -p20051003xxSGX smart_care_community --default-character-set=utf8mb4 -e "source D:/daima2/finalproject-SmartCareCommunity-main/finalproject-SmartCareCommunity-main/sql/elder_utility_demo.sql"
-- =============================================
SET NAMES utf8mb4;
SET CHARACTER SET utf8mb4;

-- =============================================
-- 1. 创建水电使用数据表
-- =============================================
CREATE TABLE IF NOT EXISTS `el_utility_data` (
  `data_id` bigint NOT NULL AUTO_INCREMENT COMMENT '数据主键',
  `resident_id` bigint NOT NULL COMMENT '老人住户ID',
  `record_time` datetime NOT NULL COMMENT '数据时间（小时级）',
  `water_usage` decimal(10,2) DEFAULT '0.00' COMMENT '用水量（升）',
  `electric_usage` decimal(10,2) DEFAULT '0.00' COMMENT '用电量（千瓦时）',
  `source` varchar(16) DEFAULT 'real' COMMENT '数据来源：real/simulated',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`data_id`),
  KEY `idx_resident_time` (`resident_id`, `record_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='独居老人水电使用数据表（小时级）';

-- =============================================
-- 2. 为独居老人(resident_id=1,3,5)插入7天正常模拟数据
--    数据模式：早间(6-9)和晚间(17-20)高峰，夜间(22-4)低用量
-- =============================================

-- 这里用存储过程批量生成数据
DELIMITER //
CREATE PROCEDURE IF NOT EXISTS gen_utility_data()
BEGIN
    DECLARE v_rid BIGINT;
    DECLARE v_hour INT DEFAULT 0;
    DECLARE v_day INT DEFAULT 0;
    DECLARE v_water DECIMAL(10,2);
    DECLARE v_electric DECIMAL(10,2);
    DECLARE v_time DATETIME;
    DECLARE v_rids CURSOR FOR SELECT resident_id FROM cm_resident WHERE is_alone_living = 1 LIMIT 3;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_rid = NULL;

    OPEN v_rids;
    read_loop: LOOP
        FETCH v_rids INTO v_rid;
        IF v_rid IS NULL THEN LEAVE read_loop; END IF;

        SET v_day = 7;
        WHILE v_day >= 0 DO
            SET v_hour = 0;
            WHILE v_hour < 24 DO
                SET v_time = DATE_SUB(NOW(), INTERVAL v_day DAY) + INTERVAL v_hour HOUR;
                SET v_time = DATE_FORMAT(v_time, '%Y-%m-%d %H:00:00');

                -- 根据时段生成合理数据
                IF v_hour >= 22 OR v_hour < 5 THEN
                    -- 夜间低用量
                    SET v_water = ROUND(RAND() * 2, 2);
                    SET v_electric = ROUND(0.1 + RAND() * 0.3, 2);
                ELSEIF v_hour >= 6 AND v_hour <= 9 THEN
                    -- 早间高峰
                    SET v_water = ROUND(8 + RAND() * 12, 2);
                    SET v_electric = ROUND(0.5 + RAND() * 1.5, 2);
                ELSEIF v_hour >= 11 AND v_hour <= 13 THEN
                    -- 午间
                    SET v_water = ROUND(5 + RAND() * 10, 2);
                    SET v_electric = ROUND(0.4 + RAND() * 1.2, 2);
                ELSEIF v_hour >= 17 AND v_hour <= 20 THEN
                    -- 晚间高峰
                    SET v_water = ROUND(10 + RAND() * 15, 2);
                    SET v_electric = ROUND(0.8 + RAND() * 2.0, 2);
                ELSE
                    -- 其他时段
                    SET v_water = ROUND(2 + RAND() * 5, 2);
                    SET v_electric = ROUND(0.2 + RAND() * 0.8, 2);
                END IF;

                INSERT IGNORE INTO `el_utility_data` (`resident_id`, `record_time`, `water_usage`, `electric_usage`, `source`, `create_time`)
                VALUES (v_rid, v_time, v_water, v_electric, 'simulated', NOW());

                SET v_hour = v_hour + 1;
            END WHILE;
            SET v_day = v_day - 1;
        END WHILE;
    END LOOP;
    CLOSE v_rids;
END //
DELIMITER ;

-- 执行存储过程
CALL gen_utility_data();

-- 清理存储过程
DROP PROCEDURE IF EXISTS gen_utility_data;

-- =============================================
-- 完成
-- =============================================
SELECT '独居老人水电监测模块数据导入完成！' AS message;
