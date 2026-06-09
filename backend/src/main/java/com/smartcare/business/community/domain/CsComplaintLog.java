package com.smartcare.business.community.domain;

import com.baomidou.mybatisplus.annotation.FieldFill;
import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@TableName("cs_complaint_log")
public class CsComplaintLog {
    @TableId(type = IdType.AUTO)
    private Long logId;
    private Long complaintId;
    private String action;
    private Long handlerId;
    private String content;

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createTime;
}
