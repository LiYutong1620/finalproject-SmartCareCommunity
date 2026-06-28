package com.smartcare.business.ai.domain;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import com.smartcare.common.core.domain.BaseEntity;
import lombok.Data;
import lombok.EqualsAndHashCode;

@Data
@EqualsAndHashCode(callSuper = true)
@TableName("cs_service_ticket")
public class CsServiceTicket extends BaseEntity {

    @TableId(type = IdType.AUTO)
    private Long ticketId;
    private Long userId;
    private Long sessionId;
    private String question;
    /** 0待处理 1处理中 2已完成 */
    private String status;
    private String reply;
}
