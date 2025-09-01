# MCP网关服务使用指南

## 🎯 概述

MCP（Model Context Protocol）网关是ImagentX项目的核心组件，负责管理和协调各种AI工具服务。本文档介绍如何配置、启动和使用MCP网关服务。

## 📋 目录

- [服务架构](#服务架构)
- [配置说明](#配置说明)
- [启动方法](#启动方法)
- [API接口](#api接口)
- [测试验证](#测试验证)
- [故障排除](#故障排除)

## 🏗️ 服务架构

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   ImagentX      │    │   MCP Gateway   │    │   MCP Tools     │
│   Backend       │◄──►│   Service       │◄──►│   (file_system, │
│   (8088)        │    │   (8081)        │    │    web_search,  │
└─────────────────┘    └─────────────────┘    │   calculator)   │
                                              └─────────────────┘
```

## ⚙️ 配置说明

### 1. 应用配置 (application.yml)

```yaml
# MCP网关配置
mcp:
  gateway:
    base-url: ${MCP_GATEWAY_URL:http://localhost:8081} # MCP网关基础URL
    api-key: ${MCP_GATEWAY_API_KEY:default-api-key-1234567890} # MCP网关API密钥
    connect-timeout: ${MCP_GATEWAY_CONNECT_TIMEOUT:30000} # 连接超时时间(毫秒)
    read-timeout: ${MCP_GATEWAY_READ_TIMEOUT:60000} # 读取超时时间(毫秒)
```

### 2. 环境变量配置 (.env)

```bash
# ===================
# MCP网关配置
# ===================
# MCP网关基础URL
MCP_GATEWAY_URL=http://localhost:8081
# MCP网关API密钥
MCP_GATEWAY_API_KEY=default-api-key-1234567890
# MCP网关连接超时时间(毫秒)
MCP_GATEWAY_CONNECT_TIMEOUT=30000
# MCP网关读取超时时间(毫秒)
MCP_GATEWAY_READ_TIMEOUT=60000
```

## 🚀 启动方法

### 方法1: 使用Docker启动（推荐）

```bash
# 启动MCP网关容器
./start-mcp-gateway.sh
```

### 方法2: 使用模拟服务（开发测试）

```bash
# 启动MCP网关模拟服务
python3 mcp-gateway-simulator.py
```

### 方法3: 使用Docker Compose

```bash
# 进入deploy目录
cd deploy

# 启动所有服务（包括MCP网关）
docker compose --profile local --profile dev up -d
```

## 🔌 API接口

### 1. 健康检查

```bash
# 基础健康检查
GET http://localhost:8081/health

# API健康检查
GET http://localhost:8081/api/health
```

**响应示例：**
```json
{
  "code": 200,
  "message": "ok",
  "data": {
    "status": "healthy",
    "service": "mcp-gateway",
    "uptime": "1h30m"
  },
  "timestamp": 1756096113221
}
```

### 2. 工具列表

```bash
GET http://localhost:8081/mcp/tools
```

**响应示例：**
```json
{
  "code": 200,
  "message": "success",
  "data": [
    {
      "name": "file_system",
      "description": "文件系统操作工具",
      "version": "1.0.0",
      "status": "active"
    },
    {
      "name": "web_search",
      "description": "网络搜索工具",
      "version": "1.0.0",
      "status": "active"
    },
    {
      "name": "calculator",
      "description": "计算器工具",
      "version": "1.0.0",
      "status": "active"
    }
  ],
  "timestamp": 1756096118919
}
```

### 3. 工具部署

```bash
POST http://localhost:8081/deploy
Content-Type: application/json

{
  "toolId": "test-tool",
  "toolName": "测试工具",
  "version": "1.0.0",
  "config": {}
}
```

**响应示例：**
```json
{
  "code": 200,
  "message": "部署成功",
  "data": {
    "deployedTools": ["test-tool"],
    "failedTools": []
  },
  "timestamp": 1756096126238
}
```

## 🧪 测试验证

### 运行集成测试

```bash
# 执行MCP网关集成测试
./test-mcp-integration.sh
```

### 手动测试

```bash
# 1. 测试健康检查
curl http://localhost:8081/health

# 2. 测试API健康检查
curl http://localhost:8081/api/health

# 3. 测试工具列表
curl http://localhost:8081/mcp/tools

# 4. 测试工具部署
curl -X POST http://localhost:8081/deploy \
  -H "Content-Type: application/json" \
  -d '{"toolId": "test-tool", "toolName": "测试工具", "version": "1.0.0"}'
```

## 🔧 故障排除

### 常见问题

#### 1. MCP网关无法启动

**症状：** 无法访问 http://localhost:8081

**解决方案：**
```bash
# 检查端口占用
lsof -i :8081

# 检查Docker服务状态
docker info

# 重启MCP网关服务
./start-mcp-gateway.sh
```

#### 2. 配置加载失败

**症状：** 后端日志显示MCP配置错误

**解决方案：**
```bash
# 检查配置文件
grep -A 5 "mcp:" ImagentX/src/main/resources/application.yml

# 检查环境变量
grep "MCP_GATEWAY" deploy/.env

# 重启后端服务
cd ImagentX
mvn spring-boot:run
```

#### 3. 工具部署失败

**症状：** 工具部署返回错误

**解决方案：**
```bash
# 检查MCP网关日志
docker logs mcp-gateway

# 检查网络连接
curl -v http://localhost:8081/health

# 验证API密钥
echo "default-api-key-1234567890"
```

### 日志查看

```bash
# 查看MCP网关容器日志
docker logs -f mcp-gateway

# 查看后端MCP相关日志
tail -f ImagentX/logs/agent-x.log | grep -i mcp

# 查看模拟服务日志
# 直接在终端中查看Python脚本输出
```

## 📚 相关文件

### 配置文件
- `ImagentX/src/main/resources/application.yml` - 应用配置
- `deploy/.env` - 环境变量配置

### 启动脚本
- `start-mcp-gateway.sh` - Docker启动脚本
- `mcp-gateway-simulator.py` - 模拟服务脚本

### 测试脚本
- `test-mcp-integration.sh` - 集成测试脚本

### 核心代码
- `ImagentX/src/main/java/org/xhy/infrastructure/mcp_gateway/MCPGatewayService.java` - MCP网关服务
- `ImagentX/src/main/java/org/xhy/infrastructure/config/MCPGatewayProperties.java` - MCP配置属性
- `ImagentX/src/main/java/org/xhy/application/conversation/service/McpUrlProviderService.java` - MCP URL提供者

## 🌐 外部资源

- **MCP网关项目**: https://github.com/lucky-aeon/mcp-gateway
- **MCP社区**: https://github.com/lucky-aeon/agent-mcp-community
- **MCP协议文档**: https://modelcontextprotocol.io/

## 📞 支持

如果您在使用MCP网关时遇到问题，请：

1. 查看本文档的故障排除部分
2. 检查相关日志文件
3. 运行集成测试脚本
4. 提交Issue到项目仓库

---

**最后更新**: 2025-08-25
**版本**: 1.0.0
