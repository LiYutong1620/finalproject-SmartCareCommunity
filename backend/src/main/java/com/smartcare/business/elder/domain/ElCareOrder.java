package com.smartcare.business.elder.domain;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@TableName("el_care_order")
public class ElCareOrder {

    @TableId(type = IdType.AUTO)
    private Long careId;
    private Long residentId;
    private String careItem;
    private Long assigneeId;
    private String status;
    private String result;
    private String checkResult;
    private String supportMeasure;
    private String disposalResult;
    private Integer level;
    private LocalDateTime createTime;
    private LocalDateTime completeTime;

    @TableField(exist = false)
    private String elderName;

    @TableField(exist = false)
    private String assigneeName;

    /** 老人住址（非数据库字段） */
    @TableField(exist = false)
    private String address;
}
