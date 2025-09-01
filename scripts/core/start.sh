#!/bin/bash

# ImagentX 统一启动脚本
# 整合所有启动选项，提供灵活的服务启动方式

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 全局变量
LOG_DIR="logs"
PIDS_DIR="pids"
MAX_RETRIES=3
RETRY_INTERVAL=10

# 创建必要的目录
mkdir -p $LOG_DIR $PIDS_DIR

# 显示帮助信息
show_help() {
    echo -e "${BLUE}🚀 ImagentX 统一启动脚本${NC}"
    echo "=================================="
    echo -e "${GREEN}用法: ./start.sh [选项]${NC}"
    echo ""
    echo -e "${CYAN}启动模式:${NC}"
    echo -e "  ${GREEN}--quick${NC}        快速启动（仅前端，跳过Docker）"
    echo -e "  ${GREEN}--local${NC}        本地开发（后端+前端，跳过Docker）"
    echo -e "  ${GREEN}--core${NC}         核心服务（后端+前端+基础服务）"
    echo -e "  ${GREEN}--full${NC}         完整服务（包含监控、MCP网关等）"
    echo -e "  ${GREEN}--docker${NC}       仅Docker服务（数据库+消息队列）"
    echo -e "  ${GREEN}--mac${NC}          macOS优化版（Docker Compose）"
    echo ""
    echo -e "${CYAN}其他选项:${NC}"
    echo -e "  ${GREEN}--help${NC}         显示此帮助信息"
    echo -e "  ${GREEN}--status${NC}       检查服务状态"
    echo -e "  ${GREEN}--clean${NC}        清理环境"
    echo ""
    echo -e "${CYAN}示例:${NC}"
    echo -e "  ./start.sh --quick    # 快速启动"
    echo -e "  ./start.sh --local    # 本地开发"
    echo -e "  ./start.sh --full     # 完整服务"
    echo ""
}

# 检查系统环境
check_system() {
    echo -e "${BLUE}📋 系统环境检查${NC}"
    echo "--------------------------------"
    
    # 操作系统信息
    echo -e "${CYAN}操作系统:${NC} $(uname -s) $(uname -r)"
    echo -e "${CYAN}架构:${NC} $(uname -m)"
    
    # 内存信息
    if [[ "$OSTYPE" == "darwin"* ]]; then
        MEMORY=$(sysctl -n hw.memsize 2>/dev/null | awk '{print $1/1024/1024/1024 "GB"}' || echo "未知")
    else
        MEMORY=$(free -h 2>/dev/null | awk 'NR==2{print $2}' || echo "未知")
    fi
    echo -e "${CYAN}内存:${NC} $MEMORY"
    
    # Java检查
    if command -v java &> /dev/null; then
        JAVA_VERSION=$(java -version 2>&1 | head -n 1 | cut -d'"' -f2)
        echo -e "${GREEN}✅ Java版本: $JAVA_VERSION${NC}"
    else
        echo -e "${RED}❌ Java未安装${NC}"
        return 1
    fi
    
    # Node.js检查
    if command -v node &> /dev/null; then
        NODE_VERSION=$(node --version)
        echo -e "${GREEN}✅ Node.js版本: $NODE_VERSION${NC}"
    else
        echo -e "${RED}❌ Node.js未安装${NC}"
        return 1
    fi
    
    # npm检查
    if command -v npm &> /dev/null; then
        NPM_VERSION=$(npm --version)
        echo -e "${GREEN}✅ npm版本: $NPM_VERSION${NC}"
    else
        echo -e "${RED}❌ npm未安装${NC}"
        return 1
    fi
    
    # Docker检查
    if command -v docker &> /dev/null; then
        if docker info &> /dev/null; then
            DOCKER_VERSION=$(docker --version | cut -d' ' -f3 | cut -d',' -f1)
            echo -e "${GREEN}✅ Docker版本: $DOCKER_VERSION${NC}"
        else
            echo -e "${YELLOW}⚠️  Docker已安装但服务未运行${NC}"
        fi
    else
        echo -e "${YELLOW}⚠️  Docker未安装（某些模式需要）${NC}"
    fi
    
    echo ""
}

# 检查端口占用
check_port() {
    local port=$1
    local service=$2
    if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1; then
        echo -e "${YELLOW}⚠️  端口 $port 已被占用，$service 可能已在运行${NC}"
        return 1
    else
        echo -e "${GREEN}✅ 端口 $port 可用${NC}"
        return 0
    fi
}

