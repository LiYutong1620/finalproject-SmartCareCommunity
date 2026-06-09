package com.smartcare.business.property.domain;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDate;

@Data
@TableName("cm_violation")
public class CmViolation {
    @TableId(type = IdType.AUTO)
    private Long violationId;
    private Long residentId;
    private String violationType;
    private String measure;
    private LocalDate unlockDate;
    private String status;
}
