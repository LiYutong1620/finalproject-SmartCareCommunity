package com.smartcare.business.property.domain;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

@Data
@TableName("cm_resident_tag")
public class CmResidentTag {
    @TableId(type = IdType.AUTO)
    private Long tagId;
    private String tagName;
    private String tagType;
}
