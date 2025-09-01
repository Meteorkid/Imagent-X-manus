#!/bin/bash

# ImagentX 版本管理脚本
# 使用方法: ./version-management.sh [命令] [版本号]

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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

# 检查Git状态
check_git_status() {
    if [ -n "$(git status --porcelain)" ]; then
        print_error "工作目录有未提交的更改，请先提交或暂存更改"
        git status --short
        exit 1
    fi
    
    if [ "$(git branch --show-current)" != "main" ]; then
        print_warning "当前不在main分支，建议在main分支上执行版本发布"
    fi
}

# 更新版本号
update_version() {
    local version=$1
    
    print_info "更新版本号到 $version"
    
    # 更新package.json（如果存在）
    if [ -f "package.json" ]; then
        sed -i.bak "s/\"version\": \".*\"/\"version\": \"$version\"/" package.json
        rm package.json.bak
        print_success "已更新 package.json 版本号"
    fi
    
    # 更新README.md中的版本徽章
    if [ -f "README.md" ]; then
        sed -i.bak "s/version-.*-blue/version-$version-blue/" README.md
        rm README.md.bak
        print_success "已更新 README.md 版本徽章"
    fi
    
    # 更新CHANGELOG.md
    if [ -f "CHANGELOG.md" ]; then
        # 在CHANGELOG.md开头添加新版本
        sed -i.bak "1i\\
## [未发布]\\
\\
### 🚧 计划中的功能\\
- 更多AI模型支持\\
- 高级分析仪表板\\
- 移动端原生应用\\
- 企业级功能增强\\
- 更多集成选项\\
\\
### 🔮 长期规划\\
- 云原生架构\\
- 边缘计算支持\\
- 联邦学习能力\\
- 更多行业解决方案\\
\\
---\\
\\
" CHANGELOG.md
        rm CHANGELOG.md.bak
        print_success "已更新 CHANGELOG.md"
    fi
}

# 创建发布分支
create_release_branch() {
    local version=$1
    local branch_name="release/v$version"
    
    print_info "创建发布分支: $branch_name"
    
    git checkout -b "$branch_name"
    print_success "已创建并切换到发布分支: $branch_name"
}

# 提交版本更新
commit_version_update() {
    local version=$1
    
    print_info "提交版本更新"
    
    git add .
    git commit -m "chore: prepare release v$version"
    
    print_success "已提交版本更新"
}

# 创建版本标签
create_version_tag() {
    local version=$1
    
    print_info "创建版本标签 v$version"
    
    git tag -a "v$version" -m "ImagentX v$version Release"
    
    print_success "已创建版本标签 v$version"
}

# 推送发布分支和标签
push_release() {
    local version=$1
    local branch_name="release/v$version"
    
    print_info "推送发布分支和标签"
    
    git push origin "$branch_name"
    git push origin "v$version"
    
    print_success "已推送发布分支和标签"
}

# 合并到主分支
merge_to_main() {
    local version=$1
    local branch_name="release/v$version"
    
    print_info "合并到主分支"
    
    git checkout main
    git merge "$branch_name"
    git push origin main
    
    print_success "已合并到主分支并推送"
}

# 清理发布分支
cleanup_release_branch() {
    local version=$1
    local branch_name="release/v$version"
    
    print_info "清理发布分支"
    
    git branch -d "$branch_name"
    git push origin --delete "$branch_name"
    
    print_success "已清理发布分支"
}

# 显示帮助信息
show_help() {
    echo "ImagentX 版本管理脚本"
    echo ""
    echo "使用方法:"
    echo "  $0 [命令] [版本号]"
    echo ""
    echo "命令:"
    echo "  prepare <version>    准备新版本发布"
    echo "  release <version>    完成版本发布"
    echo "  tag <version>        创建版本标签"
    echo "  help                 显示此帮助信息"
    echo ""
    echo "示例:"
    echo "  $0 prepare 1.0.2    准备版本1.0.2"
    echo "  $0 release 1.0.2    发布版本1.0.2"
    echo "  $0 tag 1.0.2        创建版本1.0.2标签"
}

# 准备新版本
prepare_release() {
    local version=$1
    
    if [ -z "$version" ]; then
        print_error "请提供版本号"
        exit 1
    fi
    
    print_info "开始准备版本 $version 发布"
    
    check_git_status
    update_version "$version"
    create_release_branch "$version"
    commit_version_update "$version"
    
    print_success "版本 $version 准备完成！"
    print_info "请在新分支上完成最后的测试和修复"
    print_info "完成后运行: $0 release $version"
}

# 完成版本发布
complete_release() {
    local version=$1
    
    if [ -z "$version" ]; then
        print_error "请提供版本号"
        exit 1
    fi
    
    print_info "开始完成版本 $version 发布"
    
    create_version_tag "$version"
    push_release "$version"
    merge_to_main "$version"
    cleanup_release_branch "$version"
    
    print_success "版本 $version 发布完成！"
    print_info "新版本已推送到GitHub，用户可以通过以下方式访问："
    print_info "  - 标签: v$version"
    print_info "  - 主分支: main"
    print_info "  - 下载: https://github.com/Meteorkid/Imagent-X-manus/archive/v$version.zip"
}

# 主函数
main() {
    local command=$1
    local version=$2
    
    case "$command" in
        "prepare")
            prepare_release "$version"
            ;;
        "release")
            complete_release "$version"
            ;;
        "tag")
            create_version_tag "$version"
            git push origin "v$version"
            print_success "版本标签 v$version 已推送"
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
