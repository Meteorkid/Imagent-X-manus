#!/bin/bash

# 国内域名 Cloudflare Tunnel 配置脚本
# 专为国内域名和备案环境优化

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
    echo -e "${PURPLE}║${NC}  🇨🇳 ${GREEN}国内域名 Cloudflare Tunnel 配置助手${NC}               ${PURPLE}║${NC}"
    echo -e "${PURPLE}║${NC}  专为国内域名和备案环境优化                           ${PURPLE}║${NC}"
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

# 国内域名推荐
show_china_domains() {
    echo ""
    print_step "推荐国内可注册域名"
    echo ""
    echo -e "${CYAN}个人项目推荐:${NC}"
    echo "  • imagentx.cn        - 中国域名，备案快，29元/年"
    echo "  • imagentx.top       - 新颖后缀，价格低至9元/年"
    echo "  • imagentx.xyz       - 国际通用，无需备案，12元/年"
    echo ""
    echo -e "${CYAN}商业项目推荐:${NC}"
    echo "  • imagentx.com       - 国际通用，品牌性强，55元/年"
    echo "  • imagentx.net       - 技术感强，45元/年"
    echo "  • ai-imagex.com      - 包含关键词，55元/年"
    echo ""
    echo -e "${CYAN}注册平台:${NC}"
    echo "  • 阿里云万网: https://wanwang.aliyun.com"
    echo "  • 腾讯云DNSPod: https://dnspod.cloud.tencent.com"
    echo "  • 西部数码: https://www.west.cn"
    echo ""
}

# 域名注册指导
register_guide() {
    print_step "域名注册流程"
    echo ""
    echo "1. ${YELLOW}选择注册商${NC}: 推荐阿里云万网"
    echo "2. ${YELLOW}搜索域名${NC}: 输入你想要的域名"
    echo "3. ${YELLOW}实名认证${NC}: 个人身份证或企业营业执照"
    echo "4. ${YELLOW}支付费用${NC}: 支持支付宝/微信支付"
    echo "5. ${YELLOW}完成注册${NC}: 获得域名管理权限"
    echo ""
    
    read -p "是否已注册域名? (y/n): " HAS_DOMAIN
    if [[ "$HAS_DOMAIN" != "y" && "$HAS_DOMAIN" != "Y" ]]; then
        print_warning "请先注册域名后再继续"
        echo ""
        echo "快速注册:"
        echo "阿里云: open https://wanwang.aliyun.com"
        echo "腾讯云: open https://dnspod.cloud.tencent.com"
        exit 1
    fi
}

# 获取域名信息
get_domain_info() {
    print_step "配置域名信息"
    echo ""
    
    read -p "请输入你的完整域名 (如: imagentx.cn): " DOMAIN
    if [[ -z "$DOMAIN" ]]; then
        print_error "域名不能为空"
        exit 1
    fi
    
    # 移除前缀
    DOMAIN=$(echo "$DOMAIN" | sed 's|https://||g' | sed 's|http://||g' | sed 's|www.||g')
    
    # 验证域名格式
    if [[ ! "$DOMAIN" =~ ^[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
        print_error "域名格式不正确"
        exit 1
    fi
    
    print_info "将使用域名: $DOMAIN"
    
    # 判断域名后缀
    SUFFIX=$(echo "$DOMAIN" | awk -F. '{print $NF}')
    case "$SUFFIX" in
        "cn")
            print_info "检测到 .cn 域名，支持国内备案"
            ;;
        "com"|"net"|"org")
            print_info "检测到国际域名，全球访问"
            ;;
        "top"|"xyz"|"club")
            print_info "检测到新顶级域名，无需备案"
            ;;
        *)
            print_info "检测到域名后缀: .$SUFFIX"
            ;;
    esac
    
    # 子域名配置
    FRONTEND_SUBDOMAIN="imagentx"
    BACKEND_SUBDOMAIN="api"
    
    echo ""
    echo -e "${CYAN}子域名配置:${NC}"
    read -p "前端子域名 [$FRONTEND_SUBDOMAIN]: " FRONTEND_INPUT
    if [[ -n "$FRONTEND_INPUT" ]]; then
        FRONTEND_SUBDOMAIN="$FRONTEND_INPUT"
    fi
    
    read -p "后端子域名 [$BACKEND_SUBDOMAIN]: " BACKEND_INPUT
    if [[ -n "$BACKEND_INPUT" ]]; then
        BACKEND_SUBDOMAIN="$BACKEND_INPUT"
    fi
    
    FRONTEND_DOMAIN="$FRONTEND_SUBDOMAIN.$DOMAIN"
    BACKEND_DOMAIN="$BACKEND_SUBDOMAIN.$DOMAIN"
    
    echo ""
    print_info "最终配置:"
    print_info "- 前端域名: https://$FRONTEND_DOMAIN"
    print_info "- 后端域名: https://$BACKEND_DOMAIN"
    
    read -p "确认配置正确? (y/n): " CONFIRM
    if [[ "$CONFIRM" != "y" && "$CONFIRM" != "Y" ]]; then
        print_warning "配置取消"
        exit 1
    fi
}

