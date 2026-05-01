#!/bin/bash

# MCP网关启动脚本
# 用于启动MCP网关服务

set -e

HOST_PORT="${MCP_GATEWAY_HOST_PORT:-8081}"
CONTAINER_PORT="${MCP_GATEWAY_CONTAINER_PORT:-8080}"
API_KEY="${MCP_GATEWAY_API_KEY:-default-api-key-1234567890}"
ALLOW_401_AS_HEALTHY="${MCP_GATEWAY_ALLOW_401_AS_HEALTHY:-true}"

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # 无颜色

echo -e "${BLUE}🚀 启动MCP网关服务...${NC}"

# 检查Docker服务状态
check_docker() {
    if ! docker info >/dev/null 2>&1; then
        echo -e "${YELLOW}⚠️  Docker服务未运行，尝试启动Docker Desktop...${NC}"
        open -a Docker
        echo -e "${YELLOW}等待Docker启动...${NC}"
        sleep 30
        
        if ! docker info >/dev/null 2>&1; then
            echo -e "${RED}❌ Docker服务启动失败，请手动启动Docker Desktop${NC}"
            exit 1
        fi
    fi
    echo -e "${GREEN}✅ Docker服务正常运行${NC}"
}

# 启动MCP网关容器
start_mcp_gateway() {
    echo -e "${BLUE}📦 拉取MCP网关镜像...${NC}"
    
    # 尝试拉取MCP网关镜像
    if ! docker pull ghcr.io/lucky-aeon/mcp-gateway:latest; then
        echo -e "${YELLOW}⚠️  无法拉取MCP网关镜像，尝试使用本地镜像...${NC}"
        
        # 检查是否有本地镜像
        if ! docker images | grep -q "mcp-gateway"; then
            echo -e "${RED}❌ 未找到MCP网关镜像，请检查网络连接或手动下载${NC}"
            echo -e "${YELLOW}提示：您可以尝试手动拉取镜像：${NC}"
            echo -e "${YELLOW}docker pull ghcr.io/lucky-aeon/mcp-gateway:latest${NC}"
            exit 1
        fi
    fi
    
    echo -e "${BLUE}🔧 启动MCP网关容器...${NC}"
    
    # 停止并删除已存在的容器
    docker stop mcp-gateway 2>/dev/null || true
    docker rm mcp-gateway 2>/dev/null || true
    
    # 启动MCP网关容器
    docker run -d \
        --name mcp-gateway \
        -p "${HOST_PORT}:${CONTAINER_PORT}" \
        -e MCP_GATEWAY_API_KEY="${API_KEY}" \
        -e MCP_GATEWAY_PORT="${CONTAINER_PORT}" \
        ghcr.io/lucky-aeon/mcp-gateway:latest
    
    echo -e "${GREEN}✅ MCP网关容器已启动${NC}"
}

# 检查MCP网关服务状态
check_mcp_gateway() {
    echo -e "${BLUE}🔍 检查MCP网关服务状态...${NC}"
    
    # 等待服务启动
    for i in {1..30}; do
        status=""

        status="$(curl -sS -o /dev/null -w '%{http_code}' "http://localhost:${HOST_PORT}/health" || true)"
        if [ "$status" = "200" ]; then
            echo -e "${GREEN}✅ MCP网关服务已启动并正常运行${NC}"
            echo -e "${BLUE}🌐 MCP网关地址: http://localhost:${HOST_PORT}${NC}"
            echo -e "${BLUE}🔍 健康检查: http://localhost:${HOST_PORT}/health${NC}"
            return 0
        fi
        if [ "$status" = "401" ] && [ "$ALLOW_401_AS_HEALTHY" != "false" ]; then
            echo -e "${GREEN}✅ MCP网关已启动（鉴权开启，401 视为可达）${NC}"
            echo -e "${BLUE}🌐 MCP网关地址: http://localhost:${HOST_PORT}${NC}"
            return 0
        fi

        status="$(curl -sS -o /dev/null -w '%{http_code}' "http://localhost:${HOST_PORT}/api/health" || true)"
        if [ "$status" = "200" ]; then
            echo -e "${GREEN}✅ MCP网关服务已启动并正常运行${NC}"
            echo -e "${BLUE}🌐 MCP网关地址: http://localhost:${HOST_PORT}${NC}"
            echo -e "${BLUE}🔍 健康检查: http://localhost:${HOST_PORT}/api/health${NC}"
            return 0
        fi
        if [ "$status" = "401" ] && [ "$ALLOW_401_AS_HEALTHY" != "false" ]; then
            echo -e "${GREEN}✅ MCP网关已启动（鉴权开启，401 视为可达）${NC}"
            echo -e "${BLUE}🌐 MCP网关地址: http://localhost:${HOST_PORT}${NC}"
            return 0
        fi
        
        echo -e "${YELLOW}⏳ 等待MCP网关服务启动... (${i}/30)${NC}"
        sleep 2
    done
    
    echo -e "${RED}❌ MCP网关服务启动超时${NC}"
    echo -e "${YELLOW}检查容器日志：${NC}"
    docker logs mcp-gateway
    return 1
}

# 显示使用说明
show_usage() {
    local api_key_display="(已配置)"
    if [ "$API_KEY" = "default-api-key-1234567890" ]; then
        api_key_display="$API_KEY"
    fi

    echo -e "\n${BLUE}📖 MCP网关使用说明:${NC}"
    echo -e "${GREEN}• 网关地址: http://localhost:${HOST_PORT}${NC}"
    echo -e "${GREEN}• API密钥: ${api_key_display}${NC}"
    echo -e "${GREEN}• 健康检查: http://localhost:${HOST_PORT}/health${NC}"
    echo -e "\n${YELLOW}常用命令:${NC}"
    echo -e "${YELLOW}• 查看日志: docker logs -f mcp-gateway${NC}"
    echo -e "${YELLOW}• 停止服务: docker stop mcp-gateway${NC}"
    echo -e "${YELLOW}• 重启服务: docker restart mcp-gateway${NC}"
    echo -e "${YELLOW}• 删除容器: docker rm -f mcp-gateway${NC}"
}

# 主函数
main() {
    echo -e "${BLUE}===== MCP网关启动脚本 =====${NC}"
    
    check_docker
    start_mcp_gateway
    check_mcp_gateway
    
    if [ $? -eq 0 ]; then
        show_usage
        echo -e "\n${GREEN}🎉 MCP网关启动成功！${NC}"
    else
        echo -e "\n${RED}❌ MCP网关启动失败${NC}"
        exit 1
    fi
}

# 执行主函数
main "$@"
