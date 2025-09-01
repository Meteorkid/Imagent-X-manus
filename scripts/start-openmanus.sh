#!/bin/bash

# OpenManus 启动脚本
# 用于启动和管理 OpenManus 服务

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 日志函数
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查 OpenManus 目录
check_openmanus() {
    if [ ! -d "OpenManus" ]; then
        log_error "OpenManus 目录不存在"
        exit 1
    fi
    
    if [ ! -f "OpenManus/main.py" ]; then
        log_error "OpenManus main.py 文件不存在"
        exit 1
    fi
}

# 检查 Python 环境
check_python() {
    if ! command -v python3 &> /dev/null; then
        log_error "Python3 未安装"
        exit 1
    fi
    
    python_version=$(python3 --version 2>&1 | grep -oE '[0-9]+\.[0-9]+' | head -1)
    required_version="3.12"
    
    if [ "$(printf '%s\n' "$required_version" "$python_version" | sort -V | head -n1)" != "$required_version" ]; then
        log_warning "Python 版本过低，建议使用 Python 3.12 或更高版本，当前版本: $python_version"
    fi
}

# 激活虚拟环境
activate_venv() {
    if [ -d "OpenManus/.venv" ]; then
        log_info "激活虚拟环境..."
        source OpenManus/.venv/bin/activate
    else
        log_warning "虚拟环境不存在，使用系统 Python"
    fi
}

# 启动 OpenManus 服务
start_openmanus() {
    log_info "启动 OpenManus 服务..."
    
    cd OpenManus
    
    # 检查配置文件
    if [ ! -f "config/config.toml" ]; then
        log_warning "配置文件不存在，请先运行 setup-openmanus.sh"
        exit 1
    fi
    
    # 启动服务
    log_info "运行 OpenManus..."
    python main.py
    
    cd ..
}

# 启动 MCP 服务
start_mcp() {
    log_info "启动 OpenManus MCP 服务..."
    
    cd OpenManus
    
    # 检查配置文件
    if [ ! -f "config/config.toml" ]; then
        log_warning "配置文件不存在，请先运行 setup-openmanus.sh"
        exit 1
    fi
    
    # 启动 MCP 服务
    log_info "运行 OpenManus MCP..."
    python run_mcp.py
    
    cd ..
}

# 启动多智能体服务
start_flow() {
    log_info "启动 OpenManus 多智能体服务..."
    
    cd OpenManus
    
    # 检查配置文件
    if [ ! -f "config/config.toml" ]; then
        log_warning "配置文件不存在，请先运行 setup-openmanus.sh"
        exit 1
    fi
    
    # 启动多智能体服务
    log_info "运行 OpenManus Flow..."
    python run_flow.py
    
    cd ..
}

# 显示帮助信息
show_help() {
    echo "OpenManus 启动脚本"
    echo ""
    echo "用法: $0 [选项]"
    echo ""
    echo "选项:"
    echo "  start     启动标准 OpenManus 服务"
    echo "  mcp       启动 MCP 服务"
    echo "  flow      启动多智能体服务"
    echo "  check     检查环境"
    echo "  help      显示此帮助信息"
    echo ""
    echo "示例:"
    echo "  $0 start    # 启动标准服务"
    echo "  $0 mcp      # 启动 MCP 服务"
    echo "  $0 flow     # 启动多智能体服务"
}

# 检查环境
check_environment() {
    log_info "检查 OpenManus 环境..."
    
    check_openmanus
    check_python
    
    log_success "环境检查完成"
}

# 主函数
main() {
    case "${1:-start}" in
        "start")
            check_openmanus
            check_python
            activate_venv
            start_openmanus
            ;;
        "mcp")
            check_openmanus
            check_python
            activate_venv
            start_mcp
            ;;
        "flow")
            check_openmanus
            check_python
            activate_venv
            start_flow
            ;;
        "check")
            check_environment
            ;;
        "help"|"-h"|"--help")
            show_help
            ;;
        *)
            log_error "未知选项: $1"
            show_help
            exit 1
            ;;
    esac
}

# 运行主函数
main "$@"

