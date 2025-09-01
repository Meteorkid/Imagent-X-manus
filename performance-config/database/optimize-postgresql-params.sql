-- PostgreSQL性能参数优化

-- 内存配置
ALTER SYSTEM SET shared_buffers = '256MB';  -- 系统内存的25%
ALTER SYSTEM SET effective_cache_size = '1GB';  -- 系统内存的75%
ALTER SYSTEM SET work_mem = '4MB';  -- 排序和哈希操作内存
ALTER SYSTEM SET maintenance_work_mem = '64MB';  -- 维护操作内存

-- 连接配置
ALTER SYSTEM SET max_connections = 100;  -- 最大连接数
ALTER SYSTEM SET superuser_reserved_connections = 3;  -- 保留连接

-- 查询优化
ALTER SYSTEM SET random_page_cost = 1.1;  -- SSD存储
ALTER SYSTEM SET effective_io_concurrency = 200;  -- 并发I/O
ALTER SYSTEM SET checkpoint_completion_target = 0.9;  -- 检查点完成目标

-- 日志配置
ALTER SYSTEM SET log_min_duration_statement = 1000;  -- 慢查询日志阈值(毫秒)
ALTER SYSTEM SET log_checkpoints = on;  -- 记录检查点
ALTER SYSTEM SET log_connections = on;  -- 记录连接
ALTER SYSTEM SET log_disconnections = on;  -- 记录断开连接

-- 重新加载配置
SELECT pg_reload_conf();
