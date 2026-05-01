'use client';

import React from 'react';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { Wifi, WifiOff, AlertTriangle, RefreshCw } from 'lucide-react';
import type { NetworkState } from '@/hooks/useNetworkStatus';

interface NetworkStatusIndicatorProps {
  state: NetworkState;
  isOnline: boolean;
  isConnecting: boolean;
  errorCount: number;
  lastChecked: Date | null;
  onRetry?: () => void;
  showOfflineGame?: () => void;
  className?: string;
}

export default function NetworkStatusIndicator({ 
  state,
  isOnline,
  isConnecting,
  errorCount,
  lastChecked,
  onRetry,
  showOfflineGame, 
  className = '' 
}: NetworkStatusIndicatorProps) {
  const shouldShowOfflineGame = state === 'offline' && errorCount >= 2;

  // 如果网络正常，不显示指示器
  if (isOnline && errorCount === 0) {
    return null;
  }

  const getStatusColor = () => {
    if (state === 'online') return 'bg-green-100 text-green-800 border-green-200';
    if (state === 'unstable') return 'bg-yellow-100 text-yellow-800 border-yellow-200';
    if (state === 'recovering') return 'bg-blue-100 text-blue-800 border-blue-200';
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
    if (state === 'online') return '网络正常';
    if (state === 'unstable') return '网络不稳定';
    if (state === 'recovering') return '网络恢复中';
    return '网络断开';
  };

  const handleRetry = () => {
    if (onRetry) {
      onRetry();
    }
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
        title={lastChecked ? `最后检测: ${lastChecked.toLocaleTimeString()}` : '尚未检测'}
      >
        {getStatusIcon()}
        <span className="ml-1">{getStatusText()}</span>
      </Badge>
      
      {(state === 'offline' || state === 'unstable') && (
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
