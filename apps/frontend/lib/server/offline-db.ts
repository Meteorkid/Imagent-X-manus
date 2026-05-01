import { Pool } from 'pg';

let pool: Pool | null = null;
let schemaReadyPromise: Promise<void> | null = null;
let lastCleanupAt = 0;
let lastAuditArchiveAt = 0;

const DEFAULT_RETENTION_DAYS = 30;
const CLEANUP_INTERVAL_MS = 6 * 60 * 60 * 1000;
const AUDIT_ARCHIVE_INTERVAL_MS = 6 * 60 * 60 * 1000;
const DEFAULT_AUDIT_HOT_RETENTION_DAYS = 30;
const DEFAULT_AUDIT_ARCHIVE_RETENTION_DAYS = 365;
const AUDIT_ARCHIVE_BATCH_SIZE = 2000;

function isDbEnabled() {
  return Boolean(process.env.OFFLINE_EVENTS_DATABASE_URL || process.env.DATABASE_URL);
}

function getConnectionString() {
  return process.env.OFFLINE_EVENTS_DATABASE_URL || process.env.DATABASE_URL || '';
}

function getPool() {
  if (!pool) {
    pool = new Pool({
      connectionString: getConnectionString(),
      max: 8,
      idleTimeoutMillis: 30000,
      connectionTimeoutMillis: 5000,
    });
  }
  return pool;
}

