#!/bin/bash

# Mac环境下一键部署脚本
# 用于简化ImagentX项目的部署过程

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 配置变量
PROJECT_DIR="/Users/Meteorkid/Downloads/ImagentX-master"
DEPLOY_PACKAGE="imagentx-deploy.tar.gz"
SERVER_IP=""
SERVER_USER="root"
DEPLOY_PATH="/opt/imagentx"

# 显示帮助信息
show_help() {
    echo -e "${BLUE}🍎 Mac环境一键部署脚本${NC}"
    echo "=================================="
    echo -e "${GREEN}用法: ./mac-deploy.sh [选项]${NC}"
    echo ""
    echo -e "${CYAN}部署选项:${NC}"
    echo -e "  ${GREEN}--prepare${NC}      准备部署包"
    echo -e "  ${GREEN}--upload${NC}       上传到服务器"
    echo -e "  ${GREEN}--deploy${NC}       完整部署"
    echo -e "  ${GREEN}--check${NC}        检查部署状态"
    echo -e "  ${GREEN}--help${NC}         显示此帮助信息"
    echo ""
    echo -e "${CYAN}示例:${NC}"
    echo -e "  ./mac-deploy.sh --prepare   # 准备部署包"
    echo -e "  ./mac-deploy.sh --deploy    # 完整部署"
    echo ""
    echo -e "${YELLOW}注意: 请先设置SERVER_IP变量${NC}"
}

# 检查必要工具
check_tools() {
    echo -e "${CYAN}🔧 检查必要工具...${NC}"
    
    # 检查SSH
    if ! command -v ssh &> /dev/null; then
        echo -e "${RED}❌ SSH未安装${NC}"
        exit 1
    fi
    
    # 检查scp
    if ! command -v scp &> /dev/null; then
        echo -e "${RED}❌ SCP未安装${NC}"
        exit 1
    fi
    
    # 检查tar
    if ! command -v tar &> /dev/null; then
        echo -e "${RED}❌ TAR未安装${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✅ 必要工具检查通过${NC}"
}

# 设置服务器IP
set_server_ip() {
    if [ -z "$SERVER_IP" ]; then
        echo -e "${YELLOW}请输入服务器IP地址:${NC}"
        read -p "服务器IP: " SERVER_IP
        
        if [ -z "$SERVER_IP" ]; then
            echo -e "${RED}❌ 服务器IP不能为空${NC}"
            exit 1
        fi
        
        echo -e "${GREEN}✅ 服务器IP设置为: ${SERVER_IP}${NC}"
    fi
}

# 测试SSH连接
test_ssh_connection() {
    echo -e "${CYAN}🔌 测试SSH连接...${NC}"
    
    if ssh -o ConnectTimeout=10 -o BatchMode=yes $SERVER_USER@$SERVER_IP exit 2>/dev/null; then
        echo -e "${GREEN}✅ SSH连接成功${NC}"
    else
        echo -e "${YELLOW}⚠️  SSH连接失败，请手动输入密码${NC}"
        echo -e "${CYAN}请执行: ssh $SERVER_USER@$SERVER_IP${NC}"
        read -p "按回车键继续..."
    fi
}

# 准备部署包
prepare_deploy_package() {
    echo -e "${BLUE}📦 准备部署包${NC}"
    echo "--------------------------------"
    
    # 检查项目目录
    if [ ! -d "$PROJECT_DIR" ]; then
        echo -e "${RED}❌ 项目目录不存在: $PROJECT_DIR${NC}"
        exit 1
    fi
    
    cd "$PROJECT_DIR"
    
    # 创建部署包
    echo -e "${CYAN}创建部署包...${NC}"
    tar -czf "$DEPLOY_PACKAGE" \
        --exclude='.git' \
        --exclude='node_modules' \
        --exclude='target' \
        --exclude='logs' \
        --exclude='temp' \
        --exclude='*.tar.gz' \
        .
    
    # 检查文件大小
    FILE_SIZE=$(du -h "$DEPLOY_PACKAGE" | cut -f1)
    echo -e "${GREEN}✅ 部署包创建成功: $DEPLOY_PACKAGE (${FILE_SIZE})${NC}"
}

