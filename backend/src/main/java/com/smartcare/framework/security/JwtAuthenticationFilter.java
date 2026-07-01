package com.smartcare.framework.security;

import com.smartcare.system.service.SysUserService;
import io.jsonwebtoken.Claims;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;

@Component
@RequiredArgsConstructor
public class JwtAuthenticationFilter extends OncePerRequestFilter {

    private final JwtUtils jwtUtils;
    private final SysUserService userService;

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response,
                                    FilterChain chain) throws ServletException, IOException {
        String token = resolveToken(request);
        if (StringUtils.hasText(token)) {
            try {
                Claims claims = jwtUtils.parseToken(token);
                String username = claims.getSubject();
                String permissions = claims.get("permissions", String.class);
                if (username != null && SecurityContextHolder.getContext().getAuthentication() == null) {
                    var user = userService.selectByUsername(username);
                    if (user != null) {
                        if (user.getPermissionCode() == null && permissions != null) {
                            user.setPermissionCode(permissions);
                        }
                        List<String> permList = parsePermissionList(user.getPermissionCode());
                        LoginUser loginUser = new LoginUser(user, permList);
                        var auth = new UsernamePasswordAuthenticationToken(
                            loginUser, null, loginUser.getAuthorities());
                        auth.setDetails(new WebAuthenticationDetailsSource().buildDetails(request));
                        SecurityContextHolder.getContext().setAuthentication(auth);
                    }
                }
            } catch (Exception ignored) {
            }
        }
        chain.doFilter(request, response);
    }

    private String resolveToken(HttpServletRequest request) {
        String bearer = request.getHeader("Authorization");
        if (StringUtils.hasText(bearer) && bearer.startsWith("Bearer ")) {
            return bearer.substring(7);
        }
        return null;
    }

    private List<String> parsePermissionList(String permissionCode) {
        if (permissionCode == null || permissionCode.isEmpty()) {
            return Collections.emptyList();
        }
        return Arrays.asList(permissionCode.split(","));
    }
}
