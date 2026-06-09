#!/bin/bash

# 前端性能基准测试脚本

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
FRONTEND_URL="${FRONTEND_URL:-http://localhost:3000}"
REPORT_DIR="reports/$(date +%Y%m%d_%H%M%S)"

# 创建报告目录
mkdir -p "$REPORT_DIR"

echo -e "${BLUE}📊 前端性能基准测试${NC}"
echo "=================================="
echo "前端地址: $FRONTEND_URL"
echo "报告目录: $REPORT_DIR"
echo ""

# 测试 1: Lighthouse 测试
log_info "测试 1: Lighthouse 性能测试"
if command -v lighthouse &> /dev/null; then
    lighthouse "$FRONTEND_URL" \
        --output=html \
        --output-path="$REPORT_DIR/lighthouse.html" \
        --chrome-flags="--headless" \
        --only-categories=performance \
        > "$REPORT_DIR/lighthouse.txt" 2>&1
    log_info "Lighthouse 测试完成"
else
    log_warn "lighthouse 命令不存在，跳过测试"
fi

# 测试 2: 页面加载时间测试
log_info "测试 2: 页面加载时间测试"
if command -v curl &> /dev/null; then
    # 首字节时间 (TTFB)
    curl -o /dev/null -s -w "TTFB: %{time_starttransfer}s\nTotal: %{time_total}s\n" \
        "$FRONTEND_URL" > "$REPORT_DIR/page-load.txt" 2>&1
    log_info "页面加载时间测试完成"
fi

# 测试 3: 资源加载测试
log_info "测试 3: 资源加载测试"
if command -v curl &> /dev/null; then
    # 测试静态资源
    for resource in "/favicon.ico" "/logo.svg"; do
        curl -o /dev/null -s -w "Resource: $resource - Time: %{time_total}s\n" \
            "$FRONTEND_URL$resource" >> "$REPORT_DIR/resource-load.txt" 2>&1 || true
    done
    log_info "资源加载测试完成"
fi

# 测试 4: 并发测试
log_info "测试 4: 并发性能测试"
if command -v ab &> /dev/null; then
    ab -n 100 -c 10 "$FRONTEND_URL" > "$REPORT_DIR/concurrency.txt" 2>&1
    log_info "并发性能测试完成"
fi

# 测试 5: 响应时间测试
log_info "测试 5: 响应时间测试"
if command -v curl &> /dev/null; then
    for i in {1..10}; do
        curl -o /dev/null -s -w "Request $i: %{time_total}s\n" \
            "$FRONTEND_URL" >> "$REPORT_DIR/response-time.txt" 2>&1
    done
    log_info "响应时间测试完成"
fi

# 生成测试报告
log_info "生成测试报告..."
cat > "$REPORT_DIR/summary.txt" << EOF
前端性能基准测试报告
==================================
测试时间: $(date)
前端地址: $FRONTEND_URL

测试结果:
EOF

# 提取关键指标
if [ -f "$REPORT_DIR/page-load.txt" ]; then
    echo "" >> "$REPORT_DIR/summary.txt"
    echo "页面加载时间:" >> "$REPORT_DIR/summary.txt"
    cat "$REPORT_DIR/page-load.txt" >> "$REPORT_DIR/summary.txt"
fi

if [ -f "$REPORT_DIR/concurrency.txt" ]; then
    echo "" >> "$REPORT_DIR/summary.txt"
    echo "并发性能:" >> "$REPORT_DIR/summary.txt"
    grep "Requests per second" "$REPORT_DIR/concurrency.txt" >> "$REPORT_DIR/summary.txt" 2>/dev/null || true
fi

log_info "测试完成！报告保存在: $REPORT_DIR"
echo ""
echo -e "${GREEN}✅ 测试完成！${NC}"
