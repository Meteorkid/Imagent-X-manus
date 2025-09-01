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