# 上传到服务器
upload_to_server() {
    echo -e "${BLUE}📤 上传到服务器${NC}"
    echo "--------------------------------"
    
    set_server_ip
    test_ssh_connection
    
    # 检查部署包是否存在
    if [ ! -f "$PROJECT_DIR/$DEPLOY_PACKAGE" ]; then
        echo -e "${RED}❌ 部署包不存在，请先执行 --prepare${NC}"
        exit 1
    fi
    
    # 上传文件
    echo -e "${CYAN}上传部署包到服务器...${NC}"
    scp "$PROJECT_DIR/$DEPLOY_PACKAGE" $SERVER_USER@$SERVER_IP:/opt/
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ 文件上传成功${NC}"
    else
        echo -e "${RED}❌ 文件上传失败${NC}"
        exit 1
    fi
}

# 在服务器上部署
deploy_on_server() {
    echo -e "${BLUE}🚀 在服务器上部署${NC}"
    echo "--------------------------------"
    
    set_server_ip
    
    # 远程执行部署命令
    echo -e "${CYAN}在服务器上执行部署...${NC}"
    ssh $SERVER_USER@$SERVER_IP << 'EOF'
        # 创建部署目录
        mkdir -p /opt/imagentx
        cd /opt/imagentx
        
        # 解压部署包
        if [ -f "/opt/imagentx-deploy.tar.gz" ]; then
            tar -xzf /opt/imagentx-deploy.tar.gz
            echo "✅ 部署包解压成功"
        else
            echo "❌ 部署包不存在"
            exit 1
        fi
        
        # 设置执行权限
        chmod +x *.sh
        
        # 配置环境变量
        if [ ! -f ".env.production" ]; then
            cp env.production.template .env.production
            echo "⚠️  请编辑 .env.production 文件"
        fi
        
        # 设置服务器环境
        ./quick-deploy.sh --setup
        
        # 部署项目
        ./quick-deploy.sh --deploy
        
        echo "✅ 部署完成"
EOF
    
    echo -e "${GREEN}✅ 服务器部署完成${NC}"
}

# 检查部署状态
check_deployment() {
    echo -e "${BLUE}📊 检查部署状态${NC}"
    echo "--------------------------------"
    
    set_server_ip
    
    # 检查服务器状态
    echo -e "${CYAN}检查服务器状态...${NC}"
    ssh $SERVER_USER@$SERVER_IP "cd $DEPLOY_PATH && ./quick-deploy.sh --status"
    
    # 检查DNS解析
    echo -e "${CYAN}检查DNS解析...${NC}"
    ./check-dns.sh --check
    
    # 测试网站访问
    echo -e "${CYAN}测试网站访问...${NC}"
    curl -I --connect-timeout 10 https://imagentx.top 2>/dev/null || echo -e "${YELLOW}⚠️  网站访问失败（可能DNS未生效）${NC}"
}

# 完整部署流程
full_deploy() {
    echo -e "${BLUE}🚀 执行完整部署${NC}"
    echo "=================================="
    
    # 检查工具
    check_tools
    
    # 准备部署包
    prepare_deploy_package
    
    # 上传到服务器
    upload_to_server
    
    # 在服务器上部署
    deploy_on_server
    
    # 等待一段时间让服务启动
    echo -e "${CYAN}等待服务启动...${NC}"
    sleep 30
    
    # 检查部署状态
    check_deployment
    
    echo -e "${GREEN}🎉 完整部署流程完成${NC}"
}

# 显示部署信息
show_deployment_info() {
    echo -e "${BLUE}📋 部署信息${NC}"
    echo "--------------------------------"
    echo -e "${CYAN}项目目录:${NC} $PROJECT_DIR"
    echo -e "${CYAN}服务器IP:${NC} $SERVER_IP"
    echo -e "${CYAN}服务器用户:${NC} $SERVER_USER"
    echo -e "${CYAN}部署路径:${NC} $DEPLOY_PATH"
    echo -e "${CYAN}部署包:${NC} $DEPLOY_PACKAGE"
    echo ""
}

# 主函数
main() {
    case "${1:-}" in
        --prepare)
            show_deployment_info
            prepare_deploy_package
            ;;
        --upload)
            show_deployment_info
            upload_to_server
            ;;
        --deploy)
            show_deployment_info
            full_deploy
            ;;
        --check)
            show_deployment_info
            check_deployment
            ;;
        --help|*)
            show_help
            ;;
    esac
}

# 运行主函数
main "$@"
