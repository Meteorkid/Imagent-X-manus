#!/bin/bash

# ImagentX 数据库性能监控脚本
# 用于实时监控数据库性能指标

set -e

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # 无颜色

# 配置
DB_HOST=${DB_HOST:-"localhost"}
DB_USER=${DB_USER:-"imagentx_user"}
DB_NAME=${DB_NAME:-"imagentx"}
BACKEND_URL=${BACKEND_URL:-"http://localhost:8088"}
MONITOR_INTERVAL=${MONITOR_INTERVAL:-30}  # 监控间隔（秒）

# 日志文件
LOG_FILE="logs/database-performance-$(date +%Y%m%d).log"
mkdir -p logs

# 记录日志
log_message() {
    local level=$1
    local message=$2
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $message" | tee -a "$LOG_FILE"
}

# 检查数据库连接
check_database_connection() {
    if psql -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" -c "SELECT 1;" >/dev/null 2>&1; then
        echo -e "${GREEN}✅ 数据库连接正常${NC}"
        return 0
    else
        echo -e "${RED}❌ 数据库连接异常${NC}"
        log_message "ERROR" "数据库连接失败"
        return 1
    fi
}

# 检查后端服务
check_backend_service() {
    if curl -s "$BACKEND_URL/api/health" >/dev/null 2>&1; then
        echo -e "${GREEN}✅ 后端服务正常${NC}"
        return 0
    else
        echo -e "${RED}❌ 后端服务异常${NC}"
        log_message "ERROR" "后端服务连接失败"
        return 1
    fi
}

