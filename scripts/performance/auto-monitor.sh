#!/bin/bash

# ImagentX 自动化性能监控脚本

set -e

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

# 配置
MONITOR_INTERVAL=${MONITOR_INTERVAL:-3600}  # 默认1小时
SLOW_QUERY_THRESHOLD=${SLOW_QUERY_THRESHOLD:-1000}  # 慢查询阈值(毫秒)
LOG_DIR="logs/auto-monitor"
REPORT_DIR="reports/auto-monitor"

mkdir -p "$LOG_DIR" "$REPORT_DIR"

echo -e "${BLUE}🤖 ImagentX 自动化性能监控${NC}"
echo "监控间隔: ${MONITOR_INTERVAL}秒"
echo "慢查询阈值: ${SLOW_QUERY_THRESHOLD}ms"
echo "开始时间: $(date)"
echo ""

# 记录日志
log_message() {
    local level=$1
    local message=$2
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local log_file="$LOG_DIR/auto-monitor-$(date +%Y%m%d).log"
    echo "[$timestamp] [$level] $message" | tee -a "$log_file"
}

# 检查服务状态
check_services() {
    echo -e "${BLUE}🔍 检查服务状态...${NC}"
    
    # 检查数据库连接
    if PGPASSWORD=imagentx_pass psql -h localhost -U imagentx_user -d imagentx -c "SELECT 1;" >/dev/null 2>&1; then
        echo -e "${GREEN}✅ 数据库连接正常${NC}"
        log_message "INFO" "数据库连接正常"
    else
        echo -e "${RED}❌ 数据库连接异常${NC}"
        log_message "ERROR" "数据库连接异常"
        return 1
    fi
    
    # 检查后端服务
    if curl -s http://localhost:8088/api/health >/dev/null 2>&1; then
        echo -e "${GREEN}✅ 后端服务正常${NC}"
        log_message "INFO" "后端服务正常"
    else
        echo -e "${RED}❌ 后端服务异常${NC}"
        log_message "ERROR" "后端服务异常"
        return 1
    fi
    
    echo ""
}

# 执行性能测试
run_performance_test() {
    echo -e "${BLUE}🧪 执行性能测试...${NC}"
    
    # 运行性能测试脚本
    if [ -f "scripts/performance/test-database-performance.sh" ]; then
        ./scripts/performance/test-database-performance.sh > "$REPORT_DIR/performance-test-$(date +%Y%m%d_%H%M%S).txt" 2>&1
        echo -e "${GREEN}✅ 性能测试完成${NC}"
        log_message "INFO" "性能测试完成"
    else
        echo -e "${YELLOW}⚠️  性能测试脚本不存在${NC}"
        log_message "WARN" "性能测试脚本不存在"
    fi
    
    echo ""
}

# 执行慢查询监控
run_slow_query_monitor() {
    echo -e "${BLUE}🐌 执行慢查询监控...${NC}"
    
    # 运行慢查询监控脚本
    if [ -f "scripts/performance/monitor-slow-queries.sh" ]; then
        ./scripts/performance/monitor-slow-queries.sh > "$REPORT_DIR/slow-query-monitor-$(date +%Y%m%d_%H%M%S).txt" 2>&1
        echo -e "${GREEN}✅ 慢查询监控完成${NC}"
        log_message "INFO" "慢查询监控完成"
    else
        echo -e "${YELLOW}⚠️  慢查询监控脚本不存在${NC}"
        log_message "WARN" "慢查询监控脚本不存在"
    fi
    
    echo ""
}

# 生成监控报告
generate_monitoring_report() {
    echo -e "${BLUE}📊 生成监控报告...${NC}"
    
    local report_file="$REPORT_DIR/monitoring-report-$(date +%Y%m%d_%H%M%S).txt"
    
    {
        echo "ImagentX 自动化性能监控报告"
        echo "生成时间: $(date)"
        echo "监控间隔: ${MONITOR_INTERVAL}秒"
        echo "=================================="
        echo ""
        
        echo "服务状态:"
        echo "- 数据库: $(PGPASSWORD=imagentx_pass psql -h localhost -U imagentx_user -d imagentx -c "SELECT 1;" >/dev/null 2>&1 && echo "正常" || echo "异常")"
        echo "- 后端服务: $(curl -s http://localhost:8088/api/health >/dev/null 2>&1 && echo "正常" || echo "异常")"
        echo ""
        
        echo "数据库性能指标:"
        PGPASSWORD=imagentx_pass psql -h localhost -U imagentx_user -d imagentx -c "
            SELECT 
                count(*) as total_connections,
                count(*) FILTER (WHERE state = 'active') as active_connections,
                count(*) FILTER (WHERE state = 'idle') as idle_connections
            FROM pg_stat_activity;
        "
        echo ""
        
        echo "缓存命中率:"
        PGPASSWORD=imagentx_pass psql -h localhost -U imagentx_user -d imagentx -c "
            SELECT 
                round(100.0 * sum(heap_blks_hit) / (sum(heap_blks_hit) + sum(heap_blks_read)), 2) as cache_hit_ratio
            FROM pg_statio_user_tables;
        "
        echo ""
        
        echo "索引使用情况:"
        PGPASSWORD=imagentx_pass psql -h localhost -U imagentx_user -d imagentx -c "
            SELECT 
                schemaname,
                relname as tablename,
                indexrelname as indexname,
                idx_scan
            FROM pg_stat_user_indexes 
            WHERE idx_scan > 0
            ORDER BY idx_scan DESC
            LIMIT 10;
        "
        
    } > "$report_file"
    
    echo -e "${GREEN}✅ 监控报告已生成: $report_file${NC}"
    log_message "INFO" "监控报告已生成: $report_file"
    echo ""
}

