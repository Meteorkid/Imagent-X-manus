#!/bin/bash
# ImagentX 专用认证配置脚本
# 配置ImagentX前端和后端的认证信息

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔐 ImagentX 专用认证配置脚本${NC}"
echo "=================================="

# 创建ImagentX认证配置
create_imagentx_auth_config() {
    echo -e "${YELLOW}🔧 创建ImagentX认证配置...${NC}"
    
    # 创建ImagentX认证配置文件
    cat > mcp-config/auth/imagentx-auth.yml << 'EOF'
# ImagentX 认证配置
imagentx:
  # 管理员用户配置
  admin:
    email: admin@imagentx.top
    password: admin123
    nickname: Imagent X管理员
    role: ADMIN
  
  # 测试用户配置
  test:
    email: test@imagentx.top
    password: test123
    nickname: 测试用户
    role: USER
    enabled: false
  
  # JWT配置
  jwt:
    secret: please_change_this_in_production
    expiration: 86400  # 24小时
    refresh_expiration: 604800  # 7天
  
  # 安全配置
  security:
    password_min_length: 8
    require_special_chars: true
    max_login_attempts: 5
    lockout_duration: 300  # 5分钟
EOF
    echo -e "${GREEN}✅ ImagentX认证配置创建完成${NC}"
}

# 创建环境变量文件
create_env_file() {
    echo -e "${YELLOW}📝 创建环境变量文件...${NC}"
    
    cat > mcp-config/auth/.env.imagentx << 'EOF'
# ImagentX 环境变量配置

# 管理员用户
IMAGENTX_ADMIN_EMAIL=admin@imagentx.top
IMAGENTX_ADMIN_PASSWORD=admin123
IMAGENTX_ADMIN_NICKNAME=Imagent X管理员

# 测试用户
IMAGENTX_TEST_ENABLED=false
IMAGENTX_TEST_EMAIL=test@imagentx.top
IMAGENTX_TEST_PASSWORD=test123
IMAGENTX_TEST_NICKNAME=测试用户

# JWT配置
JWT_SECRET=please_change_this_in_production

# 数据库配置
DB_HOST=postgres
DB_PORT=5432
DB_NAME=imagentx
DB_USER=imagentx_user
DB_PASSWORD=imagentx_pass

# 应用配置
SERVER_PORT=8088
FRONTEND_PORT=3000
NEXT_PUBLIC_API_BASE_URL=/api
SPRING_PROFILES_ACTIVE=prod
EOF
    echo -e "${GREEN}✅ 环境变量文件创建完成${NC}"
}

# 创建登录测试脚本
create_login_test_script() {
    echo -e "${YELLOW}🧪 创建登录测试脚本...${NC}"
    
    cat > mcp-config/auth/test-imagentx-login.sh << 'EOF'
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
EOF
    
    chmod +x mcp-config/auth/test-imagentx-login.sh
    echo -e "${GREEN}✅ 登录测试脚本创建完成${NC}"
}

# 创建快速登录脚本
create_quick_login_script() {
    echo -e "${YELLOW}⚡ 创建快速登录脚本...${NC}"
    
    cat > mcp-config/auth/quick-login.sh << 'EOF'
#!/bin/bash
# ImagentX 快速登录脚本

# 自动打开登录页面
if command -v open >/dev/null 2>&1; then
    # macOS
    open http://localhost:3000/login
elif command -v xdg-open >/dev/null 2>&1; then
    # Linux
    xdg-open http://localhost:3000/login
elif command -v start >/dev/null 2>&1; then
    # Windows
    start http://localhost:3000/login
else
    echo "请手动访问: http://localhost:3000/login"
fi

echo "🔐 ImagentX 快速登录"
echo "===================="
echo "正在打开登录页面..."
echo ""
echo "📋 登录信息："
echo "  账号: admin@imagentx.top"
echo "  密码: admin123"
echo ""
echo "💡 提示："
echo "  - 登录成功后会自动跳转到主页面"
echo "  - 系统会记住您的登录状态"
echo "  - 如需退出，请点击右上角的用户菜单"
EOF
    
    chmod +x mcp-config/auth/quick-login.sh
    echo -e "${GREEN}✅ 快速登录脚本创建完成${NC}"
}

# 显示ImagentX认证信息
show_imagentx_auth_info() {
    echo -e "${BLUE}📊 ImagentX认证配置完成！${NC}"
    echo "=================================="
    echo -e "${GREEN}✅ ImagentX认证信息：${NC}"
    echo ""
    echo -e "${YELLOW}🔐 用户认证：${NC}"
    echo "  • 管理员: admin@imagentx.top / admin123"
    echo "  • 测试用户: test@imagentx.top / test123 (可选)"
    echo ""
    echo -e "${YELLOW}🌐 访问地址：${NC}"
    echo "  • 前端应用: http://localhost:3000"
    echo "  • 登录页面: http://localhost:3000/login"
    echo "  • 后端API: http://localhost:8088"
    echo "  • API文档: http://localhost:8088/api"
    echo ""
    echo -e "${YELLOW}📁 配置文件：${NC}"
    echo "  • 认证配置: mcp-config/auth/imagentx-auth.yml"
    echo "  • 环境变量: mcp-config/auth/.env.imagentx"
    echo "  • 登录测试: mcp-config/auth/test-imagentx-login.sh"
    echo "  • 快速登录: mcp-config/auth/quick-login.sh"
    echo ""
    echo -e "${YELLOW}🚀 使用方法：${NC}"
    echo "  • 快速登录: ./mcp-config/auth/quick-login.sh"
    echo "  • 测试登录: ./mcp-config/auth/test-imagentx-login.sh"
    echo "  • 查看配置: cat mcp-config/auth/imagentx-auth.yml"
    echo ""
    echo -e "${RED}⚠️  安全提醒：${NC}"
    echo "  • 生产环境请修改默认密码"
    echo "  • 建议启用HTTPS"
    echo "  • 定期更换JWT密钥"
    echo "  • 监控登录尝试次数"
}

# 主函数
main() {
    create_imagentx_auth_config
    create_env_file
    create_login_test_script
    create_quick_login_script
    show_imagentx_auth_info
}

# 执行主函数
main "$@"
