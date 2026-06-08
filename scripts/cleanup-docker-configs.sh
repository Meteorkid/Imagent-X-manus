#!/bin/bash

# 清理重复的 Docker 配置文件
# 保留核心配置，删除重复和过时的配置

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

echo -e "${BLUE}🐳 清理重复的 Docker 配置文件${NC}"
echo "=================================="

# 备份目录
BACKUP_DIR="$PROJECT_ROOT/scripts/backup/docker-configs/$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

# 要保留的核心配置文件
CORE_CONFIGS=(
    "docker-compose.imagent.top.yml"
    "docker-compose.imagentx.top.yml"
    "docker-compose.imagent.top.cloudflare.yml"
    "config/docker/docker-compose-local-dev.yml"
    "config/docker/docker-compose-simple.yml"
    "config/docker/docker-compose-minimal.yml"
    "config/docker/docker-compose-production.yml"
    "config/docker/docker-compose-optimized.yml"
    "config/monitoring/docker-compose.monitoring.yml"
    "mcp-config/docker-compose.mcp.yml"
    "mcp-config/docker-compose.sandbox.yml"
    "production/docker-compose.yml"
)

# 要删除的重复配置文件
DEPRECATED_CONFIGS=(
    "config/docker/docker-compose-agentx.yml"
    "config/docker/docker-compose-basic.yml"
    "config/docker/docker-compose-fixed.yml"
    "config/docker/docker-compose-frontend-only.yml"
    "config/docker/docker-compose-imagentx.yml"
    "config/docker/docker-compose-internal-db.yml"
    "config/docker/docker-compose-local.yml"
    "config/docker/docker-compose-local-production.yml"
    "config/docker/docker-compose-network.yml"
    "config/docker/docker-compose-openmanus.yml"
    "config/docker/docker-compose-production-optimized.yml"
    "config/docker/docker-compose.mac.yml"
    "config/docker/docker-compose.mac.fixed.yml"
    "config/docker/docker-compose.optimized.yml"
    "config/docker/docker-compose.simple.yml"
    "config/docker/docker-compose.test.yml"
    "config/cache/docker-compose.redis.yml"
    "scripts/deployment/docker-compose.yml"
)

# 检查并删除重复的配置文件
log_info "检查重复的配置文件..."
for config in "${DEPRECATED_CONFIGS[@]}"; do
    if [ -f "$PROJECT_ROOT/$config" ]; then
        log_warn "删除重复配置: $config"
        mkdir -p "$BACKUP_DIR/$(dirname "$config")"
        mv "$PROJECT_ROOT/$config" "$BACKUP_DIR/$config" 2>/dev/null || true
    fi
done

# 统计清理结果
log_info "清理完成！"
echo "=================================="
echo "备份目录: $BACKUP_DIR"
echo "清理的配置文件数量: $(find "$BACKUP_DIR" -name "docker-compose*.yml" -type f | wc -l)"

# 显示保留的核心配置
log_info "保留的核心配置文件:"
echo "  - 根目录:"
echo "    - docker-compose.imagent.top.yml (主配置)"
echo "    - docker-compose.imagentx.top.yml (备用配置)"
echo "    - docker-compose.imagent.top.cloudflare.yml (Cloudflare 配置)"
echo "  - config/docker/:"
echo "    - docker-compose-local-dev.yml (本地开发)"
echo "    - docker-compose-simple.yml (简化配置)"
echo "    - docker-compose-minimal.yml (最小配置)"
echo "    - docker-compose-production.yml (生产配置)"
echo "    - docker-compose-optimized.yml (优化配置)"
echo "  - config/monitoring/:"
echo "    - docker-compose.monitoring.yml (监控配置)"
echo "  - mcp-config/:"
echo "    - docker-compose.mcp.yml (MCP 配置)"
echo "    - docker-compose.sandbox.yml (沙箱配置)"
echo "  - production/:"
echo "    - docker-compose.yml (生产环境)"

echo ""
echo -e "${GREEN}✅ 清理完成！备份保存在: $BACKUP_DIR${NC}"
