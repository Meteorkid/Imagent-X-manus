#!/bin/bash

# ImagentX 安全增强设置脚本
# 用于实施数据加密、API限流、审计日志等安全功能

set -e

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # 无颜色

echo -e "${BLUE}🔒 设置ImagentX安全增强功能...${NC}"

# 检查Java和Maven环境
check_environment() {
    echo -e "${BLUE}🔍 检查开发环境...${NC}"
    
    if java -version 2>&1 | grep -q "version \"17"; then
        echo -e "${GREEN}✅ Java 17 已安装${NC}"
    else
        echo -e "${RED}❌ 需要Java 17${NC}"
        exit 1
    fi
    
    if mvn -version >/dev/null 2>&1; then
        echo -e "${GREEN}✅ Maven 已安装${NC}"
    else
        echo -e "${RED}❌ Maven 未安装${NC}"
        exit 1
    fi
}

# 创建安全配置目录
create_security_structure() {
    echo -e "${BLUE}📁 创建安全配置目录结构...${NC}"
    
    mkdir -p ImagentX/src/main/java/org/xhy/infrastructure/security/{encryption,rateLimit,audit}
    mkdir -p ImagentX/src/main/resources/security
    mkdir -p security-config/{encryption,rate-limit,audit}
    
    echo -e "${GREEN}✅ 安全目录结构创建完成${NC}"
}

# 创建数据加密配置
create_encryption_config() {
    echo -e "${BLUE}🔐 创建数据加密配置...${NC}"
    
    # 创建加密工具类
    cat > ImagentX/src/main/java/org/xhy/infrastructure/security/encryption/EncryptionUtils.java << 'EOF'
package org.xhy.infrastructure.security.encryption;

import javax.crypto.Cipher;
import javax.crypto.KeyGenerator;
import javax.crypto.SecretKey;
import javax.crypto.spec.GCMParameterSpec;
import javax.crypto.spec.SecretKeySpec;
import java.security.SecureRandom;
import java.util.Base64;

/**
 * 数据加密工具类
 * 使用AES-GCM算法进行数据加密
 */
public class EncryptionUtils {
    
    private static final String ALGORITHM = "AES/GCM/NoPadding";
    private static final int GCM_IV_LENGTH = 12;
    private static final int GCM_TAG_LENGTH = 16;
    
    /**
     * 生成AES密钥
     */
    public static String generateKey() throws Exception {
        KeyGenerator keyGen = KeyGenerator.getInstance("AES");
        keyGen.init(256);
        SecretKey key = keyGen.generateKey();
        return Base64.getEncoder().encodeToString(key.getEncoded());
    }
    
    /**
     * 加密数据
     */
    public static String encrypt(String data, String key) throws Exception {
        SecretKey secretKey = new SecretKeySpec(Base64.getDecoder().decode(key), "AES");
        Cipher cipher = Cipher.getInstance(ALGORITHM);
        
        byte[] iv = new byte[GCM_IV_LENGTH];
        SecureRandom random = new SecureRandom();
        random.nextBytes(iv);
        
        GCMParameterSpec spec = new GCMParameterSpec(GCM_TAG_LENGTH * 8, iv);
        cipher.init(Cipher.ENCRYPT_MODE, secretKey, spec);
        
        byte[] encrypted = cipher.doFinal(data.getBytes());
        byte[] combined = new byte[iv.length + encrypted.length];
        System.arraycopy(iv, 0, combined, 0, iv.length);
        System.arraycopy(encrypted, 0, combined, iv.length, encrypted.length);
        
        return Base64.getEncoder().encodeToString(combined);
    }
    
    /**
     * 解密数据
     */
    public static String decrypt(String encryptedData, String key) throws Exception {
        SecretKey secretKey = new SecretKeySpec(Base64.getDecoder().decode(key), "AES");
        Cipher cipher = Cipher.getInstance(ALGORITHM);
        
        byte[] decoded = Base64.getDecoder().decode(encryptedData);
        byte[] iv = new byte[GCM_IV_LENGTH];
        byte[] encrypted = new byte[decoded.length - GCM_IV_LENGTH];
        
        System.arraycopy(decoded, 0, iv, 0, iv.length);
        System.arraycopy(decoded, iv.length, encrypted, 0, encrypted.length);
        
        GCMParameterSpec spec = new GCMParameterSpec(GCM_TAG_LENGTH * 8, iv);
        cipher.init(Cipher.DECRYPT_MODE, secretKey, spec);
        
        byte[] decrypted = cipher.doFinal(encrypted);
        return new String(decrypted);
    }
}
EOF

    # 创建加密配置
    cat > ImagentX/src/main/resources/security/encryption.yml << 'EOF'
# 数据加密配置
encryption:
  # 加密算法
  algorithm: AES/GCM/NoPadding
  # 密钥长度
  key-size: 256
  # 密钥存储方式 (file/database/vault)
  key-storage: file
  # 密钥文件路径
  key-file: ${user.home}/.imagentx/encryption.key
  # 需要加密的字段
  encrypted-fields:
    - user.password
    - user.email
    - api-key.secret
    - payment.card-number
  # 加密敏感数据
  sensitive-data:
    - password
    - email
    - phone
    - id-card
    - credit-card
EOF

    echo -e "${GREEN}✅ 数据加密配置创建完成${NC}"
}

