package com.smartcare.business.property.domain;

import com.baomidou.mybatisplus.annotation.FieldFill;
import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@TableName("cm_move_apply")
public class CmMoveApply {
    @TableId(type = IdType.AUTO)
    private Long applyId;
    private Long residentId;
    private Long houseId;
    private String applicantName;
    private String applicantPhone;
    private Long userId;
    private String applyType;
    private String status;
    private String rejectReason;

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createTime;
}
