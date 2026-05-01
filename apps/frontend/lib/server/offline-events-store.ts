type EventPayload = Record<string, unknown> | undefined;
import { offlineDbEnabled, queryDb } from './offline-db';

export interface OfflineEventRecord {
  event: string;
  payload?: EventPayload;
  experiment?: {
    triggerVariant?: string;
    contentVariant?: string;
  };
  sessionId?: string;
  route?: string;
  timestamp: number;
  userAgent?: string;
}

const MAX_EVENTS = 5000;
const memoryStore: OfflineEventRecord[] = [];

function toNumber(value: unknown): number {
  return typeof value === 'number' && Number.isFinite(value) ? value : 0;
}

async function persistEvent(record: OfflineEventRecord) {
  if (!offlineDbEnabled()) return;
  await queryDb(
    `
      INSERT INTO offline_events (event, payload, experiment, session_id, route, event_at, user_agent)
      VALUES ($1, $2::jsonb, $3::jsonb, $4, $5, to_timestamp($6 / 1000.0), $7)
    `,
    [
      record.event,
      JSON.stringify(record.payload || {}),
      JSON.stringify(record.experiment || {}),
      record.sessionId || null,
      record.route || null,
      record.timestamp,
      record.userAgent || null,
    ],
  );
}

async function loadEventsFromDb(days: number): Promise<OfflineEventRecord[]> {
  if (!offlineDbEnabled()) return [];
  const rows = await queryDb<{
    event: string;
    payload: Record<string, unknown> | null;
    experiment: Record<string, unknown> | null;
    session_id: string | null;
    route: string | null;
    event_at_ms: number;
    user_agent: string | null;
  }>(
    `
      SELECT
        event,
        payload,
        experiment,
        session_id,
        route,
        EXTRACT(EPOCH FROM event_at) * 1000 AS event_at_ms,
        user_agent
      FROM offline_events
      WHERE event_at >= NOW() - ($1 || ' days')::INTERVAL
      ORDER BY event_at DESC
    `,
    [days.toString()],
  );

  return rows.map((item) => ({
    event: item.event,
    payload: item.payload || undefined,
    experiment: item.experiment as OfflineEventRecord['experiment'],
    sessionId: item.session_id || undefined,
    route: item.route || undefined,
    timestamp: Math.round(item.event_at_ms),
    userAgent: item.user_agent || undefined,
  }));
}

export async function addOfflineEvent(record: OfflineEventRecord): Promise<void> {
  addOfflineEventToMemory(record);
  try {
    await persistEvent(record);
  } catch (error) {
    console.warn('[offline-events] persist failed, fallback to memory store only', error);
  }
}

function addOfflineEventToMemory(record: OfflineEventRecord): void {
  memoryStore.push(record);
  if (memoryStore.length > MAX_EVENTS) {
    memoryStore.splice(0, memoryStore.length - MAX_EVENTS);
  }
}

export async function listOfflineEvents(days = 7) {
  if (offlineDbEnabled()) {
    try {
      return await loadEventsFromDb(days);
    } catch (error) {
      console.warn('[offline-events] list from db failed, fallback to memory', error);
    }
  }
  const sinceTs = Date.now() - days * 24 * 60 * 60 * 1000;
  return memoryStore.filter((item) => item.timestamp >= sinceTs);
}

function safeDivide(numerator: number, denominator: number): number {
  return denominator > 0 ? numerator / denominator : 0;
}

function round4(value: number): number {
  return Math.round(value * 10000) / 10000;
}

function getVariantKey(record: OfflineEventRecord, dimension: 'trigger' | 'content'): string {
  if (dimension === 'trigger') {
    return record.experiment?.triggerVariant || 'unknown';
  }
  return record.experiment?.contentVariant || 'unknown';
}

interface VariantAccumulator {
  shown: number;
  recovered: number;
  resumed: number;
}

interface ObservabilityMetrics {
  offlineTriggerRate: number;
  gameOpenRate: number;
  recoveryReturnRate: number;
  recoveryDurationMs: number;
  scriptLoadFailureRate: number;
  swCacheHitRate: number;
  swFetchFailureRate: number;
}

interface ObservabilityAlert {
  level: 'warn' | 'critical';
  code: string;
  message: string;
  currentValue: number;
  threshold: number;
}

interface DimensionDrilldownRow {
  key: string;
  events: number;
  sessions: number;
  swAlertCount: number;
  scriptLoadFailureRate: number;
  swCacheHitRate: number;
  swFetchFailureRate: number;
  recoveryReturnRate: number;
}

interface ObservabilityDrilldowns {
  byScriptVersion: DimensionDrilldownRow[];
  byRoute: DimensionDrilldownRow[];
}

interface DimensionTrendPoint {
  day: string;
  events: number;
  scriptLoadFailureRate: number;
  swCacheHitRate: number;
  swFetchFailureRate: number;
  recoveryReturnRate: number;
}

interface DimensionTrendRow {
  key: string;
  totalEvents: number;
  points: DimensionTrendPoint[];
}

interface ObservabilityTrends {
  byScriptVersion: DimensionTrendRow[];
  byRoute: DimensionTrendRow[];
}

interface ActionItem {
  priority: 'P0' | 'P1' | 'P2';
  type: 'rollback_version' | 'route_investigation' | 'cache_policy_tuning' | 'recovery_experience_tuning';
  title: string;
  reason: string;
  recommendation: string;
  target: string;
  adminPath?: string;
  executeApi?: {
    endpoint: string;
    method: 'PUT' | 'POST';
    body?: Record<string, unknown>;
  };
}

