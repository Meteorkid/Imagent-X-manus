#!/bin/bash

# 修复路径问题并重新配置 Cloudflare Tunnel

set -e

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
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

# 获取正确的用户名
USERNAME=$(whoami)
print_info "当前用户名: $USERNAME"

# 设置正确的路径
CLOUDFLARE_DIR="/Users/$USERNAME/.cloudflared"
PROJECT_DIR="/Users/$USERNAME/Downloads/ImagentX-master"

print_info "Cloudflare 配置目录: $CLOUDFLARE_DIR"
print_info "项目目录: $PROJECT_DIR"

# 创建正确的配置文件
create_fixed_config() {
    print_info "创建修正后的配置文件..."
    
    mkdir -p "$CLOUDFLARE_DIR"
    
    # 创建一键启动脚本
    cat > "$CLOUDFLARE_DIR/start.sh" << EOF
#!/bin/bash
# ImagentX Cloudflare Tunnel 一键启动

echo "🚀 启动 ImagentX Cloudflare Tunnel"
echo ""

# 检查服务
if ! lsof -Pi :3002 -sTCP:LISTEN -t >/dev/null 2>&1; then
    echo "❌ 前端服务未运行 (端口3002)"
    echo "请运行: cd $PROJECT_DIR/apps/frontend && npm run dev"
    exit 1
fi

if ! lsof -Pi :8088 -sTCP:LISTEN -t >/dev/null 2>&1; then
    echo "❌ 后端服务未运行 (端口8088)"
    echo "请运行: cd $PROJECT_DIR/apps/backend && ./mvnw spring-boot:run"
    exit 1
fi

echo "✅ 本地服务检查通过"

# 启动隧道
if [ -f "$CLOUDFLARE_DIR/config.yml" ]; then
    echo "使用现有配置启动隧道..."
    cloudflared tunnel --config "$CLOUDFLARE_DIR/config.yml" run imagentx-tunnel
else
    echo "❌ 配置文件不存在"
    echo "请先运行配置脚本: $PROJECT_DIR/scripts/utils/quick-setup-domain.sh"
fi
EOF

    # 创建一键测试脚本
    cat > "$CLOUDFLARE_DIR/test.sh" << EOF
#!/bin/bash
# ImagentX 一键测试

echo "🧪 测试 ImagentX 服务状态"
echo ""

# 检查本地服务
echo "本地服务状态:"
echo "前端 (3002): \$(lsof -Pi :3002 -sTCP:LISTEN -t >/dev/null && echo '运行中 ✓' || echo '未运行 ✗')"
echo "后端 (8088): \$(lsof -Pi :8088 -sTCP:LISTEN -t >/dev/null && echo '运行中 ✓' || echo '未运行 ✗')"

# 检查隧道
echo ""
echo "Cloudflare Tunnel 状态:"
echo "隧道进程: \$(pgrep -f "cloudflared.*tunnel" >/dev/null && echo '运行中 ✓' || echo '未运行 ✗')"

if [ -f "$CLOUDFLARE_DIR/config.yml" ]; then
    echo ""
    echo "配置文件存在: ✓"
    echo "当前配置:"
    grep "hostname:" "$CLOUDFLARE_DIR/config.yml" | sed 's/^[[:space:]]*//'
else
    echo ""
    echo "配置文件: 不存在 ✗"
fi
EOF

    # 创建状态检查脚本
    cat > "$CLOUDFLARE_DIR/status.sh" << EOF
#!/bin/bash
# ImagentX 完整状态检查

echo "📊 ImagentX 完整状态报告"
echo "=========================="
echo ""

echo "🖥️  系统信息:"
echo "用户: $USERNAME"
echo "项目目录: $PROJECT_DIR"
echo "配置目录: $CLOUDFLARE_DIR"
echo ""

echo "🔧 服务状态:"
echo "前端 (3002): \$(lsof -Pi :3002 -sTCP:LISTEN -t >/dev/null && echo '运行中 ✓' || echo '未运行 ✗')"
echo "后端 (8088): \$(lsof -Pi :8088 -sTCP:LISTEN -t >/dev/null && echo '运行中 ✓' || echo '未运行 ✗')"
echo ""

echo "🌐 Cloudflare Tunnel:"
echo "进程状态: \$(pgrep -f "cloudflared.*tunnel" >/dev/null && echo '运行中 ✓' || echo '未运行 ✗')"
echo "配置文件: \$([ -f "$CLOUDFLARE_DIR/config.yml" ] && echo '存在 ✓' || echo '不存在 ✗')"
echo "证书文件: \$([ -f "$CLOUDFLARE_DIR/cert.pem" ] && echo '存在 ✓' || echo '不存在 ✗')"
echo ""

echo "📁 文件结构:"
ls -la "$CLOUDFLARE_DIR"
echo ""

echo "📱 使用命令:"
echo "启动隧道: $CLOUDFLARE_DIR/start.sh"
echo "测试状态: $CLOUDFLARE_DIR/test.sh"
echo "完整检查: $CLOUDFLARE_DIR/status.sh"
echo "配置域名: $PROJECT_DIR/scripts/utils/quick-setup-domain.sh"
EOF

    chmod +x "$CLOUDFLARE_DIR/start.sh"
    chmod +x "$CLOUDFLARE_DIR/test.sh"
    chmod +x "$CLOUDFLARE_DIR/status.sh"
    
    print_info "修正后的脚本已创建:"
    print_info "- 启动脚本: $CLOUDFLARE_DIR/start.sh"
    print_info "- 测试脚本: $CLOUDFLARE_DIR/test.sh"
    print_info "- 状态脚本: $CLOUDFLARE_DIR/status.sh"
}

