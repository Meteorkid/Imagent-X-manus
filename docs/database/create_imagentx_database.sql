-- 创建imagentx数据库的SQL脚本
-- 此脚本用于创建新的imagentx数据库和用户

-- ========================================
-- 数据库创建
-- ========================================

-- 创建新数据库
CREATE DATABASE imagentx;

-- ========================================
-- 用户创建
-- ========================================

-- 创建新用户（如果不存在）
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'imagentx_user') THEN
        CREATE USER imagentx_user WITH PASSWORD 'imagentx_pass';
    END IF;
END
$$;

-- ========================================
-- 权限授予
-- ========================================

-- 授予数据库权限
GRANT ALL PRIVILEGES ON DATABASE imagentx TO imagentx_user;

-- 连接到新数据库并授予模式权限
\c imagentx;

-- 授予模式权限
GRANT ALL PRIVILEGES ON SCHEMA public TO imagentx_user;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO imagentx_user;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO imagentx_user;

-- 设置默认权限
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO imagentx_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO imagentx_user;

-- ========================================
-- 验证结果
-- ========================================

-- 显示创建结果
SELECT 'Database creation completed' as status;

-- 验证数据库和用户
SELECT current_database() as database_name, current_user as current_user;

-- ========================================
-- 使用说明
-- ========================================
--
-- 执行此脚本前请确保：
-- 1. 以postgres用户身份执行
-- 2. 有足够的权限创建数据库和用户
--
-- 执行命令：
-- docker exec -i agentx-app psql -U postgres < create_imagentx_database.sql
--
-- 验证命令：
-- docker exec agentx-app psql -U imagentx_user -d imagentx -c "SELECT current_database(), current_user;"
