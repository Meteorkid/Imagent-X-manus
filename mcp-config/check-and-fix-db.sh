#!/bin/bash
# 数据库检查和修复脚本

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔍 数据库检查和修复脚本${NC}"
echo "=================================="

# 检查数据库连接
check_db_connection() {
    echo -e "${YELLOW}🔍 检查数据库连接...${NC}"
    
    # 检查PostgreSQL容器状态
    if docker ps | grep -q imagentx-postgres; then
        echo -e "${GREEN}✅ PostgreSQL容器运行正常${NC}"
    else
        echo -e "${RED}❌ PostgreSQL容器未运行${NC}"
        return 1
    fi
    
    # 检查数据库连接
    if docker exec imagentx-postgres pg_isready -U imagentx_user -d imagentx > /dev/null 2>&1; then
        echo -e "${GREEN}✅ 数据库连接正常${NC}"
    else
        echo -e "${RED}❌ 数据库连接失败${NC}"
        return 1
    fi
}

# 检查用户表
check_users_table() {
    echo -e "${YELLOW}🔍 检查用户表...${NC}"
    
    # 检查users表是否存在
    TABLE_EXISTS=$(docker exec imagentx-postgres psql -U imagentx_user -d imagentx -t -c "SELECT EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'users');" 2>/dev/null | tr -d ' ')
    
    if [ "$TABLE_EXISTS" = "t" ]; then
        echo -e "${GREEN}✅ users表存在${NC}"
        
        # 检查用户数量
        USER_COUNT=$(docker exec imagentx-postgres psql -U imagentx_user -d imagentx -t -c "SELECT COUNT(*) FROM users;" 2>/dev/null | tr -d ' ')
        echo "用户数量: $USER_COUNT"
        
        if [ "$USER_COUNT" -gt 0 ]; then
            echo -e "${GREEN}✅ 数据库中有用户数据${NC}"
            return 0
        else
            echo -e "${YELLOW}⚠️  数据库中没有用户数据${NC}"
            return 1
        fi
    else
        echo -e "${RED}❌ users表不存在${NC}"
        return 1
    fi
}

# 创建管理员用户
create_admin_user() {
    echo -e "${YELLOW}🔧 创建管理员用户...${NC}"
    
    # 使用BCrypt加密密码 (admin123)
    ENCRYPTED_PASSWORD='$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVEFDa'
    
    # 插入管理员用户
    docker exec imagentx-postgres psql -U imagentx_user -d imagentx -c "
    INSERT INTO users (id, nickname, email, phone, password, is_admin, created_at, updated_at) 
    VALUES (
        'admin-user-uuid-001',
        'Imagent X管理员',
        'admin@imagentx.ai',
        '',
        '$ENCRYPTED_PASSWORD',
        true,
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    ) ON CONFLICT (id) DO NOTHING;
    " 2>/dev/null
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ 管理员用户创建成功${NC}"
    else
        echo -e "${RED}❌ 管理员用户创建失败${NC}"
        return 1
    fi
}

# 测试登录
test_login() {
    echo -e "${YELLOW}🔍 测试登录...${NC}"
    
    LOGIN_RESPONSE=$(curl -s -X POST http://localhost:8088/api/login \
        -H "Content-Type: application/json" \
        -d '{"account":"admin@imagentx.ai","password":"admin123"}')
    
    if echo "$LOGIN_RESPONSE" | grep -q "token"; then
        echo -e "${GREEN}✅ 登录测试成功${NC}"
        TOKEN=$(echo "$LOGIN_RESPONSE" | grep -o '"token":"[^"]*"' | cut -d'"' -f4)
        echo "Token: ${TOKEN:0:20}..."
        return 0
    else
        echo -e "${RED}❌ 登录测试失败${NC}"
        echo "响应: $LOGIN_RESPONSE"
        return 1
    fi
}

# 显示修复结果
show_result() {
    echo -e "${BLUE}📊 修复完成！${NC}"
    echo "=================================="
    echo -e "${GREEN}✅ 修复步骤：${NC}"
    echo "  • 检查数据库连接"
    echo "  • 检查用户表"
    echo "  • 创建管理员用户"
    echo "  • 测试登录功能"
    echo ""
    echo -e "${YELLOW}🔐 登录信息：${NC}"
    echo "  • 账号: admin@imagentx.ai"
    echo "  • 密码: admin123"
    echo "  • 登录页面: http://localhost:3000/login"
    echo ""
    echo -e "${YELLOW}🚀 下一步：${NC}"
    echo "  • 访问 http://localhost:3000/login"
    echo "  • 使用上述账号密码登录"
    echo "  • 如果仍有问题，请清除浏览器缓存"
}

# 主函数
main() {
    check_db_connection || exit 1
    check_users_table || create_admin_user
    test_login
    show_result
}

# 执行主函数
main "$@"
