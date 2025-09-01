#!/bin/bash

# ImagentX Cloudflare Tunnel 配置脚本
# 提供HTTPS安全访问，无需配置路由器

set -e

echo "🚀 ImagentX Cloudflare Tunnel 配置脚本"
echo "=========================================="

# 检查cloudflared是否安装
if ! command -v cloudflared &> /dev/null; then
    echo "❌ cloudflared 未安装，正在安装..."
    brew install cloudflared
fi

echo "✅ cloudflared 已安装"

# 获取当前服务信息
FRONTEND_PORT=3002
BACKEND_PORT=8088
LOCAL_IP=$(ipconfig getifaddr en0 || ipconfig getifaddr en1)

echo "📊 当前服务状态:"
echo "  前端服务端口: $FRONTEND_PORT"
echo "  后端服务端口: $BACKEND_PORT"
echo "  本地IP: $LOCAL_IP"

# 检查服务是否运行
check_service() {
    local port=$1
    local name=$2
    if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1; then
        echo "✅ $name 服务正在端口 $port 运行"
        return 0
    else
        echo "❌ $name 服务未运行"
        return 1
    fi
}

check_service $FRONTEND_PORT "前端"
check_service $BACKEND_PORT "后端"

echo ""
echo "📋 Cloudflare Tunnel 配置步骤:"
echo "1. 登录 Cloudflare 账户"
echo "2. 选择一个域名或添加新域名"
echo "3. 运行以下命令创建隧道:"
echo ""

# 创建隧道配置目录
CONFIG_DIR="$HOME/.cloudflared"
mkdir -p "$CONFIG_DIR"

cat << 'EOF'

🔧 手动配置步骤:

1️⃣  登录 Cloudflare:
   运行: cloudflared tunnel login
   浏览器会打开，登录你的 Cloudflare 账户

2️⃣  创建隧道:
   运行: cloudflared tunnel create imagentx-tunnel
   记下返回的隧道UUID

3️⃣  创建配置文件:
   在 ~/.cloudflared/config.yml 中添加:

   tunnel: <你的隧道UUID>
   credentials-file: ~/.cloudflared/<你的隧道UUID>.json
   
   ingress:
     - hostname: imagentx.yourdomain.com
       service: http://localhost:3002
     - hostname: api.imagentx.yourdomain.com  
       service: http://localhost:8088
     - service: http_status:404

4️⃣  配置DNS:
   运行: cloudflared tunnel route dns imagentx-tunnel imagentx.yourdomain.com
   运行: cloudflared tunnel route dns imagentx-tunnel api.imagentx.yourdomain.com

5️⃣  启动隧道:
   运行: cloudflared tunnel run imagentx-tunnel

EOF

# 创建示例配置文件
create_sample_config() {
    local sample_config="$CONFIG_DIR/config.yml.example"
    cat > "$sample_config" << 'EOF'
# Cloudflare Tunnel 配置文件示例
# 替换以下内容:
# - <隧道UUID> 替换为你的实际隧道UUID
# - yourdomain.com 替换为你的实际域名

tunnel: <隧道UUID>
credentials-file: ~/.cloudflared/<隧道UUID>.json

ingress:
  # 前端服务
  - hostname: imagentx.yourdomain.com
    service: http://localhost:3002
  
  # 后端API服务  
  - hostname: api.imagentx.yourdomain.com
    service: http://localhost:8088
    
  # 默认404页面
  - service: http_status:404
EOF
    
    echo "✅ 示例配置文件已创建: $sample_config"
}

# 创建启动脚本
create_start_script() {
    local start_script="$CONFIG_DIR/start-tunnel.sh"
    cat > "$start_script" << 'EOF'
#!/bin/bash
# Cloudflare Tunnel 启动脚本

echo "🚀 启动 ImagentX Cloudflare Tunnel..."

# 检查服务是否运行
if ! lsof -Pi :3002 -sTCP:LISTEN -t >/dev/null 2>&1; then
    echo "❌ 前端服务未运行，请先启动前端服务"
    exit 1
fi

if ! lsof -Pi :8088 -sTCP:LISTEN -t >/dev/null 2>&1; then
    echo "❌ 后端服务未运行，请先启动后端服务"
    exit 1
fi

# 启动隧道
echo "✅ 服务检查通过，启动隧道..."
cloudflared tunnel run imagentx-tunnel
EOF
    
    chmod +x "$start_script"
    echo "✅ 启动脚本已创建: $start_script"
}

# 创建测试脚本
create_test_script() {
    local test_script="$CONFIG_DIR/test-tunnel.sh"
    cat > "$test_script" << 'EOF'
#!/bin/bash
# Cloudflare Tunnel 测试脚本

echo "🧪 测试 Cloudflare Tunnel 连接..."

# 检查隧道状态
if pgrep -f "cloudflared.*tunnel" > /dev/null; then
    echo "✅ Cloudflare Tunnel 正在运行"
else
    echo "❌ Cloudflare Tunnel 未运行"
    echo "请运行: ~/.cloudflared/start-tunnel.sh"
    exit 1
fi

# 获取配置域名
if [ -f ~/.cloudflared/config.yml ]; then
    DOMAIN=$(grep -E "hostname:" ~/.cloudflared/config.yml | head -1 | awk '{print $2}')
    if [ -n "$DOMAIN" ]; then
        echo "🌐 域名配置: $DOMAIN"
        echo "测试访问: https://$DOMAIN"
        echo "API测试: https://api.imagentx.$(echo $DOMAIN | cut -d'.' -f2-)/api/actuator/health"
    else
        echo "❌ 未找到域名配置"
    fi
else
    echo "❌ 配置文件不存在"
fi
EOF
    
    chmod +x "$test_script"
    echo "✅ 测试脚本已创建: $test_script"
}

# 创建systemd服务文件（macOS LaunchAgent）
create_launchd_service() {
    local plist_file="$HOME/Library/LaunchAgents/com.imagentx.cloudflared.plist"
    
    cat > "$plist_file" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.imagentx.cloudflared</string>
    <key>ProgramArguments</key>
    <array>
        <string>/opt/homebrew/bin/cloudflared</string>
        <string>tunnel</string>
        <string>run</string>
        <string>imagentx-tunnel</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>StandardOutPath</key>
    <string>/tmp/imagentx-cloudflared.log</string>
    <key>StandardErrorPath</key>
    <string>/tmp/imagentx-cloudflared-error.log</string>
</dict>
</plist>
EOF
    
    echo "✅ macOS 服务文件已创建: $plist_file"
    echo "启用服务运行: launchctl load $plist_file"
}

# 执行创建
mkdir -p "$CONFIG_DIR"
create_sample_config
create_start_script
create_test_script
create_launchd_service

echo ""
echo "🎯 快速开始命令:"
echo "1. 登录: cloudflared tunnel login"
echo "2. 创建: cloudflared tunnel create imagentx-tunnel"
echo "3. 配置: 编辑 ~/.cloudflared/config.yml"
echo "4. 启动: ~/.cloudflared/start-tunnel.sh"
echo "5. 测试: ~/.cloudflared/test-tunnel.sh"
echo ""
echo "📖 详细指南:"
echo "- 官方文档: https://developers.cloudflare.com/cloudflare-one/connections/connect-apps"
echo "- 免费域名: 可以在 freenom.com 获取免费域名"
echo "- Cloudflare域名: 在 Cloudflare 注册或使用已有域名"