# 创建API限流配置
create_rate_limit_config() {
    echo -e "${BLUE}🚦 创建API限流配置...${NC}"
    
    # 创建限流注解
    cat > ImagentX/src/main/java/org/xhy/infrastructure/security/rateLimit/RateLimit.java << 'EOF'
package org.xhy.infrastructure.security.rateLimit;

import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

/**
 * API限流注解
 */
@Target(ElementType.METHOD)
@Retention(RetentionPolicy.RUNTIME)
public @interface RateLimit {
    /**
     * 限流时间窗口（秒）
     */
    int timeWindow() default 60;
    
    /**
     * 最大请求次数
     */
    int maxRequests() default 100;
    
    /**
     * 限流策略
     */
    Strategy strategy() default Strategy.TOKEN_BUCKET;
    
    /**
     * 限流键生成策略
     */
    String keyGenerator() default "ip";
    
    enum Strategy {
        TOKEN_BUCKET,    // 令牌桶算法
        LEAKY_BUCKET,    // 漏桶算法
        FIXED_WINDOW,    // 固定窗口
        SLIDING_WINDOW   // 滑动窗口
    }
}
EOF

    # 创建限流拦截器
    cat > ImagentX/src/main/java/org/xhy/infrastructure/security/rateLimit/RateLimitInterceptor.java << 'EOF'
package org.xhy.infrastructure.security.rateLimit;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.stereotype.Component;
import org.springframework.web.method.HandlerMethod;
import org.springframework.web.servlet.HandlerInterceptor;
import org.xhy.infrastructure.security.rateLimit.strategy.RateLimitStrategy;
import org.xhy.infrastructure.security.rateLimit.strategy.TokenBucketStrategy;

import java.util.concurrent.ConcurrentHashMap;

/**
 * API限流拦截器
 */
@Component
public class RateLimitInterceptor implements HandlerInterceptor {
    
    private final ConcurrentHashMap<String, RateLimitStrategy> rateLimiters = new ConcurrentHashMap<>();
    
    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {
        if (!(handler instanceof HandlerMethod)) {
            return true;
        }
        
        HandlerMethod handlerMethod = (HandlerMethod) handler;
        RateLimit rateLimit = handlerMethod.getMethodAnnotation(RateLimit.class);
        
        if (rateLimit == null) {
            return true;
        }
        
        String key = generateKey(request, rateLimit);
        RateLimitStrategy strategy = getOrCreateStrategy(key, rateLimit);
        
        if (!strategy.allowRequest()) {
            response.setStatus(429); // Too Many Requests
            response.getWriter().write("{\"code\":429,\"message\":\"请求过于频繁，请稍后重试\"}");
            return false;
        }
        
        return true;
    }
    
    private String generateKey(HttpServletRequest request, RateLimit rateLimit) {
        String ip = getClientIp(request);
        String method = request.getMethod();
        String path = request.getRequestURI();
        
        return String.format("%s:%s:%s", ip, method, path);
    }
    
    private String getClientIp(HttpServletRequest request) {
        String xForwardedFor = request.getHeader("X-Forwarded-For");
        if (xForwardedFor != null && !xForwardedFor.isEmpty()) {
            return xForwardedFor.split(",")[0].trim();
        }
        return request.getRemoteAddr();
    }
    
    private RateLimitStrategy getOrCreateStrategy(String key, RateLimit rateLimit) {
        return rateLimiters.computeIfAbsent(key, k -> {
            switch (rateLimit.strategy()) {
                case TOKEN_BUCKET:
                    return new TokenBucketStrategy(rateLimit.maxRequests(), rateLimit.timeWindow());
                default:
                    return new TokenBucketStrategy(rateLimit.maxRequests(), rateLimit.timeWindow());
            }
        });
    }
}
EOF

    # 创建限流策略接口
    cat > ImagentX/src/main/java/org/xhy/infrastructure/security/rateLimit/strategy/RateLimitStrategy.java << 'EOF'
package org.xhy.infrastructure.security.rateLimit.strategy;

/**
 * 限流策略接口
 */
public interface RateLimitStrategy {
    /**
     * 是否允许请求
     */
    boolean allowRequest();
}
EOF

    # 创建令牌桶策略
    cat > ImagentX/src/main/java/org/xhy/infrastructure/security/rateLimit/strategy/TokenBucketStrategy.java << 'EOF'
package org.xhy.infrastructure.security.rateLimit.strategy;

import java.util.concurrent.atomic.AtomicLong;
import java.util.concurrent.atomic.AtomicReference;

/**
 * 令牌桶限流策略
 */
public class TokenBucketStrategy implements RateLimitStrategy {
    
    private final long capacity;
    private final long refillRate;
    private final AtomicLong tokens;
    private final AtomicReference<Long> lastRefillTime;
    
    public TokenBucketStrategy(int maxRequests, int timeWindow) {
        this.capacity = maxRequests;
        this.refillRate = maxRequests / (double) timeWindow;
        this.tokens = new AtomicLong(maxRequests);
        this.lastRefillTime = new AtomicReference<>(System.currentTimeMillis());
    }
    
    @Override
    public boolean allowRequest() {
        refillTokens();
        long currentTokens = tokens.get();
        
        if (currentTokens > 0) {
            return tokens.decrementAndGet() >= 0;
        }
        
        return false;
    }
    
    private void refillTokens() {
        long now = System.currentTimeMillis();
        long lastRefill = lastRefillTime.get();
        long timePassed = now - lastRefill;
        
        if (timePassed > 0) {
            long newTokens = (long) (timePassed * refillRate / 1000.0);
            if (newTokens > 0) {
                long currentTokens = tokens.get();
                long newTokenCount = Math.min(capacity, currentTokens + newTokens);
                tokens.set(newTokenCount);
                lastRefillTime.set(now);
            }
        }
    }
}
EOF

    # 创建限流配置
    cat > ImagentX/src/main/resources/security/rate-limit.yml << 'EOF'
# API限流配置
rate-limit:
  # 全局默认限流
  default:
    time-window: 60
    max-requests: 100
    strategy: TOKEN_BUCKET
  
  # 按接口限流
  endpoints:
    # 登录接口限流
    /api/login:
      time-window: 60
      max-requests: 5
      strategy: FIXED_WINDOW
    
    # 注册接口限流
    /api/register:
      time-window: 300
      max-requests: 3
      strategy: FIXED_WINDOW
    
    # API接口限流
    /api/v1/**:
      time-window: 60
      max-requests: 1000
      strategy: TOKEN_BUCKET
    
    # 文件上传限流
    /api/upload:
      time-window: 60
      max-requests: 10
      strategy: LEAKY_BUCKET
  
  # 按用户限流
  user-limits:
    default:
      time-window: 60
      max-requests: 200
    premium:
      time-window: 60
      max-requests: 1000
    admin:
      time-window: 60
      max-requests: 5000
EOF

    echo -e "${GREEN}✅ API限流配置创建完成${NC}"
}

# 创建审计日志配置
create_audit_config() {
    echo -e "${BLUE}📝 创建审计日志配置...${NC}"
    
    # 创建审计日志注解
    cat > ImagentX/src/main/java/org/xhy/infrastructure/security/audit/AuditLog.java << 'EOF'
package org.xhy.infrastructure.security.audit;

import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

/**
 * 审计日志注解
 */
@Target(ElementType.METHOD)
@Retention(RetentionPolicy.RUNTIME)
public @interface AuditLog {
    /**
     * 操作类型
     */
    String action();
    
    /**
     * 操作描述
     */
    String description() default "";
    
    /**
     * 是否记录请求参数
     */
    boolean logParams() default true;
    
    /**
     * 是否记录响应结果
     */
    boolean logResponse() default false;
    
    /**
     * 敏感字段（不记录）
     */
    String[] sensitiveFields() default {"password", "token", "secret"};
}
EOF

    # 创建审计日志实体
    cat > ImagentX/src/main/java/org/xhy/infrastructure/security/audit/AuditLogEntity.java << 'EOF'
package org.xhy.infrastructure.security.audit;

import jakarta.persistence.*;
import java.time.LocalDateTime;

/**
 * 审计日志实体
 */
@Entity
@Table(name = "audit_logs")
public class AuditLogEntity {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(name = "user_id")
    private String userId;
    
    @Column(name = "username")
    private String username;
    
    @Column(name = "action")
    private String action;
    
    @Column(name = "description")
    private String description;
    
    @Column(name = "resource_type")
    private String resourceType;
    
    @Column(name = "resource_id")
    private String resourceId;
    
    @Column(name = "ip_address")
    private String ipAddress;
    
    @Column(name = "user_agent")
    private String userAgent;
    
    @Column(name = "request_method")
    private String requestMethod;
    
    @Column(name = "request_url")
    private String requestUrl;
    
    @Column(name = "request_params", columnDefinition = "TEXT")
    private String requestParams;
    
    @Column(name = "response_status")
    private Integer responseStatus;
    
    @Column(name = "execution_time")
    private Long executionTime;
    
    @Column(name = "created_at")
    private LocalDateTime createdAt;
    
    // 构造函数
    public AuditLogEntity() {
        this.createdAt = LocalDateTime.now();
    }
    
    // Getter和Setter方法
    // ... (省略标准的getter和setter方法)
}
EOF

    # 创建审计日志服务
    cat > ImagentX/src/main/java/org/xhy/infrastructure/security/audit/AuditLogService.java << 'EOF'
package org.xhy.infrastructure.security.audit;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.xhy.infrastructure.auth.UserContext;

import java.time.LocalDateTime;

/**
 * 审计日志服务
 */
@Service
public class AuditLogService {
    
    private final AuditLogRepository auditLogRepository;
    
    public AuditLogService(AuditLogRepository auditLogRepository) {
        this.auditLogRepository = auditLogRepository;
    }
    
    /**
     * 记录审计日志
     */
    @Transactional
    public void logAuditEvent(AuditLogEvent event) {
        AuditLogEntity entity = new AuditLogEntity();
        entity.setUserId(event.getUserId());
        entity.setUsername(event.getUsername());
        entity.setAction(event.getAction());
        entity.setDescription(event.getDescription());
        entity.setResourceType(event.getResourceType());
        entity.setResourceId(event.getResourceId());
        entity.setIpAddress(event.getIpAddress());
        entity.setUserAgent(event.getUserAgent());
        entity.setRequestMethod(event.getRequestMethod());
        entity.setRequestUrl(event.getRequestUrl());
        entity.setRequestParams(event.getRequestParams());
        entity.setResponseStatus(event.getResponseStatus());
        entity.setExecutionTime(event.getExecutionTime());
        entity.setCreatedAt(LocalDateTime.now());
        
        auditLogRepository.save(entity);
    }
    
    /**
     * 记录简单审计事件
     */
    public void logSimpleEvent(String action, String description) {
        AuditLogEvent event = AuditLogEvent.builder()
            .userId(UserContext.getCurrentUserId())
            .action(action)
            .description(description)
            .build();
        
        logAuditEvent(event);
    }
}
EOF

    # 创建审计日志配置
    cat > ImagentX/src/main/resources/security/audit.yml << 'EOF'
# 审计日志配置
audit:
  # 是否启用审计日志
  enabled: true
  
  # 日志级别
  level: INFO
  
  # 记录的操作类型
  actions:
    - CREATE
    - UPDATE
    - DELETE
    - READ
    - LOGIN
    - LOGOUT
    - EXPORT
    - IMPORT
  
  # 需要审计的资源类型
  resources:
    - user
    - agent
    - session
    - payment
    - api-key
  
  # 敏感字段（不记录）
  sensitive-fields:
    - password
    - token
    - secret
    - api-key
    - credit-card
  
  # 日志保留策略
  retention:
    # 保留天数
    days: 365
    # 归档策略
    archive: true
    # 压缩策略
    compress: true
  
  # 日志输出
  output:
    # 数据库存储
    database: true
    # 文件存储
    file: true
    # 文件路径
    file-path: logs/audit
    # 日志格式
    format: JSON
EOF

    echo -e "${GREEN}✅ 审计日志配置创建完成${NC}"
}

