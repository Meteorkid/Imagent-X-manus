#!/bin/bash

# ImagentX SSL证书配置脚本 - imagent.top
# 使用Let's Encrypt自动配置SSL证书

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔐 ImagentX SSL证书配置脚本${NC}"
echo "=================================="
echo -e "${CYAN}域名: imagent.top${NC}"
echo -e "${CYAN}邮箱: admin@imagent.top${NC}"
echo ""

# 检查Docker是否运行
if ! docker info &> /dev/null; then
    echo -e "${RED}❌ Docker未运行，请先启动Docker Desktop${NC}"
    exit 1
fi

# 检查域名解析
echo -e "${YELLOW}🔍 检查域名解析...${NC}"
if ! nslookup imagent.top &> /dev/null; then
    echo -e "${RED}❌ 域名imagent.top无法解析，请先配置DNS记录${NC}"
    echo -e "${YELLOW}💡 需要配置的DNS记录：${NC}"
    echo -e "${YELLOW}   A记录: imagent.top -> 您的服务器IP${NC}"
    echo -e "${YELLOW}   A记录: www.imagent.top -> 您的服务器IP${NC}"
    exit 1
fi

echo -e "${GREEN}✅ 域名解析正常${NC}"

# 创建必要的目录
echo -e "${YELLOW}📁 创建必要的目录...${NC}"
sudo mkdir -p /var/www/certbot
sudo mkdir -p /etc/letsencrypt
sudo chown -R $USER:$USER /var/www/certbot

# 启动基础服务（不包含SSL）
echo -e "${YELLOW}🚀 启动基础服务...${NC}"
docker-compose -f docker-compose.imagent.top.yml up -d postgres rabbitmq backend frontend

# 等待服务启动
echo -e "${YELLOW}⏳ 等待服务启动...${NC}"
sleep 30

# 启动Nginx（HTTP模式）
echo -e "${YELLOW}🌐 启动Nginx（HTTP模式）...${NC}"
docker-compose -f docker-compose.imagent.top.yml up -d nginx

# 等待Nginx启动
sleep 10

# 测试HTTP访问
echo -e "${YELLOW}🔍 测试HTTP访问...${NC}"
if curl -s http://imagent.top > /dev/null; then
    echo -e "${GREEN}✅ HTTP访问正常${NC}"
else
    echo -e "${RED}❌ HTTP访问失败，请检查域名解析和防火墙设置${NC}"
    exit 1
fi

# 申请SSL证书
echo -e "${YELLOW}🔐 申请SSL证书...${NC}"
docker-compose -f docker-compose.imagent.top.yml run --rm certbot

# 检查证书是否申请成功
if [ -f "/etc/letsencrypt/live/imagent.top/fullchain.pem" ]; then
    echo -e "${GREEN}✅ SSL证书申请成功${NC}"
else
    echo -e "${RED}❌ SSL证书申请失败${NC}"
    exit 1
fi

# 重启Nginx以启用HTTPS
echo -e "${YELLOW}🔄 重启Nginx以启用HTTPS...${NC}"
docker-compose -f docker-compose.imagent.top.yml restart nginx

# 测试HTTPS访问
echo -e "${YELLOW}🔍 测试HTTPS访问...${NC}"
sleep 10

if curl -s https://imagent.top > /dev/null; then
    echo -e "${GREEN}✅ HTTPS访问正常${NC}"
else
    echo -e "${YELLOW}⚠️ HTTPS访问可能还在配置中，请稍等...${NC}"
fi

# 设置证书自动续期
echo -e "${YELLOW}🔄 设置证书自动续期...${NC}"
cat > /tmp/certbot-renew.sh << 'EOF'
#!/bin/bash
docker-compose -f /Users/Meteorkid/Downloads/Imagent-X/docker-compose.imagent.top.yml run --rm certbot renew
docker-compose -f /Users/Meteorkid/Downloads/Imagent-X/docker-compose.imagent.top.yml restart nginx
EOF

chmod +x /tmp/certbot-renew.sh

# 添加到crontab（每月1号凌晨2点检查续期）
(crontab -l 2>/dev/null; echo "0 2 1 * * /tmp/certbot-renew.sh") | crontab -

echo ""
echo -e "${GREEN}🎉 SSL证书配置完成！${NC}"
echo "=================================="
echo -e "${CYAN}🌐 网站地址: https://imagent.top${NC}"
echo -e "${CYAN}🔧 API地址: https://imagent.top/api${NC}"
echo -e "${CYAN}🔍 健康检查: https://imagent.top/health${NC}"
echo -e "${CYAN}📊 RabbitMQ管理: https://imagent.top:15672${NC}"
echo ""
echo -e "${YELLOW}💡 管理命令：${NC}"
echo -e "${YELLOW}   - 查看日志: docker-compose -f docker-compose.imagent.top.yml logs${NC}"
echo -e "${YELLOW}   - 停止服务: docker-compose -f docker-compose.imagent.top.yml down${NC}"
echo -e "${YELLOW}   - 重启服务: docker-compose -f docker-compose.imagent.top.yml restart${NC}"
echo -e "${YELLOW}   - 手动续期证书: /tmp/certbot-renew.sh${NC}"
echo ""
echo -e "${GREEN}✨ 现在可以通过 https://imagent.top 访问您的ImagentX服务了！${NC}"



