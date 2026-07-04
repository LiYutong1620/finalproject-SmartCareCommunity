package com.smartcare.business.repair.domain;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

@Data
@TableName("rp_repair_type")
public class RpRepairType {

    @TableId(type = IdType.AUTO)
    private Long typeId;

    private Long parentId;

    private String typeName;

    private Integer orderNum;

    /** 典型关键词（逗号分隔，一级分类用于 AI 识别） */
    private String keywords;
}
