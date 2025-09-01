#!/bin/bash

# ImagentX 快速域名配置脚本
# 一键完成 Cloudflare Tunnel 配置

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
    echo -e "${CYAN}║${NC}  🚀 ImagentX Cloudflare Tunnel 快速配置${NC}          ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}  一键完成域名和隧道配置                           ${CYAN}║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# 检查当前路径
check_paths() {
    print_info "检查路径..."
    
    # 获取实际用户名
    USERNAME=$(whoami)
    PROJECT_DIR="/Users/$USERNAME/Downloads/ImagentX-master"
    CLOUDFLARE_DIR="/Users/$USERNAME/.cloudflared"
    
    print_info "当前用户: $USERNAME"
    print_info "项目目录: $PROJECT_DIR"
    print_info "配置目录: $CLOUDFLARE_DIR"
    
    # 创建目录
    mkdir -p "$CLOUDFLARE_DIR"
}

# 快速域名配置
quick_domain_setup() {
    print_header
    check_paths
    
    echo -e "${BLUE}📋 快速配置步骤${NC}"
    echo ""
    
    # 检查服务
    print_info "检查本地服务..."
    if lsof -Pi :3002 -sTCP:LISTEN -t >/dev/null 2>&1; then
        print_success "前端服务运行中 (端口3002) ✓"
    else
        print_error "前端服务未运行"
        echo "运行: cd apps/frontend && npm run dev"
        exit 1
    fi
    
    if lsof -Pi :8088 -sTCP:LISTEN -t >/dev/null 2>&1; then
        print_success "后端服务运行中 (端口8088) ✓"
    else
        print_error "后端服务未运行"
        echo "运行: cd apps/backend && ./mvnw spring-boot:run"
        exit 1
    fi
    
    echo ""
    read -p "请输入你的完整域名 (例如: yourdomain.com): " DOMAIN
    
    if [[ -z "$DOMAIN" ]]; then
        print_error "域名不能为空"
        exit 1
    fi
    
    # 清理域名
    DOMAIN=$(echo "$DOMAIN" | sed 's|https://||g' | sed 's|http://||g' | sed 's|/||g')
    
    echo ""
    print_info "域名配置:"
    echo "- 前端: imagentx.$DOMAIN"
    echo "- 后端: api.$DOMAIN"
    echo ""
    
    read -p "确认配置? (y/n): " CONFIRM
    if [[ "$CONFIRM" != "y" && "$CONFIRM" != "Y" ]]; then
        print_warning "配置取消"
        exit 1
    fi
    
    # 创建配置文件
    create_config "$DOMAIN"
    
    # 创建启动脚本
    create_start_script "$DOMAIN"
    
    # 创建测试脚本
    create_test_script "$DOMAIN"
    
    print_success "🎉 配置完成！"
    echo ""
    print_info "访问地址:"
    echo "- 前端: https://imagentx.$DOMAIN"
    echo "- 后端: https://api.$DOMAIN"
    echo ""
    print_info "使用命令:"
    echo "- 启动: /Users/$USERNAME/.cloudflared/start.sh"
    echo "- 测试: /Users/$USERNAME/.cloudflared/test.sh"
    echo "- 状态: /Users/$USERNAME/.cloudflared/status.sh"
}

# 创建配置文件
create_config() {
    local domain=$1
    
    cat > "/Users/$(whoami)/.cloudflared/config.yml" << EOF
# ImagentX Cloudflare Tunnel 配置
tunnel: imagentx-tunnel
credentials-file: /Users/$(whoami)/.cloudflared/imagentx-tunnel.json

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
}

# 创建启动脚本
create_start_script() {
    local domain=$1
    local username=$(whoami)
    
    cat > "/Users/$username/.cloudflared/start.sh" << EOF
#!/bin/bash
# ImagentX 一键启动脚本

echo "🚀 启动 ImagentX Cloudflare Tunnel"
echo "前端: https://imagentx.$domain"
echo "后端: https://api.$domain"
echo ""

# 检查服务
if ! lsof -Pi :3002 -sTCP:LISTEN -t >/dev/null 2>&1; then
    echo "❌ 前端服务未运行 (端口3002)"
    echo "启动: cd /Users/$username/Downloads/ImagentX-master/apps/frontend && npm run dev"
    exit 1
fi

if ! lsof -Pi :8088 -sTCP:LISTEN -t >/dev/null 2>&1; then
    echo "❌ 后端服务未运行 (端口8088)"
    echo "启动: cd /Users/$username/Downloads/ImagentX-master/apps/backend && ./mvnw spring-boot:run"
    exit 1
fi

echo "✅ 本地服务检查通过"
echo "启动隧道..."

# 检查隧道是否存在
if ! cloudflared tunnel list 2>/dev/null | grep -q "imagentx-tunnel"; then
    echo "创建隧道..."
    cloudflared tunnel create imagentx-tunnel
fi

# 配置DNS路由
cloudflared tunnel route dns imagentx-tunnel imagentx.$domain
cloudflared tunnel route dns imagentx-tunnel api.$domain

# 启动隧道
cloudflared tunnel --config /Users/$username/.cloudflared/config.yml run imagentx-tunnel
EOF
    
    chmod +x "/Users/$username/.cloudflared/start.sh"
    print_success "启动脚本已创建 ✓"
}

# 创建测试脚本
create_test_script() {
    local domain=$1
    local username=$(whoami)
    
    cat > "/Users/$username/.cloudflared/test.sh" << EOF
#!/bin/bash
# ImagentX 一键测试脚本

echo "🧪 测试 ImagentX 服务"
echo ""

echo "本地服务:"
echo "前端 (3002): \$(lsof -Pi :3002 -sTCP:LISTEN -t >/dev/null && echo '运行中 ✓' || echo '未运行 ✗')"
echo "后端 (8088): \$(lsof -Pi :8088 -sTCP:LISTEN -t >/dev/null && echo '运行中 ✓' || echo '未运行 ✗')"

echo ""
echo "Cloudflare Tunnel:"
echo "进程状态: \$(pgrep -f "cloudflared.*tunnel" >/dev/null && echo '运行中 ✓' || echo '未运行 ✗')"

echo ""
echo "访问地址:"
echo "- 前端: https://imagentx.$domain"
echo "- 后端: https://api.$domain"

echo ""
echo "测试命令:"
echo "curl -I https://imagentx.$domain"
echo "curl -I https://api.$domain"
EOF
    
    chmod +x "/Users/$username/.cloudflared/test.sh"
    print_success "测试脚本已创建 ✓"
}

# 主流程
main() {
    quick_domain_setup
}

main "$@"