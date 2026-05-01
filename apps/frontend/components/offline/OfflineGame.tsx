'use client';

import React, { useState, useEffect, useRef, useCallback } from 'react';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { Wifi, WifiOff, Gamepad2, RefreshCw, X } from 'lucide-react';
import {
  DEFAULT_ACTIVE_GAME_SCRIPT,
  normalizeActiveGameScript,
  resolveVersionIdFromLegacyScriptPath,
} from '@/lib/offline-game-script';
import { logOfflineEvent } from '@/lib/offline-telemetry';

const SCRIPT_ID = 'offline-dino-game-script';
const scriptRuntime = {
  loadedSrc: '' as string,
  loadingPromise: null as Promise<void> | null,
};

type DinoGameCtor = new () => { startGame: () => void; stopGame?: () => void };

function ensureDinoScriptLoaded(src: string): Promise<void> {
  const win = window as unknown as { DinoGame?: DinoGameCtor };
  if (scriptRuntime.loadedSrc === src && typeof win.DinoGame !== 'undefined') {
    return Promise.resolve();
  }
  // class DinoGame 在同一页面上下文里无法重复声明；切换脚本需刷新页面。
  if (scriptRuntime.loadedSrc && scriptRuntime.loadedSrc !== src) {
    return Promise.reject(new Error('当前页面已加载其他游戏脚本，切换版本请刷新页面后重试'));
  }
  if (scriptRuntime.loadingPromise) {
    return scriptRuntime.loadingPromise;
  }

  scriptRuntime.loadingPromise = new Promise<void>((resolve, reject) => {
    const existing = document.getElementById(SCRIPT_ID) as HTMLScriptElement | null;
    if (existing && existing.src.endsWith(src) && typeof win.DinoGame !== 'undefined') {
      scriptRuntime.loadedSrc = src;
      scriptRuntime.loadingPromise = null;
      resolve();
      return;
    }

    const script = existing || document.createElement('script');
    script.id = SCRIPT_ID;
    script.async = true;
    script.src = src;
    script.onload = () => {
      scriptRuntime.loadedSrc = src;
      scriptRuntime.loadingPromise = null;
      resolve();
    };
    script.onerror = () => {
      scriptRuntime.loadingPromise = null;
      reject(new Error('游戏脚本加载失败'));
    };
    if (!existing) {
      document.head.appendChild(script);
    }
  });

  return scriptRuntime.loadingPromise;
}

interface OfflineGameProps {
  isVisible: boolean;
  contentMode?: 'game' | 'prompt';
  /** 例如 /offline-dino/dino-game-fixed.js，由实验配置下发 */
  gameScriptPath?: string;
  onClose?: () => void;
  onRetry?: () => void;
  onStartGame?: () => void;
  onResumeTask?: () => void;
}

