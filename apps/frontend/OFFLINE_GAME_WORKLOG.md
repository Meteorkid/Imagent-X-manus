# 离线小游戏工作日志

> 维护规则：每完成一个任务立即追加记录，包含目标、改动、验证结果、后续计划。

## 2026-04-14（历史回顾补录）

### 阶段成果回顾（此前已完成）
- 接入离线状态机（`online / unstable / offline / recovering`）与离线弹窗。
- 完成实验分流、埋点、周报、SW 配置治理、管理员写配置鉴权、审计日志写入与查询页。
- 修复 `dino.html` 中完整版脚本未实例化导致空格无法开局问题。
- 修复 `/offline-dino/dino` iframe 场景下焦点导致空格无效问题（自动聚焦 iframe）。
- 修复重复加载脚本导致 `Identifier 'DinoGame' has already been declared` 的运行时错误。
- 新增网络恢复提示弹窗（recovering 阶段可返回原网站）。
- 状态机优化：并发探测去竞态、recovering 抖动抑制、动态探测频率与后台降频。
- 补充状态机单测（去竞态、抖动抑制、离线退避阶梯）。

## 2026-04-14（本轮优化）

### 任务 1：默认兜底策略 ✅
**目标**
- 任意版本脚本加载失败时自动回落到默认 `dino-game-fixed.js`。
- UI 明确提示“当前版本不可用，已切换默认版本”。

**改动**
- `components/offline/OfflineGame.tsx`
  - 新增 `activeScriptSrc` 与 `fallbackNotice`。
  - 首次加载失败且非默认版本时，自动尝试加载默认版本并展示提示。
  - UI 显示当前实际生效脚本及版本 ID。

**验证**
- 本地构建通过（见本轮 `npm run build`）。

---

### 任务 2：脚本版本注册表（manifest）✅
**目标**
- 配置不再直接依赖脚本路径，改为版本 ID（如 `v1 / v2`）映射。
- 管理端选择版本时可校验兼容性与离线属性。

**改动**
- `lib/offline-game-script.ts`
  - 新增版本注册表 `OFFLINE_GAME_SCRIPT_REGISTRY`。
  - 新增版本解析与映射函数：
    - `normalizeActiveGameVersion`
    - `resolveGameScriptPathByVersion`
    - `resolveVersionIdFromLegacyScriptPath`
    - `listOfflineGameScriptVersions`
- `lib/server/offline-experiment-config.ts`
  - 配置结构升级：新增 `activeGameVersion`，同时保留 `activeGameScript`（由版本映射推导）。
  - 兼容历史仅路径配置。
- `lib/offline-experiment.ts`
  - 前端配置缓存与拉取逻辑改为“版本 + 脚本推导”。
- `app/api/offline-experiments/config/route.ts`
  - 支持 `activeGameVersion` 写入。
- 新增 `app/api/offline-experiments/script-versions/route.ts`
  - 对外提供版本注册表（管理页读取）。
- 新增管理页 `app/(main)/admin/offline-experiments/page.tsx`
  - 管理员可通过版本 ID 选择并保存。
- `app/(main)/admin/components/AdminSidebar.tsx`
  - 增加「离线实验配置」菜单入口。
- 数据库结构与迁移
  - `lib/server/offline-db.ts` 增加 `active_game_version` 列兼容创建。
  - `db/migrations/20260413_offline_events_optimization.sql` 增加 `active_game_version` 默认列。
  - `db/migrations/20260414_offline_active_game_script.sql` 同步补列版本字段。
  - 新增 `db/migrations/20260415_offline_active_game_version.sql`（历史数据映射修复）。
- 文档更新
  - `OFFLINE_GAME_INTEGRATION.md` 补充版本注册表 API、版本字段与默认兜底说明。
- 测试
  - 新增 `lib/__tests__/offline-game-script.test.ts`。

**验证**
- `npm run build` 通过（新增 `/admin/offline-experiments` 与 `/api/offline-experiments/script-versions` 路由编译成功）。
- `npx jest lib/__tests__/offline-game-script.test.ts --runInBand` 通过（4/4）。

---

### 下一任务（进行中）
3. 完善 SW 缓存策略（默认 pre-cache + runtime 缓存淘汰 + 命中/失败埋点）

---

### 任务 3：SW 缓存策略与观测增强 ✅
**目标**
- 保持“默认版本 pre-cache，其他版本 runtime 缓存”策略。
- 增加 runtime 缓存预算控制，避免无限增长。
- 增加缓存命中率/失败率指标埋点与阈值告警。

**改动**
- `public/offline-dino/sw.js`
  - 新增 runtime 缓存预算：
    - `RUNTIME_CACHE_MAX_ENTRIES = 60`
    - `RUNTIME_CACHE_MAX_BYTES = 30MB`（基于 `content-length` 近似）
  - 新增 `enforceRuntimeCacheBudget()`：
    - 超预算时从最旧缓存开始删除（按 `cache.keys()` 顺序）。
  - 新增 SW 指标聚合与消息广播：
    - 请求数、缓存命中、网络回源、失败数、命中率。
    - 周期/批次发送 `offline-sw-metrics` 给页面。
