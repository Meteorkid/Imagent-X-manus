#!/bin/bash

# API 性能基准测试脚本

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
API_BASE_URL="${API_BASE_URL:-http://localhost:8088}"
REQUESTS="${REQUESTS:-1000}"
CONCURRENCY="${CONCURRENCY:-10}"
REPORT_DIR="reports/$(date +%Y%m%d_%H%M%S)"

# 创建报告目录
mkdir -p "$REPORT_DIR"

echo -e "${BLUE}📊 API 性能基准测试${NC}"
echo "=================================="
echo "API 地址: $API_BASE_URL"
echo "请求数: $REQUESTS"
echo "并发数: $CONCURRENCY"
echo "报告目录: $REPORT_DIR"
echo ""

# 测试 1: 健康检查接口
log_info "测试 1: 健康检查接口"
if command -v ab &> /dev/null; then
    ab -n $REQUESTS -c $CONCURRENCY "$API_BASE_URL/api/health" > "$REPORT_DIR/health-check.txt" 2>&1
    log_info "健康检查测试完成"
else
    log_warn "ab 命令不存在，跳过测试"
fi

# 测试 2: 插件列表接口
log_info "测试 2: 插件列表接口"
if command -v ab &> /dev/null; then
    ab -n $REQUESTS -c $CONCURRENCY "$API_BASE_URL/api/plugins" > "$REPORT_DIR/plugin-list.txt" 2>&1
    log_info "插件列表测试完成"
fi

# 测试 3: 工作流列表接口
log_info "测试 3: 工作流列表接口"
if command -v ab &> /dev/null; then
    ab -n $REQUESTS -c $CONCURRENCY "$API_BASE_URL/api/workflows" > "$REPORT_DIR/workflow-list.txt" 2>&1
    log_info "工作流列表测试完成"
fi

# 测试 4: 用户列表接口
log_info "测试 4: 用户列表接口"
if command -v ab &> /dev/null; then
    ab -n $REQUESTS -c $CONCURRENCY "$API_BASE_URL/api/users" > "$REPORT_DIR/user-list.txt" 2>&1
    log_info "用户列表测试完成"
fi

# 生成测试报告
log_info "生成测试报告..."
cat > "$REPORT_DIR/summary.txt" << EOF
API 性能基准测试报告
==================================
测试时间: $(date)
API 地址: $API_BASE_URL
请求数: $REQUESTS
并发数: $CONCURRENCY

测试结果:
EOF

# 提取关键指标
if [ -f "$REPORT_DIR/health-check.txt" ]; then
    echo "" >> "$REPORT_DIR/summary.txt"
    echo "健康检查接口:" >> "$REPORT_DIR/summary.txt"
    grep "Requests per second" "$REPORT_DIR/health-check.txt" >> "$REPORT_DIR/summary.txt" 2>/dev/null || true
    grep "Time per request.*mean" "$REPORT_DIR/health-check.txt" >> "$REPORT_DIR/summary.txt" 2>/dev/null || true
fi

log_info "测试完成！报告保存在: $REPORT_DIR"
echo ""
echo -e "${GREEN}✅ 测试完成！${NC}"
