package com.smartcare.business.elder.domain;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

@Data
@TableName("el_disposal_plan")
public class ElDisposalPlan {

    @TableId(type = IdType.AUTO)
    private Long planId;
    private String planName;
    private String triggerCondition;
    private Integer level;
    private String responseAction;
}
