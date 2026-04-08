#!/bin/bash

# ImagentX 停止脚本
# 停止所有相关服务

echo "🛑 停止 ImagentX 所有服务..."
echo "=================================="

# 颜色定义
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# 停止前端服务
echo -e "${CYAN}🎨 停止前端服务...${NC}"
if [ -f "pids/frontend.pid" ]; then
    FRONTEND_PID=$(cat pids/frontend.pid)
    if ps -p $FRONTEND_PID > /dev/null 2>&1; then
        echo -e "${YELLOW}⚠️  停止前端进程 (PID: $FRONTEND_PID)...${NC}"
        kill $FRONTEND_PID
        sleep 2
        if ps -p $FRONTEND_PID > /dev/null 2>&1; then
            echo -e "${RED}❌ 强制停止前端进程...${NC}"
            kill -9 $FRONTEND_PID
        fi
        echo -e "${GREEN}✅ 前端服务已停止${NC}"
    else
        echo -e "${YELLOW}⚠️  前端进程不存在${NC}"
    fi
    rm -f pids/frontend.pid
else
    echo -e "${YELLOW}⚠️  前端PID文件不存在${NC}"
fi

# 停止后端服务
echo -e "${CYAN}🔧 停止后端服务...${NC}"
if [ -f "pids/backend.pid" ]; then
    BACKEND_PID=$(cat pids/backend.pid)
    if ps -p $BACKEND_PID > /dev/null 2>&1; then
        echo -e "${YELLOW}⚠️  停止后端进程 (PID: $BACKEND_PID)...${NC}"
        kill $BACKEND_PID
        sleep 2
        if ps -p $BACKEND_PID > /dev/null 2>&1; then
            echo -e "${RED}❌ 强制停止后端进程...${NC}"
            kill -9 $BACKEND_PID
        fi
        echo -e "${GREEN}✅ 后端服务已停止${NC}"
    else
        echo -e "${YELLOW}⚠️  后端进程不存在${NC}"
    fi
    rm -f pids/backend.pid
else
    echo -e "${YELLOW}⚠️  后端PID文件不存在${NC}"
fi

# 检查端口占用
echo -e "${CYAN}🔍 检查端口占用...${NC}"

# 检查端口3000
if lsof -i :3000 > /dev/null 2>&1; then
    echo -e "${YELLOW}⚠️  端口3000仍被占用，正在释放...${NC}"
    lsof -ti :3000 | xargs kill -9
    echo -e "${GREEN}✅ 端口3000已释放${NC}"
fi

# 检查端口3001
if lsof -i :3001 > /dev/null 2>&1; then
    echo -e "${YELLOW}⚠️  端口3001仍被占用，正在释放...${NC}"
    lsof -ti :3001 | xargs kill -9
    echo -e "${GREEN}✅ 端口3001已释放${NC}"
fi

# 检查端口8088
if lsof -i :8088 > /dev/null 2>&1; then
    echo -e "${YELLOW}⚠️  端口8088仍被占用，正在释放...${NC}"
    lsof -ti :8088 | xargs kill -9
    echo -e "${GREEN}✅ 端口8088已释放${NC}"
fi

# 停止Docker服务（可选）
echo -e "${CYAN}🐳 检查Docker服务...${NC}"
read -p "是否停止Docker服务 (PostgreSQL/RabbitMQ)? [y/N]: " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}⚠️  停止Docker服务...${NC}"
    cd config/docker
    docker-compose down
    cd ../..
    echo -e "${GREEN}✅ Docker服务已停止${NC}"
else
    echo -e "${CYAN}ℹ️  保持Docker服务运行${NC}"
fi

echo -e "\n${GREEN}🎉 所有服务已停止！${NC}"
echo "=================================="
echo -e "${CYAN}💡 提示:${NC}"
echo -e "${CYAN}   - 使用 './start-imagentx-complete.sh' 重新启动所有服务${NC}"
echo -e "${CYAN}   - 使用 './start-backend.sh' 只启动后端服务${NC}"
echo -e "${CYAN}   - 使用 'cd apps/frontend && npm run dev' 只启动前端服务${NC}"







