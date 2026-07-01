package com.smartcare.business.elder.domain;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@TableName("el_health_record")
public class ElHealthRecord {

    @TableId(type = IdType.AUTO)
    private Long recordId;
    private Long residentId;
    private Integer heartRate;
    private String bloodPressure;
    private Integer steps;
    private LocalDateTime recordTime;
}
