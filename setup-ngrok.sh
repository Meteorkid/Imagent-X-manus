#!/bin/bash

# ngrok内网穿透设置脚本
# 用于临时让外网访问本地ImagentX服务

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 显示帮助信息
show_help() {
    echo -e "${BLUE}🌐 ngrok内网穿透设置脚本${NC}"
    echo "=================================="
    echo -e "${GREEN}用法: ./setup-ngrok.sh [选项]${NC}"
    echo ""
    echo -e "${CYAN}选项:${NC}"
    echo -e "  ${GREEN}--install${NC}     安装ngrok"
    echo -e "  ${GREEN}--config${NC}      配置ngrok token"
    echo -e "  ${GREEN}--start${NC}       启动内网穿透"
    echo -e "  ${GREEN}--help${NC}        显示此帮助信息"
    echo ""
    echo -e "${YELLOW}注意: 此方案仅用于临时测试，不适合生产环境${NC}"
}

# 检查ngrok是否已安装
check_ngrok_installed() {
    if command -v ngrok &> /dev/null; then
        echo -e "${GREEN}✅ ngrok已安装${NC}"
        return 0
    else
        echo -e "${RED}❌ ngrok未安装${NC}"
        return 1
    fi
}

# 安装ngrok
install_ngrok() {
    echo -e "${BLUE}📦 安装ngrok...${NC}"
    
    if check_ngrok_installed; then
        echo -e "${YELLOW}ngrok已安装，跳过安装步骤${NC}"
        return 0
    fi
    
    # 检查是否安装了Homebrew
    if ! command -v brew &> /dev/null; then
        echo -e "${RED}❌ 未安装Homebrew，请先安装Homebrew${NC}"
        echo -e "${CYAN}安装命令:${NC}"
        echo -e "${YELLOW}/bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\"${NC}"
        exit 1
    fi
    
    # 使用Homebrew安装ngrok
    echo -e "${CYAN}使用Homebrew安装ngrok...${NC}"
    brew install ngrok
    
    if check_ngrok_installed; then
        echo -e "${GREEN}✅ ngrok安装成功${NC}"
    else
        echo -e "${RED}❌ ngrok安装失败${NC}"
        exit 1
    fi
}

# 配置ngrok token
config_ngrok() {
    echo -e "${BLUE}🔧 配置ngrok token${NC}"
    echo "--------------------------------"
    
    if ! check_ngrok_installed; then
        echo -e "${RED}请先安装ngrok: ./setup-ngrok.sh --install${NC}"
        exit 1
    fi
    
    echo -e "${YELLOW}⚠️  您需要先注册ngrok账号获取token${NC}"
    echo -e "${CYAN}注册步骤:${NC}"
    echo -e "${CYAN}1. 访问 https://ngrok.com/ ${NC}"
    echo -e "${CYAN}2. 点击 'Sign up for free' 注册账号${NC}"
    echo -e "${CYAN}3. 登录后进入 'Your Authtoken' 页面${NC}"
    echo -e "${CYAN}4. 复制您的authtoken${NC}"
    echo ""
    
    read -p "请输入您的ngrok authtoken: " ngrok_token
    
    if [ -z "$ngrok_token" ]; then
        echo -e "${RED}❌ token不能为空${NC}"
        exit 1
    fi
    
    # 配置ngrok token
    echo -e "${CYAN}配置ngrok token...${NC}"
    ngrok config add-authtoken "$ngrok_token"
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ ngrok token配置成功${NC}"
    else
        echo -e "${RED}❌ ngrok token配置失败${NC}"
        exit 1
    fi
}

# 检查本地服务状态
check_local_services() {
    echo -e "${CYAN}🔍 检查本地服务状态...${NC}"
    
    # 检查80端口
    if lsof -i :80 >/dev/null 2>&1; then
        echo -e "${GREEN}✅ 端口80有服务运行${NC}"
        return 0
    fi
    
    # 检查3000端口
    if lsof -i :3000 >/dev/null 2>&1; then
        echo -e "${GREEN}✅ 端口3000有服务运行${NC}"
        return 0
    fi
    
    echo -e "${RED}❌ 未检测到本地服务运行${NC}"
    echo -e "${YELLOW}请先启动ImagentX服务:${NC}"
    echo -e "${CYAN}./scripts/core/start.sh --production${NC}"
    return 1
}

# 启动内网穿透
start_ngrok() {
    echo -e "${BLUE}🚀 启动内网穿透${NC}"
    echo "--------------------------------"
    
    if ! check_ngrok_installed; then
        echo -e "${RED}请先安装ngrok: ./setup-ngrok.sh --install${NC}"
        exit 1
    fi
    
    # 检查token是否配置
    if ! ngrok config check >/dev/null 2>&1; then
        echo -e "${RED}请先配置ngrok token: ./setup-ngrok.sh --config${NC}"
        exit 1
    fi
    
    # 检查本地服务
    if ! check_local_services; then
        exit 1
    fi
    
    echo -e "${CYAN}选择要穿透的端口:${NC}"
    echo -e "${CYAN}1. 端口80 (如果Nginx运行在80端口)${NC}"
    echo -e "${CYAN}2. 端口3000 (如果前端运行在3000端口)${NC}"
    echo -e "${CYAN}3. 端口8080 (如果后端运行在8080端口)${NC}"
    echo ""
    
    read -p "请选择端口 (1/2/3): " port_choice
    
    case $port_choice in
        1)
            port=80
            ;;
        2)
            port=3000
            ;;
        3)
            port=8080
            ;;
        *)
            echo -e "${RED}❌ 无效选择${NC}"
            exit 1
            ;;
    esac
    
    echo -e "${GREEN}🎉 启动ngrok内网穿透...${NC}"
    echo -e "${CYAN}穿透端口: $port${NC}"
    echo -e "${YELLOW}注意: 请保持此终端窗口打开${NC}"
    echo -e "${YELLOW}ngrok会显示公网访问地址${NC}"
    echo ""
    echo -e "${GREEN}按 Ctrl+C 停止内网穿透${NC}"
    echo "--------------------------------"
    
    # 启动ngrok
    ngrok http $port
}

# 显示使用说明
show_usage_info() {
    echo -e "${BLUE}📖 使用说明${NC}"
    echo "=================="
    echo -e "${CYAN}1. 安装ngrok:${NC}"
    echo -e "${YELLOW}   ./setup-ngrok.sh --install${NC}"
    echo ""
    echo -e "${CYAN}2. 配置token:${NC}"
    echo -e "${YELLOW}   ./setup-ngrok.sh --config${NC}"
    echo ""
    echo -e "${CYAN}3. 启动本地服务:${NC}"
    echo -e "${YELLOW}   ./scripts/core/start.sh --production${NC}"
    echo ""
    echo -e "${CYAN}4. 启动内网穿透:${NC}"
    echo -e "${YELLOW}   ./setup-ngrok.sh --start${NC}"
    echo ""
    echo -e "${CYAN}5. 配置域名解析:${NC}"
    echo -e "${YELLOW}   将域名解析到ngrok提供的IP地址${NC}"
    echo ""
    echo -e "${YELLOW}⚠️  注意: 此方案仅用于临时测试${NC}"
    echo -e "${YELLOW}   生产环境建议使用云服务器部署${NC}"
}

# 主函数
main() {
    case "${1:-}" in
        --install)
            install_ngrok
            ;;
        --config)
            config_ngrok
            ;;
        --start)
            start_ngrok
            ;;
        --help|*)
            show_help
            echo ""
            show_usage_info
            ;;
    esac
}

# 运行主函数
main "$@"
