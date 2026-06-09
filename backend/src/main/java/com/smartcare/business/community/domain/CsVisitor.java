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
@TableName("cs_visitor")
public class CsVisitor {
    @TableId(type = IdType.AUTO)
    private Long visitorId;
    private Long ownerId;
    private String visitorName;
    private String phone;
    private LocalDateTime visitStart;
    private LocalDateTime visitEnd;
    private String plateNo;
    private String qrcode;
    private String status;

    @TableField(fill = FieldFill.INSERT)
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime createTime;
}
