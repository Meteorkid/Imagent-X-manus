# 🐳 Docker 配置说明

## 📁 配置文件列表

| 文件 | 用途 | 域名 | SSL |
|------|------|------|-----|
| `docker-compose.imagent.top.yml` | 主配置 | imagent.top | ✅ |
| `docker-compose.imagentx.top.yml` | 备用配置 | imagentx.top | ✅ |
| `docker-compose.imagent.top.cloudflare.yml` | Cloudflare 配置 | imagent.top | ✅ (Cloudflare) |

## 🚀 使用方式

### 1. 本地开发

```bash
# 使用本地开发配置
docker-compose -f docker-compose-local-dev.yml up -d

# 或使用简化配置
docker-compose -f config/docker/docker-compose.minimal.yml up -d
```

### 2. 生产部署

```bash
# 使用主配置（imagent.top）
docker-compose -f docker-compose.imagent.top.yml up -d

# 使用 Cloudflare 配置
docker-compose -f docker-compose.imagent.top.cloudflare.yml up -d
```

### 3. 停止服务

```bash
docker-compose down
```

## ⚙️ 配置对比

### 服务配置

| 服务 | imagent.top | imagentx.top | Cloudflare |
|------|-------------|--------------|------------|
| Nginx | ✅ | ✅ | ✅ |
| 前端 | ✅ | ✅ | ✅ |
| 后端 | ✅ | ✅ | ✅ |
| 数据库 | ✅ | ✅ | ✅ |
| Redis | ✅ | ✅ | ✅ |
| RabbitMQ | ✅ | ✅ | ✅ |

### 端口映射

| 服务 | 端口 | 说明 |
|------|------|------|
| Nginx | 80, 443 | HTTP/HTTPS |
| 前端 | 3000 | Next.js 应用 |
| 后端 | 8088 | Spring Boot API |
| 数据库 | 5432 | PostgreSQL |
| Redis | 6379 | 缓存 |
| RabbitMQ | 5672, 15672 | 消息队列 |

## 🔧 环境变量配置

### 必需的环境变量

```bash
# 数据库配置
DB_HOST=postgres
DB_PORT=5432
DB_NAME=imagentx
DB_USER=imagentx_user
DB_PASSWORD=your_password

# Redis 配置
REDIS_HOST=redis
REDIS_PORT=6379

# RabbitMQ 配置
RABBITMQ_HOST=rabbitmq
RABBITMQ_PORT=5672
RABBITMQ_USERNAME=guest
RABBITMQ_PASSWORD=guest

# 应用配置
SERVER_PORT=8088
JWT_SECRET=your_jwt_secret_key

# 域名配置
DOMAIN=imagent.top
```

### 可选的环境变量

```bash
# SSL 配置
SSL_EMAIL=admin@imagent.top

# 监控配置
PROMETHEUS_PORT=9090
GRAFANA_PORT=3001

# 日志配置
LOG_LEVEL=INFO
```

## 📊 服务依赖关系

```
Nginx
├── 前端 (Next.js)
└── 后端 (Spring Boot)
    ├── PostgreSQL
    ├── Redis
    └── RabbitMQ
```

## 🎯 推荐配置

### 本地开发

```bash
# .env 文件
DB_HOST=localhost
DB_PORT=5432
DB_NAME=imagentx
DB_USER=imagentx_user
DB_PASSWORD=dev_password
REDIS_HOST=localhost
RABBITMQ_HOST=localhost
SERVER_PORT=8088
JWT_SECRET=dev_jwt_secret_key
```

### 生产环境

```bash
# .env 文件
DB_HOST=postgres
DB_PORT=5432
DB_NAME=imagentx
DB_USER=prod_user
DB_PASSWORD=strong_production_password
REDIS_HOST=redis
RABBITMQ_HOST=rabbitmq
RABBITMQ_PASSWORD=strong_rabbitmq_password
SERVER_PORT=8088
JWT_SECRET=strong_random_jwt_secret_key
DOMAIN=imagent.top
SSL_EMAIL=admin@imagent.top
```

## 🔍 配置验证

### 检查服务状态

```bash
# 查看所有容器状态
docker-compose ps

# 查看服务日志
docker-compose logs -f [service_name]

# 检查健康状态
docker-compose exec backend curl http://localhost:8088/api/health
```

### 检查网络连接

```bash
# 检查容器网络
docker network ls

# 检查容器连接
docker-compose exec backend ping postgres
```

## 🐛 常见问题

### Q: 服务启动失败怎么办？
A: 检查日志 `docker-compose logs [service_name]`，确认环境变量配置正确。

### Q: 如何切换域名？
A: 修改 `DOMAIN` 环境变量，更新 Nginx 配置文件。

### Q: 如何启用 SSL？
A: 配置 `SSL_EMAIL` 环境变量，确保域名已解析到服务器。

### Q: 如何查看实时日志？
A: 使用 `docker-compose logs -f [service_name]` 或 `docker-compose logs -f` 查看所有服务。

## 📝 相关文档

- [部署指南](docs/deployment/)
- [启动指南](docs/guides/启动指南.md)
- [Docker 设置](docs/deployment/docker/DOCKER_SETUP.md)
