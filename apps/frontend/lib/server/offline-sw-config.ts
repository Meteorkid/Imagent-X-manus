import { offlineDbEnabled, queryDb } from './offline-db';

export interface OfflineSwConfig {
  enabled: boolean;
  emergencyDisable: boolean;
  activeCacheVersion: string;
  rollbackCacheVersion: string;
}

const defaultConfig: OfflineSwConfig = {
  enabled: true,
  emergencyDisable: false,
  activeCacheVersion: 'v3',
  rollbackCacheVersion: 'v2',
};

let inMemoryConfig: OfflineSwConfig = { ...defaultConfig };

function normalizeVersion(value: unknown, fallback: string): string {
  if (typeof value !== 'string') return fallback;
  const trimmed = value.trim();
  if (!/^v\d+$/i.test(trimmed)) return fallback;
  return trimmed.toLowerCase();
}

export async function getOfflineSwConfig(): Promise<OfflineSwConfig> {
  if (!offlineDbEnabled()) return inMemoryConfig;
  const rows = await queryDb<{
    enabled: boolean;
    emergency_disable: boolean;
    active_cache_version: string;
    rollback_cache_version: string;
  }>(`SELECT enabled, emergency_disable, active_cache_version, rollback_cache_version FROM offline_sw_config WHERE id = 1`);

  if (!rows.length) return defaultConfig;
  const row = rows[0];
  return {
    enabled: row.enabled,
    emergencyDisable: row.emergency_disable,
    activeCacheVersion: normalizeVersion(row.active_cache_version, defaultConfig.activeCacheVersion),
    rollbackCacheVersion: normalizeVersion(row.rollback_cache_version, defaultConfig.rollbackCacheVersion),
  };
}

export async function updateOfflineSwConfig(input: Partial<OfflineSwConfig>): Promise<OfflineSwConfig> {
  const current = await getOfflineSwConfig();
  const merged: OfflineSwConfig = {
    enabled: typeof input.enabled === 'boolean' ? input.enabled : current.enabled,
    emergencyDisable:
      typeof input.emergencyDisable === 'boolean' ? input.emergencyDisable : current.emergencyDisable,
    activeCacheVersion: normalizeVersion(input.activeCacheVersion, current.activeCacheVersion),
    rollbackCacheVersion: normalizeVersion(input.rollbackCacheVersion, current.rollbackCacheVersion),
  };

  if (!offlineDbEnabled()) {
    inMemoryConfig = merged;
    return inMemoryConfig;
  }

  await queryDb(
    `
      UPDATE offline_sw_config
      SET enabled = $1,
          emergency_disable = $2,
          active_cache_version = $3,
          rollback_cache_version = $4,
          updated_at = NOW()
      WHERE id = 1
    `,
    [merged.enabled, merged.emergencyDisable, merged.activeCacheVersion, merged.rollbackCacheVersion],
  );
  return merged;
}

export async function rollbackOfflineSw(): Promise<OfflineSwConfig> {
  const current = await getOfflineSwConfig();
  return updateOfflineSwConfig({
    activeCacheVersion: current.rollbackCacheVersion,
    rollbackCacheVersion: current.activeCacheVersion,
  });
}

