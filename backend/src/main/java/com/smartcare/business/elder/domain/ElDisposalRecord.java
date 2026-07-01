package com.smartcare.business.elder.domain;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;

import java.time.LocalDateTime;

/**
 * 处置记录表
 */
@Data
@TableName("el_disposal_record")
public class ElDisposalRecord {

    @TableId(type = IdType.AUTO)
    private Long recordId;

    /** 关联工单ID（可为空） */
    private Long careId;

    /** 关联预警ID（可为空） */
    private Long alertId;

    /** 处理人ID */
    private Long handlerId;

    /** 处理时间 */
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime handleTime;

    /** 核查结果 */
    private String checkResult;

    /** 帮扶措施 */
    private String supportMeasure;

    /** 处置结果 */
    private String disposalResult;

    /** 创建时间 */
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime createTime;

    /** 处理人姓名（非数据库字段） */
    @TableField(exist = false)
    private String handlerName;
}
