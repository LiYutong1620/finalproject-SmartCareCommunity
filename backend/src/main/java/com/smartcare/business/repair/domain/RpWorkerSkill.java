package com.smartcare.business.repair.domain;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

@Data
@TableName("rp_worker_skill")
public class RpWorkerSkill {

    @TableId(type = IdType.AUTO)
    private Long skillId;
    private Long workerId;
    private String skillName;
    private String skillLevel;
    /** 审核：0待审核 1已通过 2已驳回 */
    private String auditStatus;
    /** 申请说明/从业证明 */
    private String applyRemark;
    /** 审核意见（驳回原因等） */
    private String auditRemark;
}
