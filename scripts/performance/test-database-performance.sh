#!/bin/bash

# ImagentX 数据库性能测试脚本

set -e

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🧪 ImagentX 数据库性能测试${NC}"
echo ""

# 设置环境变量
export PGPASSWORD=imagentx_pass

# 测试1: 基础查询性能
echo -e "${BLUE}📊 测试1: 基础查询性能${NC}"
echo "执行时间: $(date)"
echo ""

# 测试用户表查询
echo "测试用户表查询..."
START_TIME=$(date +%s%N)
PGPASSWORD=imagentx_pass psql -h localhost -U imagentx_user -d imagentx -c "SELECT COUNT(*) FROM users;" >/dev/null 2>&1
END_TIME=$(date +%s%N)
DURATION=$(( (END_TIME - START_TIME) / 1000000 ))
echo "用户表查询耗时: ${DURATION}ms"

# 测试Agent表查询
echo "测试Agent表查询..."
START_TIME=$(date +%s%N)
PGPASSWORD=imagentx_pass psql -h localhost -U imagentx_user -d imagentx -c "SELECT COUNT(*) FROM agents;" >/dev/null 2>&1
END_TIME=$(date +%s%N)
DURATION=$(( (END_TIME - START_TIME) / 1000000 ))
echo "Agent表查询耗时: ${DURATION}ms"

# 测试会话表查询
echo "测试会话表查询..."
START_TIME=$(date +%s%N)
PGPASSWORD=imagentx_pass psql -h localhost -U imagentx_user -d imagentx -c "SELECT COUNT(*) FROM sessions;" >/dev/null 2>&1
END_TIME=$(date +%s%N)
DURATION=$(( (END_TIME - START_TIME) / 1000000 ))
echo "会话表查询耗时: ${DURATION}ms"

echo ""

# 测试2: 索引查询性能
echo -e "${BLUE}🔍 测试2: 索引查询性能${NC}"
echo "执行时间: $(date)"
echo ""

# 测试带索引的查询
echo "测试带索引的用户查询..."
START_TIME=$(date +%s%N)
PGPASSWORD=imagentx_pass psql -h localhost -U imagentx_user -d imagentx -c "SELECT * FROM users WHERE email IS NOT NULL LIMIT 10;" >/dev/null 2>&1
END_TIME=$(date +%s%N)
DURATION=$(( (END_TIME - START_TIME) / 1000000 ))
echo "索引查询耗时: ${DURATION}ms"

# 测试复合索引查询
echo "测试复合索引查询..."
START_TIME=$(date +%s%N)
PGPASSWORD=imagentx_pass psql -h localhost -U imagentx_user -d imagentx -c "SELECT * FROM agents WHERE user_id IS NOT NULL AND enabled = true LIMIT 10;" >/dev/null 2>&1
END_TIME=$(date +%s%N)
DURATION=$(( (END_TIME - START_TIME) / 1000000 ))
echo "复合索引查询耗时: ${DURATION}ms"

echo ""

# 测试3: 连接池性能
echo -e "${BLUE}🔗 测试3: 连接池性能${NC}"
echo "执行时间: $(date)"
echo ""

# 检查当前连接数
echo "当前数据库连接状态:"
PGPASSWORD=imagentx_pass psql -h localhost -U imagentx_user -d imagentx -c "
SELECT 
    count(*) as total_connections,
    count(*) FILTER (WHERE state = 'active') as active_connections,
    count(*) FILTER (WHERE state = 'idle') as idle_connections
FROM pg_stat_activity;
"

echo ""

# 测试4: 并发查询性能
echo -e "${BLUE}⚡ 测试4: 并发查询性能${NC}"
echo "执行时间: $(date)"
echo ""

# 模拟并发查询
echo "启动5个并发查询..."
for i in {1..5}; do
    (
        START_TIME=$(date +%s%N)
        PGPASSWORD=imagentx_pass psql -h localhost -U imagentx_user -d imagentx -c "SELECT COUNT(*) FROM users;" >/dev/null 2>&1
        END_TIME=$(date +%s%N)
        DURATION=$(( (END_TIME - START_TIME) / 1000000 ))
        echo "并发查询 $i 耗时: ${DURATION}ms"
    ) &
done
wait

echo ""

# 测试5: 缓存命中率
echo -e "${BLUE}💾 测试5: 缓存命中率${NC}"
echo "执行时间: $(date)"
echo ""

echo "当前缓存命中率:"
PGPASSWORD=imagentx_pass psql -h localhost -U imagentx_user -d imagentx -c "
SELECT 
    round(100.0 * sum(heap_blks_hit) / (sum(heap_blks_hit) + sum(heap_blks_read)), 2) as cache_hit_ratio
FROM pg_statio_user_tables;
"

echo ""

# 测试6: 慢查询检测
echo -e "${BLUE}🐌 测试6: 慢查询检测${NC}"
echo "执行时间: $(date)"
echo ""

echo "检查慢查询统计:"
PGPASSWORD=imagentx_pass psql -h localhost -U imagentx_user -d imagentx -c "
SELECT 
    query,
    calls,
    total_exec_time,
    mean_exec_time,
    rows
FROM pg_stat_statements 
ORDER BY mean_exec_time DESC
LIMIT 5;
" 2>/dev/null || echo "pg_stat_statements 数据不足，需要更多查询"

echo ""

# 性能测试总结
echo -e "${BLUE}📈 性能测试总结${NC}"
echo "=================================="
echo "✅ 基础查询性能: 已测试"
echo "✅ 索引查询性能: 已测试"
echo "✅ 连接池性能: 已测试"
echo "✅ 并发查询性能: 已测试"
echo "✅ 缓存命中率: 已测试"
echo "✅ 慢查询检测: 已测试"
echo ""
echo -e "${GREEN}🎉 数据库性能测试完成！${NC}"
echo ""
echo -e "${YELLOW}📋 建议：${NC}"
echo "1. 观察查询响应时间是否在预期范围内"
echo "2. 检查连接池使用情况"
echo "3. 监控缓存命中率变化"
echo "4. 分析慢查询日志"
