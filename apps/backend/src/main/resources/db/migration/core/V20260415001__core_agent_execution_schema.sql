-- Core baseline for agent execution trace tables.
-- This migration is idempotent and only governs core tracing tables.

CREATE TABLE IF NOT EXISTS public.agent_execution_details (
    id BIGSERIAL PRIMARY KEY NOT NULL,
    message_content TEXT,
    message_type CHARACTER VARYING(32) NOT NULL,
    model_endpoint CHARACTER VARYING(128),
    provider_name CHARACTER VARYING(64),
    message_tokens INTEGER,
    model_call_time INTEGER,
    tool_name CHARACTER VARYING(128),
    tool_request_args TEXT,
    tool_response_data TEXT,
    tool_execution_time INTEGER,
    tool_success BOOLEAN,
    is_fallback_used BOOLEAN DEFAULT FALSE,
    fallback_reason TEXT,
    fallback_from_endpoint CHARACTER VARYING(128),
    fallback_to_endpoint CHARACTER VARYING(128),
    step_cost NUMERIC(10, 6),
    step_success BOOLEAN NOT NULL,
    step_error_message TEXT,
    created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITHOUT TIME ZONE,
    session_id CHARACTER VARYING(64) NOT NULL DEFAULT '',
    fallback_from_provider CHARACTER VARYING(255),
    fallback_to_provider CHARACTER VARYING(255)
);

CREATE TABLE IF NOT EXISTS public.agent_execution_summary (
    id BIGSERIAL PRIMARY KEY NOT NULL,
    user_id CHARACTER VARYING(64) NOT NULL,
    session_id CHARACTER VARYING(64) NOT NULL,
    agent_id CHARACTER VARYING(64) NOT NULL,
    execution_start_time TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    execution_end_time TIMESTAMP WITHOUT TIME ZONE,
    total_execution_time INTEGER,
    total_input_tokens INTEGER DEFAULT 0,
    total_output_tokens INTEGER DEFAULT 0,
    total_tokens INTEGER DEFAULT 0,
    tool_call_count INTEGER DEFAULT 0,
    total_tool_execution_time INTEGER DEFAULT 0,
    total_cost NUMERIC(10, 6) DEFAULT 0,
    execution_success BOOLEAN NOT NULL,
    error_phase CHARACTER VARYING(64),
    error_message TEXT,
    created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITHOUT TIME ZONE
);

CREATE INDEX IF NOT EXISTS idx_agent_exec_details_tool
    ON public.agent_execution_details USING BTREE (tool_name);
CREATE INDEX IF NOT EXISTS idx_agent_exec_details_model
    ON public.agent_execution_details USING BTREE (model_endpoint);
CREATE INDEX IF NOT EXISTS idx_agent_exec_details_session_type
    ON public.agent_execution_details USING BTREE (session_id, message_type);
CREATE INDEX IF NOT EXISTS idx_agent_execution_details_model_endpoint
    ON public.agent_execution_details USING BTREE (model_endpoint);
CREATE INDEX IF NOT EXISTS idx_agent_execution_details_fallback
    ON public.agent_execution_details USING BTREE (is_fallback_used)
    WHERE (is_fallback_used = TRUE);

CREATE INDEX IF NOT EXISTS idx_agent_exec_summary_user_time
    ON public.agent_execution_summary USING BTREE (user_id, execution_start_time);
CREATE INDEX IF NOT EXISTS idx_agent_exec_summary_session
    ON public.agent_execution_summary USING BTREE (session_id);
CREATE INDEX IF NOT EXISTS idx_agent_exec_summary_agent
    ON public.agent_execution_summary USING BTREE (agent_id);
