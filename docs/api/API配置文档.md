# Imagent X 项目 API 配置文档

## 项目概览

Imagent X 是一个基于 LLM 和 MCP 的智能 Agent 构建平台，提供完整的 API 接口支持 Agent 管理、会话聊天、工具市场、RAG 知识库等功能。

## 🌐 基础配置

### 服务地址
- **开发环境**: `http://localhost:8088/api`
- **内网环境**: `http://192.168.1.63:8088/api`
- **公网环境**: `http://163.142.180.93:8088/api`
- **测试环境**: `https://test-api.imagentx.ai/api`

### 认证方式
- **认证类型**: Bearer Token (JWT)
- **Token获取**: 通过 `/auth/login` 接口获取
- **Token使用**: 在请求头中添加 `Authorization: Bearer <token>`

## 🔗 完整 API 接口列表

### 1. 系统健康检查
```
GET /health           - 后端健康检查
GET /health/db       - 数据库连接检查
GET /health/redis    - Redis连接检查
```

### 2. 用户认证
```
POST /auth/login     - 用户登录
POST /auth/register  - 用户注册
POST /auth/refresh   - 刷新令牌
POST /auth/logout    - 用户登出
```

### 3. 用户管理
```
GET    /users/me          - 获取当前用户信息
PUT    /users/password    - 修改密码
```

### 4. Agent 管理
```
GET    /agents/published                    - 获取已发布Agent列表
GET    /agents/user/{userId}               - 获取用户创建的Agent
POST   /agents                             - 创建Agent
GET    /agents/{agentId}                   - 获取Agent详情
PUT    /agents/{agentId}                   - 更新Agent
DELETE /agents/{agentId}                  - 删除Agent
GET    /agents/{agentId}/versions          - 获取Agent版本
POST   /agents/{agentId}/publish          - 发布Agent版本
POST   /agents/generate-system-prompt     - 生成系统提示词
```

### 5. Agent 工作区
```
GET    /agents/workspaces                  - 获取工作区列表
POST   /agents/workspaces/{agentId}       - 添加Agent到工作区
GET    /agents/workspaces/{agentId}/model-config    - 获取模型配置
POST   /agents/workspaces/{agentId}/model/config    - 设置模型配置
```

### 6. 会话管理
```
GET    /agents/sessions                    - 获取会话列表
POST   /agents/sessions                  - 创建会话
DELETE /agents/sessions/{sessionId}      - 删除会话
GET    /agents/sessions/{sessionId}/messages  - 获取消息历史
POST   /agents/sessions/{sessionId}/message    - 发送消息
POST   /agents/sessions/{sessionId}/stream-chat - 流式聊天
```

### 7. LLM 提供商管理
```
GET    /llms/providers                   - 获取提供商列表
POST   /llms/providers                  - 创建提供商
GET    /llms/providers/{id}             - 获取提供商详情
PUT    /llms/providers                  - 更新提供商
DELETE /llms/providers/{id}            - 删除提供商
GET    /llms/providers/protocols        - 获取支持的协议
POST   /llms/providers/{id}/status      - 切换提供商状态
```

### 8. LLM 模型管理
```
GET    /llms/models                      - 获取模型列表
POST   /llms/models                    - 创建模型
GET    /llms/models/default             - 获取默认模型
GET    /llms/models/{id}               - 获取模型详情
PUT    /llms/models                    - 更新模型
DELETE /llms/models/{id}              - 删除模型
POST   /llms/models/{id}/status         - 切换模型状态
GET    /llms/models/types               - 获取模型类型
```

### 9. 工具市场
```
GET    /tools/market                    - 工具市场列表
GET    /tools/market/{id}              - 工具详情
GET    /tools/market/{id}/versions    - 工具版本列表
GET    /tools/market/labels           - 工具标签列表
GET    /tools/recommend               - 推荐工具列表
POST   /tools/install/{toolId}/{version} - 安装工具
GET    /tools/installed               - 已安装工具列表
GET    /tools/user                    - 用户创建的工具
POST   /tools                         - 上传工具
GET    /tools/{toolId}               - 工具详情
PUT    /tools/{toolId}               - 更新工具
DELETE /tools/{toolId}               - 删除工具
DELETE /tools/uninstall/{toolId}     - 卸载工具
```

