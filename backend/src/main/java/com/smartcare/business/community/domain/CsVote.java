package com.smartcare.business.community.domain;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@TableName("cs_vote")
public class CsVote {
    @TableId(type = IdType.AUTO)
    private Long voteId;
    private String title;
    private String content;
    private String options;
    private Integer anonymous;
    private LocalDateTime endTime;
    private String status;
}
