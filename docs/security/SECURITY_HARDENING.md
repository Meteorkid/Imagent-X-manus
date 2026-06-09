# 🛡️ 安全加固实施指南

## 📋 概述

本指南提供 ImagentX 项目的安全加固实施方案。

## 🎯 加固目标

### 1. 系统安全
- 操作系统加固
- 网络安全加固
- 应用安全加固

### 2. 数据安全
- 数据加密
- 访问控制
- 数据备份

### 3. 运维安全
- 监控告警
- 日志审计
- 应急响应

## 🔧 加固措施

### 1. 操作系统加固

#### 1.1 用户管理
```bash
# 禁用 root 登录
sed -i 's/#PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config

# 使用密钥登录
ssh-keygen -t rsa -b 4096
ssh-copy-id user@server

# 设置密码策略
apt install libpam-pwquality
```

#### 1.2 文件权限
```bash
# 设置关键文件权限
chmod 600 /etc/shadow
chmod 644 /etc/passwd
chmod 700 /root

# 设置目录权限
chmod 755 /var/log
chmod 700 /etc/ssh
```

#### 1.3 服务管理
```bash
# 禁用不必要的服务
systemctl disable avahi-daemon
systemctl disable cups

# 启用防火墙
ufw enable
ufw default deny incoming
ufw default allow outgoing
```

### 2. 网络安全加固

#### 2.1 防火墙配置
```bash
# 配置防火墙规则
ufw allow 22/tcp
ufw allow 80/tcp
ufw allow 443/tcp
ufw deny 3306/tcp
ufw deny 5432/tcp
```

#### 2.2 SSL/TLS 配置
```nginx
# Nginx SSL 配置
server {
    listen 443 ssl http2;
    ssl_certificate /etc/letsencrypt/live/domain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/domain.com/privkey.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256;
    ssl_prefer_server_ciphers off;
}
```

#### 2.3 API 限流
```java
// Spring Boot 限流配置
@Configuration
public class RateLimitConfig {
    @Bean
    public RateLimiter rateLimiter() {
        return RateLimiter.create(100.0); // 100 requests per second
    }
}
```

### 3. 应用安全加固

#### 3.1 认证和授权
```java
// JWT 配置
@Configuration
public class SecurityConfig {
    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            .csrf(csrf -> csrf.disable())
            .sessionManagement(session -> 
                session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
            .authorizeHttpRequests(auth -> auth
                .requestMatchers("/api/auth/**").permitAll()
                .anyRequest().authenticated())
            .addFilterBefore(jwtAuthenticationFilter, 
                UsernamePasswordAuthenticationFilter.class);
        return http.build();
    }
}
```

#### 3.2 输入验证
```java
// 输入验证
@RestController
public class UserController {
    @PostMapping("/users")
    public ResponseEntity<User> createUser(@Valid @RequestBody UserDTO userDTO) {
        // 验证通过后处理
    }
}

// DTO 验证
public class UserDTO {
    @NotBlank
    @Email
    private String email;
    
    @NotBlank
    @Size(min = 8, max = 100)
    private String password;
}
```

#### 3.3 SQL 注入防护
```java
// 使用参数化查询
@Query("SELECT u FROM User u WHERE u.email = :email")
User findByEmail(@Param("email") String email);

// 使用 MyBatis-Plus
LambdaQueryWrapper<User> wrapper = new LambdaQueryWrapper<>();
wrapper.eq(User::getEmail, email);
User user = userMapper.selectOne(wrapper);
```

#### 3.4 XSS 防护
```java
// 输入清理
public String sanitizeInput(String input) {
    return Jsoup.clean(input, Whitelist.relaxed());
}

// 输出编码
public String encodeOutput(String output) {
    return HtmlUtils.htmlEscape(output);
}
```

### 4. 数据安全加固

#### 4.1 数据加密
```java
// 密码加密
@Bean
public PasswordEncoder passwordEncoder() {
    return new BCryptPasswordEncoder();
}

// 敏感数据加密
public String encrypt(String data, String key) {
    // 使用 AES 加密
}

public String decrypt(String encryptedData, String key) {
    // 使用 AES 解密
}
```

#### 4.2 数据备份
```bash
# 自动备份脚本
#!/bin/bash
DATE=$(date +%Y%m%d)
pg_dump -h localhost -U imagentx_user imagentx > /backup/db_$DATE.sql
find /backup -name "*.sql" -mtime +30 -delete
```

#### 4.3 访问控制
```java
// 角色权限控制
@PreAuthorize("hasRole('ADMIN')")
public void deleteUser(String userId) {
    // 只有管理员可以删除用户
}

// 数据权限控制
public List<Order> getUserOrders(String userId) {
    return orderRepository.findByUserId(userId);
}
```

### 5. 运维安全加固

#### 5.1 日志审计
```java
// 审计日志
@Aspect
@Component
public class AuditLogAspect {
    @Around("@annotation(auditLog)")
    public Object audit(ProceedingJoinPoint joinPoint, AuditLog auditLog) {
        // 记录审计日志
    }
}
```

#### 5.2 监控告警
```yaml
# Prometheus 告警规则
groups:
  - name: security
    rules:
      - alert: HighFailedLoginAttempts
        expr: rate(failed_login_attempts_total[5m]) > 0.1
        for: 5m
        labels:
          severity: warning
```

#### 5.3 应急响应
```bash
# 应急响应脚本
#!/bin/bash
# 1. 隔离受影响系统
# 2. 保存证据
# 3. 分析原因
# 4. 修复漏洞
# 5. 恢复服务
# 6. 总结改进
```

## 📊 加固效果

### 1. 量化指标
- 安全漏洞数量减少
- 安全事件响应时间缩短
- 系统可用性提升

### 2. 质化指标
- 安全意识提升
- 安全流程完善
- 安全文化建立

## 📅 加固计划

### 1. 短期计划（1-3 个月）
- 完成基础安全加固
- 修复已知安全漏洞
- 建立安全监控

### 2. 中期计划（3-6 个月）
- 实施深度安全加固
- 通过安全认证
- 建立安全体系

### 3. 长期计划（6-12 个月）
- 持续安全改进
- 安全文化建设
- 安全生态建设

## 📝 下一步

1. 制定详细加固计划
2. 实施基础加固措施
3. 验证加固效果
4. 持续安全改进
