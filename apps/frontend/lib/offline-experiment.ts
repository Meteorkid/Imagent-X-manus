import {
  DEFAULT_ACTIVE_GAME_VERSION,
  resolveGameScriptPathByVersion,
  normalizeActiveGameVersion,
  resolveVersionIdFromLegacyScriptPath,
} from './offline-game-script';

export type TriggerVariant = 'immediate_modal' | 'delayed_modal';
export type ContentVariant = 'game_modal' | 'prompt_modal';

export interface OfflineExperimentAssignment {
  triggerVariant: TriggerVariant;
  contentVariant: ContentVariant;
}

export interface OfflineExperimentConfig {
  enabled: boolean;
  triggerWeights: Record<TriggerVariant, number>;
  contentWeights: Record<ContentVariant, number>;
  forceTrigger?: TriggerVariant | null;
  forceContent?: ContentVariant | null;
  /** 主应用离线弹窗加载的游戏版本 ID（由注册表映射到脚本 URL） */
  activeGameVersion: string;
  /** 兼容字段：由 activeGameVersion 推导 */
  activeGameScript: string;
}

const STORAGE_KEY = 'offline_experiment_assignment_v1';
const CONFIG_STORAGE_KEY = 'offline_experiment_config_v1';

const defaultConfig: OfflineExperimentConfig = {
  enabled: true,
  triggerWeights: { immediate_modal: 50, delayed_modal: 50 },
  contentWeights: { game_modal: 50, prompt_modal: 50 },
  forceTrigger: null,
  forceContent: null,
  activeGameVersion: DEFAULT_ACTIVE_GAME_VERSION,
  activeGameScript: resolveGameScriptPathByVersion(DEFAULT_ACTIVE_GAME_VERSION),
};

function normalizeConfig(config: OfflineExperimentConfig): OfflineExperimentConfig {
  const version = normalizeActiveGameVersion(
    config.activeGameVersion || resolveVersionIdFromLegacyScriptPath(config.activeGameScript),
  );
  return {
    ...config,
    activeGameVersion: version,
    activeGameScript: resolveGameScriptPathByVersion(version),
  };
}

function getSessionSeed() {
  if (typeof window === 'undefined') return 'server-seed';
  const key = 'offline_session_id';
  const existing = localStorage.getItem(key);
  if (existing) return existing;
  const generated = `offline-${Date.now()}-${Math.random().toString(36).slice(2, 8)}`;
  localStorage.setItem(key, generated);
  return generated;
}

function hashString(input: string) {
  let hash = 2166136261;
  for (let i = 0; i < input.length; i += 1) {
    hash ^= input.charCodeAt(i);
    hash += (hash << 1) + (hash << 4) + (hash << 7) + (hash << 8) + (hash << 24);
  }
  return Math.abs(hash >>> 0);
}

function weightedPick<T extends string>(weights: Record<T, number>, seedKey: string): T {
  const entries = Object.entries(weights) as [T, number][];
  const total = entries.reduce((sum, [, value]) => sum + Math.max(0, value), 0);
  if (total <= 0) return entries[0][0];

  const normalized = hashString(seedKey) % total;
  let cumulative = 0;
  for (const [name, value] of entries) {
    cumulative += Math.max(0, value);
    if (normalized < cumulative) return name;
  }
  return entries[entries.length - 1][0];
}

export function getOfflineExperimentConfigCached(): OfflineExperimentConfig {
  if (typeof window === 'undefined') return defaultConfig;
  const raw = localStorage.getItem(CONFIG_STORAGE_KEY);
  if (!raw) return defaultConfig;
  try {
    const parsed = { ...defaultConfig, ...JSON.parse(raw) } as OfflineExperimentConfig;
    return normalizeConfig(parsed);
  } catch (_) {
    return defaultConfig;
  }
}

export async function fetchOfflineExperimentConfig(): Promise<OfflineExperimentConfig> {
  if (typeof window === 'undefined') return defaultConfig;
  try {
    const response = await fetch('/api/offline-experiments/config', { cache: 'no-store' });
    const json = await response.json();
    if (!json?.ok || !json?.data) return getOfflineExperimentConfigCached();
    const config = normalizeConfig({ ...defaultConfig, ...json.data } as OfflineExperimentConfig);
    localStorage.setItem(CONFIG_STORAGE_KEY, JSON.stringify(config));
    return config;
  } catch (_) {
    return getOfflineExperimentConfigCached();
  }
}

export function getOfflineExperimentAssignment(
  config: OfflineExperimentConfig = getOfflineExperimentConfigCached(),
): OfflineExperimentAssignment {
  if (!config.enabled) {
    return {
      triggerVariant: 'delayed_modal',
      contentVariant: 'game_modal',
    };
  }

  if (typeof window === 'undefined') {
    return {
      triggerVariant: 'delayed_modal',
      contentVariant: 'game_modal',
    };
  }

  if (config.forceTrigger || config.forceContent) {
    const forced: OfflineExperimentAssignment = {
      triggerVariant: config.forceTrigger || 'delayed_modal',
      contentVariant: config.forceContent || 'game_modal',
    };
    localStorage.setItem(STORAGE_KEY, JSON.stringify(forced));
    return forced;
  }

  const cached = localStorage.getItem(STORAGE_KEY);
  if (cached) {
    try {
      return JSON.parse(cached) as OfflineExperimentAssignment;
    } catch (_) {
      // ignore parse error and regenerate
    }
  }

  const seed = getSessionSeed();
  const assignment: OfflineExperimentAssignment = {
    triggerVariant: weightedPick(config.triggerWeights, `${seed}:trigger`),
    contentVariant: weightedPick(config.contentWeights, `${seed}:content`),
  };

  localStorage.setItem(STORAGE_KEY, JSON.stringify(assignment));
  return assignment;
}

