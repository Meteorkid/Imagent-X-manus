# OpenManus 集成指南

本文档介绍如何将 OpenManus 智能体集成到 ImagentX 项目中。

## 概述

OpenManus 是一个强大的通用 AI 智能体框架，支持多种工具和功能。通过集成 OpenManus，ImagentX 用户可以：

- 使用强大的 AI 智能体进行任务处理
- 支持代码生成、数据分析、网页浏览等功能
- 通过 MCP (Model Context Protocol) 扩展工具能力
- 在 Web 界面中与智能体进行交互

## 功能特性

### 核心功能
- **通用任务处理**: 支持各种类型的任务和问题
- **代码生成**: 自动生成和优化代码
- **数据分析**: 专门的数据分析智能体
- **网页浏览**: 自动浏览和提取网页信息
- **文件操作**: 读取、写入和修改文件

### 工具支持
- **Python 执行**: 运行 Python 代码
- **浏览器自动化**: 使用 Playwright 进行网页操作
- **MCP 工具**: 支持 Model Context Protocol
- **搜索功能**: 集成多种搜索引擎
- **文件编辑器**: 文本编辑和替换功能

## 安装配置

### 1. 环境要求

- Python 3.12 或更高版本
- Node.js 16+ (用于前端)
- Java 17+ (用于后端)

### 2. 安装 OpenManus

```bash
# 运行安装脚本
./scripts/setup-openmanus.sh
```

### 3. 配置 API 密钥

编辑 `OpenManus/config/config.toml` 文件：

```toml
[llm]
model = "gpt-4o"
base_url = "https://api.openai.com/v1"
api_key = "your-api-key-here"  # 替换为您的 API 密钥
max_tokens = 4096
temperature = 0.0
```

### 4. 启动服务

```bash
# 启动标准服务
./scripts/start-openmanus.sh start

# 启动 MCP 服务
./scripts/start-openmanus.sh mcp

# 启动多智能体服务
./scripts/start-openmanus.sh flow
```

## 使用指南

### Web 界面使用

1. 启动 ImagentX 项目
2. 访问 `/agents` 页面
3. 在聊天界面中输入任务或问题
4. 智能体会自动处理并返回结果

### 配置选项

在 Web 界面中可以配置以下参数：

- **模型选择**: GPT-4o, GPT-4 Turbo, GPT-3.5 Turbo
- **最大令牌数**: 控制响应长度
- **温度**: 控制响应随机性
- **MCP 工具**: 启用/禁用 MCP 功能
- **数据分析智能体**: 启用专门的数据分析功能

### 示例任务

#### 代码生成
```
请帮我生成一个 Python 函数来计算斐波那契数列
```

#### 数据分析
```
分析这个 CSV 文件并生成可视化图表
```

#### 网页信息提取
```
访问 https://example.com 并提取页面标题和主要内容
```

#### 文件操作
```
读取 config.json 文件并修改其中的配置项
```

## 架构设计

### 前端架构

```
apps/frontend/app/(main)/agents/
├── page.tsx              # 智能体工作台页面
└── components/           # 智能体相关组件
```

### 后端架构

```
apps/backend/src/main/java/org/xhy/
├── interfaces/api/portal/
│   └── AgentController.java    # 智能体 API 控制器
├── interfaces/dto/
│   ├── AgentRequest.java       # 请求 DTO
│   └── AgentResponse.java      # 响应 DTO
└── application/service/
    └── AgentService.java       # 智能体服务
```

### API 接口

#### POST /api/agents/openmanus
执行 OpenManus 智能体任务

**请求体:**
```json
{
  "prompt": "任务描述",
  "config": {
    "model": "gpt-4o",
    "maxTokens": 4096,
    "temperature": 0.0,
    "useMCP": true,
    "useDataAnalysis": false
  }
}
```

**响应:**
```json
{
  "success": true,
  "response": "智能体执行结果",
  "message": "执行成功"
}
```

#### GET /api/agents/status
检查智能体服务状态

**响应:**
```json
{
  "success": true,
  "message": "OpenManus服务正常"
}
```

## 部署指南

### Docker 部署

使用提供的 Docker Compose 配置：

```bash
# 启动包含 OpenManus 的完整服务
docker-compose -f docker-compose-openmanus.yml up -d
```

### 生产环境部署

1. 确保 Python 环境正确配置
2. 配置 API 密钥和网络设置
3. 启动后端服务
4. 启动前端服务
5. 验证智能体功能

## 故障排除

### 常见问题

#### 1. Python 环境问题
```bash
# 检查 Python 版本
python3 --version

# 重新安装依赖
cd OpenManus
pip install -r requirements.txt
```

#### 2. API 密钥配置
确保在 `config/config.toml` 中正确配置了 API 密钥

#### 3. 权限问题
```bash
# 确保脚本有执行权限
chmod +x scripts/setup-openmanus.sh
chmod +x scripts/start-openmanus.sh
```

#### 4. 网络连接
检查防火墙设置和网络连接

### 日志查看

```bash
# 查看后端日志
docker logs imagentx-backend

# 查看 OpenManus 日志
cd OpenManus
python main.py --debug
```

## 扩展开发

### 添加新工具

1. 在 `OpenManus/app/tool/` 目录下创建新工具
2. 在智能体中注册新工具
3. 更新前端界面以支持新功能

### 自定义配置

可以通过修改配置文件来自定义：

- LLM 模型和参数
- MCP 服务器配置
- 工具集合
- 工作空间设置

## 安全考虑

- 确保 API 密钥安全存储
- 限制文件系统访问权限
- 监控智能体执行过程
- 实施适当的访问控制

## 性能优化

- 使用缓存减少重复请求
- 优化 Python 环境配置
- 监控资源使用情况
- 实施请求限流

## 更新维护

### 更新 OpenManus

```bash
cd OpenManus
git pull origin main
pip install -r requirements.txt
```

### 备份配置

```bash
# 备份配置文件
cp OpenManus/config/config.toml OpenManus/config/config.toml.backup
```

## 技术支持

如遇到问题，请：

1. 查看本文档的故障排除部分
2. 检查日志文件
3. 提交 Issue 到项目仓库
4. 联系技术支持团队

## 相关链接

- [OpenManus 官方文档](https://github.com/FoundationAgents/OpenManus)
- [ImagentX 项目文档](./README.md)
- [MCP 协议文档](https://modelcontextprotocol.io/)

