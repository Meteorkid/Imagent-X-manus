# Imagent X 快速API使用指南

## 📋 关于 Imagent X API

Imagent X 是一个智能对话系统平台，提供完整的Agent管理和对话功能API。

## 🎯 Imagent X 核心功能

Imagent X 平台提供以下核心API功能：

## 🚀 5分钟快速上手

### 步骤1：启动服务
```bash
# 使用Docker一键启动
docker-compose up -d

# 或使用本地启动
# 后端 (端口8088)
cd ImagentX
./mvnw spring-boot:run

# 前端 (端口3000)
cd imagentx-frontend-plus
npm install
npm run dev
```

### 步骤2：获取访问令牌
```bash
# 使用curl获取token
curl -X POST http://localhost:8088/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@imagentx.ai","password":"admin123"}'

# 响应示例
{
  "code": 200,
  "message": "登录成功",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIs...",
    "user": {"id": 1, "email": "admin@imagentx.ai"}
  }
}
```

### 步骤3：测试核心API

#### 1. 创建第一个Agent
```bash
# 保存token到变量
TOKEN="eyJhbGciOiJIUzI1NiIs..."

# 创建Agent
curl -X POST http://localhost:8088/api/agents \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "我的第一个AI助手",
    "description": "一个智能对话助手",
    "systemPrompt": "你是一个 helpful AI assistant",
    "modelId": "gpt-4"
  }'
```

#### 2. 创建会话并聊天
```bash
# 创建会话
SESSION_ID=$(curl -X POST http://localhost:8088/api/agents/sessions \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"agentId":"agent-id-from-above","title":"测试会话"}' \
  | jq -r '.data.id')

# 发送消息
curl -X POST http://localhost:8088/api/agents/sessions/$SESSION_ID/message \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"content":"你好，请介绍一下Imagent X平台","type":"text"}'
```

#### 3. 使用RAG知识库
```bash
# 创建数据集
DATASET_ID=$(curl -X POST http://localhost:8088/api/rag/datasets \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"name":"技术文档