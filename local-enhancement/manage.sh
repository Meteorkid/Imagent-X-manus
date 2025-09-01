#!/bin/bash

# ImagentX本地增强管理脚本

case "$1" in
    monitor)
        echo "启动实时监控..."
        watch -n 5 ./monitoring/monitor.sh
        ;;
    logs)
        echo "启动日志监控..."
        watch -n 10 ./monitoring/log-monitor.sh
        ;;
    cache-test)
        echo "运行缓存测试..."
        cd cache && python3 test-cache.py
        ;;
    performance)
        echo "运行性能测试..."
        cd performance && python3 api-benchmark.py
        ;;
    status)
        echo "=== ImagentX 服务状态 ==="
        ./monitoring/monitor.sh
        ;;
    help)
        echo "ImagentX本地增强管理工具"
        echo ""
        echo "用法: $0 {monitor|logs|cache-test|performance|status|help}"
        echo ""
        echo "命令:"
        echo "  monitor     - 启动实时监控"
        echo "  logs        - 启动日志监控"
        echo "  cache-test  - 运行缓存测试"
        echo "  performance - 运行性能测试"
        echo "  status      - 查看服务状态"
        echo "  help        - 显示帮助信息"
        ;;
    *)
        echo "用法: $0 {monitor|logs|cache-test|performance|status|help}"
        exit 1
        ;;
esac