# Cloudflare 配置检查
check_cloudflare_setup() {
    print_step "检查 Cloudflare 配置"
    
    print_info "请确保已完成以下步骤:"
    echo ""
    echo "1. ${YELLOW}域名已添加到 Cloudflare${NC}"
    echo "2. ${YELLOW}DNS服务器已修改为 Cloudflare${NC}"
    echo "   - bob.ns.cloudflare.com"
    echo "   - lucy.ns.cloudflare.com"
    echo "3. ${YELLOW}域名状态为 Active${NC}"
    echo ""
    
    read -p "是否已完成 Cloudflare 配置? (y/n): " CLOUDFLARE_READY
    if [[ "$CLOUDFLARE_READY" != "y" && "$CLOUDFLARE_READY" != "Y" ]]; then
        print_warning "请先完成 Cloudflare 配置"
        echo ""
        echo "配置步骤:"
        echo "1. 登录: https://dash.cloudflare.com"
        echo "2. 添加站点: $DOMAIN"
        echo "3. 修改DNS服务器"
        echo "4. 等待生效 (通常几分钟到几小时)"
        exit 1
    fi
}

# 创建优化配置
create_optimized_config() {
    print_step "创建优化配置"
    
    CONFIG_DIR="$HOME/.cloudflared"
    mkdir -p "$CONFIG_DIR"
    
    # 创建隧道
    TUNNEL_NAME="imagentx-tunnel"
    
    if cloudflared tunnel list | grep -q "$TUNNEL_NAME"; then
        print_info "隧道已存在，获取信息..."
        TUNNEL_ID=$(cloudflared tunnel list | grep "$TUNNEL_NAME" | awk '{print $1}')
    else
        print_info "创建新隧道..."
        TUNNEL_ID=$(cloudflared tunnel create "$TUNNEL_NAME" 2>&1 | grep -o 'Created tunnel [^ ]* with id [^ ]*' | awk '{print $NF}')
        if [[ -z "$TUNNEL_ID" ]]; then
            print_error "隧道创建失败，请检查网络连接"
            exit 1
        fi
    fi
    
    print_success "隧道创建成功 ✓"
    print_info "隧道ID: $TUNNEL_ID"
    
    # 创建优化配置文件
    CONFIG_FILE="$CONFIG_DIR/config.yml"
    cat > "$CONFIG_FILE" << EOF
tunnel: $TUNNEL_ID
credentials-file: $CONFIG_DIR/$TUNNEL_ID.json

# 优化配置
originRequest:
  connectTimeout: 30s
  tlsTimeout: 10s
  tcpKeepAlive: 30s

# 中国优化
warp-routing:
  enabled: true

ingress:
  # 前端服务 - 中国优化
  - hostname: $FRONTEND_DOMAIN
    service: http://localhost:3002
    originRequest:
      httpHostHeader: $FRONTEND_DOMAIN
      
  # 后端API服务 - 中国优化  
  - hostname: $BACKEND_DOMAIN
    service: http://localhost:8088
    originRequest:
      httpHostHeader: $BACKEND_DOMAIN
      
  # 默认404页面
  - service: http_status:404
EOF
    
    print_success "优化配置文件已创建: $CONFIG_FILE"
}

# 配置DNS路由
configure_dns_routing() {
    print_step "配置 DNS 路由"
    
    print_info "配置 DNS 记录..."
    
    # 配置前端域名
    cloudflared tunnel route dns imagentx-tunnel "$FRONTEND_DOMAIN"
    
    # 配置后端域名  
    cloudflared tunnel route dns imagentx-tunnel "$BACKEND_DOMAIN"
    
    print_success "DNS 路由配置完成 ✓"
    print_info "DNS 生效时间: 通常几分钟到几小时"
}

