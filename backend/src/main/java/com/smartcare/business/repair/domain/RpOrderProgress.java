package com.smartcare.business.repair.domain;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@TableName("rp_order_progress")
public class RpOrderProgress {

    @TableId(type = IdType.AUTO)
    private Long progressId;
    private Long orderId;
    private String nodeName;
    private String operator;
    private String remark;
    private LocalDateTime createTime;
}