# 等待服务启动
wait_for_service() {
    local url=$1
    local service=$2
    local max_attempts=30
    local attempt=1
    
    echo -e "${CYAN}⏳ 等待 $service 启动...${NC}"
    
    while [ $attempt -le $max_attempts ]; do
        if curl -s "$url" >/dev/null 2>&1; then
            echo -e "${GREEN}✅ $service 启动成功！${NC}"
            return 0
        fi
        
        echo -n "."
        sleep 2
        attempt=$((attempt + 1))
    done
    
    echo -e "${RED}❌ $service 启动超时${NC}"
    return 1
}

# 快速启动模式
start_quick() {
    echo -e "${BLUE}🚀 快速启动模式${NC}"
    echo "--------------------------------"
    
    # 检查端口
    check_port 3000 "前端服务"
    
    # 启动前端服务
    echo -e "${CYAN}🎨 启动前端服务...${NC}"
    cd apps/frontend
    
    if [ -f "package.json" ]; then
        echo -e "${CYAN}安装前端依赖...${NC}"
        npm install --legacy-peer-deps
        
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✅ 前端依赖安装成功${NC}"
            echo -e "${CYAN}启动前端开发服务器...${NC}"
            npm run dev &
            FRONTEND_PID=$!
            echo $FRONTEND_PID > ../$PIDS_DIR/frontend.pid
            echo -e "${GREEN}✅ 前端服务已启动 (PID: $FRONTEND_PID)${NC}"
        else
            echo -e "${RED}❌ 前端依赖安装失败${NC}"
            return 1
        fi
    else
        echo -e "${RED}❌ 未找到package.json${NC}"
        return 1
    fi
    
    cd ..
    
    echo ""
    echo -e "${GREEN}🎯 快速启动完成！${NC}"
    echo -e "${CYAN}前端服务:${NC} http://localhost:3000"
    echo -e "${YELLOW}注意: 后端服务需要手动启动${NC}"
    echo -e "${CYAN}后端启动命令:${NC} cd apps/backend && ./mvnw spring-boot:run"
}

# 本地开发模式
start_local() {
    echo -e "${BLUE}🚀 本地开发模式${NC}"
    echo "--------------------------------"
    
    # 检查端口
    check_port 8080 "后端服务"
    check_port 3000 "前端服务"
    
    # 启动后端服务
    echo -e "${CYAN}🔧 启动后端服务...${NC}"
    cd apps/backend
    
    if [ -f "mvnw" ]; then
        chmod +x mvnw
        echo -e "${CYAN}构建后端项目...${NC}"
        ./mvnw clean compile
        
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✅ 后端构建成功${NC}"
            echo -e "${CYAN}启动后端开发服务器...${NC}"
            ./mvnw spring-boot:run &
            BACKEND_PID=$!
            echo $BACKEND_PID > ../$PIDS_DIR/backend.pid
            echo -e "${GREEN}✅ 后端服务已启动 (PID: $BACKEND_PID)${NC}"
        else
            echo -e "${RED}❌ 后端构建失败${NC}"
            cd ..
            return 1
        fi
    else
        echo -e "${RED}❌ 未找到Maven Wrapper${NC}"
        cd ..
        return 1
    fi
    
    cd ..
    
    # 启动前端服务
    echo -e "${CYAN}🎨 启动前端服务...${NC}"
    cd apps/frontend
    
    if [ -f "package.json" ]; then
        echo -e "${CYAN}安装前端依赖...${NC}"
        npm install
        
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✅ 前端依赖安装成功${NC}"
            echo -e "${CYAN}启动前端开发服务器...${NC}"
            npm run dev &
            FRONTEND_PID=$!
            echo $FRONTEND_PID > ../$PIDS_DIR/frontend.pid
            echo -e "${GREEN}✅ 前端服务已启动 (PID: $FRONTEND_PID)${NC}"
        else
            echo -e "${RED}❌ 前端依赖安装失败${NC}"
            cd ..
            return 1
        fi
    else
        echo -e "${RED}❌ 未找到package.json${NC}"
        cd ..
        return 1
    fi
    
    cd ..
    
    # 等待服务启动
    sleep 5
    wait_for_service "http://localhost:8080/actuator/health" "后端服务" || true
    wait_for_service "http://localhost:3000" "前端服务" || true
    
    echo ""
    echo -e "${GREEN}🎯 本地开发模式启动完成！${NC}"
    echo -e "${CYAN}后端服务:${NC} http://localhost:8080"
    echo -e "${CYAN}前端服务:${NC} http://localhost:3000"
}

