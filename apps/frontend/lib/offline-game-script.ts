/** 离线小游戏脚本版本注册表（用于配置选择与校验） */
export interface OfflineGameScriptVersion {
  id: string;
  label: string;
  scriptPath: string;
  allowOffline: boolean;
  compatible: boolean;
  description?: string;
}

/** 仅允许 /offline-dino/ 下的 .js 文件名，防止路径穿越 */
const SAFE_SCRIPT = /^\/offline-dino\/[a-zA-Z0-9][a-zA-Z0-9._-]*\.js$/;

export const OFFLINE_GAME_SCRIPT_REGISTRY: OfflineGameScriptVersion[] = [
  {
    id: 'v1',
    label: '第一版（精简版）',
    scriptPath: '/offline-dino/dino-game.js',
    allowOffline: false,
    compatible: true,
    description: '早期精简玩法，主要用于程序员对照与回归验证。',
  },
  {
    id: 'v2',
    label: '第二版（完整版）',
    scriptPath: '/offline-dino/dino-game-fixed.js',
    allowOffline: true,
    compatible: true,
    description: '当前默认版本，支持完整玩法与默认离线预缓存。',
  },
];

export const DEFAULT_ACTIVE_GAME_VERSION = 'v2';
export const DEFAULT_ACTIVE_GAME_SCRIPT = '/offline-dino/dino-game-fixed.js';

export function listOfflineGameScriptVersions(): OfflineGameScriptVersion[] {
  return OFFLINE_GAME_SCRIPT_REGISTRY.map((v) => ({ ...v }));
}

export function getOfflineGameVersionById(versionId: string): OfflineGameScriptVersion | undefined {
  return OFFLINE_GAME_SCRIPT_REGISTRY.find((v) => v.id === versionId);
}

export function normalizeActiveGameVersion(input: unknown): string {
  if (typeof input !== 'string') return DEFAULT_ACTIVE_GAME_VERSION;
  const raw = input.trim();
  if (!raw) return DEFAULT_ACTIVE_GAME_VERSION;
  return getOfflineGameVersionById(raw) ? raw : DEFAULT_ACTIVE_GAME_VERSION;
}

export function resolveGameScriptPathByVersion(versionId: unknown): string {
  const id = normalizeActiveGameVersion(versionId);
  return getOfflineGameVersionById(id)?.scriptPath || DEFAULT_ACTIVE_GAME_SCRIPT;
}

export function normalizeActiveGameScript(input: unknown): string {
  if (typeof input !== 'string') return DEFAULT_ACTIVE_GAME_SCRIPT;
  const t = input.trim();
  if (t.length > 160 || !SAFE_SCRIPT.test(t)) return DEFAULT_ACTIVE_GAME_SCRIPT;
  return t;
}

/** 兼容旧配置：如果传的是脚本路径，映射到注册表版本；找不到则回默认。 */
export function resolveVersionIdFromLegacyScriptPath(scriptPath: unknown): string {
  const normalized = normalizeActiveGameScript(scriptPath);
  const matched = OFFLINE_GAME_SCRIPT_REGISTRY.find((v) => v.scriptPath === normalized);
  return matched?.id || DEFAULT_ACTIVE_GAME_VERSION;
}
