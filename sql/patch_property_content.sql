-- 社区内容与投诉管理模块补丁
USE smart_care_community;

DROP TABLE IF EXISTS cs_complaint_log;
CREATE TABLE cs_complaint_log (
  log_id bigint NOT NULL AUTO_INCREMENT COMMENT '日志ID',
  complaint_id bigint NOT NULL COMMENT '投诉ID',
  action varchar(32) NOT NULL COMMENT '动作：accept/reply/assign',
  handler_id bigint NULL COMMENT '操作人',
  content varchar(512) NULL DEFAULT '' COMMENT '说明',
  create_time datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '时间',
  PRIMARY KEY (log_id)
) ENGINE=InnoDB COMMENT='投诉处理记录';
