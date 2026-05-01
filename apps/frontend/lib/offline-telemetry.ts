import { getOfflineExperimentAssignment, getOfflineExperimentConfigCached } from './offline-experiment';

type OfflineEventName =
  | 'offline_state_transition'
  | 'offline_modal_shown'
  | 'offline_modal_closed'
  | 'offline_recovered'
  | 'offline_retry_clicked'
  | 'offline_game_started'
  | 'offline_game_script_load'
  | 'offline_resume_primary_task'
  | 'offline_experiment_assigned'
  | 'offline_resume_business_funnel'
  | 'offline_sw_alert'
  | 'offline_sw_metrics';

export interface OfflineTelemetryEvent {
  event: OfflineEventName;
  payload?: Record<string, unknown>;
}

function getSessionId(): string {
  if (typeof window === 'undefined') return 'server';
  const key = 'offline_session_id';
  const existed = localStorage.getItem(key);
  if (existed) return existed;
  const created = `offline-${Date.now()}-${Math.random().toString(36).slice(2, 8)}`;
  localStorage.setItem(key, created);
  return created;
}

export function logOfflineEvent(event: OfflineTelemetryEvent): void {
  if (typeof window === 'undefined') return;
  const cfg = getOfflineExperimentConfigCached();

  const body = JSON.stringify({
    ...event,
    experiment: getOfflineExperimentAssignment(),
    activeGameVersion: cfg.activeGameVersion,
    activeGameScript: cfg.activeGameScript,
    sessionId: getSessionId(),
    route: `${window.location.pathname}${window.location.search}`,
    timestamp: Date.now(),
    userAgent: navigator.userAgent,
  });

  if (navigator.sendBeacon) {
    const blob = new Blob([body], { type: 'application/json' });
    navigator.sendBeacon('/api/offline-events', blob);
    return;
  }

  fetch('/api/offline-events', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body,
    keepalive: true,
  }).catch(() => {
    // 非关键链路，忽略上报失败
  });
}

