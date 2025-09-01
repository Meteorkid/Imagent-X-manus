#!/bin/bash

# ImagentX 统一停止脚本
# 整合所有停止功能，提供灵活的停止选项

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

PIDS_DIR="pids"

echo -e "${BLUE}🛑 ImagentX 统一停止脚本${NC}"
echo "================================"

# 显示帮助信息
show_help() {
    echo -e "${GREEN}用法: ./stop.sh [选项]${NC}"
    echo ""
    echo -e "${CYAN}停止选项:${NC}"
    echo -e "  ${GREEN}--all${NC}         停止所有服务（默认）"
    echo -e "  ${GREEN}--backend${NC}     仅停止后端服务"
    echo -e "  ${GREEN}--frontend${NC}    仅停止前端服务"
    echo -e "  ${GREEN}--docker${NC}      仅停止Docker服务"
    echo -e "  ${GREEN}--force${NC}       强制停止所有进程"
    echo -e "  ${GREEN}--clean${NC}       清理所有文件和日志"
    echo -e "  ${GREEN}--help${NC}        显示此帮助信息"
    echo ""
    echo -e "${CYAN}示例:${NC}"
    echo -e "  ./stop.sh              # 停止所有服务"
    echo -e "  ./stop.sh --backend    # 仅停止后端"
    echo -e "  ./stop.sh --force      # 强制停止"
    echo ""
}

# 停止进程函数
stop_process() {
    local pid_file=$1
    local service_name=$2
    
    if [ -f "$pid_file" ]; then
        local pid=$(cat "$pid_file")
        if ps -p $pid > /dev/null 2>&1; then
            echo -e "${CYAN}停止 $service_name (PID: $pid)...${NC}"
            kill $pid
            sleep 2
            
            # 检查是否还在运行
            if ps -p $pid > /dev/null 2>&1; then
                echo -e "${YELLOW}强制停止 $service_name...${NC}"
                kill -9 $pid
            fi
            
            rm -f "$pid_file"
            echo -e "${GREEN}✅ $service_name 已停止${NC}"
        else
            echo -e "${YELLOW}⚠️  $service_name 进程不存在${NC}"
            rm -f "$pid_file"
        fi
    else
        echo -e "${YELLOW}⚠️  $service_name PID文件不存在${NC}"
    fi
}

# 停止后端服务
stop_backend() {
    echo -e "${BLUE}🔧 停止后端服务${NC}"
    stop_process "$PIDS_DIR/backend.pid" "后端服务"
}

# 停止前端服务
stop_frontend() {
    echo -e "${BLUE}🎨 停止前端服务${NC}"
    stop_process "$PIDS_DIR/frontend.pid" "前端服务"
}

# 停止MCP网关
stop_mcp() {
    echo -e "${BLUE}🔗 停止MCP网关${NC}"
    stop_process "$PIDS_DIR/mcp.pid" "MCP网关"
}

# 停止Docker服务
stop_docker() {
    echo -e "${BLUE}🐳 停止Docker服务${NC}"
    
    if command -v docker &> /dev/null; then
        # 停止所有相关的Docker Compose服务
        if [ -f "config/docker/docker-compose.simple.yml" ]; then
            echo -e "${CYAN}停止基础服务...${NC}"
            config/docker/docker-compose -f config/docker/docker-compose.simple.yml down
        fi
        
        if [ -f "config/docker/docker-compose.mac.yml" ]; then
            echo -e "${CYAN}停止macOS服务...${NC}"
            config/docker/docker-compose -f config/docker/docker-compose.mac.yml down
        fi
        
        if [ -f "config/docker/docker-compose.monitoring.yml" ]; then
            echo -e "${CYAN}停止监控服务...${NC}"
            config/docker/docker-compose -f config/docker/docker-compose.monitoring.yml down
        fi
        
        echo -e "${GREEN}✅ Docker服务已停止${NC}"
    else
        echo -e "${YELLOW}⚠️  Docker不可用${NC}"
    fi
}

