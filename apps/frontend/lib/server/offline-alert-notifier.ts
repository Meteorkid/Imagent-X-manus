import { offlineDbEnabled, queryDb } from './offline-db';
type AlertLevel = 'warn' | 'critical';

export type AlertNotificationItem = {
  code: string;
  level: AlertLevel;
  message: string;
  currentValue: string;
  threshold: string;
  suggestion: string;
  hitCount?: number;
};

export type AlertNotificationInput = {
  signature: string;
  alerts: AlertNotificationItem[];
  stats: Record<string, unknown>;
  aggregation: Record<string, unknown>;
};

export type AlertDeliveryResult = {
  channel: 'webhook';
  provider: 'generic' | 'wecom' | 'feishu' | 'dingtalk';
  enabled: boolean;
  attempted: boolean;
  delivered: boolean;
  severity: AlertLevel;
  minLevel: AlertLevel;
  targetCount: number;
  statusCodes: number[];
  maxAttempts: number;
  attemptsMade: number;
  retryCount: number;
  queueWaitMs: number;
  processingDurationMs: number;
  backoffDelaysMs: number[];
  deadLettered: boolean;
  deadLetterReason?: string;
  queueJobId?: string;
  skippedReason?: string;
  error?: string;
};

const LEVEL_WEIGHT: Record<AlertLevel, number> = {
  warn: 1,
  critical: 2,
};

type QueueJob = {
  id: string;
  enqueuedAt: number;
  input: AlertNotificationInput;
  resolve: (value: AlertDeliveryResult) => void;
};

const deliveryQueue: QueueJob[] = [];
let queueWorkerRunning = false;
let recoveryLoaded = false;
const queuedJobIds = new Set<string>();

function normalizeProvider(input: string | undefined): AlertDeliveryResult['provider'] {
  const value = (input || '').trim().toLowerCase();
  if (value === 'wecom' || value === 'feishu' || value === 'dingtalk') return value;
  return 'generic';
}

function normalizeLevel(input: string | undefined, fallback: AlertLevel): AlertLevel {
  return input === 'warn' || input === 'critical' ? input : fallback;
}

function toSafeInt(input: string | undefined, fallback: number, min: number, max: number) {
  const num = Number(input);
  if (!Number.isFinite(num)) return fallback;
  return Math.min(max, Math.max(min, Math.floor(num)));
}

function resolveMaxSeverity(alerts: AlertNotificationItem[]): AlertLevel {
  if (alerts.some((item) => item.level === 'critical')) return 'critical';
  return 'warn';
}

function resolveWebhookTargets(): string[] {
  const fromList = (process.env.OFFLINE_ALERT_WEBHOOK_URLS || '')
    .split(',')
    .map((item) => item.trim())
    .filter(Boolean);
  if (fromList.length > 0) return fromList;
  const single = (process.env.OFFLINE_ALERT_WEBHOOK_URL || '').trim();
  return single ? [single] : [];
}

function sleep(ms: number) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

function buildJobId() {
  return `alert-delivery-${Date.now()}-${Math.random().toString(36).slice(2, 8)}`;
}

function buildNotificationText(input: AlertNotificationInput, severity: AlertLevel) {
  const top = input.alerts
    .slice(0, 5)
    .map((item) => `- [${item.level}] ${item.code}: ${item.currentValue} / ${item.threshold}`)
    .join('\n');
  return [
    `离线下载中心告警（${severity.toUpperCase()}）`,
    `签名: ${input.signature}`,
    `告警数: ${input.alerts.length}`,
    `详情:`,
    top || '- 无',
  ].join('\n');
}

function buildProviderPayload(
  provider: AlertDeliveryResult['provider'],
  input: AlertNotificationInput,
  severity: AlertLevel,
) {
  const text = buildNotificationText(input, severity);
  if (provider === 'wecom') {
    return {
      msgtype: 'markdown',
      markdown: {
        content: text.replaceAll('\n', '\n> '),
      },
    };
  }
  if (provider === 'feishu') {
    return {
      msg_type: 'text',
      content: {
        text,
      },
    };
  }
  if (provider === 'dingtalk') {
    return {
      msgtype: 'text',
      text: {
        content: text,
      },
    };
  }
  return {
    source: 'offline_download_center_alert',
    severity,
    signature: input.signature,
    alerts: input.alerts,
    stats: input.stats,
    aggregation: input.aggregation,
    sentAt: new Date().toISOString(),
  };
}

