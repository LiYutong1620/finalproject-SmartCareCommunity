package com.smartcare.business.community.domain;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.math.BigDecimal;

@Data
@TableName("cs_venue")
public class CsVenue {
    @TableId(type = IdType.AUTO)
    private Long venueId;
    private String venueName;
    private BigDecimal feeStandard;
}
