#!/bin/bash

# ImagentX 缓存系统设置脚本
# 用于快速部署Redis缓存系统

set -e

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # 无颜色

echo -e "${BLUE}🚀 设置ImagentX缓存系统...${NC}"

# 检查Docker服务
check_docker() {
    if ! docker info >/dev/null 2>&1; then
        echo -e "${RED}❌ Docker服务未运行，请先启动Docker${NC}"
        exit 1
    fi
    echo -e "${GREEN}✅ Docker服务正常运行${NC}"
}

# 创建缓存配置目录
create_directories() {
    echo -e "${BLUE}📁 创建缓存配置目录...${NC}"
    mkdir -p cache/{redis,redis-commander}
    mkdir -p cache/redis/{data,conf}
}

# 创建Redis配置
create_redis_config() {
    echo -e "${BLUE}⚙️  创建Redis配置...${NC}"
    
    cat > cache/redis/conf/redis.conf << 'EOF'
# Redis配置文件
bind 0.0.0.0
port 6379
timeout 0
tcp-keepalive 300
daemonize no
supervised no
pidfile /var/run/redis_6379.pid
loglevel notice
logfile ""
databases 16
save 900 1
save 300 10
save 60 10000
stop-writes-on-bgsave-error yes
rdbcompression yes
rdbchecksum yes
dbfilename dump.rdb
dir /data
maxmemory 256mb
maxmemory-policy allkeys-lru
appendonly yes
appendfilename "appendonly.aof"
appendfsync everysec
no-appendfsync-on-rewrite no
auto-aof-rewrite-percentage 100
auto-aof-rewrite-min-size 64mb
aof-load-truncated yes
aof-use-rdb-preamble yes
EOF
}

# 创建Docker Compose文件
create_docker_compose() {
    echo -e "${BLUE}🐳 创建缓存Docker Compose配置...${NC}"
    
    cat > cache/docker-compose.cache.yml << 'EOF'
version: '3.8'

services:
  redis:
    image: redis:7-alpine
    container_name: imagentx-redis
    ports:
      - "6379:6379"
    volumes:
      - ./redis/conf/redis.conf:/usr/local/etc/redis/redis.conf
      - ./redis/data:/data
    command: redis-server /usr/local/etc/redis/redis.conf
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 30s
      timeout: 10s
      retries: 3

  redis-commander:
    image: rediscommander/redis-commander:latest
    container_name: imagentx-redis-commander
    ports:
      - "8081:8081"
    environment:
      - REDIS_HOSTS=local:redis:6379
    depends_on:
      - redis
    restart: unless-stopped
EOF
}

# 创建Spring Boot缓存配置
create_spring_cache_config() {
    echo -e "${BLUE}☕ 创建Spring Boot缓存配置...${NC}"
    
    cat > cache/application-cache.yml << 'EOF'
# Spring Boot缓存配置
spring:
  cache:
    type: redis
    redis:
      time-to-live: 600000 # 10分钟
      cache-null-values: true
      use-key-prefix: true
      key-prefix: "imagentx:"
  
  redis:
    host: localhost
    port: 6379
    database: 0
    timeout: 2000ms
    lettuce:
      pool:
        max-active: 8
        max-idle: 8
        min-idle: 0
        max-wait: -1ms

# 缓存配置
cache:
  # 用户会话缓存
  session:
    ttl: 3600000 # 1小时
    max-size: 1000
  
  # 配置信息缓存
  config:
    ttl: 1800000 # 30分钟
    max-size: 100
  
  # 查询结果缓存
  query:
    ttl: 300000 # 5分钟
    max-size: 500
  
  # 工具信息缓存
  tool:
    ttl: 900000 # 15分钟
    max-size: 200
  
  # RAG知识库缓存
  rag:
    ttl: 600000 # 10分钟
    max-size: 300
EOF
}

# 创建缓存管理脚本
create_cache_scripts() {
    echo -e "${BLUE}📜 创建缓存管理脚本...${NC}"
    
    cat > cache/manage.sh << 'EOF'
#!/bin/bash

# 缓存服务管理脚本

case "$1" in
    start)
        docker-compose -f docker-compose.cache.yml up -d
        echo "缓存服务已启动"
        ;;
    stop)
        docker-compose -f docker-compose.cache.yml down
        echo "缓存服务已停止"
        ;;
    restart)
        docker-compose -f docker-compose.cache.yml restart
        echo "缓存服务已重启"
        ;;
    status)
        docker-compose -f docker-compose.cache.yml ps
        ;;
    logs)
        docker-compose -f docker-compose.cache.yml logs -f
        ;;
    flush)
        echo "清空Redis缓存..."
        docker exec imagentx-redis redis-cli FLUSHALL
        echo "缓存已清空"
        ;;
    info)
        echo "Redis信息:"
        docker exec imagentx-redis redis-cli INFO
        ;;
    monitor)
        echo "监控Redis命令..."
        docker exec imagentx-redis redis-cli MONITOR
        ;;
    *)
        echo "用法: $0 {start|stop|restart|status|logs|flush|info|monitor}"
        exit 1
        ;;
esac
EOF

    chmod +x cache/manage.sh
}

