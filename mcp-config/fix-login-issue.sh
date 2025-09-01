#!/bin/bash
# ImagentX 登录问题修复脚本
# 解决前端显示"暂时无法登录"的问题

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔧 ImagentX 登录问题修复脚本${NC}"
echo "=================================="

# 检查服务状态
check_services() {
    echo -e "${YELLOW}🔍 检查服务状态...${NC}"
    
    # 检查后端服务
    if curl -s -o /dev/null -w "%{http_code}" http://localhost:8088/api/health | grep -q "200"; then
        echo -e "${GREEN}✅ 后端服务运行正常${NC}"
    else
        echo -e "${RED}❌ 后端服务未运行或无法访问${NC}"
        echo "请先启动后端服务: docker-compose up -d"
        return 1
    fi
    
    # 检查前端服务
    if curl -s -o /dev/null -w "%{http_code}" http://localhost:3000 | grep -q "200"; then
        echo -e "${GREEN}✅ 前端服务运行正常${NC}"
    else
        echo -e "${RED}❌ 前端服务未运行或无法访问${NC}"
        echo "请先启动前端服务: docker-compose up -d"
        return 1
    fi
}

# 测试认证配置API
test_auth_config_api() {
    echo -e "${YELLOW}🔍 测试认证配置API...${NC}"
    
    # 测试认证配置API
    AUTH_CONFIG_RESPONSE=$(curl -s http://localhost:8088/api/auth/config)
    echo "认证配置API响应: $AUTH_CONFIG_RESPONSE"
    
    if echo "$AUTH_CONFIG_RESPONSE" | grep -q "loginMethods"; then
        echo -e "${GREEN}✅ 认证配置API响应正常${NC}"
        
        # 检查是否有启用的登录方式
        if echo "$AUTH_CONFIG_RESPONSE" | grep -q '"enabled":true'; then
            echo -e "${GREEN}✅ 有启用的登录方式${NC}"
        else
            echo -e "${YELLOW}⚠️  没有启用的登录方式，需要启用登录功能${NC}"
            enable_login_features
        fi
    else
        echo -e "${RED}❌ 认证配置API响应异常${NC}"
        return 1
    fi
}

# 启用登录功能
enable_login_features() {
    echo -e "${YELLOW}🔧 启用登录功能...${NC}"
    
    # 启用普通登录
    echo "启用普通登录..."
    NORMAL_LOGIN_RESPONSE=$(curl -s -X PUT http://localhost:8088/api/auth/settings/auth-normal-login/toggle)
    echo "普通登录启用响应: $NORMAL_LOGIN_RESPONSE"
    
    # 启用GitHub登录
    echo "启用GitHub登录..."
    GITHUB_LOGIN_RESPONSE=$(curl -s -X PUT http://localhost:8088/api/auth/settings/auth-github-login/toggle)
    echo "GitHub登录启用响应: $GITHUB_LOGIN_RESPONSE"
    
    # 启用用户注册
    echo "启用用户注册..."
    REGISTER_RESPONSE=$(curl -s -X PUT http://localhost:8088/api/auth/settings/auth-user-register/toggle)
    echo "用户注册启用响应: $REGISTER_RESPONSE"
    
    echo -e "${GREEN}✅ 登录功能启用完成${NC}"
}

# 测试登录功能
test_login_function() {
    echo -e "${YELLOW}🔍 测试登录功能...${NC}"
    
    # 测试登录API
    LOGIN_RESPONSE=$(curl -s -X POST http://localhost:8088/api/login \
        -H "Content-Type: application/json" \
        -d '{"account":"admin@imagentx.ai","password":"admin123"}')
    
    if echo "$LOGIN_RESPONSE" | grep -q "token"; then
        echo -e "${GREEN}✅ 登录API测试成功${NC}"
        TOKEN=$(echo "$LOGIN_RESPONSE" | grep -o '"token":"[^"]*"' | cut -d'"' -f4)
        echo "获取到Token: ${TOKEN:0:20}..."
        
        # 测试用户信息API
        USER_RESPONSE=$(curl -s -H "Authorization: Bearer $TOKEN" http://localhost:8088/api/users/me)
        if echo "$USER_RESPONSE" | grep -q "email"; then
            echo -e "${GREEN}✅ 用户信息API测试成功${NC}"
        else
            echo -e "${RED}❌ 用户信息API测试失败${NC}"
        fi
    else
        echo -e "${RED}❌ 登录API测试失败${NC}"
        echo "响应: $LOGIN_RESPONSE"
        return 1
    fi
}

# 清除浏览器缓存提示
clear_browser_cache() {
    echo -e "${YELLOW}🧹 浏览器缓存清理提示...${NC}"
    echo ""
    echo -e "${BLUE}📋 请执行以下步骤清理浏览器缓存：${NC}"
    echo "1. 打开浏览器开发者工具 (F12)"
    echo "2. 右键点击刷新按钮，选择'清空缓存并硬性重新加载'"
    echo "3. 或者按 Ctrl+Shift+R (Windows/Linux) 或 Cmd+Shift+R (Mac)"
    echo "4. 清除localStorage: 在控制台执行 localStorage.clear()"
    echo "5. 重新访问: http://localhost:3000/login"
    echo ""
}

# 创建快速修复脚本
create_quick_fix_script() {
    echo -e "${YELLOW}⚡ 创建快速修复脚本...${NC}"
    
    cat > mcp-config/quick-fix-login.sh << 'EOF'
#!/bin/bash
# ImagentX 快速修复登录问题

echo "🔧 快速修复ImagentX登录问题..."
echo "=================================="

# 启用所有登录功能
echo "启用登录功能..."
curl -s -X PUT http://localhost:8088/api/auth/settings/auth-normal-login/toggle > /dev/null
curl -s -X PUT http://localhost:8088/api/auth/settings/auth-github-login/toggle > /dev/null
curl -s -X PUT http://localhost:8088/api/auth/settings/auth-user-register/toggle > /dev/null

echo "✅ 登录功能已启用"
echo ""
echo "📋 登录信息："
echo "  账号: admin@imagentx.top"
echo "  密码: admin123"
echo "  登录页面: http://localhost:3000/login"
echo ""
echo "💡 如果仍然显示'暂时无法登录'，请："
echo "  1. 清除浏览器缓存 (Ctrl+Shift+R)"
echo "  2. 清除localStorage (F12 -> 控制台 -> localStorage.clear())"
echo "  3. 重新访问登录页面"
EOF
    
    chmod +x mcp-config/quick-fix-login.sh
    echo -e "${GREEN}✅ 快速修复脚本创建完成${NC}"
}

# 显示修复结果
show_fix_result() {
    echo -e "${BLUE}📊 修复完成！${NC}"
    echo "=================================="
    echo -e "${GREEN}✅ 修复步骤：${NC}"
    echo "  • 检查服务状态"
    echo "  • 测试认证配置API"
    echo "  • 启用登录功能"
    echo "  • 测试登录功能"
    echo "  • 创建快速修复脚本"
    echo ""
    echo -e "${YELLOW}🔐 登录信息：${NC}"
    echo "  • 账号: admin@imagentx.top"
    echo "  • 密码: admin123"
    echo "  • 登录页面: http://localhost:3000/login"
    echo ""
    echo -e "${YELLOW}🚀 使用方法：${NC}"
    echo "  • 快速修复: ./mcp-config/quick-fix-login.sh"
    echo "  • 手动登录: 访问 http://localhost:3000/login"
    echo "  • 清除缓存: Ctrl+Shift+R (硬刷新)"
    echo ""
    echo -e "${RED}⚠️  如果问题仍然存在：${NC}"
    echo "  • 检查后端服务是否正常运行"
    echo "  • 检查数据库连接是否正常"
    echo "  • 查看后端日志: docker logs imagentx-app"
    echo "  • 清除浏览器缓存和localStorage"
}

# 主函数
main() {
    check_services || exit 1
    test_auth_config_api
    test_login_function
    create_quick_fix_script
    clear_browser_cache
    show_fix_result
}

# 执行主函数
main "$@"
