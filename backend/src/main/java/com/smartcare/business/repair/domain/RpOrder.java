package com.smartcare.business.repair.domain;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import com.smartcare.common.core.domain.BaseEntity;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.math.BigDecimal;

@Data
@EqualsAndHashCode(callSuper = true)
@TableName("rp_order")
public class RpOrder extends BaseEntity {

    @TableId(type = IdType.AUTO)
    private Long orderId;
    private String orderNo;
    private Long ownerId;
    private Long houseId;
    private Long typeId;
    private String description;
    private String urgency;
    private String status;
    private Long workerId;
    private Integer urgeCount;
    private Integer promiseHours;
    private BigDecimal materialFee;
    private BigDecimal laborFee;
    private Integer frozen;
    private String signImage;
    private String rejectReason;
    private String assignReason;
    /** AI识别故障类型标签 */
    private String aiTypeLabel;
    /** 高风险标记：0否 1是 */
    private Integer highRisk;
    /** 重复报修标记：0否 1是 */
    private Integer duplicateFlag;
}
