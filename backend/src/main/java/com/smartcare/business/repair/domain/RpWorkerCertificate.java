package com.smartcare.business.repair.domain;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
@TableName("rp_worker_certificate")
public class RpWorkerCertificate {

    @TableId(type = IdType.AUTO)
    private Long certId;
    private Long workerId;
    private String certName;
    private LocalDate certExpire;
    /** 关联技能（可选，便于物业对照审核） */
    private String relatedSkill;
    private String applyRemark;
    /** 审核：0待审核 1已通过 2已驳回 */
    private String auditStatus;
    /** 审核意见（驳回原因等） */
    private String auditRemark;
    private LocalDateTime createTime;
}
