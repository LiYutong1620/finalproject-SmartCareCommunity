package com.smartcare.business.elder.domain;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@TableName("el_alert")
public class ElAlert {

    @TableId(type = IdType.AUTO)
    private Long alertId;
    private Long residentId;
    private String alertType;
    private Integer alertLevel;
    private String content;
    private String status;
    private Long handlerId;
    private LocalDateTime handleTime;
    private String handleResult;
    private LocalDateTime createTime;
}
