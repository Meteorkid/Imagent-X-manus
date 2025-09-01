#!/bin/bash

# Imagent X 内网/公网部署脚本
# 支持自动IP检测和配置

set -e

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🚀 Imagent X 内网/公网部署脚本${NC}"
echo "=================================="

# 检测部署环境
detect_environment() {
    echo -e "${BLUE}🔍 检测部署环境...${NC}"
    
    # 获取本机IP地址
    LOCAL_IP=$(hostname -I | awk '{print $1}' | head -1)
    if [ -z "$LOCAL_IP" ]; then
        LOCAL_IP=$(ip route get 1 | awk '{print $7; exit}')
    fi
    
    # 获取公网IP（如果可能）
    PUBLIC_IP=$(curl -s --max-time 5 https://ipinfo.io/ip 2>/dev/null || echo "")
    
    echo "本地IP: ${LOCAL_IP}"
    if [ -n "$PUBLIC_IP" ]; then
        echo "公网IP: ${PUBLIC_IP}"
    fi
    
    # 询问部署类型
    echo
    echo -e "${YELLOW}请选择部署类型:${NC}"
    echo "1) 内网部署 (使用本地IP: ${LOCAL_IP})"
    echo "2) 公网部署 (使用公网IP: ${PUBLIC_IP:-未知})"
    echo "3) 自定义域名/IP"
    read -p "请输入选择 (1-3): " choice
    
    case $choice in
        1)
            DEPLOY_TYPE="internal"
            SERVER_IP=$LOCAL_IP
            ;;
        2)
            if [ -z "$PUBLIC_IP" ]; then
                echo -e "${RED}无法获取公网IP，请手动输入${NC}"
                read -p "请输入公网IP或域名: " SERVER_IP
            else
                DEPLOY_TYPE="public"
                SERVER_IP=$PUBLIC_IP
            fi
            ;;
        3)
            DEPLOY_TYPE="custom"
            read -p "请输入服务器IP或域名: " SERVER_IP
            ;;
        *)
            echo -e "${RED}无效选择，使用内网部署${NC}"
            DEPLOY_TYPE="internal"
            SERVER_IP=$LOCAL_IP
            ;;
    esac
    
    echo -e "${GREEN}✅ 部署类型: ${DEPLOY_TYPE}${NC}"
    echo -e "${GREEN}✅ 服务器地址: ${SERVER_IP}${NC}"
}

# 配置环境变量
configure_environment() {
    echo -e "${BLUE}⚙️ 配置环境变量...${NC}"
    
    # 创建或更新.env文件
    cat > .env << EOF
# Imagent X 部署配置
DEPLOY_TYPE=${DEPLOY_TYPE}
SERVER_IP=${SERVER_IP}

# 数据库配置
DB_NAME=imagentx
DB_USER=postgres
DB_PASSWORD=imagentx_pass

# RabbitMQ配置
RABBITMQ_USERNAME=guest
RABBITMQ_PASSWORD=guest

# 安全配置
JWT_SECRET=$(openssl rand -base64 48)
IMAGENTX_ADMIN_EMAIL=admin@imagentx.ai
IMAGENTX_ADMIN_PASSWORD=admin123

# 服务配置
FRONTEND_URL=http://${SERVER_IP}
BACKEND_URL=http://${SERVER_IP}:8088
GATEWAY_URL=http://${SERVER_IP}:8081
RABBITMQ_MANAGEMENT_URL=http://${SERVER_IP}:15672
EOF
    
    echo -e "${GREEN}✅ 环境变量配置完成${NC}"
}

# 启动服务
start_services() {
    echo -e "${BLUE}🚀 启动服务...${NC}"
    
    # 停止现有容器
    docker compose -f docker-compose-network.yml down 2>/dev/null || true
    
    # 启动服务
    docker compose -f docker-compose-network.yml up -d
    
    echo -e "${GREEN}✅ 服务启动完成${NC}"
}

# 等待服务就绪
wait_for_services() {
    echo -e "${BLUE}⏳ 等待服务就绪...${NC}"
    
    local max_attempts=30
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        echo -n "检查服务状态... "
        
        # 检查前端
        if curl -s -o /dev/null -w "%{http_code}" "http://${SERVER_IP}:3000" | grep -q "200"; then
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

# 显示部署信息
show_deployment_info() {
    echo
    echo -e "${BLUE}=====================================${NC}"
    echo -e "${GREEN}🎉 Imagent X 部署完成！${NC}"
    echo -e "${BLUE}=====================================${NC}"
    echo
    echo -e "${BLUE}🌐 访问地址:${NC}"
    echo -e "  前端应用: ${GREEN}http://${SERVER_IP}${NC}"
    echo -e "  后端API: ${GREEN}http://${SERVER_IP}:8088/api${NC}"
    echo -e "  MCP网关: ${GREEN}http://${SERVER_IP}:8081${NC}"
    echo -e "  RabbitMQ管理: ${GREEN}http://${SERVER_IP}:15672${NC}"
    echo
    echo -e "${BLUE}👤 登录账号:${NC}"
    echo -e "  管理员: ${GREEN}admin@imagentx.ai / admin123${NC}"
    echo
    echo -e "${BLUE}🔧 管理命令:${NC}"
    echo -e "  查看状态: ${GREEN}docker compose -f docker-compose-network.yml ps${NC}"
    echo -e "  查看日志: ${GREEN}docker compose -f docker-compose-network.yml logs -f${NC}"
    echo -e "  停止服务: ${GREEN}docker compose -f docker-compose-network.yml down${NC}"
    echo -e "  重启服务: ${GREEN}docker compose -f docker-compose-network.yml restart${NC}"
    echo
    echo -e "${BLUE}📝 注意事项:${NC}"
    echo -e "  • 确保防火墙开放端口: 80, 3000, 8088, 8081, 15672${NC}"
    echo -e "  • 如需HTTPS，请配置SSL证书${NC}"
    echo -e "  • 生产环境请修改默认密码${NC}"
}

# 主函数
main() {
    detect_environment
    configure_environment
    start_services
    wait_for_services
    show_deployment_info
}

# 运行主函数
main "$@"
