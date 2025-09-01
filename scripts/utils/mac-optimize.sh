#!/bin/bash

# Imagent X macOS 优化配置脚本
# 专为Apple Silicon和Intel Mac优化

set -e

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🍎 Imagent X macOS 优化配置${NC}"
echo "================================"

# 检测Mac架构
ARCH=$(uname -m)
if [[ "$ARCH" == "arm64" ]]; then
    echo -e "${GREEN}✅ 检测到Apple Silicon (M1/M2)${NC}"
    PLATFORM="linux/arm64"
    JVM_OPTS="-XX:+UseG1GC -XX:MaxGCPauseMillis=200 -Xms1g -Xmx2g"
else
    echo -e "${GREEN}✅ 检测到Intel Mac${NC}"
    PLATFORM="linux/amd64"
    JVM_OPTS="-XX:+UseG1GC -XX:MaxGCPauseMillis=200 -Xms1g -Xmx3g"
fi

# 检查macOS版本
MACOS_VERSION=$(sw_vers -productVersion)
echo -e "${BLUE}📱 macOS版本: ${MACOS_VERSION}${NC}"

# 检查Docker Desktop
if ! docker info >/dev/null 2>&1; then
    echo -e "${RED}❌ Docker Desktop未运行${NC}"
    echo -e "${YELLOW}请先启动Docker Desktop或安装: https://docs.docker.com/desktop/install/mac-install/${NC}"
    exit 1
fi

# 检查可用内存
TOTAL_MEM=$(sysctl -n hw.memsize | awk '{print int($1/1024/1024/1024)}')
echo -e "${BLUE}💾 总内存: ${TOTAL_MEM}GB${NC}"

# 根据内存调整配置
if [[ $TOTAL_MEM -lt 8 ]]; then
    POSTGRES_MEM="512m"
    RABBITMQ_MEM="512m"
    BACKEND_MEM="1g"
elif [[ $TOTAL_MEM -lt 16 ]]; then
    POSTGRES_MEM="1g"
    RABBITMQ_MEM="1g"
    BACKEND_MEM="2g"
else
    POSTGRES_MEM="2g"
    RABBITMQ_MEM="1g"
    BACKEND_MEM="3g"
fi

# 优化Docker配置
cat > docker-compose.mac.yml << EOF
version: '3.8'

# macOS优化配置
services:
  postgres:
    platform: ${PLATFORM}
    mem_limit: ${POSTGRES_MEM}
    cpus: 1.5
    environment:
      - POSTGRES_SHARED_PRELOAD_LIBRARIES=vector
      - POSTGRES_WORK_MEM=64MB
      - POSTGRES_MAINTENANCE_WORK_MEM=256MB
    volumes:
      - postgres-data:/var/lib/postgresql/data:delegated
    
  rabbitmq:
    platform: ${PLATFORM}
    mem_limit: ${RABBITMQ_MEM}
    cpus: 0.5
    environment:
      - RABBITMQ_VM_MEMORY_HIGH_WATERMARK=0.6
    
  imagentx-backend:
    platform: ${PLATFORM}
    mem_limit: ${BACKEND_MEM}
    cpus: 2
    environment:
      - JAVA_OPTS=${JVM_OPTS}
      - SPRING_PROFILES_ACTIVE=dev
    volumes:
      - storage-data:/app/storage:delegated
      - ./logs:/app/logs:delegated
    ports:
      - "${BACKEND_PORT:-8088}:8088"
      - "${DEBUG_PORT:-5005}:5005"
    
  imagentx-frontend:
    platform: ${PLATFORM}
    mem_limit: 1g
    cpus: 1
    environment:
      - NODE_ENV=development
      - NEXT_TELEMETRY_DISABLED=1

volumes:
  postgres-data:
    driver: local
  storage-data:
    driver: local
EOF

# 创建macOS专用环境配置
cat > .env.mac << EOF
# macOS专用环境配置

# 端口配置（避免冲突）
BACKEND_PORT=${BACKEND_PORT:-8088}
FRONTEND_PORT=${FRONTEND_PORT:-3000}
POSTGRES_PORT=${POSTGRES_PORT:-5432}
RABBITMQ_PORT=${RABBITMQ_PORT:-5672}
RABBITMQ_MANAGEMENT_PORT=${RABBITMQ_MANAGEMENT_PORT:-15672}
DEBUG_PORT=${DEBUG_PORT:-5005}

# 资源限制
POSTGRES_MEM=${POSTGRES_MEM}
RABBITMQ_MEM=${RABBITMQ_MEM}
BACKEND_MEM=${BACKEND_MEM}

# JVM优化
JAVA_OPTS="${JVM_OPTS}"

# macOS特定路径
FILE_STORAGE_PATH=/app/storage
LOG_PATH=/app/logs

# 开发工具
ADMINER_PORT=${ADMINER_PORT:-8082}

# 网络配置
DOCKER_NETWORK_NAME=imagentx-mac
EOF

# 创建端口检测和自动分配脚本
cat > detect-ports.sh << 'EOF'
#!/bin/bash

# 端口检测和自动分配
get_free_port() {
    local start_port=$1
    local end_port=$2
    
    for ((port=start_port; port<=end_port; port++)); do
        if ! lsof -i :$port >/dev/null 2>&1; then
            echo $port
            return 0
        fi
    done
    
    echo -1
    return 1
}

