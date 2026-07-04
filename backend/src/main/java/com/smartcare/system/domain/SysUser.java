package com.smartcare.system.domain;

import com.baomidou.mybatisplus.annotation.TableField;
import com.smartcare.common.core.domain.BaseEntity;
import lombok.Data;
import lombok.EqualsAndHashCode;

/**
 * 运行时用户聚合对象（登录态），资料分别存于业主/维修工/物业分表。
 */
@Data
@EqualsAndHashCode(callSuper = true)
public class SysUser extends BaseEntity {

    @TableField(exist = false)
    private Long userId;
    private String username;
    private String password;
    private String nickName;
    private String gender;
    private Integer age;
    private String phone;
    private String idCard;
    private String avatar;
    /** 0业主 1维修工 2物业(含原后台管理职责) */
    private String userType;
    private Long buildingId;
    private Long houseId;
    private String status;
    /** 权限码，逗号分隔，如 "elder_view,elder_manage,dashboard_view" */
    private String permissionCode;
    @TableField(exist = false)
    private String delFlag;
    /** 关联档案主键：业主=residentId，维修工=workerId，物业=staffId */
    @TableField(exist = false)
    private Long profileRefId;
    @TableField(exist = false)
    private String houseAddress;
    @TableField(exist = false)
    private Boolean residentBound;
}
