#!/bin/bash
# ImagentX 登录测试脚本

set -e

# 颜色定义
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}🔐 ImagentX 登录测试${NC}"
echo "=========================="

# 测试登录
echo "测试管理员登录..."
LOGIN_RESPONSE=$(curl -s -X POST http://localhost:8088/api/login \
    -H "Content-Type: application/json" \
    -d '{"account":"admin@imagentx.top","password":"admin123"}')

if echo "$LOGIN_RESPONSE" | grep -q "token"; then
    echo -e "${GREEN}✅ 管理员登录成功${NC}"
    TOKEN=$(echo "$LOGIN_RESPONSE" | grep -o '"token":"[^"]*"' | cut -d'"' -f4)
    echo "Token: ${TOKEN:0:20}..."
    
    # 测试API访问
    echo "测试API访问..."
    API_RESPONSE=$(curl -s -H "Authorization: Bearer $TOKEN" http://localhost:8088/api/users/me)
    
    if echo "$API_RESPONSE" | grep -q "email"; then
        echo -e "${GREEN}✅ API访问成功${NC}"
        echo "用户信息: $(echo "$API_RESPONSE" | grep -o '"email":"[^"]*"' | cut -d'"' -f4)"
    else
        echo -e "${RED}❌ API访问失败${NC}"
        echo "响应: $API_RESPONSE"
    fi
else
    echo -e "${RED}❌ 管理员登录失败${NC}"
    echo "响应: $LOGIN_RESPONSE"
fi

echo ""
echo -e "${YELLOW}📋 登录信息：${NC}"
echo "  账号: admin@imagentx.top"
echo "  密码: admin123"
echo "  登录页面: http://localhost:3000/login"
echo "  API地址: http://localhost:8088/api/login"
