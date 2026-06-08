#!/bin/bash

# Cloudflare Tunnel 完整配置脚本（含证书配置）

set -e

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_header() {
    echo -e "${CYAN}╔══════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC}  🚀 Cloudflare Tunnel 完整配置${NC}                   ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}  包含证书配置和域名设置${NC}                        ${CYAN}║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# 获取用户信息
get_user_info() {
    USERNAME=$(whoami)
    CLOUDFLARE_DIR="/Users/$USERNAME/.cloudflared"
    
    print_info "当前用户: $USERNAME"
    print_info "配置目录: $CLOUDFLARE_DIR"
    
    mkdir -p "$CLOUDFLARE_DIR"
}

# 检查证书
check_certificate() {
    print_info "检查 Cloudflare 证书..."
    
    if [ ! -f "$CLOUDFLARE_DIR/cert.pem" ]; then
        print_warning "未找到证书文件，需要登录 Cloudflare"
        echo ""
        echo "📋 请按以下步骤操作："
        echo "1. 运行: cloudflared tunnel login"
        echo "2. 浏览器会打开 Cloudflare 登录页面"
        echo "3. 登录你的 Cloudflare 账户"
        echo "4. 选择你的域名"
        echo "5. 完成后证书会自动下载到 ~/.cloudflared/cert.pem"
        echo ""
        
        read -p "完成登录后按回车继续..."
        
        if [ ! -f "$CLOUDFLARE_DIR/cert.pem" ]; then
            print_error "证书仍未找到，请重新运行 cloudflared tunnel login"
            exit 1
        fi
    fi
    
    print_success "证书已存在 ✓"
}

# 创建隧道
create_tunnel() {
    print_info "创建 Cloudflare 隧道..."
    
    TUNNEL_NAME="imagentx-tunnel"
    
    # 检查隧道是否已存在
    if cloudflared tunnel list 2>/dev/null | grep -q "$TUNNEL_NAME"; then
        print_info "隧道已存在，获取信息..."
        TUNNEL_ID=$(cloudflared tunnel list | grep "$TUNNEL_NAME" | awk '{print $1}')
    else
        print_info "创建新隧道..."
        TUNNEL_ID=$(cloudflared tunnel create "$TUNNEL_NAME" 2>&1 | grep -o 'Created tunnel [^ ]* with id [^ ]*' | awk '{print $NF}')
        if [[ -z "$TUNNEL_ID" ]]; then
            print_error "隧道创建失败"
            exit 1
        fi
    fi
    
    print_success "隧道创建成功 ✓"
    print_info "隧道ID: $TUNNEL_ID"
    
    # 保存隧道ID
    echo "$TUNNEL_ID" > "$CLOUDFLARE_DIR/tunnel-id.txt"
}

# 配置域名
setup_domain() {
    print_info "配置域名..."
    
    read -p "请输入你的完整域名 (例如: yourdomain.com): " DOMAIN
    
    if [[ -z "$DOMAIN" ]]; then
        print_error "域名不能为空"
        exit 1
    fi
    
    # 清理域名格式
    DOMAIN=$(echo "$DOMAIN" | sed 's|https://||g' | sed 's|http://||g' | sed 's|/||g')
    
    FRONTEND_DOMAIN="imagentx.$DOMAIN"
    BACKEND_DOMAIN="api.$DOMAIN"
    
    print_info "域名配置:"
    print_info "- 前端: $FRONTEND_DOMAIN"
    print_info "- 后端: $BACKEND_DOMAIN"
    
    read -p "确认配置? (y/n): " CONFIRM
    if [[ "$CONFIRM" != "y" && "$CONFIRM" != "Y" ]]; then
        print_warning "配置取消"
        exit 1
    fi
    
    # 配置DNS路由
    print_info "配置 DNS 路由..."
    cloudflared tunnel route dns imagentx-tunnel "$FRONTEND_DOMAIN"
    cloudflared tunnel route dns imagentx-tunnel "$BACKEND_DOMAIN"
    
    print_success "DNS 路由配置完成 ✓"
}

# 创建配置文件
create_config() {
    local tunnel_id=$(cat "$CLOUDFLARE_DIR/tunnel-id.txt")
    
    cat > "$CLOUDFLARE_DIR/config.yml" << EOF
# ImagentX Cloudflare Tunnel 配置
tunnel: $tunnel_id
credentials-file: $CLOUDFLARE_DIR/$tunnel_id.json

# 优化配置
originRequest:
  connectTimeout: 30s
  tlsTimeout: 10s
  tcpKeepAlive: 30s

compression: true
noTLSVerify: false

# 路由配置
ingress:
  # 前端应用
  - hostname: imagentx.$DOMAIN
    service: http://localhost:3002
    originRequest:
      httpHostHeader: imagentx.$DOMAIN
      
  # 后端API
  - hostname: api.$DOMAIN
    service: http://localhost:8088
    originRequest:
      httpHostHeader: api.$DOMAIN
      
  # 默认404
  - service: http_status:404
EOF
    
    print_success "配置文件已创建 ✓"
}

# 创建一键启动脚本
create_start_script() {
    cat > "$CLOUDFLARE_DIR/start.sh" << 'EOF'
#!/bin/bash
# ImagentX 一键启动脚本

USERNAME=$(whoami)
CLOUDFLARE_DIR="/Users/$USERNAME/.cloudflared"

echo "🚀 启动 ImagentX Cloudflare Tunnel"
echo ""

# 检查服务
if ! lsof -Pi :3002 -sTCP:LISTEN -t >/dev/null 2>&1; then
    echo "❌ 前端服务未运行 (端口3002)"
    echo "启动: cd /Users/$USERNAME/Downloads/ImagentX-master/apps/frontend && npm run dev"
    exit 1
fi

if ! lsof -Pi :8088 -sTCP:LISTEN -t >/dev/null 2>&1; then
    echo "❌ 后端服务未运行 (端口8088)"
    echo "启动: cd /Users/$USERNAME/Downloads/ImagentX-master/apps/backend && ./mvnw spring-boot:run"
    exit 1
fi

echo "✅ 本地服务检查通过"
echo "启动隧道..."

# 启动隧道
cloudflared tunnel --config "$CLOUDFLARE_DIR/config.yml" run imagentx-tunnel
EOF
    
    chmod +x "$CLOUDFLARE_DIR/start.sh"
    print_success "启动脚本已创建 ✓"
}

# 创建测试脚本
create_test_script() {
    cat > "$CLOUDFLARE_DIR/test.sh" << 'EOF'
#!/bin/bash
# ImagentX 测试脚本

USERNAME=$(whoami)
CLOUDFLARE_DIR="/Users/$USERNAME/.cloudflared"

echo "🧪 测试 ImagentX 服务状态"
echo ""

echo "本地服务:"
echo "前端 (3002): $(lsof -Pi :3002 -sTCP:LISTEN -t >/dev/null && echo '运行中 ✓' || echo '未运行 ✗')"
echo "后端 (8088): $(lsof -Pi :8088 -sTCP:LISTEN -t >/dev/null && echo '运行中 ✓' || echo '未运行 ✗')"

echo ""
echo "Cloudflare Tunnel:"
echo "进程状态: $(pgrep -f "cloudflared.*tunnel" >/dev/null && echo '运行中 ✓' || echo '未运行 ✗')"
echo "证书文件: $([ -f "$CLOUDFLARE_DIR/cert.pem" ] && echo '存在 ✓' || echo '不存在 ✗')"

echo ""
echo "配置文件:"
echo "隧道配置: $([ -f "$CLOUDFLARE_DIR/config.yml" ] && echo '存在 ✓' || echo '不存在 ✗')"
echo "隧道ID: $([ -f "$CLOUDFLARE_DIR/tunnel-id.txt" ] && echo "$(cat $CLOUDFLARE_DIR/tunnel-id.txt)" || echo '未创建')"

echo ""
echo "使用命令:"
echo "- 启动: $CLOUDFLARE_DIR/start.sh"
echo "- 测试: $CLOUDFLARE_DIR/test.sh"
EOF
    
    chmod +x "$CLOUDFLARE_DIR/test.sh"
    print_success "测试脚本已创建 ✓"
}

# 主流程
main() {
    print_header
    get_user_info
    check_certificate
    create_tunnel
    setup_domain
    create_config
    create_start_script
    create_test_script
    
    echo ""
    print_success "🎉 配置完成！"
    echo ""
    echo "📋 使用指南:"
    echo "1. 启动隧道: $CLOUDFLARE_DIR/start.sh"
    echo "2. 测试状态: $CLOUDFLARE_DIR/test.sh"
    echo "3. 访问地址:"
    echo "   - 前端: https://imagentx.$DOMAIN"
    echo "   - 后端: https://api.$DOMAIN"
    echo ""
}

main "$@"