# 强制停止所有进程
force_stop() {
    echo -e "${BLUE}💥 强制停止所有进程${NC}"
    
    # 查找并停止Java进程
    echo -e "${CYAN}查找Java进程...${NC}"
    java_pids=$(ps aux | grep java | grep -v grep | awk '{print $2}')
    if [ ! -z "$java_pids" ]; then
        echo -e "${YELLOW}发现Java进程: $java_pids${NC}"
        echo "$java_pids" | xargs kill -9
        echo -e "${GREEN}✅ Java进程已清理${NC}"
    else
        echo -e "${GREEN}✅ 无Java进程${NC}"
    fi
    
    # 查找并停止Node.js进程
    echo -e "${CYAN}查找Node.js进程...${NC}"
    node_pids=$(ps aux | grep node | grep -v grep | awk '{print $2}')
    if [ ! -z "$node_pids" ]; then
        echo -e "${YELLOW}发现Node.js进程: $node_pids${NC}"
        echo "$node_pids" | xargs kill -9
        echo -e "${GREEN}✅ Node.js进程已清理${NC}"
    else
        echo -e "${GREEN}✅ 无Node.js进程${NC}"
    fi
    
    # 查找并停止Python进程
    echo -e "${CYAN}查找Python进程...${NC}"
    python_pids=$(ps aux | grep python | grep -v grep | awk '{print $2}')
    if [ ! -z "$python_pids" ]; then
        echo -e "${YELLOW}发现Python进程: $python_pids${NC}"
        echo "$python_pids" | xargs kill -9
        echo -e "${GREEN}✅ Python进程已清理${NC}"
    else
        echo -e "${GREEN}✅ 无Python进程${NC}"
    fi
}

# 检查端口占用
check_ports() {
    echo -e "${BLUE}🔍 检查端口占用${NC}"
    
    ports=(8080 3000 8081 9090 3001 5432 5672)
    for port in "${ports[@]}"; do
        if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1; then
            echo -e "${YELLOW}⚠️  端口 $port 仍被占用${NC}"
            lsof -Pi :$port -sTCP:LISTEN
        else
            echo -e "${GREEN}✅ 端口 $port 已释放${NC}"
        fi
    done
}

# 清理环境
clean_environment() {
    echo -e "${BLUE}🧹 清理环境${NC}"
    
    # 停止所有服务
    stop_backend
    stop_frontend
    stop_mcp
    stop_docker
    force_stop
    
    # 清理PID目录
    if [ -d "$PIDS_DIR" ]; then
        rm -rf "$PIDS_DIR"
        echo -e "${GREEN}✅ PID目录已清理${NC}"
    fi
    
    # 清理日志文件
    if [ -d "logs" ]; then
        rm -rf logs
        echo -e "${GREEN}✅ 日志文件已清理${NC}"
    fi
    
    # 清理临时文件
    find . -name "*.tmp" -delete 2>/dev/null || true
    find . -name "*.log" -delete 2>/dev/null || true
    
    echo -e "${GREEN}✅ 环境清理完成${NC}"
}

# 显示最终状态
show_final_status() {
    echo ""
    echo -e "${BLUE}✨ 停止完成！${NC}"
    echo "================================"
    
    # 显示进程状态
    echo -e "${CYAN}进程状态:${NC}"
    ps aux | grep -E "(java|node|python)" | grep -v grep || echo "无相关进程"
    
    echo ""
    # 显示端口状态
    echo -e "${CYAN}端口状态:${NC}"
    ports=(8080 3000 8081 9090 3001 5432 5672)
    for port in "${ports[@]}"; do
        if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1; then
            echo -e "${RED}❌ 端口 $port 仍被占用${NC}"
        else
            echo -e "${GREEN}✅ 端口 $port 可用${NC}"
        fi
    done
    
    echo ""
    echo -e "${GREEN}🎉 ImagentX 服务停止完成！${NC}"
}

# 主函数
main() {
    case "${1:-}" in
        --backend)
            stop_backend
            ;;
        --frontend)
            stop_frontend
            ;;
        --docker)
            stop_docker
            ;;
        --force)
            force_stop
            ;;
        --clean)
            clean_environment
            ;;
        --help|"")
            show_help
            ;;
        --all|*)
            echo -e "${BLUE}🛑 停止所有服务${NC}"
            echo "--------------------------------"
            stop_backend
            stop_frontend
            stop_mcp
            stop_docker
            check_ports
            show_final_status
            ;;
    esac
}

# 执行主函数
main "$@"
