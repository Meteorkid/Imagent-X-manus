-- 数据库索引优化脚本

-- 用户表索引优化
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_username ON users(username);
CREATE INDEX IF NOT EXISTS idx_users_status ON users(status);
CREATE INDEX IF NOT EXISTS idx_users_created_at ON users(created_at);

-- Agent表索引优化
CREATE INDEX IF NOT EXISTS idx_agents_user_id ON agents(created_by);
CREATE INDEX IF NOT EXISTS idx_agents_status ON agents(status);
CREATE INDEX IF NOT EXISTS idx_agents_created_at ON agents(created_at);
CREATE INDEX IF NOT EXISTS idx_agents_model ON agents(model);

-- 会话表索引优化
CREATE INDEX IF NOT EXISTS idx_sessions_user_id ON sessions(user_id);
CREATE INDEX IF NOT EXISTS idx_sessions_agent_id ON sessions(agent_id);
CREATE INDEX IF NOT EXISTS idx_sessions_created_at ON sessions(created_at);
CREATE INDEX IF NOT EXISTS idx_sessions_status ON sessions(status);

-- 消息表索引优化
CREATE INDEX IF NOT EXISTS idx_messages_session_id ON messages(session_id);
CREATE INDEX IF NOT EXISTS idx_messages_created_at ON messages(created_at);
CREATE INDEX IF NOT EXISTS idx_messages_role ON messages(role);

-- 工具表索引优化
CREATE INDEX IF NOT EXISTS idx_tools_user_id ON tools(created_by);
CREATE INDEX IF NOT EXISTS idx_tools_status ON tools(status);
CREATE INDEX IF NOT EXISTS idx_tools_type ON tools(type);

-- 账户表索引优化
CREATE INDEX IF NOT EXISTS idx_accounts_user_id ON accounts(user_id);
CREATE INDEX IF NOT EXISTS idx_accounts_created_at ON accounts(created_at);

-- 复合索引优化
CREATE INDEX IF NOT EXISTS idx_agents_user_status ON agents(created_by, status);
CREATE INDEX IF NOT EXISTS idx_sessions_user_agent ON sessions(user_id, agent_id);
CREATE INDEX IF NOT EXISTS idx_messages_session_time ON messages(session_id, created_at);

-- 分区表优化（适用于大数据量）
-- CREATE TABLE messages_partitioned (
--     LIKE messages INCLUDING ALL
-- ) PARTITION BY RANGE (created_at);

-- 创建分区
-- CREATE TABLE messages_2024_01 PARTITION OF messages_partitioned
--     FOR VALUES FROM ('2024-01-01') TO ('2024-02-01');
