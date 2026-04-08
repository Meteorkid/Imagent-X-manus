#!/bin/bash

# ImagentX API Token 快速配置脚本

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔑 ImagentX API Token 配置脚本${NC}"
echo "=================================="
echo -e "${CYAN}域名: imagentx.top${NC}"
echo ""

# 检查必要工具
if ! command -v curl &> /dev/null; then
    echo -e "${RED}❌ curl未安装，请先安装curl${NC}"
    exit 1
fi

if ! command -v jq &> /dev/null; then
    echo -e "${YELLOW}⚠️ jq未安装，正在安装...${NC}"
    if [[ "$OSTYPE" == "darwin"* ]]; then
        brew install jq
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        sudo apt-get update && sudo apt-get install -y jq
    fi
fi

echo -e "${GREEN}✅ 工具检查完成${NC}"
echo ""

# 获取用户输入
echo -e "${YELLOW}📝 请输入您的Cloudflare配置信息：${NC}"
echo ""

read -p "🔑 Cloudflare API Token: " API_TOKEN
read -p "🌐 Cloudflare Zone ID: " ZONE_ID
read -p "🖥️ 服务器IP地址: " SERVER_IP

# 验证输入
if [ -z "$API_TOKEN" ] || [ -z "$ZONE_ID" ] || [ -z "$SERVER_IP" ]; then
    echo -e "${RED}❌ 所有字段都必须填写${NC}"
    exit 1
fi

echo ""
echo -e "${YELLOW}🔍 验证配置信息...${NC}"

# 验证API Token
echo -e "${CYAN}验证API Token...${NC}"
TOKEN_RESPONSE=$(curl -s -X GET "https://api.cloudflare.com/client/v4/user/tokens/verify" \
    -H "Authorization: Bearer $API_TOKEN" \
    -H "Content-Type: application/json")

if echo "$TOKEN_RESPONSE" | jq -r '.success' 2>/dev/null | grep -q "true"; then
    echo -e "${GREEN}✅ API Token验证成功${NC}"
else
    echo -e "${RED}❌ API Token验证失败${NC}"
    echo -e "${YELLOW}请检查Token是否正确，或重新创建Token${NC}"
    exit 1
fi

# 验证Zone ID
echo -e "${CYAN}验证Zone ID...${NC}"
ZONE_RESPONSE=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$ZONE_ID" \
    -H "Authorization: Bearer $API_TOKEN" \
    -H "Content-Type: application/json")

if echo "$ZONE_RESPONSE" | jq -r '.success' 2>/dev/null | grep -q "true"; then
    ZONE_NAME=$(echo "$ZONE_RESPONSE" | jq -r '.result.name' 2>/dev/null)
    echo -e "${GREEN}✅ Zone ID验证成功${NC}"
    echo -e "${CYAN}   域名: $ZONE_NAME${NC}"
else
    echo -e "${RED}❌ Zone ID验证失败${NC}"
    echo -e "${YELLOW}请检查Zone ID是否正确${NC}"
    exit 1
fi

# 验证服务器IP
echo -e "${CYAN}验证服务器IP...${NC}"
if [[ $SERVER_IP =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
    echo -e "${GREEN}✅ 服务器IP格式正确${NC}"
else
    echo -e "${RED}❌ 服务器IP格式不正确${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}✅ 所有配置验证通过${NC}"
echo ""

# 设置环境变量
echo -e "${YELLOW}🔧 设置环境变量...${NC}"
export CLOUDFLARE_API_TOKEN="$API_TOKEN"
export CLOUDFLARE_ZONE_ID="$ZONE_ID"
export SERVER_IP="$SERVER_IP"

# 创建环境配置文件
echo -e "${YELLOW}📝 创建环境配置文件...${NC}"
cat > .env.production << EOF
# Cloudflare配置
CLOUDFLARE_API_TOKEN=$API_TOKEN
CLOUDFLARE_ZONE_ID=$ZONE_ID

# 服务器配置
SERVER_IP=$SERVER_IP
DOMAIN=imagentx.top

# 数据库配置
POSTGRES_PASSWORD=imagentx_secure_password_$(date +%s)
RABBITMQ_PASSWORD=imagentx_secure_password_$(date +%s)

# 应用配置
NODE_ENV=production
SPRING_PROFILES_ACTIVE=production
EOF

echo -e "${GREEN}✅ 环境配置文件已创建: .env.production${NC}"

# 永久设置环境变量
echo -e "${YELLOW}💾 永久设置环境变量...${NC}"
SHELL_CONFIG=""
if [ -f "$HOME/.zshrc" ]; then
    SHELL_CONFIG="$HOME/.zshrc"
elif [ -f "$HOME/.bashrc" ]; then
    SHELL_CONFIG="$HOME/.bashrc"
elif [ -f "$HOME/.bash_profile" ]; then
    SHELL_CONFIG="$HOME/.bash_profile"
fi

if [ -n "$SHELL_CONFIG" ]; then
    # 检查是否已存在
    if ! grep -q "CLOUDFLARE_API_TOKEN" "$SHELL_CONFIG"; then
        echo "" >> "$SHELL_CONFIG"
        echo "# ImagentX Cloudflare配置" >> "$SHELL_CONFIG"
        echo "export CLOUDFLARE_API_TOKEN=\"$API_TOKEN\"" >> "$SHELL_CONFIG"
        echo "export CLOUDFLARE_ZONE_ID=\"$ZONE_ID\"" >> "$SHELL_CONFIG"
        echo "export SERVER_IP=\"$SERVER_IP\"" >> "$SHELL_CONFIG"
        echo -e "${GREEN}✅ 环境变量已添加到 $SHELL_CONFIG${NC}"
    else
        echo -e "${YELLOW}⚠️ 环境变量已存在于 $SHELL_CONFIG${NC}"
    fi
fi

echo ""
echo -e "${GREEN}🎉 API Token配置完成！${NC}"
echo "=================================="
echo -e "${CYAN}📋 配置摘要：${NC}"
echo -e "${CYAN}   API Token: ${API_TOKEN:0:10}...${NC}"
echo -e "${CYAN}   Zone ID: $ZONE_ID${NC}"
echo -e "${CYAN}   服务器IP: $SERVER_IP${NC}"
echo -e "${CYAN}   域名: imagentx.top${NC}"
echo ""
echo -e "${YELLOW}🚀 下一步操作：${NC}"
echo -e "${YELLOW}   1. 确保域名服务器已更新为Cloudflare提供的服务器${NC}"
echo -e "${YELLOW}   2. 准备服务器环境（安装Docker等）${NC}"
echo -e "${YELLOW}   3. 运行部署脚本: ./scripts/deploy-imagentx.top.sh${NC}"
echo ""
echo -e "${YELLOW}💡 管理命令：${NC}"
echo -e "${YELLOW}   - 查看配置: cat .env.production${NC}"
echo -e "${YELLOW}   - 测试API: curl -H \"Authorization: Bearer \$CLOUDFLARE_API_TOKEN\" https://api.cloudflare.com/client/v4/user/tokens/verify${NC}"
echo -e "${YELLOW}   - 部署服务: ./scripts/deploy-imagentx.top.sh${NC}"
echo ""
echo -e "${GREEN}✨ 配置完成！现在可以开始部署了！${NC}"



