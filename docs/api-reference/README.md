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