# 修复配置文件
create_config_template() {
    print_info "创建配置模板..."
    
    cat > "$CLOUDFLARE_DIR/config-template.yml" << EOF
# ImagentX Cloudflare Tunnel 配置模板
# 使用前请将 YOUR_DOMAIN 替换为你的实际域名
# 并将 YOUR_TUNNEL_ID 替换为你的隧道ID

tunnel: YOUR_TUNNEL_ID
credentials-file: $CLOUDFLARE_DIR/YOUR_TUNNEL_ID.json

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
  - hostname: imagentx.YOUR_DOMAIN
    service: http://localhost:3002
    originRequest:
      httpHostHeader: imagentx.YOUR_DOMAIN
      
  # 后端API
  - hostname: api.YOUR_DOMAIN
    service: http://localhost:8088
    originRequest:
      httpHostHeader: api.YOUR_DOMAIN
      
  # 默认404
  - service: http_status:404
EOF

    print_info "配置模板已创建: $CLOUDFLARE_DIR/config-template.yml"
}

# 显示使用指南
show_usage() {
    echo ""
    echo "✅ 路径问题已修复！"
    echo ""
    echo "🎯 现在你可以使用以下命令："
    echo ""
    echo "1️⃣ 配置域名（首次使用）:"
    echo "   $PROJECT_DIR/scripts/utils/quick-setup-domain.sh"
    echo ""
    echo "2️⃣ 启动隧道:"
    echo "   $CLOUDFLARE_DIR/start.sh"
    echo ""
    echo "3️⃣ 检查状态:"
    echo "   $CLOUDFLARE_DIR/status.sh"
    echo ""
    echo "4️⃣ 快速测试:"
    echo "   $CLOUDFLARE_DIR/test.sh"
    echo ""
    echo "📁 配置文件位置: $CLOUDFLARE_DIR"
    echo "📝 配置模板: $CLOUDFLARE_DIR/config-template.yml"
    echo ""
}

# 主流程
main() {
    print_info "修复 Cloudflare Tunnel 路径问题..."
    create_fixed_config
    create_config_template
    show_usage
}

main "$@"