#!/bin/bash

# ImagentX 数据库性能优化部署脚本
# 用于快速部署数据库性能优化配置

set -e

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # 无颜色

echo -e "${BLUE}🚀 开始部署ImagentX数据库性能优化...${NC}"

# 检查必要工具
check_requirements() {
    echo -e "${BLUE}🔍 检查必要工具...${NC}"
    
    # 检查psql
    if ! command -v psql &> /dev/null; then
        echo -e "${RED}❌ PostgreSQL客户端未安装${NC}"
        exit 1
    fi
    
    # 检查docker
    if ! command -v docker &> /dev/null; then
        echo -e "${RED}❌ Docker未安装${NC}"
        exit 1
    fi
    
    # 检查jq
    if ! command -v jq &> /dev/null; then
        echo -e "${YELLOW}⚠️  jq未安装，将跳过JSON解析${NC}"
    fi
    
    echo -e "${GREEN}✅ 必要工具检查完成${NC}"
}

# 备份当前配置
backup_configuration() {
    echo -e "${BLUE}📦 备份当前配置...${NC}"
    
    # 创建备份目录
    mkdir -p backup/$(date +%Y%m%d_%H%M%S)
    BACKUP_DIR="backup/$(date +%Y%m%d_%H%M%S)"
    
    # 备份应用配置
    if [ -f "apps/backend/src/main/resources/application.yml" ]; then
        cp apps/backend/src/main/resources/application.yml "$BACKUP_DIR/application.yml.backup"
        echo -e "${GREEN}✅ 应用配置已备份到 $BACKUP_DIR${NC}"
    fi
    
    # 备份数据库配置
    if [ -f "config/docker/docker-compose.yml" ]; then
        cp config/docker/docker-compose.yml "$BACKUP_DIR/docker-compose.yml.backup"
        echo -e "${GREEN}✅ Docker配置已备份到 $BACKUP_DIR${NC}"
    fi
    
    echo -e "${GREEN}✅ 配置备份完成${NC}"
}

# 应用优化配置
apply_optimization_config() {
    echo -e "${BLUE}⚙️  应用优化配置...${NC}"
    
    # 创建性能配置目录
    mkdir -p performance-config/database
    
    # 创建优化的数据库连接池配置
    cat > performance-config/database/database-pool-optimized.yml << 'EOF'
spring:
  datasource:
    hikari:
      # 连接池优化配置
      pool-name: ImagentXHikariCP
      maximum-pool-size: 30  # 根据CPU核心数调整
      minimum-idle: 10
      connection-timeout: 20000  # 20秒
      idle-timeout: 300000  # 5分钟
      max-lifetime: 1200000  # 20分钟
      leak-detection-threshold: 60000  # 1分钟
      connection-test-query: SELECT 1
      validation-timeout: 5000  # 5秒
      register-mbeans: true
      
  # JPA配置优化
  jpa:
    properties:
      hibernate:
        # 批处理大小
        jdbc:
          batch_size: 50
          batch_versioned_data: true
        # 二级缓存配置
        cache:
          use_second_level_cache: true
          use_query_cache: true
        # 查询优化
        order_inserts: true
        order_updates: true
        # 统计信息
        generate_statistics: true
        # 慢查询日志
        session_factory:
          observer_class: org.hibernate.stat.Statistics
EOF
    
    echo -e "${GREEN}✅ 优化配置已创建${NC}"
}

