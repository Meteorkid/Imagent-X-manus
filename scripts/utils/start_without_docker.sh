#!/bin/bash

# Imagent X 项目手动启动脚本（不依赖Docker）
# 由于Docker镜像拉取存在问题，此脚本提供一种手动启动项目的方式

# 设置颜色变量
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # 无颜色

# 检查必要的依赖
check_dependencies() {
    echo -e "${BLUE}检查必要的依赖...${NC}"
    
    # 检查Java
    if ! command -v java &> /dev/null; then
        echo -e "${RED}错误: Java 17 未安装。请安装Java 17后重试。${NC}"
        exit 1
    fi
    
    # 检查Java版本
    JAVA_VERSION=$(java -version 2>&1 | awk -F '"' '/version/ {print $2}' | cut -d. -f1-2)
    if (( $(echo "$JAVA_VERSION < 17" | bc -l) )); then
        echo -e "${RED}错误: Java 版本过低 ($JAVA_VERSION)。请安装Java 17或更高版本。${NC}"
        exit 1
    fi
    
    # 检查Maven
    if ! command -v mvn &> /dev/null; then
        echo -e "${RED}错误: Maven 未安装。请安装Maven后重试。${NC}"
        exit 1
    fi
    
    # 检查Node.js
    if ! command -v node &> /dev/null; then
        echo -e "${RED}错误: Node.js 未安装。请安装Node.js后重试。${NC}"
        exit 1
    fi
    
    # 检查npm
    if ! command -v npm &> /dev/null; then
        echo -e "${RED}错误: npm 未安装。请安装npm后重试。${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}所有必要依赖检查通过！${NC}"
}

# 配置环境变量
configure_env() {
    echo -e "${BLUE}配置环境变量...${NC}"
    
    # 如果.env文件不存在，则创建一个基础版本
    if [ ! -f ".env" ]; then
        echo -e "${YELLOW}未找到.env文件，创建默认配置...${NC}"
        cat > .env << EOF
# 基础环境配置
ENV=development

# 后端配置
SERVER_PORT=8088

# 数据库配置
DB_HOST=localhost
DB_PORT=5432
DB_NAME=imagentx
DB_USER=postgres
DB_PASSWORD=postgres

# 向量数据库配置（默认使用与数据库相同的配置）
VECTOR_DB_HOST=\$DB_HOST
VECTOR_DB_PORT=\$DB_PORT
VECTOR_DB_NAME=\$DB_NAME
VECTOR_DB_USER=\$DB_USER
VECTOR_DB_PASSWORD=\$DB_PASSWORD
VECTOR_DB_DIMENSION=1024

# RabbitMQ配置
RABBITMQ_HOST=localhost
RABBITMQ_PORT=5672
RABBITMQ_USERNAME=guest
RABBITMQ_PASSWORD=guest

# 高可用配置
HIGH_AVAILABILITY_ENABLED=false

# 邮件配置（可选）
MAIL_SMTP_HOST=smtp.qq.com
MAIL_SMTP_PORT=587
MAIL_SMTP_USERNAME=
MAIL_SMTP_PASSWORD=

# GitHub配置
GITHUB_REPO_NAME=agent-mcp-community
GITHUB_USERNAME=lucky-aeon
GITHUB_TOKEN=

# 其他配置（按需填写）
EOF
    fi
    
    echo -e "${GREEN}环境变量配置完成！${NC}"
}

# 提示用户安装外部服务
install_external_services() {
    echo -e "${YELLOW}请注意：在继续之前，您需要手动安装和配置以下服务：${NC}"
    echo -e "${BLUE}1. PostgreSQL (推荐版本 12+)${NC}"
    echo -e "   - 创建数据库: imagentx"
    echo -e "   - 创建用户: postgres (密码: postgres)"
    echo -e "   - 安装 pgvector 扩展"
    echo -e ""
    echo -e "${BLUE}2. RabbitMQ${NC}"
    echo -e "   - 默认用户: guest"
    echo -e "   - 默认密码: guest"
    echo -e ""
    echo -e "${YELLOW}安装完成后按任意键继续...${NC}"
    read -n 1 -s
}

# 构建和启动后端服务
start_backend() {
    echo -e "${BLUE}构建和启动后端服务...${NC}"
    cd ImagentX || exit
    
    # 构建项目
    echo -e "${BLUE}正在构建后端项目...${NC}"
    mvn clean install
    if [ $? -ne 0 ]; then
        echo -e "${RED}后端项目构建失败！${NC}"
        exit 1
    fi
    
    # 启动后端服务
    echo -e "${BLUE}正在启动后端服务...${NC}"
    mvn spring-boot:run &
    BACKEND_PID=$!
    echo -e "${GREEN}后端服务已启动（PID: $BACKEND_PID）${NC}"
    
    cd ..
}

# 构建和启动前端服务
start_frontend() {
    echo -e "${BLUE}构建和启动前端服务...${NC}"
    cd imagentx-frontend-plus || exit
    
    # 安装依赖
    echo -e "${BLUE}正在安装前端依赖...${NC}"
    npm install
    if [ $? -ne 0 ]; then
        echo -e "${RED}前端依赖安装失败！${NC}"
        exit 1
    fi
    
    # 启动前端服务
    echo -e "${BLUE}正在启动前端服务...${NC}"
    npm run dev &
    FRONTEND_PID=$!
    echo -e "${GREEN}前端服务已启动（PID: $FRONTEND_PID）${NC}"
    
    cd ..
}

# 显示服务访问信息
show_access_info() {
    echo -e "\n${BLUE}=====================================${NC}"
    echo -e "${GREEN}Imagent X 项目启动成功！${NC}"
    echo -e "${BLUE}=====================================${NC}"
    echo -e "${GREEN}后端API地址: http://localhost:8088/api${NC}"
    echo -e "${GREEN}前端访问地址: http://localhost:3000${NC}"
    echo -e "${BLUE}=====================================${NC}"
    echo -e "${YELLOW}按 Ctrl+C 停止所有服务${NC}"
}

# 清理函数
cleanup() {
    echo -e "\n${BLUE}正在停止所有服务...${NC}"
    if [ -n "$BACKEND_PID" ]; then
        kill $BACKEND_PID 2>/dev/null
        echo -e "${GREEN}后端服务已停止${NC}"
    fi
    if [ -n "$FRONTEND_PID" ]; then
        kill $FRONTEND_PID 2>/dev/null
        echo -e "${GREEN}前端服务已停止${NC}"
    fi
    echo -e "${GREEN}所有服务已停止，感谢使用！${NC}"
}

# 主函数
main() {
    echo -e "${BLUE}===== Imagent X 项目手动启动脚本 =====${NC}"
    
    # 设置清理函数
    trap cleanup SIGINT SIGTERM
    
    # 执行各个步骤
    check_dependencies
    configure_env
    install_external_services
    start_backend
    
    # 等待后端服务启动
    echo -e "${BLUE}等待后端服务初始化...${NC}"
    sleep 10
    
    start_frontend
    show_access_info
    
    # 保持脚本运行
    wait
}

# 执行主函数
main