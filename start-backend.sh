#!/bin/bash

# ImagentX 后端启动脚本
# 解决Java版本兼容性问题

set -e

echo "🚀 启动 ImagentX 后端服务..."

# 设置Java环境
export JAVA_HOME=/opt/homebrew/opt/openjdk@17
export PATH=$JAVA_HOME/bin:$PATH

echo "📋 Java版本信息:"
java -version

# 检查后端目录
BACKEND_DIR="apps/backend"
if [ ! -d "$BACKEND_DIR" ]; then
    echo "❌ 错误: 后端目录不存在: $BACKEND_DIR"
    exit 1
fi

cd "$BACKEND_DIR"

# 检查Maven wrapper
if [ ! -f "mvnw" ]; then
    echo "❌ 错误: Maven wrapper不存在"
    exit 1
fi

# 给Maven wrapper添加执行权限
chmod +x mvnw

echo "🔧 编译项目..."
./mvnw clean compile

echo "📦 打包项目..."
./mvnw package -DskipTests

echo "🎯 启动Spring Boot应用..."
./mvnw spring-boot:run

echo "✅ 后端服务启动完成！"
echo "🌐 访问地址: http://localhost:8088"
echo "🔍 健康检查: http://localhost:8088/api/health"







