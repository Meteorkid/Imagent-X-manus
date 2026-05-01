-- Repeatable assertions: fail migration immediately if core schema drifts.

DO
$$
DECLARE
    missing_count integer;
BEGIN
    -- Required columns in agent_execution_details
    SELECT COUNT(*)
    INTO missing_count
    FROM (
        SELECT unnest(ARRAY[
            'id','session_id','message_content','message_type','model_endpoint','provider_name',
            'message_tokens','model_call_time','tool_name','tool_request_args','tool_response_data',
            'tool_execution_time','tool_success','is_fallback_used','fallback_reason',
            'fallback_from_endpoint','fallback_to_endpoint','step_cost','step_success',
            'step_error_message','created_at','updated_at','deleted_at',
            'fallback_from_provider','fallback_to_provider'
        ]) AS col
    ) expected
    LEFT JOIN information_schema.columns c
      ON c.table_schema = 'public'
     AND c.table_name = 'agent_execution_details'
     AND c.column_name = expected.col
    WHERE c.column_name IS NULL;

    IF missing_count > 0 THEN
        RAISE EXCEPTION 'agent_execution_details missing % required columns', missing_count;
    END IF;

    -- Required columns in agent_execution_summary
    SELECT COUNT(*)
    INTO missing_count
    FROM (
        SELECT unnest(ARRAY[
            'id','user_id','session_id','agent_id','execution_start_time','execution_end_time',
            'total_execution_time','total_input_tokens','total_output_tokens','total_tokens',
            'tool_call_count','total_tool_execution_time','total_cost','execution_success',
            'error_phase','error_message','created_at','updated_at','deleted_at'
        ]) AS col
    ) expected
    LEFT JOIN information_schema.columns c
      ON c.table_schema = 'public'
     AND c.table_name = 'agent_execution_summary'
     AND c.column_name = expected.col
    WHERE c.column_name IS NULL;

    IF missing_count > 0 THEN
        RAISE EXCEPTION 'agent_execution_summary missing % required columns', missing_count;
    END IF;

    -- Legacy trace indexes must not exist.
    IF EXISTS (
        SELECT 1
        FROM pg_indexes
        WHERE schemaname = 'public'
          AND tablename IN ('agent_execution_details','agent_execution_summary')
          AND indexname IN (
              'idx_agent_exec_details_trace_seq',
              'idx_agent_exec_details_trace_type',
              'idx_agent_exec_summary_trace',
              'agent_execution_summary_trace_id_key'
          )
    ) THEN
        RAISE EXCEPTION 'legacy trace indexes still exist';
    END IF;
END
$$;
