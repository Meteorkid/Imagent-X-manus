#!/bin/bash

# 端口检测和自动分配
get_free_port() {
    local start_port=$1
    local end_port=$2
    
    for ((port=start_port; port<=end_port; port++)); do
        if ! lsof -i :$port >/dev/null 2>&1; then
            echo $port
            return 0
        fi
    done
    
    echo -1
    return 1
}

# 检测并分配端口
BACKEND_PORT=$(get_free_port 8088 8098)
FRONTEND_PORT=$(get_free_port 3000 3010)
POSTGRES_PORT=$(get_free_port 5432 5442)
RABBITMQ_PORT=$(get_free_port 5672 5682)
RABBITMQ_MANAGEMENT_PORT=$(get_free_port 15672 15682)
DEBUG_PORT=$(get_free_port 5005 5015)
ADMINER_PORT=$(get_free_port 8082 8092)

echo "自动分配的端口:"
echo "后端端口: $BACKEND_PORT"
echo "前端端口: $FRONTEND_PORT"
echo "数据库端口: $POSTGRES_PORT"
echo "RabbitMQ端口: $RABBITMQ_PORT"
echo "RabbitMQ管理端口: $RABBITMQ_MANAGEMENT_PORT"
echo "调试端口: $DEBUG_PORT"
echo "Adminer端口: $ADMINER_PORT"

# 写入环境文件
cat >> .env.mac << EOL
BACKEND_PORT=$BACKEND_PORT
FRONTEND_PORT=$FRONTEND_PORT
POSTGRES_PORT=$POSTGRES_PORT
RABBITMQ_PORT=$RABBITMQ_PORT
RABBITMQ_MANAGEMENT_PORT=$RABBITMQ_MANAGEMENT_PORT
DEBUG_PORT=$DEBUG_PORT
ADMINER_PORT=$ADMINER_PORT
EOL
