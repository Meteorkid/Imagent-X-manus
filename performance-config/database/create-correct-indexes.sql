-- 基于实际表结构的性能索引优化脚本

-- 用户表索引优化（基于实际字段）
CREATE INDEX IF NOT EXISTS idx_users_nickname ON users(nickname);
CREATE INDEX IF NOT EXISTS idx_users_phone ON users(phone);
CREATE INDEX IF NOT EXISTS idx_users_is_admin ON users(is_admin);
CREATE INDEX IF NOT EXISTS idx_users_login_platform ON users(login_platform);
CREATE INDEX IF NOT EXISTS idx_users_github_id ON users(github_id);

-- Agent表索引优化（基于实际字段）
CREATE INDEX IF NOT EXISTS idx_agents_name ON agents(name);
CREATE INDEX IF NOT EXISTS idx_agents_enabled ON agents(enabled);
CREATE INDEX IF NOT EXISTS idx_agents_multi_modal ON agents(multi_modal);
CREATE INDEX IF NOT EXISTS idx_agents_published_version ON agents(published_version);

-- 会话表索引优化
CREATE INDEX IF NOT EXISTS idx_sessions_user_id ON sessions(user_id);
CREATE INDEX IF NOT EXISTS idx_sessions_agent_id ON sessions(agent_id);
CREATE INDEX IF NOT EXISTS idx_sessions_created_at ON sessions(created_at);

-- 消息表索引优化
CREATE INDEX IF NOT EXISTS idx_messages_session_id ON messages(session_id);
CREATE INDEX IF NOT EXISTS idx_messages_created_at ON messages(created_at);
CREATE INDEX IF NOT EXISTS idx_messages_role ON messages(role);

-- 工具表索引优化
CREATE INDEX IF NOT EXISTS idx_tools_name ON tools(name);
CREATE INDEX IF NOT EXISTS idx_tools_enabled ON tools(enabled);
CREATE INDEX IF NOT EXISTS idx_tools_type ON tools(type);

-- 账户表索引优化
CREATE INDEX IF NOT EXISTS idx_accounts_user_id ON accounts(user_id);
CREATE INDEX IF NOT EXISTS idx_accounts_created_at ON accounts(created_at);

-- 复合索引优化
CREATE INDEX IF NOT EXISTS idx_agents_user_enabled ON agents(user_id, enabled);
CREATE INDEX IF NOT EXISTS idx_sessions_user_agent ON sessions(user_id, agent_id);
CREATE INDEX IF NOT EXISTS idx_messages_session_time ON messages(session_id, created_at);
CREATE INDEX IF NOT EXISTS idx_users_email_platform ON users(email, login_platform);

-- 分析表统计信息
ANALYZE users;
ANALYZE agents;
ANALYZE sessions;
ANALYZE messages;
ANALYZE tools;
ANALYZE accounts;