# Docker服务启动
start_docker() {
    echo -e "${BLUE}🐳 Docker服务启动${NC}"
    echo "--------------------------------"
    
    if ! command -v docker &> /dev/null; then
        echo -e "${RED}❌ Docker未安装${NC}"
        return 1
    fi
    
    if ! docker info &> /dev/null; then
        echo -e "${RED}❌ Docker服务未运行${NC}"
        return 1
    fi
    
    # 检查数据目录
    if [ ! -d "docs/sql" ]; then
        echo -e "${CYAN}创建SQL初始化文件...${NC}"
        mkdir -p docs/sql
        
        cat > docs/sql/00_install_pgvector.sql << EOF
CREATE EXTENSION IF NOT EXISTS vector;
EOF
        
        cat > docs/sql/01_init.sql << EOF
-- 基础表结构初始化
EOF
    fi
    
    # 拉取镜像
    echo -e "${CYAN}拉取Docker镜像...${NC}"
    docker pull postgres:15
    docker pull rabbitmq:3.12-management-alpine
    
    # 启动基础服务
    echo -e "${CYAN}启动基础服务...${NC}"
    docker-compose -f docker-compose.simple.yml up -d
    
    echo ""
    echo -e "${GREEN}✅ Docker服务启动完成！${NC}"
    echo -e "${CYAN}PostgreSQL:${NC} localhost:5432"
    echo -e "${CYAN}RabbitMQ:${NC} localhost:5672"
    echo -e "${CYAN}RabbitMQ管理界面:${NC} http://localhost:15672"
}

# 核心服务启动
start_core() {
    echo -e "${BLUE}🚀 核心服务启动${NC}"
    echo "--------------------------------"
    
    # 先启动Docker服务
    start_docker
    
    # 等待数据库启动
    echo -e "${CYAN}等待数据库启动...${NC}"
    sleep 10
    
    # 启动后端和前端
    start_local
}

# 完整服务启动
start_full() {
    echo -e "${BLUE}🚀 完整服务启动${NC}"
    echo "--------------------------------"
    
    # 启动核心服务
    start_core
    
    # 启动MCP网关
    echo -e "${CYAN}🔗 启动MCP网关...${NC}"
    if [ -f "start-mcp-gateway.sh" ]; then
        ./start-mcp-gateway.sh &
        MCP_PID=$!
        echo $MCP_PID > $PIDS_DIR/mcp.pid
        echo -e "${GREEN}✅ MCP网关已启动 (PID: $MCP_PID)${NC}"
    else
        echo -e "${YELLOW}⚠️  MCP网关脚本不存在${NC}"
    fi
    
    # 启动监控服务
    echo -e "${CYAN}📊 启动监控服务...${NC}"
    if [ -f "docker-compose.monitoring.yml" ]; then
        docker-compose -f docker-compose.monitoring.yml up -d
        echo -e "${GREEN}✅ 监控服务已启动${NC}"
    else
        echo -e "${YELLOW}⚠️  监控配置文件不存在${NC}"
    fi
    
    echo ""
    echo -e "${GREEN}🎯 完整服务启动完成！${NC}"
    echo -e "${CYAN}后端服务:${NC} http://localhost:8080"
    echo -e "${CYAN}前端服务:${NC} http://localhost:3000"
    echo -e "${CYAN}MCP网关:${NC} http://localhost:8081"
    echo -e "${CYAN}监控服务:${NC} http://localhost:9090"
}

# macOS优化启动
start_mac() {
    echo -e "${BLUE}🍎 macOS优化启动${NC}"
    echo "--------------------------------"
    
    if [ ! -f "docker-compose.mac.yml" ]; then
        echo -e "${RED}❌ macOS配置文件不存在${NC}"
        return 1
    fi
    
    # 检测端口
    if [ -f "detect-ports.sh" ]; then
        ./detect-ports.sh
    fi
    
    # 启动服务
    echo -e "${CYAN}启动macOS优化服务...${NC}"
    docker-compose -f docker-compose.mac.yml --env-file .env.mac up -d
    
    echo ""
    echo -e "${GREEN}✅ macOS优化启动完成！${NC}"
    if [ -f ".env.mac" ]; then
        echo -e "${CYAN}前端:${NC} http://localhost:$(grep FRONTEND_PORT .env.mac | cut -d'=' -f2)"
        echo -e "${CYAN}后端:${NC} http://localhost:$(grep BACKEND_PORT .env.mac | cut -d'=' -f2)/api"
        echo -e "${CYAN}Adminer:${NC} http://localhost:$(grep ADMINER_PORT .env.mac | cut -d'=' -f2)"
    fi
}

