package com.smartcare.business.ai.domain;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@TableName("kb_learn_draft")
public class KbLearnDraft {

    @TableId(type = IdType.AUTO)
    private Long draftId;
    /** notice / chat / document */
    private String sourceType;
    private Long sourceId;
    private String sourceRef;
    private String title;
    private String keywords;
    private String content;
    /** 0待审核 1已采纳 2已拒绝 */
    private String status;
    private LocalDateTime createTime;
}
