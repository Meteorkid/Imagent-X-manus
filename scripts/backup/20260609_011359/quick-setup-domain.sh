#!/bin/bash

# 已有域名 Cloudflare Tunnel 快速配置脚本
# 一键完成域名配置和隧道设置

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

print_header() {
    echo -e "${PURPLE}╔══════════════════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}║${NC}  🚀 ${GREEN}已有域名 Cloudflare Tunnel 快速配置${NC}              ${PURPLE}║${NC}"
    echo -e "${PURPLE}║${NC}  一键完成域名配置和隧道设置                           ${PURPLE}║${NC}"
    echo -e "${PURPLE}╚══════════════════════════════════════════════════════╝${NC}"
    echo ""
}

print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

# 检查依赖
check_dependencies() {
    print_step "检查依赖..."
    
    if ! command -v cloudflared &> /dev/null; then
        print_warning "cloudflared 未安装，正在安装..."
        brew install cloudflared
    fi
    
    # 检查服务
    if ! lsof -Pi :3002 -sTCP:LISTEN -t >/dev/null 2>&1; then
        print_error "前端服务未运行，请先启动"
        echo "运行: cd apps/frontend && npm run dev"
        exit 1
    fi
    
    if ! lsof -Pi :8088 -sTCP:LISTEN -t >/dev/null 2>&1; then
        print_error "后端服务未运行，请先启动"
        echo "运行: cd apps/backend && ./mvnw spring-boot:run"
        exit 1
    fi
    
    print_success "所有依赖检查通过 ✓"
}

# 获取域名信息
get_domain() {
    print_step "域名配置"
    echo ""
    
    read -p "请输入你的完整域名 (如: yourdomain.com): " DOMAIN
    if [[ -z "$DOMAIN" ]]; then
        print_error "域名不能为空"
        exit 1
    fi
    
    # 清理域名格式
    DOMAIN=$(echo "$DOMAIN" | sed 's|https://||g' | sed 's|http://||g' | sed 's|www.||g' | sed 's|/||g')
    
    print_info "使用域名: $DOMAIN"
    
    # 子域名建议
    echo ""
    echo -e "${CYAN}子域名配置建议:${NC}"
    echo "  • 前端: imagentx.$DOMAIN"
    echo "  • 后端: api.$DOMAIN"
    echo "  • 管理: admin.$DOMAIN"
    echo ""
    
    read -p "前端子域名 [imagentx]: " FRONTEND_SUB
    FRONTEND_SUB=${FRONTEND_SUB:-imagentx}
    
    read -p "后端子域名 [api]: " BACKEND_SUB  
    BACKEND_SUB=${BACKEND_SUB:-api}
    
    FRONTEND_DOMAIN="$FRONTEND_SUB.$DOMAIN"
    BACKEND_DOMAIN="$BACKEND_SUB.$DOMAIN"
    
    echo ""
    print_info "最终配置:"
    print_info "- 前端: https://$FRONTEND_DOMAIN"
    print_info "- 后端: https://$BACKEND_DOMAIN"
    
    read -p "确认配置? (y/n): " CONFIRM
    if [[ "$CONFIRM" != "y" && "$CONFIRM" != "Y" ]]; then
        print_warning "配置取消"
        exit 1
    fi
}

# Cloudflare 登录
check_cloudflare_login() {
    print_step "Cloudflare 登录检查"
    
    CONFIG_DIR="$HOME/.cloudflared"
    
    if [ ! -f "$CONFIG_DIR/cert.pem" ]; then
        print_warning "需要先登录 Cloudflare"
        echo ""
        echo "步骤:"
        echo "1. 运行: cloudflared tunnel login"
        echo "2. 浏览器会打开 Cloudflare 登录页面"
        echo "3. 登录你的 Cloudflare 账户"
        echo "4. 选择你的域名 ($DOMAIN)"
        echo ""
        read -p "完成登录后按回车继续..."
        
        if [ ! -f "$CONFIG_DIR/cert.pem" ]; then
            print_error "登录失败，请重试"
            exit 1
        fi
    fi
    
    print_success "Cloudflare 登录成功 ✓"
}

# 检查域名在Cloudflare
check_domain_in_cloudflare() {
    print_step "检查域名配置"
    
    print_info "请确认:"
    echo "1. 域名 $DOMAIN 已添加到 Cloudflare"
    echo "2. DNS服务器已修改为 Cloudflare 的"
    echo "   - bob.ns.cloudflare.com"
    echo "   - lucy.ns.cloudflare.com"
    echo "3. 域名状态显示为 'Active'"
    echo ""
    
    read -p "域名配置完成? (y/n): " DOMAIN_READY
    if [[ "$DOMAIN_READY" != "y" && "$DOMAIN_READY" != "Y" ]]; then
        print_warning "请先完成域名配置"
        echo ""
        echo "快速配置:"
        echo "1. 登录: https://dash.cloudflare.com"
        echo "2. 添加站点: $DOMAIN"
        echo "3. 修改DNS服务器"
        echo "4. 等待生效 (几分钟到几小时)"
        exit 1
    fi
}

