#!/bin/bash

# 修复 Cloudflare 证书问题的完整解决方案

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
    echo -e "${CYAN}║${NC}  🔧 Cloudflare 证书问题修复${NC}                      ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}  解决 cert.pem 缺失问题${NC}                        ${CYAN}║${NC}"
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

# 检查并修复证书
check_and_fix_certificate() {
    print_info "检查证书状态..."
    
    if [ -f "$CLOUDFLARE_DIR/cert.pem" ]; then
        print_success "证书文件已存在 ✓"
        return 0
    fi
    
    print_warning "未找到证书文件 cert.pem"
    echo ""
    echo "📋 需要完成以下步骤："
    echo ""
    echo "1️⃣ 运行登录命令："
    echo "   cloudflared tunnel login"
    echo ""
    echo "2️⃣ 浏览器会打开 Cloudflare 登录页面"
    echo "3️⃣ 登录你的 Cloudflare 账户"
    echo "4️⃣ 选择要管理的域名"
    echo "5️⃣ 授权完成后，证书会自动下载"
    echo ""
    
    read -p "现在运行登录命令? (y/n): " RUN_LOGIN
    
    if [[ "$RUN_LOGIN" == "y" || "$RUN_LOGIN" == "Y" ]]; then
        print_info "运行登录命令..."
        cloudflared tunnel login
        
        # 再次检查证书
        if [ -f "$CLOUDFLARE_DIR/cert.pem" ]; then
            print_success "证书获取成功 ✓"
        else
            print_error "证书仍未获取，请手动运行: cloudflared tunnel login"
            exit 1
        fi
    else
        print_info "请手动运行: cloudflared tunnel login"
        exit 1
    fi
}

# 检查隧道状态
check_tunnel_status() {
    print_info "检查隧道状态..."
    
    # 检查隧道列表
    if command -v cloudflared &> /dev/null; then
        print_info "当前隧道列表："
        cloudflared tunnel list 2>/dev/null || echo "暂无隧道"
    else
        print_error "cloudflared 未安装"
        exit 1
    fi
}

# 创建隧道
create_tunnel() {
    print_info "创建或检查隧道..."
    
    TUNNEL_NAME="imagentx-tunnel"
    
    # 检查隧道是否存在
    if cloudflared tunnel list 2>/dev/null | grep -q "$TUNNEL_NAME"; then
        print_info "隧道已存在，获取信息..."
        TUNNEL_ID=$(cloudflared tunnel list | grep "$TUNNEL_NAME" | awk '{print $1}')
        echo "$TUNNEL_ID" > "$CLOUDFLARE_DIR/tunnel-id.txt"
        print_success "隧道ID: $TUNNEL_ID"
    else
        print_info "创建新隧道..."
        
        # 创建隧道
        TUNNEL_ID=$(cloudflared tunnel create "$TUNNEL_NAME" 2>&1 | grep -o 'Created tunnel [^ ]* with id [^ ]*' | awk '{print $NF}' || echo "")
        
        if [[ -z "$TUNNEL_ID" ]]; then
            print_error "隧道创建失败"
            echo "请检查："
            echo "1. 是否已完成 cloudflared tunnel login"
            echo "2. 网络连接是否正常"
            echo "3. 是否有权限创建隧道"
            exit 1
        fi
        
        echo "$TUNNEL_ID" > "$CLOUDFLARE_DIR/tunnel-id.txt"
        print_success "隧道创建成功 ✓"
        print_info "隧道ID: $TUNNEL_ID"
    fi
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
    
    # 保存域名配置
    echo "$DOMAIN" > "$CLOUDFLARE_DIR/domain.txt"
    echo "$FRONTEND_DOMAIN" > "$CLOUDFLARE_DIR/frontend-domain.txt"
    echo "$BACKEND_DOMAIN" > "$CLOUDFLARE_DIR/backend-domain.txt"
    
    # 配置DNS路由
    print_info "配置 DNS 路由..."
    cloudflared tunnel route dns imagentx-tunnel "$FRONTEND_DOMAIN"
    cloudflared tunnel route dns imagentx-tunnel "$BACKEND_DOMAIN"
    
    print_success "DNS 路由配置完成 ✓"
}

