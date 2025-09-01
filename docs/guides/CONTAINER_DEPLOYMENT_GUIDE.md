# ImagentX 容器部署指南

## 🎯 概述

本指南详细说明如何部署和运行优化后的ImagentX容器系统，包括生产环境配置、监控设置和故障排除。

## 🚀 快速部署

### 1. 环境准备

#### 系统要求
- **操作系统**: Linux (Ubuntu 20.04+, CentOS 8+)
- **Docker**: 20.10+
- **Docker Compose**: 2.0+
- **内存**: 最少8GB，推荐16GB+
- **存储**: 最少50GB可用空间
- **网络**: 稳定的互联网连接

#### 目录结构准备
```bash
# 创建应用目录
sudo mkdir -p /opt/imagentx
sudo chown $USER:$USER /opt/imagentx

# 创建子目录
mkdir -p /opt/imagentx/{postgres,redis,nginx,traefik}/{data,logs}
mkdir -p /opt/imagentx/nginx/cache

# 设置权限
sudo chown -R 999:999 /opt/imagentx/postgres
sudo chown -R 999:999 /opt/imagentx/redis
sudo chown -R 100:101 /opt/imagentx/nginx
sudo chown -R 1000:1000 /opt/imagentx/traefik
```

### 2. 环境变量配置

#### 创建环境变量文件
```bash
# 创建.env文件
cat > .env << EOF
# 数据库配置
DB_USER=imagentx_admin
DB_PASSWORD=your_secure_password_here
POSTGRES_DB=imagentx

# SSL证书配置
ACME_EMAIL=admin@imagentx.top

# 域名配置
FRONTEND_DOMAIN=imagentx.top
API_DOMAIN=api.imagentx.top

# 应用配置
NODE_ENV=production
SPRING_PROFILES_ACTIVE=production

# 监控配置
PROMETHEUS_RETENTION_TIME=15d
GRAFANA_ADMIN_PASSWORD=admin123
EOF
```

### 3. 部署命令

#### 使用优化配置部署
```bash
# 进入项目目录
cd /path/to/Imagent-X

# 使用生产优化配置部署
docker-compose -f config/docker/docker-compose-production-optimized.yml --env-file .env up -d

# 查看部署状态
docker-compose -f config/docker/docker-compose-production-optimized.yml ps

# 查看日志
docker-compose -f config/docker/docker-compose-production-optimized.yml logs -f
```

## 🔧 服务配置详解

### 1. 前端服务 (Frontend)

#### 配置说明
```yaml
frontend:
  build:
    context: ../../apps/frontend
    dockerfile: Dockerfile
    args:
      NODE_ENV: production
  deploy:
    resources:
      limits:
        memory: 512M
        cpus: '0.5'
      reservations:
        memory: 256M
        cpus: '0.25'
```

#### 优化特性
- **多阶段构建**: 减少镜像大小30-50%
- **资源限制**: 防止内存泄漏和CPU过载
- **健康检查**: 自动检测服务状态
- **生产环境**: 禁用源码映射，优化性能

### 2. 后端服务 (Backend)

#### 配置说明
```yaml
backend:
  build:
    context: ../../apps/backend
    dockerfile: Dockerfile
    args:
      JAVA_VERSION: 17
      MAVEN_VERSION: 3.9.5
  environment:
    - JAVA_OPTS=-Xms1g -Xmx2g -XX:+UseG1GC -XX:MaxGCPauseMillis=200
    - SPRING_PROFILES_ACTIVE=production
```

#### 优化特性
- **JVM优化**: G1垃圾收集器，优化内存使用
- **连接池**: HikariCP优化配置
- **健康检查**: Spring Boot Actuator集成
- **资源管理**: 智能内存分配

### 3. 数据库服务 (PostgreSQL)

#### 配置说明
```yaml
postgres:
  image: postgres:15-alpine
  command: >
    postgres
    -c shared_buffers=512MB
    -c effective_cache_size=1.5GB
    -c maintenance_work_mem=128MB
    -c max_connections=200
```

#### 优化特性
- **内存优化**: 根据系统内存智能分配
- **连接池**: 支持200个并发连接
- **性能监控**: pg_stat_statements扩展
- **日志管理**: 详细的性能日志记录

### 4. 缓存服务 (Redis)

#### 配置说明
```yaml
redis:
  image: redis:7-alpine
  command: >
    redis-server
    --maxmemory 512mb
    --maxmemory-policy allkeys-lru
    --save 900 1
    --save 300 10
    --save 60 10000
```

#### 优化特性
- **内存策略**: LRU淘汰策略
- **持久化**: 多级RDB快照
- **网络优化**: TCP keepalive和backlog
- **客户端管理**: 支持10000个并发连接

### 5. 负载均衡 (Traefik)

