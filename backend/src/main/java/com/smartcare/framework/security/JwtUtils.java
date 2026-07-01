package com.smartcare.framework.security;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import javax.crypto.SecretKey;
import java.nio.charset.StandardCharsets;
import java.util.Date;
import java.util.Map;

@Component
public class JwtUtils {

    @Value("${smartcare.jwt.secret}")
    private String secret;

    @Value("${smartcare.jwt.expire-minutes}")
    private long expireMinutes;

    private SecretKey key() {
        return Keys.hmacShaKeyFor(secret.getBytes(StandardCharsets.UTF_8));
    }

    public String createToken(Long userId, String username, String userType) {
        return createToken(userId, username, userType, null);
    }

    public String createToken(Long userId, String username, String userType, String permissions) {
        long now = System.currentTimeMillis();
        var builder = Jwts.builder()
            .subject(username)
            .claim("userId", userId)
            .claim("userType", userType)
            .issuedAt(new Date(now))
            .expiration(new Date(now + expireMinutes * 60 * 1000));
        if (permissions != null && !permissions.isEmpty()) {
            builder.claim("permissions", permissions);
        }
        return builder.signWith(key()).compact();
    }

    public Claims parseToken(String token) {
        return Jwts.parser().verifyWith(key()).build()
            .parseSignedClaims(token).getPayload();
    }
}