- `public/offline-game.js`
  - 监听 `offline-sw-metrics` 并上报埋点事件 `offline_sw_metrics`。
  - 失败率阈值告警：当 `fetchFailures / requests > 2%` 时上报 `offline_sw_alert`（`sw_fetch_failure_rate_high`）。

**验证**
- `npm run build` 通过。
- 相关单测回归通过（`utils`、`useNetworkStatus`、`offline-game-script` 共 12/12）。

---

### 任务 4：状态机可维护性升级 ✅
**目标**
- 将状态迁移逻辑改为“表驱动 reducer”，降低 if-else 复杂度。
- 补迁移快照测试，锁定核心迁移矩阵。

**改动**
- 新增 `hooks/networkStateMachine.ts`
  - 抽离纯状态机：
    - `createInitialNetworkStatus`
    - `reduceNetworkStatus`
  - 引入表驱动迁移表 `probeTransitionTable`（按状态 + 成功/失败分发表达）。
  - 新增事件 `ACK_OFFLINE_PROMPT`，统一提示冷却窗口逻辑。
- 重构 `hooks/useNetworkStatus.ts`
  - 由 `useState + 手写分支` 改为 `useReducer + dispatch(event)`。
  - hook 只保留 I/O 与调度（fetch、browser 事件、动态轮询）。
- 新增快照测试 `hooks/__tests__/networkStateMachine.snapshot.test.ts`
  - 覆盖 online/unstable/offline/recovering 的核心迁移矩阵。
  - 写入快照文件锁定行为。

**验证**
- `npx jest hooks/__tests__/useNetworkStatus.test.ts hooks/__tests__/networkStateMachine.snapshot.test.ts --runInBand` 通过（4/4，快照 1 条）。
- `npm run build` 通过。

---

### 下一任务（进行中）
5. 恢复链路产品化（自动回到离线前具体任务上下文）

---

### 任务 5：恢复链路产品化（自动回到离线前具体任务上下文）✅
**目标**
- 从“recovering 阶段可手动返回”升级为“自动回到离线前具体任务页面”。
- 保留用户可控的兜底交互（取消自动返回 / 手动立即返回）。
- 记录恢复链路关键行为，便于后续观测分析。

**改动**
- `components/offline/OfflineGameProvider.tsx`
  - 新增“离线前上下文路由”捕获能力：
    - 进入 `offline` 时，记录当前完整任务路由（`pathname + search`），排除离线演示页（`/offline-dino*`、`/offline-demo`）。
  - 新增自动恢复返回流程：
    - 进入 `recovering` 时，如检测到可恢复目标且当前页不同，默认在短延迟后自动 `router.push` 返回原任务上下文。
    - 增加单次恢复周期去重，避免重复触发自动跳转。
  - 新增弹窗兜底交互升级：
    - 弹窗文案显示“即将自动返回”状态。
    - 支持“取消自动返回”和“立即返回原网站”两种用户操作。
  - 新增清理逻辑：
    - 回到 `offline` 时重置自动恢复标志并清除定时器，防止状态抖动下的误跳转。
    - 组件卸载时统一清理定时器。
  - 埋点增强：
    - 自动恢复调度时记录 `offline_resume_business_funnel`（含 `source/target/from`）。
    - 实际跳转时记录 `offline_resume_primary_task`（区分 `auto/manual` 触发）。

**验证**
- `npm run build` 通过（58/58 页面静态生成成功）。

---

### 下一任务（进行中）
6. 观测与告警（离线触发率、游戏打开率、恢复耗时、恢复后回流率、脚本失败率、SW 命中率与阈值告警）

---

### 任务 6：观测与告警完善（指标落地 + 阈值告警）✅
**目标**
- 补齐核心指标：离线触发率、游戏打开率、恢复耗时、恢复后回流率、脚本加载失败率、SW 缓存命中率。
- 建立统一阈值告警规则，并在周报看板直接展示告警状态。

**改动**
- `lib/offline-telemetry.ts`
  - 扩展事件枚举：新增 `offline_game_script_load`、`offline_sw_metrics`。
  - `route` 上报改为 `pathname + search`，提升上下文可观测性。
- `components/offline/OfflineGame.tsx`
  - 新增脚本加载结果埋点 `offline_game_script_load`：
    - 初次加载成功/失败
    - fallback 兜底成功
    - 手动重载成功/失败
  - 埋点字段包含 `requestedScript`、`effectiveScript`、`fallbackUsed`、`source`、`error`。
- `public/offline-game.js`
  - 继续上报 `offline_sw_metrics`。
  - 告警增强：新增低命中率告警 `sw_cache_hit_rate_low`（请求样本 >= 20 且命中率 < 60%）。
  - 保留高失败率告警 `sw_fetch_failure_rate_high`（失败率 > 2%）。
