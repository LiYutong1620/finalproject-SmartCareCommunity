package com.smartcare.business.community.domain;

import com.baomidou.mybatisplus.annotation.FieldFill;
import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@TableName("cs_activity")
public class CsActivity {
    @TableId(type = IdType.AUTO)
    private Long activityId;
    private String title;
    private String content;
    private String location;
    private LocalDateTime startTime;
    private LocalDateTime deadline;
    private Integer maxCount;
    private String status;

    @TableField(fill = FieldFill.INSERT)
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime createTime;
}
