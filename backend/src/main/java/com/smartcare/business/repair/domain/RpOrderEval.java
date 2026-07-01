package com.smartcare.business.repair.domain;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@TableName("rp_order_eval")
public class RpOrderEval {

    @TableId(type = IdType.AUTO)
    private Long evalId;

    private Long orderId;

    private Integer score;

    private String tags;

    private String content;

    private String appealStatus;

    private LocalDateTime createTime;
}