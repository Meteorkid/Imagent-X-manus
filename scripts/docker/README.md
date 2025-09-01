# Docker 管理脚本

本目录包含ImagentX项目的Docker服务管理脚本。

## 脚本说明

### `start-docker.sh`
Docker服务启动脚本
- 检查Docker环境
- 启动PostgreSQL和RabbitMQ服务
- 验证服务状态
- 提供使用提示

**使用方法：**
```bash
# 从项目根目录运行
./scripts/docker/start-docker.sh
```

### `check-docker-status.sh`
Docker服务状态检查脚本
- 检查Docker运行状态
- 显示容器状态
- 检查网络和数据卷
- 测试服务连接
- 显示端口占用情况

**使用方法：**
```bash
# 从项目根目录运行
./scripts/docker/check-docker-status.sh
```

## 功能特性

- ✅ 自动环境检查
- ✅ 服务健康状态监控
- ✅ 连接测试
- ✅ 彩色输出
- ✅ 错误处理
- ✅ 详细状态报告

## 依赖关系

- Docker Desktop
- Docker Compose
- `deploy/docker/working-docker-compose.yml` 配置文件

## 注意事项

1. 脚本需要在项目根目录下运行
2. 确保Docker Desktop已启动
3. 脚本会自动处理路径引用
4. 提供详细的错误信息和解决建议
