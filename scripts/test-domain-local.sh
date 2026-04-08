#!/bin/bash

# ImagentX 本地域名测试脚本
# 用于在本地环境测试域名配置

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${BLUE}🧪 ImagentX 本地域名测试脚本${NC}"
echo "=================================="
echo -e "${CYAN}测试域名: imagent.top${NC}"
echo ""

# 检查服务是否运行
echo -e "${YELLOW}🔍 检查本地服务状态...${NC}"

# 检查前端服务
if curl -s http://localhost:3000 > /dev/null; then
    echo -e "${GREEN}✅ 前端服务正常 (localhost:3000)${NC}"
else
    echo -e "${RED}❌ 前端服务未运行${NC}"
    echo -e "${YELLOW}💡 请先运行: cd apps/frontend && npm run dev${NC}"
    exit 1
fi

# 检查后端服务
if curl -s http://localhost:8088/api/health > /dev/null; then
    echo -e "${GREEN}✅ 后端服务正常 (localhost:8088)${NC}"
else
    echo -e "${RED}❌ 后端服务未运行${NC}"
    echo -e "${YELLOW}💡 请先运行: cd apps/backend && ./mvnw spring-boot:run${NC}"
    exit 1
fi

# 检查Docker服务
if docker ps | grep -q "imagentx-postgres-dev"; then
    echo -e "${GREEN}✅ PostgreSQL服务正常${NC}"
else
    echo -e "${RED}❌ PostgreSQL服务未运行${NC}"
    echo -e "${YELLOW}💡 请先运行: docker-compose -f config/docker/docker-compose-local-dev.yml up -d postgres rabbitmq${NC}"
    exit 1
fi

if docker ps | grep -q "imagentx-rabbitmq-dev"; then
    echo -e "${GREEN}✅ RabbitMQ服务正常${NC}"
else
    echo -e "${RED}❌ RabbitMQ服务未运行${NC}"
    exit 1
fi

echo ""

# 配置本地hosts文件
echo -e "${YELLOW}📝 配置本地hosts文件...${NC}"

# 检查是否已配置
if grep -q "imagent.top" /etc/hosts; then
    echo -e "${GREEN}✅ hosts文件已配置imagent.top${NC}"
else
    echo -e "${YELLOW}⚠️ 需要配置hosts文件${NC}"
    echo -e "${YELLOW}请手动添加以下内容到 /etc/hosts 文件：${NC}"
    echo -e "${CYAN}127.0.0.1 imagent.top${NC}"
    echo -e "${CYAN}127.0.0.1 www.imagent.top${NC}"
    echo ""
    echo -e "${YELLOW}或者运行以下命令（需要sudo权限）：${NC}"
    echo -e "${CYAN}sudo sh -c 'echo \"127.0.0.1 imagent.top\" >> /etc/hosts'${NC}"
    echo -e "${CYAN}sudo sh -c 'echo \"127.0.0.1 www.imagent.top\" >> /etc/hosts'${NC}"
    echo ""
    read -p "是否现在配置hosts文件？(y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        sudo sh -c 'echo "127.0.0.1 imagent.top" >> /etc/hosts'
        sudo sh -c 'echo "127.0.0.1 www.imagent.top" >> /etc/hosts'
        echo -e "${GREEN}✅ hosts文件配置完成${NC}"
    else
        echo -e "${YELLOW}⚠️ 请手动配置hosts文件后重新运行此脚本${NC}"
        exit 1
    fi
fi

echo ""

# 启动Nginx代理
echo -e "${YELLOW}🌐 启动Nginx代理服务...${NC}"

# 检查Nginx是否已安装
if ! command -v nginx &> /dev/null; then
    echo -e "${YELLOW}⚠️ Nginx未安装，使用Docker运行Nginx${NC}"
    
    # 创建简化的Nginx配置
    cat > /tmp/nginx-test.conf << 'EOF'
events {
    worker_connections 1024;
}

http {
    upstream frontend {
        server host.docker.internal:3000;
    }
    
    upstream backend {
        server host.docker.internal:8088;
    }

    server {
        listen 80;
        server_name imagent.top www.imagent.top;

        location / {
            proxy_pass http://frontend;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
        
        location /api/ {
            proxy_pass http://backend/api/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
    }
}
EOF

    # 启动Docker Nginx
    docker run -d --name imagentx-nginx-test \
        -p 80:80 \
        -v /tmp/nginx-test.conf:/etc/nginx/nginx.conf:ro \
        --add-host=host.docker.internal:host-gateway \
        nginx:alpine
    
    echo -e "${GREEN}✅ Docker Nginx启动完成${NC}"
else
    echo -e "${GREEN}✅ 系统Nginx可用${NC}"
    echo -e "${YELLOW}💡 请手动配置Nginx使用imagent.top.conf配置文件${NC}"
fi

echo ""

# 等待服务启动
echo -e "${YELLOW}⏳ 等待服务启动...${NC}"
sleep 5

# 测试域名访问
echo -e "${YELLOW}🔍 测试域名访问...${NC}"

# 测试主域名
if curl -s http://imagent.top > /dev/null; then
    echo -e "${GREEN}✅ 主域名访问正常: http://imagent.top${NC}"
else
    echo -e "${RED}❌ 主域名访问失败${NC}"
fi

# 测试www子域名
if curl -s http://www.imagent.top > /dev/null; then
    echo -e "${GREEN}✅ www子域名访问正常: http://www.imagent.top${NC}"
else
    echo -e "${RED}❌ www子域名访问失败${NC}"
fi

# 测试API接口
if curl -s http://imagent.top/api/health > /dev/null; then
    echo -e "${GREEN}✅ API接口访问正常: http://imagent.top/api/health${NC}"
else
    echo -e "${RED}❌ API接口访问失败${NC}"
fi

echo ""

# 显示测试结果
echo -e "${GREEN}🎉 域名测试完成！${NC}"
echo "=================================="
echo -e "${CYAN}🌐 测试地址：${NC}"
echo -e "${CYAN}   - 主站: http://imagent.top${NC}"
echo -e "${CYAN}   - www: http://www.imagent.top${NC}"
echo -e "${CYAN}   - API: http://imagent.top/api/health${NC}"
echo -e "${CYAN}   - 离线游戏: http://imagent.top/offline-demo${NC}"
echo ""
echo -e "${YELLOW}💡 注意事项：${NC}"
echo -e "${YELLOW}   - 这是本地测试环境，仅用于验证配置${NC}"
echo -e "${YELLOW}   - 生产环境需要配置真实的DNS和SSL证书${NC}"
echo -e "${YELLOW}   - 停止测试: docker stop imagentx-nginx-test && docker rm imagentx-nginx-test${NC}"
echo ""
echo -e "${GREEN}✨ 现在可以在浏览器中访问 http://imagent.top 测试您的配置了！${NC}"



