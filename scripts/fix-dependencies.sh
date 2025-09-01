#!/bin/bash

# ImagentX 依赖冲突解决脚本
# 使用方法: ./fix-dependencies.sh [fix|clean|update|check]

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# 打印带颜色的消息
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_step() {
    echo -e "${PURPLE}[STEP]${NC} $1"
}

# 检查前端目录
check_frontend_dir() {
    if [ ! -d "apps/frontend" ]; then
        print_error "前端目录不存在: apps/frontend"
        exit 1
    fi
    
    if [ ! -f "apps/frontend/package.json" ]; then
        print_error "package.json 不存在"
        exit 1
    fi
}

# 检查依赖冲突
check_conflicts() {
    print_step "检查依赖冲突..."
    
    cd apps/frontend
    
    print_info "检查过时的依赖包..."
    npm outdated || true
    
    print_info "检查依赖冲突..."
    npm ls --depth=0 || true
    
    cd ../..
    
    print_success "依赖检查完成"
}

# 快速修复依赖冲突
fix_dependencies() {
    print_step "快速修复依赖冲突..."
    
    cd apps/frontend
    
    print_info "备份 package-lock.json..."
    if [ -f "package-lock.json" ]; then
        cp package-lock.json package-lock.json.backup
    fi
    
    print_info "清理 node_modules..."
    rm -rf node_modules
    
    print_info "使用 --legacy-peer-deps 安装依赖..."
    npm install --legacy-peer-deps
    
    print_info "验证安装..."
    npm ls --depth=0 || true
    
    cd ../..
    
    print_success "依赖冲突修复完成"
}

# 清理依赖
clean_dependencies() {
    print_step "清理依赖..."
    
    cd apps/frontend
    
    print_info "删除 node_modules 和 package-lock.json..."
    rm -rf node_modules package-lock.json
    
    print_info "清理 npm 缓存..."
    npm cache clean --force
    
    cd ../..
    
    print_success "依赖清理完成"
}

# 更新依赖
update_dependencies() {
    print_step "更新依赖..."
    
    cd apps/frontend
    
    print_info "检查可更新的依赖..."
    npm outdated || true
    
    print_info "更新依赖包..."
    npm update --legacy-peer-deps
    
    print_info "检查安全漏洞..."
    npm audit || true
    
    cd ../..
    
    print_success "依赖更新完成"
}

# 安全修复
security_fix() {
    print_step "安全修复..."
    
    cd apps/frontend
    
    print_info "运行安全修复..."
    npm audit fix --legacy-peer-deps || true
    
    print_info "运行安全修复（可能破坏依赖）..."
    npm audit fix --force || true
    
    cd ../..
    
    print_success "安全修复完成"
}

# 构建测试
build_test() {
    print_step "构建测试..."
    
    cd apps/frontend
    
    print_info "运行构建测试..."
    if npm run build; then
        print_success "构建成功！"
    else
        print_error "构建失败，请检查依赖配置"
        cd ../..
        exit 1
    fi
    
    cd ../..
}

# 显示帮助信息
show_help() {
    echo "ImagentX 依赖冲突解决脚本"
    echo ""
    echo "使用方法:"
    echo "  $0 [命令]"
    echo ""
    echo "命令:"
    echo "  fix        快速修复依赖冲突"
    echo "  clean      清理依赖文件"
    echo "  update     更新依赖包"
    echo "  check      检查依赖状态"
    echo "  security   安全修复"
    echo "  build      构建测试"
    echo "  help       显示此帮助信息"
    echo ""
    echo "示例:"
    echo "  $0 fix      快速修复依赖冲突"
    echo "  $0 check    检查依赖状态"
}

# 主函数
main() {
    local command=$1
    
    case "$command" in
        "fix")
            check_frontend_dir
            fix_dependencies
            build_test
            ;;
        "clean")
            check_frontend_dir
            clean_dependencies
            ;;
        "update")
            check_frontend_dir
            update_dependencies
            ;;
        "check")
            check_frontend_dir
            check_conflicts
            ;;
        "security")
            check_frontend_dir
            security_fix
            ;;
        "build")
            check_frontend_dir
            build_test
            ;;
        "help"|"--help"|"-h")
            show_help
            ;;
        *)
            print_error "未知命令: $command"
            show_help
            exit 1
            ;;
    esac
}

# 执行主函数
main "$@"