# 创建隧道
create_tunnel() {
    print_step "创建 Cloudflare 隧道"
    
    CONFIG_DIR="$HOME/.cloudflared"
    mkdir -p "$CONFIG_DIR"
    
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
}

# 配置DNS路由
setup_dns_routing() {
    print_step "配置 DNS 路由"
    
    print_info "正在配置 DNS 记录..."
    
    # 配置前端域名
    cloudflared tunnel route dns imagentx-tunnel "$FRONTEND_DOMAIN"
    
    # 配置后端域名
    cloudflared tunnel route dns imagentx-tunnel "$BACKEND_DOMAIN"
    
    print_success "DNS 路由配置完成 ✓"
    print_info "DNS 生效时间: 通常几分钟到几小时"
}

# 创建配置文件
create_config() {
    print_step "创建配置文件"
    
    CONFIG_FILE="$HOME/.cloudflared/config.yml"
    cat > "$CONFIG_FILE" << EOF
tunnel: $TUNNEL_ID
credentials-file: $HOME/.cloudflared/$TUNNEL_ID.json

# 优化配置
originRequest:
  connectTimeout: 30s
  tlsTimeout: 10s
  tcpKeepAlive: 30s

# 性能优化
compression: true
noTLSVerify: false

ingress:
  # 前端服务
  - hostname: $FRONTEND_DOMAIN
    service: http://localhost:3002
    originRequest:
      httpHostHeader: $FRONTEND_DOMAIN
      
  # 后端API服务
  - hostname: $BACKEND_DOMAIN
    service: http://localhost:8088
    originRequest:
      httpHostHeader: $BACKEND_DOMAIN
      
  # 默认404页面
  - service: http_status:404
EOF
    
    print_success "配置文件已创建: $CONFIG_FILE"
}

# 创建一键脚本
create_quick_scripts() {
    print_step "创建一键脚本"
    
    CONFIG_DIR="$HOME/.cloudflared"
    
    # 一键启动脚本
    cat > "$CONFIG_DIR/quick-start.sh" << EOF
#!/bin/bash
# ImagentX 一键启动脚本

echo "🚀 一键启动 ImagentX Cloudflare Tunnel"
echo "前端: https://$FRONTEND_DOMAIN"
echo "后端: https://$BACKEND_DOMAIN"
echo ""

# 检查服务
if ! lsof -Pi :3002 -sTCP:LISTEN -t >/dev/null 2>&1; then
    echo "❌ 前端服务未运行"
    echo "启动: cd apps/frontend && npm run dev"
    exit 1
fi

if ! lsof -Pi :8088 -sTCP:LISTEN -t >/dev/null 2>&1; then
    echo "❌ 后端服务未运行"
    echo "启动: cd apps/backend && ./mvnw spring-boot:run"
    exit 1
fi

echo "✅ 服务检查通过"
echo "启动隧道..."

# 启动隧道
cloudflared tunnel --config "$CONFIG_DIR/config.yml" run imagentx-tunnel
EOF

    # 一键测试脚本
    cat > "$CONFIG_DIR/quick-test.sh" << EOF
#!/bin/bash
# ImagentX 一键测试脚本

echo "🧪 一键测试 Cloudflare Tunnel"
echo ""

# 检查隧道状态
if pgrep -f "cloudflared.*tunnel" > /dev/null; then
    echo "✅ Cloudflare Tunnel 正在运行"
else
    echo "❌ Cloudflare Tunnel 未运行"
    echo "启动: $CONFIG_DIR/quick-start.sh"
    exit 1
fi

echo ""
echo "测试访问:"
echo "1. 前端: https://$FRONTEND_DOMAIN"
echo "2. 后端: https://$BACKEND_DOMAIN"
echo "3. API测试: https://$BACKEND_DOMAIN/api/actuator/health"
echo ""

echo "本地测试:"
echo "前端本地: \$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3002 || echo '失败')"
echo "后端本地: \$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8088 || echo '失败')"

echo ""
echo "公网测试:"
echo "前端公网: \$(curl -s -o /dev/null -w "%{http_code}" https://$FRONTEND_DOMAIN || echo '等待DNS')"
echo "后端公网: \$(curl -s -o /dev/null -w "%{http_code}" https://$BACKEND_DOMAIN || echo '等待DNS')"
EOF

    # 状态检查脚本
    cat > "$CONFIG_DIR/status.sh" << EOF
#!/bin/bash
# ImagentX 状态检查脚本

echo "📊 ImagentX 服务状态"
echo ""

echo "本地服务:"
echo "前端 (3002): \$(lsof -Pi :3002 -sTCP:LISTEN -t >/dev/null && echo '运行中 ✓' || echo '未运行 ✗')"
echo "后端 (8088): \$(lsof -Pi :8088 -sTCP:LISTEN -t >/dev/null && echo '运行中 ✓' || echo '未运行 ✗')"

echo ""
echo "Cloudflare Tunnel:"
echo "隧道状态: \$(pgrep -f "cloudflared.*tunnel" >/dev/null && echo '运行中 ✓' || echo '未运行 ✗')"

if pgrep -f "cloudflared.*tunnel" >/dev/null; then
    echo "进程ID: \$(pgrep -f "cloudflared.*tunnel")"
fi

echo ""
echo "访问地址:"
echo "- 前端: https://$FRONTEND_DOMAIN"
echo "- 后端: https://$BACKEND_DOMAIN"
EOF

    chmod +x "$CONFIG_DIR/quick-start.sh"
    chmod +x "$CONFIG_DIR/quick-test.sh"
    chmod +x "$CONFIG_DIR/status.sh"
    
    print_success "一键脚本创建完成 ✓"
}