const ALERT_THRESHOLDS = {
  scriptLoadFailureRate: 0.02,
  swFetchFailureRate: 0.02,
  swCacheHitRateMin: 0.6,
  recoveryReturnRateMin: 0.5,
  recoveryDurationMsHigh: 90_000,
};

function normalizeRouteKey(route: string | undefined): string {
  if (!route) return 'unknown';
  return route.split('?')[0] || 'unknown';
}

function inferVersionFromScript(scriptPath: string | undefined): string {
  if (!scriptPath) return 'unknown';
  if (scriptPath.includes('dino-game-fixed.js')) return 'v2';
  if (scriptPath.includes('dino-game.js')) return 'v1';
  return 'unknown';
}

function resolveVersionKey(record: OfflineEventRecord): string {
  const ctx = record.payload?._ctx as Record<string, unknown> | undefined;
  const ctxVersion = typeof ctx?.activeGameVersion === 'string' ? ctx.activeGameVersion : '';
  if (ctxVersion) return ctxVersion;
  const effectiveScript =
    typeof record.payload?.effectiveScript === 'string' ? (record.payload.effectiveScript as string) : '';
  return inferVersionFromScript(effectiveScript);
}

function buildDimensionDrilldowns(records: OfflineEventRecord[]): ObservabilityDrilldowns {
  const versionBuckets = new Map<
    string,
    {
      events: number;
      sessions: Set<string>;
      swAlertCount: number;
      scriptLoadAttempts: number;
      scriptLoadFailures: number;
      swRequests: number;
      swCacheHits: number;
      swFetchFailures: number;
      recoveredCount: number;
      resumedCount: number;
    }
  >();
  const routeBuckets = new Map<
    string,
    {
      events: number;
      sessions: Set<string>;
      swAlertCount: number;
      scriptLoadAttempts: number;
      scriptLoadFailures: number;
      swRequests: number;
      swCacheHits: number;
      swFetchFailures: number;
      recoveredCount: number;
      resumedCount: number;
    }
  >();

  const ensureBucket = (
    map: Map<
      string,
      {
        events: number;
        sessions: Set<string>;
        swAlertCount: number;
        scriptLoadAttempts: number;
        scriptLoadFailures: number;
        swRequests: number;
        swCacheHits: number;
        swFetchFailures: number;
        recoveredCount: number;
        resumedCount: number;
      }
    >,
    key: string,
  ) => {
    const existing = map.get(key);
    if (existing) return existing;
    const created = {
      events: 0,
      sessions: new Set<string>(),
      swAlertCount: 0,
      scriptLoadAttempts: 0,
      scriptLoadFailures: 0,
      swRequests: 0,
      swCacheHits: 0,
      swFetchFailures: 0,
      recoveredCount: 0,
      resumedCount: 0,
    };
    map.set(key, created);
    return created;
  };

  for (const record of records) {
    const versionKey = resolveVersionKey(record);
    const routeKey = normalizeRouteKey(record.route);
    const versionBucket = ensureBucket(versionBuckets, versionKey);
    const routeBucket = ensureBucket(routeBuckets, routeKey);
    const targets = [versionBucket, routeBucket];

    for (const bucket of targets) {
      bucket.events += 1;
      if (record.sessionId) {
        bucket.sessions.add(record.sessionId);
      }
      if (record.event === 'offline_sw_alert') {
        bucket.swAlertCount += 1;
      }
      if (record.event === 'offline_game_script_load') {
        bucket.scriptLoadAttempts += 1;
        if (!Boolean(record.payload?.success)) {
          bucket.scriptLoadFailures += 1;
        }
      }
      if (record.event === 'offline_sw_metrics') {
        bucket.swRequests += toNumber(record.payload?.requests);
        bucket.swCacheHits += toNumber(record.payload?.cacheHits);
        bucket.swFetchFailures += toNumber(record.payload?.fetchFailures);
      }
      if (record.event === 'offline_recovered') {
        bucket.recoveredCount += 1;
      }
      if (record.event === 'offline_resume_primary_task') {
        bucket.resumedCount += 1;
      }
    }
  }

  const toRows = (
    map: Map<
      string,
      {
        events: number;
        sessions: Set<string>;
        swAlertCount: number;
        scriptLoadAttempts: number;
        scriptLoadFailures: number;
        swRequests: number;
        swCacheHits: number;
        swFetchFailures: number;
        recoveredCount: number;
        resumedCount: number;
      }
    >,
  ): DimensionDrilldownRow[] => {
    return [...map.entries()]
      .map(([key, item]) => ({
        key,
        events: item.events,
        sessions: item.sessions.size,
        swAlertCount: item.swAlertCount,
        scriptLoadFailureRate: round4(safeDivide(item.scriptLoadFailures, item.scriptLoadAttempts)),
        swCacheHitRate: round4(safeDivide(item.swCacheHits, item.swRequests)),
        swFetchFailureRate: round4(safeDivide(item.swFetchFailures, item.swRequests)),
        recoveryReturnRate: round4(safeDivide(item.resumedCount, item.recoveredCount)),
      }))
      .sort((a, b) => {
        if (b.swAlertCount !== a.swAlertCount) return b.swAlertCount - a.swAlertCount;
        return b.events - a.events;
      })
      .slice(0, 10);
  };

  return {
    byScriptVersion: toRows(versionBuckets),
    byRoute: toRows(routeBuckets),
  };
}

