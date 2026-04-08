--
-- PostgreSQL database dump
--

\restrict 7pNeG7ui1dwhTYJ9EOOZDqwabiUbxrbSdWF6GyqSHYaxnw9dmKaDpsktWh7n2UA

-- Dumped from database version 15.14 (Debian 15.14-1.pgdg13+1)
-- Dumped by pg_dump version 15.14 (Debian 15.14-1.pgdg13+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: accounts; Type: TABLE; Schema: public; Owner: imagentx_user
--

CREATE TABLE public.accounts (
    id character varying(64) NOT NULL,
    user_id character varying(64) NOT NULL,
    balance numeric(20,8) DEFAULT 0.00000000,
    credit numeric(20,8) DEFAULT 0.00000000,
    total_consumed numeric(20,8) DEFAULT 0.00000000,
    last_transaction_at timestamp without time zone,
    deleted_at timestamp without time zone,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.accounts OWNER TO imagentx_user;

--
-- Name: TABLE accounts; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON TABLE public.accounts IS '用户账户表，存储用户余额和消费记录';


--
-- Name: COLUMN accounts.user_id; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.accounts.user_id IS '用户ID';


--
-- Name: COLUMN accounts.balance; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.accounts.balance IS '账户余额';


--
-- Name: COLUMN accounts.credit; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.accounts.credit IS '信用额度';


--
-- Name: COLUMN accounts.total_consumed; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.accounts.total_consumed IS '总消费金额';


--
-- Name: COLUMN accounts.last_transaction_at; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.accounts.last_transaction_at IS '最后交易时间';


--
-- Name: agent_execution_details; Type: TABLE; Schema: public; Owner: imagentx_user
--

CREATE TABLE public.agent_execution_details (
    id bigint NOT NULL,
    trace_id character varying(64) NOT NULL,
    sequence_no integer NOT NULL,
    step_type character varying(32) NOT NULL,
    message_content text,
    message_type character varying(32),
    model_id character varying(128),
    provider_name character varying(64),
    message_tokens integer,
    model_call_time integer,
    tool_name character varying(128),
    tool_request_args text,
    tool_response_data text,
    tool_execution_time integer,
    tool_success boolean,
    is_fallback_used boolean DEFAULT false,
    fallback_reason text,
    fallback_from_model character varying(128),
    fallback_to_model character varying(128),
    step_cost numeric(10,6),
    step_success boolean NOT NULL,
    step_error_message text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    deleted_at timestamp without time zone
);


ALTER TABLE public.agent_execution_details OWNER TO imagentx_user;

--
-- Name: TABLE agent_execution_details; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON TABLE public.agent_execution_details IS 'Agent执行链路详细记录表，记录每次执行的详细过程';


--
-- Name: COLUMN agent_execution_details.trace_id; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.agent_execution_details.trace_id IS '关联汇总表的追踪ID';


--
-- Name: COLUMN agent_execution_details.sequence_no; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.agent_execution_details.sequence_no IS '执行序号，同一trace_id内递增';


--
-- Name: COLUMN agent_execution_details.step_type; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.agent_execution_details.step_type IS '步骤类型：USER_MESSAGE, AI_RESPONSE, TOOL_CALL';


--
-- Name: COLUMN agent_execution_details.message_content; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.agent_execution_details.message_content IS '统一的消息内容（用户消息/AI响应/工具调用描述）';


--
-- Name: COLUMN agent_execution_details.message_type; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.agent_execution_details.message_type IS '消息类型：USER_MESSAGE, AI_RESPONSE, TOOL_CALL';


--
-- Name: COLUMN agent_execution_details.model_id; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.agent_execution_details.model_id IS '此次使用的模型ID';


--
-- Name: COLUMN agent_execution_details.tool_request_args; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.agent_execution_details.tool_request_args IS '工具调用入参(JSON格式)';


--
-- Name: COLUMN agent_execution_details.tool_response_data; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.agent_execution_details.tool_response_data IS '工具调用出参(JSON格式)';


--
-- Name: COLUMN agent_execution_details.is_fallback_used; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.agent_execution_details.is_fallback_used IS '是否触发了平替/降级';


--
-- Name: agent_execution_details_id_seq; Type: SEQUENCE; Schema: public; Owner: imagentx_user
--

CREATE SEQUENCE public.agent_execution_details_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.agent_execution_details_id_seq OWNER TO imagentx_user;

--
-- Name: agent_execution_details_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: imagentx_user
--

ALTER SEQUENCE public.agent_execution_details_id_seq OWNED BY public.agent_execution_details.id;


--
-- Name: agent_execution_summary; Type: TABLE; Schema: public; Owner: imagentx_user
--

CREATE TABLE public.agent_execution_summary (
    id bigint NOT NULL,
    trace_id character varying(64) NOT NULL,
    user_id character varying(64) NOT NULL,
    session_id character varying(64) NOT NULL,
    agent_id character varying(64) NOT NULL,
    execution_start_time timestamp without time zone NOT NULL,
    execution_end_time timestamp without time zone,
    total_execution_time integer,
    total_input_tokens integer DEFAULT 0,
    total_output_tokens integer DEFAULT 0,
    total_tokens integer DEFAULT 0,
    tool_call_count integer DEFAULT 0,
    total_tool_execution_time integer DEFAULT 0,
    total_cost numeric(10,6) DEFAULT 0,
    execution_success boolean NOT NULL,
    error_phase character varying(64),
    error_message text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    deleted_at timestamp without time zone
);


ALTER TABLE public.agent_execution_summary OWNER TO imagentx_user;

--
-- Name: TABLE agent_execution_summary; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON TABLE public.agent_execution_summary IS 'Agent执行链路汇总表，记录每次Agent执行的汇总信息';


--
-- Name: COLUMN agent_execution_summary.trace_id; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.agent_execution_summary.trace_id IS '执行追踪ID，唯一标识一次完整执行';


--
-- Name: COLUMN agent_execution_summary.user_id; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.agent_execution_summary.user_id IS '用户ID (String类型UUID)';


--
-- Name: COLUMN agent_execution_summary.session_id; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.agent_execution_summary.session_id IS '会话ID，作为追踪的唯一标识';


--
-- Name: COLUMN agent_execution_summary.agent_id; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.agent_execution_summary.agent_id IS 'Agent ID (String类型UUID)';


--
-- Name: COLUMN agent_execution_summary.total_execution_time; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.agent_execution_summary.total_execution_time IS '总执行时间(毫秒)';


--
-- Name: COLUMN agent_execution_summary.total_tokens; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.agent_execution_summary.total_tokens IS '总Token数';


--
-- Name: COLUMN agent_execution_summary.tool_call_count; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.agent_execution_summary.tool_call_count IS '工具调用总次数';


--
-- Name: COLUMN agent_execution_summary.total_cost; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.agent_execution_summary.total_cost IS '总成本费用';


--
-- Name: COLUMN agent_execution_summary.execution_success; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.agent_execution_summary.execution_success IS '执行是否成功';


--
-- Name: agent_execution_summary_id_seq; Type: SEQUENCE; Schema: public; Owner: imagentx_user
--

CREATE SEQUENCE public.agent_execution_summary_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.agent_execution_summary_id_seq OWNER TO imagentx_user;

--
-- Name: agent_execution_summary_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: imagentx_user
--

ALTER SEQUENCE public.agent_execution_summary_id_seq OWNED BY public.agent_execution_summary.id;


--
-- Name: agent_tasks; Type: TABLE; Schema: public; Owner: imagentx_user
--

CREATE TABLE public.agent_tasks (
    id character varying(36) NOT NULL,
    session_id character varying(36) NOT NULL,
    user_id character varying(36) NOT NULL,
    parent_task_id character varying(36),
    task_name character varying(255) NOT NULL,
    description text,
    status character varying(20),
    progress integer DEFAULT 0,
    start_time timestamp without time zone,
    end_time timestamp without time zone,
    task_result text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp without time zone
);


ALTER TABLE public.agent_tasks OWNER TO imagentx_user;

--
-- Name: TABLE agent_tasks; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON TABLE public.agent_tasks IS '任务实体类';


--
-- Name: COLUMN agent_tasks.id; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.agent_tasks.id IS '任务ID';


--
-- Name: COLUMN agent_tasks.session_id; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.agent_tasks.session_id IS '所属会话ID';


--
-- Name: COLUMN agent_tasks.user_id; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.agent_tasks.user_id IS '用户ID';


--
-- Name: COLUMN agent_tasks.parent_task_id; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.agent_tasks.parent_task_id IS '父任务ID';


--
-- Name: COLUMN agent_tasks.task_name; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.agent_tasks.task_name IS '任务名称';


--
-- Name: COLUMN agent_tasks.description; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.agent_tasks.description IS '任务描述';


--
-- Name: COLUMN agent_tasks.status; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.agent_tasks.status IS '任务状态';


--
-- Name: COLUMN agent_tasks.progress; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.agent_tasks.progress IS '任务进度,存放父任务中';


--
-- Name: COLUMN agent_tasks.start_time; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.agent_tasks.start_time IS '开始时间';


--
-- Name: COLUMN agent_tasks.end_time; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.agent_tasks.end_time IS '结束时间';


--
-- Name: COLUMN agent_tasks.task_result; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.agent_tasks.task_result IS '任务结果';


--
-- Name: COLUMN agent_tasks.created_at; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.agent_tasks.created_at IS '创建时间';


--
-- Name: COLUMN agent_tasks.updated_at; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.agent_tasks.updated_at IS '更新时间';


--
-- Name: COLUMN agent_tasks.deleted_at; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.agent_tasks.deleted_at IS '逻辑删除时间';


--
-- Name: agent_versions; Type: TABLE; Schema: public; Owner: imagentx_user
--

CREATE TABLE public.agent_versions (
    id character varying(36) NOT NULL,
    agent_id character varying(36) NOT NULL,
    name character varying(255) NOT NULL,
    avatar character varying(255),
    description text,
    version_number character varying(20) NOT NULL,
    system_prompt text,
    welcome_message text,
    tool_ids jsonb,
    knowledge_base_ids jsonb,
    change_log text,
    publish_status integer DEFAULT 1,
    reject_reason text,
    review_time timestamp without time zone,
    published_at timestamp without time zone,
    user_id character varying(36) NOT NULL,
    tool_preset_params jsonb,
    multi_modal boolean DEFAULT false,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp without time zone
);


ALTER TABLE public.agent_versions OWNER TO imagentx_user;

--
-- Name: TABLE agent_versions; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON TABLE public.agent_versions IS 'Agent版本实体类，代表一个Agent的发布版本';


--
-- Name: COLUMN agent_versions.id; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.agent_versions.id IS '版本唯一ID';


--
-- Name: COLUMN agent_versions.agent_id; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.agent_versions.agent_id IS '关联的Agent ID';


--
-- Name: COLUMN agent_versions.name; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.agent_versions.name IS 'Agent名称';


--
-- Name: COLUMN agent_versions.avatar; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.agent_versions.avatar IS 'Agent头像URL';


--
-- Name: COLUMN agent_versions.description; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.agent_versions.description IS 'Agent描述';


--
-- Name: COLUMN agent_versions.version_number; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.agent_versions.version_number IS '版本号，如1.0.0';


--
-- Name: COLUMN agent_versions.system_prompt; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.agent_versions.system_prompt IS 'Agent系统提示词';


--
-- Name: COLUMN agent_versions.welcome_message; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.agent_versions.welcome_message IS '欢迎消息';


--
-- Name: COLUMN agent_versions.tool_ids; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.agent_versions.tool_ids IS 'Agent可使用的工具ID列表，JSON数组格式';


--
-- Name: COLUMN agent_versions.knowledge_base_ids; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.agent_versions.knowledge_base_ids IS '关联的知识库ID列表，JSON数组格式';


--
-- Name: COLUMN agent_versions.change_log; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.agent_versions.change_log IS '版本更新日志';


--
-- Name: COLUMN agent_versions.publish_status; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.agent_versions.publish_status IS '发布状态：1-审核中, 2-已发布, 3-拒绝, 4-已下架';


--
-- Name: COLUMN agent_versions.reject_reason; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.agent_versions.reject_reason IS '审核拒绝原因';


--
-- Name: COLUMN agent_versions.review_time; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.agent_versions.review_time IS '审核时间';


--
-- Name: COLUMN agent_versions.published_at; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.agent_versions.published_at IS '发布时间';


--
-- Name: COLUMN agent_versions.user_id; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.agent_versions.user_id IS '创建者用户ID';


--
-- Name: COLUMN agent_versions.created_at; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.agent_versions.created_at IS '创建时间';


--
-- Name: COLUMN agent_versions.updated_at; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.agent_versions.updated_at IS '更新时间';


--
-- Name: COLUMN agent_versions.deleted_at; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.agent_versions.deleted_at IS '逻辑删除时间';


--
-- Name: agent_workspace; Type: TABLE; Schema: public; Owner: imagentx_user
--

CREATE TABLE public.agent_workspace (
    id character varying(36) NOT NULL,
    agent_id character varying(36) NOT NULL,
    user_id character varying(36) NOT NULL,
    llm_model_config jsonb,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp without time zone
);


ALTER TABLE public.agent_workspace OWNER TO imagentx_user;

--
-- Name: TABLE agent_workspace; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON TABLE public.agent_workspace IS 'Agent工作区实体类，用于记录用户添加到工作区的Agent';


--
-- Name: COLUMN agent_workspace.id; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.agent_workspace.id IS '主键ID';


--
-- Name: COLUMN agent_workspace.agent_id; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.agent_workspace.agent_id IS 'Agent ID';


--
-- Name: COLUMN agent_workspace.user_id; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.agent_workspace.user_id IS '用户ID';


--
-- Name: COLUMN agent_workspace.llm_model_config; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.agent_workspace.llm_model_config IS '模型配置，JSON格式';


--
-- Name: COLUMN agent_workspace.created_at; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.agent_workspace.created_at IS '创建时间';


--
-- Name: COLUMN agent_workspace.updated_at; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.agent_workspace.updated_at IS '更新时间';


--
-- Name: COLUMN agent_workspace.deleted_at; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.agent_workspace.deleted_at IS '逻辑删除时间';


--
-- Name: agents; Type: TABLE; Schema: public; Owner: imagentx_user
--

CREATE TABLE public.agents (
    id character varying(36) NOT NULL,
    name character varying(255) NOT NULL,
    avatar character varying(255),
    description text,
    system_prompt text,
    welcome_message text,
    tool_ids jsonb,
    published_version character varying(36),
    enabled boolean DEFAULT true,
    user_id character varying(36) NOT NULL,
    tool_preset_params jsonb,
    multi_modal boolean DEFAULT false,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp without time zone,
    knowledge_base_ids jsonb
);


ALTER TABLE public.agents OWNER TO imagentx_user;

--
-- Name: TABLE agents; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON TABLE public.agents IS 'Agent实体类，代表一个AI助手';


--
-- Name: COLUMN agents.id; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.agents.id IS 'Agent唯一ID';


--
-- Name: COLUMN agents.name; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.agents.name IS 'Agent名称';


--
-- Name: COLUMN agents.avatar; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.agents.avatar IS 'Agent头像URL';


--
-- Name: COLUMN agents.description; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.agents.description IS 'Agent描述';


--
-- Name: COLUMN agents.system_prompt; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.agents.system_prompt IS 'Agent系统提示词';


--
-- Name: COLUMN agents.welcome_message; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.agents.welcome_message IS '欢迎消息';


--
-- Name: COLUMN agents.published_version; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.agents.published_version IS '当前发布的版本ID';


--
-- Name: COLUMN agents.enabled; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.agents.enabled IS 'Agent状态：TRUE-启用，FALSE-禁用';


--
-- Name: COLUMN agents.user_id; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.agents.user_id IS '创建者用户ID';


--
-- Name: COLUMN agents.created_at; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.agents.created_at IS '创建时间';


--
-- Name: COLUMN agents.updated_at; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.agents.updated_at IS '更新时间';


--
-- Name: COLUMN agents.deleted_at; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.agents.deleted_at IS '逻辑删除时间';


--
-- Name: COLUMN agents.knowledge_base_ids; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.agents.knowledge_base_ids IS '关联的知识库ID列表，JSON数组格式，用于RAG功能';


--
-- Name: ai_rag_qa_dataset; Type: TABLE; Schema: public; Owner: imagentx_user
--

CREATE TABLE public.ai_rag_qa_dataset (
    id character varying(64) NOT NULL,
    name character varying(64),
    icon character varying(64),
    description character varying(64),
    user_id character varying(64),
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp without time zone
);


ALTER TABLE public.ai_rag_qa_dataset OWNER TO imagentx_user;

--
-- Name: api_keys; Type: TABLE; Schema: public; Owner: imagentx_user
--

CREATE TABLE public.api_keys (
    id character varying(36) NOT NULL,
    api_key character varying(64) NOT NULL,
    agent_id character varying(36) NOT NULL,
    user_id character varying(36) NOT NULL,
    name character varying(100),
    status boolean DEFAULT true,
    usage_count integer DEFAULT 0,
    last_used_at timestamp without time zone,
    expires_at timestamp without time zone,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp without time zone
);


ALTER TABLE public.api_keys OWNER TO imagentx_user;

--
-- Name: TABLE api_keys; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON TABLE public.api_keys IS 'API密钥管理表';


--
-- Name: COLUMN api_keys.id; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.api_keys.id IS 'API Key ID';


--
-- Name: COLUMN api_keys.api_key; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.api_keys.api_key IS 'API密钥';


--
-- Name: COLUMN api_keys.agent_id; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.api_keys.agent_id IS '关联的Agent ID';


--
-- Name: COLUMN api_keys.user_id; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.api_keys.user_id IS '创建者用户ID';


--
-- Name: COLUMN api_keys.name; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.api_keys.name IS 'API Key名称/描述';


--
-- Name: COLUMN api_keys.status; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.api_keys.status IS '状态：TRUE-启用，FALSE-禁用';


--
-- Name: COLUMN api_keys.usage_count; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.api_keys.usage_count IS '已使用次数';


--
-- Name: COLUMN api_keys.last_used_at; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.api_keys.last_used_at IS '最后使用时间';


--
-- Name: COLUMN api_keys.expires_at; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.api_keys.expires_at IS '过期时间';


--
-- Name: COLUMN api_keys.created_at; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.api_keys.created_at IS '创建时间';


--
-- Name: COLUMN api_keys.updated_at; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.api_keys.updated_at IS '更新时间';


--
-- Name: COLUMN api_keys.deleted_at; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.api_keys.deleted_at IS '逻辑删除时间';


--
-- Name: auth_settings; Type: TABLE; Schema: public; Owner: imagentx_user
--

CREATE TABLE public.auth_settings (
    id character varying(36) NOT NULL,
    feature_type character varying(50) NOT NULL,
    feature_key character varying(100) NOT NULL,
    feature_name character varying(100) NOT NULL,
    enabled boolean DEFAULT true,
    config_data jsonb,
    display_order integer DEFAULT 0,
    description text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp without time zone
);


ALTER TABLE public.auth_settings OWNER TO imagentx_user;

--
-- Name: TABLE auth_settings; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON TABLE public.auth_settings IS '认证配置表，管理登录方式和注册功能的开关';


--
-- Name: COLUMN auth_settings.id; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.auth_settings.id IS '配置记录唯一ID';


--
-- Name: COLUMN auth_settings.feature_type; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.auth_settings.feature_type IS '功能类型：LOGIN-登录功能，REGISTER-注册功能';


--
-- Name: COLUMN auth_settings.feature_key; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.auth_settings.feature_key IS '功能键：NORMAL_LOGIN, GITHUB_LOGIN, COMMUNITY_LOGIN, USER_REGISTER等';


--
-- Name: COLUMN auth_settings.feature_name; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.auth_settings.feature_name IS '功能显示名称';


--
-- Name: COLUMN auth_settings.enabled; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.auth_settings.enabled IS '是否启用该功能';


--
-- Name: COLUMN auth_settings.config_data; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.auth_settings.config_data IS '功能配置数据，JSON格式，存储SSO配置等';


--
-- Name: COLUMN auth_settings.display_order; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.auth_settings.display_order IS '显示顺序';


--
-- Name: COLUMN auth_settings.description; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.auth_settings.description IS '功能描述';


--
-- Name: COLUMN auth_settings.created_at; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.auth_settings.created_at IS '创建时间';


--
-- Name: COLUMN auth_settings.updated_at; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.auth_settings.updated_at IS '更新时间';


--
-- Name: COLUMN auth_settings.deleted_at; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.auth_settings.deleted_at IS '逻辑删除时间';


--
-- Name: container_templates; Type: TABLE; Schema: public; Owner: imagentx_user
--

CREATE TABLE public.container_templates (
    id character varying(36) NOT NULL,
    name character varying(100) NOT NULL,
    description text,
    type character varying(50) NOT NULL,
    image character varying(200) NOT NULL,
    image_tag character varying(50),
    internal_port integer NOT NULL,
    cpu_limit numeric(4,2) NOT NULL,
    memory_limit integer NOT NULL,
    environment text,
    volume_mount_path character varying(500),
    command text,
    network_mode character varying(50),
    restart_policy character varying(50),
    health_check text,
    resource_config text,
    enabled boolean DEFAULT true NOT NULL,
    is_default boolean DEFAULT false NOT NULL,
    created_by character varying(36),
    sort_order integer DEFAULT 0 NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp without time zone
);


ALTER TABLE public.container_templates OWNER TO imagentx_user;

--
-- Name: TABLE container_templates; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON TABLE public.container_templates IS '容器模板表';


--
-- Name: COLUMN container_templates.id; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.container_templates.id IS '模板ID';


--
-- Name: COLUMN container_templates.name; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.container_templates.name IS '模板名称';


--
-- Name: COLUMN container_templates.description; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.container_templates.description IS '模板描述';


--
-- Name: COLUMN container_templates.type; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.container_templates.type IS '模板类型(mcp-gateway等)';


--
-- Name: COLUMN container_templates.image; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.container_templates.image IS '容器镜像名称';


--
-- Name: COLUMN container_templates.image_tag; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.container_templates.image_tag IS '镜像版本标签';


--
-- Name: COLUMN container_templates.internal_port; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.container_templates.internal_port IS '容器内部端口';


--
-- Name: COLUMN container_templates.cpu_limit; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.container_templates.cpu_limit IS 'CPU限制(核数)';


--
-- Name: COLUMN container_templates.memory_limit; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.container_templates.memory_limit IS '内存限制(MB)';


--
-- Name: COLUMN container_templates.environment; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.container_templates.environment IS '环境变量配置(JSON格式)';


--
-- Name: COLUMN container_templates.volume_mount_path; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.container_templates.volume_mount_path IS '数据卷挂载路径';


--
-- Name: COLUMN container_templates.command; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.container_templates.command IS '启动命令(JSON数组格式)';


--
-- Name: COLUMN container_templates.network_mode; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.container_templates.network_mode IS '网络模式';


--
-- Name: COLUMN container_templates.restart_policy; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.container_templates.restart_policy IS '重启策略';


--
-- Name: COLUMN container_templates.health_check; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.container_templates.health_check IS '健康检查配置(JSON格式)';


--
-- Name: COLUMN container_templates.resource_config; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.container_templates.resource_config IS '资源配置(JSON格式)';


--
-- Name: COLUMN container_templates.enabled; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.container_templates.enabled IS '是否启用';


--
-- Name: COLUMN container_templates.is_default; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.container_templates.is_default IS '是否为默认模板';


--
-- Name: COLUMN container_templates.created_by; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.container_templates.created_by IS '创建者用户ID';


--
-- Name: COLUMN container_templates.sort_order; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.container_templates.sort_order IS '排序权重';


--
-- Name: COLUMN container_templates.created_at; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.container_templates.created_at IS '创建时间';


--
-- Name: COLUMN container_templates.updated_at; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.container_templates.updated_at IS '更新时间';


--
-- Name: COLUMN container_templates.deleted_at; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.container_templates.deleted_at IS '删除时间';


--
-- Name: context; Type: TABLE; Schema: public; Owner: imagentx_user
--

CREATE TABLE public.context (
    id character varying(36) NOT NULL,
    session_id character varying(36) NOT NULL,
    active_messages jsonb,
    summary text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp without time zone
);


ALTER TABLE public.context OWNER TO imagentx_user;

--
-- Name: TABLE context; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON TABLE public.context IS '上下文实体类，管理会话的上下文窗口';


--
-- Name: COLUMN context.id; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.context.id IS '上下文唯一ID';


--
-- Name: COLUMN context.session_id; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.context.session_id IS '所属会话ID';


--
-- Name: COLUMN context.active_messages; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.context.active_messages IS '活跃消息ID列表，JSON数组格式';


--
-- Name: COLUMN context.summary; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.context.summary IS '历史消息摘要';


--
-- Name: COLUMN context.created_at; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.context.created_at IS '创建时间';


--
-- Name: COLUMN context.updated_at; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.context.updated_at IS '更新时间';


--
-- Name: COLUMN context.deleted_at; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.context.deleted_at IS '逻辑删除时间';


--
-- Name: document_unit; Type: TABLE; Schema: public; Owner: imagentx_user
--

CREATE TABLE public.document_unit (
    id character varying(64) NOT NULL,
    file_id character varying(64),
    page integer,
    content text,
    flag integer,
    is_vector boolean NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp without time zone,
    is_ocr boolean
);


ALTER TABLE public.document_unit OWNER TO imagentx_user;

--
-- Name: TABLE document_unit; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON TABLE public.document_unit IS '文档单元表';


--
-- Name: COLUMN document_unit.id; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.document_unit.id IS '文件id';


--
-- Name: COLUMN document_unit.file_id; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.document_unit.file_id IS '文档ID';


--
-- Name: COLUMN document_unit.page; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.document_unit.page IS '页码';


--
-- Name: COLUMN document_unit.content; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.document_unit.content IS '当前页内容';


--
-- Name: COLUMN document_unit.flag; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.document_unit.flag IS '标记';


--
-- Name: COLUMN document_unit.is_vector; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.document_unit.is_vector IS '是否进行了向量化';


--
-- Name: file_detail; Type: TABLE; Schema: public; Owner: imagentx_user
--

CREATE TABLE public.file_detail (
    id character varying(64) NOT NULL,
    url text,
    size bigint,
    filename character varying(255),
    original_filename character varying(255),
    base_path character varying(255),
    path character varying(255),
    ext character varying(50),
    content_type character varying(100),
    platform character varying(50),
    th_url text,
    th_filename character varying(255),
    th_size bigint,
    th_content_type character varying(100),
    object_id character varying(64),
    object_type character varying(50),
    metadata text,
    user_metadata text,
    th_metadata text,
    th_user_metadata text,
    attr text,
    file_acl character varying(50),
    th_file_acl character varying(50),
    hash_info text,
    upload_id character varying(64),
    upload_status integer,
    user_id character varying,
    data_set_id character varying,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp without time zone,
    file_page_size bigint,
    current_page_number integer DEFAULT 0,
    process_progress numeric(5,2) DEFAULT 0.00,
    current_ocr_page_number integer DEFAULT 0,
    current_embedding_page_number integer DEFAULT 0,
    ocr_process_progress numeric(5,2) DEFAULT 0.00,
    embedding_process_progress numeric(5,2) DEFAULT 0.00,
    processing_status integer DEFAULT 0
);


ALTER TABLE public.file_detail OWNER TO imagentx_user;

--
-- Name: TABLE file_detail; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON TABLE public.file_detail IS '文件详情表';


--
-- Name: COLUMN file_detail.id; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.file_detail.id IS '文件id';


--
-- Name: COLUMN file_detail.url; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.file_detail.url IS '文件访问地址';


--
-- Name: COLUMN file_detail.size; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.file_detail.size IS '文件大小，单位字节';


--
-- Name: COLUMN file_detail.filename; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.file_detail.filename IS '文件名称';


--
-- Name: COLUMN file_detail.original_filename; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.file_detail.original_filename IS '原始文件名';


--
-- Name: COLUMN file_detail.base_path; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.file_detail.base_path IS '基础存储路径';


--
-- Name: COLUMN file_detail.path; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.file_detail.path IS '存储路径';


--
-- Name: COLUMN file_detail.ext; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.file_detail.ext IS '文件扩展名';


--
-- Name: COLUMN file_detail.content_type; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.file_detail.content_type IS 'MIME类型';


--
-- Name: COLUMN file_detail.platform; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.file_detail.platform IS '存储平台';


--
-- Name: COLUMN file_detail.th_url; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.file_detail.th_url IS '缩略图访问路径';


--
-- Name: COLUMN file_detail.th_filename; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.file_detail.th_filename IS '缩略图名称';


--
-- Name: COLUMN file_detail.th_size; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.file_detail.th_size IS '缩略图大小，单位字节';


--
-- Name: COLUMN file_detail.th_content_type; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.file_detail.th_content_type IS '缩略图MIME类型';


--
-- Name: COLUMN file_detail.object_id; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.file_detail.object_id IS '文件所属对象id';


--
-- Name: COLUMN file_detail.object_type; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.file_detail.object_type IS '文件所属对象类型';


--
-- Name: COLUMN file_detail.metadata; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.file_detail.metadata IS '文件元数据';


--
-- Name: COLUMN file_detail.user_metadata; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.file_detail.user_metadata IS '文件用户元数据';


--
-- Name: COLUMN file_detail.th_metadata; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.file_detail.th_metadata IS '缩略图元数据';


--
-- Name: COLUMN file_detail.th_user_metadata; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.file_detail.th_user_metadata IS '缩略图用户元数据';


--
-- Name: COLUMN file_detail.attr; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.file_detail.attr IS '附加属性';


--
-- Name: COLUMN file_detail.file_acl; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.file_detail.file_acl IS '文件ACL';


--
-- Name: COLUMN file_detail.th_file_acl; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.file_detail.th_file_acl IS '缩略图文件ACL';


--
-- Name: COLUMN file_detail.hash_info; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.file_detail.hash_info IS '哈希信息';


--
-- Name: COLUMN file_detail.upload_id; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.file_detail.upload_id IS '上传ID';


--
-- Name: COLUMN file_detail.upload_status; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.file_detail.upload_status IS '上传状态，1：初始化完成，2：上传完成';


--
-- Name: COLUMN file_detail.user_id; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.file_detail.user_id IS '用户ID';


--
-- Name: COLUMN file_detail.file_page_size; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.file_detail.file_page_size IS '文件页数';


--
-- Name: COLUMN file_detail.current_ocr_page_number; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.file_detail.current_ocr_page_number IS '当前OCR处理页数';


--
-- Name: COLUMN file_detail.current_embedding_page_number; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.file_detail.current_embedding_page_number IS '当前向量化处理页数';


--
-- Name: COLUMN file_detail.ocr_process_progress; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.file_detail.ocr_process_progress IS 'OCR处理进度百分比';


--
-- Name: COLUMN file_detail.embedding_process_progress; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.file_detail.embedding_process_progress IS '向量化处理进度百分比(0-100)';


--
-- Name: COLUMN file_detail.processing_status; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.file_detail.processing_status IS '文件处理状态：0-已上传，1-OCR处理中，2-OCR完成，3-向量化处理中，4-处理完成，5-OCR失败，6-向量化失败';


--
-- Name: messages; Type: TABLE; Schema: public; Owner: imagentx_user
--

CREATE TABLE public.messages (
    id character varying(36) NOT NULL,
    session_id character varying(36) NOT NULL,
    role character varying(20) NOT NULL,
    content text NOT NULL,
    message_type character varying(20) DEFAULT 'TEXT'::character varying NOT NULL,
    token_count integer DEFAULT 0,
    body_token_count integer DEFAULT 0,
    provider character varying(50),
    model character varying(50),
    metadata jsonb,
    file_urls jsonb,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp without time zone
);


ALTER TABLE public.messages OWNER TO imagentx_user;

--
-- Name: TABLE messages; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON TABLE public.messages IS '消息实体类，代表对话中的一条消息';


--
-- Name: COLUMN messages.id; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.messages.id IS '消息唯一ID';


--
-- Name: COLUMN messages.session_id; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.messages.session_id IS '所属会话ID';


--
-- Name: COLUMN messages.role; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.messages.role IS '消息角色 (user, assistant, system)';


--
-- Name: COLUMN messages.content; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.messages.content IS '消息内容';


--
-- Name: COLUMN messages.message_type; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.messages.message_type IS '消息类型';


--
-- Name: COLUMN messages.token_count; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.messages.token_count IS 'Token数量';


--
-- Name: COLUMN messages.body_token_count; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.messages.body_token_count IS '消息本体的token数量';


--
-- Name: COLUMN messages.provider; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.messages.provider IS '服务提供商';


--
-- Name: COLUMN messages.model; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.messages.model IS '使用的模型';


--
-- Name: COLUMN messages.metadata; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.messages.metadata IS '消息元数据，JSON格式';


--
-- Name: COLUMN messages.created_at; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.messages.created_at IS '创建时间';


--
-- Name: COLUMN messages.updated_at; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.messages.updated_at IS '更新时间';


--
-- Name: COLUMN messages.deleted_at; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.messages.deleted_at IS '逻辑删除时间';


--
-- Name: models; Type: TABLE; Schema: public; Owner: imagentx_user
--

CREATE TABLE public.models (
    id character varying(36) NOT NULL,
    user_id character varying(36),
    provider_id character varying(36) NOT NULL,
    model_id character varying(100) NOT NULL,
    name character varying(100) NOT NULL,
    model_endpoint character varying(255) NOT NULL,
    description text,
    is_official boolean DEFAULT false,
    type character varying(20) NOT NULL,
    status boolean DEFAULT true,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp without time zone
);


ALTER TABLE public.models OWNER TO imagentx_user;

--
-- Name: TABLE models; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON TABLE public.models IS '模型领域模型';


--
-- Name: COLUMN models.id; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.models.id IS '模型ID';


--
-- Name: COLUMN models.user_id; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.models.user_id IS '用户ID';


--
-- Name: COLUMN models.provider_id; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.models.provider_id IS '服务提供商ID';


--
-- Name: COLUMN models.model_id; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.models.model_id IS '模型ID标识';


--
-- Name: COLUMN models.name; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.models.name IS '模型名称';


--
-- Name: COLUMN models.description; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.models.description IS '模型描述';


--
-- Name: COLUMN models.is_official; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.models.is_official IS '是否官方模型';


--
-- Name: COLUMN models.type; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.models.type IS '模型类型';


--
-- Name: COLUMN models.status; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.models.status IS '模型状态';


--
-- Name: COLUMN models.created_at; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.models.created_at IS '创建时间';


--
-- Name: COLUMN models.updated_at; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.models.updated_at IS '更新时间';


--
-- Name: COLUMN models.deleted_at; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.models.deleted_at IS '逻辑删除时间';


--
-- Name: orders; Type: TABLE; Schema: public; Owner: imagentx_user
--

CREATE TABLE public.orders (
    id character varying(64) NOT NULL,
    user_id character varying(64) NOT NULL,
    order_no character varying(100) NOT NULL,
    order_type character varying(50) NOT NULL,
    title character varying(255) NOT NULL,
    description text,
    amount numeric(20,8) NOT NULL,
    currency character varying(10) DEFAULT 'CNY'::character varying,
    status integer DEFAULT 1 NOT NULL,
    expired_at timestamp without time zone,
    paid_at timestamp without time zone,
    cancelled_at timestamp without time zone,
    refunded_at timestamp without time zone,
    refund_amount numeric(20,8) DEFAULT 0.00000000,
    payment_platform character varying(50),
    payment_type character varying(50),
    provider_order_id character varying(200),
    metadata jsonb,
    deleted_at timestamp without time zone,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.orders OWNER TO imagentx_user;

--
-- Name: TABLE orders; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON TABLE public.orders IS '订单表，存储各种类型的订单信息和支付方式';


--
-- Name: COLUMN orders.id; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.orders.id IS '订单唯一ID';


--
-- Name: COLUMN orders.user_id; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.orders.user_id IS '用户ID';


--
-- Name: COLUMN orders.order_no; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.orders.order_no IS '订单号（唯一）';


--
-- Name: COLUMN orders.order_type; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.orders.order_type IS '订单类型：RECHARGE(充值)、PURCHASE(购买)、SUBSCRIPTION(订阅)';


--
-- Name: COLUMN orders.title; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.orders.title IS '订单标题';


--
-- Name: COLUMN orders.description; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.orders.description IS '订单描述';


--
-- Name: COLUMN orders.amount; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.orders.amount IS '订单金额';


--
-- Name: COLUMN orders.currency; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.orders.currency IS '货币代码，默认CNY';


--
-- Name: COLUMN orders.status; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.orders.status IS '订单状态：1-待支付，2-已支付，3-已取消，4-已退款，5-已过期';


--
-- Name: COLUMN orders.expired_at; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.orders.expired_at IS '订单过期时间';


--
-- Name: COLUMN orders.paid_at; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.orders.paid_at IS '支付完成时间';


--
-- Name: COLUMN orders.cancelled_at; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.orders.cancelled_at IS '取消时间';


--
-- Name: COLUMN orders.refunded_at; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.orders.refunded_at IS '退款时间';


--
-- Name: COLUMN orders.refund_amount; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.orders.refund_amount IS '退款金额';


--
-- Name: COLUMN orders.payment_platform; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.orders.payment_platform IS '支付平台：alipay(支付宝)、wechat(微信支付)、stripe(Stripe)';


--
-- Name: COLUMN orders.payment_type; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.orders.payment_type IS '支付类型：web(网页支付)、qr_code(二维码支付)、mobile(移动端支付)、h5(H5支付)、mini_program(小程序支付)';


--
-- Name: COLUMN orders.provider_order_id; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.orders.provider_order_id IS '第三方支付平台的订单ID，用于查询支付状态和对账';


--
-- Name: COLUMN orders.metadata; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.orders.metadata IS '订单扩展信息（JSONB格式）';


--
-- Name: products; Type: TABLE; Schema: public; Owner: imagentx_user
--

CREATE TABLE public.products (
    id character varying(64) NOT NULL,
    name character varying(255) NOT NULL,
    type character varying(50) NOT NULL,
    service_id character varying(100) NOT NULL,
    rule_id character varying(64) NOT NULL,
    pricing_config jsonb,
    status integer DEFAULT 1,
    deleted_at timestamp without time zone,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.products OWNER TO imagentx_user;

--
-- Name: TABLE products; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON TABLE public.products IS '计费商品表，存储可计费的服务和产品信息';


--
-- Name: COLUMN products.name; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.products.name IS '商品名称';


--
-- Name: COLUMN products.type; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.products.type IS '计费类型：MODEL_USAGE, AGENT_CREATION, API_CALLS等';


--
-- Name: COLUMN products.service_id; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.products.service_id IS '业务服务标识';


--
-- Name: COLUMN products.rule_id; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.products.rule_id IS '关联的规则ID';


--
-- Name: COLUMN products.pricing_config; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.products.pricing_config IS '价格配置（JSONB格式）';


--
-- Name: COLUMN products.status; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.products.status IS '状态：1-激活，0-禁用';


--
-- Name: providers; Type: TABLE; Schema: public; Owner: imagentx_user
--

CREATE TABLE public.providers (
    id character varying(36) NOT NULL,
    user_id character varying(36),
    protocol character varying(50) NOT NULL,
    name character varying(100) NOT NULL,
    description text,
    config text,
    is_official boolean DEFAULT false,
    status boolean DEFAULT true,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp without time zone
);


ALTER TABLE public.providers OWNER TO imagentx_user;

--
-- Name: TABLE providers; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON TABLE public.providers IS '服务提供商领域模型';


--
-- Name: COLUMN providers.id; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.providers.id IS '服务提供商ID';


--
-- Name: COLUMN providers.user_id; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.providers.user_id IS '用户ID';


--
-- Name: COLUMN providers.protocol; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.providers.protocol IS '协议类型';


--
-- Name: COLUMN providers.name; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.providers.name IS '服务提供商名称';


--
-- Name: COLUMN providers.description; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.providers.description IS '服务提供商描述';


--
-- Name: COLUMN providers.config; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.providers.config IS '服务提供商配置,加密后的值';


--
-- Name: COLUMN providers.is_official; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.providers.is_official IS '是否官方服务提供商';


--
-- Name: COLUMN providers.status; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.providers.status IS '服务提供商状态';


--
-- Name: COLUMN providers.created_at; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.providers.created_at IS '创建时间';


--
-- Name: COLUMN providers.updated_at; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.providers.updated_at IS '更新时间';


--
-- Name: COLUMN providers.deleted_at; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.providers.deleted_at IS '逻辑删除时间';


--
-- Name: rag_version_documents; Type: TABLE; Schema: public; Owner: imagentx_user
--

CREATE TABLE public.rag_version_documents (
    id character varying(36) NOT NULL,
    rag_version_id character varying(36) NOT NULL,
    rag_version_file_id character varying(36) NOT NULL,
    original_document_id character varying(36),
    content text NOT NULL,
    page integer,
    vector_id character varying(36),
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp without time zone
);


ALTER TABLE public.rag_version_documents OWNER TO imagentx_user;

--
-- Name: TABLE rag_version_documents; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON TABLE public.rag_version_documents IS 'RAG版本文档单元表（文档内容快照）';


--
-- Name: COLUMN rag_version_documents.id; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.rag_version_documents.id IS '主键ID';


--
-- Name: COLUMN rag_version_documents.rag_version_id; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.rag_version_documents.rag_version_id IS '关联RAG版本ID';


--
-- Name: COLUMN rag_version_documents.rag_version_file_id; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.rag_version_documents.rag_version_file_id IS '关联版本文件ID';


--
-- Name: COLUMN rag_version_documents.original_document_id; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.rag_version_documents.original_document_id IS '原始文档单元ID（仅标识）';


--
-- Name: COLUMN rag_version_documents.content; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.rag_version_documents.content IS '文档内容';


--
-- Name: COLUMN rag_version_documents.page; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.rag_version_documents.page IS '页码';


--
-- Name: COLUMN rag_version_documents.vector_id; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.rag_version_documents.vector_id IS '向量ID';


--
-- Name: COLUMN rag_version_documents.created_at; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.rag_version_documents.created_at IS '创建时间';


--
-- Name: COLUMN rag_version_documents.updated_at; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.rag_version_documents.updated_at IS '更新时间';


--
-- Name: COLUMN rag_version_documents.deleted_at; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.rag_version_documents.deleted_at IS '删除时间（软删除）';


--
-- Name: rag_version_files; Type: TABLE; Schema: public; Owner: imagentx_user
--

CREATE TABLE public.rag_version_files (
    id character varying(36) NOT NULL,
    rag_version_id character varying(36) NOT NULL,
    original_file_id character varying(36) NOT NULL,
    file_name character varying(255) NOT NULL,
    file_size bigint DEFAULT 0,
    file_type character varying(50),
    file_path character varying(500),
    process_status integer,
    embedding_status integer,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp without time zone,
    file_page_size integer
);


ALTER TABLE public.rag_version_files OWNER TO imagentx_user;

--
-- Name: TABLE rag_version_files; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON TABLE public.rag_version_files IS 'RAG版本文件表（文件快照）';


--
-- Name: COLUMN rag_version_files.id; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.rag_version_files.id IS '主键ID';


--
-- Name: COLUMN rag_version_files.rag_version_id; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.rag_version_files.rag_version_id IS '关联RAG版本ID';


--
-- Name: COLUMN rag_version_files.original_file_id; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.rag_version_files.original_file_id IS '原始文件ID（仅标识）';


--
-- Name: COLUMN rag_version_files.file_name; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.rag_version_files.file_name IS '文件名';


--
-- Name: COLUMN rag_version_files.file_size; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.rag_version_files.file_size IS '文件大小（字节）';


--
-- Name: COLUMN rag_version_files.file_type; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.rag_version_files.file_type IS '文件类型';


--
-- Name: COLUMN rag_version_files.file_path; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.rag_version_files.file_path IS '文件存储路径';


--
-- Name: COLUMN rag_version_files.process_status; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.rag_version_files.process_status IS '处理状态';


--
-- Name: COLUMN rag_version_files.embedding_status; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.rag_version_files.embedding_status IS '向量化状态';


--
-- Name: COLUMN rag_version_files.created_at; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.rag_version_files.created_at IS '创建时间';


--
-- Name: COLUMN rag_version_files.updated_at; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.rag_version_files.updated_at IS '更新时间';


--
-- Name: COLUMN rag_version_files.deleted_at; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.rag_version_files.deleted_at IS '删除时间（软删除）';


--
-- Name: COLUMN rag_version_files.file_page_size; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.rag_version_files.file_page_size IS '文件页数';


--
-- Name: rag_versions; Type: TABLE; Schema: public; Owner: imagentx_user
--

CREATE TABLE public.rag_versions (
    id character varying(36) NOT NULL,
    name character varying(255) NOT NULL,
    icon character varying(255),
    description text,
    user_id character varying(36) NOT NULL,
    version character varying(50) NOT NULL,
    change_log text,
    labels jsonb,
    original_rag_id character varying(36) NOT NULL,
    original_rag_name character varying(255),
    file_count integer DEFAULT 0,
    total_size bigint DEFAULT 0,
    document_count integer DEFAULT 0,
    publish_status integer DEFAULT 1,
    reject_reason text,
    review_time timestamp without time zone,
    published_at timestamp without time zone,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp without time zone
);


ALTER TABLE public.rag_versions OWNER TO imagentx_user;

--
-- Name: TABLE rag_versions; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON TABLE public.rag_versions IS 'RAG版本表（完整快照）';


--
-- Name: COLUMN rag_versions.id; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.rag_versions.id IS '主键ID';


--
-- Name: COLUMN rag_versions.name; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.rag_versions.name IS '快照时的名称';


--
-- Name: COLUMN rag_versions.icon; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.rag_versions.icon IS '快照时的图标';


--
-- Name: COLUMN rag_versions.description; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.rag_versions.description IS '快照时的描述';


--
-- Name: COLUMN rag_versions.user_id; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.rag_versions.user_id IS '创建者用户ID';


--
-- Name: COLUMN rag_versions.version; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.rag_versions.version IS '版本号 (如 "1.0.0")';


--
-- Name: COLUMN rag_versions.change_log; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.rag_versions.change_log IS '更新日志';


--
-- Name: COLUMN rag_versions.labels; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.rag_versions.labels IS '标签（JSON格式）';


--
-- Name: COLUMN rag_versions.original_rag_id; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.rag_versions.original_rag_id IS '原始RAG数据集ID（仅标识用）';


--
-- Name: COLUMN rag_versions.original_rag_name; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.rag_versions.original_rag_name IS '原始RAG名称（快照时）';


--
-- Name: COLUMN rag_versions.file_count; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.rag_versions.file_count IS '文件数量';


--
-- Name: COLUMN rag_versions.total_size; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.rag_versions.total_size IS '总大小（字节）';


--
-- Name: COLUMN rag_versions.document_count; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.rag_versions.document_count IS '文档单元数量';


--
-- Name: COLUMN rag_versions.publish_status; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.rag_versions.publish_status IS '发布状态 1:审核中, 2:已发布, 3:拒绝, 4:已下架';


--
-- Name: COLUMN rag_versions.reject_reason; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.rag_versions.reject_reason IS '审核拒绝原因';


--
-- Name: COLUMN rag_versions.review_time; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.rag_versions.review_time IS '审核时间';


--
-- Name: COLUMN rag_versions.published_at; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.rag_versions.published_at IS '发布时间';


--
-- Name: COLUMN rag_versions.created_at; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.rag_versions.created_at IS '创建时间';


--
-- Name: COLUMN rag_versions.updated_at; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.rag_versions.updated_at IS '更新时间';


--
-- Name: COLUMN rag_versions.deleted_at; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.rag_versions.deleted_at IS '删除时间（软删除）';


--
-- Name: rules; Type: TABLE; Schema: public; Owner: imagentx_user
--

CREATE TABLE public.rules (
    id character varying(64) NOT NULL,
    name character varying(255) NOT NULL,
    handler_key character varying(100) NOT NULL,
    description text,
    deleted_at timestamp without time zone,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.rules OWNER TO imagentx_user;

--
-- Name: TABLE rules; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON TABLE public.rules IS '计费规则表，存储不同的计费策略配置';


--
-- Name: COLUMN rules.name; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.rules.name IS '规则名称';


--
-- Name: COLUMN rules.handler_key; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.rules.handler_key IS '处理器标识，对应策略枚举';


--
-- Name: COLUMN rules.description; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.rules.description IS '规则描述';


--
-- Name: scheduled_tasks; Type: TABLE; Schema: public; Owner: imagentx_user
--

CREATE TABLE public.scheduled_tasks (
    id character varying(36) NOT NULL,
    user_id character varying(36) NOT NULL,
    agent_id character varying(36) NOT NULL,
    session_id character varying(36) NOT NULL,
    content text NOT NULL,
    repeat_type character varying(20) NOT NULL,
    repeat_config jsonb,
    status character varying(20) DEFAULT 'ACTIVE'::character varying,
    last_execute_time timestamp without time zone,
    next_execute_time timestamp without time zone,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp without time zone
);


ALTER TABLE public.scheduled_tasks OWNER TO imagentx_user;

--
-- Name: TABLE scheduled_tasks; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON TABLE public.scheduled_tasks IS '定时任务实体类';


--
-- Name: COLUMN scheduled_tasks.id; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.scheduled_tasks.id IS '定时任务唯一ID';


--
-- Name: COLUMN scheduled_tasks.user_id; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.scheduled_tasks.user_id IS '用户ID';


--
-- Name: COLUMN scheduled_tasks.agent_id; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.scheduled_tasks.agent_id IS '关联的Agent ID';


--
-- Name: COLUMN scheduled_tasks.session_id; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.scheduled_tasks.session_id IS '关联的会话ID';


--
-- Name: COLUMN scheduled_tasks.content; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.scheduled_tasks.content IS '任务内容';


--
-- Name: COLUMN scheduled_tasks.repeat_type; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.scheduled_tasks.repeat_type IS '重复类型：NONE-不重复, DAILY-每天, WEEKLY-每周, MONTHLY-每月, WORKDAYS-工作日, CUSTOM-自定义';


--
-- Name: COLUMN scheduled_tasks.repeat_config; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.scheduled_tasks.repeat_config IS '重复配置，JSON格式存储具体的重复规则';


--
-- Name: COLUMN scheduled_tasks.status; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.scheduled_tasks.status IS '任务状态：ACTIVE-活跃, PAUSED-暂停, COMPLETED-已完成';


--
-- Name: COLUMN scheduled_tasks.last_execute_time; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.scheduled_tasks.last_execute_time IS '上次执行时间';


--
-- Name: COLUMN scheduled_tasks.created_at; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.scheduled_tasks.created_at IS '创建时间';


--
-- Name: COLUMN scheduled_tasks.updated_at; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.scheduled_tasks.updated_at IS '更新时间';


--
-- Name: COLUMN scheduled_tasks.deleted_at; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.scheduled_tasks.deleted_at IS '逻辑删除时间';


--
-- Name: sessions; Type: TABLE; Schema: public; Owner: imagentx_user
--

CREATE TABLE public.sessions (
    id character varying(36) NOT NULL,
    title character varying(255) NOT NULL,
    user_id character varying(36) NOT NULL,
    agent_id character varying(36),
    description text,
    is_archived boolean DEFAULT false,
    metadata jsonb,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp without time zone
);


ALTER TABLE public.sessions OWNER TO imagentx_user;

--
-- Name: TABLE sessions; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON TABLE public.sessions IS '会话实体类，代表一个独立的对话会话/主题';


--
-- Name: COLUMN sessions.id; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.sessions.id IS '会话唯一ID';


--
-- Name: COLUMN sessions.title; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.sessions.title IS '会话标题';


--
-- Name: COLUMN sessions.user_id; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.sessions.user_id IS '所属用户ID';


--
-- Name: COLUMN sessions.agent_id; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.sessions.agent_id IS '关联的Agent版本ID';


--
-- Name: COLUMN sessions.description; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.sessions.description IS '会话描述';


--
-- Name: COLUMN sessions.is_archived; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.sessions.is_archived IS '是否归档';


--
-- Name: COLUMN sessions.metadata; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.sessions.metadata IS '会话元数据，可存储其他自定义信息，JSON格式';


--
-- Name: COLUMN sessions.created_at; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.sessions.created_at IS '创建时间';


--
-- Name: COLUMN sessions.updated_at; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.sessions.updated_at IS '更新时间';


--
-- Name: COLUMN sessions.deleted_at; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.sessions.deleted_at IS '逻辑删除时间';


--
-- Name: tool_versions; Type: TABLE; Schema: public; Owner: imagentx_user
--

CREATE TABLE public.tool_versions (
    id character varying(36) NOT NULL,
    name character varying(255) NOT NULL,
    icon character varying(255),
    subtitle character varying(255),
    description text,
    user_id character varying(36) NOT NULL,
    version character varying(50) NOT NULL,
    tool_id character varying(36) NOT NULL,
    upload_type character varying(20) NOT NULL,
    change_log text,
    upload_url character varying(255),
    tool_list jsonb,
    labels jsonb,
    mcp_server_name character varying(255),
    is_office boolean DEFAULT false,
    public_status boolean DEFAULT false,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp without time zone
);


ALTER TABLE public.tool_versions OWNER TO imagentx_user;

--
-- Name: TABLE tool_versions; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON TABLE public.tool_versions IS '工具版本实体类';


--
-- Name: COLUMN tool_versions.id; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.tool_versions.id IS '版本唯一ID';


--
-- Name: COLUMN tool_versions.name; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.tool_versions.name IS '工具名称';


--
-- Name: COLUMN tool_versions.icon; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.tool_versions.icon IS '工具图标';


--
-- Name: COLUMN tool_versions.subtitle; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.tool_versions.subtitle IS '副标题';


--
-- Name: COLUMN tool_versions.description; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.tool_versions.description IS '工具描述';


--
-- Name: COLUMN tool_versions.user_id; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.tool_versions.user_id IS '用户ID';


--
-- Name: COLUMN tool_versions.version; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.tool_versions.version IS '版本号';


--
-- Name: COLUMN tool_versions.tool_id; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.tool_versions.tool_id IS '工具ID';


--
-- Name: COLUMN tool_versions.upload_type; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.tool_versions.upload_type IS '上传方式';


--
-- Name: COLUMN tool_versions.upload_url; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.tool_versions.upload_url IS '上传URL';


--
-- Name: COLUMN tool_versions.tool_list; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.tool_versions.tool_list IS '工具列表，JSON数组格式';


--
-- Name: COLUMN tool_versions.labels; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.tool_versions.labels IS '标签列表，JSON数组格式';


--
-- Name: COLUMN tool_versions.is_office; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.tool_versions.is_office IS '是否官方工具';


--
-- Name: COLUMN tool_versions.public_status; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.tool_versions.public_status IS '公开状态';


--
-- Name: COLUMN tool_versions.created_at; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.tool_versions.created_at IS '创建时间';


--
-- Name: COLUMN tool_versions.updated_at; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.tool_versions.updated_at IS '更新时间';


--
-- Name: COLUMN tool_versions.deleted_at; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.tool_versions.deleted_at IS '逻辑删除时间';


--
-- Name: tools; Type: TABLE; Schema: public; Owner: imagentx_user
--

CREATE TABLE public.tools (
    id character varying(36) NOT NULL,
    name character varying(255) NOT NULL,
    icon character varying(255),
    subtitle character varying(255),
    description text,
    user_id character varying(36) NOT NULL,
    labels jsonb,
    tool_type character varying(50) NOT NULL,
    upload_type character varying(20) NOT NULL,
    upload_url character varying(255),
    install_command jsonb,
    tool_list jsonb,
    reject_reason text,
    failed_step_status character varying(20),
    mcp_server_name character varying(255),
    status character varying(20) NOT NULL,
    is_office boolean DEFAULT false,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp without time zone,
    is_global boolean DEFAULT false NOT NULL
);


ALTER TABLE public.tools OWNER TO imagentx_user;

--
-- Name: TABLE tools; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON TABLE public.tools IS '工具实体类';


--
-- Name: COLUMN tools.id; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.tools.id IS '工具唯一ID';


--
-- Name: COLUMN tools.name; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.tools.name IS '工具名称';


--
-- Name: COLUMN tools.icon; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.tools.icon IS '工具图标';


--
-- Name: COLUMN tools.subtitle; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.tools.subtitle IS '副标题';


--
-- Name: COLUMN tools.description; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.tools.description IS '工具描述';


--
-- Name: COLUMN tools.user_id; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.tools.user_id IS '用户ID';


--
-- Name: COLUMN tools.labels; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.tools.labels IS '标签列表，JSON数组格式';


--
-- Name: COLUMN tools.tool_type; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.tools.tool_type IS '工具类型';


--
-- Name: COLUMN tools.upload_type; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.tools.upload_type IS '上传方式';


--
-- Name: COLUMN tools.upload_url; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.tools.upload_url IS '上传URL';


--
-- Name: COLUMN tools.install_command; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.tools.install_command IS '安装命令，JSON格式';


--
-- Name: COLUMN tools.tool_list; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.tools.tool_list IS '工具列表，JSON数组格式';


--
-- Name: COLUMN tools.status; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.tools.status IS '审核状态';


--
-- Name: COLUMN tools.is_office; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.tools.is_office IS '是否官方工具';


--
-- Name: COLUMN tools.created_at; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.tools.created_at IS '创建时间';


--
-- Name: COLUMN tools.updated_at; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.tools.updated_at IS '更新时间';


--
-- Name: COLUMN tools.deleted_at; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.tools.deleted_at IS '逻辑删除时间';


--
-- Name: COLUMN tools.is_global; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.tools.is_global IS '是否为全局工具（true=全局工具，在系统级别部署；false=用户工具，需要在用户容器中部署）';


--
-- Name: usage_records; Type: TABLE; Schema: public; Owner: imagentx_user
--

CREATE TABLE public.usage_records (
    id character varying(64) NOT NULL,
    user_id character varying(64) NOT NULL,
    product_id character varying(64) NOT NULL,
    quantity_data jsonb,
    cost numeric(20,8) NOT NULL,
    request_id character varying(255) NOT NULL,
    billed_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    deleted_at timestamp without time zone,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    service_name character varying(255),
    service_type character varying(100),
    service_description text,
    pricing_rule text,
    related_entity_name character varying(255)
);


ALTER TABLE public.usage_records OWNER TO imagentx_user;

--
-- Name: TABLE usage_records; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON TABLE public.usage_records IS '使用记录表，存储用户的具体消费记录';


--
-- Name: COLUMN usage_records.user_id; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.usage_records.user_id IS '用户ID';


--
-- Name: COLUMN usage_records.product_id; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.usage_records.product_id IS '商品ID';


--
-- Name: COLUMN usage_records.quantity_data; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.usage_records.quantity_data IS '使用量数据（JSONB格式）';


--
-- Name: COLUMN usage_records.cost; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.usage_records.cost IS '本次消费金额';


--
-- Name: COLUMN usage_records.request_id; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.usage_records.request_id IS '请求ID（幂等性保证）';


--
-- Name: COLUMN usage_records.billed_at; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.usage_records.billed_at IS '计费时间';


--
-- Name: COLUMN usage_records.service_name; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.usage_records.service_name IS '服务名称（如：GPT-4 模型调用）';


--
-- Name: COLUMN usage_records.service_type; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.usage_records.service_type IS '服务类型（如：模型服务）';


--
-- Name: COLUMN usage_records.service_description; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.usage_records.service_description IS '服务描述';


--
-- Name: COLUMN usage_records.pricing_rule; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.usage_records.pricing_rule IS '定价规则说明（如：输入 ¥0.002/1K tokens，输出 ¥0.006/1K tokens）';


--
-- Name: COLUMN usage_records.related_entity_name; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.usage_records.related_entity_name IS '关联实体名称（如：具体的模型名称或Agent名称）';


--
-- Name: user_containers; Type: TABLE; Schema: public; Owner: imagentx_user
--

CREATE TABLE public.user_containers (
    id character varying(36) NOT NULL,
    name character varying(100) NOT NULL,
    user_id character varying(36) NOT NULL,
    type character varying(255) NOT NULL,
    status integer NOT NULL,
    docker_container_id character varying(100),
    image character varying(200) NOT NULL,
    internal_port integer NOT NULL,
    external_port integer,
    ip_address character varying(45),
    cpu_usage numeric(5,2),
    memory_usage numeric(5,2),
    volume_path character varying(500),
    env_config text,
    container_config text,
    error_message text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp without time zone,
    last_accessed_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.user_containers OWNER TO imagentx_user;

--
-- Name: TABLE user_containers; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON TABLE public.user_containers IS '用户容器表';


--
-- Name: COLUMN user_containers.id; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.user_containers.id IS '容器ID';


--
-- Name: COLUMN user_containers.name; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.user_containers.name IS '容器名称';


--
-- Name: COLUMN user_containers.user_id; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.user_containers.user_id IS '用户ID';


--
-- Name: COLUMN user_containers.status; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.user_containers.status IS '容器状态: 1-创建中, 2-运行中, 3-已停止, 4-错误状态, 5-删除中, 6-已删除';


--
-- Name: COLUMN user_containers.docker_container_id; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.user_containers.docker_container_id IS 'Docker容器ID';


--
-- Name: COLUMN user_containers.image; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.user_containers.image IS '容器镜像';


--
-- Name: COLUMN user_containers.internal_port; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.user_containers.internal_port IS '内部端口';


--
-- Name: COLUMN user_containers.external_port; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.user_containers.external_port IS '外部映射端口';


--
-- Name: COLUMN user_containers.ip_address; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.user_containers.ip_address IS '容器IP地址';


--
-- Name: COLUMN user_containers.cpu_usage; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.user_containers.cpu_usage IS 'CPU使用率(%)';


--
-- Name: COLUMN user_containers.memory_usage; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.user_containers.memory_usage IS '内存使用率(%)';


--
-- Name: COLUMN user_containers.volume_path; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.user_containers.volume_path IS '数据卷路径';


--
-- Name: COLUMN user_containers.env_config; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.user_containers.env_config IS '环境变量配置(JSON)';


--
-- Name: COLUMN user_containers.container_config; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.user_containers.container_config IS '容器配置(JSON)';


--
-- Name: COLUMN user_containers.error_message; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.user_containers.error_message IS '错误信息';


--
-- Name: COLUMN user_containers.created_at; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.user_containers.created_at IS '创建时间';


--
-- Name: COLUMN user_containers.updated_at; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.user_containers.updated_at IS '更新时间';


--
-- Name: COLUMN user_containers.last_accessed_at; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.user_containers.last_accessed_at IS '最后访问时间，用于自动清理判断';


--
-- Name: user_rag_documents; Type: TABLE; Schema: public; Owner: imagentx_user
--

CREATE TABLE public.user_rag_documents (
    id character varying(36) NOT NULL,
    user_rag_id character varying(36) NOT NULL,
    user_rag_file_id character varying(36) NOT NULL,
    original_document_id character varying(36),
    content text NOT NULL,
    page integer,
    vector_id character varying(36),
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp without time zone
);


ALTER TABLE public.user_rag_documents OWNER TO imagentx_user;

--
-- Name: TABLE user_rag_documents; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON TABLE public.user_rag_documents IS '用户RAG文档快照表 - 用于SNAPSHOT类型RAG的完全数据隔离';


--
-- Name: COLUMN user_rag_documents.id; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.user_rag_documents.id IS '主键ID';


--
-- Name: COLUMN user_rag_documents.user_rag_id; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.user_rag_documents.user_rag_id IS '关联user_rags表的ID';


--
-- Name: COLUMN user_rag_documents.user_rag_file_id; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.user_rag_documents.user_rag_file_id IS '关联user_rag_files表的ID';


--
-- Name: COLUMN user_rag_documents.original_document_id; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.user_rag_documents.original_document_id IS '原始文档单元ID（仅用于标识，不依赖）';


--
-- Name: COLUMN user_rag_documents.content; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.user_rag_documents.content IS '文档内容（快照）';


--
-- Name: COLUMN user_rag_documents.page; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.user_rag_documents.page IS '页码';


--
-- Name: COLUMN user_rag_documents.vector_id; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.user_rag_documents.vector_id IS '向量ID（在向量数据库中的ID）';


--
-- Name: user_rag_files; Type: TABLE; Schema: public; Owner: imagentx_user
--

CREATE TABLE public.user_rag_files (
    id character varying(36) NOT NULL,
    user_rag_id character varying(36) NOT NULL,
    original_file_id character varying(36) NOT NULL,
    file_name character varying(255) NOT NULL,
    file_size bigint DEFAULT 0,
    file_type character varying(50),
    file_path character varying(500),
    process_status integer,
    embedding_status integer,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp without time zone,
    file_page_size integer DEFAULT 0
);


ALTER TABLE public.user_rag_files OWNER TO imagentx_user;

--
-- Name: TABLE user_rag_files; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON TABLE public.user_rag_files IS '用户RAG文件快照表 - 用于SNAPSHOT类型RAG的完全数据隔离';


--
-- Name: COLUMN user_rag_files.id; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.user_rag_files.id IS '主键ID';


--
-- Name: COLUMN user_rag_files.user_rag_id; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.user_rag_files.user_rag_id IS '关联user_rags表的ID';


--
-- Name: COLUMN user_rag_files.original_file_id; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.user_rag_files.original_file_id IS '原始文件ID（仅用于标识，不依赖）';


--
-- Name: COLUMN user_rag_files.file_name; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.user_rag_files.file_name IS '文件名（快照）';


--
-- Name: COLUMN user_rag_files.file_size; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.user_rag_files.file_size IS '文件大小（字节）';


--
-- Name: COLUMN user_rag_files.file_type; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.user_rag_files.file_type IS '文件类型';


--
-- Name: COLUMN user_rag_files.file_path; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.user_rag_files.file_path IS '文件存储路径';


--
-- Name: COLUMN user_rag_files.process_status; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.user_rag_files.process_status IS '处理状态（快照）';


--
-- Name: COLUMN user_rag_files.embedding_status; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.user_rag_files.embedding_status IS '向量化状态（快照）';


--
-- Name: COLUMN user_rag_files.file_page_size; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.user_rag_files.file_page_size IS '文件页数（快照）';


--
-- Name: user_rags; Type: TABLE; Schema: public; Owner: imagentx_user
--

CREATE TABLE public.user_rags (
    id character varying(36) NOT NULL,
    user_id character varying(36) NOT NULL,
    rag_version_id character varying(36) NOT NULL,
    name character varying(255) NOT NULL,
    description text,
    icon character varying(255),
    version character varying(50) NOT NULL,
    installed_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp without time zone,
    original_rag_id character varying(64),
    install_type character varying(20) DEFAULT 'SNAPSHOT'::character varying
);


ALTER TABLE public.user_rags OWNER TO imagentx_user;

--
-- Name: TABLE user_rags; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON TABLE public.user_rags IS '用户安装的RAG表';


--
-- Name: COLUMN user_rags.id; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.user_rags.id IS '主键ID';


--
-- Name: COLUMN user_rags.user_id; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.user_rags.user_id IS '用户ID';


--
-- Name: COLUMN user_rags.rag_version_id; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.user_rags.rag_version_id IS '关联的RAG版本快照ID';


--
-- Name: COLUMN user_rags.name; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.user_rags.name IS '安装时的名称';


--
-- Name: COLUMN user_rags.description; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.user_rags.description IS '安装时的描述';


--
-- Name: COLUMN user_rags.icon; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.user_rags.icon IS '安装时的图标';


--
-- Name: COLUMN user_rags.version; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.user_rags.version IS '版本号';


--
-- Name: COLUMN user_rags.installed_at; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.user_rags.installed_at IS '安装时间';


--
-- Name: COLUMN user_rags.created_at; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.user_rags.created_at IS '创建时间';


--
-- Name: COLUMN user_rags.updated_at; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.user_rags.updated_at IS '更新时间';


--
-- Name: COLUMN user_rags.deleted_at; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.user_rags.deleted_at IS '删除时间（软删除）';


--
-- Name: COLUMN user_rags.original_rag_id; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.user_rags.original_rag_id IS '原始RAG数据集ID';


--
-- Name: COLUMN user_rags.install_type; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.user_rags.install_type IS '安装类型：REFERENCE(引用)/SNAPSHOT(快照)';


--
-- Name: user_settings; Type: TABLE; Schema: public; Owner: imagentx_user
--

CREATE TABLE public.user_settings (
    id character varying(36) NOT NULL,
    user_id character varying(36) NOT NULL,
    setting_config json,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp without time zone
);


ALTER TABLE public.user_settings OWNER TO imagentx_user;

--
-- Name: TABLE user_settings; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON TABLE public.user_settings IS '用户设置表，存储用户的个性化配置';


--
-- Name: COLUMN user_settings.id; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.user_settings.id IS '设置记录唯一ID';


--
-- Name: COLUMN user_settings.user_id; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.user_settings.user_id IS '用户ID，关联users表';


--
-- Name: COLUMN user_settings.setting_config; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.user_settings.setting_config IS '设置配置JSON，格式：{"default_model": "模型ID"}';


--
-- Name: COLUMN user_settings.created_at; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.user_settings.created_at IS '创建时间';


--
-- Name: COLUMN user_settings.updated_at; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.user_settings.updated_at IS '更新时间';


--
-- Name: COLUMN user_settings.deleted_at; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.user_settings.deleted_at IS '逻辑删除时间';


--
-- Name: user_tools; Type: TABLE; Schema: public; Owner: imagentx_user
--

CREATE TABLE public.user_tools (
    id character varying(36) NOT NULL,
    user_id character varying(36) NOT NULL,
    name character varying(255) NOT NULL,
    description text,
    icon character varying(255),
    subtitle character varying(255),
    tool_id character varying(36) NOT NULL,
    version character varying(50) NOT NULL,
    tool_list jsonb,
    labels jsonb,
    is_office boolean DEFAULT false,
    public_state boolean DEFAULT false,
    mcp_server_name character varying(255),
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp without time zone,
    is_global boolean DEFAULT false NOT NULL
);


ALTER TABLE public.user_tools OWNER TO imagentx_user;

--
-- Name: TABLE user_tools; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON TABLE public.user_tools IS '用户工具关联实体类';


--
-- Name: COLUMN user_tools.id; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.user_tools.id IS '唯一ID';


--
-- Name: COLUMN user_tools.user_id; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.user_tools.user_id IS '用户ID';


--
-- Name: COLUMN user_tools.name; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.user_tools.name IS '工具名称';


--
-- Name: COLUMN user_tools.description; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.user_tools.description IS '工具描述';


--
-- Name: COLUMN user_tools.icon; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.user_tools.icon IS '工具图标';


--
-- Name: COLUMN user_tools.subtitle; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.user_tools.subtitle IS '副标题';


--
-- Name: COLUMN user_tools.tool_id; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.user_tools.tool_id IS '工具ID';


--
-- Name: COLUMN user_tools.version; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.user_tools.version IS '版本号';


--
-- Name: COLUMN user_tools.tool_list; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.user_tools.tool_list IS '工具列表，JSON数组格式';


--
-- Name: COLUMN user_tools.labels; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.user_tools.labels IS '标签列表，JSON数组格式';


--
-- Name: COLUMN user_tools.is_office; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.user_tools.is_office IS '是否官方工具';


--
-- Name: COLUMN user_tools.public_state; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.user_tools.public_state IS '公开状态';


--
-- Name: COLUMN user_tools.mcp_server_name; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.user_tools.mcp_server_name IS 'MCP服务器名称';


--
-- Name: COLUMN user_tools.created_at; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.user_tools.created_at IS '创建时间';


--
-- Name: COLUMN user_tools.updated_at; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.user_tools.updated_at IS '更新时间';


--
-- Name: COLUMN user_tools.deleted_at; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.user_tools.deleted_at IS '逻辑删除时间';


--
-- Name: COLUMN user_tools.is_global; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.user_tools.is_global IS '是否为全局工具（继承自原始工具的全局状态）';


--
-- Name: users; Type: TABLE; Schema: public; Owner: imagentx_user
--

CREATE TABLE public.users (
    id character varying(36) NOT NULL,
    nickname character varying(255) NOT NULL,
    email character varying(255),
    phone character varying(11),
    password character varying NOT NULL,
    is_admin boolean DEFAULT false,
    login_platform character varying(50),
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp without time zone,
    github_id character varying(255),
    github_login character varying(255),
    avatar_url character varying(255)
);


ALTER TABLE public.users OWNER TO imagentx_user;

--
-- Name: COLUMN users.id; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.users.id IS '主键';


--
-- Name: COLUMN users.nickname; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.users.nickname IS '昵称';


--
-- Name: COLUMN users.email; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.users.email IS '邮箱';


--
-- Name: COLUMN users.phone; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.users.phone IS '手机号';


--
-- Name: COLUMN users.password; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.users.password IS '密码';


--
-- Name: COLUMN users.created_at; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.users.created_at IS '创建时间';


--
-- Name: COLUMN users.updated_at; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.users.updated_at IS '更新时间';


--
-- Name: COLUMN users.deleted_at; Type: COMMENT; Schema: public; Owner: imagentx_user
--

COMMENT ON COLUMN public.users.deleted_at IS '逻辑删除时间';


--
-- Name: agent_execution_details id; Type: DEFAULT; Schema: public; Owner: imagentx_user
--

ALTER TABLE ONLY public.agent_execution_details ALTER COLUMN id SET DEFAULT nextval('public.agent_execution_details_id_seq'::regclass);


--
-- Name: agent_execution_summary id; Type: DEFAULT; Schema: public; Owner: imagentx_user
--

ALTER TABLE ONLY public.agent_execution_summary ALTER COLUMN id SET DEFAULT nextval('public.agent_execution_summary_id_seq'::regclass);


--
-- Data for Name: accounts; Type: TABLE DATA; Schema: public; Owner: imagentx_user
--

COPY public.accounts (id, user_id, balance, credit, total_consumed, last_transaction_at, deleted_at, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: agent_execution_details; Type: TABLE DATA; Schema: public; Owner: imagentx_user
--

COPY public.agent_execution_details (id, trace_id, sequence_no, step_type, message_content, message_type, model_id, provider_name, message_tokens, model_call_time, tool_name, tool_request_args, tool_response_data, tool_execution_time, tool_success, is_fallback_used, fallback_reason, fallback_from_model, fallback_to_model, step_cost, step_success, step_error_message, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: agent_execution_summary; Type: TABLE DATA; Schema: public; Owner: imagentx_user
--

COPY public.agent_execution_summary (id, trace_id, user_id, session_id, agent_id, execution_start_time, execution_end_time, total_execution_time, total_input_tokens, total_output_tokens, total_tokens, tool_call_count, total_tool_execution_time, total_cost, execution_success, error_phase, error_message, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: agent_tasks; Type: TABLE DATA; Schema: public; Owner: imagentx_user
--

COPY public.agent_tasks (id, session_id, user_id, parent_task_id, task_name, description, status, progress, start_time, end_time, task_result, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: agent_versions; Type: TABLE DATA; Schema: public; Owner: imagentx_user
--

COPY public.agent_versions (id, agent_id, name, avatar, description, version_number, system_prompt, welcome_message, tool_ids, knowledge_base_ids, change_log, publish_status, reject_reason, review_time, published_at, user_id, tool_preset_params, multi_modal, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: agent_workspace; Type: TABLE DATA; Schema: public; Owner: imagentx_user
--

COPY public.agent_workspace (id, agent_id, user_id, llm_model_config, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: agents; Type: TABLE DATA; Schema: public; Owner: imagentx_user
--

COPY public.agents (id, name, avatar, description, system_prompt, welcome_message, tool_ids, published_version, enabled, user_id, tool_preset_params, multi_modal, created_at, updated_at, deleted_at, knowledge_base_ids) FROM stdin;
\.


--
-- Data for Name: ai_rag_qa_dataset; Type: TABLE DATA; Schema: public; Owner: imagentx_user
--

COPY public.ai_rag_qa_dataset (id, name, icon, description, user_id, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: api_keys; Type: TABLE DATA; Schema: public; Owner: imagentx_user
--

COPY public.api_keys (id, api_key, agent_id, user_id, name, status, usage_count, last_used_at, expires_at, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: auth_settings; Type: TABLE DATA; Schema: public; Owner: imagentx_user
--

COPY public.auth_settings (id, feature_type, feature_key, feature_name, enabled, config_data, display_order, description, created_at, updated_at, deleted_at) FROM stdin;
auth-normal-login	LOGIN	NORMAL_LOGIN	普通登录	t	\N	1	邮箱/手机号密码登录	2025-09-04 04:24:57.216961	2025-09-04 04:24:57.216961	\N
auth-github-login	LOGIN	GITHUB_LOGIN	GitHub登录	t	\N	2	GitHub OAuth登录	2025-09-04 04:24:57.216961	2025-09-04 04:24:57.216961	\N
auth-community-login	LOGIN	COMMUNITY_LOGIN	敲鸭登录	t	\N	3	敲鸭社区OAuth登录	2025-09-04 04:24:57.216961	2025-09-04 04:24:57.216961	\N
auth-user-register	REGISTER	USER_REGISTER	用户注册	t	\N	1	允许新用户注册账号	2025-09-04 04:24:57.216961	2025-09-04 04:24:57.216961	\N
\.


--
-- Data for Name: container_templates; Type: TABLE DATA; Schema: public; Owner: imagentx_user
--

COPY public.container_templates (id, name, description, type, image, image_tag, internal_port, cpu_limit, memory_limit, environment, volume_mount_path, command, network_mode, restart_policy, health_check, resource_config, enabled, is_default, created_by, sort_order, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: context; Type: TABLE DATA; Schema: public; Owner: imagentx_user
--

COPY public.context (id, session_id, active_messages, summary, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: document_unit; Type: TABLE DATA; Schema: public; Owner: imagentx_user
--

COPY public.document_unit (id, file_id, page, content, flag, is_vector, created_at, updated_at, deleted_at, is_ocr) FROM stdin;
\.


--
-- Data for Name: file_detail; Type: TABLE DATA; Schema: public; Owner: imagentx_user
--

COPY public.file_detail (id, url, size, filename, original_filename, base_path, path, ext, content_type, platform, th_url, th_filename, th_size, th_content_type, object_id, object_type, metadata, user_metadata, th_metadata, th_user_metadata, attr, file_acl, th_file_acl, hash_info, upload_id, upload_status, user_id, data_set_id, created_at, updated_at, deleted_at, file_page_size, current_page_number, process_progress, current_ocr_page_number, current_embedding_page_number, ocr_process_progress, embedding_process_progress, processing_status) FROM stdin;
\.


--
-- Data for Name: messages; Type: TABLE DATA; Schema: public; Owner: imagentx_user
--

COPY public.messages (id, session_id, role, content, message_type, token_count, body_token_count, provider, model, metadata, file_urls, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: models; Type: TABLE DATA; Schema: public; Owner: imagentx_user
--

COPY public.models (id, user_id, provider_id, model_id, name, model_endpoint, description, is_official, type, status, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: orders; Type: TABLE DATA; Schema: public; Owner: imagentx_user
--

COPY public.orders (id, user_id, order_no, order_type, title, description, amount, currency, status, expired_at, paid_at, cancelled_at, refunded_at, refund_amount, payment_platform, payment_type, provider_order_id, metadata, deleted_at, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: products; Type: TABLE DATA; Schema: public; Owner: imagentx_user
--

COPY public.products (id, name, type, service_id, rule_id, pricing_config, status, deleted_at, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: providers; Type: TABLE DATA; Schema: public; Owner: imagentx_user
--

COPY public.providers (id, user_id, protocol, name, description, config, is_official, status, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: rag_version_documents; Type: TABLE DATA; Schema: public; Owner: imagentx_user
--

COPY public.rag_version_documents (id, rag_version_id, rag_version_file_id, original_document_id, content, page, vector_id, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: rag_version_files; Type: TABLE DATA; Schema: public; Owner: imagentx_user
--

COPY public.rag_version_files (id, rag_version_id, original_file_id, file_name, file_size, file_type, file_path, process_status, embedding_status, created_at, updated_at, deleted_at, file_page_size) FROM stdin;
\.


--
-- Data for Name: rag_versions; Type: TABLE DATA; Schema: public; Owner: imagentx_user
--

COPY public.rag_versions (id, name, icon, description, user_id, version, change_log, labels, original_rag_id, original_rag_name, file_count, total_size, document_count, publish_status, reject_reason, review_time, published_at, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: rules; Type: TABLE DATA; Schema: public; Owner: imagentx_user
--

COPY public.rules (id, name, handler_key, description, deleted_at, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: scheduled_tasks; Type: TABLE DATA; Schema: public; Owner: imagentx_user
--

COPY public.scheduled_tasks (id, user_id, agent_id, session_id, content, repeat_type, repeat_config, status, last_execute_time, next_execute_time, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: sessions; Type: TABLE DATA; Schema: public; Owner: imagentx_user
--

COPY public.sessions (id, title, user_id, agent_id, description, is_archived, metadata, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: tool_versions; Type: TABLE DATA; Schema: public; Owner: imagentx_user
--

COPY public.tool_versions (id, name, icon, subtitle, description, user_id, version, tool_id, upload_type, change_log, upload_url, tool_list, labels, mcp_server_name, is_office, public_status, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: tools; Type: TABLE DATA; Schema: public; Owner: imagentx_user
--

COPY public.tools (id, name, icon, subtitle, description, user_id, labels, tool_type, upload_type, upload_url, install_command, tool_list, reject_reason, failed_step_status, mcp_server_name, status, is_office, created_at, updated_at, deleted_at, is_global) FROM stdin;
\.


--
-- Data for Name: usage_records; Type: TABLE DATA; Schema: public; Owner: imagentx_user
--

COPY public.usage_records (id, user_id, product_id, quantity_data, cost, request_id, billed_at, deleted_at, created_at, updated_at, service_name, service_type, service_description, pricing_rule, related_entity_name) FROM stdin;
\.


--
-- Data for Name: user_containers; Type: TABLE DATA; Schema: public; Owner: imagentx_user
--

COPY public.user_containers (id, name, user_id, type, status, docker_container_id, image, internal_port, external_port, ip_address, cpu_usage, memory_usage, volume_path, env_config, container_config, error_message, created_at, updated_at, deleted_at, last_accessed_at) FROM stdin;
\.


--
-- Data for Name: user_rag_documents; Type: TABLE DATA; Schema: public; Owner: imagentx_user
--

COPY public.user_rag_documents (id, user_rag_id, user_rag_file_id, original_document_id, content, page, vector_id, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: user_rag_files; Type: TABLE DATA; Schema: public; Owner: imagentx_user
--

COPY public.user_rag_files (id, user_rag_id, original_file_id, file_name, file_size, file_type, file_path, process_status, embedding_status, created_at, updated_at, deleted_at, file_page_size) FROM stdin;
\.


--
-- Data for Name: user_rags; Type: TABLE DATA; Schema: public; Owner: imagentx_user
--

COPY public.user_rags (id, user_id, rag_version_id, name, description, icon, version, installed_at, created_at, updated_at, deleted_at, original_rag_id, install_type) FROM stdin;
\.


--
-- Data for Name: user_settings; Type: TABLE DATA; Schema: public; Owner: imagentx_user
--

COPY public.user_settings (id, user_id, setting_config, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: user_tools; Type: TABLE DATA; Schema: public; Owner: imagentx_user
--

COPY public.user_tools (id, user_id, name, description, icon, subtitle, tool_id, version, tool_list, labels, is_office, public_state, mcp_server_name, created_at, updated_at, deleted_at, is_global) FROM stdin;
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: imagentx_user
--

COPY public.users (id, nickname, email, phone, password, is_admin, login_platform, created_at, updated_at, deleted_at, github_id, github_login, avatar_url) FROM stdin;
\.


--
-- Name: agent_execution_details_id_seq; Type: SEQUENCE SET; Schema: public; Owner: imagentx_user
--

SELECT pg_catalog.setval('public.agent_execution_details_id_seq', 1, false);


--
-- Name: agent_execution_summary_id_seq; Type: SEQUENCE SET; Schema: public; Owner: imagentx_user
--

SELECT pg_catalog.setval('public.agent_execution_summary_id_seq', 1, false);


--
-- Name: accounts accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: imagentx_user
--

ALTER TABLE ONLY public.accounts
    ADD CONSTRAINT accounts_pkey PRIMARY KEY (id);


--
-- Name: agent_execution_details agent_execution_details_pkey; Type: CONSTRAINT; Schema: public; Owner: imagentx_user
--

ALTER TABLE ONLY public.agent_execution_details
    ADD CONSTRAINT agent_execution_details_pkey PRIMARY KEY (id);


--
-- Name: agent_execution_summary agent_execution_summary_pkey; Type: CONSTRAINT; Schema: public; Owner: imagentx_user
--

ALTER TABLE ONLY public.agent_execution_summary
    ADD CONSTRAINT agent_execution_summary_pkey PRIMARY KEY (id);


--
-- Name: agent_tasks agent_tasks_pkey; Type: CONSTRAINT; Schema: public; Owner: imagentx_user
--

ALTER TABLE ONLY public.agent_tasks
    ADD CONSTRAINT agent_tasks_pkey PRIMARY KEY (id);


--
-- Name: agent_versions agent_versions_pkey; Type: CONSTRAINT; Schema: public; Owner: imagentx_user
--

ALTER TABLE ONLY public.agent_versions
    ADD CONSTRAINT agent_versions_pkey PRIMARY KEY (id);


--
-- Name: agent_workspace agent_workspace_pkey; Type: CONSTRAINT; Schema: public; Owner: imagentx_user
--

ALTER TABLE ONLY public.agent_workspace
    ADD CONSTRAINT agent_workspace_pkey PRIMARY KEY (id);


--
-- Name: agents agents_pkey; Type: CONSTRAINT; Schema: public; Owner: imagentx_user
--

ALTER TABLE ONLY public.agents
    ADD CONSTRAINT agents_pkey PRIMARY KEY (id);


--
-- Name: ai_rag_qa_dataset ai_rag_qa_dataset_pkey; Type: CONSTRAINT; Schema: public; Owner: imagentx_user
--

ALTER TABLE ONLY public.ai_rag_qa_dataset
    ADD CONSTRAINT ai_rag_qa_dataset_pkey PRIMARY KEY (id);


--
-- Name: api_keys api_keys_pkey; Type: CONSTRAINT; Schema: public; Owner: imagentx_user
--

ALTER TABLE ONLY public.api_keys
    ADD CONSTRAINT api_keys_pkey PRIMARY KEY (id);


--
-- Name: auth_settings auth_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: imagentx_user
--

ALTER TABLE ONLY public.auth_settings
    ADD CONSTRAINT auth_settings_pkey PRIMARY KEY (id);


--
-- Name: container_templates container_templates_pkey; Type: CONSTRAINT; Schema: public; Owner: imagentx_user
--

ALTER TABLE ONLY public.container_templates
    ADD CONSTRAINT container_templates_pkey PRIMARY KEY (id);


--
-- Name: context context_pkey; Type: CONSTRAINT; Schema: public; Owner: imagentx_user
--

ALTER TABLE ONLY public.context
    ADD CONSTRAINT context_pkey PRIMARY KEY (id);


--
-- Name: document_unit document_unit_pkey; Type: CONSTRAINT; Schema: public; Owner: imagentx_user
--

ALTER TABLE ONLY public.document_unit
    ADD CONSTRAINT document_unit_pkey PRIMARY KEY (id);


--
-- Name: file_detail file_detail_pkey; Type: CONSTRAINT; Schema: public; Owner: imagentx_user
--

ALTER TABLE ONLY public.file_detail
    ADD CONSTRAINT file_detail_pkey PRIMARY KEY (id);


--
-- Name: messages messages_pkey; Type: CONSTRAINT; Schema: public; Owner: imagentx_user
--

ALTER TABLE ONLY public.messages
    ADD CONSTRAINT messages_pkey PRIMARY KEY (id);


--
-- Name: models models_pkey; Type: CONSTRAINT; Schema: public; Owner: imagentx_user
--

ALTER TABLE ONLY public.models
    ADD CONSTRAINT models_pkey PRIMARY KEY (id);


--
-- Name: orders orders_pkey; Type: CONSTRAINT; Schema: public; Owner: imagentx_user
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_pkey PRIMARY KEY (id);


--
-- Name: products products_pkey; Type: CONSTRAINT; Schema: public; Owner: imagentx_user
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_pkey PRIMARY KEY (id);


--
-- Name: providers providers_pkey; Type: CONSTRAINT; Schema: public; Owner: imagentx_user
--

ALTER TABLE ONLY public.providers
    ADD CONSTRAINT providers_pkey PRIMARY KEY (id);


--
-- Name: rag_version_documents rag_version_documents_pkey; Type: CONSTRAINT; Schema: public; Owner: imagentx_user
--

ALTER TABLE ONLY public.rag_version_documents
    ADD CONSTRAINT rag_version_documents_pkey PRIMARY KEY (id);


--
-- Name: rag_version_files rag_version_files_pkey; Type: CONSTRAINT; Schema: public; Owner: imagentx_user
--

ALTER TABLE ONLY public.rag_version_files
    ADD CONSTRAINT rag_version_files_pkey PRIMARY KEY (id);


--
-- Name: rag_versions rag_versions_pkey; Type: CONSTRAINT; Schema: public; Owner: imagentx_user
--

ALTER TABLE ONLY public.rag_versions
    ADD CONSTRAINT rag_versions_pkey PRIMARY KEY (id);


--
-- Name: rules rules_pkey; Type: CONSTRAINT; Schema: public; Owner: imagentx_user
--

ALTER TABLE ONLY public.rules
    ADD CONSTRAINT rules_pkey PRIMARY KEY (id);


--
-- Name: scheduled_tasks scheduled_tasks_pkey; Type: CONSTRAINT; Schema: public; Owner: imagentx_user
--

ALTER TABLE ONLY public.scheduled_tasks
    ADD CONSTRAINT scheduled_tasks_pkey PRIMARY KEY (id);


--
-- Name: sessions sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: imagentx_user
--

ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (id);


--
-- Name: tool_versions tool_versions_pkey; Type: CONSTRAINT; Schema: public; Owner: imagentx_user
--

ALTER TABLE ONLY public.tool_versions
    ADD CONSTRAINT tool_versions_pkey PRIMARY KEY (id);


--
-- Name: tools tools_pkey; Type: CONSTRAINT; Schema: public; Owner: imagentx_user
--

ALTER TABLE ONLY public.tools
    ADD CONSTRAINT tools_pkey PRIMARY KEY (id);


--
-- Name: usage_records usage_records_pkey; Type: CONSTRAINT; Schema: public; Owner: imagentx_user
--

ALTER TABLE ONLY public.usage_records
    ADD CONSTRAINT usage_records_pkey PRIMARY KEY (id);


--
-- Name: user_containers user_containers_pkey; Type: CONSTRAINT; Schema: public; Owner: imagentx_user
--

ALTER TABLE ONLY public.user_containers
    ADD CONSTRAINT user_containers_pkey PRIMARY KEY (id);


--
-- Name: user_rag_documents user_rag_documents_pkey; Type: CONSTRAINT; Schema: public; Owner: imagentx_user
--

ALTER TABLE ONLY public.user_rag_documents
    ADD CONSTRAINT user_rag_documents_pkey PRIMARY KEY (id);


--
-- Name: user_rag_files user_rag_files_pkey; Type: CONSTRAINT; Schema: public; Owner: imagentx_user
--

ALTER TABLE ONLY public.user_rag_files
    ADD CONSTRAINT user_rag_files_pkey PRIMARY KEY (id);


--
-- Name: user_rags user_rags_pkey; Type: CONSTRAINT; Schema: public; Owner: imagentx_user
--

ALTER TABLE ONLY public.user_rags
    ADD CONSTRAINT user_rags_pkey PRIMARY KEY (id);


--
-- Name: user_settings user_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: imagentx_user
--

ALTER TABLE ONLY public.user_settings
    ADD CONSTRAINT user_settings_pkey PRIMARY KEY (id);


--
-- Name: user_tools user_tools_pkey; Type: CONSTRAINT; Schema: public; Owner: imagentx_user
--

ALTER TABLE ONLY public.user_tools
    ADD CONSTRAINT user_tools_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: imagentx_user
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: agent_execution_summary_trace_id_key; Type: INDEX; Schema: public; Owner: imagentx_user
--

CREATE UNIQUE INDEX agent_execution_summary_trace_id_key ON public.agent_execution_summary USING btree (trace_id);


--
-- Name: api_keys_api_key_key; Type: INDEX; Schema: public; Owner: imagentx_user
--

CREATE UNIQUE INDEX api_keys_api_key_key ON public.api_keys USING btree (api_key);


--
-- Name: auth_settings_feature_key_key; Type: INDEX; Schema: public; Owner: imagentx_user
--

CREATE UNIQUE INDEX auth_settings_feature_key_key ON public.auth_settings USING btree (feature_key);


--
-- Name: container_templates_name_key; Type: INDEX; Schema: public; Owner: imagentx_user
--

CREATE UNIQUE INDEX container_templates_name_key ON public.container_templates USING btree (name);


--
-- Name: idx_agent_exec_details_model; Type: INDEX; Schema: public; Owner: imagentx_user
--

CREATE INDEX idx_agent_exec_details_model ON public.agent_execution_details USING btree (model_id);


--
-- Name: idx_agent_exec_details_tool; Type: INDEX; Schema: public; Owner: imagentx_user
--

CREATE INDEX idx_agent_exec_details_tool ON public.agent_execution_details USING btree (tool_name);


--
-- Name: idx_agent_exec_details_trace_seq; Type: INDEX; Schema: public; Owner: imagentx_user
--

CREATE INDEX idx_agent_exec_details_trace_seq ON public.agent_execution_details USING btree (trace_id, sequence_no);


--
-- Name: idx_agent_exec_details_trace_type; Type: INDEX; Schema: public; Owner: imagentx_user
--

CREATE INDEX idx_agent_exec_details_trace_type ON public.agent_execution_details USING btree (trace_id, step_type);


--
-- Name: idx_agent_exec_summary_agent; Type: INDEX; Schema: public; Owner: imagentx_user
--

CREATE INDEX idx_agent_exec_summary_agent ON public.agent_execution_summary USING btree (agent_id);


--
-- Name: idx_agent_exec_summary_session; Type: INDEX; Schema: public; Owner: imagentx_user
--

CREATE INDEX idx_agent_exec_summary_session ON public.agent_execution_summary USING btree (session_id);


--
-- Name: idx_agent_exec_summary_trace; Type: INDEX; Schema: public; Owner: imagentx_user
--

CREATE INDEX idx_agent_exec_summary_trace ON public.agent_execution_summary USING btree (trace_id);


--
-- Name: idx_agent_exec_summary_user_time; Type: INDEX; Schema: public; Owner: imagentx_user
--

CREATE INDEX idx_agent_exec_summary_user_time ON public.agent_execution_summary USING btree (user_id, execution_start_time);


--
-- Name: idx_agent_execution_details_fallback; Type: INDEX; Schema: public; Owner: imagentx_user
--

CREATE INDEX idx_agent_execution_details_fallback ON public.agent_execution_details USING btree (is_fallback_used) WHERE (is_fallback_used = true);


--
-- Name: idx_agent_tasks_parent_task_id; Type: INDEX; Schema: public; Owner: imagentx_user
--

CREATE INDEX idx_agent_tasks_parent_task_id ON public.agent_tasks USING btree (parent_task_id);


--
-- Name: idx_agent_tasks_session_id; Type: INDEX; Schema: public; Owner: imagentx_user
--

CREATE INDEX idx_agent_tasks_session_id ON public.agent_tasks USING btree (session_id);


--
-- Name: idx_agent_tasks_user_id; Type: INDEX; Schema: public; Owner: imagentx_user
--

CREATE INDEX idx_agent_tasks_user_id ON public.agent_tasks USING btree (user_id);


--
-- Name: idx_agent_versions_agent_id; Type: INDEX; Schema: public; Owner: imagentx_user
--

CREATE INDEX idx_agent_versions_agent_id ON public.agent_versions USING btree (agent_id);


--
-- Name: idx_agent_versions_user_id; Type: INDEX; Schema: public; Owner: imagentx_user
--

CREATE INDEX idx_agent_versions_user_id ON public.agent_versions USING btree (user_id);


--
-- Name: idx_agent_workspace_agent_id; Type: INDEX; Schema: public; Owner: imagentx_user
--

CREATE INDEX idx_agent_workspace_agent_id ON public.agent_workspace USING btree (agent_id);


--
-- Name: idx_agent_workspace_user_id; Type: INDEX; Schema: public; Owner: imagentx_user
--

CREATE INDEX idx_agent_workspace_user_id ON public.agent_workspace USING btree (user_id);


--
-- Name: idx_agents_user_id; Type: INDEX; Schema: public; Owner: imagentx_user
--

CREATE INDEX idx_agents_user_id ON public.agents USING btree (user_id);


--
-- Name: idx_container_templates_created_at; Type: INDEX; Schema: public; Owner: imagentx_user
--

CREATE INDEX idx_container_templates_created_at ON public.container_templates USING btree (created_at);


--
-- Name: idx_container_templates_created_by; Type: INDEX; Schema: public; Owner: imagentx_user
--

CREATE INDEX idx_container_templates_created_by ON public.container_templates USING btree (created_by);


--
-- Name: idx_container_templates_enabled; Type: INDEX; Schema: public; Owner: imagentx_user
--

CREATE INDEX idx_container_templates_enabled ON public.container_templates USING btree (enabled);


--
-- Name: idx_container_templates_is_default; Type: INDEX; Schema: public; Owner: imagentx_user
--

CREATE INDEX idx_container_templates_is_default ON public.container_templates USING btree (is_default);


--
-- Name: idx_container_templates_sort_order; Type: INDEX; Schema: public; Owner: imagentx_user
--

CREATE INDEX idx_container_templates_sort_order ON public.container_templates USING btree (sort_order);


--
-- Name: idx_container_templates_type; Type: INDEX; Schema: public; Owner: imagentx_user
--

CREATE INDEX idx_container_templates_type ON public.container_templates USING btree (type);


--
-- Name: idx_container_templates_type_enabled_default; Type: INDEX; Schema: public; Owner: imagentx_user
--

CREATE INDEX idx_container_templates_type_enabled_default ON public.container_templates USING btree (type, enabled, is_default);


--
-- Name: idx_container_templates_unique_default; Type: INDEX; Schema: public; Owner: imagentx_user
--

CREATE UNIQUE INDEX idx_container_templates_unique_default ON public.container_templates USING btree (type) WHERE (is_default = true);


--
-- Name: idx_context_session_id; Type: INDEX; Schema: public; Owner: imagentx_user
--

CREATE INDEX idx_context_session_id ON public.context USING btree (session_id);


--
-- Name: idx_file_detail_current_embedding_page; Type: INDEX; Schema: public; Owner: imagentx_user
--

CREATE INDEX idx_file_detail_current_embedding_page ON public.file_detail USING btree (current_embedding_page_number);


--
-- Name: idx_file_detail_current_ocr_page; Type: INDEX; Schema: public; Owner: imagentx_user
--

CREATE INDEX idx_file_detail_current_ocr_page ON public.file_detail USING btree (current_ocr_page_number);


--
-- Name: idx_file_detail_current_page; Type: INDEX; Schema: public; Owner: imagentx_user
--

CREATE INDEX idx_file_detail_current_page ON public.file_detail USING btree (current_page_number);


--
-- Name: idx_file_detail_embedding_progress; Type: INDEX; Schema: public; Owner: imagentx_user
--

CREATE INDEX idx_file_detail_embedding_progress ON public.file_detail USING btree (embedding_process_progress);


--
-- Name: idx_file_detail_ocr_progress; Type: INDEX; Schema: public; Owner: imagentx_user
--

CREATE INDEX idx_file_detail_ocr_progress ON public.file_detail USING btree (ocr_process_progress);


--
-- Name: idx_file_detail_progress; Type: INDEX; Schema: public; Owner: imagentx_user
--

CREATE INDEX idx_file_detail_progress ON public.file_detail USING btree (process_progress);


--
-- Name: idx_messages_session_id; Type: INDEX; Schema: public; Owner: imagentx_user
--

CREATE INDEX idx_messages_session_id ON public.messages USING btree (session_id);


--
-- Name: idx_models_provider_id; Type: INDEX; Schema: public; Owner: imagentx_user
--

CREATE INDEX idx_models_provider_id ON public.models USING btree (provider_id);


--
-- Name: idx_models_user_id; Type: INDEX; Schema: public; Owner: imagentx_user
--

CREATE INDEX idx_models_user_id ON public.models USING btree (user_id);


--
-- Name: idx_providers_user_id; Type: INDEX; Schema: public; Owner: imagentx_user
--

CREATE INDEX idx_providers_user_id ON public.providers USING btree (user_id);


--
-- Name: idx_scheduled_tasks_agent_id; Type: INDEX; Schema: public; Owner: imagentx_user
--

CREATE INDEX idx_scheduled_tasks_agent_id ON public.scheduled_tasks USING btree (agent_id);


--
-- Name: idx_scheduled_tasks_session_id; Type: INDEX; Schema: public; Owner: imagentx_user
--

CREATE INDEX idx_scheduled_tasks_session_id ON public.scheduled_tasks USING btree (session_id);


--
-- Name: idx_scheduled_tasks_status; Type: INDEX; Schema: public; Owner: imagentx_user
--

CREATE INDEX idx_scheduled_tasks_status ON public.scheduled_tasks USING btree (status);


--
-- Name: idx_scheduled_tasks_user_id; Type: INDEX; Schema: public; Owner: imagentx_user
--

CREATE INDEX idx_scheduled_tasks_user_id ON public.scheduled_tasks USING btree (user_id);


--
-- Name: idx_sessions_agent_id; Type: INDEX; Schema: public; Owner: imagentx_user
--

CREATE INDEX idx_sessions_agent_id ON public.sessions USING btree (agent_id);


--
-- Name: idx_sessions_user_id; Type: INDEX; Schema: public; Owner: imagentx_user
--

CREATE INDEX idx_sessions_user_id ON public.sessions USING btree (user_id);


--
-- Name: idx_tools_user_id; Type: INDEX; Schema: public; Owner: imagentx_user
--

CREATE INDEX idx_tools_user_id ON public.tools USING btree (user_id);


--
-- Name: idx_user_settings_user_id; Type: INDEX; Schema: public; Owner: imagentx_user
--

CREATE INDEX idx_user_settings_user_id ON public.user_settings USING btree (user_id);


--
-- Name: orders_order_no_key; Type: INDEX; Schema: public; Owner: imagentx_user
--

CREATE UNIQUE INDEX orders_order_no_key ON public.orders USING btree (order_no);


--
-- Name: user_settings_user_id_key; Type: INDEX; Schema: public; Owner: imagentx_user
--

CREATE UNIQUE INDEX user_settings_user_id_key ON public.user_settings USING btree (user_id);


--
-- PostgreSQL database dump complete
--

\unrestrict 7pNeG7ui1dwhTYJ9EOOZDqwabiUbxrbSdWF6GyqSHYaxnw9dmKaDpsktWh7n2UA