# 创建配置文件
create_config() {
    local tunnel_id=$(cat "$CLOUDFLARE_DIR/tunnel-id.txt")
    local domain=$(cat "$CLOUDFLARE_DIR/domain.txt")
    
    cat > "$CLOUDFLARE_DIR/config.yml" << EOF
# ImagentX Cloudflare Tunnel 配置
tunnel: $tunnel_id
credentials-file: $CLOUDFLARE_DIR/$tunnel_id.json

# 证书路径（重要！）
origincert: $CLOUDFLARE_DIR/cert.pem

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
  - hostname: imagentx.$domain
    service: http://localhost:3002
    originRequest:
      httpHostHeader: imagentx.$domain
      
  # 后端API
  - hostname: api.$domain
    service: http://localhost:8088
    originRequest:
      httpHostHeader: api.$domain
      
  # 默认404
  - service: http_status:404
EOF
    
    print_success "配置文件已创建 ✓"
    print_info "配置文件: $CLOUDFLARE_DIR/config.yml"
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

# 检查证书
if [ ! -f "$CLOUDFLARE_DIR/cert.pem" ]; then
    echo "❌ 证书文件不存在，请先运行："
    echo "   cloudflared tunnel login"
    exit 1
fi

# 检查配置文件
if [ ! -f "$CLOUDFLARE_DIR/config.yml" ]; then
    echo "❌ 配置文件不存在，请重新运行配置脚本"
    exit 1
fi

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

# 创建状态检查脚本
create_status_script() {
    cat > "$CLOUDFLARE_DIR/status.sh" << 'EOF'
#!/bin/bash
# ImagentX 状态检查脚本

USERNAME=$(whoami)
CLOUDFLARE_DIR="/Users/$USERNAME/.cloudflared"

echo "📊 ImagentX 状态报告"
echo "========================"
echo ""

echo "🖥️  系统信息:"
echo "用户: $USERNAME"
echo "配置目录: $CLOUDFLARE_DIR"
echo ""

echo "🔧 服务状态:"
echo "前端 (3002): $(lsof -Pi :3002 -sTCP:LISTEN -t >/dev/null && echo '运行中 ✓' || echo '未运行 ✗')"
echo "后端 (8088): $(lsof -Pi :8088 -sTCP:LISTEN -t >/dev/null && echo '运行中 ✓' || echo '未运行 ✗')"
echo ""

echo "🌐 Cloudflare 状态:"
echo "证书文件: $([ -f "$CLOUDFLARE_DIR/cert.pem" ] && echo '存在 ✓' || echo '不存在 ✗')"
echo "配置文件: $([ -f "$CLOUDFLARE_DIR/config.yml" ] && echo '存在 ✓' || echo '不存在 ✗')"
echo "隧道ID: $([ -f "$CLOUDFLARE_DIR/tunnel-id.txt" ] && echo "$(cat $CLOUDFLARE_DIR/tunnel-id.txt)" || echo '未创建')"
echo "域名: $([ -f "$CLOUDFLARE_DIR/domain.txt" ] && echo "$(cat $CLOUDFLARE_DIR/domain.txt)" || echo '未配置')"
echo ""

echo "📁 文件列表:"
ls -la "$CLOUDFLARE_DIR" | grep -E "(cert.pem|config.yml|tunnel-id.txt|domain.txt)"
echo ""

echo "🚀 使用命令:"
echo "- 启动隧道: $CLOUDFLARE_DIR/start.sh"
echo "- 检查状态: $CLOUDFLARE_DIR/status.sh"
echo "- 登录Cloudflare: cloudflared tunnel login"
EOF
    
    chmod +x "$CLOUDFLARE_DIR/status.sh"
    print_success "状态脚本已创建 ✓"
}

# 主流程
main() {
    print_header
    get_user_info
    check_and_fix_certificate
    check_tunnel_status
    create_tunnel
    setup_domain
    create_config
    create_start_script
    create_status_script
    
    echo ""
    print_success "🎉 证书问题修复完成！"
    echo ""
    echo "📋 下一步操作："
    echo "1. 检查状态: $CLOUDFLARE_DIR/status.sh"
    echo "2. 启动隧道: $CLOUDFLARE_DIR/start.sh"
    echo "3. 如果证书仍有问题，运行: cloudflared tunnel login"
    echo ""
}

main "$@"