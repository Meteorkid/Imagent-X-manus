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
