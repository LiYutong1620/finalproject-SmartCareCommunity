-- 住户与社区资源管理模块补丁
USE smart_care_community;

ALTER TABLE cm_house ADD COLUMN tenant_name varchar(64) NULL DEFAULT '' COMMENT '租客姓名' AFTER owner_name;
ALTER TABLE cm_house ADD COLUMN tenant_phone varchar(20) NULL DEFAULT '' COMMENT '租客电话' AFTER tenant_name;
ALTER TABLE cm_house ADD COLUMN lease_start date NULL COMMENT '租期开始' AFTER tenant_phone;
ALTER TABLE cm_house ADD COLUMN lease_end date NULL COMMENT '租期结束' AFTER lease_start;
ALTER TABLE cm_house ADD COLUMN rent_amount decimal(10,2) NULL DEFAULT 0 COMMENT '租金' AFTER lease_end;

ALTER TABLE cm_resident ADD COLUMN family_members varchar(512) NULL DEFAULT '' COMMENT '家庭成员JSON' AFTER emergency_contact;

ALTER TABLE cm_move_apply ADD COLUMN applicant_name varchar(64) NULL DEFAULT '' COMMENT '申请人' AFTER house_id;
ALTER TABLE cm_move_apply ADD COLUMN applicant_phone varchar(20) NULL DEFAULT '' COMMENT '申请人电话' AFTER applicant_name;
ALTER TABLE cm_move_apply ADD COLUMN user_id bigint NULL COMMENT '申请用户ID' AFTER applicant_phone;

DROP TABLE IF EXISTS cm_parking_payment;
CREATE TABLE cm_parking_payment (
  payment_id bigint NOT NULL AUTO_INCREMENT COMMENT '缴费记录ID',
  parking_id bigint NOT NULL COMMENT '车位ID',
  resident_id bigint NULL COMMENT '住户ID',
  amount decimal(10,2) NOT NULL COMMENT '缴费金额',
  pay_type varchar(16) NULL DEFAULT 'monthly' COMMENT 'monthly/yearly',
  period_start date NULL COMMENT '费用起始',
  period_end date NULL COMMENT '费用截止',
  pay_time datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '缴费时间',
  remark varchar(255) NULL DEFAULT '' COMMENT '备注',
  PRIMARY KEY (payment_id)
) ENGINE=InnoDB COMMENT='车位缴费记录';

INSERT IGNORE INTO cm_resident_tag (tag_id, tag_name, tag_type) VALUES
(1, '独居老人', 'elder'), (2, '高龄老人', 'elder'), (3, '残疾人', 'disabled'),
(4, '党员', 'custom'), (5, '志愿者', 'custom'), (6, '宠物家庭', 'custom');

INSERT INTO cm_parking (parking_no, monthly_fee, yearly_fee, status) VALUES
('A-001', 300.00, 3000.00, '0'), ('A-002', 300.00, 3000.00, '0'), ('B-001', 350.00, 3500.00, '0');
