#!/bin/bash

# 安全扫描脚本
# 用于本地安全扫描和检查

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

echo -e "${BLUE}🔒 安全扫描${NC}"
echo "=================================="

# 创建报告目录
REPORT_DIR="$PROJECT_ROOT/reports/security/$(date +%Y%m%d_%H%M%S)"
mkdir -p "$REPORT_DIR"

# 1. 检查敏感信息泄露
log_info "检查敏感信息泄露..."
if grep -r "password\|secret\|token\|api_key" "$PROJECT_ROOT" --include="*.java" --include="*.yml" --include="*.properties" | grep -v "test" | grep -v ".env.example" > "$REPORT_DIR/secrets-check.txt" 2>&1; then
    log_warn "发现潜在的敏感信息，请检查报告"
else
    log_info "未发现敏感信息泄露"
fi

# 2. 检查硬编码密码
log_info "检查硬编码密码..."
if grep -r "password\s*=\s*[" "$PROJECT_ROOT/apps/backend/src" --include="*.yml" --include="*.properties" | grep -v "\${" > "$REPORT_DIR/hardcoded-passwords.txt" 2>&1; then
    log_warn "发现硬编码密码，请检查报告"
else
    log_info "未发现硬编码密码"
fi

# 3. 检查 SQL 注入风险
log_info "检查 SQL 注入风险..."
if grep -r "createQuery\|createSQLQuery\|nativeQuery" "$PROJECT_ROOT/apps/backend/src" --include="*.java" > "$REPORT_DIR/sql-injection.txt" 2>&1; then
    log_warn "发现潜在的 SQL 注入风险，请检查报告"
else
    log_info "未发现 SQL 注入风险"
fi

# 4. 检查 XSS 风险
log_info "检查 XSS 风险..."
if grep -r "innerHTML\|dangerouslySetInnerHTML" "$PROJECT_ROOT/apps/frontend" --include="*.tsx" --include="*.jsx" > "$REPORT_DIR/xss-risk.txt" 2>&1; then
    log_warn "发现潜在的 XSS 风险，请检查报告"
else
    log_info "未发现 XSS 风险"
fi

# 5. 检查命令注入风险
log_info "检查命令注入风险..."
if grep -r "shell=True\|subprocess.run.*shell" "$PROJECT_ROOT" --include="*.py" > "$REPORT_DIR/command-injection.txt" 2>&1; then
    log_warn "发现潜在的命令注入风险，请检查报告"
else
    log_info "未发现命令注入风险"
fi

# 6. 检查依赖漏洞
log_info "检查依赖漏洞..."
if command -v trivy &> /dev/null; then
    trivy fs --severity HIGH,CRITICAL "$PROJECT_ROOT" > "$REPORT_DIR/dependency-vulnerabilities.txt" 2>&1 || true
    log_info "依赖漏洞检查完成"
else
    log_warn "trivy 未安装，跳过依赖漏洞检查"
fi

# 生成扫描报告
log_info "生成扫描报告..."
cat > "$REPORT_DIR/summary.txt" << EOF
安全扫描报告
==================================
扫描时间: $(date)
项目路径: $PROJECT_ROOT

检查项目:
1. 敏感信息泄露
2. 硬编码密码
3. SQL 注入风险
4. XSS 风险
5. 命令注入风险
6. 依赖漏洞

详细报告请查看各检查项的输出文件。
EOF

log_info "扫描完成！报告保存在: $REPORT_DIR"
echo ""
echo -e "${GREEN}✅ 安全扫描完成！${NC}"
