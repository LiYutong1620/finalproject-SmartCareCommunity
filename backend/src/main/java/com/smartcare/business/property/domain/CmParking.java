package com.smartcare.business.property.domain;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.math.BigDecimal;

@Data
@TableName("cm_parking")
public class CmParking {
    @TableId(type = IdType.AUTO)
    private Long parkingId;
    private String parkingNo;
    private BigDecimal monthlyFee;
    private BigDecimal yearlyFee;
    private String status;
}
