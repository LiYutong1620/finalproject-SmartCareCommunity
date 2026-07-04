package com.smartcare.system.service;



import com.baomidou.mybatisplus.extension.plugins.pagination.Page;

import com.smartcare.common.exception.ServiceException;

import com.smartcare.system.domain.SysUser;

import lombok.RequiredArgsConstructor;

import org.springframework.security.crypto.password.PasswordEncoder;

import org.springframework.stereotype.Service;

import org.springframework.util.StringUtils;



@Service

@RequiredArgsConstructor

public class SysUserService {



    private final UserAccountService accountService;

    private final PasswordEncoder passwordEncoder;



    public SysUser selectByUsername(String username) {

        return accountService.findByUsername(username);

    }



    public SysUser selectById(Long userId) {

        return accountService.findById(userId);

    }



    public Page<SysUser> pageList(int pageNum, int pageSize, String username, String nickName, String userType) {

        return accountService.pageList(pageNum, pageSize, username, nickName, userType);

    }



    public void register(SysUser user) {

        user.setUserType("0");

        if (!StringUtils.hasText(user.getUsername())

                || !user.getUsername().matches("^(?=.*[a-zA-Z])(?=.*\\d)[a-zA-Z0-9]{4,}$")) {

            throw new ServiceException("账号须为4位及以上英文字母与数字组合");

        }

        if (selectByUsername(user.getUsername()) != null) {

            throw new ServiceException("账号已存在");

        }

        if (StringUtils.hasText(user.getPhone())

            && accountService.isPhoneUsed(user.getPhone(), null, "0")) {

            throw new ServiceException("手机号已注册");

        }

        user.setPassword(passwordEncoder.encode(user.getPassword()));

        user.setStatus("0");

        user.setDelFlag("0");

        Long accountId = accountService.registerOwner(user);

        user.setUserId(accountId);

    }



    public void updateProfile(SysUser user) {

        accountService.updateProfile(user);

    }



    public void createUser(SysUser user) {

        Long id = accountService.createUser(user);

        user.setUserId(id);

    }



    public void updateProfileSelf(SysUser user) {

        SysUser db = accountService.findById(user.getUserId());

        if (db == null) {

            throw new ServiceException("用户不存在");

        }

        String newPhone = StringUtils.hasText(user.getPhone()) ? user.getPhone().trim() : null;
        String dbPhone = StringUtils.hasText(db.getPhone()) ? db.getPhone().trim() : null;
        if (StringUtils.hasText(newPhone) && !newPhone.equals(dbPhone)) {
            if (accountService.isPhoneUsed(newPhone, user.getUserId(), db.getUserType())) {
                throw new ServiceException("手机号已被使用");
            }
        }
        if (newPhone != null) {
            user.setPhone(newPhone);
        }

        accountService.updateProfile(user);

    }



    public void updatePassword(Long userId, String oldPassword, String newPassword) {

        if (!StringUtils.hasText(oldPassword) || !StringUtils.hasText(newPassword)) {

            throw new ServiceException("请输入原密码和新密码");

        }

        if (newPassword.length() < 6) {

            throw new ServiceException("新密码长度至少6位");

        }

        SysUser user = accountService.findById(userId);

        if (user == null) {

            throw new ServiceException("用户不存在");

        }

        if (!passwordEncoder.matches(oldPassword, user.getPassword())) {

            throw new ServiceException("原密码错误");

        }

        accountService.updatePassword(userId, passwordEncoder.encode(newPassword));

    }



    public void resetPassword(Long userId, String newPassword) {

        accountService.updatePassword(userId, passwordEncoder.encode(newPassword));

    }



    public void deleteUser(Long userId) {

        accountService.deleteUser(userId);

    }

}


