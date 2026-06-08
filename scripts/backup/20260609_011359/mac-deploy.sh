#!/bin/bash

# Imagent X Mac部署配置脚本
# 支持内网和公网访问

set -e

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🍎 Imagent X Mac部署配置${NC}"
echo "================================"

# 获取网络信息
get_network_info() {
    echo -e "${BLUE}🔍 获取网络信息...${NC}"
    
    # 获取内网IP
    LOCAL_IP=$(ifconfig | grep "inet " | grep -v 127.0.0.1 | awk '{print $2}' | head -1)
    if [ -z "$LOCAL_IP" ]; then
        LOCAL_IP=$(ipconfig getifaddr en0 2>/dev/null || echo "192.168.1.100")
    fi
    
    # 获取公网IP
    PUBLIC_IP=$(curl -s --max-time 5 https://ipinfo.io/ip 2>/dev/null || echo "")
    
    echo -e "${GREEN}✅ 内网IP: ${LOCAL_IP}${NC}"
    if [ -n "$PUBLIC_IP" ]; then
        echo -e "${GREEN}✅ 公网IP: ${PUBLIC_IP}${NC}"
    fi
    
    # 检查Docker Desktop状态
    if ! docker info >/dev/null 2>&1; then
        echo -e "${RED}❌ Docker Desktop未运行，请先启动Docker Desktop${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✅ Docker Desktop运行正常${NC}"
}

# 配置防火墙（Mac）
configure_firewall() {
    echo -e "${BLUE}🔥 配置Mac防火墙...${NC}"
    
    # 检查端口是否被占用
    local ports=(3000 8088 8081 15673 5432)
    local occupied_ports=()
    
    for port in "${ports[@]}"; do
        if lsof -i :$port >/dev/null 2>&1; then
            occupied_ports+=($port)
        fi
    done
    
    if [ ${#occupied_ports[@]} -gt 0 ]; then
        echo -e "${YELLOW}⚠️ 以下端口已被占用: ${occupied_ports[*]}${NC}"
        echo -e "${YELLOW}   这些端口可能被其他应用使用${NC}"
    else
        echo -e "${GREEN}✅ 所有端口可用${NC}"
    fi
    
    # Mac防火墙提示
    echo -e "${BLUE}📝 Mac防火墙配置提示:${NC}"
    echo -e "   1. 系统偏好设置 → 安全性与隐私 → 防火墙"
    echo -e "   2. 点击'防火墙选项'"
    echo -e "   3. 确保Docker Desktop被允许"
    echo -e "   4. 或者临时关闭防火墙进行测试"
}

# 启动服务
start_services() {
    echo -e "${BLUE}🚀 启动Imagent X服务...${NC}"
    
    # 检查现有容器
    if docker ps --format "{{.Names}}" | grep -q "imagentx"; then
        echo -e "${YELLOW}⚠️ 检测到现有容器，正在停止...${NC}"
        docker stop imagentx imagentx-rabbitmq-ext imagentx-gateway 2>/dev/null || true
        docker rm -f imagentx imagentx-rabbitmq-ext imagentx-gateway 2>/dev/null || true
    fi
    
    # 启动RabbitMQ
    echo -e "${BLUE}📨 启动RabbitMQ...${NC}"
    docker run -d --name imagentx-rabbitmq-ext \
        -p 5673:5672 -p 15673:15672 \
        rabbitmq:3.12-management-alpine
    
    # 启动网关
    echo -e "${BLUE}🌐 启动MCP网关...${NC}"
    docker run -d --name imagentx-gateway \
        -p 8081:8081 \
        ghcr.io/lucky-aeon/api-premium-gateway:latest
    
    # 启动主服务
    echo -e "${BLUE}🤖 启动Imagent X主服务...${NC}"
    docker run -d --name imagentx \
        --env-file .env \
        -p 3000:3000 -p 8088:8088 -p 5432:5432 \
        -v imagentx-data:/var/lib/postgresql/data \
        -v imagentx-storage:/app/storage \
        ghcr.io/lucky-aeon/imagentx:latest
    
    echo -e "${GREEN}✅ 所有服务启动完成${NC}"
}

# 等待服务就绪
wait_for_services() {
    echo -e "${BLUE}⏳ 等待服务就绪...${NC}"
    
    local max_attempts=30
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        echo -n "检查服务状态... "
        
        # 检查前端
        if curl -s -o /dev/null -w "%{http_code}" "http://localhost:3000" | grep -q "200"; then
            echo -e "${GREEN}✅${NC}"
            break
        else
            echo -e "${YELLOW}⏳${NC}"
            sleep 10
            attempt=$((attempt + 1))
        fi
    done
    
    if [ $attempt -gt $max_attempts ]; then
        echo -e "${RED}❌ 服务启动超时${NC}"
        return 1
    fi
}

# 测试访问
test_access() {
    echo -e "${BLUE}🧪 测试服务访问...${NC}"
    
    local LOCAL_IP=$(ifconfig | grep "inet " | grep -v 127.0.0.1 | awk '{print $2}' | head -1)
    
    echo -e "${BLUE}本地访问测试:${NC}"
    echo -n "  前端 (localhost:3000): "
    if curl -s -o /dev/null -w "%{http_code}" "http://localhost:3000" | grep -q "200"; then
        echo -e "${GREEN}✅${NC}"
    else
        echo -e "${RED}❌${NC}"
    fi
    
    echo -n "  后端 (localhost:8088): "
    if curl -s -o /dev/null -w "%{http_code}" "http://localhost:8088/api/health" | grep -q "200"; then
        echo -e "${GREEN}✅${NC}"
    else
        echo -e "${RED}❌${NC}"
    fi
    
    echo -e "${BLUE}内网访问测试:${NC}"
    echo -n "  前端 (${LOCAL_IP}:3000): "
    if curl -s -o /dev/null -w "%{http_code}" "http://${LOCAL_IP}:3000" | grep -q "200"; then
        echo -e "${GREEN}✅${NC}"
    else
        echo -e "${RED}❌${NC}"
    fi
    
    echo -n "  后端 (${LOCAL_IP}:8088): "
    if curl -s -o /dev/null -w "%{http_code}" "http://${LOCAL_IP}:8088/api/health" | grep -q "200"; then
        echo -e "${GREEN}✅${NC}"
    else
        echo -e "${RED}❌${NC}"
    fi
}

# 显示访问信息
show_access_info() {
    echo
    echo -e "${BLUE}=====================================${NC}"
    echo -e "${GREEN}🎉 Mac部署配置完成！${NC}"
    echo -e "${BLUE}=====================================${NC}"
    echo
    echo -e "${BLUE}🌐 访问地址:${NC}"
    echo -e "  本地访问: ${GREEN}http://localhost:3000${NC}"
    echo -e "  内网访问: ${GREEN}http://192.168.1.63:3000${NC}"
    echo -e "  后端API: ${GREEN}http://192.168.1.63:8088/api${NC}"
    echo -e "  MCP网关: ${GREEN}http://192.168.1.63:8081${NC}"
    echo -e "  RabbitMQ管理: ${GREEN}http://192.168.1.63:15673${NC}"
    echo
    echo -e "${BLUE}👤 登录账号:${NC}"
    echo -e "  管理员: ${GREEN}admin@imagentx.ai / admin123${NC}"
    echo
    echo -e "${BLUE}🔧 管理命令:${NC}"
    echo -e "  查看状态: ${GREEN}docker ps${NC}"
    echo -e "  查看日志: ${GREEN}docker logs -f imagentx${NC}"
    echo -e "  停止服务: ${GREEN}docker stop imagentx imagentx-rabbitmq-ext imagentx-gateway${NC}"
    echo -e "  启动服务: ${GREEN}docker start imagentx imagentx-rabbitmq-ext imagentx-gateway${NC}"
    echo
    echo -e "${BLUE}📱 其他设备访问:${NC}"
    echo -e "  确保其他设备与Mac在同一WiFi网络"
    echo -e "  使用内网IP访问: http://192.168.1.63:3000"
    echo
    echo -e "${BLUE}🌍 公网访问（需要路由器配置）:${NC}"
    echo -e "  1. 登录路由器管理界面"
    echo -e "  2. 配置端口转发: 3000, 8088, 8081, 15673"
    echo -e "  3. 转发到Mac的内网IP: 192.168.1.63"
    echo -e "  4. 使用公网IP访问: http://163.142.180.93:3000"
}

# 主函数
main() {
    get_network_info
    configure_firewall
    start_services
    wait_for_services
    test_access
    show_access_info
}

# 运行主函数
main "$@"