function buildDimensionTrends(records: OfflineEventRecord[]): ObservabilityTrends {
  const versionTrend = new Map<
    string,
    Map<
      string,
      {
        events: number;
        scriptLoadAttempts: number;
        scriptLoadFailures: number;
        swRequests: number;
        swCacheHits: number;
        swFetchFailures: number;
        recoveredCount: number;
        resumedCount: number;
      }
    >
  >();
  const routeTrend = new Map<
    string,
    Map<
      string,
      {
        events: number;
        scriptLoadAttempts: number;
        scriptLoadFailures: number;
        swRequests: number;
        swCacheHits: number;
        swFetchFailures: number;
        recoveredCount: number;
        resumedCount: number;
      }
    >
  >();

  const ensureTrendBucket = (
    map: Map<
      string,
      Map<
        string,
        {
          events: number;
          scriptLoadAttempts: number;
          scriptLoadFailures: number;
          swRequests: number;
          swCacheHits: number;
          swFetchFailures: number;
          recoveredCount: number;
          resumedCount: number;
        }
      >
    >,
    key: string,
    day: string,
  ) => {
    let dayMap = map.get(key);
    if (!dayMap) {
      dayMap = new Map();
      map.set(key, dayMap);
    }
    let bucket = dayMap.get(day);
    if (!bucket) {
      bucket = {
        events: 0,
        scriptLoadAttempts: 0,
        scriptLoadFailures: 0,
        swRequests: 0,
        swCacheHits: 0,
        swFetchFailures: 0,
        recoveredCount: 0,
        resumedCount: 0,
      };
      dayMap.set(day, bucket);
    }
    return bucket;
  };

  for (const record of records) {
    const day = new Date(record.timestamp).toISOString().slice(0, 10);
    const versionKey = resolveVersionKey(record);
    const routeKey = normalizeRouteKey(record.route);
    const buckets = [
      ensureTrendBucket(versionTrend, versionKey, day),
      ensureTrendBucket(routeTrend, routeKey, day),
    ];

    for (const bucket of buckets) {
      bucket.events += 1;
      if (record.event === 'offline_game_script_load') {
        bucket.scriptLoadAttempts += 1;
        if (!Boolean(record.payload?.success)) {
          bucket.scriptLoadFailures += 1;
        }
      }
      if (record.event === 'offline_sw_metrics') {
        bucket.swRequests += toNumber(record.payload?.requests);
        bucket.swCacheHits += toNumber(record.payload?.cacheHits);
        bucket.swFetchFailures += toNumber(record.payload?.fetchFailures);
      }
      if (record.event === 'offline_recovered') {
        bucket.recoveredCount += 1;
      }
      if (record.event === 'offline_resume_primary_task') {
        bucket.resumedCount += 1;
      }
    }
  }

  const toTrendRows = (
    map: Map<
      string,
      Map<
        string,
        {
          events: number;
          scriptLoadAttempts: number;
          scriptLoadFailures: number;
          swRequests: number;
          swCacheHits: number;
          swFetchFailures: number;
          recoveredCount: number;
          resumedCount: number;
        }
      >
    >,
  ): DimensionTrendRow[] => {
    const rows: DimensionTrendRow[] = [];
    for (const [key, dayMap] of map.entries()) {
      const points = [...dayMap.entries()]
        .sort(([a], [b]) => a.localeCompare(b))
        .map(([day, item]) => ({
          day,
          events: item.events,
          scriptLoadFailureRate: round4(safeDivide(item.scriptLoadFailures, item.scriptLoadAttempts)),
          swCacheHitRate: round4(safeDivide(item.swCacheHits, item.swRequests)),
          swFetchFailureRate: round4(safeDivide(item.swFetchFailures, item.swRequests)),
          recoveryReturnRate: round4(safeDivide(item.resumedCount, item.recoveredCount)),
        }));
      const totalEvents = points.reduce((sum, item) => sum + item.events, 0);
      rows.push({ key, totalEvents, points });
    }
    return rows.sort((a, b) => b.totalEvents - a.totalEvents).slice(0, 5);
  };

  return {
    byScriptVersion: toTrendRows(versionTrend),
    byRoute: toTrendRows(routeTrend),
  };
}

