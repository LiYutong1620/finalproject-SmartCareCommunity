package com.smartcare.system.service;

import com.smartcare.common.exception.ServiceException;
import com.smartcare.system.domain.SysUser;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.random.RandomGenerator;

@Service
@RequiredArgsConstructor
public class ProfilePhoneVerifyService {

    private static final long CODE_EXPIRE_MS = 120_000;

    private final UserAccountService accountService;
    private final Map<Long, PhoneVerifySession> sessions = new ConcurrentHashMap<>();
    private final RandomGenerator random = RandomGenerator.getDefault();

    public String sendCode(Long userId, String phone) {
        if (!StringUtils.hasText(phone) || !phone.matches("^1\\d{10}$")) {
            throw new ServiceException("手机号格式不正确");
        }
        String newPhone = phone.trim();
        SysUser current = accountService.findById(userId);
        if (current != null && accountService.isPhoneUsed(newPhone, userId, current.getUserType())) {
            throw new ServiceException("手机号已被使用");
        }
        String code = String.format("%06d", random.nextInt(1_000_000));
        sessions.put(userId, new PhoneVerifySession(newPhone, code, System.currentTimeMillis()));
        return code;
    }

    public void verifyAndConsume(Long userId, String phone, String code) {
        if (!StringUtils.hasText(code)) {
            throw new ServiceException("修改手机号请输入验证码");
        }
        PhoneVerifySession session = sessions.get(userId);
        if (session == null) {
            throw new ServiceException("请先获取验证码");
        }
        if (System.currentTimeMillis() - session.codeTime > CODE_EXPIRE_MS) {
            sessions.remove(userId);
            throw new ServiceException("验证码已过期，请重新获取");
        }
        if (!session.phone.equals(phone.trim())) {
            throw new ServiceException("手机号与验证码不匹配，请重新获取");
        }
        if (!session.code.equals(code.trim())) {
            throw new ServiceException("验证码错误");
        }
        sessions.remove(userId);
    }

    private static class PhoneVerifySession {
        private final String phone;
        private final String code;
        private final long codeTime;

        PhoneVerifySession(String phone, String code, long codeTime) {
            this.phone = phone;
            this.code = code;
            this.codeTime = codeTime;
        }
    }
}