#### 配置说明
```yaml
traefik:
  image: traefik:v2.10
  command:
    - "--providers.docker=true"
    - "--entrypoints.web.address=:80"
    - "--entrypoints.websecure.address=:443"
    - "--certificatesresolvers.letsencrypt.acme.email=${ACME_EMAIL}"
```

#### 优化特性
- **自动发现**: Docker服务自动发现
- **SSL管理**: Let's Encrypt自动证书
- **路由规则**: 基于域名的智能路由
- **负载均衡**: 内置负载均衡器

## 📊 监控和告警

### 1. 容器监控

#### 资源监控
```bash
# 实时监控容器资源
docker stats

# 查看容器日志
docker logs -f container_name

# 检查容器健康状态
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Health}}"
```

#### 性能指标
- **CPU使用率**: 目标 < 80%
- **内存使用率**: 目标 < 80%
- **磁盘I/O**: 监控读写性能
- **网络I/O**: 监控网络流量

### 2. 应用监控

#### 健康检查端点
- **前端**: http://localhost:3000/health
- **后端**: http://localhost:8080/actuator/health
- **数据库**: pg_isready检查
- **Redis**: ping命令检查

#### 监控工具
- **Prometheus**: 指标收集
- **Grafana**: 可视化仪表板
- **Traefik**: 访问日志和指标

### 3. 告警配置

#### 资源告警
```yaml
# Prometheus告警规则
groups:
  - name: container_alerts
    rules:
      - alert: HighCPUUsage
        expr: container_cpu_usage_seconds_total > 0.8
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High CPU usage detected"
```

## 🛠️ 维护和故障排除

### 1. 日常维护

#### 容器清理
```bash
# 清理未使用的资源
docker system prune -f

# 清理特定资源
docker image prune -f
docker container prune -f
docker volume prune -f
docker network prune -f
```

#### 日志管理
```bash
# 轮转日志文件
sudo logrotate /etc/logrotate.d/imagentx

# 清理旧日志
find /opt/imagentx/*/logs -name "*.log.*" -mtime +30 -delete
```

### 2. 故障排除

#### 常见问题

**容器启动失败**
```bash
# 查看容器日志
docker logs container_name

# 检查资源限制
docker stats container_name

# 验证配置文件
docker-compose config
```

**服务无法访问**
```bash
# 检查端口映射
docker port container_name

# 验证网络连接
docker network inspect bridge

# 测试服务健康状态
curl -f http://localhost:port/health
```

**性能问题**
```bash
# 分析资源使用
docker stats --no-stream

# 检查系统资源
htop
df -h
free -h

# 分析慢查询
docker exec postgres_container psql -U user -d db -c "SELECT * FROM pg_stat_statements ORDER BY mean_time DESC LIMIT 10;"
```

### 3. 备份和恢复

#### 数据备份
```bash
# 数据库备份
docker exec postgres_container pg_dump -U user -d db > backup.sql

# Redis备份
docker exec redis_container redis-cli BGSAVE

# 配置文件备份
tar -czf config_backup_$(date +%Y%m%d).tar.gz config/
```

#### 数据恢复
```bash
# 数据库恢复
docker exec -i postgres_container psql -U user -d db < backup.sql

# 配置文件恢复
tar -xzf config_backup_20250901.tar.gz
```

## 🔮 扩展和优化

### 1. 水平扩展

#### 服务扩展
```bash
# 扩展后端服务
docker-compose -f config/docker/docker-compose-production-optimized.yml up -d --scale backend=3

# 扩展前端服务
docker-compose -f config/docker/docker-compose-production-optimized.yml up -d --scale frontend=2
```

#### 负载均衡配置
```yaml
# Traefik负载均衡配置
labels:
  - "traefik.http.services.backend.loadbalancer.server.port=8080"
  - "traefik.http.services.backend.loadbalancer.sticky.cookie=true"
```

### 2. 性能调优

#### 资源调整
```bash
# 动态调整资源限制
docker update --memory 2g --cpus 1.0 container_name

# 重启策略优化
docker update --restart=unless-stopped container_name
```

#### 网络优化
```bash
# 网络性能调优
docker network create --driver bridge --opt com.docker.network.bridge.name=imagentx-br0 imagentx-network

# 端口映射优化
docker run -p 8080:8080 --network imagentx-network container_name
```

## 📋 部署检查清单

### 预部署检查
- [ ] 系统资源满足要求
- [ ] Docker和Docker Compose已安装
- [ ] 目录权限设置正确
- [ ] 环境变量配置完整
- [ ] 网络端口可用

### 部署后验证
- [ ] 所有容器正常运行
- [ ] 健康检查通过
- [ ] 服务可以正常访问
- [ ] 监控系统工作正常
- [ ] 日志记录正常

### 性能验证
- [ ] 响应时间满足要求
- [ ] 资源使用率正常
- [ ] 并发处理能力满足需求
- [ ] 错误率在可接受范围

---

**重要提醒**: 生产环境部署前请务必进行充分测试，确保所有配置正确，并建立完善的监控和备份机制。
