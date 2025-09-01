#!/bin/bash
# ImagentX 快速登录脚本

# 自动打开登录页面
if command -v open >/dev/null 2>&1; then
    # macOS
    open http://localhost:3000/login
elif command -v xdg-open >/dev/null 2>&1; then
    # Linux
    xdg-open http://localhost:3000/login
elif command -v start >/dev/null 2>&1; then
    # Windows
    start http://localhost:3000/login
else
    echo "请手动访问: http://localhost:3000/login"
fi

echo "🔐 ImagentX 快速登录"
echo "===================="
echo "正在打开登录页面..."
echo ""
echo "📋 登录信息："
echo "  账号: admin@imagentx.top"
echo "  密码: admin123"
echo ""
echo "💡 提示："
echo "  - 登录成功后会自动跳转到主页面"
echo "  - 系统会记住您的登录状态"
echo "  - 如需退出，请点击右上角的用户菜单"
