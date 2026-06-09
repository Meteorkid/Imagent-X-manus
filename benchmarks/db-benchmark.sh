#!/bin/bash

# 数据库性能基准测试脚本

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 日志函数
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 配置
DB_HOST="${DB_HOST:-localhost}"
DB_PORT="${DB_PORT:-5432}"
DB_NAME="${DB_NAME:-imagentx}"
DB_USER="${DB_USER:-imagentx_user}"
SCALE_FACTOR="${SCALE_FACTOR:-10}"
CLIENTS="${CLIENTS:-10}"
THREADS="${THREADS:-2}"
DURATION="${DURATION:-60}"
REPORT_DIR="reports/$(date +%Y%m%d_%H%M%S)"

# 创建报告目录
mkdir -p "$REPORT_DIR"

echo -e "${BLUE}📊 数据库性能基准测试${NC}"
echo "=================================="
echo "数据库: $DB_HOST:$DB_PORT/$DB_NAME"
echo "规模因子: $SCALE_FACTOR"
echo "客户端数: $CLIENTS"
echo "线程数: $THREADS"
echo "测试时长: ${DURATION}s"
echo "报告目录: $REPORT_DIR"
echo ""

# 检查 pgbench 是否可用
if ! command -v pgbench &> /dev/null; then
    log_error "pgbench 命令不存在，请安装 PostgreSQL 客户端工具"
    exit 1
fi

# 测试 1: 初始化测试数据
log_info "测试 1: 初始化测试数据"
PGPASSWORD=$DB_PASSWORD pgbench -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -i -s $SCALE_FACTOR > "$REPORT_DIR/init.txt" 2>&1
log_info "初始化完成"

# 测试 2: 只读测试
log_info "测试 2: 只读性能测试"
PGPASSWORD=$DB_PASSWORD pgbench -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME \
    -c $CLIENTS -j $THREADS -T $DURATION -S \
    > "$REPORT_DIR/read-only.txt" 2>&1
log_info "只读测试完成"

# 测试 3: 读写测试
log_info "测试 3: 读写性能测试"
PGPASSWORD=$DB_PASSWORD pgbench -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME \
    -c $CLIENTS -j $THREADS -T $DURATION \
    > "$REPORT_DIR/read-write.txt" 2>&1
log_info "读写测试完成"

# 测试 4: 自定义查询测试
log_info "测试 4: 自定义查询性能测试"
cat > "$REPORT_DIR/custom.sql" << 'EOF'
-- 插入测试
INSERT INTO test_table (name, value) VALUES ('test', random() * 1000);

-- 查询测试
SELECT * FROM test_table WHERE id = (SELECT MAX(id) FROM test_table);

-- 更新测试
UPDATE test_table SET value = value + 1 WHERE id = (SELECT MAX(id) FROM test_table);

-- 删除测试
DELETE FROM test_table WHERE id = (SELECT MAX(id) FROM test_table);
EOF

PGPASSWORD=$DB_PASSWORD pgbench -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME \
    -c $CLIENTS -j $THREADS -T $DURATION -f "$REPORT_DIR/custom.sql" \
    > "$REPORT_DIR/custom-query.txt" 2>&1
log_info "自定义查询测试完成"

# 测试 5: 连接池测试
log_info "测试 5: 连接池性能测试"
for i in {1..100}; do
    PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -c "SELECT 1" > /dev/null 2>&1 &
done
wait
log_info "连接池测试完成"

# 生成测试报告
log_info "生成测试报告..."
cat > "$REPORT_DIR/summary.txt" << EOF
数据库性能基准测试报告
==================================
测试时间: $(date)
数据库: $DB_HOST:$DB_PORT/$DB_NAME
规模因子: $SCALE_FACTOR
客户端数: $CLIENTS
线程数: $THREADS
测试时长: ${DURATION}s

测试结果:
EOF

# 提取关键指标
if [ -f "$REPORT_DIR/read-only.txt" ]; then
    echo "" >> "$REPORT_DIR/summary.txt"
    echo "只读性能:" >> "$REPORT_DIR/summary.txt"
    grep "tps" "$REPORT_DIR/read-only.txt" >> "$REPORT_DIR/summary.txt" 2>/dev/null || true
fi

if [ -f "$REPORT_DIR/read-write.txt" ]; then
    echo "" >> "$REPORT_DIR/summary.txt"
    echo "读写性能:" >> "$REPORT_DIR/summary.txt"
    grep "tps" "$REPORT_DIR/read-write.txt" >> "$REPORT_DIR/summary.txt" 2>/dev/null || true
fi

log_info "测试完成！报告保存在: $REPORT_DIR"
echo ""
echo -e "${GREEN}✅ 测试完成！${NC}"
