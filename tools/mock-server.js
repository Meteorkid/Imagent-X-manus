const express = require('express');
const cors = require('cors');
const app = express();

app.use(cors());
app.use(express.json());

// 健康检查
app.get('/api/actuator/health', (req, res) => {
  res.json({ status: 'UP', timestamp: new Date().toISOString() });
});

// 模拟用户数据
const mockUser = {
  id: 1,
  email: 'test@imagentx.ai',
  name: '测试用户',
  avatar: '/placeholder-user.jpg',
  role: 'user',
  createdAt: '2024-01-01T00:00:00.000Z',
  updatedAt: new Date().toISOString()
};

// 模拟助理数据
const mockAssistants = [
  {
    id: 1,
    name: '智能助手A',
    description: '全能型AI助手，支持多种任务',
    avatar: '/placeholder-logo.png',
    type: 'general',
    isActive: true,
    createdAt: '2024-01-01T00:00:00.000Z'
  },
  {
    id: 2,
    name: '代码助手',
    description: '专业编程助手，支持多种语言',
    avatar: '/placeholder-logo.svg',
    type: 'coding',
    isActive: true,
    createdAt: '2024-01-02T00:00:00.000Z'
  },
  {
    id: 3,
    name: '文档助手',
    description: '文档处理和内容生成助手',
    avatar: '/placeholder-logo.jpg',
    type: 'writing',
    isActive: false,
    createdAt: '2024-01-03T00:00:00.000Z'
  }
];

// 用户相关API
app.get('/api/users/me', (req, res) => {
  res.json({
    success: true,
    data: mockUser,
    message: '获取用户信息成功'
  });
});

// 助理列表API
app.get('/api/assistants', (req, res) => {
  res.json({
    success: true,
    data: mockAssistants,
    message: '获取助理列表成功'
  });
});

// 创建助理
app.post('/api/assistants', (req, res) => {
  const { name, description, type } = req.body;
  const newAssistant = {
    id: mockAssistants.length + 1,
    name,
    description,
    avatar: '/placeholder-logo.png',
    type,
    isActive: true,
    createdAt: new Date().toISOString()
  };
  mockAssistants.push(newAssistant);
  
  res.json({
    success: true,
    data: newAssistant,
    message: '创建助理成功'
  });
});

// 其他常用API
app.get('/api/config', (req, res) => {
  res.json({
    success: true,
    data: {
      maxFileSize: 10485760,
      supportedFormats: ['txt', 'pdf', 'doc', 'docx', 'jpg', 'png'],
      features: {
        chat: true,
        upload: true,
        voice: false
      }
    }
  });
});

const PORT = process.env.PORT || 8088;
app.listen(PORT, () => {
  console.log(`✅ Mock API Server running on http://localhost:${PORT}`);
  console.log('📋 Available endpoints:');
  console.log('  GET  /api/actuator/health');
  console.log('  GET  /api/users/me');
  console.log('  GET  /api/assistants');
  console.log('  POST /api/assistants');
  console.log('  GET  /api/config');
});