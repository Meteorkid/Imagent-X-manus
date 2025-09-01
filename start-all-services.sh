#!/bin/bash

# ImagentX 完整服务启动脚本

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${BLUE}🐳 ImagentX 完整服务启动脚本${NC}"
echo "=================================="

# 检查Docker是否运行
if ! docker info &> /dev/null; then
    echo -e "${RED}❌ Docker未运行，请先启动Docker Desktop${NC}"
    exit 1
fi

# 停止现有容器
echo -e "${YELLOW}🛑 停止现有容器...${NC}"
docker-compose -f docker-compose-fixed.yml down 2>/dev/null || true

# 清理网络
echo -e "${YELLOW}🧹 清理网络...${NC}"
docker network prune -f 2>/dev/null || true

# 启动基础服务
echo -e "${YELLOW}🚀 启动基础服务（PostgreSQL + RabbitMQ）...${NC}"
docker-compose -f docker-compose-fixed.yml up -d postgres rabbitmq

# 等待基础服务启动
echo -e "${YELLOW}⏳ 等待基础服务启动...${NC}"
sleep 20

# 检查基础服务状态
echo -e "${YELLOW}📊 检查基础服务状态...${NC}"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# 测试数据库连接
echo -e "${YELLOW}🔍 测试数据库连接...${NC}"
if docker exec imagentx-postgres pg_isready -U imagentx_user -d imagentx &> /dev/null; then
    echo -e "${GREEN}✅ PostgreSQL 连接正常${NC}"
else
    echo -e "${RED}❌ PostgreSQL 连接失败${NC}"
    echo -e "${YELLOW}⏳ 等待数据库完全启动...${NC}"
    sleep 10
fi

# 测试RabbitMQ连接
echo -e "${YELLOW}🔍 测试RabbitMQ连接...${NC}"
if docker exec imagentx-rabbitmq rabbitmq-diagnostics ping &> /dev/null; then
    echo -e "${GREEN}✅ RabbitMQ 连接正常${NC}"
else
    echo -e "${RED}❌ RabbitMQ 连接失败${NC}"
    echo -e "${YELLOW}⏳ 等待RabbitMQ完全启动...${NC}"
    sleep 10
fi

# 启动应用服务
echo -e "${YELLOW}🚀 启动Imagent X应用服务...${NC}"
docker-compose -f docker-compose-fixed.yml up -d imagentx-app

# 等待应用服务启动
echo -e "${YELLOW}⏳ 等待应用服务启动...${NC}"
sleep 30

# 检查所有服务状态
echo -e "${YELLOW}📊 检查所有服务状态...${NC}"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# 测试前端服务
echo -e "${YELLOW}🔍 测试前端服务...${NC}"
if curl -s http://localhost:3000 &> /dev/null; then
    echo -e "${GREEN}✅ 前端服务正常${NC}"
else
    echo -e "${YELLOW}⚠️ 前端服务可能还在启动中...${NC}"
fi

# 测试后端API
echo -e "${YELLOW}🔍 测试后端API...${NC}"
if curl -s http://localhost:8088/api/health &> /dev/null; then
    echo -e "${GREEN}✅ 后端API正常${NC}"
else
    echo -e "${YELLOW}⚠️ 后端API可能还在启动中...${NC}"
fi

echo ""
echo -e "${GREEN}🎯 所有服务启动完成！${NC}"
echo ""
echo -e "${CYAN}📱 服务访问地址：${NC}"
echo -e "  - 前端界面: ${CYAN}http://localhost:3000${NC}"
echo -e "  - 后端API: ${CYAN}http://localhost:8088/api${NC}"
echo -e "  - RabbitMQ管理: ${CYAN}http://localhost:15672${NC}"
echo -e "  - PostgreSQL: ${CYAN}localhost:5432${NC}"
echo ""
echo -e "${CYAN}🔑 默认登录信息：${NC}"
echo -e "  - 管理员邮箱: ${CYAN}admin@imagentx.ai${NC}"
echo -e "  - 管理员密码: ${CYAN}admin123${NC}"
echo ""
echo -e "${YELLOW}💡 管理命令：${NC}"
echo -e "  - 查看日志: ${CYAN}docker-compose -f docker-compose-fixed.yml logs${NC}"
echo -e "  - 停止服务: ${CYAN}docker-compose -f docker-compose-fixed.yml down${NC}"
echo -e "  - 重启服务: ${CYAN}docker-compose -f docker-compose-fixed.yml restart${NC}"
echo ""
echo -e "${GREEN}✨ 服务启动完成！现在可以访问 http://localhost:3000 开始使用ImagentX${NC}"