# 创建分享信息
create_share_info() {
    print_step "创建分享信息"
    
    cat > "$HOME/.cloudflared/share-info.md" << EOF
# ImagentX 公网访问信息

## 🌐 访问地址
- **前端应用**: https://$FRONTEND_DOMAIN
- **后端API**: https://$BACKEND_DOMAIN
- **健康检查**: https://$BACKEND_DOMAIN/api/actuator/health

## 🚀 快速启动
\`\`\`bash
# 启动隧道
~/.cloudflared/quick-start.sh

# 测试连接
~/.cloudflared/quick-test.sh

# 查看状态
~/.cloudflared/status.sh
\`\`\`

## 📱 分享二维码
\`\`\`bash
# 生成分享二维码（需安装 qrencode）
qrencode -t UTF8 "https://$FRONTEND_DOMAIN"
\`\`\`

## 🔧 管理命令
\`\`\`bash
# 查看隧道状态
cloudflared tunnel info imagentx-tunnel

# 查看日志
tail -f ~/.cloudflared/tunnel.log

# 重启隧道
pkill -f "cloudflared.*tunnel"
~/.cloudflared/quick-start.sh
\`\`\`

## ⚡ 性能特点
- ✅ 免费HTTPS证书
- ✅ 全球CDN加速
- ✅ DDoS防护
- ✅ 无需备案（国际域名）
- ✅ 24/7在线
EOF

    print_success "分享信息已创建: $HOME/.cloudflared/share-info.md"
}

# 显示完成信息
show_completion() {
    echo ""
    print_success "🎉 域名配置完成！"
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    print_info "配置摘要:"
    print_info "- 前端域名: https://$FRONTEND_DOMAIN"
    print_info "- 后端域名: https://$BACKEND_DOMAIN"
    print_info "- 隧道名称: imagentx-tunnel"
    print_info "- 隧道ID: $TUNNEL_ID"
    echo ""
    print_info "一键命令:"
    print_info "- 启动: ~/.cloudflared/quick-start.sh"
    print_info "- 测试: ~/.cloudflared/quick-test.sh"
    print_info "- 状态: ~/.cloudflared/status.sh"
    print_info "- 日志: tail -f ~/.cloudflared/tunnel.log"
    echo ""
    print_info "分享地址:"
    print_info "- 应用: https://$FRONTEND_DOMAIN"
    print_info "- API: https://$BACKEND_DOMAIN"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    
    read -p "现在启动隧道? (y/n): " START_NOW
    if [[ "$START_NOW" == "y" || "$START_NOW" == "Y" ]]; then
        print_info "启动隧道..."
        ~/.cloudflared/quick-start.sh
    else
        print_info "稍后运行: ~/.cloudflared/quick-start.sh"
        print_info "或手动运行: cloudflared tunnel run imagentx-tunnel"
    fi
}

# 主流程
main() {
    print_header
    
    check_dependencies
    get_domain
    check_cloudflare_login
    check_domain_in_cloudflare
    create_tunnel
    setup_dns_routing
    create_config
    create_quick_scripts
    create_share_info
    show_completion
}

# 运行主程序
main "$@"