function buildActionItems(
  alerts: ObservabilityAlert[],
  drilldowns: ObservabilityDrilldowns,
  trends: ObservabilityTrends,
): ActionItem[] {
  const actionItems: ActionItem[] = [];
  const hasCritical = alerts.some((alert) => alert.level === 'critical');

  const candidateVersions = drilldowns.byScriptVersion.filter((item) => item.key !== 'unknown' && item.events >= 10);
  const worstVersion = candidateVersions
    .filter((item) => item.scriptLoadFailureRate > ALERT_THRESHOLDS.scriptLoadFailureRate)
    .sort((a, b) => b.scriptLoadFailureRate - a.scriptLoadFailureRate)[0];
  if (worstVersion) {
    const fallbackVersion = candidateVersions
      .filter((item) => item.key !== worstVersion.key)
      .sort((a, b) => {
        if (a.scriptLoadFailureRate !== b.scriptLoadFailureRate) {
          return a.scriptLoadFailureRate - b.scriptLoadFailureRate;
        }
        return b.events - a.events;
      })[0];
    actionItems.push({
      priority: hasCritical ? 'P0' : 'P1',
      type: 'rollback_version',
      title: `版本 ${worstVersion.key} 建议回滚`,
      reason: `脚本失败率 ${round4(worstVersion.scriptLoadFailureRate)} 超过阈值 ${ALERT_THRESHOLDS.scriptLoadFailureRate}`,
      recommendation: fallbackVersion
        ? `优先切回 ${fallbackVersion.key}，并冻结 ${worstVersion.key} 发布入口`
        : '暂时切回默认稳定版本（例如 v2），并冻结当前版本发布入口',
      target: worstVersion.key,
      adminPath: `/admin/offline-experiments?suggestedVersion=${encodeURIComponent(
        fallbackVersion?.key || 'v2',
      )}&from=offline-report`,
      executeApi: {
        endpoint: '/api/offline-experiments/config',
        method: 'PUT',
        body: {
          activeGameVersion: fallbackVersion?.key || 'v2',
        },
      },
    });
  }

  const highRiskRoute = drilldowns.byRoute
    .filter((item) => item.key !== 'unknown' && item.events >= 20)
    .sort((a, b) => {
      const riskA = a.swAlertCount * 2 + a.swFetchFailureRate * 100 - a.recoveryReturnRate * 30;
      const riskB = b.swAlertCount * 2 + b.swFetchFailureRate * 100 - b.recoveryReturnRate * 30;
      return riskB - riskA;
    })[0];
  if (
    highRiskRoute &&
    (highRiskRoute.swAlertCount > 0 ||
      highRiskRoute.swFetchFailureRate > ALERT_THRESHOLDS.swFetchFailureRate ||
      highRiskRoute.recoveryReturnRate < ALERT_THRESHOLDS.recoveryReturnRateMin)
  ) {
    actionItems.push({
      priority: 'P1',
      type: 'route_investigation',
      title: `路由 ${highRiskRoute.key} 需优先排查`,
      reason: `告警 ${highRiskRoute.swAlertCount} 次，SW 回源失败率 ${round4(highRiskRoute.swFetchFailureRate)}`,
      recommendation: '检查该路由静态资源依赖、Service Worker 命中路径与恢复弹窗回流文案',
      target: highRiskRoute.key,
      adminPath: '/traces',
    });
  }

  const lowHitRoute = drilldowns.byRoute
    .filter((item) => item.key !== 'unknown' && item.events >= 20)
    .sort((a, b) => a.swCacheHitRate - b.swCacheHitRate)[0];
  if (lowHitRoute && lowHitRoute.swCacheHitRate < ALERT_THRESHOLDS.swCacheHitRateMin) {
    actionItems.push({
      priority: 'P1',
      type: 'cache_policy_tuning',
      title: `路由 ${lowHitRoute.key} 建议调整缓存策略`,
      reason: `SW 缓存命中率 ${round4(lowHitRoute.swCacheHitRate)} 低于阈值 ${ALERT_THRESHOLDS.swCacheHitRateMin}`,
      recommendation: '将该路由关键脚本/样式纳入 precache 或提高 runtime cache 保留预算',
      target: lowHitRoute.key,
      adminPath: '/admin/offline-experiments',
    });
  }

  const worstRecoveryTrend = trends.byRoute
    .map((row) => {
      const first = row.points[0];
      const last = row.points[row.points.length - 1];
      return {
        key: row.key,
        delta: (last?.recoveryReturnRate || 0) - (first?.recoveryReturnRate || 0),
        latest: last?.recoveryReturnRate || 0,
        points: row.points.length,
      };
    })
    .filter((item) => item.points >= 3 && item.delta < -0.1 && item.latest < ALERT_THRESHOLDS.recoveryReturnRateMin)
    .sort((a, b) => a.delta - b.delta)[0];
  if (worstRecoveryTrend) {
    actionItems.push({
      priority: 'P2',
      type: 'recovery_experience_tuning',
      title: `路由 ${worstRecoveryTrend.key} 恢复体验下降`,
      reason: `恢复回流率趋势下滑 ${round4(worstRecoveryTrend.delta)}，当前 ${round4(worstRecoveryTrend.latest)}`,
      recommendation: '优化该页面恢复后自动回流策略与按钮文案，降低用户离场',
      target: worstRecoveryTrend.key,
      adminPath: '/admin/offline-experiments',
    });
  }

  return actionItems.slice(0, 5);
}

