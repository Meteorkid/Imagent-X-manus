#!/bin/bash

# ImagentX 生产环境部署脚本
# 域名: imagentx.top

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 显示帮助信息
show_help() {
    echo -e "${BLUE}🚀 ImagentX 生产环境部署脚本${NC}"
    echo "=================================="
    echo -e "${GREEN}用法: ./deploy-production.sh [选项]${NC}"
    echo ""
    echo -e "${CYAN}部署选项:${NC}"
    echo -e "  ${GREEN}--init${NC}        初始化部署（首次部署）"
    echo -e "  ${GREEN}--deploy${NC}      部署服务"
    echo -e "  ${GREEN}--update${NC}      更新服务"
    echo -e "  ${GREEN}--stop${NC}        停止服务"
    echo -e "  ${GREEN}--restart${NC}     重启服务"
    echo -e "  ${GREEN}--logs${NC}        查看日志"
    echo -e "  ${GREEN}--status${NC}      检查状态"
    echo -e "  ${GREEN}--ssl${NC}         更新SSL证书"
    echo -e "  ${GREEN}--backup${NC}      备份数据"
    echo -e "  ${GREEN}--help${NC}        显示此帮助信息"
    echo ""
    echo -e "${CYAN}示例:${NC}"
    echo -e "  ./deploy-production.sh --init    # 初始化部署"
    echo -e "  ./deploy-production.sh --deploy  # 部署服务"
    echo -e "  ./deploy-production.sh --status  # 检查状态"
    echo ""
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
        echo -e "${YELLOW}⚠️  环境变量文件不存在，请复制模板并配置${NC}"
        echo -e "${CYAN}cp env.production.template .env.production${NC}"
        echo -e "${CYAN}然后编辑 .env.production 文件${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✅ 环境检查通过${NC}"
}

# 初始化部署
init_deploy() {
    echo -e "${BLUE}🚀 初始化部署${NC}"
    echo "--------------------------------"
    
    # 加载环境变量
    source .env.production
    
    # 创建必要的目录
    mkdir -p logs backups
    
    # 停止现有服务
    docker-compose -f docker-compose-production.yml down 2>/dev/null || true
    
    # 启动基础服务（数据库和消息队列）
    echo -e "${CYAN}启动基础服务...${NC}"
    docker-compose -f docker-compose-production.yml up -d postgres rabbitmq
    
    # 等待服务启动
    echo -e "${CYAN}等待服务启动...${NC}"
    sleep 30
    
    # 初始化数据库
    echo -e "${CYAN}初始化数据库...${NC}"
    docker exec imagentx-postgres-prod psql -U $DB_USER -d $DB_NAME -c "SELECT version();" 2>/dev/null || {
        echo -e "${YELLOW}数据库连接失败，请检查配置${NC}"
        exit 1
    }
    
    echo -e "${GREEN}✅ 初始化完成${NC}"
}

# 部署服务
deploy_services() {
    echo -e "${BLUE}🚀 部署服务${NC}"
    echo "--------------------------------"
    
    # 加载环境变量
    source .env.production
    
    # 构建并启动所有服务
    echo -e "${CYAN}构建并启动服务...${NC}"
    docker-compose -f docker-compose-production.yml up -d --build
    
    # 等待服务启动
    echo -e "${CYAN}等待服务启动...${NC}"
    sleep 60
    
    # 检查服务状态
    check_status
    
    echo -e "${GREEN}✅ 部署完成${NC}"
}

# 更新服务
update_services() {
    echo -e "${BLUE}🔄 更新服务${NC}"
    echo "--------------------------------"
    
    # 拉取最新代码
    echo -e "${CYAN}拉取最新代码...${NC}"
    git pull origin main
    
    # 重新构建并启动服务
    deploy_services
}

# 停止服务
stop_services() {
    echo -e "${BLUE}🛑 停止服务${NC}"
    echo "--------------------------------"
    
    docker-compose -f docker-compose-production.yml down
    echo -e "${GREEN}✅ 服务已停止${NC}"
}

