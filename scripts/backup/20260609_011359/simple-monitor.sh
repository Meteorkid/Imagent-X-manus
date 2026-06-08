#!/bin/bash

# ImagentX 简化性能监控脚本

set -e

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}📊 ImagentX 简化性能监控${NC}"
echo "监控时间: $(date)"
echo ""

# 设置环境变量
export PGPASSWORD=imagentx_pass

# 检查数据库连接
check_database_connection() {
    echo -e "${BLUE}🔍 检查数据库连接...${NC}"
    if PGPASSWORD=imagentx_pass psql -h localhost -U imagentx_user -d imagentx -c "SELECT 1;" >/dev/null 2>&1; then
        echo -e "${GREEN}✅ 数据库连接正常${NC}"
        return 0
    else
        echo -e "${RED}❌ 数据库连接失败${NC}"
        return 1
    fi
}

# 检查后端服务
check_backend_service() {
    echo -e "${BLUE}🔍 检查后端服务...${NC}"
    if curl -s http://localhost:8088/api/health >/dev/null 2>&1; then
        echo -e "${GREEN}✅ 后端服务正常${NC}"
        return 0
    else
        echo -e "${RED}❌ 后端服务异常${NC}"
        return 1
    fi
}

# 获取连接池状态
get_connection_pool_status() {
    echo -e "${BLUE}🔗 数据库连接池状态${NC}"
    
    local total_connections=$(PGPASSWORD=imagentx_pass psql -h localhost -U imagentx_user -d imagentx -t -c "
        SELECT count(*) FROM pg_stat_activity;
    " | tr -d ' ')
    
    local active_connections=$(PGPASSWORD=imagentx_pass psql -h localhost -U imagentx_user -d imagentx -t -c "
        SELECT count(*) FROM pg_stat_activity WHERE state = 'active';
    " | tr -d ' ')
    
    local idle_connections=$(PGPASSWORD=imagentx_pass psql -h localhost -U imagentx_user -d imagentx -t -c "
        SELECT count(*) FROM pg_stat_activity WHERE state = 'idle';
    " | tr -d ' ')
    
    echo "总连接数: $total_connections"
    echo "活跃连接: $active_connections"
    echo "空闲连接: $idle_connections"
    echo "连接利用率: $(echo "scale=2; $active_connections * 100 / $total_connections" | bc)%"
}

# 获取缓存命中率
get_cache_hit_ratio() {
    echo -e "${BLUE}💾 缓存命中率${NC}"
    
    local cache_hit_ratio=$(PGPASSWORD=imagentx_pass psql -h localhost -U imagentx_user -d imagentx -t -c "
        SELECT 
            CASE 
                WHEN sum(heap_blks_hit) + sum(heap_blks_read) = 0 THEN 100
                ELSE round(100.0 * sum(heap_blks_hit) / (sum(heap_blks_hit) + sum(heap_blks_read)), 2)
            END
        FROM pg_statio_user_tables;
    " | tr -d ' ')
    
    echo "缓存命中率: ${cache_hit_ratio}%"
    
    # 缓存命中率告警
    if [ $(echo "$cache_hit_ratio < 80" | bc) -eq 1 ]; then
        echo -e "${YELLOW}⚠️  缓存命中率较低，建议优化${NC}"
    else
        echo -e "${GREEN}✅ 缓存命中率良好${NC}"
    fi
}

# 获取表大小信息
get_table_sizes() {
    echo -e "${BLUE}📏 主要表大小${NC}"
    
    PGPASSWORD=imagentx_pass psql -h localhost -U imagentx_user -d imagentx -c "
        SELECT 
            schemaname,
            tablename,
            pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) as size
        FROM pg_tables 
        WHERE schemaname = 'public'
            AND tablename IN ('users', 'agents', 'sessions', 'messages', 'tools', 'accounts')
        ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;
    "
}

# 获取索引使用情况
get_index_usage() {
    echo -e "${BLUE}🔍 索引使用情况${NC}"
    
    local used_indexes=$(PGPASSWORD=imagentx_pass psql -h localhost -U imagentx_user -d imagentx -t -c "
        SELECT COUNT(*) FROM pg_stat_user_indexes WHERE idx_scan > 0;
    " | tr -d ' ')
    
    local total_indexes=$(PGPASSWORD=imagentx_pass psql -h localhost -U imagentx_user -d imagentx -t -c "
        SELECT COUNT(*) FROM pg_stat_user_indexes;
    " | tr -d ' ')
    
    echo "已使用索引: $used_indexes"
    echo "总索引数: $total_indexes"
    echo "索引使用率: $(echo "scale=2; $used_indexes * 100 / $total_indexes" | bc)%"
}

# 获取系统资源使用情况
get_system_resources() {
    echo -e "${BLUE}💻 系统资源使用情况${NC}"
    
    # CPU使用率
    local cpu_usage=$(top -l 1 | grep "CPU usage" | awk '{print $3}' | sed 's/%//')
    echo "CPU使用率: ${cpu_usage}%"
    
    # 内存使用率
    local memory_info=$(vm_stat | grep "Pages free:" | awk '{print $3}' | sed 's/\.//')
    local total_memory=$(sysctl -n hw.memsize | awk '{print $1/1024/1024/1024}')
    local free_memory=$(echo "scale=2; $memory_info * 4096 / 1024 / 1024 / 1024" | bc)
    local memory_usage=$(echo "scale=2; ($total_memory - $free_memory) * 100 / $total_memory" | bc)
    echo "内存使用率: ${memory_usage}%"
    
    # 磁盘使用率
    local disk_usage=$(df -h / | tail -1 | awk '{print $5}' | sed 's/%//')
    echo "磁盘使用率: ${disk_usage}%"
}

# 性能告警检查
check_performance_alerts() {
    echo -e "${BLUE}🚨 性能告警检查${NC}"
    
    # 连接数告警
    local total_connections=$(PGPASSWORD=imagentx_pass psql -h localhost -U imagentx_user -d imagentx -t -c "
        SELECT count(*) FROM pg_stat_activity;
    " | tr -d ' ')
    
    if [ "$total_connections" -gt 80 ]; then
        echo -e "${YELLOW}⚠️  数据库连接数较高: $total_connections${NC}"
    else
        echo -e "${GREEN}✅ 数据库连接数正常: $total_connections${NC}"
    fi
    
    # 缓存命中率告警
    local cache_hit_ratio=$(PGPASSWORD=imagentx_pass psql -h localhost -U imagentx_user -d imagentx -t -c "
        SELECT 
            CASE 
                WHEN sum(heap_blks_hit) + sum(heap_blks_read) = 0 THEN 100
                ELSE round(100.0 * sum(heap_blks_hit) / (sum(heap_blks_hit) + sum(heap_blks_read)), 2)
            END
        FROM pg_statio_user_tables;
    " | tr -d ' ')
    
    if [ $(echo "$cache_hit_ratio < 80" | bc) -eq 1 ]; then
        echo -e "${YELLOW}⚠️  缓存命中率较低: ${cache_hit_ratio}%${NC}"
    else
        echo -e "${GREEN}✅ 缓存命中率良好: ${cache_hit_ratio}%${NC}"
    fi
}

# 生成性能摘要
generate_performance_summary() {
    echo -e "${BLUE}📊 性能摘要${NC}"
    echo "=================================="
    
    # 数据库状态
    if check_database_connection; then
        echo "✅ 数据库: 正常"
    else
        echo "❌ 数据库: 异常"
    fi
    
    # 后端服务状态
    if check_backend_service; then
        echo "✅ 后端服务: 正常"
    else
        echo "❌ 后端服务: 异常"
    fi
    
    echo ""
    
    # 连接池状态
    get_connection_pool_status
    echo ""
    
    # 缓存命中率
    get_cache_hit_ratio
    echo ""
    
    # 索引使用情况
    get_index_usage
    echo ""
    
    # 系统资源
    get_system_resources
    echo ""
    
    # 性能告警
    check_performance_alerts
    echo ""
    
    echo "=================================="
    echo -e "${GREEN}🎉 性能监控完成！${NC}"
}

# 主函数
main() {
    echo "=================================="
    
    # 生成性能摘要
    generate_performance_summary
    
    echo "=================================="
}

# 执行主函数
main "$@"
