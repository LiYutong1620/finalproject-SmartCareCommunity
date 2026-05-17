package com.smartcare.business.finance.domain;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import com.smartcare.common.core.domain.BaseEntity;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.math.BigDecimal;
import java.time.LocalDate;

@Data
@EqualsAndHashCode(callSuper = true)
@TableName("fn_bill")
public class FnBill extends BaseEntity {

    @TableId(type = IdType.AUTO)
    private Long billId;
    private Long houseId;
    private Long itemId;
    private String period;
    private BigDecimal amount;
    private BigDecimal paidAmount;
    private BigDecimal lateFee;
    private String status;
    private LocalDate dueDate;
}
