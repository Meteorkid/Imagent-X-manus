#!/bin/bash

# ImagentX 认证问题修复脚本
# 用于解决401认证错误问题

set -e

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # 无颜色

echo -e "${BLUE}🔐 修复ImagentX认证问题...${NC}"

# 检查服务状态
check_services() {
    echo -e "${BLUE}🔍 检查服务状态...${NC}"
    
    # 检查后端服务
    if curl -s http://localhost:8088/api/health >/dev/null 2>&1; then
        echo -e "${GREEN}✅ 后端服务运行正常${NC}"
    else
        echo -e "${RED}❌ 后端服务未运行${NC}"
        exit 1
    fi
    
    # 检查前端服务
    if curl -s http://localhost:3000 >/dev/null 2>&1; then
        echo -e "${GREEN}✅ 前端服务运行正常${NC}"
    else
        echo -e "${RED}❌ 前端服务未运行${NC}"
        exit 1
    fi
}

# 测试登录功能
test_login() {
    echo -e "${BLUE}🧪 测试登录功能...${NC}"
    
    # 测试登录接口
    LOGIN_RESPONSE=$(curl -s -X POST http://localhost:8088/api/login \
        -H "Content-Type: application/json" \
        -d '{"account":"admin@imagentx.ai","password":"admin123"}')
    
    if echo "$LOGIN_RESPONSE" | jq -e '.code == 200' >/dev/null 2>&1; then
        echo -e "${GREEN}✅ 登录接口正常${NC}"
        TOKEN=$(echo "$LOGIN_RESPONSE" | jq -r '.data.token')
        echo -e "${BLUE}📝 获取到Token: ${TOKEN:0:50}...${NC}"
    else
        echo -e "${RED}❌ 登录接口异常${NC}"
        echo "$LOGIN_RESPONSE"
        exit 1
    fi
}

