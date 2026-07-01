SET NAMES utf8mb4;
-- 给 el_care_order 添加 level, complete_time, check_result, support_measure, disposal_result 列
-- 用 IGNORE 方式，已存在则跳过
SET @dbname = 'smart_care_community';
SET @tablename = 'el_care_order';

-- level
SET @preparedStatement = (SELECT IF(
  (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA=@dbname AND TABLE_NAME=@tablename AND COLUMN_NAME='level') > 0,
  'SELECT 1',
  'ALTER TABLE el_care_order ADD COLUMN `level` int NULL DEFAULT NULL COMMENT ''处置等级1/2'''
));
PREPARE alterIfNotExists FROM @preparedStatement;
EXECUTE alterIfNotExists;
DEALLOCATE PREPARE alterIfNotExists;

-- complete_time
SET @preparedStatement = (SELECT IF(
  (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA=@dbname AND TABLE_NAME=@tablename AND COLUMN_NAME='complete_time') > 0,
  'SELECT 1',
  'ALTER TABLE el_care_order ADD COLUMN `complete_time` datetime NULL DEFAULT NULL COMMENT ''完成时间'''
));
PREPARE alterIfNotExists FROM @preparedStatement;
EXECUTE alterIfNotExists;
DEALLOCATE PREPARE alterIfNotExists;

-- check_result
SET @preparedStatement = (SELECT IF(
  (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA=@dbname AND TABLE_NAME=@tablename AND COLUMN_NAME='check_result') > 0,
  'SELECT 1',
  'ALTER TABLE el_care_order ADD COLUMN `check_result` varchar(500) NULL DEFAULT NULL COMMENT ''核查结果'''
));
PREPARE alterIfNotExists FROM @preparedStatement;
EXECUTE alterIfNotExists;
DEALLOCATE PREPARE alterIfNotExists;

-- support_measure
SET @preparedStatement = (SELECT IF(
  (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA=@dbname AND TABLE_NAME=@tablename AND COLUMN_NAME='support_measure') > 0,
  'SELECT 1',
  'ALTER TABLE el_care_order ADD COLUMN `support_measure` varchar(500) NULL DEFAULT NULL COMMENT ''帮扶措施'''
));
PREPARE alterIfNotExists FROM @preparedStatement;
EXECUTE alterIfNotExists;
DEALLOCATE PREPARE alterIfNotExists;

-- disposal_result
SET @preparedStatement = (SELECT IF(
  (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA=@dbname AND TABLE_NAME=@tablename AND COLUMN_NAME='disposal_result') > 0,
  'SELECT 1',
  'ALTER TABLE el_care_order ADD COLUMN `disposal_result` varchar(500) NULL DEFAULT NULL COMMENT ''处置结果'''
));
PREPARE alterIfNotExists FROM @preparedStatement;
EXECUTE alterIfNotExists;
DEALLOCATE PREPARE alterIfNotExists;

SELECT 'el_care_order columns updated' as status;