function computeObservabilityMetrics(
  records: OfflineEventRecord[],
  eventCounts: Record<string, number>,
  avgOfflineDurationMs: number,
): {
  metrics: ObservabilityMetrics;
  alerts: ObservabilityAlert[];
  alertCounts: Record<string, number>;
} {
  const assignmentCount = eventCounts['offline_experiment_assigned'] || 0;
  const modalShownCount = eventCounts['offline_modal_shown'] || 0;
  const recoveredCount = eventCounts['offline_recovered'] || 0;
  const resumedCount = eventCounts['offline_resume_primary_task'] || 0;
  const gameStartedCount = eventCounts['offline_game_started'] || 0;

  let scriptLoadAttempts = 0;
  let scriptLoadFailures = 0;
  let swRequests = 0;
  let swCacheHits = 0;
  let swFetchFailures = 0;
  const alertCounts: Record<string, number> = {};

  for (const record of records) {
    if (record.event === 'offline_game_script_load') {
      scriptLoadAttempts += 1;
      const success = Boolean(record.payload?.success);
      if (!success) {
        scriptLoadFailures += 1;
      }
    }
    if (record.event === 'offline_sw_metrics') {
      swRequests += toNumber(record.payload?.requests);
      swCacheHits += toNumber(record.payload?.cacheHits);
      swFetchFailures += toNumber(record.payload?.fetchFailures);
    }
    if (record.event === 'offline_sw_alert') {
      const code = String(record.payload?.code || 'unknown');
      alertCounts[code] = (alertCounts[code] || 0) + 1;
    }
  }

  const metrics: ObservabilityMetrics = {
    offlineTriggerRate: safeDivide(modalShownCount, assignmentCount),
    gameOpenRate: safeDivide(gameStartedCount, modalShownCount),
    recoveryReturnRate: safeDivide(resumedCount, recoveredCount),
    recoveryDurationMs: avgOfflineDurationMs,
    scriptLoadFailureRate: safeDivide(scriptLoadFailures, scriptLoadAttempts),
    swCacheHitRate: safeDivide(swCacheHits, swRequests),
    swFetchFailureRate: safeDivide(swFetchFailures, swRequests),
  };

  const alerts: ObservabilityAlert[] = [];
  if (scriptLoadAttempts >= 20 && metrics.scriptLoadFailureRate > ALERT_THRESHOLDS.scriptLoadFailureRate) {
    alerts.push({
      level: 'critical',
      code: 'script_load_failure_rate_high',
      message: '脚本加载失败率偏高，建议回滚到稳定版本并检查发布资源可达性',
      currentValue: round4(metrics.scriptLoadFailureRate),
      threshold: ALERT_THRESHOLDS.scriptLoadFailureRate,
    });
  }
  if (swRequests >= 20 && metrics.swFetchFailureRate > ALERT_THRESHOLDS.swFetchFailureRate) {
    alerts.push({
      level: 'critical',
      code: 'sw_fetch_failure_rate_high',
      message: 'SW 回源失败率偏高，建议检查静态资源可用性与缓存策略',
      currentValue: round4(metrics.swFetchFailureRate),
      threshold: ALERT_THRESHOLDS.swFetchFailureRate,
    });
  }
  if (swRequests >= 20 && metrics.swCacheHitRate < ALERT_THRESHOLDS.swCacheHitRateMin) {
    alerts.push({
      level: 'warn',
      code: 'sw_cache_hit_rate_low',
      message: 'SW 缓存命中率偏低，建议扩大关键资源缓存覆盖或延长 TTL',
      currentValue: round4(metrics.swCacheHitRate),
      threshold: ALERT_THRESHOLDS.swCacheHitRateMin,
    });
  }
  if (recoveredCount >= 20 && metrics.recoveryReturnRate < ALERT_THRESHOLDS.recoveryReturnRateMin) {
    alerts.push({
      level: 'warn',
      code: 'recovery_return_rate_low',
      message: '恢复后回流率偏低，建议优化恢复提示与自动回流文案',
      currentValue: round4(metrics.recoveryReturnRate),
      threshold: ALERT_THRESHOLDS.recoveryReturnRateMin,
    });
  }
  if (recoveredCount >= 20 && metrics.recoveryDurationMs > ALERT_THRESHOLDS.recoveryDurationMsHigh) {
    alerts.push({
      level: 'warn',
      code: 'recovery_duration_high',
      message: '平均恢复耗时偏高，建议优化探测间隔与恢复判定门槛',
      currentValue: Math.round(metrics.recoveryDurationMs),
      threshold: ALERT_THRESHOLDS.recoveryDurationMsHigh,
    });
  }

  return {
    metrics,
    alerts,
    alertCounts,
  };
}

function summarizeVariant(
  records: OfflineEventRecord[],
  dimension: 'trigger' | 'content',
): {
  table: Record<string, VariantAccumulator & { recoveryRate: number; resumeAfterRecoveryRate: number }>;
  winner: string;
  winnerReason: string;
} {
  const acc: Record<string, VariantAccumulator> = {};
  for (const record of records) {
    const key = getVariantKey(record, dimension);
    acc[key] = acc[key] || { shown: 0, recovered: 0, resumed: 0 };
    if (record.event === 'offline_modal_shown') acc[key].shown += 1;
    if (record.event === 'offline_recovered') acc[key].recovered += 1;
    if (record.event === 'offline_resume_primary_task') acc[key].resumed += 1;
  }

  const table: Record<
    string,
    VariantAccumulator & { recoveryRate: number; resumeAfterRecoveryRate: number }
  > = {};
  for (const [key, item] of Object.entries(acc)) {
    table[key] = {
      ...item,
      recoveryRate: round4(safeDivide(item.recovered, item.shown)),
      resumeAfterRecoveryRate: round4(safeDivide(item.resumed, item.recovered)),
    };
  }

  const validKeys = Object.keys(table).filter((key) => key !== 'unknown');
  let winner = validKeys[0] || 'n/a';
  let winnerReason = '样本不足';
  if (validKeys.length >= 2) {
    const sorted = validKeys.sort((a, b) => {
      const scoreA = table[a].resumeAfterRecoveryRate * 0.7 + table[a].recoveryRate * 0.3;
      const scoreB = table[b].resumeAfterRecoveryRate * 0.7 + table[b].recoveryRate * 0.3;
      return scoreB - scoreA;
    });
    winner = sorted[0];
    winnerReason = '按恢复后继续率(70%) + 恢复率(30%)综合评分';
  }

  return { table, winner, winnerReason };
}

