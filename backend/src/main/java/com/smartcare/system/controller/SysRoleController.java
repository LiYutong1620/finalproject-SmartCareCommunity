package com.smartcare.system.controller;

import com.smartcare.common.core.domain.AjaxResult;
import com.smartcare.system.domain.SysRole;
import com.smartcare.system.service.SysRoleService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/system/role")
@RequiredArgsConstructor
public class SysRoleController {

    private final SysRoleService roleService;

    /** 角色列表 */
    @GetMapping("/list")
    public AjaxResult list() {
        return AjaxResult.success(roleService.listAll());
    }

    /** 角色详情 */
    @GetMapping("/{roleId}")
    public AjaxResult getInfo(@PathVariable Long roleId) {
        return AjaxResult.success(roleService.getById(roleId));
    }

    /** 新增角色 */
    @PostMapping
    public AjaxResult add(@RequestBody SysRole role) {
        roleService.createRole(role);
        return AjaxResult.success();
    }

    /** 修改角色 */
    @PutMapping
    public AjaxResult edit(@RequestBody SysRole role) {
        roleService.updateRole(role);
        return AjaxResult.success();
    }

    /** 删除角色 */
    @DeleteMapping("/{roleId}")
    public AjaxResult remove(@PathVariable Long roleId) {
        roleService.deleteRole(roleId);
        return AjaxResult.success();
    }

    /** 获取用户的角色ID列表 */
    @GetMapping("/user/{userId}")
    public AjaxResult getUserRoles(@PathVariable Long userId) {
        return AjaxResult.success(roleService.getUserRoleIds(userId));
    }

    /** 为用户分配角色 */
    @PutMapping("/user/{userId}")
    public AjaxResult assignUserRole(@PathVariable Long userId, @RequestBody List<Long> roleIds) {
        roleService.assignUserRole(userId, roleIds);
        return AjaxResult.success();
    }
}
