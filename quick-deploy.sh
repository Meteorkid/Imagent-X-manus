#!/bin/bash

# ImagentX 快速部署脚本
# 用于在服务器上快速部署ImagentX项目

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 显示帮助信息
show_help() {
    echo -e "${BLUE}🚀 ImagentX 快速部署脚本${NC}"
    echo "=================================="
    echo -e "${GREEN}用法: ./quick-deploy.sh [选项]${NC}"
    echo ""
    echo -e "${CYAN}部署选项:${NC}"
    echo -e "  ${GREEN}--setup${NC}        设置服务器环境（首次使用）"
    echo -e "  ${GREEN}--deploy${NC}       部署项目"
    echo -e "  ${GREEN}--update${NC}       更新项目"
    echo -e "  ${GREEN}--status${NC}       检查状态"
    echo -e "  ${GREEN}--logs${NC}         查看日志"
    echo -e "  ${GREEN}--help${NC}         显示此帮助信息"
    echo ""
    echo -e "${CYAN}示例:${NC}"
    echo -e "  ./quick-deploy.sh --setup   # 首次设置服务器环境"
    echo -e "  ./quick-deploy.sh --deploy  # 部署项目"
    echo ""
}

# 检查是否为root用户
check_root() {
    if [ "$EUID" -ne 0 ]; then
        echo -e "${RED}❌ 请使用root用户运行此脚本${NC}"
        exit 1
    fi
}

# 设置服务器环境
setup_server() {
    echo -e "${BLUE}🔧 设置服务器环境${NC}"
    echo "--------------------------------"
    
    # 更新系统
    echo -e "${CYAN}更新系统...${NC}"
    apt update && apt upgrade -y
    
    # 安装必要工具
    echo -e "${CYAN}安装必要工具...${NC}"
    apt install -y curl wget git nano ufw
    
    # 安装Docker
    echo -e "${CYAN}安装Docker...${NC}"
    if ! command -v docker &> /dev/null; then
        curl -fsSL https://get.docker.com | sh
        systemctl start docker
        systemctl enable docker
    else
        echo -e "${GREEN}✅ Docker已安装${NC}"
    fi
    
    # 安装Docker Compose
    echo -e "${CYAN}安装Docker Compose...${NC}"
    if ! command -v docker-compose &> /dev/null; then
        curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        chmod +x /usr/local/bin/docker-compose
    else
        echo -e "${GREEN}✅ Docker Compose已安装${NC}"
    fi
    
    # 配置防火墙
    echo -e "${CYAN}配置防火墙...${NC}"
    ufw allow 22/tcp
    ufw allow 80/tcp
    ufw allow 443/tcp
    ufw --force enable
    
    echo -e "${GREEN}✅ 服务器环境设置完成${NC}"
}

# 检查环境
check_environment() {
    echo -e "${BLUE}📋 环境检查${NC}"
    echo "--------------------------------"
    
    # 检查Docker
    if ! command -v docker &> /dev/null; then
        echo -e "${RED}❌ Docker未安装${NC}"
        exit 1
    fi
    
    # 检查Docker Compose
    if ! command -v docker-compose &> /dev/null; then
        echo -e "${RED}❌ Docker Compose未安装${NC}"
        exit 1
    fi
    
    # 检查环境变量文件
    if [ ! -f ".env.production" ]; then
        echo -e "${YELLOW}⚠️  环境变量文件不存在，请先配置${NC}"
        echo -e "${CYAN}cp env.production.template .env.production${NC}"
        echo -e "${CYAN}然后编辑 .env.production 文件${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✅ 环境检查通过${NC}"
}

# 部署项目
deploy_project() {
    echo -e "${BLUE}🚀 部署项目${NC}"
    echo "--------------------------------"
    
    # 检查环境
    check_environment
    
    # 停止现有服务
    echo -e "${CYAN}停止现有服务...${NC}"
    docker-compose -f docker-compose-production.yml down 2>/dev/null || true
    
    # 执行部署
    echo -e "${CYAN}执行部署...${NC}"
    ./deploy-production.sh --init
    ./deploy-production.sh --deploy
    
    echo -e "${GREEN}✅ 项目部署完成${NC}"
}

# 更新项目
update_project() {
    echo -e "${BLUE}🔄 更新项目${NC}"
    echo "--------------------------------"
    
    # 拉取最新代码
    echo -e "${CYAN}拉取最新代码...${NC}"
    git pull origin main
    
    # 重新部署
    deploy_project
    
    echo -e "${GREEN}✅ 项目更新完成${NC}"
}

# 检查状态
check_status() {
    echo -e "${BLUE}📊 检查状态${NC}"
    echo "--------------------------------"
    
    ./deploy-production.sh --status
}

# 查看日志
show_logs() {
    echo -e "${BLUE}📋 查看日志${NC}"
    echo "--------------------------------"
    
    ./deploy-production.sh --logs
}

# 主函数
main() {
    case "${1:-}" in
        --setup)
            check_root
            setup_server
            ;;
        --deploy)
            deploy_project
            ;;
        --update)
            update_project
            ;;
        --status)
            check_status
            ;;
        --logs)
            show_logs
            ;;
        --help|*)
            show_help
            ;;
    esac
}

# 运行主函数
main "$@"
