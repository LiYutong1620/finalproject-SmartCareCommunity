package com.smartcare.business.property.domain;

import com.baomidou.mybatisplus.annotation.FieldFill;
import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@TableName("cm_house")
public class CmHouse {
    @TableId(type = IdType.AUTO)
    private Long houseId;
    private Long buildingId;
    private String houseNo;
    private BigDecimal area;
    private String layout;
    private String ownerName;
    private String remark;

    @TableField(exist = false)
    private Long residentId;
    @TableField(exist = false)
    private String residentName;
    @TableField(exist = false)
    private String livingStatus;
    @TableField(exist = false)
    private String livingStatusLabel;
    @TableField(exist = false)
    private String buildingNo;

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createTime;
}
