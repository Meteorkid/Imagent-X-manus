# ImagentX 脚本使用指南

本项目已整合和优化了所有启动、停止和状态检查脚本，提供统一的管理界面。

## 📁 脚本文件

### 核心脚本
- `start.sh` - 统一启动脚本（替代了多个重复的启动脚本）
- `stop.sh` - 统一停止脚本（替代了原来的停止脚本）
- `status.sh` - 状态检查脚本（新增功能）

### 已删除的重复脚本
以下脚本已被整合到 `start.sh` 中，不再需要：
- `start-all-services.sh`
- `start-core-services.sh`
- `start-mac.sh`
- `start-local.sh`
- `start_services.sh`
- `start_simple.sh`
- `start_manual.sh`
- `quick-start.sh`
- `stop-all-services.sh`

## 🚀 启动脚本 (start.sh)

### 基本用法
```bash
./start.sh [选项]
```

### 启动模式

#### 1. 快速启动 (--quick)
仅启动前端服务，跳过Docker依赖
```bash
./start.sh --quick
```
- ✅ 适合快速测试前端功能
- ⚠️ 后端服务需要手动启动

#### 2. 本地开发 (--local)
启动后端和前端服务，跳过Docker
```bash
./start.sh --local
```
- ✅ 适合本地开发环境
- ⚠️ 需要手动配置数据库

#### 3. 核心服务 (--core)
启动完整的核心服务（后端+前端+数据库）
```bash
./start.sh --core
```
- ✅ 推荐用于开发环境
- 🐳 自动启动Docker数据库服务

#### 4. 完整服务 (--full)
启动所有服务，包括监控和MCP网关
```bash
./start.sh --full
```
- ✅ 完整的生产环境模拟
- 📊 包含监控和网关服务

#### 5. 仅Docker服务 (--docker)
仅启动数据库和消息队列服务
```bash
./start.sh --docker
```
- 🐳 仅启动PostgreSQL和RabbitMQ
- 🔧 适合手动管理应用服务

#### 6. macOS优化 (--mac)
macOS专用的优化启动模式
```bash
./start.sh --mac
```
- 🍎 针对macOS优化的配置
- 🐳 使用Docker Compose

### 其他选项
```bash
./start.sh --status    # 检查服务状态
./start.sh --clean     # 清理环境
./start.sh --help      # 显示帮助信息
```

## 🛑 停止脚本 (stop.sh)

### 基本用法
```bash
./stop.sh [选项]
```

### 停止选项

#### 1. 停止所有服务（默认）
```bash
./stop.sh
# 或
./stop.sh --all
```

#### 2. 选择性停止
```bash
./stop.sh --backend    # 仅停止后端服务
./stop.sh --frontend   # 仅停止前端服务
./stop.sh --docker     # 仅停止Docker服务
```

#### 3. 强制停止
```bash
./stop.sh --force      # 强制停止所有进程
./stop.sh --clean      # 清理所有文件和日志
```

## 📊 状态检查脚本 (status.sh)

### 基本用法
```bash
./status.sh [选项]
```

### 检查选项

#### 1. 完整状态检查（默认）
```bash
./status.sh
```

#### 2. 选择性检查
```bash
./status.sh --process  # 检查进程状态
./status.sh --ports    # 检查端口占用
./stop.sh --docker     # 检查Docker状态
./stop.sh --health     # 检查服务健康
./stop.sh --system     # 检查系统资源
./stop.sh --logs       # 检查日志文件
```

## 🔄 常用操作流程

### 1. 首次启动
```bash
# 检查系统环境
./start.sh --help

# 启动核心服务
./start.sh --core

# 检查状态
./status.sh
```

### 2. 开发环境
```bash
# 启动本地开发环境
./start.sh --local

# 检查服务状态
./status.sh --health

# 停止服务
./stop.sh
```

### 3. 生产环境
```bash
# 启动完整服务
./start.sh --full

# 监控状态
./status.sh

# 停止服务
./stop.sh --clean
```

### 4. 故障排查
```bash
# 检查所有状态
./status.sh

# 强制停止所有服务
./stop.sh --force

# 清理环境
./stop.sh --clean

# 重新启动
./start.sh --core
```

## 🎯 服务端口

| 服务 | 端口 | 说明 |
|------|------|------|
| 前端服务 | 3000 | React开发服务器 |
| 后端API | 8080 | Spring Boot应用 |
| MCP网关 | 8081 | 模型控制协议网关 |
| 监控服务 | 9090 | Prometheus监控 |
| PostgreSQL | 5432 | 数据库服务 |
| RabbitMQ | 5672 | 消息队列 |
| RabbitMQ管理 | 15672 | 管理界面 |

## 🔧 环境要求

### 必需环境
- Java 17+
- Node.js 18+
- npm

### 可选环境
- Docker Desktop (用于数据库服务)
- Maven (如果使用Maven Wrapper则不需要)

### 系统支持
- ✅ macOS (推荐)
- ✅ Linux
- ⚠️ Windows (需要WSL)

## 🚨 故障排除

### 常见问题

#### 1. 端口被占用
```bash
# 检查端口占用
./status.sh --ports

# 停止占用端口的进程
./stop.sh --force
```

#### 2. Docker服务未启动
```bash
# 检查Docker状态
./status.sh --docker

# 启动Docker Desktop
# 然后重新运行启动脚本
```

#### 3. 依赖安装失败
```bash
# 清理环境
./stop.sh --clean

# 重新安装依赖
cd imagentx-frontend-plus && npm install
cd ../ImagentX && ./mvnw clean install
```

#### 4. 服务启动超时
```bash
# 检查服务状态
./status.sh --health

# 查看日志
tail -f logs/backend.log
tail -f logs/frontend.log
```

## 📝 日志文件

日志文件位于 `logs/` 目录：
- `backend.log` - 后端服务日志
- `frontend.log` - 前端服务日志
- `mcp-gateway.log` - MCP网关日志

## 🔄 脚本更新

如果脚本需要更新，请：
1. 备份当前配置
2. 下载最新版本
3. 重新运行启动脚本

## 📞 支持

如果遇到问题，请：
1. 查看本文档的故障排除部分
2. 运行 `./status.sh` 检查系统状态
3. 查看相关日志文件
4. 提交Issue到项目仓库
