#!/bin/bash

# 创建imagentx数据库的简化脚本
# 功能：快速创建imagentx数据库和用户

set -e

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}🗄️ 创建imagentx数据库${NC}"
echo "=================================="

# 检查容器是否运行
if ! docker ps | grep -q imagentx-app; then
    echo -e "${RED}❌ ImagentX容器未运行，请先启动服务${NC}"
    echo -e "${YELLOW}💡 启动命令：docker-compose -f docker-compose-internal-db.yml up -d${NC}"
    exit 1
fi

echo -e "${YELLOW}📝 创建imagentx数据库...${NC}"

# 创建新数据库
docker exec imagentx-app psql -U postgres -c "CREATE DATABASE imagentx;" 2>/dev/null || echo "数据库可能已存在"

# 创建新用户
docker exec imagentx-app psql -U postgres -c "CREATE USER imagentx_user WITH PASSWORD 'imagentx_pass';" 2>/dev/null || echo "用户可能已存在"

# 授予权限
docker exec imagentx-app psql -U postgres -c "GRANT ALL PRIVILEGES ON DATABASE imagentx TO imagentx_user;"
docker exec imagentx-app psql -U postgres -c "GRANT ALL PRIVILEGES ON SCHEMA public TO imagentx_user;"

# 验证数据库创建
echo -e "${YELLOW}🔍 验证数据库创建...${NC}"
if docker exec imagentx-app psql -U imagentx_user -d imagentx -c "SELECT current_database(), current_user;" 2>/dev/null; then
    echo -e "${GREEN}✅ imagentx数据库创建成功！${NC}"
    echo -e "${GREEN}✅ 数据库名：imagentx${NC}"
    echo -e "${GREEN}✅ 用户名：imagentx_user${NC}"
    echo -e "${GREEN}✅ 密码：imagentx_pass${NC}"
else
    echo -e "${RED}❌ 数据库创建失败，请检查日志${NC}"
    exit 1
fi

echo ""
echo -e "${YELLOW}💡 下一步操作：${NC}"
echo -e "  1. 停止当前服务：docker-compose -f docker-compose-internal-db.yml down"
echo -e "  2. 使用新配置启动：docker-compose -f config/docker/docker-compose-imagentx.yml up -d"
echo -e "  3. 或者运行完整迁移：./scripts/database-migration/migrate_to_imagentx.sh"
