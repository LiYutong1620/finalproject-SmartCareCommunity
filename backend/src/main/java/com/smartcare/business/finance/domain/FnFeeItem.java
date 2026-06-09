package com.smartcare.business.finance.domain;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.math.BigDecimal;

@Data
@TableName("fn_fee_item")
public class FnFeeItem {
    @TableId(type = IdType.AUTO)
    private Long itemId;
    private String itemName;
    private BigDecimal unitPrice;
    private String feeType;
}
