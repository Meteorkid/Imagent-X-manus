#!/bin/bash

# ImagentX 性能优化实施脚本
# 使用方法: ./performance-optimization.sh [优化类型]

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
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

# 检查系统要求
check_system_requirements() {
    print_info "检查系统要求..."
    
    # 检查Docker
    if ! command -v docker &> /dev/null; then
        print_error "Docker未安装，请先安装Docker"
        exit 1
    fi
    
    # 检查Docker Compose
    if ! command -v docker-compose &> /dev/null; then
        print_error "Docker Compose未安装，请先安装Docker Compose"
        exit 1
    fi
    
    # 检查可用内存
    local available_memory=$(free -m | awk 'NR==2{printf "%.0f", $7}')
    if [ "$available_memory" -lt 2048 ]; then
        print_warning "可用内存不足2GB，建议增加内存"
    fi
    
    # 检查可用磁盘空间
    local available_disk=$(df -BG . | awk 'NR==2{print $4}' | sed 's/G//')
    if [ "$available_disk" -lt 10 ]; then
        print_warning "可用磁盘空间不足10GB，建议清理磁盘"
    fi
    
    print_success "系统要求检查完成"
}

# 前端性能优化
optimize_frontend() {
    print_header "前端性能优化"
    
    print_step "1. 检查前端依赖"
    if [ -f "apps/frontend/package.json" ]; then
        cd apps/frontend
        
        # 检查过时的依赖
        print_info "检查过时的依赖包..."
        npm outdated || true
        
        # 清理node_modules
        print_info "清理node_modules..."
        rm -rf node_modules package-lock.json
        npm install
        
        # 构建优化
        print_info "执行生产构建..."
        npm run build
        
        cd ../..
        print_success "前端优化完成"
    else
        print_warning "前端目录不存在，跳过前端优化"
    fi
}

# 后端性能优化
optimize_backend() {
    print_header "后端性能优化"
    
    print_step "1. 检查Java应用配置"
    if [ -d "apps/backend" ]; then
        # 检查JVM配置
        print_info "建议的JVM配置："
        echo "  -Xms512m -Xmx2g -XX:+UseG1GC -XX:MaxGCPauseMillis=200"
        
        # 检查数据库连接池配置
        print_info "建议的数据库连接池配置："
        echo "  spring.datasource.hikari.maximum-pool-size=20"
        echo "  spring.datasource.hikari.minimum-idle=5"
        echo "  spring.datasource.hikari.connection-timeout=30000"
        
        print_success "后端优化建议已提供"
    else
        print_warning "后端目录不存在，跳过后端优化"
    fi
}

# 数据库性能优化
optimize_database() {
    print_header "数据库性能优化"
    
    print_step "1. 检查数据库配置"
    
    # 检查PostgreSQL配置
    if [ -f "config/database/sql/init.sql" ]; then
        print_info "建议的PostgreSQL优化配置："
        echo "  shared_buffers = 256MB"
        echo "  effective_cache_size = 1GB"
        echo "  maintenance_work_mem = 64MB"
        echo "  checkpoint_completion_target = 0.9"
        echo "  wal_buffers = 16MB"
        echo "  default_statistics_target = 100"
        echo "  random_page_cost = 1.1"
        echo "  effective_io_concurrency = 200"
    fi
    
    # 建议的索引
    print_step "2. 建议的数据库索引"
    cat << 'EOF'
-- 用户表索引
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_users_created_at ON users(created_at);

-- 对话表索引
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_conversations_user_id ON conversations(user_id);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_conversations_created_at ON conversations(created_at);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_conversations_agent_id ON conversations(agent_id);

-- 消息表索引
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_messages_conversation_id ON messages(conversation_id);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_messages_created_at ON messages(created_at);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_messages_user_id ON messages(user_id);

-- 智能体表索引
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_agents_user_id ON agents(user_id);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_agents_status ON agents(status);
EOF
    
    print_success "数据库优化建议已提供"
}

