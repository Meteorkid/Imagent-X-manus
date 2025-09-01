#!/bin/bash

# 部署包验证脚本
# 用于验证部署包是否包含所有必要文件

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 部署包文件
DEPLOY_PACKAGE="imagentx-deploy.tar.gz"

# 必需文件列表
REQUIRED_FILES=(
    "docker-compose-production.yml"
    "deploy-production.sh"
    "quick-deploy.sh"
    "env.production.template"
    ".env.production"
    "apps/backend/Dockerfile"
    "apps/frontend/Dockerfile"
    "config/nginx/nginx-production.conf"
    "config/nginx/nginx-local.conf"
    "check-dns.sh"
    "mac-deploy.sh"
    "部署执行详细指南.md"
    "部署检查清单.md"
    "服务器部署完整指南.md"
    "Mac环境完整部署指南.md"
    "阿里云DNS配置指南.md"
)

# 必需目录列表
REQUIRED_DIRS=(
    "apps/backend"
    "apps/frontend"
    "config"
    "scripts"
    "docs"
    "tools"
)

# 显示帮助信息
show_help() {
    echo -e "${BLUE}🔍 部署包验证脚本${NC}"
    echo "================================"
    echo -e "${GREEN}用法: ./verify-deploy-package.sh [选项]${NC}"
    echo ""
    echo -e "${CYAN}验证选项:${NC}"
    echo -e "  ${GREEN}--verify${NC}       验证部署包完整性"
    echo -e "  ${GREEN}--list${NC}         列出部署包内容"
    echo -e "  ${GREEN}--size${NC}         显示部署包大小"
    echo -e "  ${GREEN}--help${NC}         显示此帮助信息"
    echo ""
    echo -e "${CYAN}示例:${NC}"
    echo -e "  ./verify-deploy-package.sh --verify  # 验证部署包"
    echo -e "  ./verify-deploy-package.sh --list    # 列出内容"
    echo ""
}

# 检查部署包是否存在
check_package_exists() {
    if [ ! -f "$DEPLOY_PACKAGE" ]; then
        echo -e "${RED}❌ 部署包不存在: $DEPLOY_PACKAGE${NC}"
        exit 1
    fi
    echo -e "${GREEN}✅ 部署包存在: $DEPLOY_PACKAGE${NC}"
}

# 显示部署包大小
show_package_size() {
    echo -e "${BLUE}📦 部署包信息${NC}"
    echo "--------------------------------"
    
    check_package_exists
    
    # 获取文件大小
    SIZE=$(du -h "$DEPLOY_PACKAGE" | cut -f1)
    echo -e "${CYAN}文件大小:${NC} $SIZE"
    
    # 获取创建时间
    CREATED=$(stat -f "%Sm" "$DEPLOY_PACKAGE" 2>/dev/null || stat -c "%y" "$DEPLOY_PACKAGE" 2>/dev/null)
    echo -e "${CYAN}创建时间:${NC} $CREATED"
    
    # 获取文件数量
    FILE_COUNT=$(tar -tzf "$DEPLOY_PACKAGE" | wc -l)
    echo -e "${CYAN}文件数量:${NC} $FILE_COUNT"
}

# 列出部署包内容
list_package_contents() {
    echo -e "${BLUE}📋 部署包内容${NC}"
    echo "--------------------------------"
    
    check_package_exists
    
    echo -e "${CYAN}主要文件和目录:${NC}"
    tar -tzf "$DEPLOY_PACKAGE" | grep -E "^\./[^/]+$" | head -10
    
    echo -e "${CYAN}应用代码:${NC}"
    tar -tzf "$DEPLOY_PACKAGE" | grep "^\./apps/" | head -5
    
    echo -e "${CYAN}配置文件:${NC}"
    tar -tzf "$DEPLOY_PACKAGE" | grep "^\./config/" | head -5
    
    echo -e "${CYAN}部署脚本:${NC}"
    tar -tzf "$DEPLOY_PACKAGE" | grep "\.sh$" | head -5
    
    echo -e "${CYAN}文档文件:${NC}"
    tar -tzf "$DEPLOY_PACKAGE" | grep "\.md$" | head -5
}