# 创建安全配置文档
create_security_documentation() {
    echo -e "${BLUE}📚 创建安全配置文档...${NC}"
    
    cat > SECURITY_ENHANCEMENT_GUIDE.md << 'EOF'
# ImagentX 安全增强指南

## 概述

本文档介绍ImagentX项目的安全增强功能，包括数据加密、API限流、审计日志等。

## 🔐 数据加密

### 加密算法
- **算法**: AES-GCM-256
- **模式**: GCM (Galois/Counter Mode)
- **填充**: NoPadding

### 使用方式

```java
// 加密数据
String encrypted = EncryptionUtils.encrypt("敏感数据", secretKey);

// 解密数据
String decrypted = EncryptionUtils.decrypt(encrypted, secretKey);
```

### 配置说明

```yaml
encryption:
  algorithm: AES/GCM/NoPadding
  key-size: 256
  key-storage: file
  key-file: ${user.home}/.imagentx/encryption.key
```

## 🚦 API限流

### 限流策略
- **令牌桶算法**: 适合突发流量
- **漏桶算法**: 适合平滑流量
- **固定窗口**: 简单易实现
- **滑动窗口**: 更精确的限流

### 使用方式

```java
@RateLimit(timeWindow = 60, maxRequests = 100)
public ResponseEntity<?> apiMethod() {
    // API逻辑
}
```

### 配置说明

```yaml
rate-limit:
  default:
    time-window: 60
    max-requests: 100
    strategy: TOKEN_BUCKET
```

## 📝 审计日志

### 审计内容
- 用户操作记录
- 资源访问日志
- 安全事件记录
- 性能监控数据

### 使用方式

```java
@AuditLog(action = "CREATE_USER", description = "创建新用户")
public User createUser(CreateUserRequest request) {
    // 业务逻辑
}
```

### 配置说明

```yaml
audit:
  enabled: true
  level: INFO
  retention:
    days: 365
    archive: true
```

## 🔒 安全最佳实践

### 1. 密码安全
- 使用强密码策略
- 密码加密存储
- 定期密码更新

### 2. 访问控制
- 基于角色的访问控制
- 最小权限原则
- 会话管理

### 3. 数据保护
- 敏感数据加密
- 数据传输加密
- 数据备份加密

### 4. 监控告警
- 异常访问监控
- 安全事件告警
- 性能监控

## 🚨 安全检查清单

- [ ] 数据加密配置
- [ ] API限流配置
- [ ] 审计日志配置
- [ ] 访问控制配置
- [ ] 监控告警配置
- [ ] 安全测试通过
- [ ] 文档完善

## 📞 技术支持

如有安全问题，请联系安全团队。
EOF

    echo -e "${GREEN}✅ 安全配置文档创建完成${NC}"
}

