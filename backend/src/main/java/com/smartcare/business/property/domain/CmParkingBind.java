package com.smartcare.business.property.domain;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@TableName("cm_parking_bind")
public class CmParkingBind {
    @TableId(type = IdType.AUTO)
    private Long bindId;
    private Long parkingId;
    private Long residentId;
    private LocalDateTime bindTime;
}