- `lib/server/offline-events-store.ts`
  - 新增统一观测聚合器 `computeObservabilityMetrics`，计算：
    - `offlineTriggerRate`
    - `gameOpenRate`
    - `recoveryReturnRate`
    - `recoveryDurationMs`
    - `scriptLoadFailureRate`
    - `swCacheHitRate`
    - `swFetchFailureRate`
  - 新增阈值告警规则（warn/critical）：
    - `script_load_failure_rate_high`（>2%，样本>=20）
    - `sw_fetch_failure_rate_high`（>2%，样本>=20）
    - `sw_cache_hit_rate_low`（<60%，样本>=20）
    - `recovery_return_rate_low`（<50%，样本>=20）
    - `recovery_duration_high`（>90s，样本>=20）
  - 内存与 DB 两条汇总路径都接入同一套指标与告警输出，返回 `metrics/alerts/alertCounts`。
  - 将触发的告警自动拼接到 `dashboard.recommendations`。
- `app/offline-report/page.tsx`
  - 看板 KPI 扩展展示 6 个新增观测指标。
  - 新增“告警状态”卡片，展示告警等级、编码、说明与当前值/阈值。

**验证**
- `npm run build` 通过（58/58 页面静态生成成功）。

---

### 下一任务（待确认）
7. 指标看板细化（按版本/路由维度下钻 + 趋势图）

---

### 任务 7：指标看板下钻（脚本版本 + 路由）✅
**目标**
- 为观测指标增加“按脚本版本 / 按路由”的下钻维度，支持快速定位告警来源。
- 让管理看板可以直接看到“哪个版本或哪个页面路径”在拖累指标。

**改动**
- `app/api/offline-events/route.ts`
  - 事件入库前将 `activeGameVersion`、`activeGameScript` 注入 `payload._ctx`，确保后端聚合可获取版本上下文。
- `lib/server/offline-events-store.ts`
  - 新增下钻聚合结构：
    - `buildDimensionDrilldowns(records)`
    - 维度输出 `byScriptVersion`、`byRoute`（各取 Top10）。
  - 下钻行包含：
    - 事件数、会话数、SW 告警数
    - 脚本加载失败率
    - SW 缓存命中率 / 回源失败率
    - 恢复后回流率
  - 在内存汇总与 DB 汇总两条路径都返回：
    - 顶层 `drilldowns`
    - `dashboard.drilldowns`
- `app/offline-report/page.tsx`
  - 新增两个看板卡片：
    - 「下钻：脚本版本维度」
    - 「下钻：路由维度」
  - 支持按维度查看告警计数与关键质量指标，辅助快速定位问题根因。

**验证**
- `npm run build` 通过（58/58 页面静态生成成功）。

---

### 下一任务（待确认）
8. 指标趋势图（按天展示版本/路由质量变化）

---

### 任务 8：指标趋势图（版本/路由日趋势）✅
**目标**
- 在“版本/路由下钻”基础上增加时间维度，识别指标是瞬时异常还是持续劣化。
- 支持按天观察脚本失败率、SW 命中/失败率、恢复回流率变化。

**改动**
- `lib/server/offline-events-store.ts`
  - 新增趋势聚合结构：
    - `buildDimensionTrends(records)`
    - 输出 `trends.byScriptVersion`、`trends.byRoute`（按事件量 Top5）。
  - 每个趋势点（日粒度）包含：
    - `events`
    - `scriptLoadFailureRate`
    - `swCacheHitRate`
    - `swFetchFailureRate`
    - `recoveryReturnRate`
  - 在内存汇总与 DB 汇总路径同步返回：
    - 顶层 `trends`
    - `dashboard.trends`
- `app/offline-report/page.tsx`
  - 新增两块趋势看板：
    - 「趋势：脚本版本（日维度）」
    - 「趋势：路由（日维度）」
  - 展示最新日指标、与首日差值（Δ），以及覆盖天数，便于快速判断趋势方向。

**验证**
- `npm run build` 通过（58/58 页面静态生成成功）。

---

### 下一任务（待确认）
9. 告警联动自动动作（建议回滚版本 / 标注高风险路由）

---

### 任务 9：告警联动自动动作（优先级建议）✅
**目标**
- 将“看见告警”升级为“给出可执行动作”，减少人工分析成本。
- 根据版本/路由下钻与趋势，自动给出回滚与排查优先级。

**改动**
- `lib/server/offline-events-store.ts`
  - 新增动作模型 `ActionItem`（`priority/type/title/reason/recommendation/target`）。
  - 新增 `buildActionItems(alerts, drilldowns, trends)` 自动动作引擎：
    - `rollback_version`：当版本脚本失败率超阈值时给出回滚建议（优先推荐更稳定版本）。
    - `route_investigation`：定位高风险路由并建议优先排查。
    - `cache_policy_tuning`：针对低命中率路由建议缓存策略调整。
    - `recovery_experience_tuning`：当恢复回流趋势恶化时建议优化恢复体验。
  - 在内存与 DB 汇总路径都输出：
    - 顶层 `actionItems`
    - `dashboard.actionItems`
- `app/offline-report/page.tsx`
  - 新增「自动动作建议」看板：
    - 展示 `P0/P1/P2` 优先级
    - 展示目标对象、触发原因与建议动作
    - 支持与现有告警卡片联动查看

**验证**
- `npm run build` 通过（58/58 页面静态生成成功）。

---

### 下一任务（待确认）
10. 自动动作闭环（将建议动作同步到配置页快捷操作）

