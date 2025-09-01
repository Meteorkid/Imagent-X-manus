#!/bin/bash

# ImagentX 项目结构重组计划显示脚本
# 显示重组计划，不实际执行移动操作

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

echo -e "${BLUE}📋 ImagentX 项目结构重组计划${NC}"
echo "=========================================="

# 分析当前文件结构
analyze_current_structure() {
    echo -e "${CYAN}📊 当前项目结构分析${NC}"
    echo "--------------------------------"
    
    echo -e "${YELLOW}📁 主要目录:${NC}"
    ls -d */ 2>/dev/null | head -10
    
    echo -e "${YELLOW}📄 根目录文件 (前20个):${NC}"
    ls -1 | grep -v "^d" | head -20
    
    echo -e "${YELLOW}🔧 脚本文件:${NC}"
    ls -1 *.sh 2>/dev/null || echo "无脚本文件"
    
    echo -e "${YELLOW}📚 文档文件:${NC}"
    ls -1 *.md 2>/dev/null || echo "无文档文件"
    
    echo -e "${YELLOW}⚙️  配置文件:${NC}"
    ls -1 docker-compose*.yml 2>/dev/null || echo "无Docker Compose文件"
    ls -1 *.conf 2>/dev/null || echo "无配置文件"
    
    echo ""
}

# 显示重组计划
show_reorganization_plan() {
    echo -e "${BLUE}🎯 重组计划${NC}"
    echo "--------------------------------"
    
    echo -e "${GREEN}📱 阶段1: 应用程序重组${NC}"
    echo "  移动: ImagentX/ → apps/backend/"
    echo "  移动: imagentx-frontend-plus/ → apps/frontend/"
    echo "  移动: AgentX/ → apps/backend/ (合并)"
    echo ""
    
    echo -e "${GREEN}🔧 阶段2: 脚本重组${NC}"
    echo "  移动: start.sh, stop.sh, status.sh → scripts/core/"
    echo "  移动: enhancement-scripts/* → scripts/enhancement/"
    echo "  移动: deploy/* → scripts/deployment/"
    echo "  移动: test-*.sh → scripts/testing/"
    echo "  移动: 其他*.sh → scripts/utils/"
    echo ""
    
    echo -e "${GREEN}⚙️  阶段3: 配置重组${NC}"
    echo "  移动: docker-compose*.yml → config/docker/"
    echo "  移动: Dockerfile → config/docker/"
    echo "  移动: nginx.conf → config/nginx/"
    echo "  移动: .env* → config/environment/"
    echo "  移动: docs/sql/ → config/database/"
    echo ""
    
    echo -e "${GREEN}📚 阶段4: 文档重组${NC}"
    echo "  移动: *.md (根目录) → docs/guides/"
    echo "  移动: *API*.md → docs/api/"
    echo "  移动: *部署*.md → docs/deployment/"
    echo "  移动: *开发*.md → docs/development/"
    echo "  移动: *故障*.md → docs/troubleshooting/"
    echo "  移动: *-OpenAPI*.json → docs/api/"
    echo ""
    
    echo -e "${GREEN}🛠️  阶段5: 工具重组${NC}"
    echo "  移动: mcp-gateway* → tools/mcp-gateway/"
    echo "  移动: *monitor* → tools/monitoring/"
    echo "  移动: integration-tests/* → tools/testing/"
    echo ""
    
    echo -e "${GREEN}📦 阶段6: 资源重组${NC}"
    echo "  移动: *-Collection*.json → resources/api-collections/"
    echo "  移动: docs/images/* → resources/images/"
    echo "  移动: *.jpg, *.png, *.svg → resources/images/"
    echo ""
    
    echo -e "${GREEN}🗂️  阶段7: 临时文件重组${NC}"
    echo "  移动: logs/ → temp/logs/"
    echo "  移动: pids/ → temp/pids/"
    echo "  移动: .venv/ → temp/cache/"
    echo ""
    
    echo -e "${GREEN}📊 阶段8: 报告重组${NC}"
    echo "  移动: *AUDIT*.md → reports/audit/"
    echo "  移动: *PERFORMANCE*.md → reports/performance/"
    echo "  移动: *TEST*.md → reports/testing/"
    echo ""
}

