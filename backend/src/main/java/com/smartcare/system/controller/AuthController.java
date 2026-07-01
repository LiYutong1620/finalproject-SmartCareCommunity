package com.smartcare.system.controller;

import com.smartcare.common.core.domain.AjaxResult;
import com.smartcare.common.exception.ServiceException;
import com.smartcare.framework.captcha.CaptchaService;
import com.smartcare.framework.security.JwtUtils;
import com.smartcare.framework.security.SecurityUtils;
import com.smartcare.system.domain.SysLoginLog;
import com.smartcare.system.domain.SysUser;
import com.smartcare.system.domain.dto.RegisterBody;
import com.smartcare.system.service.SysLoginLogService;
import com.smartcare.system.service.SysUserService;
import jakarta.servlet.http.HttpServletRequest;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequiredArgsConstructor
public class AuthController {

    private final SysUserService userService;
    private final SysLoginLogService loginLogService;
    private final PasswordEncoder passwordEncoder;
    private final JwtUtils jwtUtils;
    private final CaptchaService captchaService;

    @PostMapping("/login")
    public AjaxResult login(@RequestBody LoginBody body, HttpServletRequest request) {
        captchaService.validate(body.getUuid(), body.getCode());
        SysUser user = userService.selectByUsername(body.getUsername());
        SysLoginLog log = new SysLoginLog();
        log.setUsername(body.getUsername());
        log.setIpaddr(request.getRemoteAddr());
        log.setDevice(request.getHeader("User-Agent"));
        if (user == null || !passwordEncoder.matches(body.getPassword(), user.getPassword())) {
            log.setStatus("1");
            log.setMsg("账号或密码错误");
            loginLogService.save(log);
            throw new ServiceException("账号或密码错误");
        }
        if (!"0".equals(user.getStatus())) {
            throw new ServiceException("账号已停用");
        }
        if ("admin".equalsIgnoreCase(user.getUsername())) {
            throw new ServiceException("系统无独立管理员端，请使用物业账号 property01 登录");
        }
        log.setStatus("0");
        log.setMsg("登录成功");
        loginLogService.save(log);
        String userType = normalizeUserType(user.getUserType());
        String token = jwtUtils.createToken(user.getUserId(), user.getUsername(), userType, user.getPermissionCode());
        Map<String, Object> data = new HashMap<>();
        data.put("token", token);
        data.put("user", sanitize(user));
        return AjaxResult.success(data);
    }

    @PostMapping("/register")
    public AjaxResult register(@RequestBody RegisterBody body) {
        captchaService.validate(body.getUuid(), body.getCode());
        if (!StringUtils.hasText(body.getUsername()) || body.getUsername().length() < 4) {
            throw new ServiceException("账号长度至少4位");
        }
        if (!StringUtils.hasText(body.getPassword()) || body.getPassword().length() < 6) {
            throw new ServiceException("密码长度至少6位");
        }
        if (!body.getPassword().equals(body.getConfirmPassword())) {
            throw new ServiceException("两次输入的密码不一致");
        }
        if (!StringUtils.hasText(body.getPhone())) {
            throw new ServiceException("请输入手机号");
        }
        SysUser user = new SysUser();
        user.setUsername(body.getUsername().trim());
        user.setPassword(body.getPassword());
        user.setNickName(StringUtils.hasText(body.getNickName()) ? body.getNickName().trim() : body.getUsername());
        user.setPhone(body.getPhone().trim());
        userService.register(user);
        return AjaxResult.success("注册成功，请登录");
    }

    @GetMapping("/getInfo")
    public AjaxResult getInfo() {
        SysUser user = SecurityUtils.getUser();
        return AjaxResult.success(sanitize(user));
    }

    private Map<String, Object> sanitize(SysUser user) {
        Map<String, Object> m = new HashMap<>();
        m.put("userId", user.getUserId());
        m.put("username", user.getUsername());
        m.put("nickName", user.getNickName());
        m.put("phone", user.getPhone());
        m.put("avatar", user.getAvatar());
        m.put("userType", normalizeUserType(user.getUserType()));
        m.put("permissionCode", user.getPermissionCode());
        return m;
    }

    private String normalizeUserType(String userType) {
        return "3".equals(userType) ? "2" : userType;
    }

    @Data
    static class LoginBody {
        private String username;
        private String password;
        private String code;
        private String uuid;
    }
}
