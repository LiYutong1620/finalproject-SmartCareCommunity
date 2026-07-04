package com.smartcare.system.domain;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableLogic;
import com.baomidou.mybatisplus.annotation.TableName;
import com.smartcare.common.core.domain.BaseEntity;
import lombok.Data;
import lombok.EqualsAndHashCode;

@Data
@EqualsAndHashCode(callSuper = true)
@TableName("pm_staff")
public class PmStaff extends BaseEntity {

    @TableId(type = IdType.AUTO)
    private Long staffId;
    private String name;
    private String gender;
    private Integer age;
    private String phone;
    private String avatar;
    private String dept;
    @TableLogic(value = "0", delval = "2")
    private String delFlag;
}