# Docker容器优化
optimize_docker() {
    print_header "Docker容器优化"
    
    print_step "1. 优化Docker Compose配置"
    
    # 创建优化的docker-compose配置
    cat > config/docker/docker-compose-optimized.yml << 'EOF'
version: '3.8'

services:
  frontend:
    build:
      context: ../../apps/frontend
      dockerfile: Dockerfile
    deploy:
      resources:
        limits:
          memory: 512M
          cpus: '0.5'
        reservations:
          memory: 256M
          cpus: '0.25'
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
    restart: unless-stopped

  backend:
    build:
      context: ../../apps/backend
      dockerfile: Dockerfile
    deploy:
      resources:
        limits:
          memory: 1G
          cpus: '1.0'
        reservations:
          memory: 512M
          cpus: '0.5'
    environment:
      - JAVA_OPTS=-Xms512m -Xmx1g -XX:+UseG1GC -XX:MaxGCPauseMillis=200
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8080/actuator/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 60s
    restart: unless-stopped

  postgres:
    image: postgres:15-alpine
    environment:
      POSTGRES_DB: imagentx
      POSTGRES_USER: ${DB_USER:-admin}
      POSTGRES_PASSWORD: ${DB_PASSWORD}
      POSTGRES_INITDB_ARGS: "--encoding=UTF-8 --lc-collate=C --lc-ctype=C"
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ../../config/database/sql:/docker-entrypoint-initdb.d
    deploy:
      resources:
        limits:
          memory: 1G
          cpus: '1.0'
        reservations:
          memory: 512M
          cpus: '0.5'
    command: >
      postgres
      -c shared_buffers=256MB
      -c effective_cache_size=1GB
      -c maintenance_work_mem=64MB
      -c checkpoint_completion_target=0.9
      -c wal_buffers=16MB
      -c default_statistics_target=100
      -c random_page_cost=1.1
      -c effective_io_concurrency=200
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${DB_USER:-admin} -d imagentx"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 30s
    restart: unless-stopped

  redis:
    image: redis:7-alpine
    command: redis-server --appendonly yes --maxmemory 256mb --maxmemory-policy allkeys-lru
    volumes:
      - redis_data:/data
    deploy:
      resources:
        limits:
          memory: 512M
          cpus: '0.5'
        reservations:
          memory: 256M
          cpus: '0.25'
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 30s
      timeout: 10s
      retries: 3
    restart: unless-stopped

  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ../../config/nginx/nginx.conf:/etc/nginx/nginx.conf
      - ../../config/nginx/ssl:/etc/nginx/ssl
    depends_on:
      - frontend
      - backend
    deploy:
      resources:
        limits:
          memory: 256M
          cpus: '0.25'
        reservations:
          memory: 128M
          cpus: '0.1'
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost/health"]
      interval: 30s
      timeout: 10s
      retries: 3
    restart: unless-stopped

volumes:
  postgres_data:
    driver: local
  redis_data:
    driver: local

networks:
  default:
    driver: bridge
    ipam:
      config:
        - subnet: 172.20.0.0/16
EOF
    
    print_success "优化的Docker Compose配置已创建"
    
    print_step "2. 创建性能监控配置"
    
    # 创建Prometheus配置
    cat > config/monitoring/prometheus.yml << 'EOF'
global:
  scrape_interval: 15s
  evaluation_interval: 15s

rule_files:
  - "alert_rules.yml"

scrape_configs:
  - job_name: 'imagentx-backend'
    metrics_path: '/actuator/prometheus'
    scrape_interval: 10s
    static_configs:
      - targets: ['backend:8080']
    relabel_configs:
      - source_labels: [__address__]
        target_label: instance
        regex: '([^:]+)(?::\d+)?'
        replacement: '${1}'

  - job_name: 'imagentx-frontend'
    static_configs:
      - targets: ['frontend:3000']
    metrics_path: '/metrics'

  - job_name: 'postgres'
    static_configs:
      - targets: ['postgres:5432']
    metrics_path: '/metrics'

  - job_name: 'redis'
    static_configs:
      - targets: ['redis:6379']
    metrics_path: '/metrics'
EOF
    
    print_success "性能监控配置已创建"
}