async function ensureSchema() {
  if (!isDbEnabled()) return;
  if (!schemaReadyPromise) {
    schemaReadyPromise = (async () => {
      const sql = `
      CREATE TABLE IF NOT EXISTS offline_events (
        id BIGSERIAL PRIMARY KEY,
        event TEXT NOT NULL,
        payload JSONB,
        experiment JSONB,
        session_id TEXT,
        route TEXT,
        event_at TIMESTAMPTZ NOT NULL,
        user_agent TEXT,
        created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
      );
      CREATE INDEX IF NOT EXISTS idx_offline_events_event_at ON offline_events(event_at DESC);
      CREATE INDEX IF NOT EXISTS idx_offline_events_event ON offline_events(event);
      CREATE INDEX IF NOT EXISTS idx_offline_events_session_id ON offline_events(session_id);

      CREATE TABLE IF NOT EXISTS offline_experiment_config (
        id SMALLINT PRIMARY KEY DEFAULT 1,
        enabled BOOLEAN NOT NULL DEFAULT true,
        trigger_weights JSONB NOT NULL DEFAULT '{"immediate_modal":50,"delayed_modal":50}'::jsonb,
        content_weights JSONB NOT NULL DEFAULT '{"game_modal":50,"prompt_modal":50}'::jsonb,
        force_trigger TEXT,
        force_content TEXT,
        active_game_version TEXT NOT NULL DEFAULT 'v2',
        active_game_script TEXT NOT NULL DEFAULT '/offline-dino/dino-game-fixed.js',
        updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
      );
      ALTER TABLE offline_experiment_config
        ADD COLUMN IF NOT EXISTS active_game_version TEXT NOT NULL DEFAULT 'v2';
      ALTER TABLE offline_experiment_config
        ADD COLUMN IF NOT EXISTS active_game_script TEXT NOT NULL DEFAULT '/offline-dino/dino-game-fixed.js';
      INSERT INTO offline_experiment_config (id)
      VALUES (1)
      ON CONFLICT (id) DO NOTHING;

      CREATE TABLE IF NOT EXISTS offline_sw_config (
        id SMALLINT PRIMARY KEY DEFAULT 1,
        enabled BOOLEAN NOT NULL DEFAULT true,
        emergency_disable BOOLEAN NOT NULL DEFAULT false,
        active_cache_version TEXT NOT NULL DEFAULT 'v3',
        rollback_cache_version TEXT NOT NULL DEFAULT 'v2',
        updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
      );
      INSERT INTO offline_sw_config (id)
      VALUES (1)
      ON CONFLICT (id) DO NOTHING;

      CREATE TABLE IF NOT EXISTS offline_admin_audit_logs (
        id BIGSERIAL PRIMARY KEY,
        actor TEXT NOT NULL,
        action TEXT NOT NULL,
        target TEXT NOT NULL,
        action_source TEXT NOT NULL DEFAULT 'manual_admin_ui',
        execution_result TEXT NOT NULL DEFAULT 'success',
        action_meta JSONB,
        source_ip TEXT NOT NULL,
        before_data JSONB,
        after_data JSONB,
        request_id TEXT,
        created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
      );
      ALTER TABLE offline_admin_audit_logs
        ADD COLUMN IF NOT EXISTS action_source TEXT NOT NULL DEFAULT 'manual_admin_ui';
      ALTER TABLE offline_admin_audit_logs
        ADD COLUMN IF NOT EXISTS execution_result TEXT NOT NULL DEFAULT 'success';
      ALTER TABLE offline_admin_audit_logs
        ADD COLUMN IF NOT EXISTS action_meta JSONB;
      CREATE INDEX IF NOT EXISTS idx_offline_admin_audit_logs_created_at
        ON offline_admin_audit_logs(created_at DESC);
      CREATE INDEX IF NOT EXISTS idx_offline_admin_audit_logs_target_created_at
        ON offline_admin_audit_logs(target, created_at DESC);
      CREATE INDEX IF NOT EXISTS idx_offline_admin_audit_logs_source_created_at
        ON offline_admin_audit_logs(action_source, created_at DESC);

      CREATE TABLE IF NOT EXISTS offline_admin_audit_logs_archive (
        archive_id BIGSERIAL PRIMARY KEY,
        original_id BIGINT NOT NULL,
        actor TEXT NOT NULL,
        action TEXT NOT NULL,
        target TEXT NOT NULL,
        action_source TEXT NOT NULL DEFAULT 'manual_admin_ui',
        execution_result TEXT NOT NULL DEFAULT 'success',
        action_meta JSONB,
        source_ip TEXT NOT NULL,
        before_data JSONB,
        after_data JSONB,
        request_id TEXT,
        created_at TIMESTAMPTZ NOT NULL,
        archived_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
      );
      CREATE INDEX IF NOT EXISTS idx_offline_admin_audit_logs_archive_created_at
        ON offline_admin_audit_logs_archive(created_at DESC);
      CREATE INDEX IF NOT EXISTS idx_offline_admin_audit_logs_archive_source_created_at
        ON offline_admin_audit_logs_archive(action_source, created_at DESC);
      CREATE UNIQUE INDEX IF NOT EXISTS idx_offline_admin_audit_logs_archive_original_id
        ON offline_admin_audit_logs_archive(original_id);

      CREATE TABLE IF NOT EXISTS offline_audit_export_jobs (
        id TEXT PRIMARY KEY,
        actor TEXT NOT NULL,
        source_ip TEXT NOT NULL,
        format TEXT NOT NULL,
        chunk_size INT NOT NULL,
        include_archived BOOLEAN NOT NULL DEFAULT true,
        status TEXT NOT NULL,
        total_rows INT NOT NULL DEFAULT 0,
        total_chunks INT NOT NULL DEFAULT 0,
        retry_count INT NOT NULL DEFAULT 0,
        filters JSONB NOT NULL DEFAULT '{}'::jsonb,
        error_message TEXT,
        processing_started_at TIMESTAMPTZ,
        processing_duration_ms INT,
        created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
        completed_at TIMESTAMPTZ
      );
      ALTER TABLE offline_audit_export_jobs
        ADD COLUMN IF NOT EXISTS retry_count INT NOT NULL DEFAULT 0;
      ALTER TABLE offline_audit_export_jobs
        ADD COLUMN IF NOT EXISTS processing_started_at TIMESTAMPTZ;
      ALTER TABLE offline_audit_export_jobs
        ADD COLUMN IF NOT EXISTS processing_duration_ms INT;
      CREATE INDEX IF NOT EXISTS idx_offline_audit_export_jobs_created_at
        ON offline_audit_export_jobs(created_at DESC);

      CREATE TABLE IF NOT EXISTS offline_audit_export_job_items (
        id BIGSERIAL PRIMARY KEY,
        job_id TEXT NOT NULL REFERENCES offline_audit_export_jobs(id) ON DELETE CASCADE,
        part_no INT NOT NULL,
        offset_rows INT NOT NULL,
        limit_rows INT NOT NULL,
        filename TEXT NOT NULL,
        download_query TEXT NOT NULL,
        created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
        UNIQUE (job_id, part_no)
      );
      CREATE INDEX IF NOT EXISTS idx_offline_audit_export_job_items_job_part
        ON offline_audit_export_job_items(job_id, part_no);

      CREATE TABLE IF NOT EXISTS offline_alert_delivery_jobs (
        id TEXT PRIMARY KEY,
        signature TEXT NOT NULL,
        payload JSONB NOT NULL,
        status TEXT NOT NULL DEFAULT 'pending',
        attempt_count INT NOT NULL DEFAULT 0,
        max_attempts INT NOT NULL DEFAULT 0,
        status_codes JSONB NOT NULL DEFAULT '[]'::jsonb,
        backoff_delays_ms JSONB NOT NULL DEFAULT '[]'::jsonb,
        queue_wait_ms INT,
        processing_duration_ms INT,
        last_error TEXT,
        dead_letter_reason TEXT,
        replayed_by_job_id TEXT,
        replayed_at TIMESTAMPTZ,
        created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
        updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
        delivered_at TIMESTAMPTZ,
        dead_lettered_at TIMESTAMPTZ
      );
      ALTER TABLE offline_alert_delivery_jobs
        ADD COLUMN IF NOT EXISTS replayed_by_job_id TEXT;
      ALTER TABLE offline_alert_delivery_jobs
        ADD COLUMN IF NOT EXISTS replayed_at TIMESTAMPTZ;
      CREATE INDEX IF NOT EXISTS idx_offline_alert_delivery_jobs_status_created_at
        ON offline_alert_delivery_jobs(status, created_at DESC);
      CREATE INDEX IF NOT EXISTS idx_offline_alert_delivery_jobs_signature_created_at
        ON offline_alert_delivery_jobs(signature, created_at DESC);
      `;
      await getPool().query(sql);
    })().catch((error) => {
      schemaReadyPromise = null;
      throw error;
    });
  }
  await schemaReadyPromise;
}

