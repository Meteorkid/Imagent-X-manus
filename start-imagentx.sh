#!/bin/bash

# ImagentX 正确启动脚本
# 启动真正的ImagentX前端，而不是agentx容器

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 ImagentX 正确启动脚本${NC}"
echo "=================================="

# 检查Docker是否运行
if ! docker info &> /dev/null; then
    echo -e "${RED}❌ Docker未运行，请先启动Docker Desktop${NC}"
    exit 1
fi

# 停止并删除agentx容器（如果存在）
echo -e "${YELLOW}🛑 清理agentx容器...${NC}"
docker stop agentx-app 2>/dev/null || true
docker rm agentx-app 2>/dev/null || true

# 启动基础服务（PostgreSQL + RabbitMQ）
echo -e "${YELLOW}🚀 启动基础服务（PostgreSQL + RabbitMQ）...${NC}"
docker-compose -f config/docker/docker-compose-fixed.yml up -d postgres rabbitmq

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

# 创建必要的目录
echo -e "${YELLOW}📁 创建必要的目录...${NC}"
mkdir -p pids logs

# 检查前端端口
echo -e "${YELLOW}🔍 检查前端端口...${NC}"
if lsof -i :3000 &> /dev/null; then
    echo -e "${YELLOW}⚠️ 端口3000被占用，正在清理...${NC}"
    lsof -ti :3000 | xargs kill -9 2>/dev/null || true
    sleep 2
fi

# 启动ImagentX前端服务
echo -e "${YELLOW}🎨 启动ImagentX前端服务...${NC}"
cd apps/frontend

if [ -f "package.json" ]; then
    echo -e "${CYAN}安装前端依赖...${NC}"
    npm install --legacy-peer-deps
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ 前端依赖安装成功${NC}"
        echo -e "${CYAN}启动前端开发服务器...${NC}"
        npm run dev &
        FRONTEND_PID=$!
        echo $FRONTEND_PID > ../pids/frontend.pid
        echo -e "${GREEN}✅ ImagentX前端服务已启动 (PID: $FRONTEND_PID)${NC}"
    else
        echo -e "${RED}❌ 前端依赖安装失败${NC}"
        cd ..
        exit 1
    fi
else
    echo -e "${RED}❌ 未找到package.json${NC}"
    cd ..
    exit 1
fi

cd ..

# 等待前端服务启动
echo -e "${YELLOW}⏳ 等待前端服务启动...${NC}"
sleep 15

# 测试前端服务
echo -e "${YELLOW}🔍 测试前端服务...${NC}"
if curl -s http://localhost:3000 &> /dev/null; then
    echo -e "${GREEN}✅ ImagentX前端服务正常${NC}"
else
    echo -e "${YELLOW}⚠️ 前端服务可能还在启动中...${NC}"
fi

echo ""
echo -e "${GREEN}🎯 ImagentX启动完成！${NC}"
echo ""
echo -e "${CYAN}📱 服务访问地址：${NC}"
echo -e "  - ImagentX前端: ${CYAN}http://localhost:3000${NC}"
echo -e "  - 离线游戏演示: ${CYAN}http://localhost:3000/offline-demo${NC}"
echo -e "  - RabbitMQ管理: ${CYAN}http://localhost:15672${NC}"
echo -e "  - PostgreSQL: ${CYAN}localhost:5432${NC}"
echo ""
echo -e "${CYAN}🔑 默认登录信息：${NC}"
echo -e "  - 管理员邮箱: ${CYAN}admin@imagentx.ai${NC}"
echo -e "  - 管理员密码: ${CYAN}admin123${NC}"
echo ""
echo -e "${YELLOW}💡 管理命令：${NC}"
echo -e "  - 查看前端日志: ${CYAN}tail -f logs/frontend.log${NC}"
echo -e "  - 停止前端: ${CYAN}kill \$(cat pids/frontend.pid)${NC}"
echo -e "  - 停止Docker服务: ${CYAN}docker-compose -f config/docker/docker-compose-fixed.yml down${NC}"
echo ""
echo -e "${GREEN}✨ ImagentX启动完成！现在可以访问 http://localhost:3000 开始使用真正的ImagentX平台${NC}"
echo -e "${CYAN}🎮 离线游戏功能已集成，可以访问 /offline-demo 页面测试${NC}"







