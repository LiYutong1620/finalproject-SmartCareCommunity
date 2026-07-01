package com.smartcare.system.controller;

import com.smartcare.common.core.domain.AjaxResult;
import com.smartcare.common.exception.ServiceException;
import com.smartcare.framework.security.SecurityUtils;
import com.smartcare.system.service.SysPermissionService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/system/permission")
@RequiredArgsConstructor
public class PermissionController {

    private final SysPermissionService permissionService;

    private void checkPermission() {
        if (!SecurityUtils.hasPermission("system_permission_manage")) {
            throw new ServiceException("没有权限管理操作权限");
        }
    }

    @GetMapping("/list")
    public AjaxResult list() {
        checkPermission();
        return AjaxResult.success(permissionService.listAllPermissions());
    }

    @GetMapping("/user/{userId}")
    public AjaxResult getUserPermissions(@PathVariable Long userId) {
        checkPermission();
        return AjaxResult.success(permissionService.getUserPermissions(userId));
    }

    @PutMapping("/user/{userId}")
    public AjaxResult updateUserPermissions(@PathVariable Long userId, @RequestBody List<String> permissions) {
        checkPermission();
        permissionService.updateUserPermissions(userId, permissions);
        return AjaxResult.success();
    }
}
