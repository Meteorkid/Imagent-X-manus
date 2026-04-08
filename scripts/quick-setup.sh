#!/bin/bash

# ImagentX 快速配置脚本
# 帮助您快速完成Cloudflare配置

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 ImagentX 快速配置脚本${NC}"
echo "=================================="
echo -e "${CYAN}域名: imagent.top${NC}"
echo -e "${CYAN}CDN: Cloudflare${NC}"
echo ""

# 检查当前环境
echo -e "${YELLOW}🔍 检查当前环境...${NC}"

# 检查是否在项目目录
if [ ! -f "docker-compose.imagent.top.cloudflare.yml" ]; then
    echo -e "${RED}❌ 请在ImagentX项目根目录运行此脚本${NC}"
    exit 1
fi

# 检查Docker
if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker未安装，请先安装Docker${NC}"
    exit 1
fi

# 检查Docker Compose
if ! command -v docker-compose &> /dev/null; then
    echo -e "${RED}❌ Docker Compose未安装，请先安装Docker Compose${NC}"
    exit 1
fi

echo -e "${GREEN}✅ 环境检查完成${NC}"
echo ""

# 配置步骤选择
echo -e "${YELLOW}📋 请选择配置步骤：${NC}"
echo "1. 本地测试配置"
echo "2. 准备生产环境配置"
echo "3. 运行完整部署"
echo "4. 验证配置"
echo "5. 查看帮助"
echo ""

read -p "请输入选项 (1-5): " choice

case $choice in
    1)
        echo -e "${CYAN}🧪 运行本地测试配置...${NC}"
        echo ""
        
        # 检查本地服务
        echo -e "${YELLOW}🔍 检查本地服务状态...${NC}"
        
        if curl -s http://localhost:3000 > /dev/null; then
            echo -e "${GREEN}✅ 前端服务正常${NC}"
        else
            echo -e "${RED}❌ 前端服务未运行，请先启动前端服务${NC}"
            echo -e "${YELLOW}💡 运行: cd apps/frontend && npm run dev${NC}"
            exit 1
        fi
        
        if curl -s http://localhost:8088/api/health > /dev/null; then
            echo -e "${GREEN}✅ 后端服务正常${NC}"
        else
            echo -e "${RED}❌ 后端服务未运行，请先启动后端服务${NC}"
            echo -e "${YELLOW}💡 运行: cd apps/backend && ./mvnw spring-boot:run${NC}"
            exit 1
        fi
        
        # 运行本地测试
        echo -e "${YELLOW}🧪 运行本地测试...${NC}"
        ./scripts/test-cloudflare-local.sh
        ;;
        
    2)
        echo -e "${CYAN}🔧 准备生产环境配置...${NC}"
        echo ""
        
        # 创建环境配置文件
        if [ ! -f ".env.production" ]; then
            echo -e "${YELLOW}📝 创建生产环境配置文件...${NC}"
            cat > .env.production << 'EOF'
# Cloudflare配置
CLOUDFLARE_API_TOKEN=your_api_token_here
CLOUDFLARE_ZONE_ID=your_zone_id_here

# 服务器配置
SERVER_IP=your_server_ip_here
DOMAIN=imagent.top

# 数据库配置
POSTGRES_PASSWORD=your_secure_password_here
RABBITMQ_PASSWORD=your_secure_password_here

