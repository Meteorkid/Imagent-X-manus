#!/bin/bash

# Imagent X Docker修复脚本 - macOS专用
# 用于解决Docker API 500错误和启动问题

set -e

echo "🍎 Imagent X Docker修复工具"
echo "================================"
echo "检测并修复macOS Docker问题..."
echo ""

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 检测函数
check_docker() {
    echo "🔍 检测Docker状态..."
    
    if ! command -v docker &> /dev/null; then
        echo -e "${RED}❌ Docker未安装${NC}"
        exit 1
    fi
    
    # 检查Docker守护进程
    if docker info &> /dev/null; then
        echo -e "${GREEN}✅ Docker守护进程运行正常${NC}"
        return 0
    else
        echo -e "${YELLOW}⚠️  Docker守护进程异常${NC}"
        return 1
    fi
}

# 修复Docker Desktop
fix_docker_desktop() {
    echo ""
    echo "🛠️  修复Docker Desktop..."
    
    # 检查Docker Desktop是否在运行
    if pgrep "Docker Desktop" > /dev/null; then
        echo "正在重启Docker Desktop..."
        killall "Docker Desktop" 2>/dev/null || true
        sleep 5
    fi
    
    # 启动Docker Desktop
    echo "启动Docker Desktop..."
    open -a "Docker Desktop"
    
    # 等待Docker完全启动
    echo "等待Docker启动完成..."
    for i in {1..30}; do
        if docker info &> /dev/null; then
            echo -e "${GREEN}✅ Docker Desktop已启动${NC}"
            return 0
        fi
        echo -n "."
        sleep 2
    done
    
    echo -e "${RED}❌ Docker Desktop启动超时${NC}"
    return 1
}

# 清理Docker状态
cleanup_docker() {
    echo ""
    echo "🧹 清理Docker状态..."
    
    # 停止所有容器
    echo "停止所有运行中的容器..."
    docker stop $(docker ps -q) 2>/dev/null || true
    
    # 清理网络
    echo "清理Docker网络..."
    docker network prune -f 2>/dev/null || true
    
    # 重置Docker配置
    echo "重置Docker配置..."
    rm -rf ~/.docker/config.json 2>/dev/null || true
    
    echo -e "${GREEN}✅ 清理完成${NC}"
}

# 验证修复
verify_fix() {
    echo ""
    echo "✅ 验证修复结果..."
    
    # 测试Docker命令
    if docker run --rm hello-world &> /dev/null; then
        echo -e "${GREEN}✅ Docker运行正常${NC}"
    else
        echo -e "${RED}❌ Docker仍然异常${NC}"
        return 1
    fi
    
    # 显示Docker信息
    echo "Docker信息:"
    docker --version
    docker system df
    
    return 0
}

# 端口检测
check_ports() {
    echo ""
    echo "🔍 检测端口占用..."
    
    ports=(3000 8080 8088 5432 5672 15672)
    
    for port in "${ports[@]}"; do
        if lsof -i :$port &> /dev/null; then
            pid=$(lsof -ti:$port)
            name=$(ps -p $pid -o comm= 2>/dev/null || echo "未知进程")
            echo -e "${YELLOW}⚠️  端口 $port 被占用 (PID: $pid, $name)${NC}"
        else
            echo -e "${GREEN}✅ 端口 $port 可用${NC}"
        fi
    done
}

# 主流程
main() {
    echo "开始检测和修复..."
    echo ""
    
    # 检查Docker
    if check_docker; then
        echo -e "${GREEN}Docker状态良好，无需修复${NC}"
    else
        # 修复Docker
        if fix_docker_desktop; then
            echo -e "${GREEN}Docker修复成功${NC}"
        else
            echo -e "${RED}Docker修复失败，请手动重启Docker Desktop${NC}"
            exit 1
        fi
    fi
    
    # 清理和验证
    cleanup_docker
    check_ports
    
    if verify_fix; then
        echo ""
        echo -e "${GREEN}🎉 所有修复完成！可以启动Imagent X项目了${NC}"
        echo ""
        echo "启动命令:"
        echo "  快速启动: ./start-mac.sh"
        echo "  标准启动: docker-compose -f docker-compose.mac.yml up -d"
        echo "  开发模式: ./dev-tools.sh"
    else
        echo -e "${RED}❌ 修复未完成，请查看日志${NC}"
        exit 1
    fi
}

# 执行主程序
main "$@"