async function sendWebhookOnce(
  target: string,
  payload: unknown,
  timeoutMs: number,
): Promise<{ statusCode: number; ok: boolean; error?: string }> {
  try {
    const controller = new AbortController();
    const timer = setTimeout(() => controller.abort(), timeoutMs);
    const response = await fetch(target, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(payload),
      signal: controller.signal,
    });
    clearTimeout(timer);
    return { statusCode: response.status, ok: response.ok };
  } catch (error) {
    return {
      statusCode: 0,
      ok: false,
      error: error instanceof Error ? error.message : 'webhook_request_failed',
    };
  }
}

async function persistJobCreated(jobId: string, input: AlertNotificationInput) {
  if (!offlineDbEnabled()) return;
  await queryDb(
    `
      INSERT INTO offline_alert_delivery_jobs (
        id,
        signature,
        payload,
        status,
        attempt_count,
        max_attempts,
        status_codes,
        backoff_delays_ms,
        created_at,
        updated_at
      ) VALUES ($1, $2, $3::jsonb, 'pending', 0, 0, '[]'::jsonb, '[]'::jsonb, NOW(), NOW())
      ON CONFLICT (id) DO NOTHING
    `,
    [jobId, input.signature, JSON.stringify(input)],
  );
}

async function persistJobAttempt(
  jobId: string,
  attemptCount: number,
  maxAttempts: number,
  statusCodes: number[],
  backoffDelaysMs: number[],
  status: 'processing' | 'retrying' | 'delivered' | 'dead_letter',
  error?: string,
) {
  if (!offlineDbEnabled()) return;
  await queryDb(
    `
      UPDATE offline_alert_delivery_jobs
      SET
        status = $2,
        attempt_count = $3,
        max_attempts = $4,
        status_codes = $5::jsonb,
        backoff_delays_ms = $6::jsonb,
        last_error = $7,
        updated_at = NOW()
      WHERE id = $1
    `,
    [
      jobId,
      status,
      attemptCount,
      maxAttempts,
      JSON.stringify(statusCodes),
      JSON.stringify(backoffDelaysMs),
      error || null,
    ],
  );
}

async function persistJobFinal(
  jobId: string,
  result: AlertDeliveryResult,
  status: 'delivered' | 'dead_letter' | 'skipped',
) {
  if (!offlineDbEnabled()) return;
  await queryDb(
    `
      UPDATE offline_alert_delivery_jobs
      SET
        status = $2,
        attempt_count = $3,
        max_attempts = $4,
        status_codes = $5::jsonb,
        backoff_delays_ms = $6::jsonb,
        queue_wait_ms = $7,
        processing_duration_ms = $8,
        last_error = $9,
        dead_letter_reason = $10,
        delivered_at = CASE WHEN $2 = 'delivered' THEN NOW() ELSE delivered_at END,
        dead_lettered_at = CASE WHEN $2 = 'dead_letter' THEN NOW() ELSE dead_lettered_at END,
        updated_at = NOW()
      WHERE id = $1
    `,
    [
      jobId,
      status,
      result.attemptsMade,
      result.maxAttempts,
      JSON.stringify(result.statusCodes),
      JSON.stringify(result.backoffDelaysMs),
      result.queueWaitMs,
      result.processingDurationMs,
      result.error || null,
      result.deadLetterReason || null,
    ],
  );
}

