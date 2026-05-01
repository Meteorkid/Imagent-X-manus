# 架构治理基线（2026Q2）

本文将“架构建议”固化为可执行约束，覆盖以下高优先级问题：

1. 数据库变更治理（Flyway + 校验 + 回滚约束）
2. 后端职责边界（编排/工具/追踪分层）
3. 事件一致性模型（幂等/重试/DLQ/补偿）
4. 可观测性模板（日志字段/指标/告警）
5. 多租户与权限边界（上下文强制传递）
6. 前端域分层（api/domain/ui）
7. 依赖平台化策略（stable/beta 分级）

---

## 1) 数据库变更治理（已落地第一阶段）

- **数据库迁移执行器**：`Flyway`（`spring.flyway.enabled=true`）
- **迁移位置**：`apps/backend/src/main/resources/db/migration/core`
- **核心策略**：
  - `baseline-on-migrate=true`（兼容已存在库）
  - `validate-on-migrate=true`
  - `clean-disabled=true`
- **CI 门禁**：
  - `config/database/sql/02_migrate_agent_execution_schema.sql`
  - `config/database/sql/03_verify_agent_execution_schema.sql`
  - 在 `ci.yml` / `test.yml` 的 `langchain4j-smoke` 中自动执行

### 迁移命名约束

- 结构变更：`V<yyyymmddnnn>__<desc>.sql`
- 断言脚本：`R__<desc>_assertions.sql`
- 禁止直接改历史 `V*` 文件内容（只能新增更高版本）

### 回滚约束

- SQL 回滚必须明确为“前滚修复”（新增 `V*` 修复脚本）
- 禁止在生产执行 `clean`

---

## 2) 后端职责边界（分层约束）

### 目标分层

- **Orchestration（编排层）**：对话流程、状态推进、策略选择
- **Tool Execution（工具层）**：MCP/RAG/外部工具调用
- **Tracing & Audit（追踪层）**：链路记录、审计、计费事件

### 代码约束

- 编排层禁止直接拼接 SQL / 直接依赖 transport 细节
- 工具层返回统一 `ToolExecutionResult` 语义，不透传底层 SDK 异常格式
- 追踪层只能接收标准事件 DTO，不反向调用业务服务

---

## 3) 事件一致性模型（RabbitMQ）

### 必填字段（消息 envelope）

- `eventId`（全局唯一，幂等键）
- `eventType`
- `occurredAt`
- `tenantId` / `userId`
- `traceId`
- `retryCount`

### 幂等与重试

- 消费端必须先做 `eventId` 幂等检查再落库
- 默认重试上限：`maxAttempts=3`（超过进入 DLQ）
- 重试退避：指数退避，最小 3s

### 补偿策略

- 业务失败不可无限重试，必须定义：
  - 是否可重试
  - 超限后的补偿动作（告警/人工处理/反向修正）

---

## 4) 可观测性模板

### 日志字段基线

- 必有：`traceId`、`authChannel`
- 推荐：`tenantId`、`userId`、`idempotencyKey`、`toolName`、`modelEndpoint`

### 指标命名建议（Prometheus）

- `imagentx_model_call_total{provider,model,status}`
- `imagentx_tool_call_total{tool,status}`
- `imagentx_tool_call_duration_ms_bucket{tool}`
- `imagentx_message_consume_total{queue,status}`
- `imagentx_retry_total{queue,reason}`

### 告警最小集

- 工具调用失败率 > 5%（5 分钟窗口）
- 模型调用 p95 延迟 > 阈值
- DLQ 新增消息 > 0

---

## 5) 多租户与权限边界

- 所有异步消息必须携带 `tenantId/userId`
- 管理员接口与普通用户接口严格分路（controller + service 双重校验）
- MCP 工具调用必须记录审计字段：
  - 谁调用（userId/tenantId）
  - 调了什么（toolName/args 摘要）
  - 结果如何（success/error code）

---

## 6) 前端域分层（落地约束）

### 推荐目录

- `app/api/*`：仅路由入口与协议适配
- `lib/domain/<domain>/*`：业务规则与 use-case
- `lib/infrastructure/*`：HTTP 客户端、鉴权、缓存、遥测
- `components/<domain>/*`：纯 UI 组件

### 约束

- UI 组件禁止直接调用 `fetch`（通过 domain 层）
- 鉴权、request-id、错误映射统一走 `lib/infrastructure/http-client`
- `app` 层不直接放业务算法

---

## 7) 依赖策略（stable/beta）

- `stable`：可直接面向业务代码（需有升级窗口）
- `beta/community`：必须经过隔离层（adapter），禁止散落调用

当前示例：

- stable：`dev.langchain4j:langchain4j/open-ai/anthropic`
- community(beta)：`langchain4j-mcp/pgvector/document-parser`

### 升级节奏

- 每月固定一个依赖评审窗口
- 每次升级必须附带：
  - 兼容性测试结果
  - 风险回滚方案
  - 变更摘要