---

### 任务 10：自动动作闭环（配置页快捷联动）✅
**目标**
- 将“自动动作建议”从只读建议升级为可直接执行，减少手工切换成本。
- 实现从看板到管理配置页的联动闭环（含一键切换稳定版本）。

**改动**
- `lib/server/offline-events-store.ts`
  - 扩展 `ActionItem` 字段：
    - `adminPath`（管理页跳转）
    - `executeApi`（可执行 API 动作）
  - `rollback_version` 动作新增可执行策略：
    - 直接调用 `PUT /api/offline-experiments/config`
    - `body: { activeGameVersion: <推荐稳定版本> }`
    - 同时提供管理页链接 `/admin/offline-experiments?suggestedVersion=...`
  - 其它动作补充 `adminPath` 跳转（`/traces`、`/admin/offline-experiments`）。
- `app/offline-report/page.tsx`
  - 自动动作建议卡片新增按钮：
    - `一键执行`（调用 `executeApi`，成功后自动刷新报表）
    - `前往管理页`（按动作跳转到对应页面）
  - 新增执行态与结果提示（toast）。
- `app/(main)/admin/offline-experiments/page.tsx`
  - 支持读取 `suggestedVersion` 查询参数并预填版本。
  - 增加存在性校验（建议版本不存在时给出提示，避免脏参数）。

**验证**
- `npm run build` 通过（58/58 页面静态生成成功）。

---

### 下一任务（待确认）
11. 动作执行审计增强（记录“自动动作来源 + 执行人 + 执行结果”）

---

### 任务 11：动作执行审计增强（来源 + 执行人 + 结果）✅
**目标**
- 让“自动动作执行”具备完整审计追踪：来源、执行人、执行结果、上下文。
- 打通从离线看板一键执行到审计查询页回溯的闭环。

**改动**
- `lib/server/offline-db.ts`
  - 审计表 `offline_admin_audit_logs` 扩展字段：
    - `action_source`（动作来源，默认 `manual_admin_ui`）
    - `execution_result`（`success/failed`）
    - `action_meta`（动作上下文 JSON）
  - 增加 `ALTER TABLE ... ADD COLUMN IF NOT EXISTS` 兼容历史库。
  - 新增索引：`idx_offline_admin_audit_logs_source_created_at`。
- `lib/server/offline-audit-log.ts`
  - 审计写入模型扩展：
    - `actionSource`
    - `executionResult`
    - `actionMeta`
  - 审计查询模型同步返回上述字段（数据库与内存路径都支持）。
- `app/api/offline-experiments/config/route.ts`
  - 支持解析请求体 `auditContext`。
  - 成功/失败都写审计日志，写入来源与执行结果。
- `app/api/offline-sw/config/route.ts`
  - 同步支持 `auditContext`。
  - `PUT/POST(rollback)` 成功/失败都写审计日志。
- `app/offline-report/page.tsx`
  - 一键执行动作时自动注入 `auditContext`（来源 `offline_report_action`、动作类型/标题/目标/优先级）。
- `app/(main)/admin/offline-audit/page.tsx`
  - 审计列表新增展示列：来源、结果。
  - 详情弹窗新增“动作上下文”区块（完整 JSON）。

**验证**
- `npm run build` 通过（58/58 页面静态生成成功）。

---

### 下一任务（待确认）
12. 审计筛选增强（按来源/结果/动作类型过滤）

---

### 任务 12：审计筛选增强（来源/结果/动作类型）✅
**目标**
- 让审计查询从“按目标/动作”扩展到“按来源/结果/动作类型”，提升排障与回溯效率。
- 支持快速筛出自动动作触发、失败执行、特定动作类型（如 `rollback_version`）记录。

**改动**
- `lib/server/offline-audit-log.ts`
  - `listOfflineAuditLogs` 新增过滤参数：
    - `actionSource`
    - `executionResult`
    - `actionType`
  - 内存与数据库两条查询路径都支持以上过滤。
  - 查询结果新增 `actionType` 字段（从 `action_meta.actionType` 派生）。
- `app/api/offline-admin/audit/route.ts`
  - API 新增接收并透传查询参数：
    - `actionSource`
    - `executionResult`
    - `actionType`
- `app/(main)/admin/offline-audit/page.tsx`
  - 新增筛选控件：
    - 来源（`manual_admin_ui` / `offline_report_action`）
    - 结果（`success` / `failed`）
    - 动作类型（`rollback_version` 等）
  - 审计表新增“动作类型”列。
  - 详情弹窗新增“动作类型”展示。
  - 请求参数与分页联动：切换筛选后自动回到第一页并刷新。

**验证**
- `npm run build` 通过（58/58 页面静态生成成功）。

---

### 下一任务（待确认）
13. 审计导出能力（按当前筛选导出 JSON/CSV）

---

### 任务 13：审计导出能力（按筛选导出 JSON/CSV）✅
**目标**
- 支持基于“当前筛选条件”一键导出审计记录，便于外部归档与分析。
- 同时提供 JSON 与 CSV 两种格式，覆盖技术分析与表格审阅场景。

