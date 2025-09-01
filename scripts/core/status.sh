#!/bin/bash

# ImagentX 服务状态检查脚本
# 检查所有服务的运行状态和健康情况

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

PIDS_DIR="pids"

echo -e "${BLUE}📊 ImagentX 服务状态检查${NC}"
echo "=================================="

# 检查进程状态
check_process_status() {
    echo -e "${BLUE}🔍 进程状态检查${NC}"
    echo "--------------------------------"
    
    local services=(
        "backend:后端服务:8080"
        "frontend:前端服务:3000"
        "mcp:MCP网关:8081"
    )
    
    for service_info in "${services[@]}"; do
        IFS=':' read -r service_name display_name port <<< "$service_info"
        pid_file="$PIDS_DIR/${service_name}.pid"
        
        if [ -f "$pid_file" ]; then
            pid=$(cat "$pid_file")
            if ps -p $pid > /dev/null 2>&1; then
                echo -e "${GREEN}✅ $display_name 运行中 (PID: $pid)${NC}"
            else
                echo -e "${RED}❌ $display_name 进程已停止 (PID: $pid)${NC}"
                rm -f "$pid_file"
            fi
        else
            echo -e "${YELLOW}⚠️  $display_name 未启动${NC}"
        fi
    done
    echo ""
}

# 检查端口占用
check_port_status() {
    echo -e "${BLUE}🔌 端口占用检查${NC}"
    echo "--------------------------------"
    
    local ports=(
        "8080:后端API"
        "3000:前端服务"
        "8081:MCP网关"
        "9090:监控服务"
        "5432:PostgreSQL"
        "5672:RabbitMQ"
        "15672:RabbitMQ管理"
    )
    
    for port_info in "${ports[@]}"; do
        IFS=':' read -r port service_name <<< "$port_info"
        
        if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1; then
            process_info=$(lsof -Pi :$port -sTCP:LISTEN | tail -n +2 | head -1)
            echo -e "${GREEN}✅ 端口 $port ($service_name) 被占用${NC}"
            echo -e "${CYAN}   进程: $process_info${NC}"
        else
            echo -e "${YELLOW}⚠️  端口 $port ($service_name) 可用${NC}"
        fi
    done
    echo ""
}

# 检查Docker容器状态
check_docker_status() {
    echo -e "${BLUE}🐳 Docker容器状态${NC}"
    echo "--------------------------------"
    
    if command -v docker &> /dev/null; then
        if docker info &> /dev/null; then
            # 检查相关容器
            local containers=(
                "imagentx-postgres"
                "imagentx-rabbitmq"
                "imagentx-backend"
                "imagentx-frontend"
            )
            
            for container in "${containers[@]}"; do
                if docker ps --format "table {{.Names}}" | grep -q "$container"; then
                    status=$(docker ps --format "table {{.Names}}\t{{.Status}}" | grep "$container")
                    echo -e "${GREEN}✅ $status${NC}"
                else
                    echo -e "${YELLOW}⚠️  $container 未运行${NC}"
                fi
            done
            
            # 显示所有运行中的容器
            echo ""
            echo -e "${CYAN}所有运行中的容器:${NC}"
            docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
        else
            echo -e "${RED}❌ Docker服务未运行${NC}"
        fi
    else
        echo -e "${YELLOW}⚠️  Docker未安装${NC}"
    fi
    echo ""
}

# 检查服务健康状态
check_health_status() {
    echo -e "${BLUE}🏥 服务健康检查${NC}"
    echo "--------------------------------"
    
    local health_endpoints=(
        "http://localhost:8080/actuator/health:后端服务"
        "http://localhost:3000:前端服务"
        "http://localhost:8081/health:MCP网关"
    )
    
    for endpoint_info in "${health_endpoints[@]}"; do
        IFS=':' read -r url service_name <<< "$endpoint_info"
        
        if curl -s "$url" >/dev/null 2>&1; then
            echo -e "${GREEN}✅ $service_name 健康检查通过${NC}"
        else
            echo -e "${RED}❌ $service_name 健康检查失败${NC}"
        fi
    done
    echo ""
}

