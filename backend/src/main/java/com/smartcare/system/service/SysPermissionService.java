package com.smartcare.system.service;

import com.smartcare.system.domain.SysUser;
import com.smartcare.system.service.UserAccountService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.*;

@Service
@RequiredArgsConstructor
public class SysPermissionService {

    private final UserAccountService accountService;

    private static final List<Map<String, String>> PERMISSIONS = new ArrayList<>();

    static {
        addPermission("elder_view", "老人信息查看");
        addPermission("elder_manage", "老人关怀管理");
        addPermission("elder_staff_manage", "关怀人员管理");
        addPermission("dashboard_view", "数据大屏查看");
        addPermission("report_export", "报表导出");
        addPermission("repair_manage", "工单管理");
        addPermission("repair_assign", "工单派单");
        addPermission("system_user_manage", "用户管理");
        addPermission("system_permission_manage", "权限管理");
        addPermission("ai_monitor_view", "AI监测查看");
        addPermission("ai_monitor_config", "AI监测配置");
    }

    private static void addPermission(String code, String name) {
        Map<String, String> map = new LinkedHashMap<>();
        map.put("code", code);
        map.put("name", name);
        PERMISSIONS.add(map);
    }

    public List<Map<String, String>> listAllPermissions() {
        return PERMISSIONS;
    }

    public List<String> getUserPermissions(Long userId) {
        SysUser user = accountService.findById(userId);
        if (user == null || user.getPermissionCode() == null || user.getPermissionCode().isEmpty()) {
            return Collections.emptyList();
        }
        return Arrays.asList(user.getPermissionCode().split(","));
    }

    @Transactional
    public void updateUserPermissions(Long userId, List<String> permissions) {
        SysUser user = new SysUser();
        user.setUserId(userId);
        user.setPermissionCode(permissions == null || permissions.isEmpty() ? "" : String.join(",", permissions));
        accountService.updateProfile(user);
    }
}
