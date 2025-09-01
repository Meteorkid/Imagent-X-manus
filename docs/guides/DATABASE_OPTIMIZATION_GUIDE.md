# ImagentX 数据库配置优化指南

## 🎯 概述

本指南提供PostgreSQL数据库的性能优化配置建议，包括参数调优、连接池配置、查询优化等，以提升ImagentX系统的整体性能。

## 🔧 PostgreSQL参数优化

### 1. 内存配置优化

#### shared_buffers (共享缓冲区)
```sql
-- 建议设置为系统内存的25%
-- 对于8GB内存的系统
ALTER SYSTEM SET shared_buffers = '2GB';

-- 对于16GB内存的系统
ALTER SYSTEM SET shared_buffers = '4GB';

-- 对于32GB内存的系统
ALTER SYSTEM SET shared_buffers = '8GB';
```

#### effective_cache_size (有效缓存大小)
```sql
-- 建议设置为系统内存的75%
-- 对于8GB内存的系统
ALTER SYSTEM SET effective_cache_size = '6GB';

-- 对于16GB内存的系统
ALTER SYSTEM SET effective_cache_size = '12GB';

-- 对于32GB内存的系统
ALTER SYSTEM SET effective_cache_size = '24GB';
```

#### work_mem (工作内存)
```sql
-- 建议设置为shared_buffers的1/100
-- 对于2GB shared_buffers
ALTER SYSTEM SET work_mem = '20MB';

-- 对于4GB shared_buffers
ALTER SYSTEM SET work_mem = '40MB';

-- 对于8GB shared_buffers
ALTER SYSTEM SET work_mem = '80MB';
```

#### maintenance_work_mem (维护工作内存)
```sql
-- 建议设置为work_mem的10倍
ALTER SYSTEM SET maintenance_work_mem = '200MB';
```

### 2. 连接配置优化

#### max_connections (最大连接数)
```sql
-- 根据应用需求设置，建议200-500
ALTER SYSTEM SET max_connections = 300;
```

#### connection_timeout (连接超时)
```sql
-- 设置合理的连接超时时间
ALTER SYSTEM SET connection_timeout = 60;
```

#### idle_in_transaction_session_timeout (空闲事务超时)
```sql
-- 防止长时间空闲事务占用连接
ALTER SYSTEM SET idle_in_transaction_session_timeout = 300;
```

### 3. 查询优化配置

#### random_page_cost (随机页面成本)
```sql
-- 对于SSD存储，建议设置为1.1
ALTER SYSTEM SET random_page_cost = 1.1;

-- 对于NVMe存储，建议设置为1.0
ALTER SYSTEM SET random_page_cost = 1.0;
```

#### effective_io_concurrency (有效I/O并发)
```sql
-- 对于SSD存储，建议设置为200-400
ALTER SYSTEM SET effective_io_concurrency = 200;

-- 对于NVMe存储，建议设置为400-800
ALTER SYSTEM SET effective_io_concurrency = 400;
```

#### seq_page_cost (顺序页面成本)
```sql
-- 对于SSD存储，建议设置为1.0
ALTER SYSTEM SET seq_page_cost = 1.0;
```

### 4. 日志和监控配置

#### log_statement (语句日志)
```sql
-- 生产环境建议设置为none，开发环境可以设置为all
ALTER SYSTEM SET log_statement = 'none';
```

#### log_min_duration_statement (最小执行时间日志)
```sql
-- 记录执行时间超过指定毫秒的查询
ALTER SYSTEM SET log_min_duration_statement = 1000;
```

#### track_activities (活动跟踪)
```sql
-- 启用活动跟踪，用于监控
ALTER SYSTEM SET track_activities = on;
```

#### track_counts (计数跟踪)
```sql
-- 启用计数跟踪，用于统计
ALTER SYSTEM SET track_counts = on;
```

## 🚀 连接池配置优化

### 1. HikariCP配置 (Spring Boot)

