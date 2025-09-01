# ImagentX Docker 服务启动指南

## 概述

本指南介绍如何使用Docker启动ImagentX的基础服务，包括PostgreSQL数据库和RabbitMQ消息队列。

## 前置要求

1. **Docker Desktop** - 确保已安装并运行
2. **Docker Compose** - 通常随Docker Desktop一起安装

## 快速启动

### 1. 启动Docker Desktop

确保Docker Desktop正在运行：
```bash
docker info
```

### 2. 使用启动脚本（推荐）

```bash
# 给脚本执行权限
chmod +x start-docker.sh

# 启动服务
./scripts/docker/start-docker.sh
```

### 3. 手动启动

```bash
# 启动基础服务（PostgreSQL + RabbitMQ）
docker-compose -f deploy/docker/working-docker-compose.yml up -d postgres rabbitmq

# 查看服务状态
docker ps
```

## 服务配置

### 配置文件
- `deploy/docker/working-docker-compose.yml` - 主要配置文件

### 服务端口
- **PostgreSQL**: `localhost:5432`
- **RabbitMQ**: `localhost:5672`
- **RabbitMQ管理界面**: `http://localhost:15672`

### 默认凭据
- **PostgreSQL**:
  - 数据库: `imagentx`
  - 用户名: `imagentx_user`
  - 密码: `imagentx_pass`
- **RabbitMQ**:
  - 用户名: `guest`
  - 密码: `guest`

## 服务管理

### 查看服务状态
```bash
./scripts/docker/check-docker-status.sh
```

### 查看日志
```bash
# 查看所有服务日志
docker-compose -f deploy/docker/working-docker-compose.yml logs

# 查看特定服务日志
docker-compose -f deploy/docker/working-docker-compose.yml logs postgres
docker-compose -f deploy/docker/working-docker-compose.yml logs rabbitmq
```

### 停止服务
```bash
docker-compose -f deploy/docker/working-docker-compose.yml down
```

### 重启服务
```bash
docker-compose -f deploy/docker/working-docker-compose.yml restart
```

## 故障排除

### 1. Docker未运行
```bash
# 启动Docker Desktop
open -a Docker
```

### 2. 端口冲突
如果端口被占用，可以修改`deploy/docker/working-docker-compose.yml`中的端口映射：
```yaml
ports:
  - "5433:5432"  # 改为5433
```

### 3. 镜像拉取失败
如果遇到镜像拉取问题，可以：
- 检查网络连接
- 使用本地已有镜像
- 修改镜像源配置

### 4. 服务启动失败
```bash
# 查看详细错误信息
docker-compose -f deploy/docker/working-docker-compose.yml logs

# 重新创建容器
docker-compose -f deploy/docker/working-docker-compose.yml down
docker-compose -f deploy/docker/working-docker-compose.yml up -d
```

## 验证服务

### 1. 检查容器状态
```bash
docker ps
```

### 2. 测试数据库连接
```bash
docker exec imagentx-postgres pg_isready -U imagentx_user -d imagentx
```

### 3. 测试RabbitMQ连接
```bash
docker exec imagentx-rabbitmq rabbitmq-diagnostics ping
```

### 4. 访问RabbitMQ管理界面
打开浏览器访问：`http://localhost:15672`
- 用户名: `guest`
- 密码: `guest`

## 数据持久化

服务数据存储在Docker卷中：
- `imagentx-master_postgres-data` - PostgreSQL数据
- `imagentx-master_rabbitmq-data` - RabbitMQ数据

## 注意事项

1. **首次启动**：PostgreSQL和RabbitMQ需要一些时间来初始化
2. **数据备份**：定期备份Docker卷数据
3. **资源使用**：确保系统有足够的内存和磁盘空间
4. **网络安全**：生产环境中请修改默认密码

## 下一步

基础服务启动后，您可以：
1. 启动ImagentX应用服务
2. 配置前端应用
3. 进行功能测试

## 支持

如果遇到问题，请：
1. 查看服务日志
2. 检查Docker状态
3. 参考故障排除部分
