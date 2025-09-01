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