**改动**
- `lib/server/offline-audit-log.ts`
  - 新增 `OfflineAuditLogFilterOptions`。
  - 新增导出查询方法 `listOfflineAuditLogsForExport(...)`：
    - 复用筛选条件（目标/动作/来源/结果/动作类型）。
    - 支持内存与数据库两条路径。
    - 增加导出上限控制（默认 1000，最大 5000）。
- `app/api/offline-admin/audit/route.ts`
  - 新增导出模式参数：
    - `mode=export`
    - `format=json|csv`
    - `limit`
  - `format=csv` 时返回附件下载流（`Content-Disposition`）。
  - `format=json` 时返回筛选后的完整导出数据。
- `app/(main)/admin/offline-audit/page.tsx`
  - 新增导出按钮：
    - `导出 JSON`
    - `导出 CSV`
  - 导出会自动带上当前筛选条件，并触发本地文件下载。
  - 增加导出中状态与成功/失败提示。

**验证**
- `npm run build` 通过（58/58 页面静态生成成功）。

---

### 下一任务（待确认）
14. 审计批量归档策略（超大导出分片 + 定时归档）

---

### 任务 14：审计批量归档策略（分片导出 + 定时归档）✅
**目标**
- 支持超大审计数据导出时分片下载，避免单次响应过大。
- 建立审计热数据与归档数据分层，降低主表膨胀风险。

**改动**
- `lib/server/offline-db.ts`
  - 新增审计归档表 `offline_admin_audit_logs_archive`（含 `archived_at`）。
  - 新增定时归档逻辑（随清理周期触发）：
    - 将超过热保留期的审计记录批量迁移到归档表。
    - 批次大小：`AUDIT_ARCHIVE_BATCH_SIZE = 2000`。
    - 归档表再按长期保留期清理。
  - 新增环境变量支持：
    - `OFFLINE_AUDIT_HOT_RETENTION_DAYS`（默认 30）
    - `OFFLINE_AUDIT_ARCHIVE_RETENTION_DAYS`（默认 365）
- `lib/server/offline-audit-log.ts`
  - 导出查询升级：
    - 支持 `offset/limit` 分片导出。
    - 返回 `hasMore/nextOffset` 游标信息。
    - 支持 `includeArchived`（导出时可选包含归档表数据）。
- `app/api/offline-admin/audit/route.ts`
  - 导出接口新增参数：
    - `offset`
    - `includeArchived`
  - JSON 导出返回分片元信息（`hasMore/nextOffset`）。
  - CSV 导出通过响应头返回游标信息（`X-Offline-Audit-Has-More`、`X-Offline-Audit-Next-Offset`）。
- `app/(main)/admin/offline-audit/page.tsx`
  - 新增分片导出按钮：
    - `分片导出 JSON`
    - `分片导出 CSV`
  - 分片导出会按 `offset/limit` 自动循环请求并生成多文件下载。
  - 新增“导出含归档 / 导出仅热数据”开关。

**验证**
- `npm run build` 通过（58/58 页面静态生成成功）。

---

### 下一任务（待确认）
15. 审计导出任务化（后台异步导出 + 下载中心）

---

### 任务 15：审计导出任务化（后台异步导出 + 下载中心）✅
**目标**
- 将大规模审计导出从“即时请求”升级为“任务化处理”，避免长请求阻塞。
- 提供下载中心查看任务状态与分片文件，支持按需下载。

**改动**
- `lib/server/offline-audit-export-jobs.ts`（新增）
  - 新增导出任务领域模型：
    - 任务状态（`pending/processing/completed/failed`）
    - 分片项（`partNo/offset/limit/filename/downloadQuery`）
  - 提供核心能力：
    - `createOfflineAuditExportJob`
    - `listOfflineAuditExportJobs`
  - 任务创建后异步处理：
    - 基于筛选条件计算总量与分片清单
    - 生成每个分片的下载查询参数
  - 支持内存存储与数据库存储双路径。
- `lib/server/offline-db.ts`
  - 新增导出任务持久化表：
    - `offline_audit_export_jobs`
    - `offline_audit_export_job_items`
  - 新增索引与分片项唯一约束。
- `app/api/offline-admin/audit/export-jobs/route.ts`（新增）
  - `POST`：创建导出任务（管理员鉴权）。
  - `GET`：查询最近导出任务列表。
- `app/(main)/admin/offline-audit/page.tsx`
  - 新增“导出下载中心”卡片：
    - 可创建 JSON/CSV 导出任务（继承当前筛选条件）
    - 展示任务状态、总行数、分片数量、时间、错误信息
    - 任务完成后可逐分片下载
  - 保留即时导出与分片导出按钮，形成“即时 + 任务化”双模式。

**验证**
- `npm run build` 通过（59/59 页面静态生成成功；新增导出任务 API 路由编译通过）。

---

### 下一任务（待确认）
16. 下载中心体验优化（任务搜索/取消/批量下载）

---

### 任务 16：下载中心体验优化（搜索/取消/批量下载）✅
**目标**
- 提升下载中心可操作性：快速定位任务、取消无效任务、批量下载已完成分片。
- 保持导出任务链路可控，避免后台任务堆积。