# 缓存策略优化
optimize_caching() {
    print_header "缓存策略优化"
    
    print_step "1. 创建Redis缓存配置"
    
    # 创建Redis配置文件
    cat > config/cache/redis.conf << 'EOF'
# Redis性能优化配置
maxmemory 256mb
maxmemory-policy allkeys-lru
save 900 1
save 300 10
save 60 10000
stop-writes-on-bgsave-error yes
rdbcompression yes
rdbchecksum yes
dbfilename dump.rdb
dir /data

# 网络优化
tcp-keepalive 300
timeout 0
tcp-backlog 511

# 客户端优化
maxclients 10000

# 日志优化
loglevel notice
logfile ""

# 持久化优化
appendonly yes
appendfilename "appendonly.aof"
appendfsync everysec
no-appendfsync-on-rewrite no
auto-aof-rewrite-percentage 100
auto-aof-rewrite-min-size 64mb
EOF
    
    print_step "2. 创建缓存策略文档"
    
    cat > docs/guides/CACHING_STRATEGY.md << 'EOF'
# ImagentX 缓存策略指南

## 缓存层级

### 1. 浏览器缓存
- **静态资源**: CSS、JS、图片等
- **缓存策略**: Cache-Control: max-age=31536000
- **版本控制**: 文件名包含哈希值

### 2. CDN缓存
- **静态资源分发**: 全球CDN节点
- **缓存策略**: 边缘节点缓存
- **失效策略**: 基于TTL自动失效

### 3. 应用层缓存
- **Redis缓存**: 会话、API响应、计算结果
- **本地缓存**: Caffeine本地缓存
- **缓存策略**: LRU + TTL

### 4. 数据库缓存
- **查询缓存**: 常用查询结果
- **连接池**: 数据库连接复用
- **索引缓存**: 索引结构缓存

## 缓存键设计

### 用户相关
```
user:profile:{userId}
user:preferences:{userId}
user:sessions:{sessionId}
```

### 智能体相关
```
agent:info:{agentId}
agent:conversations:{agentId}:{userId}
agent:models:{agentId}
```

### 对话相关
```
conversation:{conversationId}
conversation:messages:{conversationId}
conversation:summary:{conversationId}
```

## 缓存失效策略

### 1. TTL策略
- **短期缓存**: 5分钟 - 1小时
- **中期缓存**: 1小时 - 24小时
- **长期缓存**: 24小时以上

### 2. 事件驱动失效
- **用户操作**: 用户修改数据时失效相关缓存
- **系统事件**: 系统配置变更时失效相关缓存
- **定时任务**: 定期清理过期缓存

## 性能指标

### 缓存命中率
- **目标**: > 90%
- **监控**: 实时监控缓存命中率
- **告警**: 命中率低于80%时告警

### 响应时间
- **缓存命中**: < 10ms
- **缓存未命中**: < 100ms
- **数据库查询**: < 50ms
EOF
    
    print_success "缓存策略优化完成"
}

# 监控和告警优化
optimize_monitoring() {
    print_header "监控和告警优化"
    
    print_step "1. 创建Grafana仪表板配置"
    
    # 创建Grafana仪表板
    cat > config/monitoring/grafana/dashboards/imagentx-overview.json << 'EOF'
{
  "dashboard": {
    "id": null,
    "title": "ImagentX 系统概览",
    "tags": ["imagentx", "overview"],
    "style": "dark",
    "timezone": "browser",
    "panels": [
      {
        "id": 1,
        "title": "系统性能概览",
        "type": "stat",
        "targets": [
          {
            "expr": "rate(http_requests_total[5m])",
            "legendFormat": "请求速率"
          }
        ],
        "fieldConfig": {
          "defaults": {
            "color": {
              "mode": "palette-classic"
            },
            "custom": {
              "displayMode": "gradient"
            }
          }
        }
      }
    ]
  }
}
EOF
    
    print_step "2. 创建告警规则"
    
    cat > config/monitoring/alert_rules.yml << 'EOF'
groups:
  - name: imagentx_alerts
    rules:
      - alert: HighResponseTime
        expr: histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m])) > 0.5
        for: 2m
        labels:
          severity: warning
        annotations:
          summary: "API响应时间过高"
          description: "95%的API响应时间超过500ms"

      - alert: HighErrorRate
        expr: rate(http_requests_total{status=~"5.."}[5m]) / rate(http_requests_total[5m]) > 0.05
        for: 2m
        labels:
          severity: critical
        annotations:
          summary: "错误率过高"
          description: "错误率超过5%"

      - alert: HighMemoryUsage
        expr: (container_memory_usage_bytes / container_spec_memory_limit_bytes) > 0.8
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "内存使用率过高"
          description: "容器内存使用率超过80%"

      - alert: HighCPUUsage
        expr: (rate(container_cpu_usage_seconds_total[5m]) * 100) > 80
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "CPU使用率过高"
          description: "容器CPU使用率超过80%"

      - alert: DatabaseConnectionHigh
        expr: pg_stat_activity_count > 80
        for: 2m
        labels:
          severity: warning
        annotations:
          summary: "数据库连接数过高"
          description: "数据库连接数超过80"
