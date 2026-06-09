package com.smartcare.business.property.domain;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
@TableName("cm_parking_payment")
public class CmParkingPayment {
    @TableId(type = IdType.AUTO)
    private Long paymentId;
    private Long parkingId;
    private Long residentId;
    private BigDecimal amount;
    private String payType;
    private LocalDate periodStart;
    private LocalDate periodEnd;
    private LocalDateTime payTime;
    private String remark;
}
