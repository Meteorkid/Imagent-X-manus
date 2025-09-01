#!/bin/bash

# 简单的本地监控脚本

echo "=== Imagent X 本地监控 ==="
echo "时间: $(date)"
echo ""

# 检查服务状态
echo "🔍 服务状态检查:"
if curl -s http://localhost:8088/api/health >/dev/null 2>&1; then
    echo "✅ 后端服务: 正常"
else
    echo "❌ 后端服务: 异常"
fi

if curl -s http://localhost:3000 >/dev/null 2>&1; then
    echo "✅ 前端服务: 正常"
else
    echo "❌ 前端服务: 异常"
fi

# 检查端口占用
echo ""
echo "🌐 端口占用情况:"
lsof -i :8088 | head -3
lsof -i :3000 | head -3
lsof -i :5432 | head -3
lsof -i :5672 | head -3

# 检查进程状态
echo ""
echo "⚙️  进程状态:"
ps aux | grep -E "(java.*ImagentX|node.*next)" | grep -v grep

# 检查系统资源
echo ""
echo "💻 系统资源:"
top -l 1 | grep -E "(CPU usage|Load Avg|PhysMem)"
