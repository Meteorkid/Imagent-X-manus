#!/bin/bash

# OpenManus 安装和配置脚本
# 用于 ImagentX 项目集成

set -e

echo "🚀 开始安装 OpenManus..."

# 检查 Python 版本
python_version=$(python3 --version 2>&1 | grep -oE '[0-9]+\.[0-9]+' | head -1)
required_version="3.12"

if [ "$(printf '%s\n' "$required_version" "$python_version" | sort -V | head -n1)" != "$required_version" ]; then
    echo "❌ Python 版本过低，需要 Python 3.12 或更高版本，当前版本: $python_version"
    exit 1
fi

echo "✅ Python 版本检查通过: $python_version"

# 检查 OpenManus 目录
if [ ! -d "OpenManus" ]; then
    echo "❌ OpenManus 目录不存在"
    exit 1
fi

echo "✅ OpenManus 目录存在"

# 进入 OpenManus 目录
cd OpenManus

# 检查虚拟环境
if [ ! -d ".venv" ]; then
    echo "📦 创建虚拟环境..."
    python3 -m venv .venv
fi

# 激活虚拟环境
echo "🔧 激活虚拟环境..."
source .venv/bin/activate

# 升级 pip
echo "⬆️ 升级 pip..."
pip install --upgrade pip

# 安装依赖
echo "📦 安装依赖..."
if [ -f "requirements.txt" ]; then
    pip install -r requirements.txt
else
    echo "❌ requirements.txt 文件不存在"
    exit 1
fi

# 安装浏览器自动化工具（可选）
echo "🌐 安装浏览器自动化工具..."
playwright install 2>/dev/null || echo "⚠️ Playwright 安装失败，跳过"

# 检查配置文件
if [ ! -f "config/config.toml" ]; then
    echo "📝 创建配置文件..."
    cp config/config.example.toml config/config.toml
    echo "⚠️ 请编辑 config/config.toml 文件，配置您的 API 密钥"
fi

# 测试安装
echo "🧪 测试安装..."
python -c "import sys; print('✅ Python 环境正常')" || {
    echo "❌ Python 环境测试失败"
    exit 1
}

# 返回项目根目录
cd ..

echo "✅ OpenManus 安装完成！"
echo ""
echo "📋 下一步操作："
echo "1. 编辑 OpenManus/config/config.toml 文件，配置您的 API 密钥"
echo "2. 启动 ImagentX 项目"
echo "3. 访问 /agents 页面使用智能体功能"
echo ""
echo "🔧 常用命令："
echo "- 激活环境: cd OpenManus && source .venv/bin/activate"
echo "- 运行测试: python main.py"
echo "- 运行 MCP: python run_mcp.py"

