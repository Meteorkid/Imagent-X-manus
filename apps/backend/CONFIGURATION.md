# 📋 后端配置文件说明

## 📁 配置文件列表

| 文件 | 用途 | 数据库 | 适用环境 |
|------|------|--------|----------|
| `application.yml` | 主配置文件 | PostgreSQL | 生产/测试 |
| `application-dev.yml` | 开发环境 | H2 内存 | 本地开发 |
| `application-local.yml` | 本地环境 | H2 内存 | 本地开发 |
| `application-h2.yml` | H2 测试 | H2 内存 | 单元测试 |
| `application-simple.yml` | 简化配置 | H2 内存 | 快速测试 |
| `application-no-vector.yml` | 无向量配置 | PostgreSQL | 无向量功能 |

## 🚀 使用方式

### 1. 本地开发（推荐）

```bash
# 使用开发环境配置
java -jar target/imagent-x-1.0.3.jar --spring.profiles.active=dev

# 或使用 Maven
mvn spring-boot:run -Dspring-boot.run.profiles=dev
```

### 2. 生产环境

```bash
# 使用主配置文件（默认）
java -jar target/imagent-x-1.0.3.jar

# 或显式指定
java -jar target/imagent-x-1.0.3.jar --spring.profiles.active=prod
```

### 3. 单元测试

```bash
# 使用 H2 配置
mvn test -Dspring.profiles.active=h2

# 或使用简化配置
mvn test -Dspring.profiles.active=simple
```

### 4. 无向量功能

```bash
# 禁用向量存储功能
java -jar target/imagent-x-1.0.3.jar --spring.profiles.active=no-vector
```

## ⚙️ 配置优先级

1. **命令行参数**: `--server.port=9090`
2. **环境变量**: `SERVER_PORT=9090`
3. **Profile 配置**: `application-{profile}.yml`
4. **主配置**: `application.yml`

## 🔧 环境变量配置

### 数据库配置
```bash
# PostgreSQL
DB_HOST=localhost
DB_PORT=5432
DB_NAME=imagentx
DB_USER=imagentx_user
DB_PASSWORD=your_password

# H2（开发/测试）
H2_USERNAME=sa
H2_PASSWORD=
```

### 消息队列配置
```bash
RABBITMQ_HOST=localhost
RABBITMQ_PORT=5672
RABBITMQ_USERNAME=guest
RABBITMQ_PASSWORD=guest
```

### 应用配置
```bash
SERVER_PORT=8088
JWT_SECRET=your_jwt_secret_key
```

## 📊 配置对比

### 数据源配置

| 配置文件 | 驱动 | URL | 用户名 | 密码 |
|----------|------|-----|--------|------|
| application.yml | PostgreSQL | jdbc:postgresql://... | ${DB_USER} | ${DB_PASSWORD} |
| application-dev.yml | H2 | jdbc:h2:mem:testdb | ${H2_USERNAME} | ${H2_PASSWORD} |
| application-local.yml | H2 | jdbc:h2:mem:testdb | ${H2_USERNAME} | ${H2_PASSWORD} |
| application-h2.yml | H2 | jdbc:h2:mem:testdb | ${H2_USERNAME} | ${H2_PASSWORD} |
| application-simple.yml | H2 | jdbc:h2:mem:testdb | ${H2_USERNAME} | ${H2_PASSWORD} |
| application-no-vector.yml | PostgreSQL | jdbc:postgresql://... | ${DB_USER} | ${DB_PASSWORD} |

### 功能配置

| 配置文件 | RabbitMQ | 向量存储 | 高可用 |
|----------|----------|----------|--------|
| application.yml | ✅ | ✅ | ❌ |
| application-dev.yml | ✅ | ❌ | ❌ |
| application-local.yml | ✅ | ❌ | ❌ |
| application-h2.yml | ✅ | ❌ | ❌ |
| application-simple.yml | ❌ | ❌ | ❌ |
| application-no-vector.yml | ✅ | ❌ | ❌ |

## 🎯 推荐配置

### 本地开发
```bash
# .env 文件
SPRING_PROFILES_ACTIVE=dev
DB_HOST=localhost
DB_PORT=5432
DB_NAME=imagentx
DB_USER=imagentx_user
DB_PASSWORD=dev_password
JWT_SECRET=dev_jwt_secret_key_32_chars_minimum
```

### 生产环境
```bash
# .env 文件
SPRING_PROFILES_ACTIVE=prod
DB_HOST=production-db-host
DB_PORT=5432
DB_NAME=imagentx
DB_USER=prod_user
DB_PASSWORD=strong_production_password
JWT_SECRET=strong_random_jwt_secret_key
RABBITMQ_HOST=rabbitmq-host
RABBITMQ_PASSWORD=strong_rabbitmq_password
```

## 🔍 配置验证

### 检查配置加载
```bash
# 查看激活的 Profile
java -jar target/imagent-x-1.0.3.jar --debug 2>&1 | grep "Active profiles"

# 查看配置属性
java -jar target/imagent-x-1.0.3.jar --info
```

### 检查数据库连接
```bash
# 测试数据库连接
psql -h localhost -U imagentx_user -d imagentx -c "SELECT 1;"
```

## 🐛 常见问题

### Q: 配置不生效怎么办？
A: 检查 Profile 是否激活，环境变量是否设置正确。

### Q: 如何切换环境？
A: 修改 `SPRING_PROFILES_ACTIVE` 环境变量或使用 `--spring.profiles.active` 参数。

### Q: 配置文件优先级？
A: 命令行参数 > 环境变量 > Profile 配置 > 主配置。

## 📝 相关文档

- [启动指南](../../docs/guides/启动指南.md)
- [部署指南](../../docs/deployment/)
- [API 文档](../../docs/api-reference/)
