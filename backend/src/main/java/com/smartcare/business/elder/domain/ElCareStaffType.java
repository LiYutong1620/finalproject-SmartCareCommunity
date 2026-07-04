package com.smartcare.business.elder.domain;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

@Data
@TableName("el_care_staff_type")
public class ElCareStaffType {

    @TableId(type = IdType.AUTO)
    private Long typeId;
    private String typeName;
    private Integer sortOrder;
}
