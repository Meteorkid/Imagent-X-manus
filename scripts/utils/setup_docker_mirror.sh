#!/bin/bash

# 停止Docker服务
echo "停止Docker服务..."
osascript -e 'quit app "Docker"'

# 等待Docker完全停止
sleep 5

# 复制配置文件到Docker配置目录
echo "配置Docker镜像源..."
mkdir -p ~/.docker
cp .docker/config.json ~/.docker/

# 启动Docker服务
echo "启动Docker服务..."
open -a Docker

# 等待Docker完全启动
echo "等待Docker启动完成..."
sleep 15

echo "Docker镜像源配置完成！"