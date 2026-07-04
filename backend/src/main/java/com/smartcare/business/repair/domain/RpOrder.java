package com.smartcare.business.repair.domain;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import com.fasterxml.jackson.annotation.JsonFormat;
import com.smartcare.common.core.domain.BaseEntity;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.math.BigDecimal;
import java.time.LocalDateTime;

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
    private String aiTypeLabel;
    private Integer highRisk;
    private Integer duplicateFlag;

    /** 业主期望上门时间 */
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime expectedTime;

    /** 维修完成时间（来自进度「完成维修」节点，非数据库字段） */
    @TableField(exist = false)
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime repairCompleteTime;

    /** 业主是否有未读补充信息（列表展示用） */
    @TableField(exist = false)
    private Boolean appendPending;
}