async function processNotificationJob(jobId: string, enqueuedAt: number, input: AlertNotificationInput): Promise<AlertDeliveryResult> {
  const provider = normalizeProvider(process.env.OFFLINE_ALERT_WEBHOOK_PROVIDER);
  const enabled = process.env.OFFLINE_ALERT_WEBHOOK_ENABLED !== 'false';
  const minLevel = normalizeLevel(process.env.OFFLINE_ALERT_WEBHOOK_MIN_LEVEL, 'critical');
  const maxAttempts = toSafeInt(process.env.OFFLINE_ALERT_RETRY_MAX_ATTEMPTS, 3, 1, 8);
  const baseBackoffMs = toSafeInt(process.env.OFFLINE_ALERT_RETRY_BASE_DELAY_MS, 1200, 200, 120000);
  const maxBackoffMs = toSafeInt(process.env.OFFLINE_ALERT_RETRY_MAX_DELAY_MS, 30000, 500, 300000);
  const severity = resolveMaxSeverity(input.alerts);
  const targets = resolveWebhookTargets();
  const timeoutMs = toSafeInt(process.env.OFFLINE_ALERT_WEBHOOK_TIMEOUT_MS, 5000, 1000, 60000);
  const queueWaitMs = Date.now() - enqueuedAt;
  const processStartedAt = Date.now();

  if (!enabled) {
    const result: AlertDeliveryResult = {
      channel: 'webhook',
      provider,
      enabled,
      attempted: false,
      delivered: false,
      severity,
      minLevel,
      targetCount: 0,
      statusCodes: [],
      maxAttempts,
      attemptsMade: 0,
      retryCount: 0,
      queueWaitMs,
      processingDurationMs: Date.now() - processStartedAt,
      backoffDelaysMs: [],
      deadLettered: false,
      queueJobId: jobId,
      skippedReason: 'webhook_disabled',
    };
    await persistJobFinal(jobId, result, 'skipped');
    return result;
  }

  if (LEVEL_WEIGHT[severity] < LEVEL_WEIGHT[minLevel]) {
    const result: AlertDeliveryResult = {
      channel: 'webhook',
      provider,
      enabled,
      attempted: false,
      delivered: false,
      severity,
      minLevel,
      targetCount: targets.length,
      statusCodes: [],
      maxAttempts,
      attemptsMade: 0,
      retryCount: 0,
      queueWaitMs,
      processingDurationMs: Date.now() - processStartedAt,
      backoffDelaysMs: [],
      deadLettered: false,
      queueJobId: jobId,
      skippedReason: 'below_min_level',
    };
    await persistJobFinal(jobId, result, 'skipped');
    return result;
  }

  if (targets.length === 0) {
    const result: AlertDeliveryResult = {
      channel: 'webhook',
      provider,
      enabled,
      attempted: false,
      delivered: false,
      severity,
      minLevel,
      targetCount: 0,
      statusCodes: [],
      maxAttempts,
      attemptsMade: 0,
      retryCount: 0,
      queueWaitMs,
      processingDurationMs: Date.now() - processStartedAt,
      backoffDelaysMs: [],
      deadLettered: false,
      queueJobId: jobId,
      skippedReason: 'missing_webhook_url',
    };
    await persistJobFinal(jobId, result, 'skipped');
    return result;
  }

  const payload = buildProviderPayload(provider, input, severity);
  const backoffDelaysMs: number[] = [];
  const allStatusCodes: number[] = [];
  const errors: string[] = [];
  await persistJobAttempt(jobId, 0, maxAttempts, allStatusCodes, backoffDelaysMs, 'processing');

  for (let attempt = 1; attempt <= maxAttempts; attempt += 1) {
    const attemptStatusCodes: number[] = [];
    const attemptErrors: string[] = [];

    for (const target of targets) {
      const singleResult = await sendWebhookOnce(target, payload, timeoutMs);
      attemptStatusCodes.push(singleResult.statusCode);
      if (!singleResult.ok) {
        attemptErrors.push(singleResult.error || `HTTP ${singleResult.statusCode}`);
      }
    }

    allStatusCodes.push(...attemptStatusCodes);
    if (attemptErrors.length === 0) {
      const result: AlertDeliveryResult = {
        channel: 'webhook',
        provider,
        enabled,
        attempted: true,
        delivered: true,
        severity,
        minLevel,
        targetCount: targets.length,
        statusCodes: allStatusCodes,
        maxAttempts,
        attemptsMade: attempt,
        retryCount: Math.max(0, attempt - 1),
        queueWaitMs,
        processingDurationMs: Date.now() - processStartedAt,
        backoffDelaysMs,
        deadLettered: false,
        queueJobId: jobId,
      };
      await persistJobFinal(jobId, result, 'delivered');
      return result;
    }

    errors.push(`attempt_${attempt}:${attemptErrors.join('|')}`);
    const retrying = attempt < maxAttempts;
    await persistJobAttempt(
      jobId,
      attempt,
      maxAttempts,
      allStatusCodes,
      backoffDelaysMs,
      retrying ? 'retrying' : 'dead_letter',
      errors.join('; '),
    );
    if (attempt < maxAttempts) {
      const delay = Math.min(maxBackoffMs, baseBackoffMs * Math.pow(2, attempt - 1));
      backoffDelaysMs.push(delay);
      await sleep(delay);
    }
  }

  const result: AlertDeliveryResult = {
    channel: 'webhook',
    provider,
    enabled,
    attempted: true,
    delivered: false,
    severity,
    minLevel,
    targetCount: targets.length,
    statusCodes: allStatusCodes,
    maxAttempts,
    attemptsMade: maxAttempts,
    retryCount: Math.max(0, maxAttempts - 1),
    queueWaitMs,
    processingDurationMs: Date.now() - processStartedAt,
    backoffDelaysMs,
    deadLettered: true,
    deadLetterReason: 'retry_exhausted',
    queueJobId: jobId,
    error: errors.join('; '),
  };
  await persistJobFinal(jobId, result, 'dead_letter');
  return result;
}