export async function queryDb<T = unknown>(text: string, values: unknown[] = []): Promise<T[]> {
  if (!isDbEnabled()) {
    throw new Error('offline_db_disabled');
  }
  await ensureSchema();
  const result = await getPool().query<T>(text, values);
  await maybeCleanup();
  return result.rows;
}

async function maybeCleanup() {
  if (Date.now() - lastCleanupAt < CLEANUP_INTERVAL_MS) return;
  lastCleanupAt = Date.now();
  const retentionDays = Number(process.env.OFFLINE_EVENTS_RETENTION_DAYS || DEFAULT_RETENTION_DAYS);
  const safeDays = Number.isFinite(retentionDays) ? Math.max(7, Math.min(365, retentionDays)) : DEFAULT_RETENTION_DAYS;
  await getPool().query(`DELETE FROM offline_events WHERE event_at < NOW() - ($1 || ' days')::INTERVAL`, [
    safeDays.toString(),
  ]);
  await maybeArchiveOfflineAuditLogs();
}

async function maybeArchiveOfflineAuditLogs() {
  if (Date.now() - lastAuditArchiveAt < AUDIT_ARCHIVE_INTERVAL_MS) return;
  lastAuditArchiveAt = Date.now();
  const hotRetentionDays = Number(
    process.env.OFFLINE_AUDIT_HOT_RETENTION_DAYS || DEFAULT_AUDIT_HOT_RETENTION_DAYS,
  );
  const archiveRetentionDays = Number(
    process.env.OFFLINE_AUDIT_ARCHIVE_RETENTION_DAYS || DEFAULT_AUDIT_ARCHIVE_RETENTION_DAYS,
  );
  const safeHotDays = Number.isFinite(hotRetentionDays)
    ? Math.max(7, Math.min(365, hotRetentionDays))
    : DEFAULT_AUDIT_HOT_RETENTION_DAYS;
  const safeArchiveDays = Number.isFinite(archiveRetentionDays)
    ? Math.max(safeHotDays, Math.min(3650, archiveRetentionDays))
    : DEFAULT_AUDIT_ARCHIVE_RETENTION_DAYS;

  await getPool().query(
    `
      WITH moved AS (
        SELECT
          id, actor, action, target, action_source, execution_result, action_meta,
          source_ip, before_data, after_data, request_id, created_at
        FROM offline_admin_audit_logs
        WHERE created_at < NOW() - ($1 || ' days')::INTERVAL
        ORDER BY created_at ASC
        LIMIT $2
      ),
      inserted AS (
        INSERT INTO offline_admin_audit_logs_archive (
          original_id, actor, action, target, action_source, execution_result, action_meta,
          source_ip, before_data, after_data, request_id, created_at
        )
        SELECT
          id, actor, action, target, action_source, execution_result, action_meta,
          source_ip, before_data, after_data, request_id, created_at
        FROM moved
        ON CONFLICT DO NOTHING
        RETURNING original_id
      )
      DELETE FROM offline_admin_audit_logs
      WHERE id IN (SELECT original_id FROM inserted)
    `,
    [safeHotDays.toString(), AUDIT_ARCHIVE_BATCH_SIZE],
  );

  await getPool().query(
    `DELETE FROM offline_admin_audit_logs_archive WHERE created_at < NOW() - ($1 || ' days')::INTERVAL`,
    [safeArchiveDays.toString()],
  );
}

export function offlineDbEnabled() {
  return isDbEnabled();
}

