#!/bin/bash

# 数据库迁移脚本：将agentx数据库迁移到imagentx
# 功能：创建新数据库、迁移数据、更新配置

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 脚本信息
SCRIPT_NAME="数据库迁移脚本"
VERSION="1.0"
AUTHOR="ImagentX Team"

echo -e "${BLUE}🔄 ${SCRIPT_NAME} v${VERSION}${NC}"
echo -e "${CYAN}作者：${AUTHOR}${NC}"
echo "=================================="

# 检查Docker容器是否运行
check_container() {
    if ! docker ps | grep -q imagentx-app; then
        echo -e "${RED}❌ ImagentX容器未运行，请先启动服务${NC}"
        echo -e "${YELLOW}💡 启动命令：docker-compose -f docker-compose-internal-db.yml up -d${NC}"
        exit 1
    fi
    echo -e "${GREEN}✅ ImagentX容器运行正常${NC}"
}

# 备份数据库
backup_database() {
    echo -e "${YELLOW}💾 备份当前数据库...${NC}"
    local backup_file="agentx_backup_$(date +%Y%m%d_%H%M%S).sql"
    docker exec imagentx-app pg_dump -U agentx_user -d agentx > "$backup_file"
    echo -e "${GREEN}✅ 数据库已备份到：${backup_file}${NC}"
}

# 创建新数据库
create_new_database() {
    echo -e "${YELLOW}🗄️ 创建imagentx数据库...${NC}"
    
    # 创建数据库
    docker exec imagentx-app psql -U postgres -c "CREATE DATABASE imagentx;" 2>/dev/null || echo "数据库可能已存在"
    
    # 创建用户
    docker exec imagentx-app psql -U postgres -c "CREATE USER imagentx_user WITH PASSWORD 'imagentx_pass';" 2>/dev/null || echo "用户可能已存在"
    
    # 授予权限
    docker exec imagentx-app psql -U postgres -c "GRANT ALL PRIVILEGES ON DATABASE imagentx TO imagentx_user;"
    docker exec imagentx-app psql -U postgres -c "GRANT ALL PRIVILEGES ON SCHEMA public TO imagentx_user;"
    
    echo -e "${GREEN}✅ imagentx数据库创建完成${NC}"
}

# 迁移数据
migrate_data() {
    echo -e "${YELLOW}📦 迁移数据...${NC}"
    docker exec imagentx-app pg_dump -U agentx_user -d agentx | docker exec -i imagentx-app psql -U imagentx_user -d imagentx
    echo -e "${GREEN}✅ 数据迁移完成${NC}"
}

# 更新数据内容
update_data_content() {
    echo -e "${YELLOW}🔄 更新数据内容（agentx/Agentx/AGENTX → Imagent X）...${NC}"
    docker exec -i imagentx-app psql -U imagentx_user -d imagentx < ../../docs/database/update_agentx_to_imagentx.sql
    echo -e "${GREEN}✅ 数据内容更新完成${NC}"
}

# 验证迁移
verify_migration() {
    echo -e "${YELLOW}🔍 验证迁移结果...${NC}"
    if docker exec imagentx-app psql -U imagentx_user -d imagentx -c "SELECT current_database(), current_user;" 2>/dev/null; then
        echo -e "${GREEN}✅ 数据库迁移成功！${NC}"
        echo -e "${GREEN}✅ 新数据库：imagentx${NC}"
        echo -e "${GREEN}✅ 新用户：imagentx_user${NC}"
        return 0
    else
        echo -e "${RED}❌ 数据库迁移失败${NC}"
        return 1
    fi
}

# 显示迁移信息
show_migration_info() {
    echo ""
    echo -e "${GREEN}🎉 数据库迁移完成！${NC}"
    echo -e "${CYAN}新数据库信息：${NC}"
    echo -e "  - 数据库名：imagentx"
    echo -e "  - 用户名：imagentx_user"
    echo -e "  - 密码：imagentx_pass"
    echo ""
    echo -e "${YELLOW}💡 下一步操作：${NC}"
    echo -e "  1. 停止当前服务：docker-compose -f docker-compose-internal-db.yml down"
    echo -e "  2. 使用新配置启动：docker-compose -f config/docker/docker-compose-imagentx.yml up -d"
    echo -e "  3. 验证服务：curl http://localhost:3000"
    echo ""
    echo -e "${YELLOW}📝 注意事项：${NC}"
    echo -e "  - 旧数据库agentx仍然存在，可以手动删除"
    echo -e "  - 备份文件已保存为agentx_backup_*.sql"
    echo -e "  - 应用现在使用新的imagentx数据库"
}

# 主函数
main() {
    # 检查容器状态
    check_container
    
    # 确认操作
    echo -e "${YELLOW}⚠️ 警告：此操作将停止应用服务并迁移数据库${NC}"
    echo -e "${YELLOW}请确保已备份重要数据${NC}"
    read -p "是否继续？(y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}操作已取消${NC}"
        exit 0
    fi
    
    # 执行迁移步骤
    echo -e "${YELLOW}🛑 停止应用服务...${NC}"
    docker-compose -f docker-compose-internal-db.yml stop agentx-app
    
    backup_database
    create_new_database
    migrate_data
    update_data_content
    
    # 验证迁移
    if verify_migration; then
        show_migration_info
    else
        echo -e "${RED}❌ 迁移失败，请检查日志并手动处理${NC}"
        exit 1
    fi
}

# 执行主函数
main "$@"
