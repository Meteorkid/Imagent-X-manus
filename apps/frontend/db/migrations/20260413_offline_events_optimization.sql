-- Offline telemetry production migration (PostgreSQL)
-- Run in a migration framework (Flyway/Liquibase/psql) on production/staging.

BEGIN;

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

CREATE TABLE IF NOT EXISTS offline_experiment_config (
  id SMALLINT PRIMARY KEY DEFAULT 1,
  enabled BOOLEAN NOT NULL DEFAULT TRUE,
  trigger_weights JSONB NOT NULL DEFAULT '{"immediate_modal":50,"delayed_modal":50}'::jsonb,
  content_weights JSONB NOT NULL DEFAULT '{"game_modal":50,"prompt_modal":50}'::jsonb,
  force_trigger TEXT,
  force_content TEXT,
  active_game_version TEXT NOT NULL DEFAULT 'v2',
  active_game_script TEXT NOT NULL DEFAULT '/offline-dino/dino-game-fixed.js',
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
INSERT INTO offline_experiment_config (id) VALUES (1) ON CONFLICT (id) DO NOTHING;

CREATE TABLE IF NOT EXISTS offline_sw_config (
  id SMALLINT PRIMARY KEY DEFAULT 1,
  enabled BOOLEAN NOT NULL DEFAULT TRUE,
  emergency_disable BOOLEAN NOT NULL DEFAULT FALSE,
  active_cache_version TEXT NOT NULL DEFAULT 'v3',
  rollback_cache_version TEXT NOT NULL DEFAULT 'v2',
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
INSERT INTO offline_sw_config (id) VALUES (1) ON CONFLICT (id) DO NOTHING;

CREATE TABLE IF NOT EXISTS offline_admin_audit_logs (
  id BIGSERIAL PRIMARY KEY,
  actor TEXT NOT NULL,
  action TEXT NOT NULL,
  target TEXT NOT NULL,
  source_ip TEXT NOT NULL,
  before_data JSONB,
  after_data JSONB,
  request_id TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- B-Tree indexes for frequent filtering/grouping
CREATE INDEX IF NOT EXISTS idx_offline_events_event_at ON offline_events(event_at DESC);
CREATE INDEX IF NOT EXISTS idx_offline_events_event_event_at ON offline_events(event, event_at DESC);
CREATE INDEX IF NOT EXISTS idx_offline_events_session_event_at ON offline_events(session_id, event_at DESC);

-- JSON expression indexes for A/B and reason aggregations
CREATE INDEX IF NOT EXISTS idx_offline_events_trigger_variant
  ON offline_events ((COALESCE(experiment->>'triggerVariant', 'unknown')), event_at DESC);
CREATE INDEX IF NOT EXISTS idx_offline_events_content_variant
  ON offline_events ((COALESCE(experiment->>'contentVariant', 'unknown')), event_at DESC);
CREATE INDEX IF NOT EXISTS idx_offline_events_close_reason
  ON offline_events ((COALESCE(payload->>'reason', 'unknown')))
  WHERE event = 'offline_modal_closed';

-- BRIN index for large append-only time series acceleration
CREATE INDEX IF NOT EXISTS idx_offline_events_event_at_brin
  ON offline_events USING BRIN(event_at);

CREATE INDEX IF NOT EXISTS idx_offline_admin_audit_logs_created_at
  ON offline_admin_audit_logs(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_offline_admin_audit_logs_target_created_at
  ON offline_admin_audit_logs(target, created_at DESC);

-- Retention cleanup function (safe for cron/pg_cron)
CREATE OR REPLACE FUNCTION prune_offline_events(retention_days INTEGER DEFAULT 30)
RETURNS BIGINT
LANGUAGE plpgsql
AS $$
DECLARE
  deleted_count BIGINT;
BEGIN
  DELETE FROM offline_events
   WHERE event_at < NOW() - (retention_days || ' days')::INTERVAL;
  GET DIAGNOSTICS deleted_count = ROW_COUNT;
  RETURN deleted_count;
END;
$$;

COMMIT;

-- Example scheduled cleanup (if pg_cron enabled):
-- SELECT cron.schedule('offline_events_daily_cleanup', '0 3 * * *', $$SELECT prune_offline_events(30);$$);
