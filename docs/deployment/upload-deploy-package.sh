#!/bin/bash

# 部署包上传脚本
# 用于将ImagentX部署包上传到服务器

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 配置变量
SERVER_IP="103.151.173.98"
SERVER_USER="root"
DEPLOY_PACKAGE="imagentx-deploy.tar.gz"
SSH_CONFIG_HOST="imagentx-server"

# 显示帮助信息
show_help() {
    echo -e "${BLUE}📤 部署包上传脚本${NC}"
    echo "================================"
    echo -e "${GREEN}用法: ./upload-deploy-package.sh [选项]${NC}"
    echo ""
    echo -e "${CYAN}上传选项:${NC}"
    echo -e "  ${GREEN}--upload${NC}       上传部署包到服务器"
    echo -e "  ${GREEN}--test${NC}         测试SSH连接"
    echo -e "  ${GREEN}--setup${NC}        在服务器上设置部署环境"
    echo -e "  ${GREEN}--deploy${NC}       在服务器上执行部署"
    echo -e "  ${GREEN}--help${NC}         显示此帮助信息"
    echo ""
    echo -e "${CYAN}示例:${NC}"
    echo -e "  ./upload-deploy-package.sh --test      # 测试连接"
    echo -e "  ./upload-deploy-package.sh --upload    # 上传部署包"
    echo ""
}

# 检查部署包是否存在
check_deploy_package() {
    if [ ! -f "$DEPLOY_PACKAGE" ]; then
        echo -e "${RED}❌ 部署包不存在: $DEPLOY_PACKAGE${NC}"
        exit 1
    fi
    
    # 获取文件大小
    SIZE=$(du -h "$DEPLOY_PACKAGE" | cut -f1)
    echo -e "${GREEN}✅ 部署包存在: $DEPLOY_PACKAGE (${SIZE})${NC}"
}

# 检查SSH密钥
check_ssh_key() {
    if [ ! -f ~/.ssh/id_rsa ]; then
        echo -e "${RED}❌ SSH密钥不存在${NC}"
        echo -e "${YELLOW}请先生成SSH密钥或联系服务器管理员添加您的公钥${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✅ SSH密钥存在${NC}"
}

# 测试SSH连接
test_ssh_connection() {
    echo -e "${BLUE}🔌 测试SSH连接${NC}"
    echo "--------------------------------"
    
    check_ssh_key
    
    echo -e "${CYAN}测试连接到服务器...${NC}"
    
    if ssh -o ConnectTimeout=10 -o BatchMode=yes $SSH_CONFIG_HOST "echo 'SSH连接测试成功'" 2>/dev/null; then
        echo -e "${GREEN}✅ SSH连接成功${NC}"
        return 0
    else
        echo -e "${RED}❌ SSH连接失败${NC}"
        echo -e "${YELLOW}可能的原因:${NC}"
        echo -e "${YELLOW}1. SSH密钥未添加到服务器${NC}"
        echo -e "${YELLOW}2. 服务器防火墙阻止连接${NC}"
        echo -e "${YELLOW}3. SSH服务未运行${NC}"
        echo ""
        echo -e "${CYAN}您的公钥:${NC}"
        cat ~/.ssh/id_rsa.pub
        echo ""
        echo -e "${YELLOW}请将此公钥添加到服务器的 ~/.ssh/authorized_keys 文件中${NC}"
        return 1
    fi
}

# 上传部署包
upload_deploy_package() {
    echo -e "${BLUE}📤 上传部署包${NC}"
    echo "--------------------------------"
    
    check_deploy_package
    check_ssh_key
    
    echo -e "${CYAN}上传部署包到服务器...${NC}"
    
    # 创建远程目录
    ssh $SSH_CONFIG_HOST "mkdir -p /opt"
    
    # 上传文件
    if scp "$DEPLOY_PACKAGE" $SSH_CONFIG_HOST:/opt/; then
        echo -e "${GREEN}✅ 部署包上传成功${NC}"
        
        # 验证上传
        echo -e "${CYAN}验证上传...${NC}"
        ssh $SSH_CONFIG_HOST "ls -lh /opt/$DEPLOY_PACKAGE"
    else
        echo -e "${RED}❌ 部署包上传失败${NC}"
        exit 1
    fi
}

# 在服务器上设置部署环境
setup_deploy_environment() {
    echo -e "${BLUE}🔧 设置部署环境${NC}"
    echo "--------------------------------"
    
    echo -e "${CYAN}在服务器上设置部署环境...${NC}"
    
    ssh $SSH_CONFIG_HOST << 'EOF'
        # 创建部署目录
        mkdir -p /opt/imagentx
        cd /opt/imagentx
        
        # 解压部署包
        if [ -f "/opt/imagentx-deploy.tar.gz" ]; then
            echo "解压部署包..."
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
        
        echo "✅ 部署环境设置完成"
EOF
    
    echo -e "${GREEN}✅ 部署环境设置完成${NC}"
}

# 在服务器上执行部署
execute_deployment() {
    echo -e "${BLUE}🚀 执行部署${NC}"
    echo "--------------------------------"
    
    echo -e "${CYAN}在服务器上执行部署...${NC}"
    
    ssh $SSH_CONFIG_HOST << 'EOF'
        cd /opt/imagentx
        
        # 设置服务器环境
        echo "设置服务器环境..."
        ./quick-deploy.sh --setup
        
        # 部署项目
        echo "部署项目..."
        ./quick-deploy.sh --deploy
        
        # 检查部署状态
        echo "检查部署状态..."
        ./quick-deploy.sh --status
        
        echo "✅ 部署完成"
EOF
    
    echo -e "${GREEN}✅ 部署执行完成${NC}"
}

# 显示服务器信息
show_server_info() {
    echo -e "${BLUE}📋 服务器信息${NC}"
    echo "--------------------------------"
    echo -e "${CYAN}服务器IP:${NC} $SERVER_IP"
    echo -e "${CYAN}用户名:${NC} $SERVER_USER"
    echo -e "${CYAN}SSH配置:${NC} $SSH_CONFIG_HOST"
    echo -e "${CYAN}部署包:${NC} $DEPLOY_PACKAGE"
    echo ""
}

# 主函数
main() {
    case "${1:-}" in
        --test)
            show_server_info
            test_ssh_connection
            ;;
        --upload)
            show_server_info
            upload_deploy_package
            ;;
        --setup)
            show_server_info
            setup_deploy_environment
            ;;
        --deploy)
            show_server_info
            execute_deployment
            ;;
        --help|*)
            show_help
            ;;
    esac
}

# 运行主函数
main "$@"