# 检测并分配端口
BACKEND_PORT=$(get_free_port 8088 8098)
FRONTEND_PORT=$(get_free_port 3000 3010)
POSTGRES_PORT=$(get_free_port 5432 5442)
RABBITMQ_PORT=$(get_free_port 5672 5682)
RABBITMQ_MANAGEMENT_PORT=$(get_free_port 15672 15682)
DEBUG_PORT=$(get_free_port 5005 5015)
ADMINER_PORT=$(get_free_port 8082 8092)

echo "自动分配的端口:"
echo "后端端口: $BACKEND_PORT"
echo "前端端口: $FRONTEND_PORT"
echo "数据库端口: $POSTGRES_PORT"
echo "RabbitMQ端口: $RABBITMQ_PORT"
echo "RabbitMQ管理端口: $RABBITMQ_MANAGEMENT_PORT"
echo "调试端口: $DEBUG_PORT"
echo "Adminer端口: $ADMINER_PORT"

# 写入环境文件
cat >> .env.mac << EOL
BACKEND_PORT=$BACKEND_PORT
FRONTEND_PORT=$FRONTEND_PORT
POSTGRES_PORT=$POSTGRES_PORT
RABBITMQ_PORT=$RABBITMQ_PORT
RABBITMQ_MANAGEMENT_PORT=$RABBITMQ_MANAGEMENT_PORT
DEBUG_PORT=$DEBUG_PORT
ADMINER_PORT=$ADMINER_PORT
EOL
EOF

chmod +x detect-ports.sh

# 创建macOS开发工具脚本
cat > dev-tools.sh << 'EOF'
#!/bin/bash

# macOS开发工具脚本

# 函数：显示服务状态
show_status() {
    echo "=== Imagent X 服务状态 ==="
    docker-compose -f docker-compose.mac.yml ps
    
    echo ""
    echo "=== 端口使用情况 ==="
    netstat -an | grep -E ":(3000|8088|5432|5672|15672)" | head -10
    
    echo ""
    echo "=== 系统资源 ==="
    top -l 1 | head -10
}

# 函数：清理Docker资源
cleanup() {
    echo "清理Docker资源..."
    docker system prune -f
    docker volume prune -f
}

# 函数：查看实时日志
logs() {
    local service=$1
    if [ -z "$service" ]; then
        echo "使用方法: $0 logs [service]"
        echo "可用服务: postgres, rabbitmq, backend, frontend"
        return 1
    fi
    
    case $service in
        postgres)
            docker-compose -f docker-compose.mac.yml logs -f postgres
            ;;
        rabbitmq)
            docker-compose -f docker-compose.mac.yml logs -f rabbitmq
            ;;
        backend)
            docker-compose -f docker-compose.mac.yml logs -f imagentx-backend
            ;;
        frontend)
            docker-compose -f docker-compose.mac.yml logs -f imagentx-frontend
            ;;
        *)
            echo "未知服务: $service"
            ;;
    esac
}

# 函数：性能监控
monitor() {
    echo "启动性能监控..."
    while true; do
        clear
        echo "=== Imagent X 性能监控 ==="
        echo "时间: $(date)"
        echo ""
        
        echo "容器资源使用:"
        docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}"
        
        echo ""
        echo "系统资源:"
        top -l 1 | grep -E "(CPU usage|Load Avg)"
        
        sleep 5
    done
}

# 主命令处理
case "$1" in
    status)
        show_status
        ;;
    cleanup)
        cleanup
        ;;
    logs)
        logs $2
        ;;
    monitor)
        monitor
        ;;
    *)
        echo "macOS开发工具"
        echo "用法: $0 {status|cleanup|logs|monitor}"
        echo ""
        echo "命令:"
        echo "  status  - 显示服务状态"
        echo "  cleanup - 清理Docker资源"
        echo "  logs    - 查看实时日志"
        echo "  monitor - 性能监控"
        ;;
esac
EOF

chmod +x dev-tools.sh

# 创建一键启动脚本
cat > start-mac.sh << 'EOF'
#!/bin/bash

echo "🚀 启动Imagent X (macOS优化版)..."

# 检测端口
./detect-ports.sh

# 启动服务
docker-compose -f docker-compose.mac.yml --env-file .env.mac up -d

echo "✅ 服务启动完成！"
echo "访问地址:"
echo "  前端: http://localhost:$(grep FRONTEND_PORT .env.mac | cut -d'=' -f2)"
echo "  后端: http://localhost:$(grep BACKEND_PORT .env.mac | cut -d'=' -f2)/api"
echo "  Adminer: http://localhost:$(grep ADMINER_PORT .env.mac | cut -d'=' -f2)"
echo ""
echo "使用 ./dev-tools.sh 管理开发环境"
EOF

chmod +x start-mac.sh

echo -e "${GREEN}✅ macOS优化配置完成！${NC}"
echo ""
echo -e "${BLUE}使用方法:${NC}"
echo "1. 运行 ./detect-ports.sh 检测可用端口"
echo "2. 运行 ./start-mac.sh 启动优化后的服务"
echo "3. 运行 ./dev-tools.sh 管理开发环境"
echo ""
echo -e "${BLUE}优化特性:${NC}"
echo "- 自动检测Apple Silicon/Intel架构"
echo "- 动态端口分配避免冲突"
echo "- 内存限制保护系统资源"
echo "- 开发工具集成"
echo "- 性能监控工具"