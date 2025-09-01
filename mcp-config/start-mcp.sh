#!/bin/bash

# ImagentX MCP 启动脚本
# 用于启动完整的MCP监控和管理系统

set -e

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # 无颜色

echo -e "${BLUE}🚀 启动ImagentX MCP系统...${NC}"

# 检查Docker服务
check_docker() {
    if ! docker info >/dev/null 2>&1; then
        echo -e "${RED}❌ Docker服务未运行${NC}"
        exit 1
    fi
    echo -e "${GREEN}✅ Docker服务正常运行${NC}"
}

# 创建必要的目录
create_directories() {
    echo -e "${BLUE}📁 创建MCP配置目录...${NC}"
    
    mkdir -p mcp-config/grafana/provisioning/datasources
    mkdir -p mcp-config/grafana/provisioning/dashboards
    mkdir -p mcp-config/configs
    mkdir -p mcp-config/scheduler
    
    echo -e "${GREEN}✅ 目录创建完成${NC}"
}

# 启动MCP系统
start_mcp_system() {
    echo -e "${BLUE}🔧 启动MCP系统...${NC}"
    
    # 停止现有服务
    docker-compose -f mcp-config/docker-compose.mcp.yml down 2>/dev/null || true
    
    # 启动MCP系统
    docker-compose -f mcp-config/docker-compose.mcp.yml up -d
    
    echo -e "${GREEN}✅ MCP系统启动完成${NC}"
}

# 等待服务启动
wait_for_services() {
    echo -e "${BLUE}⏳ 等待服务启动...${NC}"
    
    services=(
        "http://localhost:3000"  # ImagentX前端
        "http://localhost:8088/api/health"  # ImagentX后端
        "http://localhost:9090/-/healthy"  # Prometheus
        "http://localhost:3001/api/health"  # Grafana
        "http://localhost:8080"  # MCP网关
    )
    
    for service in "${services[@]}"; do
        echo -e "${YELLOW}等待服务: $service${NC}"
        for i in {1..30}; do
            if curl -s "$service" >/dev/null 2>&1; then
                echo -e "${GREEN}✅ $service 启动成功${NC}"
                break
            fi
            if [ $i -eq 30 ]; then
                echo -e "${RED}❌ $service 启动超时${NC}"
            fi
            sleep 2
        done
    done
}

# 显示服务信息
show_service_info() {
    echo -e "\n${BLUE}📊 MCP系统服务信息:${NC}"
    echo -e "${GREEN}• ImagentX前端: http://localhost:3000${NC}"
    echo -e "${GREEN}• ImagentX后端: http://localhost:8088${NC}"
    echo -e "${GREEN}• Prometheus监控: http://localhost:9090${NC}"
    echo -e "${GREEN}• Grafana可视化: http://localhost:3001 (admin/admin123)${NC}"
    echo -e "${GREEN}• MCP网关: http://localhost:8080${NC}"
    echo -e "${GREEN}• MCP配置中心: http://localhost:8082${NC}"
    echo -e "${GREEN}• RabbitMQ管理: http://localhost:15672 (guest/guest)${NC}"
}

# 显示管理命令
show_management_commands() {
    echo -e "\n${BLUE}🔧 管理命令:${NC}"
    echo -e "${YELLOW}• 查看所有服务: docker-compose -f mcp-config/docker-compose.mcp.yml ps${NC}"
    echo -e "${YELLOW}• 查看日志: docker-compose -f mcp-config/docker-compose.mcp.yml logs -f${NC}"
    echo -e "${YELLOW}• 停止服务: docker-compose -f mcp-config/docker-compose.mcp.yml down${NC}"
    echo -e "${YELLOW}• 重启服务: docker-compose -f mcp-config/docker-compose.mcp.yml restart${NC}"
    echo -e "${YELLOW}• 更新服务: docker-compose -f mcp-config/docker-compose.mcp.yml pull && docker-compose -f mcp-config/docker-compose.mcp.yml up -d${NC}"
}

# 主函数
main() {
    echo -e "${BLUE}===== ImagentX MCP 系统启动 =====${NC}"
    
    check_docker
    create_directories
    start_mcp_system
    wait_for_services
    show_service_info
    show_management_commands
    
    echo -e "\n${GREEN}🎉 ImagentX MCP系统启动完成！${NC}"
}

# 执行主函数
main "$@"