# 创建专用脚本
create_china_scripts() {
    print_step "创建专用脚本"
    
    CONFIG_DIR="$HOME/.cloudflared"
    
    # 中国优化启动脚本
    cat > "$CONFIG_DIR/start-china.sh" << EOF
#!/bin/bash
# 中国域名专用启动脚本

echo "🇨🇳 启动 ImagentX 中国域名隧道..."
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
echo "启动 Cloudflare Tunnel..."

# 启动隧道（中国优化）
cloudflared tunnel --config "$CONFIG_DIR/config.yml" run imagentx-tunnel
EOF

    # 中国测试脚本
    cat > "$CONFIG_DIR/test-china.sh" << EOF
#!/bin/bash
# 中国域名测试脚本

echo "🇨🇳 测试中国域名访问..."
echo ""

# 检查隧道状态
if pgrep -f "cloudflared.*tunnel" > /dev/null; then
    echo "✅ Cloudflare Tunnel 正在运行"
else
    echo "❌ Cloudflare Tunnel 未运行"
    echo "启动: $CONFIG_DIR/start-china.sh"
    exit 1
fi

echo ""
echo "测试访问地址:"
echo "前端: https://$FRONTEND_DOMAIN"
echo "后端: https://$BACKEND_DOMAIN"
echo ""

echo "本地服务测试:"
echo "前端本地: \$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3002 || echo '失败')"
echo "后端本地: \$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8088 || echo '失败')"

echo ""
echo "公网测试（请等待DNS生效）:"
echo "前端公网: \$(curl -s -o /dev/null -w "%{http_code}" https://$FRONTEND_DOMAIN || echo '等待DNS')"
echo "后端公网: \$(curl -s -o /dev/null -w "%{http_code}" https://$BACKEND_DOMAIN || echo '等待DNS')"

echo ""
echo "📱 分享地址:"
echo "应用访问: https://$FRONTEND_DOMAIN"
echo "API测试: https://$BACKEND_DOMAIN/api/actuator/health"
EOF

    # 备案检查脚本
    cat > "$CONFIG_DIR/check-icp.sh" << EOF
#!/bin/bash
# 备案检查脚本

echo "🔍 备案信息检查"
echo "域名: $DOMAIN"
echo ""

echo "备案查询工具:"
echo "1. 工信部备案系统: https://beian.miit.gov.cn"
echo "2. 阿里云备案: https://beian.aliyun.com"
echo "3. 腾讯云备案: https://console.cloud.tencent.com/beian"
echo ""

echo "备案要求:"
echo "- .cn 域名必须备案"
echo "- .com/.net 域名可选备案"
echo "- 新顶级域名(.top/.xyz)无需备案"
EOF

    chmod +x "$CONFIG_DIR/start-china.sh"
    chmod +x "$CONFIG_DIR/test-china.sh"
    chmod +x "$CONFIG_DIR/check-icp.sh"
    
    print_success "专用脚本创建完成 ✓"
}

# 创建备案指南
create_icp_guide() {
    print_step "创建备案指南"
    
    cat > "$HOME/.cloudflared/icp-guide.md" << EOF
# 中国域名备案指南

## 📋 备案要求
- **.cn域名**: 必须备案
- **.com/.net域名**: 可选备案（推荐）
- **新顶级域名**: .top/.xyz等无需备案

## 🚀 备案流程

### 1. 选择备案服务商
- **阿里云备案**: https://beian.aliyun.com
- **腾讯云备案**: https://console.cloud.tencent.com/beian
- **西部数码备案**: https://www.west.cn/beian/

### 2. 准备材料
**个人备案:**
- 身份证正反面
- 域名证书
- 真实性核验单
- 网站负责人照片

**企业备案:**
- 营业执照
- 法人身份证
- 域名证书
- 真实性核验单
- 网站负责人照片

### 3. 备案时间
- 初审: 1-3个工作日
- 管局审核: 5-20个工作日
- 总计: 7-23个工作日

### 4. 备案成功后
- 获得备案号（如：京ICP备xxxxxxxx号）
- 网站底部需显示备案号
- 接入Cloudflare需修改DNS

## 🔧 无需备案方案

如果域名后缀为 .top/.xyz 等，可直接使用Cloudflare，无需备案。

## 📞 技术支持
- 阿里云客服: 95187
- 腾讯云客服: 400-910-0100
- 西部数码客服: 400-667-9006
EOF

    print_success "备案指南已创建: $HOME/.cloudflared/icp-guide.md"
}

# 显示完成信息
show_completion() {
    echo ""
    print_success "🎉 中国域名 Cloudflare Tunnel 配置完成！"
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    print_info "配置摘要:"
    print_info "- 前端域名: https://$FRONTEND_DOMAIN"
    print_info "- 后端域名: https://$BACKEND_DOMAIN"
    print_info "- 隧道名称: imagentx-tunnel"
    print_info "- 隧道ID: $TUNNEL_ID"
    echo ""
    print_info "快速开始:"
    print_info "1. 启动隧道: ~/.cloudflared/start-china.sh"
    print_info "2. 测试连接: ~/.cloudflared/test-china.sh"
    print_info "3. 备案检查: ~/.cloudflared/check-icp.sh"
    print_info "4. 查看日志: tail -f ~/.cloudflared/tunnel.log"
    echo ""
    print_info "重要提醒:"
    print_warning "- 请确保DNS已生效（等待几分钟到几小时）"
    print_warning "- .cn域名需要备案，请查看备案指南"
    print_info "- 分享地址: https://$FRONTEND_DOMAIN"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    
    read -p "现在启动隧道? (y/n): " START_NOW
    if [[ "$START_NOW" == "y" || "$START_NOW" == "Y" ]]; then
        print_info "启动隧道..."
        ~/.cloudflared/start-china.sh
    else
        print_info "稍后运行: ~/.cloudflared/start-china.sh"
    fi
}

# 主流程
main() {
    print_header
    
    show_china_domains
    register_guide
    get_domain_info
    check_cloudflare_setup
    create_optimized_config
    configure_dns_routing
    create_china_scripts
    create_icp_guide
    show_completion
}

# 运行主程序
main "$@"