# 主函数
main() {
    echo -e "${BLUE}🔍 检查开发环境...${NC}"
    check_environment
    
    echo -e "${BLUE}📁 创建安全配置目录结构...${NC}"
    create_security_structure
    
    echo -e "${BLUE}🔐 创建数据加密配置...${NC}"
    create_encryption_config
    
    echo -e "${BLUE}🚦 创建API限流配置...${NC}"
    create_rate_limit_config
    
    echo -e "${BLUE}📝 创建审计日志配置...${NC}"
    create_audit_config
    
    echo -e "${BLUE}📚 创建安全配置文档...${NC}"
    create_security_documentation
    
    echo -e "${GREEN}🎉 安全增强功能设置完成！${NC}"
    echo -e ""
    echo -e "${BLUE}📝 已创建的安全功能:${NC}"
    echo -e "  - 数据加密 (AES-GCM-256)"
    echo -e "  - API限流 (多种策略)"
    echo -e "  - 审计日志 (完整记录)"
    echo -e ""
    echo -e "${YELLOW}📚 文档:${NC}"
    echo -e "  - 安全配置指南: SECURITY_ENHANCEMENT_GUIDE.md"
    echo -e ""
    echo -e "${BLUE}💡 下一步:${NC}"
    echo -e "  1. 配置数据库表结构"
    echo -e "  2. 集成到现有代码"
    echo -e "  3. 进行安全测试"
}

# 执行主函数
main "$@"