# 清理旧报告
cleanup_old_reports() {
    echo -e "${BLUE}🧹 清理旧报告...${NC}"
    
    # 保留7天的报告
    find "$REPORT_DIR" -name "*.txt" -mtime +7 -delete 2>/dev/null || true
    find "$LOG_DIR" -name "*.log" -mtime +7 -delete 2>/dev/null || true
    
    echo -e "${GREEN}✅ 旧报告清理完成${NC}"
    echo ""
}

# 主监控循环
main_monitor_loop() {
    echo -e "${BLUE}🔄 开始自动化监控循环...${NC}"
    echo "按 Ctrl+C 停止监控"
    echo ""
    
    local iteration=1
    
    while true; do
        echo "=================================="
        echo "监控轮次: $iteration"
        echo "时间: $(date)"
        echo "=================================="
        
        # 检查服务状态
        if check_services; then
            # 执行性能测试
            run_performance_test
            
            # 执行慢查询监控
            run_slow_query_monitor
            
            # 生成监控报告
            generate_monitoring_report
            
            # 清理旧报告
            cleanup_old_reports
            
            echo -e "${GREEN}✅ 第 $iteration 轮监控完成${NC}"
            log_message "INFO" "第 $iteration 轮监控完成"
        else
            echo -e "${RED}❌ 第 $iteration 轮监控失败，服务异常${NC}"
            log_message "ERROR" "第 $iteration 轮监控失败，服务异常"
        fi
        
        echo "=================================="
        echo ""
        
        # 等待下次监控
        echo -e "${BLUE}⏰ 等待 ${MONITOR_INTERVAL} 秒后进行下一轮监控...${NC}"
        echo ""
        
        sleep "$MONITOR_INTERVAL"
        ((iteration++))
    done
}

# 显示帮助信息
show_help() {
    echo "ImagentX 自动化性能监控工具"
    echo ""
    echo "用法: $0 [选项]"
    echo ""
    echo "选项:"
    echo "  -h, --help              显示帮助信息"
    echo "  -i, --interval SECONDS  设置监控间隔（默认3600秒）"
    echo "  -t, --threshold MS      设置慢查询阈值（默认1000ms）"
    echo "  -s, --single            执行单次监控"
    echo ""
    echo "环境变量:"
    echo "  MONITOR_INTERVAL        监控间隔（秒）"
    echo "  SLOW_QUERY_THRESHOLD    慢查询阈值（毫秒）"
    echo ""
    echo "示例:"
    echo "  $0 -i 1800             每30分钟监控一次"
    echo "  $0 -t 500              慢查询阈值500ms"
    echo "  $0 -s                  执行单次监控"
}

# 主函数
main() {
    # 解析命令行参数
    SINGLE_MODE=false
    
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
            -t|--threshold)
                SLOW_QUERY_THRESHOLD="$2"
                shift 2
                ;;
            -s|--single)
                SINGLE_MODE=true
                shift
                ;;
            *)
                echo "未知选项: $1"
                show_help
                exit 1
                ;;
        esac
    done
    
    echo -e "${BLUE}🎯 ImagentX 自动化性能监控${NC}"
    echo ""
    
    # 检查服务状态
    if ! check_services; then
        echo -e "${RED}❌ 服务检查失败，无法启动监控${NC}"
        exit 1
    fi
    
    # 根据参数执行相应操作
    if [ "$SINGLE_MODE" = true ]; then
        echo -e "${BLUE}📊 执行单次监控...${NC}"
        echo ""
        
        run_performance_test
        run_slow_query_monitor
        generate_monitoring_report
        cleanup_old_reports
        
        echo -e "${GREEN}🎉 单次监控完成${NC}"
    else
        # 启动自动化监控循环
        main_monitor_loop
    fi
}

# 执行主函数
main "$@"
