package com.smartcare.system.service;

import com.smartcare.common.exception.ServiceException;
import com.smartcare.system.domain.SysUser;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.util.Map;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;
import java.util.random.RandomGenerator;

@Service
@RequiredArgsConstructor
public class ForgotPasswordService {

    private static final long EXPIRE_MS = 300_000;
    private static final long CODE_EXPIRE_MS = 120_000;

    private final SysUserService userService;
    private final PasswordEncoder passwordEncoder;
    private final Map<String, ResetSession> sessions = new ConcurrentHashMap<>();
    private final RandomGenerator random = RandomGenerator.getDefault();

    public Map<String, Object> verifyIdentity(String username, String userType) {
        SysUser user = userService.selectByUsername(username.trim());
        if (user == null) {
            throw new ServiceException("账号不存在");
        }
        if (!"0".equals(user.getStatus())) {
            throw new ServiceException("账号已停用");
        }
        String expected = normalizeUserType(userType);
        String actual = normalizeUserType(user.getUserType());
        if (!expected.equals(actual)) {
            throw new ServiceException("账号与所选角色不匹配");
        }
        if (!StringUtils.hasText(user.getPhone())) {
            throw new ServiceException("该账号未绑定手机号，请联系物业重置密码");
        }
        String token = UUID.randomUUID().toString().replace("-", "");
        sessions.put(token, new ResetSession(user.getUserId(), user.getPhone(), user.getPassword(), System.currentTimeMillis()));
        return Map.of(
            "verifyToken", token,
            "phoneMasked", maskPhone(user.getPhone())
        );
    }

    public String sendCode(String verifyToken, String phone) {
        ResetSession session = getSession(verifyToken);
        if (!session.phone.equals(phone.trim())) {
            throw new ServiceException("手机号与账号不匹配");
        }
        String code = String.format("%06d", random.nextInt(1_000_000));
        session.smsCode = code;
        session.codeTime = System.currentTimeMillis();
        return code;
    }

    public void resetPassword(String verifyToken, String code, String newPassword, String confirmPassword) {
        if (!StringUtils.hasText(newPassword) || newPassword.length() < 6) {
            throw new ServiceException("新密码长度至少6位");
        }
        if (!newPassword.equals(confirmPassword)) {
            throw new ServiceException("两次输入的密码不一致");
        }
        ResetSession session = getSession(verifyToken);
        if (!StringUtils.hasText(session.smsCode) || session.codeTime == 0) {
            throw new ServiceException("请先获取验证码");
        }
        if (System.currentTimeMillis() - session.codeTime > CODE_EXPIRE_MS) {
            sessions.remove(verifyToken);
            throw new ServiceException("验证码已过期，请重新获取");
        }
        if (!session.smsCode.equals(code.trim())) {
            throw new ServiceException("验证码错误");
        }
        if (passwordEncoder.matches(newPassword, session.oldPasswordHash)) {
            throw new ServiceException("新密码不能与原密码相同");
        }
        userService.resetPassword(session.userId, newPassword);
        sessions.remove(verifyToken);
    }

    private ResetSession getSession(String verifyToken) {
        if (!StringUtils.hasText(verifyToken)) {
            throw new ServiceException("验证已失效，请返回第一步");
        }
        ResetSession session = sessions.get(verifyToken);
        if (session == null) {
            throw new ServiceException("验证已失效，请返回第一步");
        }
        if (System.currentTimeMillis() - session.createTime > EXPIRE_MS) {
            sessions.remove(verifyToken);
            throw new ServiceException("操作超时，请返回第一步");
        }
        return session;
    }

    private String normalizeUserType(String userType) {
        return "3".equals(userType) ? "2" : userType;
    }

    private String maskPhone(String phone) {
        if (!StringUtils.hasText(phone) || phone.length() < 7) {
            return phone;
        }
        return phone.substring(0, 3) + "****" + phone.substring(phone.length() - 4);
    }

    private static class ResetSession {
        private final Long userId;
        private final String phone;
        private final String oldPasswordHash;
        private final long createTime;
        private String smsCode;
        private long codeTime;

        ResetSession(Long userId, String phone, String oldPasswordHash, long createTime) {
            this.userId = userId;
            this.phone = phone;
            this.oldPasswordHash = oldPasswordHash;
            this.createTime = createTime;
        }
    }
}
