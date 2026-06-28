package com.smartcare.business.ai.domain;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import com.smartcare.common.core.domain.BaseEntity;
import lombok.Data;
import lombok.EqualsAndHashCode;

@Data
@EqualsAndHashCode(callSuper = true)
@TableName("ai_chat_session")
public class AiChatSession extends BaseEntity {

    @TableId(type = IdType.AUTO)
    private Long sessionId;
    private Long userId;
    private String title;
    /** 0 AI对话 1人工对话中 2人工已结束 */
    private String status;
}
