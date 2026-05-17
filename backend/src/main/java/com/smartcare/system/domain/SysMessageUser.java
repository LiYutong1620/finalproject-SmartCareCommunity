package com.smartcare.system.domain;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@TableName("sys_message_user")
public class SysMessageUser {

    @TableId(type = IdType.AUTO)
    private Long id;
    private Long messageId;
    private Long userId;
    private Integer readFlag;
    private LocalDateTime readTime;
}