# 创建性能索引
create_performance_indexes() {
    echo -e "${BLUE}🔍 创建性能索引...${NC}"
    
    # 创建索引优化脚本
    cat > performance-config/database/create-performance-indexes.sql << 'EOF'
-- ImagentX 数据库性能索引优化脚本

-- 用户表索引优化
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_username ON users(username);
CREATE INDEX IF NOT EXISTS idx_users_status ON users(status);
CREATE INDEX IF NOT EXISTS idx_users_created_at ON users(created_at);

-- Agent表索引优化
CREATE INDEX IF NOT EXISTS idx_agents_user_id ON agents(created_by);
CREATE INDEX IF NOT EXISTS idx_agents_status ON agents(status);
CREATE INDEX IF NOT EXISTS idx_agents_created_at ON agents(created_at);
CREATE INDEX IF NOT EXISTS idx_agents_model ON agents(model);

-- 会话表索引优化
CREATE INDEX IF NOT EXISTS idx_sessions_user_id ON sessions(user_id);
CREATE INDEX IF NOT EXISTS idx_sessions_agent_id ON sessions(agent_id);
CREATE INDEX IF NOT EXISTS idx_sessions_created_at ON sessions(created_at);
CREATE INDEX IF NOT EXISTS idx_sessions_status ON sessions(status);

-- 消息表索引优化
CREATE INDEX IF NOT EXISTS idx_messages_session_id ON messages(session_id);
CREATE INDEX IF NOT EXISTS idx_messages_created_at ON messages(created_at);
CREATE INDEX IF NOT EXISTS idx_messages_role ON messages(role);

-- 工具表索引优化
CREATE INDEX IF NOT EXISTS idx_tools_user_id ON tools(created_by);
CREATE INDEX IF NOT EXISTS idx_tools_status ON tools(status);
CREATE INDEX IF NOT EXISTS idx_tools_type ON tools(type);

-- 账户表索引优化
CREATE INDEX IF NOT EXISTS idx_accounts_user_id ON accounts(user_id);
CREATE INDEX IF NOT EXISTS idx_accounts_created_at ON accounts(created_at);

-- 复合索引优化
CREATE INDEX IF NOT EXISTS idx_agents_user_status ON agents(created_by, status);
CREATE INDEX IF NOT EXISTS idx_sessions_user_agent ON sessions(user_id, agent_id);
CREATE INDEX IF NOT EXISTS idx_messages_session_time ON messages(session_id, created_at);

-- 分析表统计信息
ANALYZE users;
ANALYZE agents;
ANALYZE sessions;
ANALYZE messages;
ANALYZE tools;
ANALYZE accounts;
EOF
    
    # 执行索引创建
    echo -e "${BLUE}执行索引创建...${NC}"
    if [ -n "$DB_HOST" ] && [ -n "$DB_USER" ] && [ -n "$DB_NAME" ]; then
        psql -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" -f performance-config/database/create-performance-indexes.sql
        echo -e "${GREEN}✅ 索引创建完成${NC}"
    else
        echo -e "${YELLOW}⚠️  数据库连接信息未设置，请手动执行索引创建脚本${NC}"
        echo -e "${YELLOW}脚本位置: performance-config/database/create-performance-indexes.sql${NC}"
    fi
}

# 优化PostgreSQL参数
optimize_postgresql_parameters() {
    echo -e "${BLUE}⚙️  优化PostgreSQL参数...${NC}"
    
    # 创建参数优化脚本
    cat > performance-config/database/optimize-postgresql-params.sql << 'EOF'
-- PostgreSQL性能参数优化

-- 内存配置
ALTER SYSTEM SET shared_buffers = '256MB';  -- 系统内存的25%
ALTER SYSTEM SET effective_cache_size = '1GB';  -- 系统内存的75%
ALTER SYSTEM SET work_mem = '4MB';  -- 排序和哈希操作内存
ALTER SYSTEM SET maintenance_work_mem = '64MB';  -- 维护操作内存

-- 连接配置
ALTER SYSTEM SET max_connections = 100;  -- 最大连接数
ALTER SYSTEM SET superuser_reserved_connections = 3;  -- 保留连接

-- 查询优化
ALTER SYSTEM SET random_page_cost = 1.1;  -- SSD存储
ALTER SYSTEM SET effective_io_concurrency = 200;  -- 并发I/O
ALTER SYSTEM SET checkpoint_completion_target = 0.9;  -- 检查点完成目标

-- 日志配置
ALTER SYSTEM SET log_min_duration_statement = 1000;  -- 慢查询日志阈值(毫秒)
ALTER SYSTEM SET log_checkpoints = on;  -- 记录检查点
ALTER SYSTEM SET log_connections = on;  -- 记录连接
ALTER SYSTEM SET log_disconnections = on;  -- 记录断开连接

-- 重新加载配置
SELECT pg_reload_conf();
EOF
    
    echo -e "${GREEN}✅ PostgreSQL参数优化脚本已创建${NC}"
    echo -e "${YELLOW}⚠️  请手动执行参数优化脚本或重启PostgreSQL服务${NC}"
}

# 重启服务
restart_services() {
    echo -e "${BLUE}🔄 重启服务...${NC}"
    
    # 检查Docker Compose文件
    if [ -f "docker-compose.yml" ]; then
        echo -e "${BLUE}重启Docker服务...${NC}"
        docker-compose restart imagentx-backend
        echo -e "${GREEN}✅ 服务重启完成${NC}"
    elif [ -f "config/docker/docker-compose.yml" ]; then
        echo -e "${BLUE}重启Docker服务...${NC}"
        docker-compose -f config/docker/docker-compose.yml restart imagentx-backend
        echo -e "${GREEN}✅ 服务重启完成${NC}"
    else
        echo -e "${YELLOW}⚠️  未找到Docker Compose文件，请手动重启服务${NC}"
    fi
}