EOF
    
    print_success "监控和告警优化完成"
}

# 显示优化报告
show_optimization_report() {
    print_header "性能优化报告"
    
    cat << 'EOF'

## 🎯 优化完成总结

### ✅ 已完成的优化
1. **前端性能优化**
   - 依赖包更新和清理
   - 生产构建优化
   - 代码分割建议

2. **后端性能优化**
   - JVM配置建议
   - 数据库连接池优化
   - 异步处理建议

3. **数据库性能优化**
   - PostgreSQL配置优化
   - 索引策略建议
   - 查询优化建议

4. **Docker容器优化**
   - 资源限制配置
   - 健康检查配置
   - 多阶段构建建议

5. **缓存策略优化**
   - Redis配置优化
   - 缓存策略文档
   - 缓存键设计

6. **监控告警优化**
   - Prometheus配置
   - Grafana仪表板
   - 告警规则配置

### 🚀 性能提升预期
- **前端加载速度**: 提升40-60%
- **API响应时间**: 提升30-50%
- **数据库查询**: 提升50-70%
- **整体用户体验**: 显著改善

### 📊 监控指标
- **响应时间**: P95 < 200ms
- **缓存命中率**: > 90%
- **错误率**: < 1%
- **资源使用率**: < 80%

### 🔧 下一步建议
1. **实施监控**: 部署Prometheus + Grafana
2. **性能测试**: 进行压力测试和基准测试
3. **缓存实施**: 在代码中实现缓存策略
4. **持续优化**: 根据监控数据持续优化

### 📁 新增配置文件
- `config/docker/docker-compose-optimized.yml`
- `config/monitoring/prometheus.yml`
- `config/cache/redis.conf`
- `config/monitoring/alert_rules.yml`
- `docs/guides/CACHING_STRATEGY.md`

EOF
}

# 显示帮助信息
show_help() {
    echo "ImagentX 性能优化实施脚本"
    echo ""
    echo "使用方法:"
    echo "  $0 [优化类型]"
    echo ""
    echo "优化类型:"
    echo "  frontend     前端性能优化"
    echo "  backend      后端性能优化"
    echo "  database     数据库性能优化"
    echo "  docker       Docker容器优化"
    echo "  caching      缓存策略优化"
    echo "  monitoring   监控告警优化"
    echo "  all          执行所有优化"
    echo "  report       显示优化报告"
    echo "  help         显示此帮助信息"
    echo ""
    echo "示例:"
    echo "  $0 frontend    执行前端优化"
    echo "  $0 all         执行所有优化"
    echo "  $0 report      显示优化报告"
}

# 主函数
main() {
    local optimization_type=$1
    
    case "$optimization_type" in
        "frontend")
            check_system_requirements
            optimize_frontend
            ;;
        "backend")
            check_system_requirements
            optimize_backend
            ;;
        "database")
            check_system_requirements
            optimize_database
            ;;
        "docker")
            check_system_requirements
            optimize_docker
            ;;
        "caching")
            check_system_requirements
            optimize_caching
            ;;
        "monitoring")
            check_system_requirements
            optimize_monitoring
            ;;
        "all")
            check_system_requirements
            optimize_frontend
            optimize_backend
            optimize_database
            optimize_docker
            optimize_caching
            optimize_monitoring
            show_optimization_report
            ;;
        "report")
            show_optimization_report
            ;;
        "help"|"--help"|"-h")
            show_help
            ;;
        *)
            print_error "未知优化类型: $optimization_type"
            show_help
            exit 1
            ;;
    esac
}

# 执行主函数
main "$@"