# 重启服务
restart_services() {
    echo -e "${BLUE}🔄 重启服务${NC}"
    echo "--------------------------------"
    
    docker-compose -f docker-compose-production.yml restart
    echo -e "${GREEN}✅ 服务已重启${NC}"
}

# 查看日志
show_logs() {
    echo -e "${BLUE}📋 查看日志${NC}"
    echo "--------------------------------"
    
    echo -e "${CYAN}选择要查看的服务:${NC}"
    echo "1) 后端服务"
    echo "2) 前端服务"
    echo "3) Nginx"
    echo "4) 数据库"
    echo "5) RabbitMQ"
    echo "6) 所有服务"
    
    read -p "请选择 (1-6): " choice
    
    case $choice in
        1) docker-compose -f docker-compose-production.yml logs -f imagentx-backend-prod ;;
        2) docker-compose -f docker-compose-production.yml logs -f imagentx-frontend-prod ;;
        3) docker-compose -f docker-compose-production.yml logs -f imagentx-nginx-prod ;;
        4) docker-compose -f docker-compose-production.yml logs -f imagentx-postgres-prod ;;
        5) docker-compose -f docker-compose-production.yml logs -f imagentx-rabbitmq-prod ;;
        6) docker-compose -f docker-compose-production.yml logs -f ;;
        *) echo -e "${RED}无效选择${NC}" ;;
    esac
}

# 检查状态
check_status() {
    echo -e "${BLUE}📊 服务状态检查${NC}"
    echo "--------------------------------"
    
    # 检查容器状态
    echo -e "${CYAN}容器状态:${NC}"
    docker-compose -f docker-compose-production.yml ps
    
    echo ""
    
    # 检查端口
    echo -e "${CYAN}端口检查:${NC}"
    netstat -tlnp 2>/dev/null | grep -E ":(80|443|3000|8088)" || echo "端口检查失败"
    
    echo ""
    
    # 检查健康状态
    echo -e "${CYAN}健康检查:${NC}"
    curl -s https://imagentx.top/health 2>/dev/null && echo "✅ 前端健康" || echo "❌ 前端不健康"
    curl -s https://imagentx.top/api/health 2>/dev/null && echo "✅ 后端健康" || echo "❌ 后端不健康"
}

# 更新SSL证书
update_ssl() {
    echo -e "${BLUE}🔒 更新SSL证书${NC}"
    echo "--------------------------------"
    
    # 运行certbot更新证书
    docker-compose -f docker-compose-production.yml run --rm certbot renew
    
    # 重启nginx
    docker-compose -f docker-compose-production.yml restart nginx
    
    echo -e "${GREEN}✅ SSL证书已更新${NC}"
}

# 备份数据
backup_data() {
    echo -e "${BLUE}💾 备份数据${NC}"
    echo "--------------------------------"
    
    # 创建备份目录
    mkdir -p backups/$(date +%Y%m%d_%H%M%S)
    BACKUP_DIR="backups/$(date +%Y%m%d_%H%M%S)"
    
    # 备份数据库
    echo -e "${CYAN}备份数据库...${NC}"
    docker exec imagentx-postgres-prod pg_dump -U $DB_USER $DB_NAME > $BACKUP_DIR/database.sql
    
    # 备份存储文件
    echo -e "${CYAN}备份存储文件...${NC}"
    docker cp imagentx-backend-prod:/app/storage $BACKUP_DIR/
    
    # 压缩备份
    tar -czf $BACKUP_DIR.tar.gz $BACKUP_DIR
    rm -rf $BACKUP_DIR
    
    echo -e "${GREEN}✅ 备份完成: $BACKUP_DIR.tar.gz${NC}"
}

# 主函数
main() {
    case "${1:-}" in
        --init)
            check_environment
            init_deploy
            ;;
        --deploy)
            check_environment
            deploy_services
            ;;
        --update)
            check_environment
            update_services
            ;;
        --stop)
            stop_services
            ;;
        --restart)
            restart_services
            ;;
        --logs)
            show_logs
            ;;
        --status)
            check_status
            ;;
        --ssl)
            update_ssl
            ;;
        --backup)
            backup_data
            ;;
        --help|*)
            show_help
            ;;
    esac
}

# 运行主函数
main "$@"
