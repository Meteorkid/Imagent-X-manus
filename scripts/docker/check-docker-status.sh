#!/bin/bash

# ImagentX Docker 服务状态检查脚本

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${BLUE}📊 ImagentX Docker 服务状态检查${NC}"
echo "=================================="

# 检查Docker是否运行
if ! docker info &> /dev/null; then
    echo -e "${RED}❌ Docker未运行${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Docker正在运行${NC}"

# 检查容器状态
echo ""
echo -e "${CYAN}🐳 容器状态:${NC}"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep imagentx || echo -e "${YELLOW}⚠️  未找到ImagentX相关容器${NC}"

# 检查网络
echo ""
echo -e "${CYAN}🌐 网络状态:${NC}"
docker network ls | grep imagentx || echo -e "${YELLOW}⚠️  未找到ImagentX网络${NC}"

# 检查卷
echo ""
echo -e "${CYAN}💾 数据卷状态:${NC}"
docker volume ls | grep imagentx || echo -e "${YELLOW}⚠️  未找到ImagentX数据卷${NC}"

# 检查端口占用
echo ""
echo -e "${CYAN}🔌 端口占用情况:${NC}"
echo "PostgreSQL (5432): $(lsof -i :5432 2>/dev/null | wc -l || echo 0) 个连接"
echo "RabbitMQ (5672): $(lsof -i :5672 2>/dev/null | wc -l || echo 0) 个连接"
echo "RabbitMQ管理界面 (15672): $(lsof -i :15672 2>/dev/null | wc -l || echo 0) 个连接"

# 测试服务连接
echo ""
echo -e "${CYAN}🔍 服务连接测试:${NC}"

# 测试PostgreSQL
if docker exec imagentx-postgres pg_isready -U imagentx_user -d imagentx &> /dev/null 2>&1; then
    echo -e "${GREEN}✅ PostgreSQL 连接正常${NC}"
else
    echo -e "${RED}❌ PostgreSQL 连接失败${NC}"
fi

# 测试RabbitMQ
if docker exec imagentx-rabbitmq rabbitmq-diagnostics ping &> /dev/null 2>&1; then
    echo -e "${GREEN}✅ RabbitMQ 连接正常${NC}"
else
    echo -e "${RED}❌ RabbitMQ 连接失败${NC}"
fi

# 测试RabbitMQ管理界面
if curl -s http://localhost:15672/api/overview &> /dev/null; then
    echo -e "${GREEN}✅ RabbitMQ管理界面可访问${NC}"
else
    echo -e "${RED}❌ RabbitMQ管理界面不可访问${NC}"
fi

echo ""
echo -e "${YELLOW}💡 服务访问地址:${NC}"
echo -e "  PostgreSQL: localhost:5432"
echo -e "  RabbitMQ: localhost:5672"
echo -e "  RabbitMQ管理界面: http://localhost:15672 (用户名/密码: guest/guest)"
