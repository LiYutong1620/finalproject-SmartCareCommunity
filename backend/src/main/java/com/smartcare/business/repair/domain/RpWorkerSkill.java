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
}