export async function getOfflineWeeklySummary(days = 7) {
  if (offlineDbEnabled()) {
    try {
      return await getOfflineWeeklySummaryFromDb(days);
    } catch (error) {
      console.warn('[offline-events] aggregate from db failed, fallback to memory', error);
    }
  }
  const records = await listOfflineEvents(days);

  const eventCounts: Record<string, number> = {};
  const closeReasons: Record<string, number> = {};
  const triggerVariantCounts: Record<string, number> = {};
  const contentVariantCounts: Record<string, number> = {};
  const daily: Record<string, { shown: number; recovered: number; resumed: number }> = {};
  const durationList: number[] = [];

  for (const record of records) {
    eventCounts[record.event] = (eventCounts[record.event] || 0) + 1;

    const dayKey = new Date(record.timestamp).toISOString().slice(0, 10);
    daily[dayKey] = daily[dayKey] || { shown: 0, recovered: 0, resumed: 0 };

    if (record.event === 'offline_modal_shown') daily[dayKey].shown += 1;
    if (record.event === 'offline_recovered') daily[dayKey].recovered += 1;
    if (record.event === 'offline_resume_primary_task') daily[dayKey].resumed += 1;

    if (record.event === 'offline_modal_closed') {
      const reason = (record.payload?.reason as string) || 'unknown';
      closeReasons[reason] = (closeReasons[reason] || 0) + 1;
    }

    if (record.experiment?.triggerVariant) {
      const key = record.experiment.triggerVariant;
      triggerVariantCounts[key] = (triggerVariantCounts[key] || 0) + 1;
    }
    if (record.experiment?.contentVariant) {
      const key = record.experiment.contentVariant;
      contentVariantCounts[key] = (contentVariantCounts[key] || 0) + 1;
    }

    if (record.event === 'offline_recovered') {
      durationList.push(toNumber(record.payload?.offlineDurationMs));
    }
  }

  const totalShown = eventCounts['offline_modal_shown'] || 0;
  const totalRecovered = eventCounts['offline_recovered'] || 0;
  const totalResumed = eventCounts['offline_resume_primary_task'] || 0;
  const totalBusinessResumed = eventCounts['offline_resume_business_funnel'] || 0;
  const totalClosed = eventCounts['offline_modal_closed'] || 0;
  const waitingLoss = Math.max(totalShown - totalRecovered - totalClosed, 0);
  const triggerAb = summarizeVariant(records, 'trigger');
  const contentAb = summarizeVariant(records, 'content');
  const avgOfflineDurationMs =
    durationList.length > 0 ? Math.round(durationList.reduce((sum, item) => sum + item, 0) / durationList.length) : 0;
  const observability = computeObservabilityMetrics(records, eventCounts, avgOfflineDurationMs);
  const drilldowns = buildDimensionDrilldowns(records);
  const trends = buildDimensionTrends(records);
  const actionItems = buildActionItems(observability.alerts, drilldowns, trends);
  const recommendationFromAlerts = observability.alerts.map(
    (alert) => `[${alert.level.toUpperCase()}] ${alert.code}: ${alert.message}`,
  );

  const dashboard = {
    headline: {
      windowDays: days,
      totalEvents: records.length,
      sessionsCovered: new Set(records.map((record) => record.sessionId).filter(Boolean)).size,
    },
    kpi: {
      recoveryRate: round4(safeDivide(totalRecovered, totalShown)),
      resumedAfterRecoveryRate: round4(safeDivide(totalResumed, totalRecovered)),
      businessFunnelResumeRate: round4(safeDivide(totalBusinessResumed, totalRecovered)),
      waitingLossRate: round4(safeDivide(waitingLoss, totalShown)),
      avgOfflineDurationMs,
      offlineTriggerRate: round4(observability.metrics.offlineTriggerRate),
      gameOpenRate: round4(observability.metrics.gameOpenRate),
      recoveryReturnRate: round4(observability.metrics.recoveryReturnRate),
      scriptLoadFailureRate: round4(observability.metrics.scriptLoadFailureRate),
      swCacheHitRate: round4(observability.metrics.swCacheHitRate),
      swFetchFailureRate: round4(observability.metrics.swFetchFailureRate),
    },
    abInsights: {
      trigger: {
        winner: triggerAb.winner,
        winnerReason: triggerAb.winnerReason,
        variants: triggerAb.table,
      },
      content: {
        winner: contentAb.winner,
        winnerReason: contentAb.winnerReason,
        variants: contentAb.table,
      },
    },
    recommendations: [
      `触发实验当前建议优先使用: ${triggerAb.winner}`,
      `内容实验当前建议优先使用: ${contentAb.winner}`,
      '若 waitingLossRate 持续 > 0.15，建议缩短检测间隔并优化恢复提示',
      ...recommendationFromAlerts,
    ],
    actionItems,
    alerts: observability.alerts,
    drilldowns,
    trends,
  };

  return {
    windowDays: days,
    totalEvents: records.length,
    eventCounts,
    closeReasons,
    variants: {
      triggerVariantCounts,
      contentVariantCounts,
    },
    metrics: {
      resumedAfterRecoveryRate: safeDivide(totalResumed, totalRecovered),
      businessFunnelResumeRate: safeDivide(totalBusinessResumed, totalRecovered),
      recoveryRate: safeDivide(totalRecovered, totalShown),
      avgOfflineDurationMs,
      waitingLossRate: safeDivide(waitingLoss, totalShown),
      offlineTriggerRate: observability.metrics.offlineTriggerRate,
      gameOpenRate: observability.metrics.gameOpenRate,
      recoveryReturnRate: observability.metrics.recoveryReturnRate,
      scriptLoadFailureRate: observability.metrics.scriptLoadFailureRate,
      swCacheHitRate: observability.metrics.swCacheHitRate,
      swFetchFailureRate: observability.metrics.swFetchFailureRate,
    },
    alertCounts: observability.alertCounts,
    alerts: observability.alerts,
    drilldowns,
    trends,
    actionItems,
    daily,
    dashboard,
  };
}

