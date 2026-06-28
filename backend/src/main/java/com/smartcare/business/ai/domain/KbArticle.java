package com.smartcare.business.ai.domain;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@TableName("kb_article")
public class KbArticle {

    @TableId(type = IdType.AUTO)
    private Long articleId;
    private String title;
    private String keywords;
    private String content;
    private LocalDateTime createTime;
}
