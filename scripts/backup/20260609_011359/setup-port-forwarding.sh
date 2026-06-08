#!/bin/bash

# ImagentX 端口转发配置脚本
# 适用于 macOS 路由器端口转发设置

set -e

echo "🚀 ImagentX 端口转发配置脚本"
echo "================================"

# 获取当前网络信息
LOCAL_IP=$(ipconfig getifaddr en0 || ipconfig getifaddr en1)
ROUTER_IP=$(netstat -rn | grep default | head -1 | awk '{print $2}')
PUBLIC_IP=$(curl -s ifconfig.me)

echo "📊 网络信息:"
echo "  本地IP: $LOCAL_IP"
echo "  路由器IP: $ROUTER_IP"
echo "  公网IP: $PUBLIC_IP"
echo ""

# 检查端口是否已被占用
check_port() {
    local port=$1
    local service=$2
    if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1; then
        echo "✅ $service 端口 $port 正在运行"
        return 0
    else
        echo "⚠️  $service 端口 $port 未运行"
        return 1
    fi
}

# 检查服务状态
echo "🔍 检查服务状态:"
check_port 3002 "前端服务"
check_port 8088 "后端服务"

echo ""
echo "🔧 路由器配置步骤:"
echo "1. 打开浏览器访问: http://$ROUTER_IP"
echo "2. 登录路由器管理界面"
echo "3. 找到 '端口转发' 或 '虚拟服务器' 设置"
echo "4. 添加以下规则:"
echo ""
echo "   前端服务:"
echo "   - 外部端口: 3002"
echo "   - 内部IP: $LOCAL_IP"
echo "   - 内部端口: 3002"
echo "   - 协议: TCP"
echo ""
echo "   后端服务:"
echo "   - 外部端口: 8088"
echo "   - 内部IP: $LOCAL_IP"
echo "   - 内部端口: 8088"
echo "   - 协议: TCP"
echo ""

# 测试端口是否可从外部访问
test_external_access() {
    echo "🧪 测试外部访问:"
    echo "等待路由器配置完成..."
    echo "完成后，其他用户可通过以下地址访问:"
    echo "  前端: http://$PUBLIC_IP:3002"
    echo "  后端API: http://$PUBLIC_IP:8088/api"
    echo ""
    echo "局域网用户访问:"
    echo "  前端: http://$LOCAL_IP:3002"
    echo "  后端API: http://$LOCAL_IP:8088/api"
}

# 创建防火墙规则（如果防火墙启用）
setup_firewall() {
    echo "🔒 配置防火墙规则..."
    
    # 检查防火墙状态
    FIREWALL_STATE=$(sudo /usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate | grep -o 'enabled\|disabled')
    
    if [[ "$FIREWALL_STATE" == "enabled" ]]; then
        echo "启用防火墙例外规则..."
        sudo /usr/libexec/ApplicationFirewall/socketfilterfw --add /opt/homebrew/opt/openjdk@17/bin/java 2>/dev/null || true
        sudo /usr/libexec/ApplicationFirewall/socketfilterfw --add $(which node) 2>/dev/null || true
        sudo /usr/libexec/ApplicationFirewall/socketfilterfw --unblockapp /opt/homebrew/opt/openjdk@17/bin/java 2>/dev/null || true
        sudo /usr/libexec/ApplicationFirewall/socketfilterfw --unblockapp $(which node) 2>/dev/null || true
        echo "✅ 防火墙规则已配置"
    else
        echo "ℹ️  防火墙当前已禁用，无需额外配置"
    fi
}

# 创建测试脚本
create_test_script() {
    cat > /tmp/test-imagentx-access.sh << 'EOF'
#!/bin/bash
PUBLIC_IP=$(curl -s ifconfig.me)
echo "测试 ImagentX 外部访问..."
echo "公网IP: $PUBLIC_IP"
echo ""
echo "测试前端: http://$PUBLIC_IP:3002"
echo "测试后端: http://$PUBLIC_IP:8088/api/actuator/health"
echo ""
echo "按 Ctrl+C 停止测试"
EOF
    chmod +x /tmp/test-imagentx-access.sh
    echo "✅ 测试脚本已创建: /tmp/test-imagentx-access.sh"
}

# 执行配置
setup_firewall
create_test_script
test_external_access

echo ""
echo "📝 下一步操作:"
echo "1. 按上述步骤配置路由器端口转发"
echo "2. 配置完成后运行: /tmp/test-imagentx-access.sh"
echo "3. 分享公网地址给其他用户"
echo ""
echo "⚠️  安全提醒:"
echo "- 仅向你信任的用户分享访问地址"
echo "- 考虑设置强密码保护"
echo "- 定期检查访问日志"