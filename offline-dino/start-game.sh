#!/bin/bash

echo "🎮 启动离线小游戏服务器..."
echo "=================================="

# 检查Python3是否可用
if command -v python3 &> /dev/null; then
    echo "✅ 使用 Python3 启动服务器"
    echo "🌐 服务器地址: http://localhost:8080"
    echo "🎯 主要游戏页面: http://localhost:8080/fixed-optimized-game.html"
    echo "🧪 功能测试页面: http://localhost:8080/test-game-functionality.html"
    echo "=================================="
    echo "按 Ctrl+C 停止服务器"
    echo ""
    
    cd "$(dirname "$0")"
    python3 -m http.server 8080
    
elif command -v python &> /dev/null; then
    echo "✅ 使用 Python 启动服务器"
    echo "🌐 服务器地址: http://localhost:8080"
    echo "🎯 主要游戏页面: http://localhost:8080/fixed-optimized-game.html"
    echo "🧪 功能测试页面: http://localhost:8080/test-game-functionality.html"
    echo "=================================="
    echo "按 Ctrl+C 停止服务器"
    echo ""
    
    cd "$(dirname "$0")"
    python -m http.server 8080
    
elif command -v node &> /dev/null; then
    echo "✅ 使用 Node.js 启动服务器"
    echo "🌐 服务器地址: http://localhost:8080"
    echo "🎯 主要游戏页面: http://localhost:8080/fixed-optimized-game.html"
    echo "🧪 功能测试页面: http://localhost:8080/test-game-functionality.html"
    echo "=================================="
    echo "按 Ctrl+C 停止服务器"
    echo ""
    
    cd "$(dirname "$0")"
    npx http-server -p 8080
    
else
    echo "❌ 错误: 未找到 Python 或 Node.js"
    echo "请安装以下任一环境:"
    echo "  - Python3: https://www.python.org/downloads/"
    echo "  - Node.js: https://nodejs.org/"
    echo ""
    echo "或者手动启动服务器:"
    echo "  cd offline-dino"
    echo "  python3 -m http.server 8080"
    exit 1
fi







