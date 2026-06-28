package com.smartcare.system.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.smartcare.common.exception.ServiceException;
import com.smartcare.system.domain.SysUser;
import com.smartcare.system.mapper.SysUserMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

@Service
@RequiredArgsConstructor
public class SysUserService {

    private final SysUserMapper userMapper;
    private final PasswordEncoder passwordEncoder;

    public SysUser selectByUsername(String username) {
        return userMapper.selectOne(new LambdaQueryWrapper<SysUser>()
            .eq(SysUser::getUsername, username).eq(SysUser::getDelFlag, "0"));
    }

    public SysUser selectById(Long userId) {
        return userMapper.selectById(userId);
    }

    public Page<SysUser> pageList(int pageNum, int pageSize, String username, String userType) {
        LambdaQueryWrapper<SysUser> qw = new LambdaQueryWrapper<SysUser>()
            .eq(SysUser::getDelFlag, "0")
            .like(StringUtils.hasText(username), SysUser::getUsername, username)
            .eq(StringUtils.hasText(userType), SysUser::getUserType, userType);
        return userMapper.selectPage(new Page<>(pageNum, pageSize), qw);
    }

    public void register(SysUser user) {
        user.setUserType("0");
        if (selectByUsername(user.getUsername()) != null) {
            throw new ServiceException("账号已存在");
        }
        if (StringUtils.hasText(user.getPhone())) {
            Long cnt = userMapper.selectCount(new LambdaQueryWrapper<SysUser>()
                .eq(SysUser::getPhone, user.getPhone()).eq(SysUser::getDelFlag, "0"));
            if (cnt > 0) throw new ServiceException("手机号已注册");
        }
        user.setPassword(passwordEncoder.encode(user.getPassword()));
        user.setStatus("0");
        user.setDelFlag("0");
        userMapper.insert(user);
    }

    public void updateProfile(SysUser user) {
        userMapper.updateById(user);
    }

    public void updateProfileSelf(SysUser user) {
        SysUser db = userMapper.selectById(user.getUserId());
        if (db == null) {
            throw new ServiceException("用户不存在");
        }
        if (StringUtils.hasText(user.getPhone()) && !user.getPhone().equals(db.getPhone())) {
            Long cnt = userMapper.selectCount(new LambdaQueryWrapper<SysUser>()
                .eq(SysUser::getPhone, user.getPhone())
                .eq(SysUser::getDelFlag, "0")
                .ne(SysUser::getUserId, user.getUserId()));
            if (cnt > 0) {
                throw new ServiceException("手机号已被使用");
            }
        }
        SysUser update = new SysUser();
        update.setUserId(user.getUserId());
        update.setNickName(user.getNickName());
        update.setPhone(user.getPhone());
        update.setGender(user.getGender());
        update.setAge(user.getAge());
        if (user.getAvatar() != null) {
            update.setAvatar(user.getAvatar());
        }
        userMapper.updateById(update);
    }

    public void updatePassword(Long userId, String oldPassword, String newPassword) {
        if (!StringUtils.hasText(oldPassword) || !StringUtils.hasText(newPassword)) {
            throw new ServiceException("请输入原密码和新密码");
        }
        if (newPassword.length() < 6) {
            throw new ServiceException("新密码长度至少6位");
        }
        SysUser user = userMapper.selectById(userId);
        if (user == null) {
            throw new ServiceException("用户不存在");
        }
        if (!passwordEncoder.matches(oldPassword, user.getPassword())) {
            throw new ServiceException("原密码错误");
        }
        SysUser update = new SysUser();
        update.setUserId(userId);
        update.setPassword(passwordEncoder.encode(newPassword));
        userMapper.updateById(update);
    }

    public void resetPassword(Long userId, String newPassword) {
        SysUser u = new SysUser();
        u.setUserId(userId);
        u.setPassword(passwordEncoder.encode(newPassword));
        userMapper.updateById(u);
    }

    public void deleteUser(Long userId) {
        SysUser u = new SysUser();
        u.setUserId(userId);
        u.setDelFlag("2");
        userMapper.updateById(u);
    }
}
