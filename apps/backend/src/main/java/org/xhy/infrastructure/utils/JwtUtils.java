package org.xhy.infrastructure.utils;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.JwtException;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.io.Decoders;
import io.jsonwebtoken.security.Keys;
import org.springframework.beans.factory.InitializingBean;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import javax.crypto.SecretKey;
import java.util.Date;

@Component
public class JwtUtils implements InitializingBean {

    private final String jwtSecret;

    // token过期时间 - 24小时
    private static final long EXPIRATION_TIME = 24 * 60 * 60 * 1000;

    public JwtUtils(@Value("${jwt.secret:}") String jwtSecret) {
        this.jwtSecret = jwtSecret;
    }

    @Override
    public void afterPropertiesSet() {
        if (jwtSecret == null || jwtSecret.isEmpty()) {
            throw new IllegalStateException(
                "JWT 密钥未配置！请设置环境变量 JWT_SECRET。" +
                "参考 .env.example 文件获取配置说明。"
            );
        }
        if (jwtSecret.length() < 32) {
            throw new IllegalStateException(
                "JWT 密钥长度不足！至少需要 32 个字符。" +
                "使用命令生成：openssl rand -base64 32"
            );
        }
    }

    private SecretKey getSigningKey() {
        byte[] keyBytes = Decoders.BASE64.decode(jwtSecret);
        return Keys.hmacShaKeyFor(keyBytes);
    }

    /** 生成JWT Token */
    public String generateToken(String userId) {
        Date now = new Date();
        Date expiryDate = new Date(now.getTime() + EXPIRATION_TIME);

        return Jwts.builder().subject(userId).issuedAt(now).expiration(expiryDate).signWith(getSigningKey()).compact();
    }

    /** 从token中获取用户ID */
    public String getUserIdFromToken(String token) {
        Claims claims = Jwts.parser().verifyWith(getSigningKey()).build().parseSignedClaims(token).getPayload();

        return claims.getSubject();
    }

    /** 验证token是否有效 */
    public boolean validateToken(String token) {
        try {
            Jwts.parser().verifyWith(getSigningKey()).build().parseSignedClaims(token);
            return true;
        } catch (JwtException | IllegalArgumentException e) {
            return false;
        }
    }
}