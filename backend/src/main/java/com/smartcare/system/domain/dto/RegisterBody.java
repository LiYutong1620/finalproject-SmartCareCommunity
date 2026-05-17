package com.smartcare.system.domain.dto;

import lombok.Data;

@Data
public class RegisterBody {

    private String username;
    private String password;
    private String confirmPassword;
    private String nickName;
    private String phone;
    /** 业主自助注册固定为 0 */
    private String userType;
    private String code;
    private String uuid;
}
