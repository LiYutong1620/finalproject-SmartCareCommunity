package com.smartcare.framework.security;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.smartcare.common.core.domain.AjaxResult;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.http.MediaType;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.List;
import java.util.Map;

/**
 * 按 URL 前缀校验登录角色，防止业主/维修工/物业跨端调用 API。
 */
@Component
@RequiredArgsConstructor
public class RolePathAuthorizationFilter extends OncePerRequestFilter {

    private static final Map<String, String> PREFIX_USER_TYPE = Map.of(
        "/owner/", "0",
        "/worker/", "1",
        "/property/", "2"
    );

    /** 三端均可访问的系统接口 */
    private static final List<String> SYSTEM_SHARED_PREFIXES = List.of(
        "/system/user/profile",
        "/system/message"
    );

    /** 仅物业可访问的系统管理接口 */
    private static final List<String> SYSTEM_PROPERTY_PREFIXES = List.of(
        "/system/user",
        "/system/role",
        "/system/permission",
        "/system/worker-skill"
    );

    private final ObjectMapper objectMapper;

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response,
                                    FilterChain chain) throws ServletException, IOException {
        var auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth == null || !(auth.getPrincipal() instanceof LoginUser loginUser)) {
            chain.doFilter(request, response);
            return;
        }

        String path = request.getRequestURI();
        String userType = loginUser.getUser().getUserType();

        for (Map.Entry<String, String> entry : PREFIX_USER_TYPE.entrySet()) {
            if (path.startsWith(entry.getKey())) {
                if (!entry.getValue().equals(userType)) {
                    deny(response, "当前角色无权访问该接口");
                    return;
                }
                chain.doFilter(request, response);
                return;
            }
        }

        if (path.startsWith("/system/")) {
            for (String prefix : SYSTEM_SHARED_PREFIXES) {
                if (path.startsWith(prefix)) {
                    chain.doFilter(request, response);
                    return;
                }
            }
            for (String prefix : SYSTEM_PROPERTY_PREFIXES) {
                if (path.startsWith(prefix)) {
                    if (!"2".equals(userType)) {
                        deny(response, "仅物业管理员可访问该接口");
                        return;
                    }
                    chain.doFilter(request, response);
                    return;
                }
            }
        }

        chain.doFilter(request, response);
    }

    private void deny(HttpServletResponse response, String message) throws IOException {
        response.setStatus(HttpServletResponse.SC_FORBIDDEN);
        response.setContentType(MediaType.APPLICATION_JSON_VALUE);
        response.setCharacterEncoding("UTF-8");
        objectMapper.writeValue(response.getWriter(), AjaxResult.error(403, message));
    }
}
