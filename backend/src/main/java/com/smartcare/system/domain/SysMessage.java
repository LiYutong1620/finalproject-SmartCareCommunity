package com.smartcare.system.domain;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import com.smartcare.common.core.domain.BaseEntity;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.time.LocalDateTime;

@Data
@EqualsAndHashCode(callSuper = true)
@TableName("sys_message")
public class SysMessage extends BaseEntity {

    @TableId(type = IdType.AUTO)
    private Long messageId;
    private String msgType;
    private String title;
    private String content;
    private String priority;
    private Long senderId;
    private String bizId;
    private LocalDateTime validStart;
    private LocalDateTime validEnd;
    private Integer recalled;
    private LocalDateTime recallTime;
}
