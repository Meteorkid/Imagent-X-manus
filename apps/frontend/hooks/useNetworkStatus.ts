import { useState, useEffect, useCallback } from 'react';

interface NetworkStatus {
  isOnline: boolean;
  isConnecting: boolean;
  lastChecked: Date | null;
  errorCount: number;
}

interface NetworkCheckOptions {
  checkInterval?: number; // 检查间隔（毫秒）
  timeout?: number; // 超时时间（毫秒）
  healthCheckUrl?: string; // 健康检查URL
  maxRetries?: number; // 最大重试次数
}

export function useNetworkStatus(options: NetworkCheckOptions = {}) {
  const {
    checkInterval = 5000,
    timeout = 3000,
    healthCheckUrl = '/api/health',
    maxRetries = 3
  } = options;

  const [status, setStatus] = useState<NetworkStatus>({
    isOnline: true,
    isConnecting: false,
    lastChecked: null,
    errorCount: 0
  });

  // 网络状态检测函数
  const checkNetworkStatus = useCallback(async () => {
    setStatus(prev => ({ ...prev, isConnecting: true }));

    try {
      const controller = new AbortController();
      const timeoutId = setTimeout(() => controller.abort(), timeout);

      // 尝试访问健康检查端点
      const response = await fetch(healthCheckUrl, {
        method: 'HEAD',
        signal: controller.signal,
        cache: 'no-cache'
      });

      clearTimeout(timeoutId);

      if (response.ok) {
        setStatus({
          isOnline: true,
          isConnecting: false,
          lastChecked: new Date(),
          errorCount: 0
        });
      } else {
        throw new Error(`HTTP ${response.status}`);
      }
    } catch (error) {
      console.warn('[NetworkStatus] 网络检测失败:', error);
      
      setStatus(prev => ({
        isOnline: false,
        isConnecting: false,
        lastChecked: new Date(),
        errorCount: Math.min(prev.errorCount + 1, maxRetries)
      }));
    }
  }, [healthCheckUrl, timeout, maxRetries]);

  // 手动检查网络状态
  const manualCheck = useCallback(() => {
    checkNetworkStatus();
  }, [checkNetworkStatus]);

  // 重置错误计数
  const resetErrorCount = useCallback(() => {
    setStatus(prev => ({ ...prev, errorCount: 0 }));
  }, []);

  // 监听浏览器原生网络状态变化
  useEffect(() => {
    const handleOnline = () => {
      console.log('[NetworkStatus] 浏览器检测到网络恢复');
      setStatus(prev => ({ ...prev, isOnline: true, errorCount: 0 }));
    };

    const handleOffline = () => {
      console.log('[NetworkStatus] 浏览器检测到网络断开');
      setStatus(prev => ({ ...prev, isOnline: false }));
    };

    window.addEventListener('online', handleOnline);
    window.addEventListener('offline', handleOffline);

    return () => {
      window.removeEventListener('online', handleOnline);
      window.removeEventListener('offline', handleOffline);
    };
  }, []);

  // 定期检查网络状态
  useEffect(() => {
    // 初始检查
    checkNetworkStatus();

    // 设置定期检查
    const intervalId = setInterval(checkNetworkStatus, checkInterval);

    return () => clearInterval(intervalId);
  }, [checkNetworkStatus, checkInterval]);

  // 当错误次数达到最大值时，自动标记为离线
  useEffect(() => {
    if (status.errorCount >= maxRetries && status.isOnline) {
      console.log(`[NetworkStatus] 连续${maxRetries}次检测失败，标记为离线状态`);
      setStatus(prev => ({ ...prev, isOnline: false }));
    }
  }, [status.errorCount, status.isOnline, maxRetries]);

  return {
    ...status,
    checkNetworkStatus: manualCheck,
    resetErrorCount,
    // 判断是否应该显示离线游戏
    shouldShowOfflineGame: !status.isOnline && status.errorCount >= maxRetries
  };
}







