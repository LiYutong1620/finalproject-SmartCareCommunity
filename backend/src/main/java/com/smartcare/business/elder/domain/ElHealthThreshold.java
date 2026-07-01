package com.smartcare.business.elder.domain;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.math.BigDecimal;

@Data
@TableName("el_health_threshold")
public class ElHealthThreshold {

    @TableId(type = IdType.AUTO)
    private Integer id;
    private String metric;
    private BigDecimal minValue;
    private BigDecimal maxValue;
}