**改动**
- `lib/server/offline-audit-export-jobs.ts`
  - 导出任务状态新增 `cancelled`。
  - 新增任务筛选查询：
    - `listOfflineAuditExportJobsFiltered({ q, status, limit })`
  - 新增取消任务能力：
    - `cancelOfflineAuditExportJob(jobId)`
  - 任务处理过程增加取消检查，避免已取消任务继续生成分片。
- `app/api/offline-admin/audit/export-jobs/route.ts`
  - `GET` 新增查询参数：
    - `q`（关键字搜索）
    - `status`（任务状态筛选）
  - 新增 `DELETE`：
    - `?jobId=...` 取消导出任务（管理员鉴权）。
- `app/(main)/admin/offline-audit/page.tsx`
  - 下载中心新增搜索框（任务ID/执行人/IP）与状态筛选。
  - 新增任务操作：
    - `取消任务`（pending/processing 可用）
    - `批量下载全部分片`（completed 可用）
  - 增加批量下载执行态与取消执行态反馈。

**验证**
- `npm run build` 通过（59/59 页面静态生成成功）。

---

### 下一任务（待确认）
17. 下载中心稳定性优化（批量下载重试 + 限流保护）

---

### 任务 17：下载中心稳定性优化（重试 + 限流）✅
**目标**
- 降低批量下载过程中的偶发失败率（网络抖动/限流）。
- 防止导出接口被短时间高频调用压垮（限流保护）。

**改动**
- `lib/server/api-rate-limit.ts`（新增）
  - 新增轻量内存限流器 `checkRateLimit(key, limit, windowMs)`。
  - 返回 `retryAfterMs`、剩余配额信息。
- `app/api/offline-admin/audit/route.ts`
  - 对 `mode=export` 导出请求增加限流保护（按来源 IP）。
  - 超限返回 `429` 与 `Retry-After`。
- `app/api/offline-admin/audit/export-jobs/route.ts`
  - `GET/POST/DELETE` 全部增加限流保护（按来源 IP，不同动作不同配额）。
  - 超限返回 `429` 与 `Retry-After`。
- `app/(main)/admin/offline-audit/page.tsx`
  - 批量下载改为“请求下载 + 自动重试”：
    - 单分片失败支持最多 3 次重试
    - 遇到 `429/5xx` 按指数退避并遵循 `Retry-After`
  - 批量下载增加节流间隔（220ms），降低瞬时并发压力。
  - 单分片下载也复用同一重试逻辑，增加下载状态反馈。

**验证**
- `npm run build` 通过（59/59 页面静态生成成功）。

---

### 下一任务（待确认）
18. 下载中心可观测增强（任务耗时/失败原因统计）

---

### 任务 18：下载中心可观测增强（耗时/失败原因/重试次数）✅
**目标**
- 将下载中心从“可用”升级为“可观测”：看得到任务耗时、失败原因、重试次数。
- 同时覆盖后端导出任务处理阶段与前端下载执行阶段。

**改动**
- `lib/server/offline-db.ts`
  - 导出任务表新增可观测字段：
    - `retry_count`
    - `processing_started_at`
    - `processing_duration_ms`
  - 使用 `ALTER TABLE ... ADD COLUMN IF NOT EXISTS` 兼容历史库。
- `lib/server/offline-audit-export-jobs.ts`
  - 导出任务模型扩展字段：
    - `retryCount`
    - `processingStartedAt`
    - `processingDurationMs`
  - 导出任务处理逻辑新增内建重试（最多 3 次，指数退避）。
  - 每次重试更新任务状态与错误信息（含尝试次数），最终保留耗时和失败原因。
  - 任务查询/取消路径同步返回上述指标字段。
- `app/(main)/admin/offline-audit/page.tsx`
  - 下载中心新增可视化统计卡片：
    - 任务平均耗时
    - 后台任务重试次数
    - 后台失败任务数
    - 前端下载重试次数
  - 每个任务卡片新增：
    - 任务处理耗时
    - 后台重试次数
    - 前端下载统计（尝试/重试/成功/失败/最近失败原因）
  - 前端下载层新增指标采集：
    - 单分片/批量下载记录尝试次数、重试次数、耗时、失败原因。

**验证**
- `npm run build` 通过（59/59 页面静态生成成功）。

---

### 下一任务（待确认）
19. 下载中心告警规则（失败率/超时阈值告警）

---

### 任务 19：下载中心告警规则（失败率/超时阈值）✅
**目标**
- 为下载中心建立明确阈值告警规则，及时识别失败率上升与处理超时风险。
- 将告警与任务明细联动展示，便于快速定位根因。

**改动**
- `app/(main)/admin/offline-audit/page.tsx`
  - 新增告警规则常量 `DOWNLOAD_ALERT_THRESHOLDS`，覆盖：
    - 后台任务失败率阈值
    - 后台任务平均耗时阈值
    - 后台单任务平均重试阈值
    - 前端下载失败率阈值
    - 前端下载重试率阈值
  - 新增 `downloadCenterAlerts` 规则引擎，按规则产出：
    - 告警级别（`warn/critical`）
    - 告警编码
    - 当前值/阈值
    - 建议动作
  - 下载中心新增“告警规则状态”卡片，集中展示命中告警。
  - 对超时任务（处理耗时超阈值）增加行内高亮提示。
  - 统计口径增强：
    - 新增后台失败率、后台每任务平均重试
    - 新增前端下载失败率、前端下载重试率

