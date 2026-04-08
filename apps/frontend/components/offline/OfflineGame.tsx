'use client';

import React, { useState, useEffect, useRef } from 'react';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { Wifi, WifiOff, Gamepad2, RefreshCw, X } from 'lucide-react';

interface OfflineGameProps {
  isVisible: boolean;
  onClose?: () => void;
  onRetry?: () => void;
}

export default function OfflineGame({ isVisible, onClose, onRetry }: OfflineGameProps) {
  const [gameLoaded, setGameLoaded] = useState(false);
  const [gameError, setGameError] = useState<string | null>(null);
  const [showGame, setShowGame] = useState(false);
  const gameContainerRef = useRef<HTMLDivElement>(null);
  const gameInstanceRef = useRef<any>(null);

  // 加载游戏脚本
  useEffect(() => {
    if (isVisible && !gameLoaded) {
      loadGameScript();
    }
  }, [isVisible, gameLoaded]);

  // 加载游戏脚本
  const loadGameScript = async () => {
    try {
      setGameError(null);
      
      // 检查游戏脚本是否已加载
      if (typeof (window as any).DinoGame !== 'undefined') {
        setGameLoaded(true);
        return;
      }

      // 动态加载游戏脚本
      const script = document.createElement('script');
      script.src = '/offline-dino/dino-game-fixed.js';
      script.async = true;
      
      script.onload = () => {
        console.log('[OfflineGame] 游戏脚本加载成功');
        setGameLoaded(true);
        setGameError(null);
      };
      
      script.onerror = () => {
        console.error('[OfflineGame] 游戏脚本加载失败');
        setGameError('游戏脚本加载失败，请刷新页面重试');
      };
      
      document.head.appendChild(script);
      
      return () => {
        if (script.parentNode) {
          script.parentNode.removeChild(script);
        }
      };
    } catch (error) {
      console.error('[OfflineGame] 加载游戏脚本时出错:', error);
      setGameError('加载游戏时发生错误');
    }
  };

  // 启动游戏
  const startGame = () => {
    if (!gameLoaded || !gameContainerRef.current) {
      setGameError('游戏未准备就绪');
      return;
    }

    try {
      // 检查DinoGame类是否存在
      if (typeof (window as any).DinoGame === 'undefined') {
        setGameError('游戏类未加载');
        return;
      }

      // 创建游戏画布
      const canvas = document.createElement('canvas');
      canvas.id = 'gameCanvas';
      canvas.width = gameContainerRef.current.clientWidth;
      canvas.height = gameContainerRef.current.clientHeight;
      canvas.style.width = '100%';
      canvas.style.height = '100%';
      canvas.style.display = 'block';

      // 清空容器并添加画布
      gameContainerRef.current.innerHTML = '';
      gameContainerRef.current.appendChild(canvas);

      // 创建游戏实例
      const DinoGame = (window as any).DinoGame;
      gameInstanceRef.current = new DinoGame();
      
      // 启动游戏
      gameInstanceRef.current.startGame();
      setShowGame(true);
      setGameError(null);
      
      console.log('[OfflineGame] 游戏启动成功');
    } catch (error) {
      console.error('[OfflineGame] 启动游戏时出错:', error);
      setGameError('启动游戏失败: ' + (error instanceof Error ? error.message : '未知错误'));
    }
  };

  // 停止游戏
  const stopGame = () => {
    if (gameInstanceRef.current && typeof gameInstanceRef.current.stopGame === 'function') {
      try {
        gameInstanceRef.current.stopGame();
      } catch (error) {
        console.warn('[OfflineGame] 停止游戏时出错:', error);
      }
    }
    
    if (gameContainerRef.current) {
      gameContainerRef.current.innerHTML = '';
    }
    
    setShowGame(false);
    gameInstanceRef.current = null;
  };

  // 重新加载游戏
  const reloadGame = () => {
    stopGame();
    setGameLoaded(false);
    setGameError(null);
    loadGameScript();
  };

  // 组件卸载时清理
  useEffect(() => {
    return () => {
      stopGame();
    };
  }, []);

  if (!isVisible) {
    return null;
  }

  return (
    <div className="fixed inset-0 z-50 bg-black/80 backdrop-blur-sm flex items-center justify-center p-4">
      <Card className="w-full max-w-4xl max-h-[90vh] overflow-hidden">
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
                <Wifi className="h-3 w-3 mr-1" />
                离线模式
              </Badge>
              {onClose && (
                <Button
                  variant="ghost"
                  size="sm"
                  onClick={onClose}
                  className="text-white hover:bg-white/20"
                >
                  <X className="h-4 w-4" />
                </Button>
              )}
            </div>
          </div>
        </CardHeader>
        
        <CardContent className="p-0">
          {!showGame ? (
            <div className="p-6 text-center">
              {gameError ? (
                <div className="space-y-4">
                  <div className="text-red-600 text-lg font-medium">
                    ❌ {gameError}
                  </div>
                  <div className="flex gap-3 justify-center">
                    <Button onClick={reloadGame} variant="outline">
                      <RefreshCw className="h-4 w-4 mr-2" />
                      重新加载
                    </Button>
                    {onRetry && (
                      <Button onClick={onRetry}>
                        <Wifi className="h-4 w-4 mr-2" />
                        重试连接
                      </Button>
                    )}
                  </div>
                </div>
              ) : (
                <div className="space-y-6">
                  <div className="space-y-4">
                    <div className="text-6xl">👽</div>
                    <h3 className="text-2xl font-bold text-gray-800">
                      外星人小男孩游戏
                    </h3>
                    <p className="text-gray-600 max-w-md mx-auto">
                      帮助小外星人从抑郁状态成长到治愈状态。
                      收集宝石，躲避障碍物，获得高分！
                    </p>
                  </div>
                  
                  <div className="space-y-3">
                    <div className="text-sm text-gray-500">
                      <strong>游戏控制：</strong>
                    </div>
                    <div className="flex flex-wrap gap-2 justify-center text-sm">
                      <Badge variant="outline">空格键 跳跃</Badge>
                      <Badge variant="outline">↓ 下蹲</Badge>
                      <Badge variant="outline">点击屏幕 跳跃</Badge>
                      <Badge variant="outline">双击 全屏</Badge>
                    </div>
                  </div>
                  
                  <div className="space-y-3">
                    {!gameLoaded ? (
                      <div className="flex items-center justify-center gap-2 text-blue-600">
                        <RefreshCw className="h-4 w-4 animate-spin" />
                        正在加载游戏...
                      </div>
                    ) : (
                      <Button onClick={startGame} size="lg" className="px-8">
                        <Gamepad2 className="h-5 w-5 mr-2" />
                        开始游戏
                      </Button>
                    )}
                  </div>
                </div>
              )}
            </div>
          ) : (
            <div className="relative">
              <div className="absolute top-4 right-4 z-10">
                <Button
                  variant="outline"
                  size="sm"
                  onClick={() => setShowGame(false)}
                  className="bg-white/80 backdrop-blur-sm"
                >
                  <X className="h-4 w-4 mr-2" />
                  返回菜单
                </Button>
              </div>
              
              <div 
                ref={gameContainerRef}
                className="w-full h-[600px] bg-gradient-to-b from-blue-100 to-purple-100"
                style={{ minHeight: '600px' }}
              />
            </div>
          )}
        </CardContent>
      </Card>
    </div>
  );
}