async function getOfflineWeeklySummaryFromDb(days: number) {
  const dayWindow = Math.min(Math.max(days, 1), 30);
  const intervalParam = dayWindow.toString();
  const records = await loadEventsFromDb(dayWindow);

  const eventRows = await queryDb<{ event: string; count: number }>(
    `
      SELECT event, COUNT(*)::int AS count
      FROM offline_events
      WHERE event_at >= NOW() - ($1 || ' days')::INTERVAL
      GROUP BY event
    `,
    [intervalParam],
  );

  const eventCounts: Record<string, number> = {};
  for (const row of eventRows) {
    eventCounts[row.event] = Number(row.count) || 0;
  }

  const closeRows = await queryDb<{ reason: string; count: number }>(
    `
      SELECT COALESCE(payload->>'reason', 'unknown') AS reason, COUNT(*)::int AS count
      FROM offline_events
      WHERE event = 'offline_modal_closed'
        AND event_at >= NOW() - ($1 || ' days')::INTERVAL
      GROUP BY COALESCE(payload->>'reason', 'unknown')
    `,
    [intervalParam],
  );
  const closeReasons: Record<string, number> = {};
  for (const row of closeRows) {
    closeReasons[row.reason] = Number(row.count) || 0;
  }

  const dailyRows = await queryDb<{ day_key: string; shown: number; recovered: number; resumed: number }>(
    `
      SELECT
        to_char(event_at AT TIME ZONE 'UTC', 'YYYY-MM-DD') AS day_key,
        SUM(CASE WHEN event = 'offline_modal_shown' THEN 1 ELSE 0 END)::int AS shown,
        SUM(CASE WHEN event = 'offline_recovered' THEN 1 ELSE 0 END)::int AS recovered,
        SUM(CASE WHEN event = 'offline_resume_primary_task' THEN 1 ELSE 0 END)::int AS resumed
      FROM offline_events
      WHERE event_at >= NOW() - ($1 || ' days')::INTERVAL
      GROUP BY day_key
      ORDER BY day_key
    `,
    [intervalParam],
  );
  const daily: Record<string, { shown: number; recovered: number; resumed: number }> = {};
  for (const row of dailyRows) {
    daily[row.day_key] = {
      shown: Number(row.shown) || 0,
      recovered: Number(row.recovered) || 0,
      resumed: Number(row.resumed) || 0,
    };
  }

  const variantRows = await queryDb<{
    trigger_variant: string;
    content_variant: string;
    shown: number;
    recovered: number;
    resumed: number;
  }>(
    `
      SELECT
        COALESCE(experiment->>'triggerVariant', 'unknown') AS trigger_variant,
        COALESCE(experiment->>'contentVariant', 'unknown') AS content_variant,
        SUM(CASE WHEN event = 'offline_modal_shown' THEN 1 ELSE 0 END)::int AS shown,
        SUM(CASE WHEN event = 'offline_recovered' THEN 1 ELSE 0 END)::int AS recovered,
        SUM(CASE WHEN event = 'offline_resume_primary_task' THEN 1 ELSE 0 END)::int AS resumed
      FROM offline_events
      WHERE event_at >= NOW() - ($1 || ' days')::INTERVAL
        AND event IN ('offline_modal_shown', 'offline_recovered', 'offline_resume_primary_task')
      GROUP BY trigger_variant, content_variant
    `,
    [intervalParam],
  );

  const triggerVariantCounts: Record<string, number> = {};
  const contentVariantCounts: Record<string, number> = {};
  const triggerAcc: Record<string, VariantAccumulator> = {};
  const contentAcc: Record<string, VariantAccumulator> = {};

  for (const row of variantRows) {
    const trigger = row.trigger_variant || 'unknown';
    const content = row.content_variant || 'unknown';
    const shown = Number(row.shown) || 0;
    const recovered = Number(row.recovered) || 0;
    const resumed = Number(row.resumed) || 0;

    triggerVariantCounts[trigger] = (triggerVariantCounts[trigger] || 0) + shown;
    contentVariantCounts[content] = (contentVariantCounts[content] || 0) + shown;

    triggerAcc[trigger] = triggerAcc[trigger] || { shown: 0, recovered: 0, resumed: 0 };
    contentAcc[content] = contentAcc[content] || { shown: 0, recovered: 0, resumed: 0 };
    triggerAcc[trigger].shown += shown;
    triggerAcc[trigger].recovered += recovered;
    triggerAcc[trigger].resumed += resumed;
    contentAcc[content].shown += shown;
    contentAcc[content].recovered += recovered;
    contentAcc[content].resumed += resumed;
  }

  const durationRows = await queryDb<{ avg_duration_ms: number | null }>(
    `
      SELECT AVG((payload->>'offlineDurationMs')::numeric)::float8 AS avg_duration_ms
      FROM offline_events
      WHERE event = 'offline_recovered'
        AND event_at >= NOW() - ($1 || ' days')::INTERVAL
        AND payload ? 'offlineDurationMs'
    `,
    [intervalParam],
  );
  const avgDuration = Math.round(Number(durationRows[0]?.avg_duration_ms || 0));

  const metaRows = await queryDb<{ total_events: number; sessions_covered: number }>(
    `
      SELECT
        COUNT(*)::int AS total_events,
        COUNT(DISTINCT session_id)::int AS sessions_covered
      FROM offline_events
      WHERE event_at >= NOW() - ($1 || ' days')::INTERVAL
    `,
    [intervalParam],
  );

  const totalShown = eventCounts['offline_modal_shown'] || 0;
  const totalRecovered = eventCounts['offline_recovered'] || 0;
  const totalResumed = eventCounts['offline_resume_primary_task'] || 0;
  const totalBusinessResumed = eventCounts['offline_resume_business_funnel'] || 0;
  const totalClosed = eventCounts['offline_modal_closed'] || 0;
  const waitingLoss = Math.max(totalShown - totalRecovered - totalClosed, 0);

  const triggerAb = summarizeVariantFromAcc(triggerAcc);
  const contentAb = summarizeVariantFromAcc(contentAcc);
  const observability = computeObservabilityMetrics(records, eventCounts, avgDuration);
  const drilldowns = buildDimensionDrilldowns(records);
  const trends = buildDimensionTrends(records);
  const actionItems = buildActionItems(observability.alerts, drilldowns, trends);
  const recommendationFromAlerts = observability.alerts.map(
    (alert) => `[${alert.level.toUpperCase()}] ${alert.code}: ${alert.message}`,
  );

  const totalEvents = Number(metaRows[0]?.total_events || 0);
  const sessionsCovered = Number(metaRows[0]?.sessions_covered || 0);

  return {
    windowDays: dayWindow,
    totalEvents,
    eventCounts,
    closeReasons,
    variants: {
      triggerVariantCounts,
      contentVariantCounts,
    },
    metrics: {
      resumedAfterRecoveryRate: safeDivide(totalResumed, totalRecovered),
      businessFunnelResumeRate: safeDivide(totalBusinessResumed, totalRecovered),
      recoveryRate: safeDivide(totalRecovered, totalShown),
      avgOfflineDurationMs: avgDuration,
      waitingLossRate: safeDivide(waitingLoss, totalShown),
      offlineTriggerRate: observability.metrics.offlineTriggerRate,
      gameOpenRate: observability.metrics.gameOpenRate,
      recoveryReturnRate: observability.metrics.recoveryReturnRate,
      scriptLoadFailureRate: observability.metrics.scriptLoadFailureRate,
      swCacheHitRate: observability.metrics.swCacheHitRate,
      swFetchFailureRate: observability.metrics.swFetchFailureRate,
    },
    alertCounts: observability.alertCounts,
    alerts: observability.alerts,
    drilldowns,
    trends,
    actionItems,
    daily,
    dashboard: {
      headline: {
        windowDays: dayWindow,
        totalEvents,
        sessionsCovered,
      },
      kpi: {
        recoveryRate: round4(safeDivide(totalRecovered, totalShown)),
        resumedAfterRecoveryRate: round4(safeDivide(totalResumed, totalRecovered)),
        businessFunnelResumeRate: round4(safeDivide(totalBusinessResumed, totalRecovered)),
        waitingLossRate: round4(safeDivide(waitingLoss, totalShown)),
        avgOfflineDurationMs: avgDuration,
        offlineTriggerRate: round4(observability.metrics.offlineTriggerRate),
        gameOpenRate: round4(observability.metrics.gameOpenRate),
        recoveryReturnRate: round4(observability.metrics.recoveryReturnRate),
        scriptLoadFailureRate: round4(observability.metrics.scriptLoadFailureRate),
        swCacheHitRate: round4(observability.metrics.swCacheHitRate),
        swFetchFailureRate: round4(observability.metrics.swFetchFailureRate),
      },
      abInsights: {
        trigger: {
          winner: triggerAb.winner,
          winnerReason: triggerAb.winnerReason,
          variants: triggerAb.table,
        },
        content: {
          winner: contentAb.winner,
          winnerReason: contentAb.winnerReason,
          variants: contentAb.table,
        },
      },
      recommendations: [
        `触发实验当前建议优先使用: ${triggerAb.winner}`,
        `内容实验当前建议优先使用: ${contentAb.winner}`,
        '若 waitingLossRate 持续 > 0.15，建议缩短检测间隔并优化恢复提示',
        ...recommendationFromAlerts,
      ],
      actionItems,
      alerts: observability.alerts,
      drilldowns,
      trends,
    },
  };
}

function summarizeVariantFromAcc(acc: Record<string, VariantAccumulator>) {
  const table: Record<
    string,
    VariantAccumulator & { recoveryRate: number; resumeAfterRecoveryRate: number }
  > = {};
  for (const [key, item] of Object.entries(acc)) {
    table[key] = {
      ...item,
      recoveryRate: round4(safeDivide(item.recovered, item.shown)),
      resumeAfterRecoveryRate: round4(safeDivide(item.resumed, item.recovered)),
    };
  }

  const validKeys = Object.keys(table).filter((key) => key !== 'unknown');
  let winner = validKeys[0] || 'n/a';
  let winnerReason = '样本不足';
  if (validKeys.length >= 2) {
    const sorted = validKeys.sort((a, b) => {
      const scoreA = table[a].resumeAfterRecoveryRate * 0.7 + table[a].recoveryRate * 0.3;
      const scoreB = table[b].resumeAfterRecoveryRate * 0.7 + table[b].recoveryRate * 0.3;
      return scoreB - scoreA;
    });
    winner = sorted[0];
    winnerReason = '按恢复后继续率(70%) + 恢复率(30%)综合评分';
  }
  return { table, winner, winnerReason };
}