# 验证必需文件
verify_required_files() {
    echo -e "${BLUE}🔍 验证必需文件${NC}"
    echo "--------------------------------"
    
    local missing_files=()
    local found_files=()
    
    for file in "${REQUIRED_FILES[@]}"; do
        if tar -tzf "$DEPLOY_PACKAGE" | grep -q "^\./$file$"; then
            echo -e "${GREEN}✅ $file${NC}"
            found_files+=("$file")
        else
            echo -e "${RED}❌ $file${NC}"
            missing_files+=("$file")
        fi
    done
    
    echo ""
    echo -e "${CYAN}验证结果:${NC}"
    echo -e "${GREEN}找到文件: ${#found_files[@]}/${#REQUIRED_FILES[@]}${NC}"
    
    if [ ${#missing_files[@]} -eq 0 ]; then
        echo -e "${GREEN}✅ 所有必需文件都已找到${NC}"
        return 0
    else
        echo -e "${RED}❌ 缺少文件:${NC}"
        for file in "${missing_files[@]}"; do
            echo -e "${RED}  - $file${NC}"
        done
        return 1
    fi
}

# 验证必需目录
verify_required_dirs() {
    echo -e "${BLUE}📁 验证必需目录${NC}"
    echo "--------------------------------"
    
    local missing_dirs=()
    local found_dirs=()
    
    for dir in "${REQUIRED_DIRS[@]}"; do
        if tar -tzf "$DEPLOY_PACKAGE" | grep -q "^\./$dir/"; then
            echo -e "${GREEN}✅ $dir/${NC}"
            found_dirs+=("$dir")
        else
            echo -e "${RED}❌ $dir/${NC}"
            missing_dirs+=("$dir")
        fi
    done
    
    echo ""
    echo -e "${CYAN}验证结果:${NC}"
    echo -e "${GREEN}找到目录: ${#found_dirs[@]}/${#REQUIRED_DIRS[@]}${NC}"
    
    if [ ${#missing_dirs[@]} -eq 0 ]; then
        echo -e "${GREEN}✅ 所有必需目录都已找到${NC}"
        return 0
    else
        echo -e "${RED}❌ 缺少目录:${NC}"
        for dir in "${missing_dirs[@]}"; do
            echo -e "${RED}  - $dir/${NC}"
        done
        return 1
    fi
}

# 验证文件完整性
verify_file_integrity() {
    echo -e "${BLUE}🔧 验证文件完整性${NC}"
    echo "--------------------------------"
    
    # 测试tar文件完整性
    if tar -tzf "$DEPLOY_PACKAGE" >/dev/null 2>&1; then
        echo -e "${GREEN}✅ 部署包完整性检查通过${NC}"
    else
        echo -e "${RED}❌ 部署包损坏或格式错误${NC}"
        return 1
    fi
    
    # 检查是否有可执行脚本
    local script_count=$(tar -tzf "$DEPLOY_PACKAGE" | grep "\.sh$" | wc -l)
    echo -e "${CYAN}部署脚本数量:${NC} $script_count"
    
    # 检查是否有Docker文件
    local docker_count=$(tar -tzf "$DEPLOY_PACKAGE" | grep -E "(Dockerfile|docker-compose)" | wc -l)
    echo -e "${CYAN}Docker文件数量:${NC} $docker_count"
    
    # 检查是否有配置文件
    local config_count=$(tar -tzf "$DEPLOY_PACKAGE" | grep -E "\.(yml|yaml|conf|env)" | wc -l)
    echo -e "${CYAN}配置文件数量:${NC} $config_count"
}

# 生成部署包报告
generate_report() {
    echo -e "${BLUE}📊 部署包验证报告${NC}"
    echo "=================================="
    
    show_package_size
    echo ""
    
    verify_file_integrity
    echo ""
    
    verify_required_files
    echo ""
    
    verify_required_dirs
    echo ""
    
    # 总结
    echo -e "${BLUE}📋 验证总结${NC}"
    echo "--------------------------------"
    
    local total_files=${#REQUIRED_FILES[@]}
    local total_dirs=${#REQUIRED_DIRS[@]}
    local missing_files_count=$(verify_required_files >/dev/null 2>&1; echo $?)
    local missing_dirs_count=$(verify_required_dirs >/dev/null 2>&1; echo $?)
    
    if [ $missing_files_count -eq 0 ] && [ $missing_dirs_count -eq 0 ]; then
        echo -e "${GREEN}🎉 部署包验证通过！${NC}"
        echo -e "${GREEN}✅ 所有必需文件和目录都已包含${NC}"
        echo -e "${GREEN}✅ 部署包完整性良好${NC}"
        echo -e "${GREEN}✅ 可以安全部署到生产环境${NC}"
        return 0
    else
        echo -e "${RED}❌ 部署包验证失败！${NC}"
        echo -e "${RED}❌ 缺少必需文件或目录${NC}"
        echo -e "${YELLOW}⚠️  请检查部署包内容${NC}"
        return 1
    fi
}

# 主函数
main() {
    case "${1:-}" in
        --verify)
            generate_report
            ;;
        --list)
            list_package_contents
            ;;
        --size)
            show_package_size
            ;;
        --help|*)
            show_help
            ;;
    esac
}

# 运行主函数
main "$@"