# 应用配置
NODE_ENV=production
SPRING_PROFILES_ACTIVE=production
EOF
            echo -e "${GREEN}✅ 环境配置文件已创建: .env.production${NC}"
        else
            echo -e "${GREEN}✅ 环境配置文件已存在${NC}"
        fi
        
        # 提示配置信息
        echo ""
        echo -e "${YELLOW}💡 请编辑 .env.production 文件，填入以下信息：${NC}"
        echo -e "${CYAN}   - CLOUDFLARE_API_TOKEN: 您的Cloudflare API Token${NC}"
        echo -e "${CYAN}   - CLOUDFLARE_ZONE_ID: 您的Cloudflare Zone ID${NC}"
        echo -e "${CYAN}   - SERVER_IP: 您的服务器IP地址${NC}"
        echo -e "${CYAN}   - POSTGRES_PASSWORD: 数据库密码${NC}"
        echo -e "${CYAN}   - RABBITMQ_PASSWORD: 消息队列密码${NC}"
        echo ""
        echo -e "${YELLOW}📖 详细配置说明请查看: docs/CLOUDFLARE_SETUP_GUIDE.md${NC}"
        ;;
        
    3)
        echo -e "${CYAN}🚀 运行完整部署...${NC}"
        echo ""
        
        # 检查环境变量
        if [ ! -f ".env.production" ]; then
            echo -e "${RED}❌ 请先运行选项2准备生产环境配置${NC}"
            exit 1
        fi
        
        # 加载环境变量
        source .env.production
        
        # 检查必要的环境变量
        if [ -z "$CLOUDFLARE_API_TOKEN" ] || [ "$CLOUDFLARE_API_TOKEN" = "your_api_token_here" ]; then
            echo -e "${RED}❌ 请先配置CLOUDFLARE_API_TOKEN${NC}"
            exit 1
        fi
        
        if [ -z "$CLOUDFLARE_ZONE_ID" ] || [ "$CLOUDFLARE_ZONE_ID" = "your_zone_id_here" ]; then
            echo -e "${RED}❌ 请先配置CLOUDFLARE_ZONE_ID${NC}"
            exit 1
        fi
        
        if [ -z "$SERVER_IP" ] || [ "$SERVER_IP" = "your_server_ip_here" ]; then
            echo -e "${RED}❌ 请先配置SERVER_IP${NC}"
            exit 1
        fi
        
        # 运行部署脚本
        echo -e "${YELLOW}🚀 开始部署...${NC}"
        ./scripts/deploy-cloudflare.sh
        ;;
        
    4)
        echo -e "${CYAN}🔍 验证配置...${NC}"
        echo ""
        
        # 运行测试脚本
        ./scripts/test-cloudflare-local.sh
        
        echo ""
        echo -e "${YELLOW}💡 手动验证步骤：${NC}"
        echo -e "${CYAN}   1. 访问 https://imagent.top${NC}"
        echo -e "${CYAN}   2. 检查SSL证书是否正常${NC}"
        echo -e "${CYAN}   3. 测试API接口: https://imagent.top/api/health${NC}"
        echo -e "${CYAN}   4. 检查页面加载速度${NC}"
        ;;
        
    5)
        echo -e "${CYAN}📖 查看帮助信息...${NC}"
        echo ""
        echo -e "${YELLOW}📚 相关文档：${NC}"
        echo -e "${CYAN}   - 下一步配置指南: NEXT_STEPS_GUIDE.md${NC}"
        echo -e "${CYAN}   - Cloudflare配置指南: docs/CLOUDFLARE_SETUP_GUIDE.md${NC}"
        echo -e "${CYAN}   - 域名配置指南: docs/DOMAIN_SETUP_IMAGENT_TOP.md${NC}"
        echo ""
        echo -e "${YELLOW}🔗 重要链接：${NC}"
        echo -e "${CYAN}   - Cloudflare Dashboard: https://dash.cloudflare.com${NC}"
        echo -e "${CYAN}   - 域名管理: 您的域名注册商管理面板${NC}"
        echo -e "${CYAN}   - SSL测试: https://www.ssllabs.com/ssltest/${NC}"
        echo ""
        echo -e "${YELLOW}📞 技术支持：${NC}"
        echo -e "${CYAN}   - GitHub Issues: https://github.com/Meteor-kid/ImagentX/issues${NC}"
        echo -e "${CYAN}   - 项目文档: docs/README.md${NC}"
        ;;
        
    *)
        echo -e "${RED}❌ 无效选项，请输入1-5${NC}"
        exit 1
        ;;
esac

echo ""
echo -e "${GREEN}✨ 操作完成！${NC}"
echo ""
echo -e "${YELLOW}💡 提示：${NC}"
echo -e "${YELLOW}   - 如需帮助，请运行: ./scripts/quick-setup.sh 并选择选项5${NC}"
echo -e "${YELLOW}   - 查看详细文档: cat NEXT_STEPS_GUIDE.md${NC}"
echo -e "${YELLOW}   - 重新运行此脚本: ./scripts/quick-setup.sh${NC}"



