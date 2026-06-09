package com.smartcare.business.community.domain;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import com.smartcare.common.core.domain.BaseEntity;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.time.LocalDateTime;

@Data
@EqualsAndHashCode(callSuper = true)
@TableName("cs_complaint")
public class CsComplaint extends BaseEntity {

    @TableId(type = IdType.AUTO)
    private Long complaintId;
    private String complaintNo;
    private Long userId;
    private String category;
    private String title;
    private String content;
    private String images;
    private Integer anonymous;
    private String status;
    private Long handlerId;
    private String reply;
    private LocalDateTime replyTime;
}
