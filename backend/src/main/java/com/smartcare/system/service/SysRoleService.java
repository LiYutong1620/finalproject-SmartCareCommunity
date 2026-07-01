package com.smartcare.system.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.smartcare.common.exception.ServiceException;
import com.smartcare.system.domain.SysRole;
import com.smartcare.system.domain.SysUserRole;
import com.smartcare.system.mapper.SysRoleMapper;
import com.smartcare.system.mapper.SysUserRoleMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class SysRoleService {

    private final SysRoleMapper roleMapper;
    private final SysUserRoleMapper userRoleMapper;

    public List<SysRole> listAll() {
        return roleMapper.selectList(new LambdaQueryWrapper<SysRole>()
            .orderByAsc(SysRole::getRoleId));
    }

    public SysRole getById(Long roleId) {
        return roleMapper.selectById(roleId);
    }

    @Transactional
    public void createRole(SysRole role) {
        if (!StringUtils.hasText(role.getRoleName())) {
            throw new ServiceException("角色名称不能为空");
        }
        if (!StringUtils.hasText(role.getRoleKey())) {
            throw new ServiceException("角色标识不能为空");
        }
        // 检查roleKey唯一性
        Long cnt = roleMapper.selectCount(new LambdaQueryWrapper<SysRole>()
            .eq(SysRole::getRoleKey, role.getRoleKey()));
        if (cnt > 0) {
            throw new ServiceException("角色标识已存在");
        }
        role.setStatus("0");
        role.setCreateTime(LocalDateTime.now());
        roleMapper.insert(role);
    }

    @Transactional
    public void updateRole(SysRole role) {
        if (role.getRoleId() == null) {
            throw new ServiceException("角色ID不能为空");
        }
        SysRole db = roleMapper.selectById(role.getRoleId());
        if (db == null) {
            throw new ServiceException("角色不存在");
        }
        roleMapper.updateById(role);
    }

    @Transactional
    public void deleteRole(Long roleId) {
        // 检查是否有用户关联
        Long cnt = userRoleMapper.selectCount(new LambdaQueryWrapper<SysUserRole>()
            .eq(SysUserRole::getRoleId, roleId));
        if (cnt > 0) {
            throw new ServiceException("该角色下存在用户，无法删除");
        }
        roleMapper.deleteById(roleId);
    }

    public List<Long> getUserRoleIds(Long userId) {
        List<SysUserRole> list = userRoleMapper.selectList(
            new LambdaQueryWrapper<SysUserRole>().eq(SysUserRole::getUserId, userId));
        return list.stream().map(SysUserRole::getRoleId).toList();
    }

    @Transactional
    public void assignUserRole(Long userId, List<Long> roleIds) {
        // 删除旧关联
        userRoleMapper.delete(new LambdaQueryWrapper<SysUserRole>()
            .eq(SysUserRole::getUserId, userId));
        // 插入新关联
        if (roleIds != null) {
            for (Long roleId : roleIds) {
                SysUserRole ur = new SysUserRole();
                ur.setUserId(userId);
                ur.setRoleId(roleId);
                userRoleMapper.insert(ur);
            }
        }
    }
}
