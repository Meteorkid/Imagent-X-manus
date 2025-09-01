# 数据库管理文档

本文档包含了ImagentX项目的数据库管理相关脚本和配置。

## 📁 文件结构

```
docs/database/
├── README.md                           # 本文档
├── update_agentx_to_imagentx.sql      # 数据库内容更新脚本
└── create_imagentx_database.sql       # 数据库创建脚本

scripts/database-migration/
├── migrate_to_imagentx.sh             # 完整数据库迁移脚本
└── create_imagentx_db.sh              # 简化数据库创建脚本

config/docker/
└── docker-compose-imagentx.yml        # 使用imagentx数据库的Docker配置
```

## 🗄️ 数据库信息

### 旧数据库（agentx）
- **数据库名**: agentx
- **用户名**: agentx_user
- **密码**: agentx_pass

### 新数据库（imagentx）
- **数据库名**: imagentx
- **用户名**: imagentx_user
- **密码**: imagentx_pass

## 🚀 快速开始

### 1. 创建imagentx数据库

```bash
# 简化版本（仅创建数据库）
./scripts/database-migration/create_imagentx_db.sh

# 完整版本（创建数据库并迁移数据）
./scripts/database-migration/migrate_to_imagentx.sh
```

### 2. 使用新数据库启动服务

```bash
# 停止旧服务
docker-compose -f docker-compose-internal-db.yml down

# 启动新服务
docker-compose -f config/docker/docker-compose-imagentx.yml up -d
```

### 3. 验证服务

```bash
# 检查前端
curl http://localhost:3000

# 检查后端API
curl http://localhost:8088/api/health

# 检查数据库连接
docker exec imagentx-app psql -U imagentx_user -d imagentx -c "SELECT current_database(), current_user;"
```

## 📝 脚本说明

### update_agentx_to_imagentx.sql
将数据库中所有包含"agentx"、"Agentx"、"AGENTX"的内容替换为"Imagent X"。

**执行命令：**
```bash
docker exec -i imagentx-app psql -U imagentx_user -d imagentx < docs/database/update_agentx_to_imagentx.sql
```

**更新内容：**
- 用户昵称和邮箱
- 代理名称和描述
- 消息内容
- 工具名称和描述
- 提供商信息
- 模型信息
- 产品信息
- 规则内容
- 文档内容
- 文件名

**替换规则：**
- `agentx` → `Imagent X`
- `Agentx` → `Imagent X`
- `AGENTX` → `Imagent X`
- 邮箱地址中的上述形式 → `imagentx`（小写）

### create_imagentx_database.sql
创建新的imagentx数据库和用户。

**执行命令：**
```bash
docker exec -i imagentx-app psql -U postgres < docs/database/create_imagentx_database.sql
```

### migrate_to_imagentx.sh
完整的数据库迁移脚本，包含：
- 备份原数据库
- 创建新数据库
- 迁移数据
- 更新内容（处理所有大小写形式）
- 验证结果

### create_imagentx_db.sh
简化的数据库创建脚本，仅创建数据库和用户。

## ⚠️ 注意事项

1. **备份数据**：在执行迁移前，请确保已备份重要数据
2. **停止服务**：迁移过程中需要停止应用服务
3. **权限检查**：确保有足够的数据库权限
4. **网络连接**：确保Docker容器正常运行
5. **大小写处理**：脚本会处理所有大小写形式的"agentx"

## 🔧 故障排除

### 常见问题

1. **容器未运行**
   ```bash
   # 启动服务
   docker-compose -f docker-compose-internal-db.yml up -d
   ```

2. **权限不足**
   ```bash
   # 检查用户权限
   docker exec imagentx-app psql -U postgres -c "\du"
   ```

3. **数据库连接失败**
   ```bash
   # 检查数据库状态
   docker exec imagentx-app psql -U imagentx_user -d imagentx -c "SELECT version();"
   ```

### 日志查看

```bash
# 查看容器日志
docker logs imagentx-app

# 查看数据库日志
docker exec imagentx-app tail -f /var/log/postgresql/postgresql-*.log
```

## 📞 支持

如果遇到问题，请检查：
1. Docker容器状态
2. 数据库连接
3. 网络配置
4. 权限设置

更多信息请参考项目主文档。
