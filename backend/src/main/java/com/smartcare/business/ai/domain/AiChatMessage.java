package com.smartcare.business.ai.domain;

import com.baomidou.mybatisplus.annotation.FieldFill;
import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@TableName("ai_chat_message")
public class AiChatMessage {

    @TableId(type = IdType.AUTO)
    private Long messageId;
    private Long sessionId;
    /** user / assistant / staff */
    private String role;
    private String content;
    /** 物业人工回复时的显示名，如「王管家」 */
    private String senderName;
    /** text / voice */
    private String inputType;
    /** 0否 1是 */
    private String transferHuman;
    private Long ticketId;
    private String refArticles;

    @TableField(fill = FieldFill.INSERT)
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime createTime;
}
