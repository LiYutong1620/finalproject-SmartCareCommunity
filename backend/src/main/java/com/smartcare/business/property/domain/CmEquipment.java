package com.smartcare.business.property.domain;

import com.baomidou.mybatisplus.annotation.FieldFill;
import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
@TableName("cm_equipment")
public class CmEquipment {
    @TableId(type = IdType.AUTO)
    private Long equipmentId;
    private String equipType;
    private String equipNo;
    private String location;
    private String iotStatus;
    private LocalDate nextMaintain;

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createTime;
}
