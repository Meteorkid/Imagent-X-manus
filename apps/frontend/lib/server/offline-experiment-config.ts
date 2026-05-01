import { offlineDbEnabled, queryDb } from './offline-db';
import type { ContentVariant, TriggerVariant } from '@/lib/offline-experiment';
import {
  DEFAULT_ACTIVE_GAME_VERSION,
  resolveGameScriptPathByVersion,
  normalizeActiveGameVersion,
  resolveVersionIdFromLegacyScriptPath,
} from '@/lib/offline-game-script';

export interface OfflineExperimentConfig {
  enabled: boolean;
  triggerWeights: Record<TriggerVariant, number>;
  contentWeights: Record<ContentVariant, number>;
  forceTrigger?: TriggerVariant | null;
  forceContent?: ContentVariant | null;
  activeGameVersion: string;
  activeGameScript: string;
}

const defaultConfig: OfflineExperimentConfig = {
  enabled: true,
  triggerWeights: {
    immediate_modal: 50,
    delayed_modal: 50,
  },
  contentWeights: {
    game_modal: 50,
    prompt_modal: 50,
  },
  forceTrigger: null,
  forceContent: null,
  activeGameVersion: DEFAULT_ACTIVE_GAME_VERSION,
  activeGameScript: resolveGameScriptPathByVersion(DEFAULT_ACTIVE_GAME_VERSION),
};

let inMemoryConfig: OfflineExperimentConfig = { ...defaultConfig };

function normalizeWeights<T extends string>(input: Record<T, number>, defaults: Record<T, number>): Record<T, number> {
  const merged = { ...defaults, ...input };
  const fixed: Record<T, number> = { ...merged };
  for (const key of Object.keys(fixed) as T[]) {
    if (!Number.isFinite(fixed[key]) || fixed[key] < 0) fixed[key] = defaults[key];
  }
  return fixed;
}

function deriveVersion(inputVersion: unknown, legacyScript: unknown): string {
  if (typeof inputVersion === 'string' && inputVersion.trim()) {
    return normalizeActiveGameVersion(inputVersion);
  }
  return resolveVersionIdFromLegacyScriptPath(legacyScript);
}

export async function getOfflineExperimentConfig(): Promise<OfflineExperimentConfig> {
  if (!offlineDbEnabled()) {
    const version = deriveVersion(inMemoryConfig.activeGameVersion, inMemoryConfig.activeGameScript);
    return {
      ...defaultConfig,
      ...inMemoryConfig,
      triggerWeights: normalizeWeights(inMemoryConfig.triggerWeights, defaultConfig.triggerWeights),
      contentWeights: normalizeWeights(inMemoryConfig.contentWeights, defaultConfig.contentWeights),
      activeGameVersion: version,
      activeGameScript: resolveGameScriptPathByVersion(version),
    };
  }
  const rows = await queryDb<{
    enabled: boolean;
    trigger_weights: Record<TriggerVariant, number>;
    content_weights: Record<ContentVariant, number>;
    force_trigger: TriggerVariant | null;
    force_content: ContentVariant | null;
    active_game_version: string | null;
    active_game_script: string | null;
  }>(
    `SELECT enabled, trigger_weights, content_weights, force_trigger, force_content, active_game_version, active_game_script FROM offline_experiment_config WHERE id = 1`,
  );

  if (!rows.length) return defaultConfig;
  const row = rows[0];
  const version = deriveVersion(row.active_game_version, row.active_game_script);
  return {
    enabled: row.enabled,
    triggerWeights: normalizeWeights(row.trigger_weights || defaultConfig.triggerWeights, defaultConfig.triggerWeights),
    contentWeights: normalizeWeights(row.content_weights || defaultConfig.contentWeights, defaultConfig.contentWeights),
    forceTrigger: row.force_trigger,
    forceContent: row.force_content,
    activeGameVersion: version,
    activeGameScript: resolveGameScriptPathByVersion(version),
  };
}

export async function updateOfflineExperimentConfig(
  input: Partial<OfflineExperimentConfig>,
): Promise<OfflineExperimentConfig> {
  const current = await getOfflineExperimentConfig();
  const version = deriveVersion(input.activeGameVersion, input.activeGameScript || current.activeGameScript);
  const merged: OfflineExperimentConfig = {
    ...current,
    ...input,
    triggerWeights: normalizeWeights(
      input.triggerWeights || current.triggerWeights,
      defaultConfig.triggerWeights,
    ),
    contentWeights: normalizeWeights(
      input.contentWeights || current.contentWeights,
      defaultConfig.contentWeights,
    ),
    activeGameVersion: version,
    activeGameScript: resolveGameScriptPathByVersion(version),
  };

  if (!offlineDbEnabled()) {
    inMemoryConfig = merged;
    return inMemoryConfig;
  }

  await queryDb(
    `
      UPDATE offline_experiment_config
      SET enabled = $1,
          trigger_weights = $2::jsonb,
          content_weights = $3::jsonb,
          force_trigger = $4,
          force_content = $5,
          active_game_version = $6,
          active_game_script = $7,
          updated_at = NOW()
      WHERE id = 1
    `,
    [
      merged.enabled,
      JSON.stringify(merged.triggerWeights),
      JSON.stringify(merged.contentWeights),
      merged.forceTrigger || null,
      merged.forceContent || null,
      merged.activeGameVersion,
      merged.activeGameScript,
    ],
  );

  return merged;
}