#### application.yml配置
```yaml
spring:
  datasource:
    hikari:
      # 连接池大小
      maximum-pool-size: 20
      minimum-idle: 5
      
      # 连接超时
      connection-timeout: 30000
      idle-timeout: 600000
      max-lifetime: 1800000
      
      # 连接测试
      connection-test-query: SELECT 1
      validation-timeout: 5000
      
      # 泄漏检测
      leak-detection-threshold: 60000
      
      # 性能优化
      auto-commit: true
      read-only: false
```

#### 连接池大小计算
```
连接池大小 = ((核心数 * 2) + 有效磁盘数)

例如：
- 4核心CPU + 1个SSD = (4 * 2) + 1 = 9个连接
- 8核心CPU + 2个SSD = (8 * 2) + 2 = 18个连接
```

### 2. PgBouncer配置 (外部连接池)

#### pgbouncer.ini配置
```ini
[databases]
* = host=localhost port=5432

[pgbouncer]
# 监听地址
listen_addr = *
listen_port = 6432

# 连接池设置
pool_mode = transaction
max_client_conn = 1000
default_pool_size = 20

# 超时设置
server_reset_query = DISCARD ALL
server_check_delay = 30
server_check_timeout = 10

# 日志设置
log_connections = 1
log_disconnections = 1
log_pooler_errors = 1
```

## 📊 查询优化策略

### 1. 索引优化原则

#### 复合索引设计
```sql
-- 为高频查询创建复合索引
-- 查询: SELECT * FROM messages WHERE session_id = ? AND created_at > ? ORDER BY created_at DESC
CREATE INDEX idx_messages_session_time ON messages (session_id, created_at DESC);

-- 查询: SELECT * FROM agent_execution_summary WHERE user_id = ? AND agent_id = ? AND execution_start_time > ?
CREATE INDEX idx_agent_exec_user_agent_time ON agent_execution_summary (user_id, agent_id, execution_start_time);
```

#### 部分索引
```sql
-- 只为活跃数据创建索引
CREATE INDEX idx_active_sessions ON sessions (user_id, created_at) 
WHERE deleted_at IS NULL;

-- 只为启用的智能体创建索引
CREATE INDEX idx_enabled_agents ON agents (user_id, name) 
WHERE enabled = true AND deleted_at IS NULL;
```

#### 函数索引
```sql
-- 为JSON字段创建GIN索引
CREATE INDEX idx_agents_tools ON agents USING GIN (tool_ids);

-- 为向量字段创建向量索引
CREATE INDEX idx_document_vectors ON document_vectors USING ivfflat (embedding vector_cosine_ops);
```

### 2. 查询重写优化

#### 避免SELECT *
```sql
-- 不推荐
SELECT * FROM users WHERE email = ?;

-- 推荐
SELECT id, username, email, status FROM users WHERE email = ?;
```

#### 使用LIMIT限制结果集
```sql
-- 不推荐
SELECT * FROM messages WHERE session_id = ? ORDER BY created_at DESC;

-- 推荐
SELECT id, content, created_at FROM messages 
WHERE session_id = ? 
ORDER BY created_at DESC 
LIMIT 50;
```

#### 避免在WHERE子句中使用函数
```sql
-- 不推荐
SELECT * FROM users WHERE DATE(created_at) = CURRENT_DATE;

-- 推荐
SELECT * FROM users WHERE created_at >= CURRENT_DATE AND created_at < CURRENT_DATE + INTERVAL '1 day';
```

### 3. 分页查询优化

#### 使用游标分页
```sql
-- 传统OFFSET分页（不推荐用于大数据集）
SELECT * FROM messages 
WHERE session_id = ? 
ORDER BY created_at DESC 
LIMIT 20 OFFSET 40;

-- 游标分页（推荐）
SELECT * FROM messages 
WHERE session_id = ? AND created_at < ? 
ORDER BY created_at DESC 
LIMIT 20;
```

## 🔍 性能监控和诊断

### 1. 关键性能指标

#### 查询性能指标
```sql
-- 查看慢查询
SELECT query, calls, total_time, mean_time, rows
FROM pg_stat_statements 
ORDER BY mean_time DESC 
LIMIT 10;

-- 查看索引使用情况
SELECT schemaname, tablename, indexname, idx_scan, idx_tup_read, idx_tup_fetch
FROM pg_stat_user_indexes 
ORDER BY idx_scan DESC;
```