# 创建缓存测试脚本
create_test_scripts() {
    echo -e "${BLUE}🧪 创建缓存测试脚本...${NC}"
    
    cat > cache/test-cache.py << 'EOF'
#!/usr/bin/env python3
"""
Redis缓存测试脚本
"""

import redis
import time
import json

def test_redis_connection():
    """测试Redis连接"""
    try:
        r = redis.Redis(host='localhost', port=6379, db=0, decode_responses=True)
        r.ping()
        print("✅ Redis连接成功")
        return r
    except Exception as e:
        print(f"❌ Redis连接失败: {e}")
        return None

def test_basic_operations(redis_client):
    """测试基本操作"""
    print("\n🔧 测试基本操作...")
    
    # 测试字符串操作
    redis_client.set('test:string', 'Hello Redis!')
    value = redis_client.get('test:string')
    print(f"字符串操作: {value}")
    
    # 测试哈希操作
    redis_client.hset('test:hash', 'name', 'ImagentX')
    redis_client.hset('test:hash', 'version', '1.0.0')
    hash_data = redis_client.hgetall('test:hash')
    print(f"哈希操作: {hash_data}")
    
    # 测试列表操作
    redis_client.lpush('test:list', 'item1', 'item2', 'item3')
    list_data = redis_client.lrange('test:list', 0, -1)
    print(f"列表操作: {list_data}")
    
    # 测试集合操作
    redis_client.sadd('test:set', 'member1', 'member2', 'member3')
    set_data = redis_client.smembers('test:set')
    print(f"集合操作: {set_data}")
    
    # 测试过期时间
    redis_client.setex('test:expire', 5, 'Will expire in 5 seconds')
    print(f"过期时间测试: {redis_client.get('test:expire')}")
    print("等待6秒...")
    time.sleep(6)
    print(f"过期后: {redis_client.get('test:expire')}")

def test_performance(redis_client):
    """测试性能"""
    print("\n⚡ 测试性能...")
    
    # 批量写入测试
    start_time = time.time()
    for i in range(1000):
        redis_client.set(f'perf:key:{i}', f'value:{i}')
    write_time = time.time() - start_time
    print(f"批量写入1000条记录耗时: {write_time:.3f}秒")
    
    # 批量读取测试
    start_time = time.time()
    for i in range(1000):
        redis_client.get(f'perf:key:{i}')
    read_time = time.time() - start_time
    print(f"批量读取1000条记录耗时: {read_time:.3f}秒")
    
    # 清理测试数据
    for i in range(1000):
        redis_client.delete(f'perf:key:{i}')

def test_cache_patterns(redis_client):
    """测试缓存模式"""
    print("\n🎯 测试缓存模式...")
    
    # 模拟用户会话缓存
    session_data = {
        'user_id': '12345',
        'username': 'testuser',
        'login_time': time.time(),
        'permissions': ['read', 'write', 'admin']
    }
    redis_client.setex('session:12345', 3600, json.dumps(session_data))
    print("✅ 用户会话缓存设置成功")
    
    # 模拟配置缓存
    config_data = {
        'max_agents': 10,
        'max_tools': 50,
        'rate_limit': 100
    }
    redis_client.setex('config:user:12345', 1800, json.dumps(config_data))
    print("✅ 用户配置缓存设置成功")
    
    # 模拟查询结果缓存
    query_result = {
        'agents': [
            {'id': '1', 'name': 'Agent1'},
            {'id': '2', 'name': 'Agent2'}
        ],
        'total': 2,
        'cached_at': time.time()
    }
    redis_client.setex('query:agents:user:12345', 300, json.dumps(query_result))
    print("✅ 查询结果缓存设置成功")

def main():
    """主函数"""
    print("🧪 Redis缓存测试开始...")
    
    # 测试连接
    redis_client = test_redis_connection()
    if not redis_client:
        return
    
    # 测试基本操作
    test_basic_operations(redis_client)
    
    # 测试性能
    test_performance(redis_client)
    
    # 测试缓存模式
    test_cache_patterns(redis_client)
    
    print("\n🎉 缓存测试完成！")
    print("📊 访问Redis Commander: http://localhost:8081")

if __name__ == "__main__":
    main()
EOF

    chmod +x cache/test-cache.py
}

# 启动缓存服务
start_cache() {
    echo -e "${BLUE}🚀 启动缓存服务...${NC}"
    cd cache
    docker-compose -f docker-compose.cache.yml up -d
    
    echo -e "${GREEN}✅ 缓存服务启动完成！${NC}"
    echo -e "${BLUE}📊 访问地址:${NC}"
    echo -e "  - Redis: localhost:6379"
    echo -e "  - Redis Commander: http://localhost:8081"
    echo -e ""
    echo -e "${YELLOW}📝 使用以下命令管理缓存服务:${NC}"
    echo -e "  cd cache"
    echo -e "  ./manage.sh {start|stop|restart|status|logs|flush|info|monitor}"
    echo -e ""
    echo -e "${YELLOW}🧪 运行缓存测试:${NC}"
    echo -e "  cd cache"
    echo -e "  python3 test-cache.py"
}

# 主函数
main() {
    echo -e "${BLUE}🔍 检查环境...${NC}"
    check_docker
    
    echo -e "${BLUE}📁 创建目录结构...${NC}"
    create_directories
    
    echo -e "${BLUE}⚙️  生成配置文件...${NC}"
    create_redis_config
    create_docker_compose
    create_spring_cache_config
    create_cache_scripts
    create_test_scripts
    
    echo -e "${BLUE}🚀 启动缓存服务...${NC}"
    start_cache
    
    echo -e "${GREEN}🎉 缓存系统设置完成！${NC}"
    echo -e "${YELLOW}📝 下一步操作:${NC}"
    echo -e "1. 将 application-cache.yml 配置集成到Spring Boot应用"
    echo -e "2. 添加Spring Boot Cache依赖"
    echo -e "3. 在代码中使用 @Cacheable 注解"
    echo -e "4. 运行测试脚本验证缓存功能"
}

# 执行主函数
main "$@"
