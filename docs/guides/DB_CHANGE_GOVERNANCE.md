# 数据库变更治理（Flyway Core）

## 目标

将数据库变更从“手工执行脚本”升级为“可追踪、可校验、可在 CI 门禁”的流程。

## 当前执行链

1. **初始化/升级（核心追踪表）**
   - `apps/backend/src/main/resources/db/migration/core/V20260415001__core_agent_execution_schema.sql`
   - `apps/backend/src/main/resources/db/migration/core/V20260415002__core_agent_execution_legacy_upgrade.sql`

2. **重复断言（迁移后强校验）**
   - `apps/backend/src/main/resources/db/migration/core/R__core_agent_execution_schema_assertions.sql`

3. **CI 级验证（独立 SQL）**
   - `config/database/sql/02_migrate_agent_execution_schema.sql`
   - `config/database/sql/03_verify_agent_execution_schema.sql`

## 配置

`application.yml`:

- `spring.flyway.enabled=true`
- `spring.flyway.locations=classpath:db/migration/core`
- `spring.flyway.baseline-on-migrate=true`
- `spring.flyway.validate-on-migrate=true`
- `spring.flyway.clean-disabled=true`

`application-h2.yml`:

- `spring.flyway.enabled=false`（H2 测试继续使用既有 SQL init）

## 变更流程（必须遵循）

1. 新增迁移脚本（只增不改历史版本）
2. 在本地执行 `migrate` 并确认无失败
3. 执行 `03_verify_agent_execution_schema.sql`，必须全 PASS
4. 更新对应文档（影响面、回滚策略、验证结果）

## 回滚原则

- 禁止对生产库 `clean`
- 回滚使用“前滚修复”方式（新增更高版本 `V*`）
- 若涉及数据重写，必须提供可审计的备份/恢复脚本