#### 系统性能指标
```sql
-- 查看表大小
SELECT schemaname, tablename, 
       pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) as size
FROM pg_tables 
WHERE schemaname = 'public'
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;

-- 查看连接状态
SELECT state, count(*) as connections
FROM pg_stat_activity 
GROUP BY state;
```

### 2. 性能分析工具

#### EXPLAIN ANALYZE
```sql
-- 分析查询执行计划
EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
SELECT * FROM messages 
WHERE session_id = ? AND created_at > ? 
ORDER BY created_at DESC;
```

#### pg_stat_statements扩展
```sql
-- 安装扩展
CREATE EXTENSION IF NOT EXISTS pg_stat_statements;

-- 查看查询统计
SELECT query, calls, total_time, mean_time, rows
FROM pg_stat_statements 
WHERE query LIKE '%messages%'
ORDER BY total_time DESC;
```

## 🛠️ 维护和优化

### 1. 定期维护任务

#### 统计信息更新
```sql
-- 更新所有表的统计信息
ANALYZE;

-- 更新特定表的统计信息
ANALYZE messages;
ANALYZE agent_execution_summary;
```

#### 表空间清理
```sql
-- 清理表空间
VACUUM ANALYZE;

-- 清理特定表
VACUUM ANALYZE messages;
VACUUM ANALYZE agent_execution_summary;
```

#### 索引重建
```sql
-- 重建碎片化的索引
REINDEX INDEX CONCURRENTLY idx_messages_session_time;
REINDEX INDEX CONCURRENTLY idx_agent_exec_user_agent_time;
```

### 2. 自动化维护脚本

#### 创建维护函数
```sql
-- 创建自动维护函数
CREATE OR REPLACE FUNCTION perform_maintenance()
RETURNS void AS $$
BEGIN
    -- 更新统计信息
    ANALYZE;
    
    -- 清理表空间
    VACUUM ANALYZE;
    
    -- 记录维护时间
    INSERT INTO maintenance_log (operation, executed_at) 
    VALUES ('daily_maintenance', NOW());
END;
$$ LANGUAGE plpgsql;

-- 创建维护日志表
CREATE TABLE IF NOT EXISTS maintenance_log (
    id SERIAL PRIMARY KEY,
    operation VARCHAR(100),
    executed_at TIMESTAMP DEFAULT NOW(),
    duration INTERVAL,
    status VARCHAR(20)
);
```

## 🚨 注意事项

### 1. 参数调优注意事项
- **循序渐进**: 不要一次性修改太多参数
- **测试验证**: 在生产环境应用前充分测试
- **监控观察**: 修改后密切监控系统性能
- **备份回滚**: 保留原始配置以便回滚

### 2. 索引优化注意事项
- **适度原则**: 不要过度创建索引
- **维护成本**: 考虑索引维护的开销
- **查询模式**: 基于实际查询模式设计索引
- **定期评估**: 定期评估索引的使用效果

### 3. 连接池注意事项
- **资源平衡**: 平衡连接池大小和系统资源
- **超时设置**: 设置合理的连接超时时间
- **监控告警**: 监控连接池使用情况
- **故障处理**: 实现连接池故障转移机制

## 🔮 下一步计划

### 短期目标
1. **参数调优**: 根据系统负载调整关键参数
2. **索引优化**: 创建和优化关键索引
3. **查询优化**: 重写和优化慢查询

### 中期目标
1. **连接池优化**: 实施外部连接池
2. **监控完善**: 建立完整的性能监控体系
3. **自动化维护**: 实现自动化维护脚本

### 长期目标
1. **读写分离**: 实施读写分离架构
2. **分库分表**: 评估和实施分库分表
3. **性能基准**: 建立长期性能基准和SLA

---

**重要提醒**: 数据库优化是一个持续的过程，需要根据实际使用情况和性能指标不断调整和优化。建议建立定期评估和优化的机制。
