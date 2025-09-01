# ImagentX 认证问题解决指南

## 🔍 问题描述

前端访问需要认证的API接口时出现401错误：
```
Failed to load resource: the server responded with a status of 401 ()
[AccountContext] 获取账户数据失败 请求失败 (401)
```

## 🎯 问题原因

1. **用户未登录**: 前端没有有效的认证token
2. **Token过期**: 存储的token已过期
3. **Token格式错误**: token格式不正确
4. **认证头缺失**: 请求头中缺少Authorization头

## 🛠️ 解决方案

### 方案1: 手动登录

1. 访问登录页面: http://localhost:3000/login
2. 使用默认账号登录:
   - 账号: admin@imagentx.ai
   - 密码: admin123
3. 登录成功后会自动保存token

### 方案2: 自动登录修复

运行认证修复脚本：
```bash
./enhancement-scripts/fix-auth-issue.sh
```

### 方案3: 检查认证状态

运行认证状态检查：
```bash
./check-auth-status.sh
```

## 🔧 技术细节

### 认证流程

1. **登录**: POST /api/login
   ```json
   {
     "account": "admin@imagentx.ai",
     "password": "admin123"
   }
   ```

2. **获取Token**: 登录成功后返回JWT token
   ```json
   {
     "code": 200,
     "message": "登录成功",
     "data": {
       "token": "eyJhbGciOiJIUzM4NCJ9..."
     }
   }
   ```

3. **使用Token**: 在请求头中添加Authorization
   ```
   Authorization: Bearer eyJhbGciOiJIUzM4NCJ9...
   ```

### 需要认证的接口

- `/api/accounts/current` - 获取当前用户账户信息
- `/api/users/me` - 获取当前用户信息
- `/api/agents/**` - Agent相关接口
- `/api/sessions/**` - 会话相关接口

### 前端认证配置

前端使用localStorage存储token：
```javascript
// 保存token
localStorage.setItem('auth_token', token);

// 获取token
const token = localStorage.getItem('auth_token');

// 在请求头中使用
headers: {
  'Authorization': `Bearer ${token}`
}
```

## 🚨 常见问题

### Q1: 登录后仍然出现401错误
**A**: 检查token是否正确保存到localStorage，可以在浏览器开发者工具中查看。

### Q2: Token过期怎么办
**A**: 清除localStorage中的token，重新登录：
```javascript
localStorage.removeItem('auth_token');
```

### Q3: 如何验证token是否有效
**A**: 使用以下命令测试：
```bash
curl -H "Authorization: Bearer YOUR_TOKEN" http://localhost:8088/api/accounts/current
```

### Q4: 前端自动登录失败
**A**: 检查后端服务是否正常运行，确认登录接口可访问。

## 📞 技术支持

如果问题仍然存在，请：

1. 运行认证状态检查脚本
2. 查看浏览器控制台错误信息
3. 检查后端服务日志
4. 联系技术支持团队

## 🔄 预防措施

1. **定期检查token有效性**
2. **实现token自动刷新机制**
3. **添加认证状态监控**
4. **完善错误处理和用户提示**
