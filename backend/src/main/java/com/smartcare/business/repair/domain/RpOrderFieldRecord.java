package com.smartcare.business.repair.domain;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;

import java.time.LocalDateTime;
import java.util.List;

@Data
@TableName("rp_order_field_record")
public class RpOrderFieldRecord {

    /** 0=到场记录中 1=已保存未完工 2=已随完工提交 */
    public static final String STATUS_OPEN = "0";
    public static final String STATUS_SAVED = "1";
    public static final String STATUS_SUBMITTED = "2";

    @TableId(type = IdType.AUTO)
    private Long recordId;
    private Long orderId;
    private Long workerId;
    private String content;
    private String status;

    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime createTime;

    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime submitTime;

    @TableField(exist = false)
    private List<RpOrderFieldImage> images;
}
