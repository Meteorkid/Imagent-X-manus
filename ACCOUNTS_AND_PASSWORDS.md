# ImagentX 账号密码汇总

> ⚠️ **安全提醒**: 此文件包含敏感信息，请妥善保管，不要提交到版本控制系统。

## 📋 目录
- [数据库账号](#数据库账号)
- [应用账号](#应用账号)
- [监控系统账号](#监控系统账号)
- [消息队列账号](#消息队列账号)
- [API密钥](#api密钥)
- [SSL证书配置](#ssl证书配置)

---

## 🗄️ 数据库账号

### PostgreSQL 主数据库
- **数据库名**: `imagentx`
- **用户名**: `imagentx_user`
- **密码**: `imagentx_pass`
- **端口**: `5432`
- **主机**: `localhost` (本地) / `postgres` (Docker容器内)

### 生产环境数据库
- **数据库名**: `imagentx`
- **用户名**: `${DB_USER:-postgres}` (默认: `postgres`)
- **密码**: `${DB_PASSWORD:-postgres}` (默认: `postgres`)
- **端口**: `5432`

---

## 🚀 应用账号

### ImagentX 管理员账户
- **邮箱**: `admin@imagentx.top`
- **密码**: `admin123`
- **昵称**: `Imagent X管理员`

### ImagentX 测试账户
- **邮箱**: `test@imagentx.top`
- **密码**: `test123`
- **昵称**: `测试用户`
- **状态**: 可配置启用/禁用

---

## 📊 监控系统账号

### Grafana
- **用户名**: `admin`
- **密码**: `admin123`
- **端口**: `3001` (本地访问)
- **URL**: `http://localhost:3001`

### Prometheus
- **端口**: `9090`
- **URL**: `http://localhost:9090`
- **认证**: 无 (生产环境建议启用)

### Alertmanager
- **端口**: `9093`
- **URL**: `http://localhost:9093`

### Elasticsearch (沙箱环境)
- **用户名**: `elastic`
- **密码**: `elastic123`
- **端口**: `9200`
- **URL**: `http://localhost:9200`

### Kibana (沙箱环境)
- **端口**: `5601`
- **URL**: `http://localhost:5601`
- **认证**: 通过 Elasticsearch 认证

### 监控API服务 (沙箱环境)
- **用户名**: `admin`
- **密码**: `api123`
- **端口**: `5000`
- **URL**: `http://localhost:5000`

---

## 🐰 消息队列账号

### RabbitMQ
- **用户名**: `guest`
- **密码**: `guest`
- **端口**: `5672` (AMQP), `15672` (管理界面)
- **管理界面**: `http://localhost:15672`

### 生产环境 RabbitMQ
- **用户名**: `${RABBITMQ_USERNAME:-guest}` (默认: `guest`)
- **密码**: `${RABBITMQ_PASSWORD:-guest}` (默认: `guest`)

---

## 🔑 API密钥

### JWT 密钥
- **开发环境**: `please_change_this_in_production`
- **生产环境**: `${JWT_SECRET:-your-secret-key-change-this}`

### MCP 网关 API 密钥
- **密钥**: `imagentx-mcp-key-2024`
- **端口**: `8080`

---

## 🔒 SSL证书配置

### 域名配置
- **主域名**: `imagentx.top`
- **SSL邮箱**: `admin@imagentx.top`

---

## 🐳 Docker 服务端口映射

### 主要服务
- **前端**: `3000` → `localhost:3000`
- **后端API**: `8088` → `localhost:8088`
- **数据库**: `5432` → `localhost:5432`
- **消息队列**: `5672` → `localhost:5672`
- **消息队列管理**: `15672` → `localhost:15672`

### 监控服务
- **Prometheus**: `9090` → `localhost:9090`
- **Grafana**: `3001` → `localhost:3001`
- **Alertmanager**: `9093` → `localhost:9093`
- **Elasticsearch**: `9200` → `localhost:9200`
- **Kibana**: `5601` → `localhost:5601`

---

## 🔧 环境变量配置

### 数据库配置
```bash
DB_USER=imagentx_user
DB_PASSWORD=imagentx_pass
DB_NAME=imagentx
DB_HOST=postgres
DB_PORT=5432
```

### RabbitMQ配置
```bash
RABBITMQ_USERNAME=guest
RABBITMQ_PASSWORD=guest
RABBITMQ_HOST=rabbitmq
RABBITMQ_PORT=5672
```

### 应用配置
```bash
SERVER_PORT=8088
FRONTEND_PORT=3000
JWT_SECRET=please_change_this_in_production
IMAGENTX_ADMIN_EMAIL=admin@imagentx.top
IMAGENTX_ADMIN_PASSWORD=admin123
```

---

## 🚨 安全注意事项

1. **生产环境**: 请更改所有默认密码
2. **JWT密钥**: 必须使用强随机字符串
3. **数据库密码**: 使用强密码策略
4. **网络访问**: 限制不必要的端口暴露
5. **定期更新**: 定期更换密码和密钥
6. **访问控制**: 实施最小权限原则

---

## 📝 更新记录

- **2024-09-02**: 初始版本，包含所有服务账号信息
- **环境**: 开发、测试、生产环境配置汇总

---

> 💡 **提示**: 如需修改密码，请同时更新相关的配置文件和环境变量。
