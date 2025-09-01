# 🚀 Imagent X 项目启动指南

## 📋 快速开始

### 1. 环境检查
```bash
./环境检查.sh
```

### 2. 快速启动 (推荐新手)
```bash
./快速启动.sh
```
访问: http://localhost:3000

### 3. 完整启动 (包含后端)
```bash
# 需要先安装JDK 17
brew install openjdk@17

# 启动完整服务
./scripts/core/start.sh --local
```

## 🎯 启动方案

### 本地开发模式
- **前端**: http://localhost:3000
- **后端**: http://localhost:8080
- **适用**: 开发调试

### 内网部署模式
- **前端**: http://localhost:3000
- **后端**: http://localhost:8088
- **数据库**: localhost:5432
- **消息队列**: localhost:5672
- **适用**: 生产环境

### 外网部署模式
- **前端**: http://your-server-ip
- **后端**: http://your-server-ip/api
- **适用**: 公网访问

## 🔧 环境要求

### 必需环境
- **Java**: JDK 17+
- **Node.js**: 18+
- **npm**: 8+

### 可选环境
- **Docker**: 20.10+
- **Git**: 2.20+

## 📊 当前状态

✅ **前端服务**: 已启动 (http://localhost:3000)  
❌ **后端服务**: 需要JDK 17  
⚠️ **数据库**: 端口被占用  

## 🛠️ 故障排除

### Java版本问题
```bash
# 安装JDK 17
brew install openjdk@17

# 设置环境变量
export JAVA_HOME=/opt/homebrew/opt/openjdk@17
```

### 端口占用
```bash
# 检查端口占用
lsof -i :3000
lsof -i :8080

# 杀死进程
kill -9 <PID>
```

## 📖 详细文档

- [完整启动指南](启动指南.md)
- [API文档](docs/api/)
- [部署指南](docs/deployment/)

---

**注意**: 首次启动可能需要较长时间下载依赖。
