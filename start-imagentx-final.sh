#!/bin/bash

# ImagentX 最终启动脚本
# 确保前后端服务都正常运行

set -e

echo "🚀 启动 ImagentX 完整项目..."
echo "=================================="

# 颜色定义
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# 检查Docker服务
echo -e "${CYAN}🔍 检查Docker服务状态...${NC}"
if ! docker ps | grep -q "imagentx-postgres"; then
    echo -e "${YELLOW}⚠️  PostgreSQL服务未运行，正在启动...${NC}"
    cd config/docker
    docker-compose up -d postgres rabbitmq
    cd ../..
else
    echo -e "${GREEN}✅ PostgreSQL和RabbitMQ服务已运行${NC}"
fi

# 创建必要的目录
echo -e "${CYAN}📁 创建必要的目录...${NC}"
mkdir -p pids logs

# 检查端口占用
echo -e "${CYAN}🔍 检查端口占用...${NC}"

# 检查端口3000
if lsof -i :3000 > /dev/null 2>&1; then
    echo -e "${YELLOW}⚠️  端口3000被占用，正在释放...${NC}"
    lsof -ti :3000 | xargs kill -9
    sleep 2
fi

# 检查端口3001
if lsof -i :3001 > /dev/null 2>&1; then
    echo -e "${YELLOW}⚠️  端口3001被占用，正在释放...${NC}"
    lsof -ti :3001 | xargs kill -9
    sleep 2
fi

# 检查端口8088
if lsof -i :8088 > /dev/null 2>&1; then
    echo -e "${YELLOW}⚠️  端口8088被占用，正在释放...${NC}"
    lsof -ti :8088 | xargs kill -9
    sleep 2
fi

# 启动后端服务
echo -e "${CYAN}🔧 启动后端服务...${NC}"
export JAVA_HOME=/opt/homebrew/opt/openjdk@17
export PATH=$JAVA_HOME/bin:$PATH

cd apps/backend
echo -e "${YELLOW}📋 Java版本: $(java -version 2>&1 | head -1)${NC}"

# 编译和启动后端
echo -e "${CYAN}🔨 编译后端项目...${NC}"
./mvnw clean compile
echo -e "${CYAN}📦 打包后端项目...${NC}"
./mvnw package -DskipTests

echo -e "${CYAN}🎯 启动Spring Boot应用...${NC}"
./mvnw spring-boot:run > ../../logs/backend.log 2>&1 &
BACKEND_PID=$!
echo $BACKEND_PID > ../../pids/backend.pid

cd ../..

# 等待后端启动
echo -e "${CYAN}⏳ 等待后端服务启动...${NC}"
for i in {1..30}; do
    if curl -s http://localhost:8088/api/health > /dev/null 2>&1; then
        echo -e "${GREEN}✅ 后端服务启动成功！${NC}"
        break
    fi
    if [ $i -eq 30 ]; then
        echo -e "${RED}❌ 后端服务启动超时${NC}"
        exit 1
    fi
    echo -n "."
    sleep 2
done

# 验证后端API
echo -e "${CYAN}🔍 验证后端API...${NC}"
if curl -s http://localhost:8088/api/auth/config > /dev/null 2>&1; then
    echo -e "${GREEN}✅ 认证配置API正常${NC}"
else
    echo -e "${RED}❌ 认证配置API失败${NC}"
fi

# 启动前端服务
echo -e "${CYAN}🎨 启动前端服务...${NC}"
cd apps/frontend

# 检查依赖
if [ ! -d "node_modules" ]; then
    echo -e "${YELLOW}📦 安装前端依赖...${NC}"
    npm install --legacy-peer-deps
fi

echo -e "${CYAN}🚀 启动Next.js开发服务器...${NC}"
npm run dev > ../../logs/frontend.log 2>&1 &
FRONTEND_PID=$!
echo $FRONTEND_PID > ../../pids/frontend.pid

cd ../..

# 等待前端启动
echo -e "${CYAN}⏳ 等待前端服务启动...${NC}"
for i in {1..20}; do
    if curl -s http://localhost:3000 > /dev/null 2>&1; then
        echo -e "${GREEN}✅ 前端服务启动成功！${NC}"
        break
    fi
    if [ $i -eq 20 ]; then
        echo -e "${YELLOW}⚠️  前端服务可能启动在端口3001${NC}"
        break
    fi
    echo -n "."
    sleep 2
done

# 验证前端内容
echo -e "${CYAN}🔍 验证前端内容...${NC}"
FRONTEND_CONTENT=$(curl -s http://localhost:3000 2>/dev/null || curl -s http://localhost:3001 2>/dev/null || echo "")
if echo "$FRONTEND_CONTENT" | grep -q "Imagent X"; then
    echo -e "${GREEN}✅ 前端显示正确的品牌名称: Imagent X${NC}"
else
    echo -e "${YELLOW}⚠️  前端内容验证失败${NC}"
fi

# 显示服务状态
echo -e "\n${GREEN}🎉 ImagentX 项目启动完成！${NC}"
echo "=================================="
echo -e "${CYAN}🌐 前端地址: http://localhost:3000 (或3001)${NC}"
echo -e "${CYAN}🔧 后端地址: http://localhost:8088${NC}"
echo -e "${CYAN}🔍 健康检查: http://localhost:8088/api/health${NC}"
echo -e "${CYAN}🔐 认证配置: http://localhost:8088/api/auth/config${NC}"
echo -e "${CYAN}🎮 离线游戏: http://localhost:3000/offline-demo${NC}"
echo -e "${CYAN}📊 进程ID: 前端($FRONTEND_PID) 后端($BACKEND_PID)${NC}"
echo -e "${CYAN}📁 日志文件: logs/frontend.log, logs/backend.log${NC}"
echo -e "${CYAN}📁 进程ID: pids/frontend.pid, pids/backend.pid${NC}"

echo -e "\n${YELLOW}💡 提示:${NC}"
echo -e "${YELLOW}   - 使用 'tail -f logs/frontend.log' 查看前端日志${NC}"
echo -e "${YELLOW}   - 使用 'tail -f logs/backend.log' 查看后端日志${NC}"
echo -e "${YELLOW}   - 使用 './stop-imagentx.sh' 停止所有服务${NC}"

echo -e "\n${GREEN}✨ 现在可以正常登录和使用ImagentX了！${NC}"
echo -e "${CYAN}🔐 支持的登录方式:${NC}"
echo -e "${CYAN}   - 普通登录 (邮箱/手机号密码)${NC}"
echo -e "${CYAN}   - GitHub登录${NC}"
echo -e "${CYAN}   - 敲鸭社区登录${NC}"
echo -e "${CYAN}   - 新用户注册功能已启用${NC}"







