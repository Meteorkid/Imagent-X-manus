# ImagentX 部署指南

## 概述

本指南介绍如何部署ImagentX项目到不同环境。

**可选监控栈**（Grafana / Prometheus / Kibana 等，仓库内 `mcp-config/`）与**最小运行集**的说明见 [MONITORING_OPTIONAL.md](./MONITORING_OPTIONAL.md)。

## 🐳 Docker部署

### 环境要求
- Docker 20.10+
- Docker Compose 2.0+
- 至少4GB内存
- 20GB磁盘空间

### 快速部署
```bash
# 克隆项目
git clone https://github.com/imagentx/imagentx.git
cd imagentx

# 配置环境变量
cp deploy/.env.example deploy/.env
# 编辑deploy/.env文件，配置数据库等信息

# 启动服务
cd deploy
docker-compose up -d

# 检查服务状态
docker-compose ps
```

### 服务说明
- **imagentx-backend**: 后端API服务 (端口: 8088)
- **imagentx-frontend**: 前端Web服务 (端口: 3000)
- **postgres**: PostgreSQL数据库 (端口: 5432)
- **rabbitmq**: RabbitMQ消息队列 (端口: 5672)
- **redis**: Redis缓存 (端口: 6379)

## ☸️ Kubernetes部署

### 环境要求
- Kubernetes 1.20+
- Helm 3.0+
- Ingress Controller

### 部署步骤
```bash
# 添加Helm仓库
helm repo add imagentx https://charts.imagentx.ai
helm repo update

# 安装ImagentX
helm install imagentx imagentx/imagentx \
  --namespace imagentx \
  --create-namespace \
  --values values.yaml
```

### 配置文件
```yaml
# values.yaml
global:
  environment: production
  
backend:
  replicaCount: 3
  resources:
    requests:
      memory: "512Mi"
      cpu: "250m"
    limits:
      memory: "1Gi"
      cpu: "500m"
      
frontend:
  replicaCount: 2
  resources:
    requests:
      memory: "256Mi"
      cpu: "100m"
    limits:
      memory: "512Mi"
      cpu: "200m"
      
database:
  postgresql:
    enabled: true
    postgresqlPassword: "your-password"
    persistence:
      enabled: true
      size: 20Gi
```

## ☁️ 云平台部署

### AWS部署
```bash
# 使用Terraform部署
cd terraform/aws
terraform init
terraform plan
terraform apply
```

### 阿里云部署
```bash
# 使用阿里云CLI
aliyun ecs CreateInstance \
  --InstanceName imagentx-server \
  --ImageId ami-12345678 \
  --InstanceType ecs.g6.large
```

## 🔧 配置管理

### 环境变量
```bash
# 数据库配置
DB_HOST=localhost
DB_PORT=5432
DB_NAME=imagentx
DB_USERNAME=postgres
DB_PASSWORD=your-password

# Redis配置
REDIS_HOST=localhost
REDIS_PORT=6379
REDIS_PASSWORD=your-password

# RabbitMQ配置
RABBITMQ_HOST=localhost
RABBITMQ_PORT=5672
RABBITMQ_USERNAME=guest
RABBITMQ_PASSWORD=guest

# JWT配置
JWT_SECRET=your-jwt-secret
JWT_EXPIRATION=86400000

# 文件存储配置
STORAGE_TYPE=local
STORAGE_PATH=/data/uploads
```

### 配置文件
```yaml
# application.yml
spring:
  profiles:
    active: production
  
  datasource:
    url: jdbc:postgresql://${DB_HOST}:${DB_PORT}/${DB_NAME}
    username: ${DB_USERNAME}
    password: ${DB_PASSWORD}
    
  redis:
    host: ${REDIS_HOST}
    port: ${REDIS_PORT}
    password: ${REDIS_PASSWORD}
    
  rabbitmq:
    host: ${RABBITMQ_HOST}
    port: ${RABBITMQ_PORT}
    username: ${RABBITMQ_USERNAME}
    password: ${RABBITMQ_PASSWORD}

server:
  port: 8088
  
logging:
  level:
    org.xhy: INFO
    org.springframework: WARN
```

## 📊 监控和日志

### 监控配置
```yaml
# prometheus.yml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'imagentx-backend'
    static_configs:
      - targets: ['localhost:8088']
    metrics_path: '/actuator/prometheus'
```

### 日志配置
```yaml
# logback-spring.xml
<configuration>
  <appender name="FILE" class="ch.qos.logback.core.rolling.RollingFileAppender">
    <file>logs/imagentx.log</file>
    <rollingPolicy class="ch.qos.logback.core.rolling.TimeBasedRollingPolicy">
      <fileNamePattern>logs/imagentx.%d{yyyy-MM-dd}.log</fileNamePattern>
      <maxHistory>30</maxHistory>
    </rollingPolicy>
  </appender>
</configuration>
```

## 🔒 安全配置

### SSL/TLS配置
```nginx
# nginx.conf
server {
    listen 443 ssl http2;
    server_name api.imagentx.ai;
    
    ssl_certificate /path/to/cert.pem;
    ssl_certificate_key /path/to/key.pem;
    
    location / {
        proxy_pass http://localhost:8088;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

### 防火墙配置
```bash
# UFW配置
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw enable
```

## 🔄 更新和回滚

### 更新流程
```bash
# 1. 备份数据
pg_dump imagentx > backup.sql

# 2. 更新代码
git pull origin main

# 3. 重新构建
docker-compose build

# 4. 滚动更新
docker-compose up -d --no-deps backend
```

### 回滚流程
```bash
# 1. 回滚到上一个版本
git checkout HEAD~1

# 2. 重新构建
docker-compose build

# 3. 重启服务
docker-compose up -d
```

## 📞 技术支持

- **部署问题**: deployment@imagentx.ai
- **运维支持**: ops@imagentx.ai
- **紧急联系**: emergency@imagentx.ai