### 10. RAG 知识库
```
GET    /rag/datasets                  - 数据集列表
POST   /rag/datasets                  - 创建数据集
GET    /rag/datasets/{datasetId}      - 数据集详情
DELETE /rag/datasets/{datasetId}      - 删除数据集
POST   /rag/datasets/files            - 上传文件到数据集
GET    /rag/datasets/{datasetId}/files - 数据集文件列表
DELETE /rag/datasets/{datasetId}/files/{fileId} - 删除文件
POST   /rag/datasets/files/process    - 启动文件预处理
GET    /rag/datasets/files/{fileId}/progress - 文件处理进度
GET    /rag/datasets/{datasetId}/files/progress - 数据集文件处理进度
POST   /rag/search                    - RAG搜索文档
POST   /rag/search/stream-chat        - RAG流式聊天
```

### 11. RAG 文件操作
```
GET    /rag/files/{fileId}/info       - 文件详细信息
GET    /rag/files/document-units/list  - 分页查询语料
PUT    /rag/files/document-units      - 更新语料内容
DELETE /rag/files/document-units/{id} - 删除语料
GET    /rag/files/detail              - 文件详情
GET    /rag/files/content             - 文件内容
```

### 12. API 密钥管理
```
GET    /api-keys                      - API密钥列表
POST   /api-keys                      - 创建API密钥
GET    /api-keys/{id}                 - API密钥详情
PUT    /api-keys/{id}/status          - 更新API密钥状态
DELETE /api-keys/{id}                 - 删除API密钥
POST   /api-keys/{id}/reset           - 重置API密钥
GET    /api-keys/{id}/usage           - API密钥使用统计
GET    /api-keys/agent/{agentId}      - Agent的API密钥列表
```

### 13. 订单管理
```
GET    /orders                        - 用户订单列表
GET    /orders/{id}                   - 订单详情
```

### 14. 管理员接口
```
GET    /admin/users                   - 用户列表
GET    /admin/agents                  - Agent列表
GET    /admin/agents/statistics      - Agent统计
GET    /admin/orders                  - 订单列表
GET    /admin/orders/{id}             - 订单详情
```

## 📝 请求配置示例

### 基础请求配置
```typescript
// API基础配置
const API_CONFIG = {
  BASE_URL: 'http://localhost:8088/api',
  CURRENT_USER_ID: "1"
}

// HTTP客户端配置
const httpClient = new HttpClient(API_CONFIG.BASE_URL, [
  {
    request: (config) => {
      // 添加认证头
      const token = localStorage.getItem('auth_token');
      if (token) {
        config.headers = {
          ...config.headers,
          'Authorization': `Bearer ${token}`
        };
      }
      return config;
    },
    response: async (response) => {
      if (response.status === 401) {
        localStorage.removeItem('auth_token');
        window.location.href = '/login';
      }
      return response.json();
    }
  }
]);
```

### 常用请求示例

#### 1. 用户登录
```javascript
POST /auth/login
Content-Type: application/json

{
  "email": "admin@imagentx.ai",
  "password": "admin123"
}

// 响应
{
  "code": 200,
  "message": "登录成功",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "user": {
      "id": 1,
      "email": "admin@imagentx.ai",
      "nickname": "Imagent X管理员"
    }
  }
}
```

#### 2. 创建Agent
```javascript
POST /agents
Authorization: Bearer <token>
Content-Type: application/json

{
  "name": "智能助手",
  "description": "一个智能对话助手",
  "systemPrompt": "你是一个 helpful AI assistant",
  "modelId": "gpt-4",
  "tools": ["web-search", "calculator"]
}
```

#### 3. 创建会话
```javascript
POST /agents/sessions
Authorization: Bearer <token>
Content-Type: application/json

{
  "agentId": "agent-123",
  "title": "新会话"
}
```

#### 4. 发送消息
```javascript
POST /agents/sessions/{sessionId}/message
Authorization: Bearer <token>
Content-Type: application/json

{
  "content": "你好，请介绍一下自己",
  "type": "text"
}
```

#### 5. 流式聊天
```javascript
POST /agents/sessions/{sessionId}/stream-chat
Authorization: Bearer <token>
Content-Type: application/json
Accept: text/event-stream

{
  "content": "请详细介绍一下人工智能",
  "type": "text"
}
```

#### 6. 上传文件到RAG数据集
```javascript
POST /rag/datasets/files
Authorization: Bearer <token>
Content-Type: multipart/form-data

Form Data:
- datasetId: "dataset-123"
- file: <文件二进制数据>
```

#### 7. RAG搜索
```javascript
POST /rag/search
Authorization: Bearer <token>
Content-Type: application/json

{
  "query": "什么是机器学习",
  "datasetIds": ["dataset-123"],
  "topK": 5
}
```

## 🔧 环境变量配置