# 检查服务状态
check_status() {
    echo -e "${BLUE}📊 服务状态检查${NC}"
    echo "--------------------------------"
    
    # 检查进程
    echo -e "${CYAN}进程状态:${NC}"
    if [ -f "$PIDS_DIR/backend.pid" ]; then
        BACKEND_PID=$(cat $PIDS_DIR/backend.pid)
        if ps -p $BACKEND_PID > /dev/null 2>&1; then
            echo -e "${GREEN}✅ 后端服务运行中 (PID: $BACKEND_PID)${NC}"
        else
            echo -e "${RED}❌ 后端服务未运行${NC}"
        fi
    else
        echo -e "${YELLOW}⚠️  后端服务PID文件不存在${NC}"
    fi
    
    if [ -f "$PIDS_DIR/frontend.pid" ]; then
        FRONTEND_PID=$(cat $PIDS_DIR/frontend.pid)
        if ps -p $FRONTEND_PID > /dev/null 2>&1; then
            echo -e "${GREEN}✅ 前端服务运行中 (PID: $FRONTEND_PID)${NC}"
        else
            echo -e "${RED}❌ 前端服务未运行${NC}"
        fi
    else
        echo -e "${YELLOW}⚠️  前端服务PID文件不存在${NC}"
    fi
    
    # 检查端口
    echo -e "${CYAN}端口状态:${NC}"
    ports=(8080 3000 8081 9090 5432 5672)
    for port in "${ports[@]}"; do
        if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1; then
            echo -e "${GREEN}✅ 端口 $port 被占用${NC}"
        else
            echo -e "${YELLOW}⚠️  端口 $port 可用${NC}"
        fi
    done
    
    # 检查Docker容器
    if command -v docker &> /dev/null && docker info &> /dev/null; then
        echo -e "${CYAN}Docker容器状态:${NC}"
        docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
    fi
}

# 清理环境
clean_environment() {
    echo -e "${BLUE}🧹 清理环境${NC}"
    echo "--------------------------------"
    
    # 停止进程
    if [ -f "$PIDS_DIR/backend.pid" ]; then
        BACKEND_PID=$(cat $PIDS_DIR/backend.pid)
        if ps -p $BACKEND_PID > /dev/null 2>&1; then
            kill $BACKEND_PID
            echo -e "${GREEN}✅ 后端服务已停止${NC}"
        fi
        rm -f $PIDS_DIR/backend.pid
    fi
    
    if [ -f "$PIDS_DIR/frontend.pid" ]; then
        FRONTEND_PID=$(cat $PIDS_DIR/frontend.pid)
        if ps -p $FRONTEND_PID > /dev/null 2>&1; then
            kill $FRONTEND_PID
            echo -e "${GREEN}✅ 前端服务已停止${NC}"
        fi
        rm -f $PIDS_DIR/frontend.pid
    fi
    
    # 停止Docker容器
    if command -v docker &> /dev/null; then
        docker-compose -f docker-compose.simple.yml down 2>/dev/null || true
        docker-compose -f docker-compose.mac.yml down 2>/dev/null || true
        echo -e "${GREEN}✅ Docker容器已停止${NC}"
    fi
    
    # 清理目录
    rm -rf $PIDS_DIR
    echo -e "${GREEN}✅ PID目录已清理${NC}"
    
    echo -e "${GREEN}🎯 环境清理完成！${NC}"
}

# 主函数
main() {
    case "${1:-}" in
        --quick)
            check_system
            start_quick
            ;;
        --local)
            check_system
            start_local
            ;;
        --core)
            check_system
            start_core
            ;;
        --full)
            check_system
            start_full
            ;;
        --docker)
            start_docker
            ;;
        --mac)
            start_mac
            ;;
        --status)
            check_status
            ;;
        --clean)
            clean_environment
            ;;
        --help|"")
            show_help
            ;;
        *)
            echo -e "${RED}❌ 未知选项: $1${NC}"
            echo ""
            show_help
            exit 1
            ;;
    esac
}

# 执行主函数
main "$@"