**验证**
- `npm run build` 通过（59/59 页面静态生成成功）。

---

### 下一任务（待确认）
20. 下载中心告警通知联动（告警触发时推送与审计记录）

---

### 任务 20：下载中心告警通知联动（通知 + 审计）✅
**目标**
- 当下载中心阈值告警触发时，自动推送通知并沉淀审计记录，形成可追溯闭环。
- 确保后续可按“告警动作”在审计页快速检索。

**改动**
- `app/api/offline-admin/audit/alerts/route.ts`（新增）
  - 新增告警审计写入接口（管理员鉴权）。
  - 写入审计目标：
    - `action = alert`
    - `target = offline_download_center_alert`
    - `actionSource = download_center_alert_engine`
    - `actionType = download_center_alert`
  - 记录告警签名、告警明细、统计快照、执行结果（成功/失败）。
- `app/(main)/admin/offline-audit/page.tsx`
  - 新增告警联动逻辑：
    - 告警签名去重（同一签名仅上报一次，防止重复刷日志）
    - 触发告警时弹出 toast 通知（critical/warn 区分）
    - 异步调用 `/api/offline-admin/audit/alerts` 写审计记录
  - 审计筛选项补充：
    - 目标增加 `offline_download_center_alert`
    - 动作增加 `alert`
    - 动作类型增加 `download_center_alert`

**验证**
- `npm run build` 通过（60/60 页面静态生成成功，新增告警审计 API 路由编译通过）。

---

### 下一任务（待确认）
21. 告警抑制与冷却策略（避免短时重复告警风暴）

---

### 任务 21：告警抑制与冷却策略（cooldown + 去抖窗口 + 聚合通知）✅
**目标**
- 避免短时间内重复阈值波动导致 toast 与审计日志被频繁刷屏。
- 将多次告警合并成窗口级通知与审计批次，降低噪音同时保留可追溯性。

**改动**
- `app/(main)/admin/offline-audit/page.tsx`
  - 新增告警噪音控制配置 `DOWNLOAD_ALERT_NOISE_CONTROL`：
    - `debounceMs`（去抖窗口）
    - `cooldownMs`（按告警码冷却）
    - `maxAlertsPerBatch`（单次聚合上报上限）
  - 新增聚合状态与冷却状态管理（`useRef`）：
    - 待上报告警批次缓存
    - 去抖定时器
    - 告警码级冷却时间戳
  - 告警联动从“即触发即上报”升级为：
    1. 进入去抖窗口收集多批告警
    2. 按 `code` 聚合同类告警（保留更高等级，累计命中次数）
    3. 应用冷却策略抑制重复告警
    4. 输出一次聚合 toast（展示观测总量/通知量/抑制量）
    5. 上报聚合审计（含 `hitCount` 与聚合统计）
  - 增加组件卸载时定时器清理，防止悬挂上报。
- `app/api/offline-admin/audit/alerts/route.ts`
  - 告警审计写入新增 `aggregation` 字段持久化（去抖窗口、冷却、抑制数量、批次数等），便于回看告警抑制效果。

**验证**
- `npm run build` 通过（60/60 页面静态生成成功）。

---

### 下一任务（待确认）
22. 告警路由分级通知（站内 + Webhook/企业IM 可选）

---

### 任务 22：告警分级通知通道（站内 + Webhook/企业IM）✅
**目标**
- 将下载中心告警从“站内 toast + 审计”升级为“站内 + 可选外发”双通道。
- 支持按严重级别分流（`warn/critical`），并保留完整投递审计。

**改动**
- `lib/server/offline-alert-notifier.ts`（新增）
  - 新增后端外发通知器，支持：
    - 通道：`webhook`
    - Provider：`generic / wecom / feishu / dingtalk`
    - 分级：按 `OFFLINE_ALERT_WEBHOOK_MIN_LEVEL` 控制仅外发高于阈值的告警
    - 多目标：`OFFLINE_ALERT_WEBHOOK_URLS`（逗号分隔）或单目标 `OFFLINE_ALERT_WEBHOOK_URL`
    - 超时控制：`OFFLINE_ALERT_WEBHOOK_TIMEOUT_MS`
  - 返回标准投递结果：是否尝试、是否成功、状态码列表、跳过原因、错误信息。
- `app/api/offline-admin/audit/alerts/route.ts`
  - 告警写审计前增加外发步骤。
  - 审计 `actionMeta`/`afterData` 增加通道结果：
    - `channels.inApp`
    - `channels.external`
  - 当外发已尝试但失败时，审计结果标记为 `failed`，便于筛选补偿。
- `app/(main)/admin/offline-audit/page.tsx`
  - 上报告警时附带 `inAppNotification` 上下文（站内通道确认信息）。
  - 接收 API 返回的外发结果：
    - 外发成功：提示“外发通知成功”
    - 外发失败：提示“站内已送达，外发失败”
  - 保持告警抑制/聚合链路不变，外发能力作为聚合批次的附加动作。
