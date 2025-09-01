#!/bin/bash

# ImagentX 项目结构重组脚本
# 将混乱的项目结构重新组织为清晰、有序的目录结构

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔄 ImagentX 项目结构重组${NC}"
echo "=================================="

# 创建备份
create_backup() {
    echo -e "${CYAN}📦 创建项目备份...${NC}"
    BACKUP_DIR="backup_$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$BACKUP_DIR"
    
    # 备份所有文件和目录（除了备份目录本身）
    rsync -av --exclude="$BACKUP_DIR" --exclude="backup_*" . "$BACKUP_DIR/"
    
    echo -e "${GREEN}✅ 备份已创建: $BACKUP_DIR${NC}"
    echo ""
}

# 创建新目录结构
create_directory_structure() {
    echo -e "${CYAN}📁 创建新的目录结构...${NC}"
    
    # 主要目录
    mkdir -p apps/{backend,frontend}
    mkdir -p scripts/{core,deployment,enhancement,testing,utils}
    mkdir -p config/{docker,nginx,database,environment}
    mkdir -p docs/{guides,api,deployment,development,troubleshooting}
    mkdir -p deployment/{docker,kubernetes,cloud}
    mkdir -p tools/{mcp-gateway,monitoring,testing}
    mkdir -p reports/{audit,performance,testing}
    mkdir -p resources/{api-collections,images,templates}
    mkdir -p temp/{logs,pids,cache}
    
    echo -e "${GREEN}✅ 目录结构创建完成${NC}"
    echo ""
}

