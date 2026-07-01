package com.smartcare.business.elder.domain;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

@Data
@TableName("el_care_staff")
public class ElCareStaff {

    @TableId(type = IdType.AUTO)
    private Long staffId;
    private String name;
    private String phone;
    private String staffType;
    private String buildingIds;
}
