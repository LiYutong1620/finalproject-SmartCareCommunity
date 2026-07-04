package com.smartcare.business.elder.domain;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@TableName("el_temp_guardian")
public class ElTempGuardian {

    @TableId(type = IdType.AUTO)
    private Long id;
    private Long residentId;
    private String guardianName;
    private String guardianPhone;
    private LocalDateTime startTime;
    private LocalDateTime endTime;
    /** 1有效 0已失效 */
    private String status;
    private LocalDateTime createTime;
}
