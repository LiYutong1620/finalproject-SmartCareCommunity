package com.smartcare.business.elder.domain;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 独居老人水电使用数据（小时级）
 */
@Data
@TableName("el_utility_data")
public class ElUtilityData {

    @TableId(type = IdType.AUTO)
    private Long dataId;

    /** 老人住户ID */
    private Long residentId;

    /** 数据时间（小时级，如 2026-07-01 08:00:00 代表 08:00-09:00 这一小时） */
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime recordTime;

    /** 用水量（升） */
    private BigDecimal waterUsage;

    /** 用电量（千瓦时） */
    private BigDecimal electricUsage;

    /** 数据来源：real-实际数据, simulated-模拟数据 */
    private String source;

    /** 创建时间 */
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime createTime;
}
