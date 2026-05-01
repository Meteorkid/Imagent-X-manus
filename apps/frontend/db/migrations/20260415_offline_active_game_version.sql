-- 离线小游戏版本注册表配置字段（active_game_version）
BEGIN;

ALTER TABLE offline_experiment_config
  ADD COLUMN IF NOT EXISTS active_game_version TEXT NOT NULL DEFAULT 'v2';

-- 兼容历史数据：若只有脚本路径则映射到版本 ID
UPDATE offline_experiment_config
SET active_game_version = CASE
  WHEN active_game_script = '/offline-dino/dino-game.js' THEN 'v1'
  ELSE 'v2'
END
WHERE active_game_version IS NULL OR active_game_version = '';

COMMIT;
