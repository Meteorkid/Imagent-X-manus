-- Upgrade legacy trace schema (trace_id/step_type/model_id model) into current session-based model.
-- Safe for repeated execution.

DO
$$
BEGIN
    IF to_regclass('public.agent_execution_details') IS NOT NULL THEN
        IF EXISTS (SELECT 1 FROM information_schema.columns
                   WHERE table_schema = 'public'
                     AND table_name = 'agent_execution_details'
                     AND column_name = 'trace_id')
            AND NOT EXISTS (SELECT 1 FROM information_schema.columns
                            WHERE table_schema = 'public'
                              AND table_name = 'agent_execution_details'
                              AND column_name = 'session_id') THEN
            ALTER TABLE public.agent_execution_details RENAME COLUMN trace_id TO session_id;
        END IF;

        IF EXISTS (SELECT 1 FROM information_schema.columns
                   WHERE table_schema = 'public'
                     AND table_name = 'agent_execution_details'
                     AND column_name = 'model_id')
            AND NOT EXISTS (SELECT 1 FROM information_schema.columns
                            WHERE table_schema = 'public'
                              AND table_name = 'agent_execution_details'
                              AND column_name = 'model_endpoint') THEN
            ALTER TABLE public.agent_execution_details RENAME COLUMN model_id TO model_endpoint;
        END IF;

        IF EXISTS (SELECT 1 FROM information_schema.columns
                   WHERE table_schema = 'public'
                     AND table_name = 'agent_execution_details'
                     AND column_name = 'fallback_from_model')
            AND NOT EXISTS (SELECT 1 FROM information_schema.columns
                            WHERE table_schema = 'public'
                              AND table_name = 'agent_execution_details'
                              AND column_name = 'fallback_from_endpoint') THEN
            ALTER TABLE public.agent_execution_details RENAME COLUMN fallback_from_model TO fallback_from_endpoint;
        END IF;

        IF EXISTS (SELECT 1 FROM information_schema.columns
                   WHERE table_schema = 'public'
                     AND table_name = 'agent_execution_details'
                     AND column_name = 'fallback_to_model')
            AND NOT EXISTS (SELECT 1 FROM information_schema.columns
                            WHERE table_schema = 'public'
                              AND table_name = 'agent_execution_details'
                              AND column_name = 'fallback_to_endpoint') THEN
            ALTER TABLE public.agent_execution_details RENAME COLUMN fallback_to_model TO fallback_to_endpoint;
        END IF;

        ALTER TABLE public.agent_execution_details
            ADD COLUMN IF NOT EXISTS session_id CHARACTER VARYING(64) DEFAULT '',
            ADD COLUMN IF NOT EXISTS model_endpoint CHARACTER VARYING(128),
            ADD COLUMN IF NOT EXISTS fallback_from_endpoint CHARACTER VARYING(128),
            ADD COLUMN IF NOT EXISTS fallback_to_endpoint CHARACTER VARYING(128),
            ADD COLUMN IF NOT EXISTS fallback_from_provider CHARACTER VARYING(255),
            ADD COLUMN IF NOT EXISTS fallback_to_provider CHARACTER VARYING(255);

        IF EXISTS (SELECT 1 FROM information_schema.columns
                   WHERE table_schema = 'public'
                     AND table_name = 'agent_execution_details'
                     AND column_name = 'step_type') THEN
            UPDATE public.agent_execution_details
            SET message_type = COALESCE(message_type, step_type)
            WHERE message_type IS NULL;
        END IF;

        IF EXISTS (SELECT 1 FROM information_schema.columns
                   WHERE table_schema = 'public'
                     AND table_name = 'agent_execution_details'
                     AND column_name = 'trace_id') THEN
            EXECUTE 'UPDATE public.agent_execution_details SET session_id = COALESCE(session_id, trace_id, '''') WHERE session_id IS NULL';
        END IF;

        UPDATE public.agent_execution_details
        SET session_id = ''
        WHERE session_id IS NULL;

        ALTER TABLE public.agent_execution_details
            ALTER COLUMN session_id SET DEFAULT '',
            ALTER COLUMN session_id SET NOT NULL,
            ALTER COLUMN message_type SET NOT NULL,
            ALTER COLUMN step_success SET NOT NULL;

        ALTER TABLE public.agent_execution_details
            DROP COLUMN IF EXISTS trace_id,
            DROP COLUMN IF EXISTS sequence_no,
            DROP COLUMN IF EXISTS step_type;

        DROP INDEX IF EXISTS idx_agent_exec_details_trace_seq;
        DROP INDEX IF EXISTS idx_agent_exec_details_trace_type;
        DROP INDEX IF EXISTS idx_agent_exec_details_tool;
        DROP INDEX IF EXISTS idx_agent_exec_details_model;

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
    END IF;

    IF to_regclass('public.agent_execution_summary') IS NOT NULL THEN
        ALTER TABLE public.agent_execution_summary
            ADD COLUMN IF NOT EXISTS session_id CHARACTER VARYING(64),
            ADD COLUMN IF NOT EXISTS total_input_tokens INTEGER DEFAULT 0,
            ADD COLUMN IF NOT EXISTS total_output_tokens INTEGER DEFAULT 0,
            ADD COLUMN IF NOT EXISTS total_tokens INTEGER DEFAULT 0,
            ADD COLUMN IF NOT EXISTS tool_call_count INTEGER DEFAULT 0,
            ADD COLUMN IF NOT EXISTS total_tool_execution_time INTEGER DEFAULT 0,
            ADD COLUMN IF NOT EXISTS total_cost NUMERIC(10, 6) DEFAULT 0;

        IF EXISTS (SELECT 1 FROM information_schema.columns
                   WHERE table_schema = 'public'
                     AND table_name = 'agent_execution_summary'
                     AND column_name = 'trace_id') THEN
            EXECUTE 'UPDATE public.agent_execution_summary SET session_id = COALESCE(session_id, trace_id, '''') WHERE session_id IS NULL';
        END IF;

        UPDATE public.agent_execution_summary
        SET session_id = ''
        WHERE session_id IS NULL;

        ALTER TABLE public.agent_execution_summary
            ALTER COLUMN session_id SET NOT NULL;

        DROP INDEX IF EXISTS agent_execution_summary_trace_id_key;
        DROP INDEX IF EXISTS idx_agent_exec_summary_trace;
        ALTER TABLE public.agent_execution_summary
            DROP COLUMN IF EXISTS trace_id;

        CREATE INDEX IF NOT EXISTS idx_agent_exec_summary_user_time
            ON public.agent_execution_summary USING BTREE (user_id, execution_start_time);
        CREATE INDEX IF NOT EXISTS idx_agent_exec_summary_session
            ON public.agent_execution_summary USING BTREE (session_id);
        CREATE INDEX IF NOT EXISTS idx_agent_exec_summary_agent
            ON public.agent_execution_summary USING BTREE (agent_id);
    END IF;
END
$$;