- `README.md`
  - 补充任务 22 新增环境变量说明（外发通道、Provider、分级阈值、超时等）。

**验证**
- `npm run build` 通过（60/60 页面静态生成成功）。

---

### 下一任务（待确认）
23. 通知投递可靠性增强（失败重试队列 + 指数退避 + 死信审计）

---

### 任务 23：外发通知可靠性增强（失败重试队列 + 指数退避 + 死信审计）✅
**目标**
- 提升外发通知在不稳定网络下的投递成功率，避免瞬时失败直接丢失告警。
- 为重试失败场景提供死信审计，确保失败链路可定位、可回溯、可补偿。

**改动**
- `lib/server/offline-alert-notifier.ts`
  - 通知投递从“单次直发”升级为“内存重试队列 + Worker 串行消费”。
  - 新增指数退避重试策略：
    - `OFFLINE_ALERT_RETRY_MAX_ATTEMPTS`（含首次）
    - `OFFLINE_ALERT_RETRY_BASE_DELAY_MS`
    - `OFFLINE_ALERT_RETRY_MAX_DELAY_MS`
  - 返回增强投递结果：
    - 实际尝试次数、重试次数、退避序列、队列等待时长、处理耗时
    - `deadLettered` / `deadLetterReason` / `queueJobId`
  - 重试耗尽后标记死信（`deadLettered: true`）。
- `app/api/offline-admin/audit/alerts/route.ts`
  - 继续保留主告警审计记录，并写入重试与队列元数据。
  - 新增死信审计：当 `deadLettered=true` 时追加一条 `dead_letter` 动作审计，`actionType=download_center_dead_letter`。
  - 便于在审计页按动作/动作类型快速筛出需补偿告警。
- `app/(main)/admin/offline-audit/page.tsx`
  - 审计筛选项新增：
    - 动作：`dead_letter`
    - 动作类型：`download_center_dead_letter`
- `README.md`
  - 补充任务 23 新增环境变量（重试次数、退避基准、退避上限）。

**验证**
- `npm run build` 通过（60/60 页面静态生成成功）。

---

### 下一任务（待确认）
24. 通知队列持久化（DB队列表 + 进程重启续投 + 死信重放）

---

### 任务 24：通知队列持久化（DB队列表 + 进程重启续投）✅
**目标**
- 解决进程重启导致内存队列丢失的问题，让未完成通知任务可恢复继续投递。
- 为通知链路提供可观测的任务状态字段（尝试次数、重试轨迹、耗时）。

**改动**
- `lib/server/offline-db.ts`
  - 新增通知队列表 `offline_alert_delivery_jobs`（自动建表）：
    - `status / attempt_count / max_attempts`
    - `status_codes / backoff_delays_ms`
    - `queue_wait_ms / processing_duration_ms`
    - `last_error / dead_letter_reason`
    - `replayed_by_job_id / replayed_at`
    - `delivered_at / dead_lettered_at`
  - 增加索引，支持按状态与签名回查。
- `lib/server/offline-alert-notifier.ts`
  - 通知器升级为“内存队列 + DB 持久化状态”双层模型。
  - 任务创建、每次重试、最终结果都会更新 DB。
  - 新增进程启动恢复逻辑 `ensureQueueRecovered()`：
    - 自动拉取 `pending/processing/retrying` 任务回填内存队列并续投。

**验证**
- `npm run build` 通过（60/60 页面静态生成成功）。

---

### 任务 25：死信重放（API + 审计页一键补偿）✅
**目标**
- 为重试耗尽的死信告警提供可操作补偿入口，避免人工离线处理。
- 重放动作全程可审计。

**改动**
- `lib/server/offline-alert-notifier.ts`
  - 新增 `replayDeadLetterAlertDelivery(jobId)`：
    - 校验死信任务有效性
    - 创建新的重放任务并入队
    - 回写原任务 `replayed_by_job_id / replayed_at`
- `app/api/offline-admin/audit/alerts/replay/route.ts`（新增）
  - 提供管理员重放接口。
  - 成功/失败均写审计日志：
    - `action = replay_dead_letter`
    - `actionType = download_center_dead_letter_replay`
- `app/api/offline-admin/audit/alerts/route.ts`
  - 任务 23 的死信审计继续保留：
    - `action = dead_letter`
    - `actionType = download_center_dead_letter`
- `app/(main)/admin/offline-audit/page.tsx`
  - 审计筛选新增 `replay_dead_letter` 与 `download_center_dead_letter_replay`。
  - 详情弹窗新增“重放该死信通知”按钮（死信记录可一键触发重放）。
- `README.md`
  - 补充重试退避参数说明（最大尝试、退避基准、退避上限）。

**验证**
- `npm run build` 通过（60/60 页面静态生成成功）。

---

### 当前状态
- 当前规划内剩余任务已清零（告警链路已具备：聚合抑制、分级外发、重试、死信、重放、审计闭环）。
- 后续如需继续，可转入“通知 SLA 与运维面板”阶段（如投递成功率看板、重放成功率趋势、自动补偿策略）。