# 验证优化效果
verify_optimization() {
    echo -e "${BLUE}✅ 验证优化效果...${NC}"
    
    # 等待服务启动
    echo -e "${BLUE}等待服务启动...${NC}"
    sleep 30
    
    # 检查服务健康状态
    if curl -s http://localhost:8088/api/health >/dev/null 2>&1; then
        echo -e "${GREEN}✅ 后端服务运行正常${NC}"
    else
        echo -e "${RED}❌ 后端服务异常${NC}"
    fi
    
    # 检查数据库连接
    if [ -n "$DB_HOST" ] && [ -n "$DB_USER" ] && [ -n "$DB_NAME" ]; then
        if psql -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" -c "SELECT 1;" >/dev/null 2>&1; then
            echo -e "${GREEN}✅ 数据库连接正常${NC}"
        else
            echo -e "${RED}❌ 数据库连接异常${NC}"
        fi
    fi
    
    # 检查索引状态
    if [ -n "$DB_HOST" ] && [ -n "$DB_USER" ] && [ -n "$DB_NAME" ]; then
        echo -e "${BLUE}检查索引状态...${NC}"
        psql -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" -c "
        SELECT 
            schemaname,
            tablename,
            indexname,
            idx_scan
        FROM pg_stat_user_indexes 
        WHERE indexname LIKE 'idx_%'
        ORDER BY idx_scan DESC;
        "
    fi
}

# 创建监控配置
setup_monitoring() {
    echo -e "${BLUE}📊 设置监控配置...${NC}"
    
    # 创建监控配置目录
    mkdir -p monitoring/{prometheus,grafana}
    
    # 创建Prometheus配置
    cat > monitoring/prometheus/prometheus.yml << 'EOF'
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: 'imagentx-backend'
    static_configs:
      - targets: ['host.docker.internal:8088']
    metrics_path: '/actuator/prometheus'
    scrape_interval: 10s

  - job_name: 'postgres'
    static_configs:
      - targets: ['host.docker.internal:5432']
    scrape_interval: 30s
EOF
    
    # 创建Grafana仪表板配置
    cat > monitoring/grafana/dashboard.json << 'EOF'
{
  "dashboard": {
    "title": "ImagentX Database Performance",
    "panels": [
      {
        "title": "Database Connections",
        "type": "graph",
        "targets": [
          {
            "expr": "database_connections_active",
            "legendFormat": "Active Connections"
          },
          {
            "expr": "database_connections_idle",
            "legendFormat": "Idle Connections"
          }
        ]
      }
    ]
  }
}
EOF
    
    echo -e "${GREEN}✅ 监控配置已创建${NC}"
}

# 显示使用说明
show_usage_instructions() {
    echo -e "${BLUE}📚 使用说明${NC}"
    echo ""
    echo -e "${GREEN}✅ 数据库性能优化部署完成！${NC}"
    echo ""
    echo -e "${YELLOW}📋 后续步骤：${NC}"
    echo "1. 手动执行PostgreSQL参数优化脚本（如需要）"
    echo "2. 监控系统性能指标"
    echo "3. 根据实际负载调整连接池大小"
    echo "4. 定期检查慢查询日志"
    echo ""
    echo -e "${YELLOW}📁 重要文件位置：${NC}"
    echo "- 优化配置: performance-config/database/"
    echo "- 监控配置: monitoring/"
    echo "- 备份文件: backup/"
    echo ""
    echo -e "${YELLOW}🔧 常用命令：${NC}"
    echo "- 检查索引: psql -h localhost -U imagentx_user -d imagentx -c \"SELECT * FROM pg_stat_user_indexes;\""
    echo "- 检查慢查询: psql -h localhost -U imagentx_user -d imagentx -c \"SELECT * FROM pg_stat_statements ORDER BY mean_time DESC LIMIT 10;\""
    echo "- 检查连接池: curl http://localhost:8088/actuator/health"
}

# 主函数
main() {
    echo -e "${BLUE}🎯 ImagentX 数据库性能优化部署${NC}"
    echo ""
    
    # 检查环境变量
    if [ -z "$DB_HOST" ]; then
        export DB_HOST="localhost"
    fi
    if [ -z "$DB_USER" ]; then
        export DB_USER="imagentx_user"
    fi
    if [ -z "$DB_NAME" ]; then
        export DB_NAME="imagentx"
    fi
    
    echo -e "${BLUE}数据库连接信息：${NC}"
    echo "- 主机: $DB_HOST"
    echo "- 用户: $DB_USER"
    echo "- 数据库: $DB_NAME"
    echo ""
    
    # 执行优化步骤
    check_requirements
    backup_configuration
    apply_optimization_config
    create_performance_indexes
    optimize_postgresql_parameters
    restart_services
    verify_optimization
    setup_monitoring
    show_usage_instructions
    
    echo -e "${GREEN}🎉 数据库性能优化部署完成！${NC}"
}

# 执行主函数
main "$@"
