# Docker 部署配置

本目录包含ImagentX项目的Docker部署配置文件。

## 文件说明

- `working-docker-compose.yml` - 主要的生产环境Docker Compose配置文件
  - 包含PostgreSQL数据库服务
  - 包含RabbitMQ消息队列服务
  - 包含ImagentX应用服务（需要镜像可用）

## 使用方法

### 启动服务
```bash
# 从项目根目录运行
./scripts/docker/start-docker.sh
```

### 手动启动
```bash
# 启动基础服务
docker-compose -f deploy/docker/working-docker-compose.yml up -d postgres rabbitmq

# 启动所有服务（包括应用）
docker-compose -f deploy/docker/working-docker-compose.yml up -d
```

### 查看状态
```bash
./scripts/docker/check-docker-status.sh
```

## 服务配置

### PostgreSQL
- 端口: 5432
- 数据库: imagentx
- 用户名: imagentx_user
- 密码: imagentx_pass

### RabbitMQ
- 端口: 5672
- 管理界面: http://localhost:15672
- 用户名: guest
- 密码: guest

## 数据持久化

数据存储在Docker卷中：
- `imagentx-master_postgres-data` - PostgreSQL数据
- `imagentx-master_rabbitmq-data` - RabbitMQ数据
- `imagentx-master_storage-data` - 应用存储数据

## 注意事项

1. 确保Docker Desktop已启动
2. 首次启动需要一些时间来初始化数据库
3. 如果端口冲突，可以修改配置文件中的端口映射
4. 生产环境中请修改默认密码
