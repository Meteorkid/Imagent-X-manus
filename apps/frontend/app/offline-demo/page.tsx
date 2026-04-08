'use client';

import React from 'react';
import { useOfflineGame } from '@/components/offline/OfflineGameProvider';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { Wifi, WifiOff, Gamepad2, Info } from 'lucide-react';

export default function OfflineDemoPage() {
  const { showOfflineGame, hideOfflineGame, isOfflineGameVisible, NetworkStatusIndicator } = useOfflineGame();

  return (
    <div className="container mx-auto px-4 py-8 max-w-4xl">
      <div className="space-y-6">
        {/* 页面标题 */}
        <div className="text-center space-y-4">
          <h1 className="text-4xl font-bold text-gray-900">
            离线游戏功能演示
          </h1>
          <p className="text-lg text-gray-600 max-w-2xl mx-auto">
            当网络连接不稳定或断开时，ImagentX 会自动显示离线小游戏，
            让您在等待网络恢复的同时享受游戏乐趣。
          </p>
        </div>

        {/* 网络状态指示器 */}
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <Wifi className="h-5 w-5" />
              网络状态监控
            </CardTitle>
            <CardDescription>
              实时监控网络连接状态，自动检测网络问题
            </CardDescription>
          </CardHeader>
          <CardContent>
            <div className="flex items-center justify-between">
              <div className="text-sm text-gray-600">
                当前状态：
              </div>
              <NetworkStatusIndicator />
            </div>
          </CardContent>
        </Card>

        {/* 功能特性 */}
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <WifiOff className="h-5 w-5 text-orange-500" />
                自动检测
              </CardTitle>
            </CardHeader>
            <CardContent>
              <ul className="space-y-2 text-sm text-gray-600">
                <li>• 每10秒自动检测网络状态</li>
                <li>• 连续2次检测失败后自动显示游戏</li>
                <li>• 支持手动重试网络连接</li>
                <li>• 实时显示网络状态指示器</li>
              </ul>
            </CardContent>
          </Card>

          <Card>
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <Gamepad2 className="h-5 w-5 text-blue-500" />
                离线游戏
              </CardTitle>
            </CardHeader>
            <CardContent>
              <ul className="space-y-2 text-sm text-gray-600">
                <li>• 完全离线运行，无需网络</li>
                <li>• 外星人小男孩跑酷游戏</li>
                <li>• 支持键盘和触摸操作</li>
                <li>• 自动保存游戏进度</li>
              </ul>
            </CardContent>
          </Card>
        </div>

        {/* 手动控制 */}
        <Card>
          <CardHeader>
            <CardTitle>手动控制</CardTitle>
            <CardDescription>
              您可以手动测试离线游戏功能
            </CardDescription>
          </CardHeader>
          <CardContent>
            <div className="flex flex-wrap gap-4">
              <Button 
                onClick={showOfflineGame}
                disabled={isOfflineGameVisible}
                className="bg-blue-600 hover:bg-blue-700"
              >
                <Gamepad2 className="h-4 w-4 mr-2" />
                显示离线游戏
              </Button>
              
              <Button 
                onClick={hideOfflineGame}
                disabled={!isOfflineGameVisible}
                variant="outline"
              >
                隐藏离线游戏
              </Button>
              
              <Button 
                variant="outline"
                onClick={() => {
                  // 模拟网络断开
                  if (typeof window !== 'undefined') {
                    window.dispatchEvent(new Event('offline'));
                  }
                }}
              >
                模拟网络断开
              </Button>
            </div>
          </CardContent>
        </Card>

        {/* 使用说明 */}
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <Info className="h-5 w-5 text-green-500" />
              使用说明
            </CardTitle>
          </CardHeader>
          <CardContent>
            <div className="space-y-4">
              <div>
                <h4 className="font-medium text-gray-900 mb-2">自动模式（推荐）</h4>
                <p className="text-sm text-gray-600">
                  系统会自动监控网络状态，当检测到网络问题时，
                  会在2秒后自动显示离线游戏界面。
                </p>
              </div>
              
              <div>
                <h4 className="font-medium text-gray-900 mb-2">手动模式</h4>
                <p className="text-sm text-gray-600">
                  您也可以点击"显示离线游戏"按钮手动打开游戏，
                  或者使用网络状态指示器中的"离线游戏"按钮。
                </p>
              </div>
              
              <div>
                <h4 className="font-medium text-gray-900 mb-2">游戏控制</h4>
                <div className="flex flex-wrap gap-2 mt-2">
                  <Badge variant="outline">空格键 跳跃</Badge>
                  <Badge variant="outline">↓ 下蹲</Badge>
                  <Badge variant="outline">点击屏幕 跳跃</Badge>
                  <Badge variant="outline">双击 全屏</Badge>
                </div>
              </div>
            </div>
          </CardContent>
        </Card>

        {/* 技术信息 */}
        <Card>
          <CardHeader>
            <CardTitle>技术实现</CardTitle>
            <CardDescription>
              离线游戏功能的技术架构和实现细节
            </CardDescription>
          </CardHeader>
          <CardContent>
            <div className="grid grid-cols-1 md:grid-cols-3 gap-4 text-sm">
              <div className="space-y-2">
                <h5 className="font-medium text-gray-900">前端组件</h5>
                <ul className="text-gray-600 space-y-1">
                  <li>• useNetworkStatus Hook</li>
                  <li>• OfflineGame 组件</li>
                  <li>• NetworkStatusIndicator</li>
                  <li>• OfflineGameProvider</li>
                </ul>
              </div>
              
              <div className="space-y-2">
                <h5 className="font-medium text-gray-900">网络检测</h5>
                <ul className="text-gray-600 space-y-1">
                  <li>• 定期健康检查</li>
                  <li>• 超时控制</li>
                  <li>• 重试机制</li>
                  <li>• 浏览器事件监听</li>
                </ul>
              </div>
              
              <div className="space-y-2">
                <h5 className="font-medium text-gray-900">游戏引擎</h5>
                <ul className="text-gray-600 space-y-1">
                  <li>• Canvas 2D 渲染</li>
                  <li>• Service Worker 缓存</li>
                  <li>• 离线优先设计</li>
                  <li>• 响应式布局</li>
                </ul>
              </div>
            </div>
          </CardContent>
        </Card>
      </div>
    </div>
  );
}







