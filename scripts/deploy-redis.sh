#!/bin/bash

# ImagentX Redis缓存部署脚本
# 使用方法: ./deploy-redis.sh [start|stop|status|restart|test]

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# 打印带颜色的消息
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_step() {
    echo -e "${PURPLE}[STEP]${NC} $1"
}

print_header() {
    echo -e "${CYAN}================================${NC}"
    echo -e "${CYAN}  $1${NC}"
    echo -e "${CYAN}================================${NC}"
}

# 检查Docker和Docker Compose
check_requirements() {
    print_info "检查系统要求..."
    
    if ! command -v docker &> /dev/null; then
        print_error "Docker未安装，请先安装Docker"
        exit 1
    fi
    
    if ! command -v docker-compose &> /dev/null; then
        print_error "Docker Compose未安装，请先安装Docker Compose"
        exit 1
    fi
    
    print_success "系统要求检查完成"
}

# 启动Redis服务
start_redis() {
    print_step "启动Redis缓存服务..."
    
    cd config/cache
    
    # 启动Redis服务
    docker-compose -f docker-compose.redis.yml up -d
    
    cd ../..
    
    print_success "Redis缓存服务启动完成"
    print_info "访问地址："
    print_info "  - Redis: localhost:6379"
    print_info "  - Redis Commander: http://localhost:8081"
}

# 停止Redis服务
stop_redis() {
    print_step "停止Redis缓存服务..."
    
    cd config/cache
    
    # 停止Redis服务
    docker-compose -f docker-compose.redis.yml down
    
    cd ../..
    
    print_success "Redis缓存服务已停止"
}

# 查看Redis服务状态
status_redis() {
    print_step "查看Redis缓存服务状态..."
    
    cd config/cache
    
    # 查看服务状态
    docker-compose -f docker-compose.redis.yml ps
    
    cd ../..
    
    print_info "Redis缓存服务状态查询完成"
}

# 重启Redis服务
restart_redis() {
    print_step "重启Redis缓存服务..."
    
    stop_redis
    sleep 2
    start_redis
    
    print_success "Redis缓存服务重启完成"
}

# 测试Redis连接
test_redis() {
    print_step "测试Redis连接..."
    
    # 等待Redis启动
    sleep 5
    
    # 测试Redis连接
    if docker exec imagentx-redis redis-cli ping | grep -q "PONG"; then
        print_success "Redis连接测试成功"
        
        # 测试基本操作
        print_info "测试基本Redis操作..."
        
        # 设置测试键
        docker exec imagentx-redis redis-cli set "test:key" "test_value"
        
        # 获取测试键
        local value=$(docker exec imagentx-redis redis-cli get "test:key")
        if [ "$value" = "test_value" ]; then
            print_success "Redis读写测试成功"
        else
            print_error "Redis读写测试失败"
        fi
        
        # 删除测试键
        docker exec imagentx-redis redis-cli del "test:key"
        
        # 显示Redis信息
        print_info "Redis服务器信息："
        docker exec imagentx-redis redis-cli info server | head -5
        
        # 显示内存使用
        print_info "Redis内存使用："
        docker exec imagentx-redis redis-cli info memory | grep -E "(used_memory|maxmemory)"
        
    else
        print_error "Redis连接测试失败"
        exit 1
    fi
}

# 性能测试
performance_test() {
    print_step "执行Redis性能测试..."
    
    # 安装redis-benchmark（如果不存在）
    if ! docker exec imagentx-redis which redis-benchmark > /dev/null 2>&1; then
        print_info "安装redis-benchmark..."
        docker exec imagentx-redis apk add --no-cache redis
    fi
    
    print_info "执行Redis基准测试..."
    
    # 基本性能测试
    docker exec imagentx-redis redis-benchmark -h localhost -p 6379 -n 1000 -c 10 -t set,get
    
    print_success "Redis性能测试完成"
}

# 监控Redis
monitor_redis() {
    print_step "监控Redis实时状态..."
    
    print_info "按 Ctrl+C 停止监控"
    
    # 实时监控Redis命令
    docker exec imagentx-redis redis-cli monitor
}

# 显示帮助信息
show_help() {
    echo "ImagentX Redis缓存部署脚本"
    echo ""
    echo "使用方法:"
    echo "  $0 [命令]"
    echo ""
    echo "命令:"
    echo "  start       启动Redis服务"
    echo "  stop        停止Redis服务"
    echo "  status      查看服务状态"
    echo "  restart     重启Redis服务"
    echo "  test        测试Redis连接"
    echo "  perf        性能测试"
    echo "  monitor     实时监控"
    echo "  help        显示此帮助信息"
    echo ""
    echo "示例:"
    echo "  $0 start     启动Redis服务"
    echo "  $0 test      测试Redis连接"
}

# 主函数
main() {
    local command=$1
    
    case "$command" in
        "start")
            check_requirements
            start_redis
            ;;
        "stop")
            stop_redis
            ;;
        "status")
            status_redis
            ;;
        "restart")
            restart_redis
            ;;
        "test")
            test_redis
            ;;
        "perf")
            performance_test
            ;;
        "monitor")
            monitor_redis
            ;;
        "help"|"--help"|"-h")
            show_help
            ;;
        *)
            print_error "未知命令: $command"
            show_help
            exit 1
            ;;
    esac
}

# 执行主函数
main "$@"
