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
@TableName("sys_worker_account")
public class SysWorkerAccount extends BaseEntity {

    @TableId(type = IdType.AUTO)
    private Long accountId;
    private String username;
    private String password;
    private String status;
    @TableLogic(value = "0", delval = "2")
    private String delFlag;
}
