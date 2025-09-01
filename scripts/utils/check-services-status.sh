#!/bin/bash

# 服务状态检测脚本
echo "🔍 ImagentX 服务状态检测"
echo "========================"

# 检查后端
if curl -s "http://localhost:8080/actuator/health" >/dev/null; then
    echo "✅ 后端服务: 运行中"
else
    echo "❌ 后端服务: 未运行"
fi

# 检查前端
if curl -s "http://localhost:3000" >/dev/null; then
    echo "✅ 前端服务: 运行中"
else
    echo "❌ 前端服务: 未运行"
fi

echo ""
echo "📊 进程信息:"
ps aux | grep -E "(java|node)" | grep -v grep

echo ""
echo "🌐 访问地址:"
echo "前端应用: http://localhost:3000"
echo "后端API:  http://localhost:8080"
