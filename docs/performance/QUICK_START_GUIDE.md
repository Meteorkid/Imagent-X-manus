# ImagentX 数据库性能优化快速启动指南

## 🚀 快速开始

### 第一步：环境准备

确保您的系统已安装以下工具：
- PostgreSQL 客户端 (`psql`)
- Docker 和 Docker Compose
- curl 和 jq (可选)

```bash
# 检查工具是否安装
which psql
which docker
which curl
```

### 第二步：设置环境变量

```bash
# 设置数据库连接信息
export DB_HOST="localhost"
export DB_USER="imagentx_user"
export DB_NAME="imagentx"
export BACKEND_URL="http://localhost:8088"
```

### 第三步：执行优化部署

```bash
# 运行优化部署脚本
./scripts/performance/deploy-database-optimization.sh
```

这个脚本会自动完成：
- ✅ 备份当前配置
- ✅ 创建性能索引
- ✅ 优化连接池配置
- ✅ 设置监控配置
- ✅ 重启服务

---

## 📊 性能监控

### 实时监控

```bash
# 持续监控（每30秒更新一次）
./scripts/performance/monitor-database-performance.sh -c

# 自定义监控间隔（每60秒）
./scripts/performance/monitor-database-performance.sh -c -i 60
```

### 单次检查

```bash
# 执行单次性能检查
./scripts/performance/monitor-database-performance.sh

# 仅检查告警
./scripts/performance/monitor-database-performance.sh -a

# 生成性能报告
./scripts/performance/monitor-database-performance.sh -r
```

---

## 🔧 手动优化步骤

### 1. 创建性能索引

```sql
-- 连接到数据库
psql -h localhost -U imagentx_user -d imagentx

-- 执行索引创建脚本
\i performance-config/database/create-performance-indexes.sql
```

### 2. 优化PostgreSQL参数

```sql
-- 内存配置
ALTER SYSTEM SET shared_buffers = '256MB';
ALTER SYSTEM SET effective_cache_size = '1GB';
ALTER SYSTEM SET work_mem = '4MB';

-- 连接配置
ALTER SYSTEM SET max_connections = 100;

-- 查询优化
ALTER SYSTEM SET random_page_cost = 1.1;
ALTER SYSTEM SET effective_io_concurrency = 200;

-- 重新加载配置
SELECT pg_reload_conf();
```

### 3. 优化连接池配置

编辑 `application.yml` 文件：

```yaml
spring:
  datasource:
    hikari:
      maximum-pool-size: 30
      minimum-idle: 10
      connection-timeout: 20000
      idle-timeout: 300000
      max-lifetime: 1200000
      leak-detection-threshold: 60000
```

---

## 📈 性能验证

### 检查索引效果

```sql
-- 查看索引使用情况
SELECT 
    schemaname,
    tablename,
    indexname,
    idx_scan,
    idx_tup_read
FROM pg_stat_user_indexes 
WHERE indexname LIKE 'idx_%'
ORDER BY idx_scan DESC;
```

### 检查慢查询

```sql
-- 查看慢查询统计
SELECT 
    query,
    calls,
    total_time,
    mean_time,
    rows
FROM pg_stat_statements 
WHERE mean_time > 1000
ORDER BY mean_time DESC
LIMIT 10;
```

### 检查连接池状态

```bash
# 检查连接池健康状态
curl http://localhost:8088/actuator/health

# 查看详细连接池信息
curl http://localhost:8088/actuator/metrics/hikaricp.connections
```

---

## 🚨 常见问题解决

### 问题1：数据库连接失败

```bash
# 检查PostgreSQL服务状态
brew services list | grep postgresql

# 启动PostgreSQL服务
brew services start postgresql@15

# 检查连接
psql -h localhost -U imagentx_user -d imagentx -c "SELECT 1;"
```

### 问题2：索引创建失败

```sql
-- 检查表是否存在
\dt

-- 手动创建索引
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_agents_user_id ON agents(created_by);
```

### 问题3：连接池配置不生效

```bash
# 重启应用服务
docker-compose restart imagentx-backend

# 检查配置是否加载
curl http://localhost:8088/actuator/env | jq '.propertySources[] | select(.name | contains("applicationConfig"))'
```

### 问题4：监控数据不显示

```bash
# 检查Prometheus是否运行
docker ps | grep prometheus

# 检查Grafana是否运行
docker ps | grep grafana

# 访问监控面板
open http://localhost:9090  # Prometheus
open http://localhost:3001  # Grafana
```

---

## 📋 性能检查清单

### 每日检查
- [ ] 数据库连接数是否正常
- [ ] 慢查询数量是否增加
- [ ] 缓存命中率是否正常
- [ ] 系统资源使用是否合理

### 每周检查
- [ ] 索引使用情况分析
- [ ] 表大小增长趋势
- [ ] 性能报告生成
- [ ] 连接池配置优化

### 每月检查
- [ ] 数据库参数调优
- [ ] 分片策略评估
- [ ] 容量规划
- [ ] 备份策略验证

---

## 🎯 性能目标

### 短期目标（1周内）
- ✅ 查询响应时间 < 200ms
- ✅ 连接池利用率 < 80%
- ✅ 慢查询数量 < 5个/小时

### 中期目标（1个月内）
- 🔄 系统并发处理能力提升 100%
- 🔄 数据库错误率 < 0.1%
- 🔄 缓存命中率 > 90%

### 长期目标（3个月内）
- 📈 支持 10倍用户增长
- 📈 系统可用性达到 99.9%
- 📈 运维成本降低 40%

---

## 📞 技术支持

### 获取帮助
- **性能优化团队**: performance@imagentx.ai
- **数据库团队**: database@imagentx.ai
- **运维团队**: ops@imagentx.ai

### 文档资源
- [完整性能优化计划](../DATABASE_PERFORMANCE_OPTIMIZATION_PLAN.md)
- [监控配置指南](../monitoring/MONITORING_SETUP.md)
- [故障排除指南](../troubleshooting/DATABASE_TROUBLESHOOTING.md)

---

## 🔄 持续优化

### 自动化脚本
```bash
# 设置定时任务
crontab -e

# 添加以下任务
# 每天凌晨2点执行备份
0 2 * * * /path/to/Imagent-X/scripts/performance/backup-database.sh

# 每周一凌晨3点生成性能报告
0 3 * * 1 /path/to/Imagent-X/scripts/performance/monitor-database-performance.sh -r

# 每小时检查告警
0 * * * * /path/to/Imagent-X/scripts/performance/monitor-database-performance.sh -a
```

### 监控告警
- 设置邮件告警通知
- 配置Slack/钉钉通知
- 建立告警升级机制

---

*最后更新时间: 2024年12月*
