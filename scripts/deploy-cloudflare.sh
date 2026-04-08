#!/bin/bash

# ImagentX Cloudflare部署脚本
# 自动配置Cloudflare CDN和SSL

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${BLUE}☁️ ImagentX Cloudflare部署脚本${NC}"
echo "=================================="
echo -e "${CYAN}域名: imagent.top${NC}"
echo -e "${CYAN}CDN: Cloudflare${NC}"
echo ""

# 检查Docker是否运行
if ! docker info &> /dev/null; then
    echo -e "${RED}❌ Docker未运行，请先启动Docker Desktop${NC}"
    exit 1
fi

# 检查必要的环境变量
if [ -z "$CLOUDFLARE_API_TOKEN" ]; then
    echo -e "${YELLOW}⚠️ 未设置CLOUDFLARE_API_TOKEN环境变量${NC}"
    echo -e "${YELLOW}💡 请在Cloudflare Dashboard -> My Profile -> API Tokens 创建Token${NC}"
    echo -e "${YELLOW}💡 需要权限: Zone:Read, DNS:Edit, SSL:Edit${NC}"
    echo ""
    read -p "请输入您的Cloudflare API Token: " CLOUDFLARE_API_TOKEN
    export CLOUDFLARE_API_TOKEN
fi

if [ -z "$CLOUDFLARE_ZONE_ID" ]; then
    echo -e "${YELLOW}⚠️ 未设置CLOUDFLARE_ZONE_ID环境变量${NC}"
    echo -e "${YELLOW}💡 可以在Cloudflare Dashboard -> 域名概览页面找到Zone ID${NC}"
    echo ""
    read -p "请输入您的Cloudflare Zone ID: " CLOUDFLARE_ZONE_ID
    export CLOUDFLARE_ZONE_ID
fi

# 检查服务器IP
if [ -z "$SERVER_IP" ]; then
    echo -e "${YELLOW}⚠️ 未设置SERVER_IP环境变量${NC}"
    echo -e "${YELLOW}💡 请输入您的服务器公网IP地址${NC}"
    echo ""
    read -p "请输入您的服务器IP地址: " SERVER_IP
    export SERVER_IP
fi

echo -e "${GREEN}✅ 环境变量配置完成${NC}"
echo ""

# 安装Cloudflare CLI工具
echo -e "${YELLOW}📦 安装Cloudflare CLI工具...${NC}"
if ! command -v cloudflared &> /dev/null; then
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        brew install cloudflared
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Linux
        wget -q https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
        sudo dpkg -i cloudflared-linux-amd64.deb
        rm cloudflared-linux-amd64.deb
    fi
fi

# 安装jq工具
if ! command -v jq &> /dev/null; then
    if [[ "$OSTYPE" == "darwin"* ]]; then
        brew install jq
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        sudo apt-get update && sudo apt-get install -y jq
    fi
fi

echo -e "${GREEN}✅ 工具安装完成${NC}"
echo ""

# 验证Cloudflare API连接
echo -e "${YELLOW}🔍 验证Cloudflare API连接...${NC}"
if curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$CLOUDFLARE_ZONE_ID" \
    -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
    -H "Content-Type: application/json" | jq -r '.success' | grep -q "true"; then
    echo -e "${GREEN}✅ Cloudflare API连接正常${NC}"
else
    echo -e "${RED}❌ Cloudflare API连接失败，请检查Token和Zone ID${NC}"
    exit 1
fi

# 配置DNS记录
echo -e "${YELLOW}🌐 配置DNS记录...${NC}"

# 检查A记录是否存在
A_RECORD_EXISTS=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$CLOUDFLARE_ZONE_ID/dns_records?name=imagent.top&type=A" \
    -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
    -H "Content-Type: application/json" | jq -r '.result | length')

if [ "$A_RECORD_EXISTS" -eq 0 ]; then
    # 创建A记录
    curl -s -X POST "https://api.cloudflare.com/client/v4/zones/$CLOUDFLARE_ZONE_ID/dns_records" \
        -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
        -H "Content-Type: application/json" \
        --data "{\"type\":\"A\",\"name\":\"imagent.top\",\"content\":\"$SERVER_IP\",\"ttl\":1,\"proxied\":true}" > /dev/null
    echo -e "${GREEN}✅ 创建A记录: imagent.top -> $SERVER_IP${NC}"
else
    # 更新A记录
    RECORD_ID=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$CLOUDFLARE_ZONE_ID/dns_records?name=imagent.top&type=A" \
        -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
        -H "Content-Type: application/json" | jq -r '.result[0].id')
    
    curl -s -X PUT "https://api.cloudflare.com/client/v4/zones/$CLOUDFLARE_ZONE_ID/dns_records/$RECORD_ID" \
        -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
        -H "Content-Type: application/json" \
        --data "{\"type\":\"A\",\"name\":\"imagent.top\",\"content\":\"$SERVER_IP\",\"ttl\":1,\"proxied\":true}" > /dev/null
    echo -e "${GREEN}✅ 更新A记录: imagent.top -> $SERVER_IP${NC}"
fi

# 配置www子域名
WWW_RECORD_EXISTS=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$CLOUDFLARE_ZONE_ID/dns_records?name=www.imagent.top&type=A" \
    -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
    -H "Content-Type: application/json" | jq -r '.result | length')

