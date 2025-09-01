#!/bin/bash

# 日志监控脚本

LOG_DIR="logs"
if [ ! -d "$LOG_DIR" ]; then
    echo "日志目录不存在: $LOG_DIR"
    exit 1
fi

echo "=== Imagent X 日志监控 ==="
echo "时间: $(date)"
echo ""

# 显示最新的错误日志
echo "🚨 最新错误日志:"
find "$LOG_DIR" -name "*.log" -type f -exec grep -l "ERROR\|Exception\|Failed" {} \; | head -5 | while read logfile; do
    echo "文件: $logfile"
    tail -10 "$logfile" | grep -E "(ERROR|Exception|Failed)" | tail -3
    echo ""
done

# 显示最新的访问日志
echo "📝 最新访问日志:"
find "$LOG_DIR" -name "*.log" -type f -exec grep -l "GET\|POST\|PUT\|DELETE" {} \; | head -3 | while read logfile; do
    echo "文件: $logfile"
    tail -5 "$logfile" | grep -E "(GET|POST|PUT|DELETE)" | tail -3
    echo ""
done
