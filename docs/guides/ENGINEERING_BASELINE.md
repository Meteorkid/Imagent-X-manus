# 工程改进基线（2026-04）

本文记录当前已落地的工程一致性改进，以及下一步演进建议。

## 1) 依赖与构建一致性

- 前端依赖已对齐：`date-fns@3.6.0` + `react-day-picker@8.10.1`，避免再依赖 `legacy-peer-deps`。
- 后端 `langchain4j` 仍使用 JitPack fork（`1.0.4.3-beta7-SNAPSHOT`），并在 `pom.xml` 标注了稳定性说明。
- 建议下一步：
  - 方案 A：迁回上游稳定坐标（优先）。
  - 方案 B：将 fork 制品发布到私有 Maven 仓库（Nexus/Artifactory/GitHub Packages），CI 只依赖私有仓库。

## 2) 测试金字塔

已落地：
- 前端：`lib` 层 Jest 单测（`utils.test.ts`）。
- 前端：Playwright 冒烟 E2E（`e2e/auth-login.spec.ts`）。
- 后端：`HealthControllerWebMvcTest`（standalone MockMvc）。
- 后端：`HealthControllerIntegrationTest`（`@SpringBootTest` + Testcontainers PostgreSQL）。

建议下一步：
- 前端将关键 service（`api-services`、`auth-config-service`）纳入单测。
- 后端补 2~3 个核心业务集成测试（会话、RAG、订单）。

## 3) 鉴权与审计

已落地：
- BFF 代理透传并补齐：`X-Request-Id`、`X-Auth-Channel`。
- 后端统一 `TraceContextFilter`，将 `traceId/authChannel` 注入 MDC 与响应头。

建议下一步：
- 迁移到 `httpOnly` + `refresh token` 机制。
- 明确管理员/门户角色声明（JWT claims 或服务端 session）。
- API Key 与浏览器会话统一审计字段（actorId、actorType、authChannel）。

## 4) 可观测性落地

已落地：
- 日志 pattern 增加 `trace` 与 `auth` 维度，便于日志检索与问题回溯。

建议下一步：
- 产出一套「一键 profile」：
  - `backend` 开启 actuator + prometheus；
  - `config/monitoring/docker-compose.monitoring.yml` 一键拉起；
  - Grafana 预置 dashboard（接口耗时、错误率、消息积压、数据库连接池）。

## 5) 文档与脚本收敛

已落地：
- 新增 `scripts/testing/check-legacy-paths.sh`。
- CI/Test 工作流新增 Repo Guard，阻断 `imagentx-frontend-plus` 回流。

建议下一步：
- 扩展检查范围至更多文档目录；
- 对历史脚本分层：`active` 与 `archive`，减少维护噪音。
