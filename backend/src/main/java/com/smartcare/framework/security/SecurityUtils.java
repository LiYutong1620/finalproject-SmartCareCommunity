package com.smartcare.framework.security;

import com.smartcare.system.domain.SysUser;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;

import java.util.Arrays;

public final class SecurityUtils {

    private SecurityUtils() {}

    public static LoginUser getLoginUser() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth != null && auth.getPrincipal() instanceof LoginUser loginUser) {
            return loginUser;
        }
        return null;
    }

    public static Long getUserId() {
        LoginUser u = getLoginUser();
        return u != null ? u.getUser().getUserId() : null;
    }

    public static SysUser getUser() {
        LoginUser u = getLoginUser();
        return u != null ? u.getUser() : null;
    }

    public static boolean hasPermission(String code) {
        LoginUser u = getLoginUser();
        if (u == null || u.getUser() == null) return false;
        String perms = u.getUser().getPermissionCode();
        if (perms == null || perms.isEmpty()) return false;
        return Arrays.asList(perms.split(",")).contains(code);
    }
}
