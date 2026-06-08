#!/bin/bash

# 清理废弃的脚本
# 保留核心脚本，删除重复和过时的脚本

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

# 项目根目录
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo -e "${BLUE}🧹 清理废弃的脚本${NC}"
echo "=================================="

# 备份目录
BACKUP_DIR="$PROJECT_ROOT/scripts/backup/$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

# 要删除的重复脚本
DUPLICATE_SCRIPTS=(
    "start-imagentx-complete.sh"
    "start-imagentx-correct.sh"
    "start-imagentx-final.sh"
)

# 要删除的废弃脚本（根据最后修改时间判断）
DEPRECATED_SCRIPTS=()

# 检查并删除重复的根目录脚本
log_info "检查重复的根目录脚本..."
for script in "${DUPLICATE_SCRIPTS[@]}"; do
    if [ -f "$PROJECT_ROOT/$script" ]; then
        log_warn "删除重复脚本: $script"
        mv "$PROJECT_ROOT/$script" "$BACKUP_DIR/" 2>/dev/null || true
    fi
done

# 检查并删除废弃的工具脚本（最后修改时间超过 6 个月）
log_info "检查废弃的工具脚本..."
find "$PROJECT_ROOT/scripts/utils" -name "*.sh" -type f -mtime +180 | while read script; do
    script_name=$(basename "$script")
    log_warn "删除废弃脚本: scripts/utils/$script_name"
    mv "$script" "$BACKUP_DIR/" 2>/dev/null || true
done

# 检查并删除废弃的增强脚本
log_info "检查废弃的增强脚本..."
find "$PROJECT_ROOT/scripts/enhancement" -name "*.sh" -type f -mtime +180 | while read script; do
    script_name=$(basename "$script")
    log_warn "删除废弃脚本: scripts/enhancement/$script_name"
    mv "$script" "$BACKUP_DIR/" 2>/dev/null || true
done

# 检查并删除废弃的性能脚本
log_info "检查废弃的性能脚本..."
find "$PROJECT_ROOT/scripts/performance" -name "*.sh" -type f -mtime +180 | while read script; do
    script_name=$(basename "$script")
    log_warn "删除废弃脚本: scripts/performance/$script_name"
    mv "$script" "$BACKUP_DIR/" 2>/dev/null || true
done

# 检查并删除废弃的测试脚本
log_info "检查废弃的测试脚本..."
find "$PROJECT_ROOT/scripts/testing" -name "*.sh" -type f -mtime +180 | while read script; do
    script_name=$(basename "$script")
    log_warn "删除废弃脚本: scripts/testing/$script_name"
    mv "$script" "$BACKUP_DIR/" 2>/dev/null || true
done

# 统计清理结果
log_info "清理完成！"
echo "=================================="
echo "备份目录: $BACKUP_DIR"
echo "清理的脚本数量: $(find "$BACKUP_DIR" -name "*.sh" -type f | wc -l)"

# 显示保留的核心脚本
log_info "保留的核心脚本:"
echo "  - 根目录:"
echo "    - start-imagentx.sh (主启动脚本)"
echo "    - start-backend.sh"
echo "    - stop-imagentx.sh"
echo "    - init-database.sh"
echo "  - scripts/core/:"
echo "    - start.sh (统一启动脚本)"
echo "    - stop.sh"
echo "    - status.sh"
echo "  - scripts/utils/:"
echo "    - check-services-status.sh"
echo "    - detect-ports.sh"
echo "    - start-mcp-gateway.sh"

echo ""
echo -e "${GREEN}✅ 清理完成！备份保存在: $BACKUP_DIR${NC}"
