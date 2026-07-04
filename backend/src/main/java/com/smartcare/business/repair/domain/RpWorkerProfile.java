package com.smartcare.business.repair.domain;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDate;

@Data
@TableName("rp_worker_profile")
public class RpWorkerProfile {

    @TableId(type = IdType.INPUT)
    private Long workerId;

    private String workStatus;

    /** 职级：初级/中级/高级/资深（物业设置） */
    private String workerLevel;

    private String certName;

    private LocalDate certExpire;

    /** 证书审核：0待审核 1已通过 2已驳回 */
    private String certAuditStatus;

    private BigDecimal avgScore;

    private Integer evalCount;

    private String realName;
    private String phone;
    private String gender;
    private Integer age;
    private String avatar;
}
