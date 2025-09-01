#!/bin/bash

# 测试脚本：验证agentx到Imagent X的替换效果
# 功能：测试数据库中是否还有agentx相关的内容

set -e

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}🧪 测试agentx到Imagent X的替换效果${NC}"
echo "=================================="

# 检查容器是否运行
if ! docker ps | grep -q imagentx-app; then
    echo -e "${RED}❌ ImagentX容器未运行，请先启动服务${NC}"
    exit 1
fi

# 测试数据库连接
echo -e "${YELLOW}🔍 检查数据库连接...${NC}"
if ! docker exec imagentx-app psql -U imagentx_user -d imagentx -c "SELECT current_database(), current_user;" 2>/dev/null; then
    echo -e "${RED}❌ 无法连接到imagentx数据库${NC}"
    exit 1
fi

echo -e "${GREEN}✅ 数据库连接正常${NC}"

# 测试查询函数
test_table() {
    local table_name=$1
    local column_name=$2
    local search_pattern=$3
    
    echo -e "${YELLOW}🔍 检查表 ${table_name} 中的 ${column_name}...${NC}"
    
    local result=$(docker exec imagentx-app psql -U imagentx_user -d imagentx -t -c "SELECT COUNT(*) FROM ${table_name} WHERE ${column_name} ILIKE '%${search_pattern}%';" 2>/dev/null | tr -d ' ')
    
    if [ "$result" = "0" ]; then
        echo -e "${GREEN}✅ ${table_name}.${column_name} 中没有找到 ${search_pattern}${NC}"
    else
        echo -e "${RED}❌ ${table_name}.${column_name} 中找到 ${result} 条包含 ${search_pattern} 的记录${NC}"
    fi
}

# 测试所有大小写形式
echo ""
echo -e "${BLUE}📊 测试结果统计${NC}"
echo "=================================="

# 测试用户表
test_table "users" "nickname" "agentx"
test_table "users" "nickname" "Agentx"
test_table "users" "nickname" "AGENTX"
test_table "users" "email" "agentx"
test_table "users" "email" "Agentx"
test_table "users" "email" "AGENTX"

# 测试代理表
test_table "agents" "name" "agentx"
test_table "agents" "name" "Agentx"
test_table "agents" "name" "AGENTX"
test_table "agents" "description" "agentx"
test_table "agents" "description" "Agentx"
test_table "agents" "description" "AGENTX"

# 测试消息表
test_table "messages" "content" "agentx"
test_table "messages" "content" "Agentx"
test_table "messages" "content" "AGENTX"
test_table "messages" "role" "agentx"
test_table "messages" "role" "Agentx"
test_table "messages" "role" "AGENTX"

# 测试工具表
test_table "tools" "name" "agentx"
test_table "tools" "name" "Agentx"
test_table "tools" "name" "AGENTX"
test_table "tools" "description" "agentx"
test_table "tools" "description" "Agentx"
test_table "tools" "description" "AGENTX"

# 测试提供商表
test_table "providers" "name" "agentx"
test_table "providers" "name" "Agentx"
test_table "providers" "name" "AGENTX"
test_table "providers" "description" "agentx"
test_table "providers" "description" "Agentx"
test_table "providers" "description" "AGENTX"

# 测试模型表
test_table "models" "name" "agentx"
test_table "models" "name" "Agentx"
test_table "models" "name" "AGENTX"
test_table "models" "description" "agentx"
test_table "models" "description" "Agentx"
test_table "models" "description" "AGENTX"

# 测试产品表
test_table "products" "name" "agentx"
test_table "products" "name" "Agentx"
test_table "products" "name" "AGENTX"

# 测试规则表
test_table "rules" "name" "agentx"
test_table "rules" "name" "Agentx"
test_table "rules" "name" "AGENTX"
test_table "rules" "description" "agentx"
test_table "rules" "description" "Agentx"
test_table "rules" "description" "AGENTX"

# 测试上下文表
test_table "context" "summary" "agentx"
test_table "context" "summary" "Agentx"
test_table "context" "summary" "AGENTX"

# 测试文档单元表
test_table "document_unit" "content" "agentx"
test_table "document_unit" "content" "Agentx"
test_table "document_unit" "content" "AGENTX"

# 测试文件详情表
test_table "file_detail" "filename" "agentx"
test_table "file_detail" "filename" "Agentx"
test_table "file_detail" "filename" "AGENTX"
test_table "file_detail" "original_filename" "agentx"
test_table "file_detail" "original_filename" "Agentx"
test_table "file_detail" "original_filename" "AGENTX"

echo ""
echo -e "${BLUE}🎯 测试完成${NC}"
echo "=================================="
echo -e "${GREEN}✅ 如果所有测试都显示0条记录，说明替换成功${NC}"
echo -e "${YELLOW}💡 如果发现还有agentx相关内容，请重新运行更新脚本${NC}"
