package com.smartcare.business.repair.domain;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDate;

@Data
@TableName("rp_worker_profile")
public class RpWorkerProfile {

    @TableId(type = IdType.INPUT)
    private Long workerId;

    private String workStatus;

    private String certName;

    private LocalDate certExpire;

    private BigDecimal avgScore;

    private Integer evalCount;
}
