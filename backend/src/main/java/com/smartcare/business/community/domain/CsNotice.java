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
@TableName("cs_notice")
public class CsNotice extends BaseEntity {

    @TableId(type = IdType.AUTO)
    private Long noticeId;
    private String noticeType;
    private String title;
    private String content;
    private String attachment;
    private Integer pinned;
    private LocalDateTime validStart;
    private LocalDateTime validEnd;
    private String scope;
    private LocalDateTime restoreTime;
    private LocalDateTime offlineTime;
    private String status;
    private Long createBy;
}
