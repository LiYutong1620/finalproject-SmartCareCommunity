package com.smartcare.business.community.domain;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

@Data
@TableName("cs_vote_record")
public class CsVoteRecord {
    @TableId(type = IdType.AUTO)
    private Long recordId;
    private Long voteId;
    private Long userId;
    /** 对应列名 option（MySQL 保留字，需转义） */
    @TableField("`option`")
    private String voteOption;
}
