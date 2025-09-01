#!/bin/bash

# ImagentX 文档完善设置脚本
# 用于创建用户手册、API文档、开发指南等

set -e

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # 无颜色

echo -e "${BLUE}📚 设置ImagentX文档完善功能...${NC}"

# 创建文档目录结构
create_documentation_structure() {
    echo -e "${BLUE}📁 创建文档目录结构...${NC}"
    
    mkdir -p docs/{user-guide,api-reference,developer-guide,deployment}
    mkdir -p docs/user-guide/{getting-started,features,troubleshooting}
    mkdir -p docs/api-reference/{endpoints,models,examples}
    mkdir -p docs/developer-guide/{setup,architecture,contributing}
    mkdir -p docs/deployment/{docker,kubernetes,cloud}
    
    echo -e "${GREEN}✅ 文档目录结构创建完成${NC}"
}

# 创建用户手册
create_user_guide() {
    echo -e "${BLUE}👥 创建用户手册...${NC}"
    
    # 创建用户手册主页
    cat > docs/user-guide/README.md << 'EOF'
# ImagentX 用户手册

## 📖 概述

欢迎使用ImagentX！这是一个基于LLM和MCP的智能Agent构建平台，让您能够轻松创建、管理和使用AI助手。

## 🚀 快速开始

### 1. 注册账号
1. 访问 [ImagentX官网](https://imagentx.ai)
2. 点击"注册"按钮
3. 填写邮箱和密码
4. 验证邮箱完成注册

### 2. 创建第一个Agent
1. 登录后进入控制台
2. 点击"创建Agent"
3. 填写Agent基本信息
4. 配置系统提示词
5. 选择AI模型
6. 发布Agent

### 3. 开始对话
1. 在Agent列表中找到您的Agent
2. 点击"开始对话"
3. 输入您的问题
4. 享受AI助手的智能回答

## 🎯 核心功能

### Agent管理
- **创建Agent**: 自定义AI助手
- **配置模型**: 选择不同的AI模型
- **系统提示词**: 定义Agent的行为和知识
- **工具集成**: 为Agent添加各种工具

### 会话管理
- **多轮对话**: 支持上下文连续对话
- **历史记录**: 查看和管理对话历史
- **导出功能**: 导出对话记录

### 工具市场
- **内置工具**: 搜索、计算、翻译等
- **自定义工具**: 创建自己的工具
- **工具组合**: 组合多个工具

### RAG知识库
- **文档上传**: 支持多种文档格式
- **知识检索**: 基于文档的智能回答
- **知识管理**: 管理和更新知识库

## 💰 计费说明

### 免费版
- 每月1000次对话
- 基础AI模型
- 标准支持

### 专业版
- 每月10000次对话
- 高级AI模型
- 优先支持
- 自定义工具

### 企业版
- 无限对话次数
- 专属AI模型
- 24/7技术支持
- 私有化部署

## 🔧 常见问题

### Q: 如何选择合适的AI模型？
A: 根据您的需求选择：
- GPT-3.5: 适合一般对话和问答
- GPT-4: 适合复杂推理和创作
- Claude: 适合长文本处理
- 自定义模型: 适合特定领域

### Q: 如何提高Agent的回答质量？
A: 建议：
1. 编写清晰的系统提示词
2. 提供具体的示例
3. 选择合适的工具
4. 定期更新知识库

### Q: 如何保护隐私和数据安全？
A: 我们采用：
1. 端到端加密
2. 数据匿名化
3. 严格的访问控制
4. 定期安全审计

## 📞 技术支持

- **在线客服**: 7x24小时在线
- **邮箱支持**: support@imagentx.ai
- **文档中心**: https://docs.imagentx.ai
- **社区论坛**: https://community.imagentx.ai

## 🔄 更新日志

### v2.1.0 (2024-08-25)
- 新增RAG知识库功能
- 优化对话体验
- 修复已知问题

### v2.0.0 (2024-08-20)
- 全新界面设计
- 支持多模型选择
- 增强工具市场

### v1.5.0 (2024-08-15)
- 新增自定义工具
- 优化性能
- 改进用户体验
EOF

    # 创建功能指南
    cat > docs/user-guide/features/agent-management.md << 'EOF'
# Agent管理功能指南

## 创建Agent

### 步骤1: 基本信息
- **名称**: 为您的Agent起一个有意义的名字
- **描述**: 简要描述Agent的功能和用途
- **标签**: 添加相关标签便于分类

### 步骤2: 系统提示词
系统提示词决定了Agent的行为和知识范围：

```markdown
你是一个专业的客服助手，专门帮助用户解决产品相关问题。
你的回答应该：
1. 友好、专业、准确
2. 基于产品文档和FAQ
3. 如果不确定，建议联系人工客服
4. 使用简洁明了的语言
```

### 步骤3: 选择模型
- **GPT-3.5-turbo**: 适合一般对话
- **GPT-4**: 适合复杂推理
- **Claude-3**: 适合长文本处理

### 步骤4: 配置工具
选择Agent可以使用的工具：
- **搜索工具**: 实时信息查询
- **计算工具**: 数学计算
- **翻译工具**: 多语言翻译
- **天气工具**: 天气信息
- **自定义工具**: 您自己创建的工具

## 管理Agent

### 编辑Agent
- 修改基本信息
- 更新系统提示词
- 调整工具配置
- 更换AI模型

### 版本管理
- 创建新版本
- 回滚到旧版本
- 比较版本差异
- 发布版本

### 权限控制
- 公开/私有设置
- 访问权限管理
- API密钥管理
- 使用统计

## 最佳实践

### 提示词编写
1. **明确角色**: 定义Agent的身份和职责
2. **设定边界**: 明确什么能做，什么不能做
3. **提供示例**: 给出期望的回答格式
4. **持续优化**: 根据使用情况调整

### 工具选择
1. **按需选择**: 只选择必要的工具
2. **测试验证**: 确保工具正常工作
3. **性能考虑**: 避免过多工具影响响应速度

### 模型选择
1. **成本考虑**: 不同模型价格不同
2. **性能需求**: 根据复杂度选择
3. **响应速度**: 考虑实时性要求
EOF

    echo -e "${GREEN}✅ 用户手册创建完成${NC}"
}

# 创建API文档
create_api_documentation() {
    echo -e "${BLUE}🔗 创建API文档...${NC}"
    
    # 创建API文档主页
    cat > docs/api-reference/README.md << 'EOF'
# ImagentX API 参考文档

## 概述

ImagentX API 提供了完整的RESTful接口，支持Agent管理、会话聊天、工具集成等功能。

## 🔐 认证

### Bearer Token认证
所有API请求都需要在请求头中包含有效的Bearer Token：

```http
Authorization: Bearer your-api-token
```

### 获取Token
通过登录接口获取访问令牌：

```http
POST /api/login
Content-Type: application/json

{
  "account": "your-email@example.com",
  "password": "your-password"
}
```

## 🌐 基础URL

- **开发环境**: `http://localhost:8088/api`
- **测试环境**: `https://test-api.imagentx.ai/api`
- **生产环境**: `https://api.imagentx.ai/api`

## 📊 响应格式

所有API响应都遵循统一的格式：

```json
{
  "code": 200,
  "message": "操作成功",
  "data": {
    // 响应数据
  },
  "timestamp": 1640995200000
}
```

### 状态码说明

| 状态码 | 说明 |
|--------|------|
| 200 | 成功 |
| 400 | 请求参数错误 |
| 401 | 未授权 |
| 403 | 禁止访问 |
| 404 | 资源不存在 |
| 429 | 请求过于频繁 |
| 500 | 服务器内部错误 |

## 📝 通用参数

### 分页参数
```json
{
  "page": 0,
  "size": 20,
  "sort": "createdAt,desc"
}
```

### 时间格式
所有时间字段使用ISO 8601格式：`YYYY-MM-DDTHH:mm:ss.sssZ`

## 🔗 接口列表

### 认证相关
- [用户登录](./endpoints/auth.md#用户登录)
- [用户注册](./endpoints/auth.md#用户注册)
- [刷新令牌](./endpoints/auth.md#刷新令牌)

### Agent管理
- [创建Agent](./endpoints/agents.md#创建agent)
- [获取Agent列表](./endpoints/agents.md#获取agent列表)
- [获取Agent详情](./endpoints/agents.md#获取agent详情)
- [更新Agent](./endpoints/agents.md#更新agent)
- [删除Agent](./endpoints/agents.md#删除agent)

### 会话管理
- [创建会话](./endpoints/sessions.md#创建会话)
- [发送消息](./endpoints/sessions.md#发送消息)
- [获取会话历史](./endpoints/sessions.md#获取会话历史)

### 工具管理
- [获取工具列表](./endpoints/tools.md#获取工具列表)
- [创建自定义工具](./endpoints/tools.md#创建自定义工具)

### 用户管理
- [获取用户信息](./endpoints/users.md#获取用户信息)
- [更新用户信息](./endpoints/users.md#更新用户信息)

## 🚀 快速开始

### 1. 获取访问令牌
```bash
curl -X POST https://api.imagentx.ai/api/login \
  -H "Content-Type: application/json" \
  -d '{
    "account": "your-email@example.com",
    "password": "your-password"
  }'
```

### 2. 创建Agent
```bash
curl -X POST https://api.imagentx.ai/api/agents \
  -H "Authorization: Bearer your-token" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "我的助手",
    "description": "一个智能助手",
    "systemPrompt": "你是一个有用的AI助手",
    "modelId": "gpt-3.5-turbo"
  }'
```

### 3. 开始对话
```bash
curl -X POST https://api.imagentx.ai/api/sessions \
  -H "Authorization: Bearer your-token" \
  -H "Content-Type: application/json" \
  -d '{
    "agentId": "agent-id",
    "message": "你好，请介绍一下自己"
  }'
```

## 📚 SDK支持

### JavaScript/TypeScript
```bash
npm install @imagentx/sdk
```

```javascript
import { ImagentXClient } from '@imagentx/sdk';

const client = new ImagentXClient({
  apiKey: 'your-api-key',
  baseUrl: 'https://api.imagentx.ai/api'
});

// 创建Agent
const agent = await client.agents.create({
  name: '我的助手',
  description: '智能助手',
  systemPrompt: '你是一个有用的AI助手'
});
```

### Python
```bash
pip install imagentx-sdk
```

```python
from imagentx import ImagentXClient

client = ImagentXClient(
    api_key="your-api-key",
    base_url="https://api.imagentx.ai/api"
)

# 创建Agent
agent = client.agents.create(
    name="我的助手",
    description="智能助手",
    system_prompt="你是一个有用的AI助手"
)
```

## 🔧 错误处理

### 常见错误
1. **401 Unauthorized**: Token无效或过期
2. **429 Too Many Requests**: 请求频率超限
3. **400 Bad Request**: 请求参数错误

### 重试策略
建议实现指数退避重试机制：

```javascript
async function retryRequest(fn, maxRetries = 3) {
  for (let i = 0; i < maxRetries; i++) {
    try {
      return await fn();
    } catch (error) {
      if (error.status === 429 && i < maxRetries - 1) {
        await new Promise(resolve => 
          setTimeout(resolve, Math.pow(2, i) * 1000)
        );
        continue;
      }
      throw error;
    }
  }
}
```

## 📞 技术支持

- **API文档**: https://docs.imagentx.ai/api
- **开发者社区**: https://community.imagentx.ai
- **技术支持**: api-support@imagentx.ai
EOF

    echo -e "${GREEN}✅ API文档创建完成${NC}"
}

# 创建开发指南
create_developer_guide() {
    echo -e "${BLUE}👨‍💻 创建开发指南...${NC}"
    
    # 创建开发指南主页
    cat > docs/developer-guide/README.md << 'EOF'
# ImagentX 开发指南

## 概述

欢迎加入ImagentX开发团队！本指南将帮助您快速上手项目开发。

## 🛠️ 开发环境

### 系统要求
- **操作系统**: macOS 10.15+, Ubuntu 18.04+, Windows 10+
- **Java**: OpenJDK 17+
- **Node.js**: 18+
- **数据库**: PostgreSQL 13+
- **消息队列**: RabbitMQ 3.8+

### 开发工具
- **IDE**: IntelliJ IDEA / VS Code
- **数据库工具**: DBeaver / pgAdmin
- **API测试**: Postman / Apifox
- **版本控制**: Git

## 🚀 快速开始

### 1. 克隆项目
```bash
git clone https://github.com/imagentx/imagentx.git
cd imagentx
```

### 2. 后端环境配置
```bash
# 安装Java 17
brew install openjdk@17  # macOS
sudo apt install openjdk-17-jdk  # Ubuntu

# 安装Maven
brew install maven  # macOS
sudo apt install maven  # Ubuntu

# 配置环境变量
export JAVA_HOME=/path/to/java17
export PATH=$JAVA_HOME/bin:$PATH
```

### 3. 前端环境配置
```bash
# 安装Node.js
brew install node  # macOS
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -  # Ubuntu
sudo apt-get install -y nodejs

# 安装依赖
cd imagentx-frontend-plus
npm install
```

### 4. 数据库配置
```bash
# 安装PostgreSQL
brew install postgresql  # macOS
sudo apt install postgresql postgresql-contrib  # Ubuntu

# 创建数据库
createdb imagentx_dev
createdb imagentx_test
```

### 5. 启动服务
```bash
# 启动后端
cd ImagentX
mvn spring-boot:run

# 启动前端
cd imagentx-frontend-plus
npm run dev
```

## 🏗️ 项目架构

### 后端架构 (DDD)
```
ImagentX/
├── src/main/java/org/xhy/
│   ├── application/          # 应用层
│   │   ├── service/         # 应用服务
│   │   └── dto/            # 数据传输对象
│   ├── domain/              # 领域层
│   │   ├── model/          # 领域模型
│   │   ├── service/        # 领域服务
│   │   └── repository/     # 仓储接口
│   ├── infrastructure/      # 基础设施层
│   │   ├── config/         # 配置类
│   │   ├── repository/     # 仓储实现
│   │   └── external/       # 外部服务
│   └── interfaces/          # 接口层
│       ├── api/            # API接口
│       └── dto/            # 接口DTO
```

### 前端架构 (Next.js)
```
imagentx-frontend-plus/
├── app/                     # App Router
│   ├── (auth)/             # 认证页面
│   ├── (dashboard)/        # 仪表板页面
│   └── api/                # API路由
├── components/              # React组件
│   ├── ui/                 # 基础UI组件
│   └── features/           # 功能组件
├── lib/                     # 工具库
├── hooks/                   # 自定义Hooks
└── types/                   # TypeScript类型
```

## 📝 开发规范

### 代码规范
- **Java**: 遵循Google Java Style Guide
- **JavaScript/TypeScript**: 使用ESLint + Prettier
- **提交信息**: 遵循Conventional Commits

### 分支管理
- **main**: 主分支，用于生产环境
- **develop**: 开发分支，用于集成测试
- **feature/***: 功能分支
- **hotfix/***: 热修复分支

### 提交规范
```
feat: 添加新功能
fix: 修复bug
docs: 更新文档
style: 代码格式调整
refactor: 代码重构
test: 添加测试
chore: 构建过程或辅助工具的变动
```

## 🧪 测试

### 后端测试
```bash
# 运行单元测试
mvn test

# 运行集成测试
mvn verify

# 生成测试报告
mvn jacoco:report
```

### 前端测试
```bash
# 运行单元测试
npm test

# 运行E2E测试
npm run test:e2e

# 生成覆盖率报告
npm run test:coverage
```

## 🚀 部署

### 本地部署
```bash
# 构建后端
mvn clean package

# 构建前端
npm run build

# 启动Docker服务
docker-compose up -d
```

### 生产部署
```bash
# 使用部署脚本
./deploy/deploy.sh production
```

## 📚 学习资源

### 技术文档
- [Spring Boot官方文档](https://spring.io/projects/spring-boot)
- [Next.js官方文档](https://nextjs.org/docs)
- [PostgreSQL官方文档](https://www.postgresql.org/docs/)

### 项目文档
- [API文档](./api-reference.md)
- [数据库设计](./database-design.md)
- [部署指南](./deployment-guide.md)

## 🤝 贡献指南

### 提交流程
1. Fork项目
2. 创建功能分支
3. 提交代码
4. 创建Pull Request
5. 代码审查
6. 合并代码

### 代码审查
- 所有代码必须通过审查
- 至少需要一名团队成员批准
- 确保测试覆盖率不低于80%

## 📞 联系方式

- **技术讨论**: https://github.com/imagentx/imagentx/discussions
- **问题反馈**: https://github.com/imagentx/imagentx/issues
- **团队邮箱**: dev-team@imagentx.ai
EOF

    echo -e "${GREEN}✅ 开发指南创建完成${NC}"
}

# 创建部署文档
create_deployment_documentation() {
    echo -e "${BLUE}🚀 创建部署文档...${NC}"
    
    # 创建部署指南
    cat > docs/deployment/README.md << 'EOF'
# ImagentX 部署指南

## 概述

本指南介绍如何部署ImagentX项目到不同环境。

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
EOF

    echo -e "${GREEN}✅ 部署文档创建完成${NC}"
}

# 创建文档索引
create_documentation_index() {
    echo -e "${BLUE}📋 创建文档索引...${NC}"
    
    cat > docs/README.md << 'EOF'
# ImagentX 文档中心

欢迎来到ImagentX文档中心！这里包含了项目的所有文档。

## 📚 文档分类

### 👥 用户文档
- [用户手册](./user-guide/README.md) - 产品使用指南
- [快速开始](./user-guide/getting-started/README.md) - 新手指南
- [功能特性](./user-guide/features/README.md) - 详细功能介绍
- [常见问题](./user-guide/troubleshooting/README.md) - 问题解决方案

### 🔗 API文档
- [API参考](./api-reference/README.md) - 完整的API文档
- [接口列表](./api-reference/endpoints/README.md) - 所有API接口
- [数据模型](./api-reference/models/README.md) - 请求响应模型
- [代码示例](./api-reference/examples/README.md) - 使用示例

### 👨‍💻 开发文档
- [开发指南](./developer-guide/README.md) - 开发者入门
- [环境搭建](./developer-guide/setup/README.md) - 开发环境配置
- [架构设计](./developer-guide/architecture/README.md) - 系统架构
- [贡献指南](./developer-guide/contributing/README.md) - 参与贡献

### 🚀 部署文档
- [部署指南](./deployment/README.md) - 部署说明
- [Docker部署](./deployment/docker/README.md) - 容器化部署
- [Kubernetes部署](./deployment/kubernetes/README.md) - K8s部署
- [云平台部署](./deployment/cloud/README.md) - 云服务部署

## 🔍 快速导航

### 新用户
1. [快速开始](./user-guide/getting-started/README.md)
2. [用户手册](./user-guide/README.md)
3. [常见问题](./user-guide/troubleshooting/README.md)

### 开发者
1. [开发指南](./developer-guide/README.md)
2. [环境搭建](./developer-guide/setup/README.md)
3. [API文档](./api-reference/README.md)

### 运维人员
1. [部署指南](./deployment/README.md)
2. [Docker部署](./deployment/docker/README.md)
3. [监控配置](./deployment/monitoring/README.md)

## 📖 文档规范

### 编写规范
- 使用Markdown格式
- 遵循统一的目录结构
- 包含代码示例
- 提供截图说明

### 更新流程
1. 在对应分支创建文档
2. 提交Pull Request
3. 团队审查
4. 合并到主分支

## 🔗 相关链接

- [官方网站](https://imagentx.ai)
- [GitHub仓库](https://github.com/imagentx/imagentx)
- [在线演示](https://demo.imagentx.ai)
- [社区论坛](https://community.imagentx.ai)

## 📞 联系我们

- **技术支持**: support@imagentx.ai
- **文档反馈**: docs@imagentx.ai
- **商务合作**: business@imagentx.ai

---

*最后更新: 2024年8月25日*
EOF

    echo -e "${GREEN}✅ 文档索引创建完成${NC}"
}

# 主函数
main() {
    echo -e "${BLUE}📁 创建文档目录结构...${NC}"
    create_documentation_structure
    
    echo -e "${BLUE}👥 创建用户手册...${NC}"
    create_user_guide
    
    echo -e "${BLUE}🔗 创建API文档...${NC}"
    create_api_documentation
    
    echo -e "${BLUE}👨‍💻 创建开发指南...${NC}"
    create_developer_guide
    
    echo -e "${BLUE}🚀 创建部署文档...${NC}"
    create_deployment_documentation
    
    echo -e "${BLUE}📋 创建文档索引...${NC}"
    create_documentation_index
    
    echo -e "${GREEN}🎉 文档完善功能设置完成！${NC}"
    echo -e ""
    echo -e "${BLUE}📝 已创建的文档:${NC}"
    echo -e "  - 用户手册 (使用指南、功能说明)"
    echo -e "  - API文档 (接口参考、代码示例)"
    echo -e "  - 开发指南 (环境搭建、架构设计)"
    echo -e "  - 部署文档 (Docker、K8s、云平台)"
    echo -e ""
    echo -e "${YELLOW}📚 文档位置:${NC}"
    echo -e "  - 文档中心: docs/README.md"
    echo -e "  - 用户手册: docs/user-guide/"
    echo -e "  - API文档: docs/api-reference/"
    echo -e "  - 开发指南: docs/developer-guide/"
    echo -e "  - 部署文档: docs/deployment/"
    echo -e ""
    echo -e "${BLUE}💡 下一步:${NC}"
    echo -e "  1. 完善文档内容"
    echo -e "  2. 部署文档网站"
    echo -e "  3. 建立文档更新流程"
}

# 执行主函数
main "$@"
