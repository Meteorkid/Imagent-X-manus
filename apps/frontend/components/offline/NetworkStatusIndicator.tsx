'use client';

import React from 'react';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { Wifi, WifiOff, AlertTriangle, RefreshCw } from 'lucide-react';

interface NetworkStatusIndicatorProps {
  showOfflineGame?: () => void;
  className?: string;
}

export default function NetworkStatusIndicator({ 
  showOfflineGame, 
  className = '' 
}: NetworkStatusIndicatorProps) {
  // 暂时使用模拟状态，避免网络检测冲突
  const isOnline = true; // 模拟在线状态
  const isConnecting = false;
  const errorCount = 0;
  const shouldShowOfflineGame = false;

  // 如果网络正常，不显示指示器
  if (isOnline && errorCount === 0) {
    return null;
  }

  const getStatusColor = () => {
    if (isOnline) return 'bg-green-100 text-green-800 border-green-200';
    if (errorCount === 0) return 'bg-yellow-100 text-yellow-800 border-yellow-200';
    return 'bg-red-100 text-red-800 border-red-200';
  };

  const getStatusIcon = () => {
    if (isConnecting) return <RefreshCw className="h-3 w-3 animate-spin" />;
    if (isOnline) return <Wifi className="h-3 w-3" />;
    if (errorCount === 0) return <AlertTriangle className="h-3 w-3" />;
    return <WifiOff className="h-3 w-3" />;
  };

  const getStatusText = () => {
    if (isConnecting) return '检测中...';
    if (isOnline) return '网络正常';
    if (errorCount === 0) return '网络不稳定';
    return '网络断开';
  };

  const handleRetry = () => {
    // 暂时禁用重试功能
    console.log('重试功能暂时禁用');
  };

  const handleShowGame = () => {
    if (showOfflineGame) {
      showOfflineGame();
    }
  };

  return (
    <div className={`flex items-center gap-2 ${className}`}>
      <Badge 
        variant="outline" 
        className={`${getStatusColor()} border transition-colors`}
      >
        {getStatusIcon()}
        <span className="ml-1">{getStatusText()}</span>
      </Badge>
      
      {!isOnline && (
        <div className="flex items-center gap-2">
          <Button
            variant="outline"
            size="sm"
            onClick={handleRetry}
            className="h-7 px-2 text-xs"
          >
            <RefreshCw className="h-3 w-3 mr-1" />
            重试
          </Button>
          
          {shouldShowOfflineGame && showOfflineGame && (
            <Button
              variant="outline"
              size="sm"
              onClick={handleShowGame}
              className="h-7 px-2 text-xs bg-blue-50 text-blue-700 border-blue-200 hover:bg-blue-100"
            >
              离线游戏
            </Button>
          )}
        </div>
      )}
    </div>
  );
}