# 阶段1: 应用程序重组
reorganize_apps() {
    echo -e "${BLUE}📱 阶段1: 应用程序重组${NC}"
    echo "--------------------------------"
    
    # 移动后端应用
    if [ -d "ImagentX" ]; then
        echo -e "${CYAN}移动后端应用...${NC}"
        mv ImagentX/* apps/backend/ 2>/dev/null || true
        rmdir ImagentX 2>/dev/null || true
        echo -e "${GREEN}✅ 后端应用已移动到 apps/backend/${NC}"
    fi
    
    # 移动前端应用
    if [ -d "imagentx-frontend-plus" ]; then
        echo -e "${CYAN}移动前端应用...${NC}"
        mv imagentx-frontend-plus/* apps/frontend/ 2>/dev/null || true
        rmdir imagentx-frontend-plus 2>/dev/null || true
        echo -e "${GREEN}✅ 前端应用已移动到 apps/frontend/${NC}"
    fi
    
    # 移动AgentX（如果存在）
    if [ -d "AgentX" ]; then
        echo -e "${CYAN}移动AgentX应用...${NC}"
        mv AgentX/* apps/backend/ 2>/dev/null || true
        rmdir AgentX 2>/dev/null || true
        echo -e "${GREEN}✅ AgentX应用已合并到 apps/backend/${NC}"
    fi
    
    echo ""
}

# 阶段2: 脚本重组
reorganize_scripts() {
    echo -e "${BLUE}🔧 阶段2: 脚本重组${NC}"
    echo "--------------------------------"
    
    # 移动核心脚本
    echo -e "${CYAN}移动核心脚本...${NC}"
    mv start.sh scripts/core/ 2>/dev/null || true
    mv stop.sh scripts/core/ 2>/dev/null || true
    mv status.sh scripts/core/ 2>/dev/null || true
    echo -e "${GREEN}✅ 核心脚本已移动到 scripts/core/${NC}"
    
    # 移动增强脚本
    if [ -d "enhancement-scripts" ]; then
        echo -e "${CYAN}移动增强脚本...${NC}"
        mv enhancement-scripts/* scripts/enhancement/ 2>/dev/null || true
        rmdir enhancement-scripts 2>/dev/null || true
        echo -e "${GREEN}✅ 增强脚本已移动到 scripts/enhancement/${NC}"
    fi
    
    # 移动部署脚本
    if [ -d "deploy" ]; then
        echo -e "${CYAN}移动部署脚本...${NC}"
        mv deploy/* scripts/deployment/ 2>/dev/null || true
        rmdir deploy 2>/dev/null || true
        echo -e "${GREEN}✅ 部署脚本已移动到 scripts/deployment/${NC}"
    fi
    
    # 移动其他脚本到工具目录
    echo -e "${CYAN}移动工具脚本...${NC}"
    for script in *.sh; do
        if [ -f "$script" ]; then
            case "$script" in
                test-*.sh|run-tests.sh)
                    mv "$script" scripts/testing/ 2>/dev/null || true
                    ;;
                docker-*.sh|deploy-*.sh)
                    mv "$script" scripts/deployment/ 2>/dev/null || true
                    ;;
                *)
                    mv "$script" scripts/utils/ 2>/dev/null || true
                    ;;
            esac
        fi
    done
    echo -e "${GREEN}✅ 工具脚本已移动到相应目录${NC}"
    
    echo ""
}

# 阶段3: 配置重组
reorganize_config() {
    echo -e "${BLUE}⚙️  阶段3: 配置重组${NC}"
    echo "--------------------------------"
    
    # 移动Docker配置
    echo -e "${CYAN}移动Docker配置...${NC}"
    mv docker-compose*.yml config/docker/ 2>/dev/null || true
    mv Dockerfile config/docker/ 2>/dev/null || true
    mv docker/ config/docker/ 2>/dev/null || true
    echo -e "${GREEN}✅ Docker配置已移动到 config/docker/${NC}"
    
    # 移动Nginx配置
    echo -e "${CYAN}移动Nginx配置...${NC}"
    mv nginx.conf config/nginx/ 2>/dev/null || true
    echo -e "${GREEN}✅ Nginx配置已移动到 config/nginx/${NC}"
    
    # 移动环境配置
    echo -e "${CYAN}移动环境配置...${NC}"
    mv .env* config/environment/ 2>/dev/null || true
    mv api-config-complete.js config/environment/ 2>/dev/null || true
    echo -e "${GREEN}✅ 环境配置已移动到 config/environment/${NC}"
    
    # 移动数据库配置
    if [ -d "docs/sql" ]; then
        echo -e "${CYAN}移动数据库配置...${NC}"
        mv docs/sql config/database/ 2>/dev/null || true
        echo -e "${GREEN}✅ 数据库配置已移动到 config/database/${NC}"
    fi
    
    echo ""
}

# 阶段4: 文档重组
reorganize_docs() {
    echo -e "${BLUE}📚 阶段4: 文档重组${NC}"
    echo "--------------------------------"
    
    # 移动根目录的Markdown文档到guides
    echo -e "${CYAN}移动使用指南...${NC}"
    for doc in *.md; do
        if [ -f "$doc" ]; then
            case "$doc" in
                README.md)
                    # README.md保留在根目录
                    continue
                    ;;
                *API*.md|*api*.md)
                    mv "$doc" docs/api/ 2>/dev/null || true
                    ;;
                *部署*.md|*deploy*.md|*DEPLOY*.md)
                    mv "$doc" docs/deployment/ 2>/dev/null || true
                    ;;
                *开发*.md|*develop*.md|*DEVELOP*.md)
                    mv "$doc" docs/development/ 2>/dev/null || true
                    ;;
                *故障*.md|*trouble*.md|*TROUBLE*.md)
                    mv "$doc" docs/troubleshooting/ 2>/dev/null || true
                    ;;
                *)
                    mv "$doc" docs/guides/ 2>/dev/null || true
                    ;;
            esac
        fi
    done
    echo -e "${GREEN}✅ 文档已分类移动到相应目录${NC}"
    
    # 移动API相关文档
    echo -e "${CYAN}移动API文档...${NC}"
    mv *-OpenAPI*.json docs/api/ 2>/dev/null || true
    mv *-OpenAPI*.yaml docs/api/ 2>/dev/null || true
    mv *-OpenAPI*.yml docs/api/ 2>/dev/null || true
    echo -e "${GREEN}✅ API文档已移动到 docs/api/${NC}"
    
    echo ""
}

# 阶段5: 工具重组
reorganize_tools() {
    echo -e "${BLUE}🛠️  阶段5: 工具重组${NC}"
    echo "--------------------------------"
    
    # 移动MCP网关工具
    echo -e "${CYAN}移动MCP网关工具...${NC}"
    mv mcp-gateway*.py tools/mcp-gateway/ 2>/dev/null || true
    mv start-mcp-gateway.sh tools/mcp-gateway/ 2>/dev/null || true
    mv MCP_GATEWAY_README.md tools/mcp-gateway/ 2>/dev/null || true
    mv test-mcp-integration.sh tools/mcp-gateway/ 2>/dev/null || true
    echo -e "${GREEN}✅ MCP网关工具已移动到 tools/mcp-gateway/${NC}"
    
    # 移动监控工具
    echo -e "${CYAN}移动监控工具...${NC}"
    if [ -d "local-enhancement/monitoring" ]; then
        mv local-enhancement/monitoring/* tools/monitoring/ 2>/dev/null || true
    fi
    mv *monitor*.sh tools/monitoring/ 2>/dev/null || true
    echo -e "${GREEN}✅ 监控工具已移动到 tools/monitoring/${NC}"
    
    # 移动测试工具
    echo -e "${CYAN}移动测试工具...${NC}"
    if [ -d "integration-tests" ]; then
        mv integration-tests/* tools/testing/ 2>/dev/null || true
        rmdir integration-tests 2>/dev/null || true
    fi
    mv test-*.py tools/testing/ 2>/dev/null || true
    echo -e "${GREEN}✅ 测试工具已移动到 tools/testing/${NC}"
    
    echo ""
}

# 阶段6: 资源重组
reorganize_resources() {
    echo -e "${BLUE}📦 阶段6: 资源重组${NC}"
    echo "--------------------------------"
    
    # 移动API集合
    echo -e "${CYAN}移动API集合...${NC}"
    mv *-Collection*.json resources/api-collections/ 2>/dev/null || true
    mv *-Postman*.json resources/api-collections/ 2>/dev/null || true
    echo -e "${GREEN}✅ API集合已移动到 resources/api-collections/${NC}"
    
    # 移动图片资源
    echo -e "${CYAN}移动图片资源...${NC}"
    if [ -d "docs/images" ]; then
        mv docs/images/* resources/images/ 2>/dev/null || true
        rmdir docs/images 2>/dev/null || true
    fi
    mv *.jpg resources/images/ 2>/dev/null || true
    mv *.png resources/images/ 2>/dev/null || true
    mv *.svg resources/images/ 2>/dev/null || true
    echo -e "${GREEN}✅ 图片资源已移动到 resources/images/${NC}"
    
    # 移动模板文件
    echo -e "${CYAN}移动模板文件...${NC}"
    mv *.template resources/templates/ 2>/dev/null || true
    mv *.tmpl resources/templates/ 2>/dev/null || true
    echo -e "${GREEN}✅ 模板文件已移动到 resources/templates/${NC}"
    
    echo ""
}

# 阶段7: 临时文件重组
reorganize_temp() {
    echo -e "${BLUE}🗂️  阶段7: 临时文件重组${NC}"
    echo "--------------------------------"
    
    # 移动日志文件
    echo -e "${CYAN}移动日志文件...${NC}"
    if [ -d "logs" ]; then
        mv logs/* temp/logs/ 2>/dev/null || true
        rmdir logs 2>/dev/null || true
    fi
    echo -e "${GREEN}✅ 日志文件已移动到 temp/logs/${NC}"
    
    # 移动进程ID文件
    echo -e "${CYAN}移动进程ID文件...${NC}"
    if [ -d "pids" ]; then
        mv pids/* temp/pids/ 2>/dev/null || true
        rmdir pids 2>/dev/null || true
    fi
    echo -e "${GREEN}✅ 进程ID文件已移动到 temp/pids/${NC}"
    
    # 移动缓存文件
    echo -e "${CYAN}移动缓存文件...${NC}"
    if [ -d ".venv" ]; then
        mv .venv temp/cache/ 2>/dev/null || true
    fi
    mv .DS_Store temp/cache/ 2>/dev/null || true
    echo -e "${GREEN}✅ 缓存文件已移动到 temp/cache/${NC}"
    
    echo ""
}

# 阶段8: 报告重组
reorganize_reports() {
    echo -e "${BLUE}📊 阶段8: 报告重组${NC}"
    echo "--------------------------------"
    
    # 移动审计报告
    echo -e "${CYAN}移动审计报告...${NC}"
    mv *AUDIT*.md reports/audit/ 2>/dev/null || true
    mv *audit*.md reports/audit/ 2>/dev/null || true
    echo -e "${GREEN}✅ 审计报告已移动到 reports/audit/${NC}"
    
    # 移动性能报告
    echo -e "${CYAN}移动性能报告...${NC}"
    mv *PERFORMANCE*.md reports/performance/ 2>/dev/null || true
    mv *performance*.md reports/performance/ 2>/dev/null || true
    echo -e "${GREEN}✅ 性能报告已移动到 reports/performance/${NC}"
    
    # 移动测试报告
    echo -e "${CYAN}移动测试报告...${NC}"
    mv *TEST*.md reports/testing/ 2>/dev/null || true
    mv *test*.md reports/testing/ 2>/dev/null || true
    echo -e "${GREEN}✅ 测试报告已移动到 reports/testing/${NC}"
    
    echo ""
}

# 清理空目录
cleanup_empty_directories() {
    echo -e "${CYAN}🧹 清理空目录...${NC}"
    find . -type d -empty -delete 2>/dev/null || true
    echo -e "${GREEN}✅ 空目录清理完成${NC}"
    echo ""
}

# 创建新的README
create_new_readme() {
    echo -e "${CYAN}📝 创建新的项目README...${NC}"
    
    cat > PROJECT_STRUCTURE.md << 'EOF'
# ImagentX 项目结构

## 📁 目录结构

```
ImagentX-master/
├── 📁 apps/                          # 应用程序目录
│   ├── backend/                      # 后端应用
│   └── frontend/                     # 前端应用
│
├── 📁 scripts/                       # 脚本管理
│   ├── core/                         # 核心脚本
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
```

## 🚀 快速开始

### 启动服务
```bash
./scripts/core/start.sh --core
```

### 停止服务
```bash
./scripts/core/stop.sh
```

### 检查状态
```bash
./scripts/core/status.sh
```

## 📚 文档

- [使用指南](docs/guides/)
- [API文档](docs/api/)
- [部署文档](docs/deployment/)
- [开发文档](docs/development/)
- [故障排除](docs/troubleshooting/)

## 🔧 配置

- [Docker配置](config/docker/)
- [环境配置](config/environment/)
- [数据库配置](config/database/)

## 🛠️ 工具

- [MCP网关](tools/mcp-gateway/)
- [监控工具](tools/monitoring/)
- [测试工具](tools/testing/)
EOF

    echo -e "${GREEN}✅ 新的项目结构文档已创建${NC}"
    echo ""
}

# 更新脚本路径引用
update_script_references() {
    echo -e "${CYAN}🔗 更新脚本路径引用...${NC}"
    
    # 更新核心脚本中的路径引用
    if [ -f "scripts/core/start.sh" ]; then
        sed -i '' 's|cd ImagentX|cd apps/backend|g' scripts/core/start.sh 2>/dev/null || true
        sed -i '' 's|cd imagentx-frontend-plus|cd apps/frontend|g' scripts/core/start.sh 2>/dev/null || true
    fi
    
    if [ -f "scripts/core/stop.sh" ]; then
        sed -i '' 's|docker-compose|config/docker/docker-compose|g' scripts/core/stop.sh 2>/dev/null || true
    fi
    
    echo -e "${GREEN}✅ 脚本路径引用已更新${NC}"
    echo ""
}

# 主函数
main() {
    echo -e "${YELLOW}⚠️  警告: 此操作将重新组织整个项目结构${NC}"
    echo -e "${YELLOW}请确保已备份重要数据${NC}"
    echo ""
    read -p "是否继续？(y/N): " -r response
    if [[ ! "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        echo -e "${RED}❌ 操作已取消${NC}"
        exit 1
    fi
    
    echo ""
    
    # 执行重组步骤
    create_backup
    create_directory_structure
    reorganize_apps
    reorganize_scripts
    reorganize_config
    reorganize_docs
    reorganize_tools
    reorganize_resources
    reorganize_temp
    reorganize_reports
    cleanup_empty_directories
    create_new_readme
    update_script_references
    
    echo -e "${GREEN}🎉 项目结构重组完成！${NC}"
    echo "=================================="
    echo -e "${CYAN}新的项目结构已创建${NC}"
    echo -e "${CYAN}备份文件位置: backup_$(date +%Y%m%d_%H%M%S)${NC}"
    echo ""
    echo -e "${BLUE}📋 下一步操作:${NC}"
    echo -e "1. 检查新的项目结构"
    echo -e "2. 测试所有功能是否正常"
    echo -e "3. 更新团队文档"
    echo -e "4. 提交代码变更"
    echo ""
    echo -e "${GREEN}✨ 享受更清晰的项目结构！${NC}"
}

# 执行主函数
main "$@"
