package com.smartcare.business.property.domain;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import com.smartcare.common.core.domain.BaseEntity;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.time.LocalDate;

@Data
@EqualsAndHashCode(callSuper = true)
@TableName("cm_resident")
public class CmResident extends BaseEntity {

    @TableId(type = IdType.AUTO)
    private Long residentId;
    private Long userId;
    private Long houseId;
    private String name;
    private String gender;
    private Integer age;
    private String idCard;
    private String phone;
    private String residentType;
    private LocalDate moveInDate;
    private String emergencyContact;
    private String familyMembers;
    private String remark;
    private String delFlag;

    @TableField(exist = false)
    private java.util.List<Long> tagIds;
}
