package com.smartcare.business.property.domain;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import com.smartcare.common.core.domain.BaseEntity;
import lombok.Data;
import lombok.EqualsAndHashCode;

@Data
@EqualsAndHashCode(callSuper = true)
@TableName("cm_building")
public class CmBuilding extends BaseEntity {

    @TableId(type = IdType.AUTO)
    private Long buildingId;
    private String buildingNo;
    private Integer totalFloors;
    private Integer unitsPerFloor;
    private String remark;
}
