#!/bin/bash

# ImagentX Docker 服务启动脚本

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🐳 ImagentX Docker 服务启动脚本${NC}"
echo "=================================="

# 检查Docker是否运行
if ! docker info &> /dev/null; then
    echo -e "${RED}❌ Docker未运行，请先启动Docker Desktop${NC}"
    exit 1
fi

# 检查配置文件
if [ ! -f "deploy/docker/working-docker-compose.yml" ]; then
    echo -e "${RED}❌ 配置文件 deploy/docker/working-docker-compose.yml 不存在${NC}"
    exit 1
fi

# 停止现有容器
echo -e "${YELLOW}🛑 停止现有容器...${NC}"
docker-compose -f deploy/docker/working-docker-compose.yml down 2>/dev/null || true

# 启动基础服务
echo -e "${YELLOW}🚀 启动基础服务（PostgreSQL + RabbitMQ）...${NC}"
docker-compose -f deploy/docker/working-docker-compose.yml up -d postgres rabbitmq

# 等待服务启动
echo -e "${YELLOW}⏳ 等待服务启动...${NC}"
sleep 15

# 检查服务状态
echo -e "${YELLOW}📊 检查服务状态...${NC}"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# 测试数据库连接
echo -e "${YELLOW}🔍 测试数据库连接...${NC}"
if docker exec imagentx-postgres pg_isready -U imagentx_user -d imagentx &> /dev/null; then
    echo -e "${GREEN}✅ PostgreSQL 连接正常${NC}"
else
    echo -e "${RED}❌ PostgreSQL 连接失败${NC}"
fi

# 测试RabbitMQ连接
echo -e "${YELLOW}🔍 测试RabbitMQ连接...${NC}"
if docker exec imagentx-rabbitmq rabbitmq-diagnostics ping &> /dev/null; then
    echo -e "${GREEN}✅ RabbitMQ 连接正常${NC}"
else
    echo -e "${RED}❌ RabbitMQ 连接失败${NC}"
fi

echo ""
echo -e "${GREEN}🎯 Docker 服务启动完成！${NC}"
echo -e "${CYAN}PostgreSQL:${NC} localhost:5432"
echo -e "${CYAN}RabbitMQ:${NC} localhost:5672"
echo -e "${CYAN}RabbitMQ管理界面:${NC} http://localhost:15672"
echo ""
echo -e "${YELLOW}💡 提示：${NC}"
echo -e "  - 使用 'docker-compose -f deploy/docker/working-docker-compose.yml logs' 查看日志"
echo -e "  - 使用 'docker-compose -f deploy/docker/working-docker-compose.yml down' 停止服务"
echo -e "  - 使用 'docker-compose -f deploy/docker/working-docker-compose.yml restart' 重启服务"