async function processQueue() {
  if (queueWorkerRunning) return;
  queueWorkerRunning = true;
  while (deliveryQueue.length > 0) {
    const job = deliveryQueue.shift();
    if (!job) break;
    queuedJobIds.delete(job.id);
    const result = await processNotificationJob(job.id, job.enqueuedAt, job.input);
    job.resolve(result);
  }
  queueWorkerRunning = false;
}

async function ensureQueueRecovered() {
  if (recoveryLoaded || !offlineDbEnabled()) return;
  recoveryLoaded = true;
  try {
    const rows = await queryDb<{
      id: string;
      payload: AlertNotificationInput | null;
      created_at: string | Date;
    }>(
      `
        SELECT id, payload, created_at
        FROM offline_alert_delivery_jobs
        WHERE status IN ('pending', 'processing', 'retrying')
        ORDER BY created_at ASC
        LIMIT 200
      `,
    );
    for (const row of rows) {
      if (!row?.payload || queuedJobIds.has(row.id)) continue;
      queuedJobIds.add(row.id);
      deliveryQueue.push({
        id: row.id,
        enqueuedAt: row.created_at ? new Date(row.created_at).getTime() : Date.now(),
        input: row.payload,
        resolve: () => {},
      });
    }
    if (rows.length > 0) {
      void processQueue();
    }
  } catch (_) {
    recoveryLoaded = false;
  }
}

export async function notifyOfflineAlert(input: AlertNotificationInput): Promise<AlertDeliveryResult> {
  await ensureQueueRecovered();
  const jobId = buildJobId();
  queuedJobIds.add(jobId);
  await persistJobCreated(jobId, input);
  return new Promise<AlertDeliveryResult>((resolve) => {
    deliveryQueue.push({
      id: jobId,
      input,
      enqueuedAt: Date.now(),
      resolve,
    });
    void processQueue();
  });
}

export async function replayDeadLetterAlertDelivery(jobId: string): Promise<{
  ok: boolean;
  replayJobId?: string;
  reason?: string;
}> {
  if (!offlineDbEnabled()) {
    return { ok: false, reason: 'db_required' };
  }
  await ensureQueueRecovered();
  const rows = await queryDb<{
    id: string;
    payload: AlertNotificationInput | null;
    status: string;
  }>(
    `
      SELECT id, payload, status
      FROM offline_alert_delivery_jobs
      WHERE id = $1
      LIMIT 1
    `,
    [jobId],
  );
  const row = rows[0];
  if (!row) {
    return { ok: false, reason: 'job_not_found' };
  }
  if (row.status !== 'dead_letter' || !row.payload) {
    return { ok: false, reason: 'job_not_dead_letter' };
  }

  const replayJobId = buildJobId();
  queuedJobIds.add(replayJobId);
  await persistJobCreated(replayJobId, row.payload);
  await queryDb(
    `
      UPDATE offline_alert_delivery_jobs
      SET replayed_by_job_id = $2, replayed_at = NOW(), updated_at = NOW()
      WHERE id = $1
    `,
    [jobId, replayJobId],
  );

  deliveryQueue.push({
    id: replayJobId,
    enqueuedAt: Date.now(),
    input: row.payload,
    resolve: () => {},
  });
  void processQueue();
  return { ok: true, replayJobId };
}
