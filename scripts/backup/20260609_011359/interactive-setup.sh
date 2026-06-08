#!/bin/bash

# ImagentX Cloudflare Tunnel 交互式配置助手

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_header() {
    echo -e "${BLUE}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                ImagentX Cloudflare Tunnel                  ║"
    echo "║                   交互式配置助手                          ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

print_step() {
    echo -e "${GREEN}[步骤 $1]${NC} $2"
}

print_info() {
    echo -e "${BLUE}[信息]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[警告]${NC} $1"
}

print_error() {
    echo -e "${RED}[错误]${NC} $1"
}

# 检查依赖
check_dependencies() {
    print_step "1" "检查依赖项"
    
    if command -v cloudflared &> /dev/null; then
        print_info "cloudflared 已安装 ✅"
    else
        print_error "cloudflared 未安装，请先运行: brew install cloudflared"
        exit 1
    fi
    
    # 检查服务
    if lsof -Pi :3002 -sTCP:LISTEN -t >/dev/null 2>&1; then
        print_info "前端服务正在运行 ✅"
    else
        print_error "前端服务未运行，请先启动"
        exit 1
    fi
    
    if lsof -Pi :8088 -sTCP:LISTEN -t >/dev/null 2>&1; then
        print_info "后端服务正在运行 ✅"
    else
        print_error "后端服务未运行，请先启动"
        exit 1
    fi
}

# 获取用户输入
get_user_input() {
    print_step "2" "获取配置信息"
    
    echo ""
    echo "请选择域名来源:"
    echo "1) 已有Cloudflare域名"
    echo "2) 需要注册新域名"
    echo "3) 使用免费域名(freenom.com)"
    read -p "选择 [1-3]: " domain_choice
    
    read -p "请输入你的域名 (如: yourdomain.com): " DOMAIN
    if [[ -z "$DOMAIN" ]]; then
        print_error "域名不能为空"
        exit 1
    fi
    
    read -p "请输入子域名前缀 [imagentx]: " SUBDOMAIN
    SUBDOMAIN=${SUBDOMAIN:-imagentx}
    
    FRONTEND_HOST="${SUBDOMAIN}.${DOMAIN}"
    BACKEND_HOST="api.${SUBDOMAIN}.${DOMAIN}"
    
    print_info "配置域名:"
    print_info "  前端: $FRONTEND_HOST"
    print_info "  后端: $BACKEND_HOST"
}

# 登录Cloudflare
cloudflare_login() {
    print_step "3" "登录Cloudflare"
    
    print_info "正在打开浏览器进行登录..."
    print_info "请按照以下步骤操作:"
    echo ""
    echo "1. 浏览器将打开Cloudflare登录页面"
    echo "2. 登录你的Cloudflare账户"
    echo "3. 选择一个域名进行授权"
    echo "4. 完成后返回此终端"
    echo ""
    
    read -p "按回车键继续..."
    
    cloudflared tunnel login
    
    if [ $? -eq 0 ]; then
        print_info "登录成功 ✅"
    else
        print_error "登录失败，请重试"
        exit 1
    fi
}

# 创建隧道
create_tunnel() {
    print_step "4" "创建隧道"
    
    print_info "创建名为 'imagentx-tunnel' 的隧道..."
    
    TUNNEL_OUTPUT=$(cloudflared tunnel create imagentx-tunnel 2>&1)
    TUNNEL_ID=$(echo "$TUNNEL_OUTPUT" | grep -oE '[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}')
    
    if [[ -n "$TUNNEL_ID" ]]; then
        print_info "隧道创建成功 ✅"
        print_info "隧道ID: $TUNNEL_ID"
    else
        print_error "隧道创建失败"
        echo "$TUNNEL_OUTPUT"
        exit 1
    fi
}

# 配置DNS
configure_dns() {
    print_step "5" "配置DNS记录"
    
    print_info "正在配置DNS记录..."
    
    cloudflared tunnel route dns imagentx-tunnel "$FRONTEND_HOST"
    cloudflared tunnel route dns imagentx-tunnel "$BACKEND_HOST"
    
    print_info "DNS记录配置完成 ✅"
}

# 创建配置文件
create_config() {
    print_step "6" "创建配置文件"
    
    CONFIG_DIR="$HOME/.cloudflared"
    CONFIG_FILE="$CONFIG_DIR/config.yml"
    
    cat > "$CONFIG_FILE" << EOF
tunnel: $TUNNEL_ID
credentials-file: $CONFIG_DIR/$TUNNEL_ID.json

ingress:
  # 前端服务
  - hostname: $FRONTEND_HOST
    service: http://localhost:3002
  
  # 后端API服务
  - hostname: $BACKEND_HOST
    service: http://localhost:8088
    
  # 默认404页面
  - service: http_status:404
EOF
    
    print_info "配置文件已创建: $CONFIG_FILE"
}

# 启动隧道
start_tunnel() {
    print_step "7" "启动隧道"
    
    print_info "正在启动Cloudflare Tunnel..."
    
    # 创建启动脚本
    START_SCRIPT="$HOME/.cloudflared/start-tunnel.sh"
    cat > "$START_SCRIPT" << EOF
#!/bin/bash
echo "🚀 启动 ImagentX Cloudflare Tunnel..."
echo "前端访问: https://$FRONTEND_HOST"
echo "后端API访问: https://$BACKEND_HOST/api"
echo ""
cloudflared tunnel run imagentx-tunnel
EOF
    chmod +x "$START_SCRIPT"
    
    print_info "启动脚本已创建: $START_SCRIPT"
    print_info "运行以下命令启动隧道:"
    echo "  $START_SCRIPT"
}

# 测试连接
test_connection() {
    print_step "8" "测试连接"
    
    print_info "等待DNS传播..."
    echo "这通常需要1-5分钟"
    
    # 创建测试脚本
    TEST_SCRIPT="$HOME/.cloudflared/test-tunnel.sh"
    cat > "$TEST_SCRIPT" << EOF
#!/bin/bash
echo "🧪 测试 ImagentX Cloudflare Tunnel..."
echo ""
echo "📱 访问地址:"
echo "  前端: https://$FRONTEND_HOST"
echo "  后端API: https://$BACKEND_HOST/api"
echo ""
echo "测试命令:"
echo "  curl -I https://$FRONTEND_HOST"
echo "  curl -I https://$BACKEND_HOST/api/actuator/health"
echo ""
echo "浏览器测试:"
echo "  open https://$FRONTEND_HOST"
EOF
    chmod +x "$TEST_SCRIPT"
    
    print_info "测试脚本已创建: $TEST_SCRIPT"
}

# 主流程
main() {
    print_header
    
    check_dependencies
    get_user_input
    
    echo ""
    echo "🎯 开始配置..."
    echo ""
    
    cloudflare_login
    create_tunnel
    configure_dns
    create_config
    start_tunnel
    test_connection
    
    print_step "9" "配置完成!"
    
    echo ""
    echo -e "${GREEN}🎉 配置完成!${NC}"
    echo ""
    echo "🔗 最终访问地址:"
    echo "  前端界面: https://$FRONTEND_HOST"
    echo "  后端API: https://$BACKEND_HOST/api"
    echo ""
    echo "📋 后续操作:"
    echo "1. 运行: $START_SCRIPT (启动隧道)"
    echo "2. 运行: $TEST_SCRIPT (测试连接)"
    echo "3. 分享: https://$FRONTEND_HOST (给其他用户)"
    echo ""
    echo "⚠️  注意事项:"
    echo "- DNS传播可能需要1-5分钟"
    echo "- 确保服务一直在运行"
    echo "- 隧道启动后可通过浏览器访问"
}

# 运行主程序
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi