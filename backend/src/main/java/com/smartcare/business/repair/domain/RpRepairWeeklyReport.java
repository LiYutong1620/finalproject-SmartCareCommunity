package com.smartcare.business.repair.domain;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
@TableName("rp_repair_weekly_report")
public class RpRepairWeeklyReport {

    @TableId(type = IdType.AUTO)
    private Long reportId;

    private LocalDate weekStart;

    private LocalDate weekEnd;

    private Integer totalOrders;

    private BigDecimal avgCompleteHours;

    private BigDecimal overtimeRate;

    private BigDecimal duplicateRate;

    private BigDecimal goodRate;

    private String typeStats;

    private String workerStats;

    private String suggestions;

    private LocalDateTime createTime;
}
