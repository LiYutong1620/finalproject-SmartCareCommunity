package com.smartcare.framework.security;

import com.smartcare.system.domain.SysUser;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;

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
}