export default function OfflineGame({
  isVisible,
  contentMode = 'game',
  gameScriptPath = DEFAULT_ACTIVE_GAME_SCRIPT,
  onClose,
  onRetry,
  onStartGame,
  onResumeTask,
}: OfflineGameProps) {
  const [gameLoaded, setGameLoaded] = useState(false);
  const [gameError, setGameError] = useState<string | null>(null);
  const [showGame, setShowGame] = useState(false);
  const [activeScriptSrc, setActiveScriptSrc] = useState<string>(DEFAULT_ACTIVE_GAME_SCRIPT);
  const [fallbackNotice, setFallbackNotice] = useState<string | null>(null);
  const gameContainerRef = useRef<HTMLDivElement>(null);
  const gameInstanceRef = useRef<{ stopGame?: () => void } | null>(null);

  const resolvedScriptSrc = normalizeActiveGameScript(gameScriptPath);

  const stopGameInstance = useCallback(() => {
    if (gameInstanceRef.current && typeof gameInstanceRef.current.stopGame === 'function') {
      try {
        gameInstanceRef.current.stopGame();
      } catch {
        // ignore
      }
    }
    gameInstanceRef.current = null;
    if (gameContainerRef.current) {
      gameContainerRef.current.innerHTML = '';
    }
    setShowGame(false);
  }, []);

  useEffect(() => {
    if (contentMode !== 'game' || !isVisible) return;

    setGameError(null);
    setGameLoaded(false);
    setShowGame(false);
    setFallbackNotice(null);
    stopGameInstance();
    let active = true;
    ensureDinoScriptLoaded(resolvedScriptSrc)
      .then(() => {
        if (!active) return;
        setActiveScriptSrc(resolvedScriptSrc);
        setGameLoaded(true);
        logOfflineEvent({
          event: 'offline_game_script_load',
          payload: {
            source: 'initial',
            success: true,
            requestedScript: resolvedScriptSrc,
            effectiveScript: resolvedScriptSrc,
            fallbackUsed: false,
          },
        });
      })
      .catch(async (error) => {
        if (!active) return;
        if (resolvedScriptSrc !== DEFAULT_ACTIVE_GAME_SCRIPT) {
          try {
            await ensureDinoScriptLoaded(DEFAULT_ACTIVE_GAME_SCRIPT);
            if (!active) return;
            setActiveScriptSrc(DEFAULT_ACTIVE_GAME_SCRIPT);
            setGameLoaded(true);
            setFallbackNotice('当前版本不可用，已自动切换到默认版本（v2）。');
            logOfflineEvent({
              event: 'offline_game_script_load',
              payload: {
                source: 'initial',
                success: false,
                requestedScript: resolvedScriptSrc,
                effectiveScript: DEFAULT_ACTIVE_GAME_SCRIPT,
                fallbackUsed: true,
                error: error instanceof Error ? error.message : 'script_load_failed',
              },
            });
            return;
          } catch (_) {
            // fallback also failed, continue to error
          }
        }
        logOfflineEvent({
          event: 'offline_game_script_load',
          payload: {
            source: 'initial',
            success: false,
            requestedScript: resolvedScriptSrc,
            effectiveScript: resolvedScriptSrc,
            fallbackUsed: false,
            error: error instanceof Error ? error.message : 'script_load_failed',
          },
        });
        setGameError(error instanceof Error ? error.message : '游戏脚本加载失败，请重试');
      });

    return () => {
      active = false;
      stopGameInstance();
    };
  }, [isVisible, contentMode, resolvedScriptSrc, stopGameInstance]);

  const startGame = () => {
    onStartGame?.();
    if (!gameLoaded || !gameContainerRef.current) {
      setGameError('游戏未准备就绪');
      return;
    }

    try {
      const DinoGameCtor = (window as unknown as { DinoGame?: new () => { startGame: () => void; stopGame?: () => void } })
        .DinoGame;
      if (typeof DinoGameCtor === 'undefined') {
        setGameError('游戏类未加载');
        return;
      }

      const canvas = document.createElement('canvas');
      canvas.id = 'gameCanvas';
      canvas.width = gameContainerRef.current.clientWidth;
      canvas.height = gameContainerRef.current.clientHeight;
      canvas.style.width = '100%';
      canvas.style.height = '100%';
      canvas.style.display = 'block';

      gameContainerRef.current.innerHTML = '';
      gameContainerRef.current.appendChild(canvas);

      gameInstanceRef.current = new DinoGameCtor();
      gameInstanceRef.current.startGame();
      setShowGame(true);
      setGameError(null);
    } catch (error) {
      setGameError('启动游戏失败: ' + (error instanceof Error ? error.message : '未知错误'));
    }
  };

  const reloadGame = () => {
    stopGameInstance();
    setGameError(null);
    setFallbackNotice(null);
    ensureDinoScriptLoaded(activeScriptSrc || resolvedScriptSrc)
      .then(() => {
        const script = activeScriptSrc || resolvedScriptSrc;
        setGameLoaded(true);
        logOfflineEvent({
          event: 'offline_game_script_load',
          payload: {
            source: 'reload',
            success: true,
            requestedScript: script,
            effectiveScript: script,
            fallbackUsed: false,
          },
        });
      })
      .catch((error) => {
        logOfflineEvent({
          event: 'offline_game_script_load',
          payload: {
            source: 'reload',
            success: false,
            requestedScript: activeScriptSrc || resolvedScriptSrc,
            effectiveScript: activeScriptSrc || resolvedScriptSrc,
            fallbackUsed: false,
            error: error instanceof Error ? error.message : 'script_reload_failed',
          },
        });
        setGameError(error instanceof Error ? error.message : '重新加载失败');
      });
  };

  if (!isVisible) {
    return null;
  }

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/80 p-4 backdrop-blur-sm">
      <Card className="max-h-[90vh] w-full max-w-4xl overflow-hidden">
        <CardHeader className="bg-gradient-to-r from-blue-600 to-purple-600 text-white">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-3">
              <WifiOff className="h-6 w-6" />
              <div>
                <CardTitle className="text-xl">网络连接已断开</CardTitle>
                <CardDescription className="text-blue-100">
                  在等待网络恢复的同时，来玩个小游戏吧！
                </CardDescription>
              </div>
            </div>
            <div className="flex items-center gap-2">
              <Badge variant="secondary" className="bg-white/20 text-white">
                <Wifi className="mr-1 h-3 w-3" />
                离线模式
              </Badge>
              {onClose && (
                <Button variant="ghost" size="sm" onClick={onClose} className="text-white hover:bg-white/20">
                  <X className="h-4 w-4" />
                </Button>
              )}
            </div>
          </div>
        </CardHeader>

        <CardContent className="p-0">
          {contentMode === 'prompt' ? (
            <div className="p-8 text-center">
              <div className="space-y-5">
                <div className="text-5xl">🌐</div>
                <h3 className="text-2xl font-bold text-gray-800">网络暂时不可用</h3>
                <p className="mx-auto max-w-md text-gray-600">
                  我们会持续检测网络恢复。你可以继续等待并重试连接，恢复后会自动回到正常体验。
                </p>
                <div className="flex flex-wrap justify-center gap-3">
                  {onRetry && (
                    <Button onClick={onRetry}>
                      <RefreshCw className="mr-2 h-4 w-4" />
                      重试连接
                    </Button>
                  )}
                  <Button
                    variant="outline"
                    onClick={() => {
                      onResumeTask?.();
                      onClose?.();
                    }}
                  >
                    继续当前任务
                  </Button>
                </div>
              </div>
            </div>
          ) : !showGame ? (
            <div className="p-6 text-center">
              {gameError ? (
                <div className="space-y-4">
                  <div className="text-lg font-medium text-red-600">❌ {gameError}</div>
                  <div className="flex justify-center gap-3">
                    <Button onClick={reloadGame} variant="outline">
                      <RefreshCw className="mr-2 h-4 w-4" />
                      重新加载
                    </Button>
                    {onRetry && (
                      <Button onClick={onRetry}>
                        <Wifi className="mr-2 h-4 w-4" />
                        重试连接
                      </Button>
                    )}
                  </div>
                </div>
              ) : (
                <div className="space-y-6">
                  <div className="space-y-4">
                    <div className="text-6xl">👽</div>
                    <h3 className="text-2xl font-bold text-gray-800">外星人小男孩游戏</h3>
                    <p className="mx-auto max-w-md text-gray-600">
                      帮助小外星人从抑郁状态成长到治愈状态。 收集宝石，躲避障碍物，获得高分！
                    </p>
                  </div>

                  <div className="space-y-3">
                    <div className="text-sm text-gray-500">
                      <strong>游戏控制：</strong>
                    </div>
                    <div className="flex flex-wrap justify-center gap-2 text-sm">
                      <Badge variant="outline">空格键 跳跃</Badge>
                      <Badge variant="outline">↓ 下蹲</Badge>
                      <Badge variant="outline">点击屏幕 跳跃</Badge>
                      <Badge variant="outline">双击 全屏</Badge>
                    </div>
                  </div>

                  {fallbackNotice && (
                    <div className="rounded-md border border-yellow-200 bg-yellow-50 p-2 text-xs text-yellow-800">
                      {fallbackNotice}
                    </div>
                  )}

                  <p className="text-xs text-muted-foreground">
                    当前脚本：<span className="font-mono">{activeScriptSrc}</span>
                    <span className="ml-2">版本：{resolveVersionIdFromLegacyScriptPath(activeScriptSrc)}</span>
                  </p>

                  <div className="space-y-3">
                    {!gameLoaded ? (
                      <div className="flex items-center justify-center gap-2 text-blue-600">
                        <RefreshCw className="h-4 w-4 animate-spin" />
                        正在加载游戏...
                      </div>
                    ) : (
                      <Button onClick={startGame} size="lg" className="px-8">
                        <Gamepad2 className="mr-2 h-5 w-5" />
                        开始游戏
                      </Button>
                    )}
                  </div>
                </div>
              )}
            </div>
          ) : (
            <div className="relative">
              <div className="absolute right-4 top-4 z-10">
                <Button
                  variant="outline"
                  size="sm"
                  onClick={() => {
                    stopGameInstance();
                  }}
                  className="bg-white/80 backdrop-blur-sm"
                >
                  <X className="mr-2 h-4 w-4" />
                  返回菜单
                </Button>
              </div>

              <div
                ref={gameContainerRef}
                className="h-[600px] w-full bg-gradient-to-b from-blue-100 to-purple-100"
                style={{ minHeight: '600px' }}
              />
            </div>
          )}
        </CardContent>
      </Card>
    </div>
  );
}
