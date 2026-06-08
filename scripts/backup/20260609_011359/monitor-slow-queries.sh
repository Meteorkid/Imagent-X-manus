#!/bin/bash

# ImagentX 慢查询监控脚本

set -e

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

# 配置
DB_HOST=${DB_HOST:-"localhost"}
DB_USER=${DB_USER:-"imagentx_user"}
DB_NAME=${DB_NAME:-"imagentx"}
SLOW_QUERY_THRESHOLD=${SLOW_QUERY_THRESHOLD:-1000}  # 慢查询阈值(毫秒)
LOG_FILE="logs/slow-queries-$(date +%Y%m%d).log"
REPORT_FILE="reports/slow-queries-$(date +%Y%m%d_%H%M%S).txt"

mkdir -p logs reports

# 记录日志
log_message() {
    local level=$1
    local message=$2
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $message" | tee -a "$LOG_FILE"
}

echo -e "${BLUE}🐌 ImagentX 慢查询监控${NC}"
echo "慢查询阈值: ${SLOW_QUERY_THRESHOLD}ms"
echo "监控时间: $(date)"
echo ""

# 检查pg_stat_statements扩展
check_extension() {
    local extension_exists=$(PGPASSWORD=imagentx_pass psql -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" -t -c "
        SELECT count(*) FROM pg_extension WHERE extname = 'pg_stat_statements';
    " | tr -d ' ')
    
    if [ "$extension_exists" -eq 1 ]; then
        echo -e "${GREEN}✅ pg_stat_statements 扩展已启用${NC}"
        return 0
    else
        echo -e "${RED}❌ pg_stat_statements 扩展未启用${NC}"
        return 1
    fi
}

# 获取慢查询统计
get_slow_queries() {
    echo -e "${BLUE}📊 慢查询统计 (阈值: ${SLOW_QUERY_THRESHOLD}ms)${NC}"
    echo ""
    
    local slow_queries=$(PGPASSWORD=imagentx_pass psql -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" -c "
        SELECT 
            query,
            calls,
            total_exec_time,
            mean_exec_time,
            rows,
            shared_blks_hit,
            shared_blks_read
        FROM pg_stat_statements 
        WHERE mean_exec_time > $SLOW_QUERY_THRESHOLD
        ORDER BY mean_exec_time DESC
        LIMIT 10;
    " 2>/dev/null)
    
    if [ -n "$slow_queries" ] && [ "$(echo "$slow_queries" | wc -l)" -gt 1 ]; then
        echo "$slow_queries"
        log_message "WARN" "发现慢查询"
        
        # 生成慢查询报告
        {
            echo "ImagentX 慢查询报告"
            echo "生成时间: $(date)"
            echo "慢查询阈值: ${SLOW_QUERY_THRESHOLD}ms"
            echo "=================================="
            echo ""
            echo "$slow_queries"
        } > "$REPORT_FILE"
        
        echo ""
        echo -e "${YELLOW}📄 慢查询报告已生成: $REPORT_FILE${NC}"
    else
        echo "暂无慢查询"
        log_message "INFO" "无慢查询"
    fi
}

# 获取查询性能趋势
get_query_performance_trends() {
    echo -e "${BLUE}📈 查询性能趋势${NC}"
    echo ""
    
    echo "查询执行时间分布:"
    PGPASSWORD=imagentx_pass psql -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" -c "
        SELECT 
            CASE 
                WHEN mean_exec_time < 100 THEN '< 100ms'
                WHEN mean_exec_time < 500 THEN '100-500ms'
                WHEN mean_exec_time < 1000 THEN '500ms-1s'
                WHEN mean_exec_time < 5000 THEN '1s-5s'
                ELSE '> 5s'
            END as time_range,
            COUNT(*) as query_count,
            ROUND(AVG(mean_exec_time), 2) as avg_time
        FROM pg_stat_statements 
        GROUP BY 
            CASE 
                WHEN mean_exec_time < 100 THEN '< 100ms'
                WHEN mean_exec_time < 500 THEN '100-500ms'
                WHEN mean_exec_time < 1000 THEN '500ms-1s'
                WHEN mean_exec_time < 5000 THEN '1s-5s'
                ELSE '> 5s'
            END
        ORDER BY 
            CASE 
                WHEN mean_exec_time < 100 THEN 1
                WHEN mean_exec_time < 500 THEN 2
                WHEN mean_exec_time < 1000 THEN 3
                WHEN mean_exec_time < 5000 THEN 4
                ELSE 5
            END;
    " 2>/dev/null || echo "pg_stat_statements 数据不足"
}

# 获取表访问统计
get_table_access_stats() {
    echo -e "${BLUE}📋 表访问统计${NC}"
    echo ""
    
    echo "表访问频率 (按扫描次数排序):"
    PGPASSWORD=imagentx_pass psql -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" -c "
        SELECT 
            schemaname,
            relname as tablename,
            seq_scan,
            seq_tup_read,
            idx_scan,
            idx_tup_fetch
        FROM pg_stat_user_tables 
        ORDER BY seq_scan + idx_scan DESC
        LIMIT 10;
    "
}

# 获取索引使用统计
get_index_usage_stats() {
    echo -e "${BLUE}🔍 索引使用统计${NC}"
    echo ""
    
    echo "索引使用情况:"
    PGPASSWORD=imagentx_pass psql -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" -c "
        SELECT 
            schemaname,
            relname as tablename,
            indexrelname as indexname,
            idx_scan,
            idx_tup_read,
            idx_tup_fetch
        FROM pg_stat_user_indexes 
        ORDER BY idx_scan DESC
        LIMIT 15;
    "
}

# 生成优化建议
generate_optimization_suggestions() {
    echo -e "${BLUE}💡 优化建议${NC}"
    echo ""
    
    # 检查未使用的索引
    local unused_indexes=$(PGPASSWORD=imagentx_pass psql -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" -t -c "
        SELECT COUNT(*) FROM pg_stat_user_indexes WHERE idx_scan = 0;
    " | tr -d ' ')
    
    if [ "$unused_indexes" -gt 0 ]; then
        echo -e "${YELLOW}⚠️  发现 $unused_indexes 个未使用的索引，建议评估是否需要${NC}"
    fi
    
    # 检查高序列扫描的表
    local high_seq_scan=$(PGPASSWORD=imagentx_pass psql -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" -t -c "
        SELECT COUNT(*) FROM pg_stat_user_tables WHERE seq_scan > idx_scan * 10 AND seq_scan > 100;
    " | tr -d ' ')
    
    if [ "$high_seq_scan" -gt 0 ]; then
        echo -e "${YELLOW}⚠️  发现 $high_seq_scan 个表存在高序列扫描，建议添加索引${NC}"
    fi
    
    # 检查缓存命中率
    local cache_hit_ratio=$(PGPASSWORD=imagentx_pass psql -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" -t -c "
        SELECT 
            CASE 
                WHEN sum(heap_blks_hit) + sum(heap_blks_read) = 0 THEN 100
                ELSE round(100.0 * sum(heap_blks_hit) / (sum(heap_blks_hit) + sum(heap_blks_read)), 2)
            END
        FROM pg_statio_user_tables;
    " | tr -d ' ')
    
    if [ $(echo "$cache_hit_ratio < 80" | bc) -eq 1 ]; then
        echo -e "${YELLOW}⚠️  缓存命中率较低 ($cache_hit_ratio%)，建议增加 shared_buffers${NC}"
    else
        echo -e "${GREEN}✅ 缓存命中率良好 ($cache_hit_ratio%)${NC}"
    fi
}

# 主函数
main() {
    echo "=================================="
    
    # 检查扩展
    if ! check_extension; then
        echo -e "${RED}无法继续监控，请先启用 pg_stat_statements 扩展${NC}"
        exit 1
    fi
    
    echo ""
    
    # 获取慢查询统计
    get_slow_queries
    echo ""
    
    # 获取查询性能趋势
    get_query_performance_trends
    echo ""
    
    # 获取表访问统计
    get_table_access_stats
    echo ""
    
    # 获取索引使用统计
    get_index_usage_stats
    echo ""
    
    # 生成优化建议
    generate_optimization_suggestions
    echo ""
    
    echo "=================================="
    echo -e "${GREEN}🎉 慢查询监控完成！${NC}"
    echo ""
    echo -e "${YELLOW}📋 监控结果：${NC}"
    echo "- 日志文件: $LOG_FILE"
    if [ -f "$REPORT_FILE" ]; then
        echo "- 慢查询报告: $REPORT_FILE"
    fi
    echo ""
    echo -e "${YELLOW}📅 建议监控频率：${NC}"
    echo "- 开发环境: 每小时"
    echo "- 测试环境: 每4小时"
    echo "- 生产环境: 每天"
}

# 执行主函数
main "$@"
