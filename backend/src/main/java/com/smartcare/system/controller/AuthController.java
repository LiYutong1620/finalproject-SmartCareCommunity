package com.smartcare.system.controller;

import com.smartcare.common.core.domain.AjaxResult;
import com.smartcare.common.exception.ServiceException;
import com.smartcare.framework.captcha.CaptchaService;
import com.smartcare.framework.security.JwtUtils;
import com.smartcare.framework.security.SecurityUtils;
import com.smartcare.system.domain.SysLoginLog;
import com.smartcare.system.domain.SysUser;
import com.smartcare.system.domain.dto.RegisterBody;
import com.smartcare.system.service.ForgotPasswordService;
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
    private final ForgotPasswordService forgotPasswordService;

    @PostMapping("/login")
    public AjaxResult login(@RequestBody LoginBody body, HttpServletRequest request) {
        captchaService.validate(body.getUuid(), body.getCode());
        SysUser user = userService.selectByUsername(body.getUsername());
        SysLoginLog log = new SysLoginLog();
        log.setUsername(body.getUsername());
        log.setIpaddr(request.getRemoteAddr());
        log.setDevice(request.getHeader("User-Agent"));
        String rawPassword = body.getPassword();
        String encodedPassword = user != null ? user.getPassword() : null;
        if (user == null || !StringUtils.hasText(rawPassword) || !StringUtils.hasText(encodedPassword)
            || !passwordEncoder.matches(rawPassword, encodedPassword)) {
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
        if (StringUtils.hasText(body.getUserType())) {
            String expected = normalizeUserType(body.getUserType());
            String actual = normalizeUserType(user.getUserType());
            if (!expected.equals(actual)) {
                throw new ServiceException("账号与所选角色不匹配");
            }
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
        if (!body.getUsername().matches("^(?=.*[a-zA-Z])(?=.*\\d)[a-zA-Z0-9]{4,}$")) {
            throw new ServiceException("账号须为4位及以上英文字母与数字组合");
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

    @PostMapping("/forgot-password/verify")
    public AjaxResult forgotVerify(@RequestBody ForgotStep1Body body) {
        if (!StringUtils.hasText(body.getUsername()) || !StringUtils.hasText(body.getUserType())) {
            throw new ServiceException("请输入账号并选择角色");
        }
        return AjaxResult.success(forgotPasswordService.verifyIdentity(body.getUsername(), body.getUserType()));
    }

    @PostMapping("/forgot-password/send-code")
    public AjaxResult forgotSendCode(@RequestBody ForgotStep2Body body) {
        if (!StringUtils.hasText(body.getVerifyToken()) || !StringUtils.hasText(body.getPhone())) {
            throw new ServiceException("请输入手机号");
        }
        String code = forgotPasswordService.sendCode(body.getVerifyToken(), body.getPhone());
        Map<String, Object> data = new HashMap<>();
        data.put("message", "验证码已发送");
        data.put("demoCode", code);
        return AjaxResult.success(data);
    }

    @PostMapping("/forgot-password/reset")
    public AjaxResult forgotReset(@RequestBody ForgotStep3Body body) {
        forgotPasswordService.resetPassword(
            body.getVerifyToken(),
            body.getCode(),
            body.getNewPassword(),
            body.getConfirmPassword());
        return AjaxResult.success("密码重置成功，请登录");
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
        private String userType;
        private String code;
        private String uuid;
    }

    @Data
    static class ForgotStep1Body {
        private String username;
        private String userType;
    }

    @Data
    static class ForgotStep2Body {
        private String verifyToken;
        private String phone;
    }

    @Data
    static class ForgotStep3Body {
        private String verifyToken;
        private String code;
        private String newPassword;
        private String confirmPassword;
    }
}
