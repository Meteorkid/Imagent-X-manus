# Imagent X 快速启动指南

本文档提供了启动 Imagent X 项目的详细指南，包括不同的启动选项、必要的环境配置以及常见问题的解决方法。

## 项目简介
Imagent X是一个AI代理平台，集成了多种AI功能和服务。由于在启动过程中可能会遇到Docker镜像拉取和依赖版本问题，我们提供了多种启动选项以适应不同的开发环境。

## 系统要求

### 基础服务要求
- **Docker**: 用于运行PostgreSQL数据库和RabbitMQ消息队列

### 完整启动要求
- **Docker**: 用于运行基础服务
- **Java**: 17或更高版本（推荐Eclipse Temurin JDK 17）
- **Node.js**: 16或更高版本
- **npm**: 随Node.js一起安装

## 快速启动选项

### 选项 1: 仅启动基础服务

如果你只需要启动 PostgreSQL 和 RabbitMQ 基础服务，可以使用以下命令：

```bash
./start_services.sh
```

或者通过简化版脚本的选项：

```bash
./start_simple.sh --services
```

这将启动：
- PostgreSQL 数据库 (端口 5432)
- RabbitMQ 消息队列 (端口 5672) 和管理界面 (端口 15672)

### 选项 2: 完整启动（需要本地环境）

如果你想完整启动整个项目（包括前后端服务），需要先确保本地已安装以下依赖：

- Java 17 或更高版本
- Node.js (建议 16.x 或更高版本)
- npm (建议 8.x 或更高版本)

然后使用以下命令启动：

```bash
./start_simple.sh --full
```

这将启动：
- PostgreSQL 和 RabbitMQ 基础服务
- 后端 Spring Boot 应用
- 前端 React 应用

### 查看帮助信息

要查看所有可用的命令行选项，可以使用：

```bash
./start_simple.sh --help
```

## 依赖安装指南

### 1. 安装Docker

**Mac用户：**
1. 访问 [Docker Desktop for Mac 下载页面](https://docs.docker.com/desktop/install/mac-install/)
2. 下载并安装Docker Desktop
3. 启动Docker Desktop应用程序

**验证安装：**

```bash
docker --version
# 应该显示Docker版本信息

docker info
# 应该显示Docker运行状态信息
```

### 2. 安装Java 17（完整启动需要）

我们推荐使用Eclipse Temurin JDK 17，这是项目开发时使用的版本。

**下载安装：**
1. 访问 [Eclipse Temurin JDK 17 下载页面](https://adoptium.net/temurin/releases/?version=17)
2. 选择适合您操作系统的安装包下载并安装
3. 配置JAVA_HOME环境变量（具体方法请参考操作系统文档）

**验证安装：**

```bash
java -version
# 应该显示Java版本号为17或更高
```

### 3. 安装Node.js和npm（完整启动需要）

**下载安装：**
1. 访问 [Node.js 下载页面](https://nodejs.org/en/download/)
2. 下载并安装Node.js 16或更高版本
3. npm会随Node.js一起安装

**验证安装：**

```bash
node --version
# 应该显示Node.js版本号

npm --version
# 应该显示npm版本号
```

## Docker 镜像加速器配置

如果在拉取 Docker 镜像时遇到超时或速度慢的问题，强烈建议配置 Docker 镜像加速器。以下是详细的配置方法：

### Mac 系统配置步骤

1. 打开 Docker Desktop 应用
2. 点击顶部菜单栏的 Docker 图标，选择 "Preferences" 或 "Settings"
3. 在左侧导航栏中选择 "Docker Engine"
4. 在右侧配置框中添加以下内容：

```json
{
  "registry-mirrors": [
    "https://docker.mirrors.ustc.edu.cn",
    "https://mirror.ccs.tencentyun.com",
    "https://hub-mirror.c.163.com"
  ]
}
```

5. 点击 "Apply & Restart" 按钮，等待 Docker 重启生效

### 验证配置是否成功

配置完成后，可以通过以下命令验证是否生效：

```bash
docker info | grep -A 5 'Registry Mirrors'
```

如果看到你配置的镜像源列表，则表示配置成功。

## 常见问题解决方法

### Docker 相关问题

1. **Docker 未安装或未启动**
   - 确保已安装 Docker 并启动 Docker 服务
   - Mac 用户可从 [https://docs.docker.com/desktop/install/mac-install/](https://docs.docker.com/desktop/install/mac-install/) 下载安装

2. **Docker Compose 命令不兼容**
   - 脚本支持 `docker-compose` 和 `docker compose` 两种命令格式，会自动检测并使用可用的命令

3. **镜像拉取超时**
   - 配置 Docker 镜像加速器（详见上方说明）
   - 脚本已添加镜像拉取重试机制，最多尝试 3 次

4. **容器启动失败**
   - 检查 Docker 日志获取详细错误信息：
     ```bash
docker logs <container_name>
     ```
   - 常见的容器名称：imagentx-postgres, imagentx-rabbitmq

### Java 相关问题

1. **Java 版本过低**
   - 确保安装了 Java 17 或更高版本
   - 可以使用以下命令检查 Java 版本：
     ```bash
     java -version
     ```
   - 如版本过低，可从 [https://adoptium.net/](https://adoptium.net/) 下载安装 OpenJDK 17

2. **Java版本不匹配**

如果系统中安装了多个Java版本，可以使用以下方法切换到Java 17：

**Mac用户（使用Homebrew安装的Java）：**

```bash
# 查看已安装的Java版本
/usr/libexec/java_home -V

# 设置Java 17为默认
export JAVA_HOME=$(/usr/libexec/java_home -v 17)
# 可以将此命令添加到~/.zshrc或~/.bashrc文件中以持久生效
```

### 端口冲突

如果启动时遇到端口冲突（如5432、5672、8088、3000等端口已被占用），可以：

1. 关闭占用这些端口的其他应用程序
2. 或修改脚本中的端口映射配置

### 数据库相关问题

1. **数据库连接失败**
   - 确保 PostgreSQL 服务已成功启动
   - 检查数据库连接参数（主机、端口、用户名、密码）是否正确
   - 脚本默认配置：主机 localhost，端口 5432，数据库名 imagentx，用户名 postgres，密码 postgres

## 服务访问信息

成功启动后，可以通过以下地址访问相关服务：

### 基础服务

- PostgreSQL: localhost:5432
  - 数据库名: imagentx
  - 用户名: postgres
  - 密码: postgres
- RabbitMQ: localhost:5672
- RabbitMQ 管理界面: http://localhost:15672 (账号密码: guest/guest)

### 应用服务

- 后端 API: http://localhost:8088/api
- 前端界面: http://localhost:3000
- **默认账号**: 
  - 管理员: admin@imagentx.ai / admin123
  - 测试用户: test@imagentx.ai / test123

## 停止服务

要停止所有服务，请按 Ctrl+C 终止脚本运行，脚本会自动清理并停止所有启动的服务。

如果需要手动清理，可以运行：

```bash
# 停止基础服务
if [ -f "docker-compose.simple.yml" ]; then
  docker compose -f docker-compose.simple.yml down
fi
```

---

希望这个指南能帮助您顺利启动Imagent X项目！如果您遇到任何其他问题，请参考项目文档或寻求技术支持。