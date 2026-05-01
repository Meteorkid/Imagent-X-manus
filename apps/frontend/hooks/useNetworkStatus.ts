import { useState, useEffect, useCallback, useRef, useReducer } from 'react';
import {
  createInitialNetworkStatus,
  reduceNetworkStatus,
  type NetworkStatus,
  type NetworkStateMachineOptions,
  type NetworkEvent,
} from './networkStateMachine';

export type { NetworkState } from './networkStateMachine';

const isDev = process.env.NODE_ENV !== 'production';

function logNetworkDebug(...args: unknown[]) {
  if (isDev) {
    console.log(...args);
  }
}

function warnNetworkDebug(...args: unknown[]) {
  if (isDev) {
    console.warn(...args);
  }
}

interface NetworkCheckOptions extends NetworkStateMachineOptions {
  checkInterval?: number; // 检查间隔（毫秒）
  timeout?: number; // 超时时间（毫秒）
  healthCheckUrl?: string; // 健康检查URL
}

export function useNetworkStatus(options: NetworkCheckOptions = {}) {
  const {
    checkInterval = 8000,
    timeout = 3000,
    healthCheckUrl = '/api/health',
    failureThreshold = 2,
    recoverySuccessThreshold = 2,
    promptCooldownMs = 60000,
    recoveringMinDwellMs = 1500,
    recoveringFailureTolerance = 1,
  } = options;

  const initialOnline = typeof navigator === 'undefined' ? true : navigator.onLine;
  const now = Date.now();
  const machineOptions: NetworkStateMachineOptions = {
    failureThreshold,
    recoverySuccessThreshold,
    promptCooldownMs,
    recoveringMinDwellMs,
    recoveringFailureTolerance,
  };
  const [status, dispatch] = useReducer(
    (prev: NetworkStatus, event: NetworkEvent) => reduceNetworkStatus(prev, event, machineOptions),
    createInitialNetworkStatus({
      now,
      initialOnline,
      failureThreshold,
    }),
  );
  const [isPageVisible, setIsPageVisible] = useState(
    typeof document === 'undefined' ? true : document.visibilityState === 'visible',
  );
  const statusRef = useRef(status);
  const requestSeqRef = useRef(0);
  const latestHandledSeqRef = useRef(0);
  const activeControllerRef = useRef<AbortController | null>(null);

  // 网络状态检测函数
  const checkNetworkStatus = useCallback(async () => {
    const seq = ++requestSeqRef.current;
    if (activeControllerRef.current) {
      activeControllerRef.current.abort();
    }

    const controller = new AbortController();
    activeControllerRef.current = controller;
    dispatch({ type: 'PROBE_STARTED' });

    let timeoutId: ReturnType<typeof setTimeout> | null = null;
    try {
      timeoutId = setTimeout(() => controller.abort(), timeout);

      const response = await fetch(healthCheckUrl, {
        method: 'HEAD',
        signal: controller.signal,
        cache: 'no-cache',
      });

      if (seq < latestHandledSeqRef.current) return;
      latestHandledSeqRef.current = seq;
      dispatch({ type: 'PROBE_RESULT', ok: response.ok, now: Date.now() });
    } catch (error) {
      if (controller.signal.aborted) return;
      warnNetworkDebug('[NetworkStatus] 网络检测失败:', error);
      if (seq < latestHandledSeqRef.current) return;
      latestHandledSeqRef.current = seq;
      dispatch({ type: 'PROBE_RESULT', ok: false, now: Date.now() });
    } finally {
      if (timeoutId) clearTimeout(timeoutId);
      if (activeControllerRef.current === controller) {
        activeControllerRef.current = null;
      }
    }
  }, [healthCheckUrl, timeout]);

  const acknowledgeOfflinePrompt = useCallback(() => {
    dispatch({ type: 'ACK_OFFLINE_PROMPT', now: Date.now() });
  }, []);

  // 手动检查网络状态
  const manualCheck = useCallback(() => {
    checkNetworkStatus();
  }, [checkNetworkStatus]);

  // 监听浏览器原生网络状态变化
  useEffect(() => {
    const handleOnline = () => {
      logNetworkDebug('[NetworkStatus] 浏览器检测到网络恢复');
      dispatch({ type: 'BROWSER_ONLINE', now: Date.now() });
      checkNetworkStatus();
    };

    const handleOffline = () => {
      logNetworkDebug('[NetworkStatus] 浏览器检测到网络断开');
      dispatch({ type: 'BROWSER_OFFLINE', now: Date.now() });
    };

    const bridgeHandler = (event: Event) => {
      const customEvent = event as CustomEvent<{ online: boolean }>;
      if (customEvent.detail?.online) {
        handleOnline();
      } else {
        handleOffline();
      }
    };

    window.addEventListener('online', handleOnline);
    window.addEventListener('offline', handleOffline);
    window.addEventListener('imagentx:network-change', bridgeHandler as EventListener);
    const visibilityHandler = () => {
      const visible = document.visibilityState === 'visible';
      setIsPageVisible(visible);
      if (visible) {
        // 切回前台时立即探测一次，减少“已恢复但界面迟滞”的体感。
        checkNetworkStatus();
      }
    };
    document.addEventListener('visibilitychange', visibilityHandler);

    return () => {
      window.removeEventListener('online', handleOnline);
      window.removeEventListener('offline', handleOffline);
      window.removeEventListener('imagentx:network-change', bridgeHandler as EventListener);
      document.removeEventListener('visibilitychange', visibilityHandler);
    };
  }, [checkNetworkStatus]);

  const getAdaptiveInterval = useCallback(
    (current: NetworkStatus) => {
      if (!isPageVisible) return Math.max(30000, checkInterval * 2);
      if (current.state === 'online') return checkInterval;
      if (current.state === 'unstable') return Math.max(3000, Math.floor(checkInterval * 0.5));
      if (current.state === 'recovering') return Math.max(2500, Math.floor(checkInterval * 0.4));
      const offlineSteps = [2000, 4000, 8000, 12000];
      return offlineSteps[current.offlinePollStep] || offlineSteps[offlineSteps.length - 1];
    },
    [checkInterval, isPageVisible],
  );

  useEffect(() => {
    statusRef.current = status;
  }, [status]);

  // 动态轮询：按状态调整探测频率，并在后台页降频
  useEffect(() => {
    let timer: ReturnType<typeof setTimeout> | null = null;
    let cancelled = false;

    const schedule = (delay: number) => {
      timer = setTimeout(async () => {
        await checkNetworkStatus();
        if (cancelled) return;
        schedule(getAdaptiveInterval(statusRef.current));
      }, delay);
    };

    schedule(0);
    return () => {
      cancelled = true;
      if (activeControllerRef.current) {
        activeControllerRef.current.abort();
      }
      if (timer) clearTimeout(timer);
    };
  }, [checkNetworkStatus, getAdaptiveInterval]);

  const isOnline = status.state === 'online';
  const isOffline = status.state === 'offline';
  const shouldShowOfflineGame =
    isOffline && status.pendingOfflinePrompt && Date.now() >= status.nextPromptAllowedAt;

  return {
    ...status,
    isOnline,
    isOffline,
    checkNetworkStatus: manualCheck,
    acknowledgeOfflinePrompt,
    shouldShowOfflineGame,
    errorCount: status.consecutiveFailures,
    recoveryCount: status.consecutiveSuccesses,
  };
}
