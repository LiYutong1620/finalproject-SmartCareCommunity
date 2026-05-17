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
@TableName("sys_user")
public class SysUser extends BaseEntity {

    @TableId(type = IdType.AUTO)
    private Long userId;
    private String username;
    private String password;
    private String nickName;
    private String phone;
    private String idCard;
    private String avatar;
    /** 0业主 1维修工 2物业(含原后台管理职责) */
    private String userType;
    private Long buildingId;
    private Long houseId;
    private String status;
    @TableLogic(value = "0", delval = "2")
    private String delFlag;
}
