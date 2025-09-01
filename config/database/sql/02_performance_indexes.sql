-- ImagentX 性能优化索引
-- 创建时间: 2025-09-01
-- 说明: 为高频查询创建关键索引

-- 1. 用户相关索引
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_users_email ON users USING btree (email);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_users_username ON users USING btree (username);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_users_created_at ON users USING btree (created_at);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_users_status ON users USING btree (status);

-- 2. 会话相关索引
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_sessions_user_id ON sessions USING btree (user_id);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_sessions_agent_id ON sessions USING btree (agent_id);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_sessions_created_at ON sessions USING btree (created_at);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_sessions_user_agent ON sessions USING btree (user_id, agent_id);

-- 3. 消息相关索引
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_messages_session_id ON messages USING btree (session_id);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_messages_created_at ON messages USING btree (created_at);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_messages_session_time ON messages USING btree (session_id, created_at);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_messages_type ON messages USING btree (message_type);

-- 4. 智能体执行索引优化
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_agent_exec_summary_user_agent_time ON agent_execution_summary USING btree (user_id, agent_id, execution_start_time);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_agent_exec_summary_success_time ON agent_execution_summary USING btree (execution_success, execution_start_time);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_agent_exec_summary_cost ON agent_execution_summary USING btree (total_cost);

-- 5. 工具调用索引
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_agent_exec_details_tool_time ON agent_execution_details USING btree (tool_name, created_at);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_agent_exec_details_model_time ON agent_execution_details USING btree (model_id, created_at);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_agent_exec_details_success ON agent_execution_details USING btree (step_success, created_at);

-- 6. 知识库相关索引
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_knowledge_base_user ON knowledge_base USING btree (user_id);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_knowledge_base_status ON knowledge_base USING btree (status);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_knowledge_base_created_at ON knowledge_base USING btree (created_at);

-- 7. 文档向量索引（pgvector）
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_document_vectors_embedding ON document_vectors USING ivfflat (embedding vector_cosine_ops) WITH (lists = 100);

-- 8. 复合索引优化
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_agent_exec_summary_user_session_time ON agent_execution_summary USING btree (user_id, session_id, execution_start_time DESC);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_messages_session_type_time ON messages USING btree (session_id, message_type, created_at DESC);

-- 9. 部分索引（针对活跃数据）
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_active_sessions ON sessions USING btree (user_id, created_at) WHERE deleted_at IS NULL;
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_active_agents ON agents USING btree (user_id, enabled) WHERE deleted_at IS NULL;

-- 10. 函数索引（针对JSON字段）
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_agents_tool_ids ON agents USING gin (tool_ids);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_agents_knowledge_base_ids ON agents USING gin (knowledge_base_ids);

-- 索引创建完成
SELECT 'Performance indexes created successfully' as status;