# 获取数据库连接池状态
get_connection_pool_status() {
    echo -e "${BLUE}📊 数据库连接池状态：${NC}"
    
    # 获取活跃连接数
    local active_connections=$(psql -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" -t -c "
        SELECT count(*) FROM pg_stat_activity WHERE state = 'active';
    " | tr -d ' ')
    
    # 获取总连接数
    local total_connections=$(psql -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" -t -c "
        SELECT count(*) FROM pg_stat_activity;
    " | tr -d ' ')
    
    # 获取最大连接数
    local max_connections=$(psql -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" -t -c "
        SHOW max_connections;
    " | tr -d ' ')
    
    echo "活跃连接: $active_connections"
    echo "总连接数: $total_connections"
    echo "最大连接数: $max_connections"
    echo "连接利用率: $(echo "scale=2; $active_connections * 100 / $max_connections" | bc)%"
    
    # 记录到日志
    log_message "INFO" "连接池状态 - 活跃: $active_connections, 总数: $total_connections, 最大: $max_connections"
}

# 获取慢查询统计
get_slow_query_stats() {
    echo -e "${BLUE}🐌 慢查询统计：${NC}"
    
    # 检查pg_stat_statements扩展是否启用
    local extension_exists=$(psql -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" -t -c "
        SELECT count(*) FROM pg_extension WHERE extname = 'pg_stat_statements';
    " | tr -d ' ')
    
    if [ "$extension_exists" -eq 1 ]; then
        # 获取慢查询（超过1秒的查询）
        local slow_queries=$(psql -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" -t -c "
            SELECT 
                query,
                calls,
                total_time,
                mean_time,
                rows
            FROM pg_stat_statements 
            WHERE mean_time > 1000
            ORDER BY mean_time DESC
            LIMIT 5;
        ")
        
        if [ -n "$slow_queries" ]; then
            echo "$slow_queries"
            log_message "WARN" "发现慢查询"
        else
            echo "暂无慢查询"
            log_message "INFO" "无慢查询"
        fi
    else
        echo "pg_stat_statements扩展未启用"
        log_message "WARN" "pg_stat_statements扩展未启用"
    fi
}

# 获取索引使用情况
get_index_usage_stats() {
    echo -e "${BLUE}🔍 索引使用情况：${NC}"
    
    local index_stats=$(psql -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" -c "
        SELECT 
            schemaname,
            tablename,
            indexname,
            idx_scan,
            idx_tup_read,
            idx_tup_fetch
        FROM pg_stat_user_indexes 
        WHERE idx_scan > 0
        ORDER BY idx_scan DESC
        LIMIT 10;
    ")
    
    echo "$index_stats"
    log_message "INFO" "索引使用统计已收集"
}

# 获取表大小统计
get_table_size_stats() {
    echo -e "${BLUE}📏 表大小统计：${NC}"
    
    local table_sizes=$(psql -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" -c "
        SELECT 
            schemaname,
            tablename,
            pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) as size,
            pg_total_relation_size(schemaname||'.'||tablename) as size_bytes
        FROM pg_tables 
        WHERE schemaname = 'public'
        ORDER BY size_bytes DESC
        LIMIT 10;
    ")
    
    echo "$table_sizes"
    log_message "INFO" "表大小统计已收集"
}

# 获取缓存命中率
get_cache_hit_ratio() {
    echo -e "${BLUE}💾 缓存命中率：${NC}"
    
    local cache_stats=$(psql -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" -t -c "
        SELECT 
            sum(heap_blks_read) as heap_read,
            sum(heap_blks_hit) as heap_hit,
            CASE 
                WHEN sum(heap_blks_hit) + sum(heap_blks_read) = 0 THEN 0
                ELSE round(100.0 * sum(heap_blks_hit) / (sum(heap_blks_hit) + sum(heap_blks_read)), 2)
            END as hit_ratio
        FROM pg_statio_user_tables;
    ")
    
    echo "缓存命中率: $cache_stats%"
    log_message "INFO" "缓存命中率: $cache_stats%"
}

# 获取系统资源使用情况
get_system_resources() {
    echo -e "${BLUE}💻 系统资源使用情况：${NC}"
    
    # CPU使用率
    local cpu_usage=$(top -l 1 | grep "CPU usage" | awk '{print $3}' | sed 's/%//')
    echo "CPU使用率: ${cpu_usage}%"
    
    # 内存使用情况
    local memory_info=$(vm_stat | grep "Pages free" | awk '{print $3}' | sed 's/\.//')
    local total_memory=$(sysctl -n hw.memsize)
    local free_memory=$((memory_info * 4096))
    local used_memory=$((total_memory - free_memory))
    local memory_usage=$((used_memory * 100 / total_memory))
    echo "内存使用率: ${memory_usage}%"
    
    # 磁盘使用情况
    local disk_usage=$(df -h / | tail -1 | awk '{print $5}' | sed 's/%//')
    echo "磁盘使用率: ${disk_usage}%"
    
    log_message "INFO" "系统资源 - CPU: ${cpu_usage}%, 内存: ${memory_usage}%, 磁盘: ${disk_usage}%"
}

# 检查性能告警
check_performance_alerts() {
    echo -e "${BLUE}🚨 性能告警检查：${NC}"
    
    # 检查连接数告警
    local active_connections=$(psql -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" -t -c "
        SELECT count(*) FROM pg_stat_activity WHERE state = 'active';
    " | tr -d ' ')
    
    local max_connections=$(psql -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" -t -c "
        SHOW max_connections;
    " | tr -d ' ')
    
    local connection_ratio=$((active_connections * 100 / max_connections))
    
    if [ $connection_ratio -gt 80 ]; then
        echo -e "${RED}⚠️  连接数告警: 连接利用率 ${connection_ratio}%${NC}"
        log_message "ALERT" "连接数告警: 连接利用率 ${connection_ratio}%"
    fi
    
    # 检查慢查询告警
    local slow_query_count=$(psql -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" -t -c "
        SELECT count(*) FROM pg_stat_statements WHERE mean_time > 1000;
    " | tr -d ' ')
    
    if [ "$slow_query_count" -gt 10 ]; then
        echo -e "${RED}⚠️  慢查询告警: 发现 ${slow_query_count} 个慢查询${NC}"
        log_message "ALERT" "慢查询告警: 发现 ${slow_query_count} 个慢查询"
    fi
    
    # 检查缓存命中率告警
    local cache_hit_ratio=$(psql -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" -t -c "
        SELECT 
            CASE 
                WHEN sum(heap_blks_hit) + sum(heap_blks_read) = 0 THEN 100
                ELSE round(100.0 * sum(heap_blks_hit) / (sum(heap_blks_hit) + sum(heap_blks_read)), 2)
            END
        FROM pg_statio_user_tables;
    " | tr -d ' ')
    
    if [ $(echo "$cache_hit_ratio < 80" | bc) -eq 1 ]; then
        echo -e "${RED}⚠️  缓存命中率告警: ${cache_hit_ratio}%${NC}"
        log_message "ALERT" "缓存命中率告警: ${cache_hit_ratio}%"
    fi
}

# 生成性能报告
generate_performance_report() {
    echo -e "${BLUE}📊 生成性能报告...${NC}"
    
    local report_file="reports/database-performance-$(date +%Y%m%d_%H%M%S).txt"
    mkdir -p reports
    
    {
        echo "ImagentX 数据库性能报告"
        echo "生成时间: $(date)"
        echo "=================================="
        echo ""
        
        echo "数据库连接信息:"
        echo "- 主机: $DB_HOST"
        echo "- 用户: $DB_USER"
        echo "- 数据库: $DB_NAME"
        echo ""
        
        echo "连接池状态:"
        psql -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" -c "
            SELECT 
                count(*) as total_connections,
                count(*) FILTER (WHERE state = 'active') as active_connections,
                count(*) FILTER (WHERE state = 'idle') as idle_connections
            FROM pg_stat_activity;
        "
        echo ""
        
        echo "慢查询统计:"
        psql -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" -c "
            SELECT 
                query,
                calls,
                total_time,
                mean_time,
                rows
            FROM pg_stat_statements 
            WHERE mean_time > 1000
            ORDER BY mean_time DESC
            LIMIT 10;
        "
        echo ""
        
        echo "索引使用情况:"
        psql -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" -c "
            SELECT 
                schemaname,
                tablename,
                indexname,
                idx_scan,
                idx_tup_read
            FROM pg_stat_user_indexes 
            ORDER BY idx_scan DESC
            LIMIT 15;
        "
        
    } > "$report_file"
    
    echo -e "${GREEN}✅ 性能报告已生成: $report_file${NC}"
    log_message "INFO" "性能报告已生成: $report_file"
}

# 显示帮助信息
show_help() {
    echo "ImagentX 数据库性能监控工具"
    echo ""
    echo "用法: $0 [选项]"
    echo ""
    echo "选项:"
    echo "  -h, --help              显示帮助信息"
    echo "  -i, --interval SECONDS  设置监控间隔（默认30秒）"
    echo "  -c, --continuous        持续监控模式"
    echo "  -r, --report            生成性能报告"
    echo "  -a, --alerts            仅检查告警"
    echo ""
    echo "环境变量:"
    echo "  DB_HOST                 数据库主机（默认: localhost）"
    echo "  DB_USER                 数据库用户（默认: imagentx_user）"
    echo "  DB_NAME                 数据库名称（默认: imagentx）"
    echo "  BACKEND_URL             后端服务URL（默认: http://localhost:8088）"
    echo ""
    echo "示例:"
    echo "  $0 -c                   持续监控"
    echo "  $0 -r                   生成性能报告"
    echo "  $0 -a                   检查告警"
}

# 主监控循环
monitor_loop() {
    echo -e "${BLUE}🔄 开始持续监控（间隔: ${MONITOR_INTERVAL}秒）...${NC}"
    echo "按 Ctrl+C 停止监控"
    echo ""
    
    while true; do
        echo "=================================="
        echo "监控时间: $(date)"
        echo "=================================="
        
        # 检查服务状态
        check_database_connection
        check_backend_service
        echo ""
        
        # 收集性能指标
        get_connection_pool_status
        echo ""
        
        get_cache_hit_ratio
        echo ""
        
        get_slow_query_stats
        echo ""
        
        get_system_resources
        echo ""
        
        # 检查告警
        check_performance_alerts
        echo ""
        
        echo "=================================="
        echo ""
        
        # 等待下次监控
        sleep "$MONITOR_INTERVAL"
    done
}

# 主函数
main() {
    # 解析命令行参数
    CONTINUOUS_MODE=false
    GENERATE_REPORT=false
    CHECK_ALERTS_ONLY=false
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            -i|--interval)
                MONITOR_INTERVAL="$2"
                shift 2
                ;;
            -c|--continuous)
                CONTINUOUS_MODE=true
                shift
                ;;
            -r|--report)
                GENERATE_REPORT=true
                shift
                ;;
            -a|--alerts)
                CHECK_ALERTS_ONLY=true
                shift
                ;;
            *)
                echo "未知选项: $1"
                show_help
                exit 1
                ;;
        esac
    done
    
    echo -e "${BLUE}🎯 ImagentX 数据库性能监控${NC}"
    echo ""
    
    # 检查数据库连接
    if ! check_database_connection; then
        exit 1
    fi
    
    # 根据参数执行相应操作
    if [ "$CHECK_ALERTS_ONLY" = true ]; then
        echo -e "${BLUE}🚨 检查性能告警...${NC}"
        check_performance_alerts
    elif [ "$GENERATE_REPORT" = true ]; then
        generate_performance_report
    elif [ "$CONTINUOUS_MODE" = true ]; then
        monitor_loop
    else
        # 单次监控
        echo -e "${BLUE}📊 执行单次性能监控...${NC}"
        echo ""
        
        check_database_connection
        check_backend_service
        echo ""
        
        get_connection_pool_status
        echo ""
        
        get_index_usage_stats
        echo ""
        
        get_table_size_stats
        echo ""
        
        get_cache_hit_ratio
        echo ""
        
        get_slow_query_stats
        echo ""
        
        get_system_resources
        echo ""
        
        check_performance_alerts
        echo ""
        
        echo -e "${GREEN}✅ 性能监控完成${NC}"
    fi
}

# 执行主函数
main "$@"
