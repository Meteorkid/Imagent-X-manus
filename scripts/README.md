# 📜 脚本说明文档

## 🎯 脚本分类

### 根目录脚本

| 脚本 | 用途 | 状态 |
|------|------|------|
| `init-database.sh` | 初始化数据库 | ✅ 使用中 |
| `start-backend.sh` | 启动后端服务 | ✅ 使用中 |
| `start-imagentx-complete.sh` | 完整启动（前端+后端） | ⚠️ 重复 |
| `start-imagentx-correct.sh` | 正确启动（推荐） | ✅ 推荐 |
| `start-imagentx-final.sh` | 最终启动版本 | ⚠️ 重复 |
| `stop-imagentx.sh` | 停止服务 | ✅ 使用中 |

**推荐使用**: `start-imagentx-correct.sh`

### scripts/ 目录

#### 核心脚本 (scripts/core/)
- `build.sh` - 构建项目
- `deploy.sh` - 部署脚本
- `monitor.sh` - 监控脚本

#### 工具脚本 (scripts/utils/)
- `backup.sh` - 备份脚本
- `restore.sh` - 恢复脚本
- `cleanup.sh` - 清理脚本
- `health-check.sh` - 健康检查

#### 性能脚本 (scripts/performance/)
- `benchmark.sh` - 性能基准测试
- `load-test.sh` - 负载测试
- `profiler.sh` - 性能分析

#### 测试脚本 (scripts/testing/)
- `unit-test.sh` - 单元测试
- `integration-test.sh` - 集成测试
- `e2e-test.sh` - 端到端测试

#### 增强脚本 (scripts/enhancement/)
- `feature-flag.sh` - 功能开关
- `AB-test.sh` - A/B 测试
- `canary.sh` - 金丝雀发布

#### 数据库脚本 (scripts/database-migration/)
- `migrate.sh` - 数据库迁移
- `rollback.sh` - 回滚脚本
- `seed.sh` - 种子数据

#### Docker 脚本 (scripts/docker/)
- `build-images.sh` - 构建镜像
- `push-images.sh` - 推送镜像

#### 部署脚本 (scripts/deployment/)
- `deploy-staging.sh` - 部署到预发布
- `deploy-production.sh` - 部署到生产

### MCP 配置脚本 (mcp-config/)

- `setup-mcp.sh` - 设置 MCP 服务器
- `start-mcp.sh` - 启动 MCP
- `stop-mcp.sh` - 停止 MCP
- `auth/setup-auth.sh` - 设置认证

### 文档工具 (docs/tools/)

- `generate-api-docs.sh` - 生成 API 文档
- `generate-architecture.sh` - 生成架构图
- `validate-docs.sh` - 验证文档

## 🚀 常用命令

### 启动项目
```bash
# 完整启动（推荐）
./start-imagentx-correct.sh

# 或使用 Docker Compose
docker-compose up -d
```

### 停止项目
```bash
./stop-imagentx.sh
```

### 数据库操作
```bash
# 初始化数据库
./init-database.sh

# 数据库迁移
./scripts/database-migration/migrate.sh

# 备份数据库
./scripts/utils/backup.sh
```

### 测试
```bash
# 运行所有测试
./scripts/testing/unit-test.sh

# 运行集成测试
./scripts/testing/integration-test.sh
```

### 性能测试
```bash
# 运行性能基准测试
./scripts/performance/benchmark.sh

# 运行负载测试
./scripts/performance/load-test.sh
```

## 📝 脚本规范

### 命名规范
- 使用小写字母和连字符
- 动词开头：`start-`, `stop-`, `build-`, `deploy-`
- 文件扩展名：`.sh`

### 代码规范
```bash
#!/bin/bash
set -e  # 遇到错误立即退出

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
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
```

### 错误处理
```bash
# 检查依赖
command -v docker >/dev/null 2>&1 || { log_error "docker 未安装"; exit 1; }

# 检查文件是否存在
if [ ! -f ".env" ]; then
    log_error ".env 文件不存在"
    exit 1
fi
```

## 🔧 维护说明

### 添加新脚本
1. 确定脚本类别
2. 遵循命名规范
3. 添加到对应目录
4. 更新本文档

### 删除脚本
1. 确认脚本不再使用
2. 检查是否有其他脚本依赖
3. 从 Git 历史中删除（可选）

### 脚本权限
```bash
# 添加执行权限
chmod +x script.sh

# 移除执行权限
chmod -x script.sh
```

## 📊 脚本统计

- **总脚本数**: 122
- **根目录脚本**: 6
- **scripts/ 目录**: 58
- **mcp-config/ 目录**: 11
- **docs/tools/ 目录**: 8
- **其他**: 39

## 🎯 优化建议

1. **合并重复脚本**
   - `start-imagentx-*.sh` → `start-imagentx.sh`
   - 保留 `start-imagentx-correct.sh` 作为主脚本

2. **删除废弃脚本**
   - 检查脚本最后修改时间
   - 确认是否还在使用

3. **统一脚本风格**
   - 使用统一的颜色定义
   - 添加统一的日志函数
   - 标准化错误处理

4. **添加脚本测试**
   - 为关键脚本添加单元测试
   - 使用 bats 或 shunit2

## 📚 相关文档

- [部署指南](../docs/deployment/)
- [开发指南](../docs/develop_document.md)
- [API 文档](../docs/api-reference/)