if [ "$WWW_RECORD_EXISTS" -eq 0 ]; then
    curl -s -X POST "https://api.cloudflare.com/client/v4/zones/$CLOUDFLARE_ZONE_ID/dns_records" \
        -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
        -H "Content-Type: application/json" \
        --data "{\"type\":\"A\",\"name\":\"www.imagent.top\",\"content\":\"$SERVER_IP\",\"ttl\":1,\"proxied\":true}" > /dev/null
    echo -e "${GREEN}✅ 创建A记录: www.imagent.top -> $SERVER_IP${NC}"
else
    WWW_RECORD_ID=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$CLOUDFLARE_ZONE_ID/dns_records?name=www.imagent.top&type=A" \
        -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
        -H "Content-Type: application/json" | jq -r '.result[0].id')
    
    curl -s -X PUT "https://api.cloudflare.com/client/v4/zones/$CLOUDFLARE_ZONE_ID/dns_records/$WWW_RECORD_ID" \
        -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
        -H "Content-Type: application/json" \
        --data "{\"type\":\"A\",\"name\":\"www.imagent.top\",\"content\":\"$SERVER_IP\",\"ttl\":1,\"proxied\":true}" > /dev/null
    echo -e "${GREEN}✅ 更新A记录: www.imagent.top -> $SERVER_IP${NC}"
fi

# 配置SSL/TLS设置
echo -e "${YELLOW}🔐 配置SSL/TLS设置...${NC}"
curl -s -X PATCH "https://api.cloudflare.com/client/v4/zones/$CLOUDFLARE_ZONE_ID/settings/ssl" \
    -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
    -H "Content-Type: application/json" \
    --data '{"value":"flexible"}' > /dev/null

curl -s -X PATCH "https://api.cloudflare.com/client/v4/zones/$CLOUDFLARE_ZONE_ID/settings/always_use_https" \
    -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
    -H "Content-Type: application/json" \
    --data '{"value":"on"}' > /dev/null

echo -e "${GREEN}✅ SSL/TLS配置完成${NC}"

# 配置缓存设置
echo -e "${YELLOW}💾 配置缓存设置...${NC}"
curl -s -X PATCH "https://api.cloudflare.com/client/v4/zones/$CLOUDFLARE_ZONE_ID/settings/cache_level" \
    -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
    -H "Content-Type: application/json" \
    --data '{"value":"aggressive"}' > /dev/null

echo -e "${GREEN}✅ 缓存配置完成${NC}"

# 启动Docker服务
echo -e "${YELLOW}🚀 启动Docker服务...${NC}"
docker-compose -f docker-compose.imagent.top.cloudflare.yml up -d

# 等待服务启动
echo -e "${YELLOW}⏳ 等待服务启动...${NC}"
sleep 30

# 检查服务状态
echo -e "${YELLOW}🔍 检查服务状态...${NC}"
docker-compose -f docker-compose.imagent.top.cloudflare.yml ps

# 测试服务访问
echo -e "${YELLOW}🔍 测试服务访问...${NC}"
sleep 10

# 等待DNS传播
echo -e "${YELLOW}⏳ 等待DNS传播（最多5分钟）...${NC}"
for i in {1..30}; do
    if curl -s http://imagent.top > /dev/null 2>&1; then
        echo -e "${GREEN}✅ 域名访问正常${NC}"
        break
    fi
    if [ $i -eq 30 ]; then
        echo -e "${YELLOW}⚠️ DNS传播可能需要更长时间，请稍后手动测试${NC}"
        break
    fi
    echo -n "."
    sleep 10
done

echo ""
echo -e "${GREEN}🎉 Cloudflare部署完成！${NC}"
echo "=================================="
echo -e "${CYAN}🌐 网站地址: https://imagent.top${NC}"
echo -e "${CYAN}🔧 API地址: https://imagent.top/api${NC}"
echo -e "${CYAN}🔍 健康检查: https://imagent.top/health${NC}"
echo -e "${CYAN}📊 监控面板: http://$SERVER_IP:9090${NC}"
echo ""
echo -e "${YELLOW}💡 Cloudflare功能：${NC}"
echo -e "${YELLOW}   - CDN加速: 全球节点加速${NC}"
echo -e "${YELLOW}   - SSL证书: 自动HTTPS重定向${NC}"
echo -e "${YELLOW}   - DDoS防护: 自动攻击防护${NC}"
echo -e "${YELLOW}   - 缓存优化: 静态资源缓存${NC}"
echo -e "${YELLOW}   - 安全防护: WAF和Bot管理${NC}"
echo ""
echo -e "${YELLOW}🔧 管理命令：${NC}"
echo -e "${YELLOW}   - 查看日志: docker-compose -f docker-compose.imagent.top.cloudflare.yml logs${NC}"
echo -e "${YELLOW}   - 停止服务: docker-compose -f docker-compose.imagent.top.cloudflare.yml down${NC}"
echo -e "${YELLOW}   - 重启服务: docker-compose -f docker-compose.imagent.top.cloudflare.yml restart${NC}"
echo ""
echo -e "${GREEN}✨ 现在可以通过 https://imagent.top 访问您的ImagentX服务了！${NC}"