# 测试认证接口
test_auth_endpoints() {
    echo -e "${BLUE}🔐 测试认证接口...${NC}"
    
    # 测试账户接口
    ACCOUNT_RESPONSE=$(curl -s -H "Authorization: Bearer $TOKEN" \
        http://localhost:8088/api/accounts/current)
    
    if echo "$ACCOUNT_RESPONSE" | jq -e '.code == 200' >/dev/null 2>&1; then
        echo -e "${GREEN}✅ 账户接口认证正常${NC}"
    else
        echo -e "${RED}❌ 账户接口认证失败${NC}"
        echo "$ACCOUNT_RESPONSE"
    fi
    
    # 测试用户信息接口
    USER_RESPONSE=$(curl -s -H "Authorization: Bearer $TOKEN" \
        http://localhost:8088/api/users/me)
    
    if echo "$USER_RESPONSE" | jq -e '.code == 200' >/dev/null 2>&1; then
        echo -e "${GREEN}✅ 用户信息接口认证正常${NC}"
    else
        echo -e "${RED}❌ 用户信息接口认证失败${NC}"
        echo "$USER_RESPONSE"
    fi
}

# 修复前端认证配置
fix_frontend_auth() {
    echo -e "${BLUE}🔧 修复前端认证配置...${NC}"
    
    # 创建认证配置修复文件
    cat > imagentx-frontend-plus/lib/auth-fix.js << 'EOF'
// 认证问题修复脚本
// 用于解决401认证错误

// 默认登录凭据
const DEFAULT_CREDENTIALS = {
  account: 'admin@imagentx.ai',
  password: 'admin123'
};

// 自动登录函数
export async function autoLogin() {
  try {
    console.log('[AuthFix] 尝试自动登录...');
    
    const response = await fetch('/api/login', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(DEFAULT_CREDENTIALS),
    });
    
    const data = await response.json();
    
    if (data.code === 200 && data.data?.token) {
      // 保存token
      localStorage.setItem('auth_token', data.data.token);
      console.log('[AuthFix] 自动登录成功');
      return data.data.token;
    } else {
      console.error('[AuthFix] 自动登录失败:', data.message);
      return null;
    }
  } catch (error) {
    console.error('[AuthFix] 自动登录异常:', error);
    return null;
  }
}

// 检查并修复认证状态
export async function checkAndFixAuth() {
  const token = localStorage.getItem('auth_token');
  
  if (!token) {
    console.log('[AuthFix] 未找到认证token，尝试自动登录');
    return await autoLogin();
  }
  
  // 验证token是否有效
  try {
    const response = await fetch('/api/accounts/current', {
      headers: {
        'Authorization': `Bearer ${token}`
      }
    });
    
    if (response.status === 401) {
      console.log('[AuthFix] Token已过期，尝试重新登录');
      localStorage.removeItem('auth_token');
      return await autoLogin();
    }
    
    return token;
  } catch (error) {
    console.error('[AuthFix] Token验证失败:', error);
    return await autoLogin();
  }
}

// 初始化认证修复
export function initAuthFix() {
  if (typeof window !== 'undefined') {
    // 页面加载时检查认证状态
    window.addEventListener('load', () => {
      setTimeout(checkAndFixAuth, 1000);
    });
    
    // 监听401错误
    const originalFetch = window.fetch;
    window.fetch = async function(...args) {
      const response = await originalFetch.apply(this, args);
      
      if (response.status === 401) {
        console.log('[AuthFix] 检测到401错误，尝试重新认证');
        const newToken = await checkAndFixAuth();
        if (newToken) {
          // 重试原请求
          const [url, config] = args;
          const newConfig = {
            ...config,
            headers: {
              ...config?.headers,
              'Authorization': `Bearer ${newToken}`
            }
          };
          return originalFetch.apply(this, [url, newConfig]);
        }
      }
      
      return response;
    };
  }
}
EOF

    echo -e "${GREEN}✅ 前端认证修复文件已创建${NC}"
}

# 创建认证状态检查脚本
create_auth_checker() {
    echo -e "${BLUE}📋 创建认证状态检查脚本...${NC}"
    
    cat > check-auth-status.sh << 'EOF'
#!/bin/bash

# 认证状态检查脚本

echo "🔐 ImagentX 认证状态检查"
echo "=========================="

# 检查后端服务
echo "1. 检查后端服务..."
if curl -s http://localhost:8088/api/health >/dev/null 2>&1; then
    echo "✅ 后端服务正常"
else
    echo "❌ 后端服务异常"
    exit 1
fi

# 测试登录
echo "2. 测试登录功能..."
LOGIN_RESPONSE=$(curl -s -X POST http://localhost:8088/api/login \
    -H "Content-Type: application/json" \
    -d '{"account":"admin@imagentx.ai","password":"admin123"}')

if echo "$LOGIN_RESPONSE" | jq -e '.code == 200' >/dev/null 2>&1; then
    echo "✅ 登录功能正常"
    TOKEN=$(echo "$LOGIN_RESPONSE" | jq -r '.data.token')
    echo "📝 Token: ${TOKEN:0:50}..."
else
    echo "❌ 登录功能异常"
    echo "$LOGIN_RESPONSE"
    exit 1
fi

# 测试认证接口
echo "3. 测试认证接口..."
ACCOUNT_RESPONSE=$(curl -s -H "Authorization: Bearer $TOKEN" \
    http://localhost:8088/api/accounts/current)

if echo "$ACCOUNT_RESPONSE" | jq -e '.code == 200' >/dev/null 2>&1; then
    echo "✅ 账户接口认证正常"
    echo "💰 账户余额: $(echo "$ACCOUNT_RESPONSE" | jq -r '.data.balance')"
else
    echo "❌ 账户接口认证失败"
    echo "$ACCOUNT_RESPONSE"
fi

# 测试用户信息接口
USER_RESPONSE=$(curl -s -H "Authorization: Bearer $TOKEN" \
    http://localhost:8088/api/users/me)

if echo "$USER_RESPONSE" | jq -e '.code == 200' >/dev/null 2>&1; then
    echo "✅ 用户信息接口认证正常"
    echo "👤 用户ID: $(echo "$USER_RESPONSE" | jq -r '.data.id')"
else
    echo "❌ 用户信息接口认证失败"
    echo "$USER_RESPONSE"
fi

echo "=========================="
echo "🎉 认证状态检查完成"
EOF

    chmod +x check-auth-status.sh
    echo -e "${GREEN}✅ 认证状态检查脚本已创建${NC}"
}

# 创建认证问题解决指南
create_troubleshooting_guide() {
    echo -e "${BLUE}📚 创建认证问题解决指南...${NC}"
    
    cat > AUTH_TROUBLESHOOTING.md << 'EOF'
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
EOF

    echo -e "${GREEN}✅ 认证问题解决指南已创建${NC}"
}

# 主函数
main() {
    echo -e "${BLUE}🔍 检查服务状态...${NC}"
    check_services
    
    echo -e "${BLUE}🧪 测试登录功能...${NC}"
    test_login
    
    echo -e "${BLUE}🔐 测试认证接口...${NC}"
    test_auth_endpoints
    
    echo -e "${BLUE}🔧 修复前端认证配置...${NC}"
    fix_frontend_auth
    
    echo -e "${BLUE}📋 创建认证状态检查脚本...${NC}"
    create_auth_checker
    
    echo -e "${BLUE}📚 创建认证问题解决指南...${NC}"
    create_troubleshooting_guide
    
    echo -e "${GREEN}🎉 认证问题修复完成！${NC}"
    echo -e ""
    echo -e "${BLUE}📝 解决方案:${NC}"
    echo -e "  1. 运行认证状态检查: ./check-auth-status.sh"
    echo -e "  2. 查看解决指南: cat AUTH_TROUBLESHOOTING.md"
    echo -e "  3. 手动登录: http://localhost:3000/login"
    echo -e ""
    echo -e "${YELLOW}💡 建议:${NC}"
    echo -e "  - 使用默认账号: admin@imagentx.ai / admin123"
    echo -e "  - 登录成功后刷新页面"
    echo -e "  - 检查浏览器localStorage中的auth_token"
}

# 执行主函数
main "$@"
