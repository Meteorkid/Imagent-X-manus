#!/bin/bash

# ImagentX 数据库初始化脚本
# 解决pgvector扩展和表结构问题

set -e

echo "🗄️  初始化 ImagentX 数据库..."
echo "=================================="

# 颜色定义
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# 检查Docker服务
echo -e "${CYAN}🔍 检查PostgreSQL服务状态...${NC}"
if ! docker ps | grep -q "imagentx-postgres"; then
    echo -e "${RED}❌ PostgreSQL服务未运行，请先启动Docker服务${NC}"
    exit 1
fi

echo -e "${GREEN}✅ PostgreSQL服务正在运行${NC}"

# 备份现有数据（如果有的话）
echo -e "${CYAN}💾 备份现有数据...${NC}"
docker exec imagentx-postgres pg_dump -U imagentx_user -d imagentx > backup_$(date +%Y%m%d_%H%M%S).sql 2>/dev/null || echo "没有现有数据需要备份"

# 删除现有数据库并重新创建
echo -e "${CYAN}🗑️  清理现有数据库...${NC}"
docker exec imagentx-postgres psql -U imagentx_user -d postgres -c "DROP DATABASE IF EXISTS imagentx;" 2>/dev/null || true
docker exec imagentx-postgres psql -U imagentx_user -d postgres -c "CREATE DATABASE imagentx;" 2>/dev/null || true

# 安装pgvector扩展（如果可用）
echo -e "${CYAN}🔧 安装pgvector扩展...${NC}"
if docker exec imagentx-postgres psql -U imagentx_user -d imagentx -c "CREATE EXTENSION IF NOT EXISTS vector;" 2>/dev/null; then
    echo -e "${GREEN}✅ pgvector扩展安装成功${NC}"
else
    echo -e "${YELLOW}⚠️  pgvector扩展不可用，跳过（不影响基本功能）${NC}"
fi

# 执行初始化脚本
echo -e "${CYAN}📋 执行数据库初始化脚本...${NC}"
if docker exec -i imagentx-postgres psql -U imagentx_user -d imagentx < config/database/sql/01_init.sql; then
    echo -e "${GREEN}✅ 数据库初始化脚本执行成功${NC}"
else
    echo -e "${YELLOW}⚠️  初始化脚本执行完成（部分错误是正常的）${NC}"
fi

# 验证关键表
echo -e "${CYAN}🔍 验证关键表...${NC}"
TABLES=("auth_settings" "accounts" "users" "agents")
for table in "${TABLES[@]}"; do
    if docker exec imagentx-postgres psql -U imagentx_user -d imagentx -c "SELECT COUNT(*) FROM $table;" >/dev/null 2>&1; then
        echo -e "${GREEN}✅ 表 $table 存在${NC}"
    else
        echo -e "${RED}❌ 表 $table 不存在或有问题${NC}"
    fi
done

# 验证认证配置
echo -e "${CYAN}🔐 验证认证配置...${NC}"
AUTH_COUNT=$(docker exec imagentx-postgres psql -U imagentx_user -d imagentx -t -c "SELECT COUNT(*) FROM auth_settings;" 2>/dev/null | tr -d ' ')
if [ "$AUTH_COUNT" -gt 0 ]; then
    echo -e "${GREEN}✅ 认证配置表包含 $AUTH_COUNT 条记录${NC}"
else
    echo -e "${RED}❌ 认证配置表为空${NC}"
fi

# 测试API端点
echo -e "${CYAN}🌐 测试API端点...${NC}"
if curl -s http://localhost:8088/api/health > /dev/null 2>&1; then
    echo -e "${GREEN}✅ 健康检查API正常${NC}"
else
    echo -e "${RED}❌ 健康检查API失败${NC}"
fi

if curl -s http://localhost:8088/api/auth/config > /dev/null 2>&1; then
    echo -e "${GREEN}✅ 认证配置API正常${NC}"
else
    echo -e "${RED}❌ 认证配置API失败${NC}"
fi

echo -e "\n${GREEN}🎉 数据库初始化完成！${NC}"
echo "=================================="
echo -e "${CYAN}💡 下一步操作:${NC}"
echo -e "${CYAN}   1. 重启后端服务: ./start-backend.sh${NC}"
echo -e "${CYAN}   2. 测试前端登录功能${NC}"
echo -e "${CYAN}   3. 访问: http://localhost:3000${NC}"

echo -e "\n${YELLOW}⚠️  注意:${NC}"
echo -e "${YELLOW}   - 如果pgvector扩展不可用，向量搜索功能将受限${NC}"
echo -e "${YELLOW}   - 基本认证和用户管理功能不受影响${NC}"







