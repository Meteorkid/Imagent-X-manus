-- 迁移后自检：检查 agent_execution_* 是否与当前后端实体预期一致
-- 输出格式：check_item | status(PASS/FAIL) | details

WITH expected_columns AS (
    SELECT 'agent_execution_details'::text AS table_name, unnest(ARRAY[
        'id','session_id','message_content','message_type','model_endpoint','provider_name',
        'message_tokens','model_call_time','tool_name','tool_request_args','tool_response_data',
        'tool_execution_time','tool_success','is_fallback_used','fallback_reason',
        'fallback_from_endpoint','fallback_to_endpoint','step_cost','step_success',
        'step_error_message','created_at','updated_at','deleted_at',
        'fallback_from_provider','fallback_to_provider'
    ]) AS column_name
    UNION ALL
    SELECT 'agent_execution_summary', unnest(ARRAY[
        'id','user_id','session_id','agent_id','execution_start_time','execution_end_time',
        'total_execution_time','total_input_tokens','total_output_tokens','total_tokens',
        'tool_call_count','total_tool_execution_time','total_cost','execution_success',
        'error_phase','error_message','created_at','updated_at','deleted_at'
    ])
),
actual_columns AS (
    SELECT table_name, column_name
    FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name IN ('agent_execution_details', 'agent_execution_summary')
),
missing_columns AS (
    SELECT e.table_name, e.column_name
    FROM expected_columns e
    LEFT JOIN actual_columns a
      ON a.table_name = e.table_name
     AND a.column_name = e.column_name
    WHERE a.column_name IS NULL
),
unexpected_columns AS (
    SELECT a.table_name, a.column_name
    FROM actual_columns a
    LEFT JOIN expected_columns e
      ON e.table_name = a.table_name
     AND e.column_name = a.column_name
    WHERE e.column_name IS NULL
),
expected_indexes AS (
    SELECT 'agent_execution_details'::text AS table_name, unnest(ARRAY[
        'agent_execution_details_pkey',
        'idx_agent_exec_details_tool',
        'idx_agent_exec_details_model',
        'idx_agent_exec_details_session_type',
        'idx_agent_execution_details_model_endpoint',
        'idx_agent_execution_details_fallback'
    ]) AS index_name
    UNION ALL
    SELECT 'agent_execution_summary', unnest(ARRAY[
        'agent_execution_summary_pkey',
        'idx_agent_exec_summary_user_time',
        'idx_agent_exec_summary_session',
        'idx_agent_exec_summary_agent'
    ])
),
actual_indexes AS (
    SELECT tablename AS table_name, indexname AS index_name
    FROM pg_indexes
    WHERE schemaname = 'public'
      AND tablename IN ('agent_execution_details', 'agent_execution_summary')
),
missing_indexes AS (
    SELECT e.table_name, e.index_name
    FROM expected_indexes e
    LEFT JOIN actual_indexes a
      ON a.table_name = e.table_name
     AND a.index_name = e.index_name
    WHERE a.index_name IS NULL
),
forbidden_indexes AS (
    SELECT tablename AS table_name, indexname AS index_name
    FROM pg_indexes
    WHERE schemaname = 'public'
      AND tablename IN ('agent_execution_details', 'agent_execution_summary')
      AND indexname IN (
          'idx_agent_exec_details_trace_seq',
          'idx_agent_exec_details_trace_type',
          'idx_agent_exec_summary_trace',
          'agent_execution_summary_trace_id_key'
      )
),
constraint_checks AS (
    SELECT 'details.session_id_not_null' AS check_item,
           CASE WHEN EXISTS (
                    SELECT 1
                    FROM information_schema.columns
                    WHERE table_schema = 'public'
                      AND table_name = 'agent_execution_details'
                      AND column_name = 'session_id'
                      AND is_nullable = 'NO'
                ) THEN 'PASS' ELSE 'FAIL' END AS status,
           'agent_execution_details.session_id is NOT NULL' AS details
    UNION ALL
    SELECT 'details.message_type_not_null',
           CASE WHEN EXISTS (
                    SELECT 1
                    FROM information_schema.columns
                    WHERE table_schema = 'public'
                      AND table_name = 'agent_execution_details'
                      AND column_name = 'message_type'
                      AND is_nullable = 'NO'
                ) THEN 'PASS' ELSE 'FAIL' END,
           'agent_execution_details.message_type is NOT NULL'
    UNION ALL
    SELECT 'details.step_success_not_null',
           CASE WHEN EXISTS (
                    SELECT 1
                    FROM information_schema.columns
                    WHERE table_schema = 'public'
                      AND table_name = 'agent_execution_details'
                      AND column_name = 'step_success'
                      AND is_nullable = 'NO'
                ) THEN 'PASS' ELSE 'FAIL' END,
           'agent_execution_details.step_success is NOT NULL'
    UNION ALL
    SELECT 'summary.session_id_not_null',
           CASE WHEN EXISTS (
                    SELECT 1
                    FROM information_schema.columns
                    WHERE table_schema = 'public'
                      AND table_name = 'agent_execution_summary'
                      AND column_name = 'session_id'
                      AND is_nullable = 'NO'
                ) THEN 'PASS' ELSE 'FAIL' END,
           'agent_execution_summary.session_id is NOT NULL'
)
SELECT 'columns.missing' AS check_item,
       CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS status,
       COALESCE(string_agg(table_name || '.' || column_name, ', ' ORDER BY table_name, column_name), 'none') AS details
FROM missing_columns
UNION ALL
SELECT 'columns.unexpected',
       CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END,
       COALESCE(string_agg(table_name || '.' || column_name, ', ' ORDER BY table_name, column_name), 'none')
FROM unexpected_columns
UNION ALL
SELECT 'indexes.missing',
       CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END,
       COALESCE(string_agg(table_name || '.' || index_name, ', ' ORDER BY table_name, index_name), 'none')
FROM missing_indexes
UNION ALL
SELECT 'indexes.forbidden_old_trace',
       CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END,
       COALESCE(string_agg(table_name || '.' || index_name, ', ' ORDER BY table_name, index_name), 'none')
FROM forbidden_indexes
UNION ALL
SELECT check_item, status, details
FROM constraint_checks
ORDER BY check_item;
