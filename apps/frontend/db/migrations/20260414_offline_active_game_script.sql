-- 离线弹窗可切换游戏脚本版本（active_game_version + active_game_script）
BEGIN;

ALTER TABLE offline_experiment_config
  ADD COLUMN IF NOT EXISTS active_game_version TEXT NOT NULL DEFAULT 'v2';

ALTER TABLE offline_experiment_config
  ADD COLUMN IF NOT EXISTS active_game_script TEXT NOT NULL DEFAULT '/offline-dino/dino-game-fixed.js';

COMMIT;