# 检查系统资源
check_system_resources() {
    echo -e "${BLUE}💻 系统资源状态${NC}"
    echo "--------------------------------"
    
    # CPU使用率
    if [[ "$OSTYPE" == "darwin"* ]]; then
        cpu_usage=$(top -l 1 | grep "CPU usage" | awk '{print $3}' | cut -d'%' -f1)
        echo -e "${CYAN}CPU使用率:${NC} ${cpu_usage}%"
        
        # 内存使用情况
        total_mem=$(sysctl -n hw.memsize | awk '{print $1/1024/1024/1024 "GB"}')
        free_mem=$(vm_stat | grep "Pages free" | awk '{print $3}' | sed 's/\.//')
        free_mem_gb=$(echo "scale=2; $free_mem * 4096 / 1024 / 1024 / 1024" | bc)
        used_mem_gb=$(echo "scale=2; $total_mem - $free_mem_gb" | bc)
        mem_usage=$(echo "scale=1; $used_mem_gb * 100 / $total_mem" | bc)
        
        echo -e "${CYAN}内存使用:${NC} ${used_mem_gb}GB / ${total_mem}GB (${mem_usage}%)"
    else
        echo -e "${CYAN}CPU使用率:${NC} $(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)%"
        echo -e "${CYAN}内存使用:${NC} $(free -h | awk 'NR==2{printf "%s / %s (%.1f%%)", $3,$2,$3*100/$2}')"
    fi
    
    # 磁盘使用情况
    disk_usage=$(df -h . | awk 'NR==2{print $5}')
    echo -e "${CYAN}磁盘使用:${NC} $disk_usage"
    echo ""
}

# 检查日志文件
check_logs() {
    echo -e "${BLUE}📝 日志文件状态${NC}"
    echo "--------------------------------"
    
    local log_files=(
        "logs/backend.log:后端日志"
        "logs/frontend.log:前端日志"
        "logs/mcp-gateway.log:MCP网关日志"
    )
    
    for log_info in "${log_files[@]}"; do
        IFS=':' read -r log_file display_name <<< "$log_info"
        
        if [ -f "$log_file" ]; then
            size=$(ls -lh "$log_file" | awk '{print $5}')
            lines=$(wc -l < "$log_file" 2>/dev/null || echo "0")
            echo -e "${GREEN}✅ $display_name 存在 (大小: $size, 行数: $lines)${NC}"
        else
            echo -e "${YELLOW}⚠️  $display_name 不存在${NC}"
        fi
    done
    echo ""
}

# 显示总体状态
show_overall_status() {
    echo -e "${BLUE}📈 总体状态${NC}"
    echo "--------------------------------"
    
    local running_services=0
    local total_services=3
    
    # 检查后端
    if [ -f "$PIDS_DIR/backend.pid" ] && ps -p $(cat "$PIDS_DIR/backend.pid") > /dev/null 2>&1; then
        ((running_services++))
    fi
    
    # 检查前端
    if [ -f "$PIDS_DIR/frontend.pid" ] && ps -p $(cat "$PIDS_DIR/frontend.pid") > /dev/null 2>&1; then
        ((running_services++))
    fi
    
    # 检查MCP网关
    if [ -f "$PIDS_DIR/mcp.pid" ] && ps -p $(cat "$PIDS_DIR/mcp.pid") > /dev/null 2>&1; then
        ((running_services++))
    fi
    
    echo -e "${CYAN}服务运行状态:${NC} $running_services/$total_services 个服务正在运行"
    
    if [ $running_services -eq $total_services ]; then
        echo -e "${GREEN}🎉 所有服务运行正常！${NC}"
    elif [ $running_services -gt 0 ]; then
        echo -e "${YELLOW}⚠️  部分服务运行中${NC}"
    else
        echo -e "${RED}❌ 没有服务在运行${NC}"
    fi
    
    echo ""
    echo -e "${CYAN}快速操作:${NC}"
    echo -e "  启动服务: ${GREEN}./start.sh --help${NC}"
    echo -e "  停止服务: ${GREEN}./stop.sh --help${NC}"
    echo -e "  重启服务: ${GREEN}./stop.sh && ./start.sh${NC}"
}

# 主函数
main() {
    case "${1:-}" in
        --process)
            check_process_status
            ;;
        --ports)
            check_port_status
            ;;
        --docker)
            check_docker_status
            ;;
        --health)
            check_health_status
            ;;
        --system)
            check_system_resources
            ;;
        --logs)
            check_logs
            ;;
        --help|"")
            echo -e "${GREEN}用法: ./status.sh [选项]${NC}"
            echo ""
            echo -e "${CYAN}检查选项:${NC}"
            echo -e "  ${GREEN}--process${NC}    检查进程状态"
            echo -e "  ${GREEN}--ports${NC}     检查端口占用"
            echo -e "  ${GREEN}--docker${NC}    检查Docker状态"
            echo -e "  ${GREEN}--health${NC}    检查服务健康"
            echo -e "  ${GREEN}--system${NC}    检查系统资源"
            echo -e "  ${GREEN}--logs${NC}      检查日志文件"
            echo -e "  ${GREEN}--help${NC}      显示此帮助信息"
            echo ""
            echo -e "${CYAN}示例:${NC}"
            echo -e "  ./status.sh              # 完整状态检查"
            echo -e "  ./status.sh --process    # 仅检查进程"
            echo -e "  ./status.sh --health     # 仅健康检查"
            echo ""
            ;;
        *)
            # 完整状态检查
            check_process_status
            check_port_status
            check_docker_status
            check_health_status
            check_system_resources
            check_logs
            show_overall_status
            ;;
    esac
}

# 执行主函数
main "$@"
