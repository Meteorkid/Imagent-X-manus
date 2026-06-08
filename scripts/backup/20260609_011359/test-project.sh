#!/bin/bash

echo "🚀 Imagent X 项目运行状态检查"
echo "=================================="

# 检查服务状态
echo "📊 检查服务状态..."
echo "前端服务 (端口3000):"
if curl -s http://localhost:3000 > /dev/null; then
    echo "  ✅ 前端服务运行正常"
else
    echo "  ❌ 前端服务未运行"
fi

echo "后端服务 (端口8088):"
if curl -s http://localhost:8088/api/health > /dev/null; then
    echo "  ✅ 后端服务运行正常"
else
    echo "  ❌ 后端服务未运行"
fi

# 检查进程
echo ""
echo "🔍 检查进程状态..."
echo "前端进程:"
if pgrep -f "next dev" > /dev/null; then
    echo "  ✅ Next.js 开发服务器运行中"
else
    echo "  ❌ Next.js 开发服务器未运行"
fi

echo "后端进程:"
if pgrep -f "ImagentXApplication" > /dev/null; then
    echo "  ✅ Spring Boot 应用运行中"
else
    echo "  ❌ Spring Boot 应用未运行"
fi

# 测试API功能
echo ""
echo "🧪 测试API功能..."
echo "健康检查:"
HEALTH_RESPONSE=$(curl -s http://localhost:8088/api/health)
if [ $? -eq 0 ]; then
    echo "  ✅ 健康检查通过: $HEALTH_RESPONSE"
else
    echo "  ❌ 健康检查失败"
fi

# 显示访问信息
echo ""
echo "🌐 访问信息:"
echo "  前端界面: http://localhost:3000"
echo "  后端API: http://localhost:8088/api"
echo "  健康检查: http://localhost:8088/api/health"
echo ""
echo "📝 默认登录信息:"
echo "  管理员: admin@imagentx.ai / admin123"
echo "  测试用户: test@imagentx.ai / test123"
echo ""
echo "✨ 项目启动成功！"