### 后端环境变量 (.env)
```bash
# 基础配置
ENV=development
SERVER_PORT=8088

# 数据库配置
DB_HOST=localhost
DB_PORT=5432
DB_NAME=imagentx
DB_USER=postgres
DB_PASSWORD=postgres

# JWT配置
JWT_SECRET=Epe71dM+pwLWP7SBj8t/Kg4sHVsd4uFE+UK3XTxcFOn6Wur3DOezDyS5yOgqWquF

# 默认管理员账号
IMAGENTX_ADMIN_EMAIL=admin@imagentx.ai
IMAGENTX_ADMIN_PASSWORD=admin123
IMAGENTX_ADMIN_NICKNAME=Imagent X管理员
```

### 前端环境变量
```bash
NEXT_PUBLIC_API_BASE_URL=http://localhost:8088/api
```

## 🚨 错误处理

### 标准错误响应格式
```json
{
  "code": 400,
  "message": "参数错误",
  "data": null,
  "timestamp": 1755674525344
}
```

### 常见错误码
- `200`: 成功
- `400`: 参数错误
- `401`: 未认证或token过期
- `403`: 无权限
- `404`: 资源不存在
- `500`: 服务器内部错误
- `503`: 服务不可用

## 📱 前端集成示例

### 1. API服务封装
```typescript
// api-service.ts
import { API_ENDPOINTS, buildApiUrl } from '@/lib/api-config';

class ApiService {
  private baseUrl = process.env.NEXT_PUBLIC_API_BASE_URL || 'http://localhost:8088/api';

  async login(email: string, password: string) {
    const response = await fetch(`${this.baseUrl}/auth/login`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ email, password })
    });
    return response.json();
  }

  async createAgent(agentData: any) {
    const token = localStorage.getItem('auth_token');
    const response = await fetch(buildApiUrl(API_ENDPOINTS.CREATE_AGENT), {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${token}`
      },
      body: JSON.stringify(agentData)
    });
    return response.json();
  }

  async sendMessage(sessionId: string, message: string) {
    const token = localStorage.getItem('auth_token');
    const response = await fetch(buildApiUrl(API_ENDPOINTS.SEND_MESSAGE(sessionId)), {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${token}`
      },
      body: JSON.stringify({ content: message, type: 'text' })
    });
    return response.json();
  }
}

export const apiService = new ApiService();
```

### 2. React Hook 示例
```typescript
// use-api.ts
import { useState, useCallback } from 'react';
import { apiService } from '@/services/api-service';

export function useApi() {
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);

  const login = useCallback(async (email: string, password: string) => {
    setLoading(true);
    setError(null);
    try {
      const result = await apiService.login(email, password);
      if (result.code === 200) {
        localStorage.setItem('auth_token', result.data.token);
        return result.data;
      } else {
        throw new Error(result.message);
      }
    } catch (err) {
      setError(err.message);
      throw err;
    } finally {
      setLoading(false);
    }
  }, []);

  return { login, loading, error };
}
```

## 🔍 调试和测试

### 1. 使用Apifox测试
- 访问: https://nz6d48w48i.apifox.cn
- 导入文件: `ImagentX-OpenAPI.json` (OpenAPI 3.0格式)
- 或使用: `ImagentX-Apifox-Collection.json` (Apifox Collection格式)

### 2. 使用curl测试
```bash
# 登录获取token
TOKEN=$(curl -s -X POST http://localhost:8088/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@imagentx.ai","password":"admin123"}' \
  | jq -r '.data.token')

# 创建Agent
curl -X POST http://localhost:8088/api/agents \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"name":"测试Agent","description":"测试描述"}'

# 获取Agent列表
curl -X GET "http://localhost:8088/api/agents/user/1" \
  -H "Authorization: Bearer $TOKEN"
```

## 📊 性能优化建议

1. **连接池配置**: 数据库连接池最大连接数设置为100
2. **缓存策略**: Redis缓存常用查询结果
3. **分页查询**: 所有列表接口支持分页参数
4. **流式响应**: 大文本响应使用流式传输
5. **CDN加速**: 静态资源使用CDN加速

## 🔐 安全配置

1. **HTTPS**: 生产环境必须使用HTTPS
2. **CORS**: 配置跨域访问策略
3. **Rate Limiting**: 实现接口限流
4. **输入验证**: 所有输入参数严格验证
5. **SQL注入防护**: 使用参数化查询

---

**文档版本**: v1.0.0  
**最后更新**: 2024-12-20  
**维护人员**: Imagent X开发团队