package com.smartcare.business.finance.domain;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@TableName("fn_payment")
public class FnPayment {
    @TableId(type = IdType.AUTO)
    private Long paymentId;
    private Long billId;
    private Long userId;
    private BigDecimal amount;
    private String payChannel;
    private String tradeNo;
    private LocalDateTime payTime;
}
