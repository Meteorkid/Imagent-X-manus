# LangChain4j 迁移方案 A（上游稳定版）

目标：从 `com.github.lucky-aeon.langchain4j`（JitPack fork）迁移到 `dev.langchain4j`（Maven Central），降低构建漂移与离线失败概率。

## 建议兼容性分支

- 分支名：`chore/langchain4j-upstream-migration`
- 节奏：按「依赖替换 -> 编译验证 -> 回归测试 -> 清理遗留」四阶段推进。

## 改造清单

### 阶段 0：基线冻结（已完成）

- [x] 记录当前依赖与风险（fork + SNAPSHOT）。
- [x] 增加快速可回归测试（`HealthControllerWebMvcTest` / `HealthControllerIntegrationTest`）。

### 阶段 1：第一批替换（本次已完成）

- [x] `pom.xml` 坐标迁移：
  - `com.github.lucky-aeon.langchain4j` -> `dev.langchain4j`
- [x] 版本拆分：
  - `langchain4j.stable.version=1.13.0`（core/open-ai/anthropic）
  - `langchain4j.community.version=1.13.0-beta23`（mcp/pgvector/document-parser）
- [x] 删除 `jitpack.io` 仓库依赖。
- [x] Maven 编译验证通过：`mvn -DskipTests compile`

### 阶段 2：兼容性排查（进行中）

- [x] 逐模块回归（基础兼容冒烟）：
  - [x] 对话链路（OpenAI/Anthropic）——`LLMProviderFactory` 迁移为 builder 风格
  - [x] RAG 入库与检索（pgvector）——依赖与类加载校验通过
  - [x] 文档解析（Apache POI parser）——依赖与实例化校验通过
  - [x] MCP 工具调用——依赖与 transport 构建校验通过
- [x] 锁定 breaking API（若出现）并补适配提交：
  - `PresetParameter` 移除：`AgentToolManager` 改为兼容 no-op（保留参数签名，待新 context 机制）
  - `TokenStream` 思维链回调变更：`onPartialReasoning/onCompleteReasoning` -> `onPartialThinking`
  - `TracingMessageHandler` 对齐新 `TokenStream` 接口，修复 `onRetrieved/ignoreErrors` 代理行为

### 阶段 3：测试与发布门禁（进行中）

- [x] 增加业务级回归测试（第一组）：
  - [x] `MCPGatewayServiceTest`（工具网关 URL 构造）
  - [x] `TraceContextFilterTest`（trace 头生成/透传）
  - [x] `LangChain4jCompatibilityTest`（OpenAI / RAG parser+pgvector 类加载 / MCP transport）
- [x] 增加 CI 门禁：禁止回退到 fork 坐标（`check-langchain4j-upstream.sh`）。
- [x] 增加 CI 专项任务：`langchain4j-compat`。
- [x] 增加 CI 冒烟任务：`langchain4j-smoke`（`ci.yml` / `test.yml` 双工作流一致）。
- [x] CI 冒烟对齐本地规则：
  - [x] MCP 探活支持鉴权场景，`401` 可按配置视为服务可达（`MCP_GATEWAY_ALLOW_401_AS_HEALTHY=true`）。
  - [x] PostgreSQL 使用 `pgvector/pgvector:pg15` 并显式执行 `CREATE EXTENSION IF NOT EXISTS vector;`。
- [ ] 发布前灰度验证（预生产 smoke + 回归脚本）。

## 风险与策略

- `langchain4j-mcp` / `langchain4j-pgvector` / `document-parser` 当前上游仍为 `beta` 序列。
  - 策略：先保持与稳定 core 同代版本（`1.13.x`），观察兼容性。
- 若后续出现 API/行为差异：
  - 优先本地适配；
  - 次选在 `apps/backend` 增加轻量兼容层，避免业务层散改。

## 本次落地文件

- `apps/backend/pom.xml`
- `apps/backend/src/main/java/org/xhy/infrastructure/llm/factory/LLMProviderFactory.java`
- `apps/backend/src/main/java/org/xhy/application/conversation/service/message/agent/AgentToolManager.java`
- `apps/backend/src/main/java/org/xhy/application/rag/service/RagQaDatasetAppService.java`
- `apps/backend/src/main/java/org/xhy/application/conversation/service/message/TracingMessageHandler.java`
- `apps/backend/src/test/java/org/xhy/infrastructure/langchain4j/LangChain4jCompatibilityTest.java`
- `.github/workflows/ci.yml`
- `.github/workflows/test.yml`
- `scripts/testing/check-langchain4j-upstream.sh`
- `scripts/testing/langchain4j-smoke.sh`
- `scripts/testing/langchain4j-smoke.env.example`

## 灰度脚本使用

```bash
# 1) 准备环境变量（按需填写 OPENAI/ANTHROPIC/MCP/PG）
cp scripts/testing/langchain4j-smoke.env.example scripts/testing/langchain4j-smoke.env

# 2) 执行灰度脚本
./scripts/testing/langchain4j-smoke.sh

# 3) 查看报告
ls reports/smoke/langchain4j-smoke-*.md
```

## CI 冒烟规则说明（新增）

- `langchain4j-smoke` 在 `ci.yml` 与 `test.yml` 中均启用，作为质量门禁的一部分。
- 默认使用以下环境变量组合（与本地脚本保持一致）：
  - `MCP_GATEWAY_BASE_URL=http://localhost:8081`
  - `MCP_GATEWAY_API_KEY=default-api-key-1234567890`
  - `MCP_GATEWAY_ALLOW_401_AS_HEALTHY=true`
  - `PGHOST=localhost`
  - `PGPORT=5432`
  - `PGDATABASE=imagentx`
  - `PGUSER=imagentx_user`
  - `PGPASSWORD=imagentx_pass`
- 如需严格模式，可将 `MCP_GATEWAY_ALLOW_401_AS_HEALTHY=false`，此时仅 `200` 视为探活成功。
