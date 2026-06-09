package com.smartcare.business.community.domain;

import com.baomidou.mybatisplus.annotation.FieldFill;
import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@TableName("cs_activity_reg")
public class CsActivityReg {
    @TableId(type = IdType.AUTO)
    private Long regId;
    private Long activityId;
    private Long userId;
    private String name;
    private String houseNo;
    private String phone;
    private String status;
    private String voucherNo;

    @TableField(fill = FieldFill.INSERT)
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime createTime;
}