# 显示新的目录结构
show_new_structure() {
    echo -e "${BLUE}📁 新的目录结构${NC}"
    echo "--------------------------------"
    
    cat << 'EOF'
ImagentX-master/
├── 📁 apps/                          # 应用程序目录
│   ├── backend/                      # 后端应用
│   └── frontend/                     # 前端应用
│
├── 📁 scripts/                       # 脚本管理
│   ├── core/                         # 核心脚本
│   │   ├── start.sh                  # 统一启动脚本
│   │   ├── stop.sh                   # 统一停止脚本
│   │   └── status.sh                 # 状态检查脚本
│   ├── deployment/                   # 部署脚本
│   ├── enhancement/                  # 增强脚本
│   ├── testing/                      # 测试脚本
│   └── utils/                        # 工具脚本
│
├── 📁 config/                        # 配置文件
│   ├── docker/                       # Docker配置
│   ├── nginx/                        # Nginx配置
│   ├── database/                     # 数据库配置
│   └── environment/                  # 环境配置
│
├── 📁 docs/                          # 文档中心
│   ├── guides/                       # 使用指南
│   ├── api/                          # API文档
│   ├── deployment/                   # 部署文档
│   ├── development/                  # 开发文档
│   └── troubleshooting/              # 故障排除
│
├── 📁 deployment/                    # 部署相关
│   ├── docker/                       # Docker部署
│   ├── kubernetes/                   # K8s部署
│   └── cloud/                        # 云部署
│
├── 📁 tools/                         # 工具和实用程序
│   ├── mcp-gateway/                  # MCP网关工具
│   ├── monitoring/                   # 监控工具
│   └── testing/                      # 测试工具
│
├── 📁 reports/                       # 报告和审计
│   ├── audit/                        # 审计报告
│   ├── performance/                  # 性能报告
│   └── testing/                      # 测试报告
│
├── 📁 resources/                     # 资源文件
│   ├── api-collections/              # API集合
│   ├── images/                       # 图片资源
│   └── templates/                    # 模板文件
│
└── 📁 temp/                          # 临时文件
    ├── logs/                         # 日志文件
    ├── pids/                         # 进程ID文件
    └── cache/                        # 缓存文件
EOF
    echo ""
}

# 显示重组优势
show_benefits() {
    echo -e "${BLUE}🎯 重组优势${NC}"
    echo "--------------------------------"
    
    echo -e "${GREEN}✅ 清晰的结构${NC}"
    echo "  • 功能模块化分离"
    echo "  • 易于导航和理解"
    echo "  • 统一的命名规范"
    echo ""
    
    echo -e "${GREEN}✅ 更好的维护性${NC}"
    echo "  • 相关文件集中管理"
    echo "  • 减少文件搜索时间"
    echo "  • 简化版本控制"
    echo ""
    
    echo -e "${GREEN}✅ 提高开发效率${NC}"
    echo "  • 快速定位文件"
    echo "  • 清晰的职责分离"
    echo "  • 标准化的项目结构"
    echo ""
    
    echo -e "${GREEN}✅ 便于扩展${NC}"
    echo "  • 模块化的结构"
    echo "  • 易于添加新功能"
    echo "  • 支持团队协作"
    echo ""
}

# 显示执行建议
show_execution_advice() {
    echo -e "${BLUE}🚀 执行建议${NC}"
    echo "--------------------------------"
    
    echo -e "${YELLOW}⚠️  执行前准备:${NC}"
    echo "  1. 创建完整备份"
    echo "  2. 确保所有更改已提交"
    echo "  3. 通知团队成员"
    echo "  4. 准备回滚计划"
    echo ""
    
    echo -e "${YELLOW}🔧 执行步骤:${NC}"
    echo "  1. 运行: ./reorganize-project.sh"
    echo "  2. 检查新的项目结构"
    echo "  3. 测试所有功能"
    echo "  4. 更新相关文档"
    echo "  5. 提交代码变更"
    echo ""
    
    echo -e "${YELLOW}📋 执行后检查:${NC}"
    echo "  • 所有脚本路径是否正确"
    echo "  • 配置文件引用是否更新"
    echo "  • 文档链接是否有效"
    echo "  • 团队文档是否更新"
    echo ""
}

# 显示文件统计
show_file_statistics() {
    echo -e "${BLUE}📊 文件统计${NC}"
    echo "--------------------------------"
    
    echo -e "${CYAN}当前文件统计:${NC}"
    total_files=$(find . -type f -not -path "./.*" | wc -l)
    total_dirs=$(find . -type d -not -path "./.*" | wc -l)
    
    echo "  总文件数: $total_files"
    echo "  总目录数: $total_dirs"
    
    echo -e "${CYAN}按类型统计:${NC}"
    echo "  脚本文件: $(find . -name "*.sh" | wc -l)"
    echo "  文档文件: $(find . -name "*.md" | wc -l)"
    echo "  配置文件: $(find . -name "*.yml" -o -name "*.yaml" -o -name "*.conf" | wc -l)"
    echo "  JSON文件: $(find . -name "*.json" | wc -l)"
    echo "  图片文件: $(find . -name "*.jpg" -o -name "*.png" -o -name "*.svg" | wc -l)"
    
    echo ""
}

# 主函数
main() {
    analyze_current_structure
    show_reorganization_plan
    show_new_structure
    show_benefits
    show_file_statistics
    show_execution_advice
    
    echo -e "${GREEN}🎉 重组计划显示完成！${NC}"
    echo "=========================================="
    echo -e "${CYAN}要执行重组，请运行:${NC}"
    echo -e "${YELLOW}  ./reorganize-project.sh${NC}"
    echo ""
    echo -e "${CYAN}要查看详细计划，请查看:${NC}"
    echo -e "${YELLOW}  PROJECT_STRUCTURE_REORGANIZATION.md${NC}"
    echo ""
}

# 执行主函数
main "$@"
