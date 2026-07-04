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
@TableName("sys_owner_account")
public class SysOwnerAccount extends BaseEntity {

    @TableId(type = IdType.AUTO)
    private Long accountId;
    private String username;
    private String password;
    private Long residentId;
    /** 待绑定姓名（尚未建立住户档案时与业主管理表单同步） */
    private String bindName;
    /** 待绑定手机号 */
    private String bindPhone;
    /** 待绑定性别（未关联住户档案时个人中心保存） */
    private String bindGender;
    /** 待绑定年龄（未关联住户档案时个人中心保存） */
    private Integer bindAge;
    private String status;
    @TableLogic(value = "0", delval = "2")
    private String delFlag;
}
