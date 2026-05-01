'use client';

import React, { createContext, useContext, useState, useCallback, useMemo, useRef } from 'react';
import { usePathname, useRouter } from 'next/navigation';
import OfflineGame from './OfflineGame';
import NetworkStatusIndicator from './NetworkStatusIndicator';
import { useNetworkStatus } from '@/hooks/useNetworkStatus';
import { logOfflineEvent } from '@/lib/offline-telemetry';
import { Button } from '@/components/ui/button';
import { Dialog, DialogContent, DialogDescription, DialogFooter, DialogHeader, DialogTitle } from '@/components/ui/dialog';
import {
  fetchOfflineExperimentConfig,
  getOfflineExperimentAssignment,
  getOfflineExperimentConfigCached,
  type OfflineExperimentAssignment,
  type OfflineExperimentConfig,
} from '@/lib/offline-experiment';

interface OfflineGameContextType {
  showOfflineGame: () => void;
  hideOfflineGame: () => void;
  isOfflineGameVisible: boolean;
  retryNetworkCheck: () => void;
  NetworkStatusIndicator: React.ComponentType<{ className?: string }>;
}

const OfflineGameContext = createContext<OfflineGameContextType | undefined>(undefined);

export function useOfflineGame() {
  const context = useContext(OfflineGameContext);
  if (!context) {
    throw new Error('useOfflineGame must be used within OfflineGameProvider');
  }
  return context;
}

interface OfflineGameProviderProps {
  children: React.ReactNode;
}

export default function OfflineGameProvider({ children }: OfflineGameProviderProps) {
  const router = useRouter();
  const pathname = usePathname();
  const [isOfflineGameVisible, setIsOfflineGameVisible] = useState(false);
  const [isRecoveryPromptVisible, setIsRecoveryPromptVisible] = useState(false);
  const [isAutoReturning, setIsAutoReturning] = useState(false);
  const [expConfig, setExpConfig] = useState<OfflineExperimentConfig>(() => getOfflineExperimentConfigCached());
  const [experiment, setExperiment] = useState<OfflineExperimentAssignment>(() =>
    getOfflineExperimentAssignment(getOfflineExperimentConfigCached()),
  );
  const offlineStartedAtRef = useRef<number | null>(null);
  const prevStateRef = useRef<string | null>(null);
  const showDelayTimerRef = useRef<ReturnType<typeof setTimeout> | null>(null);
  const recoveredAtRef = useRef<number | null>(null);
  const reportedResumeRef = useRef(false);
  const returnRouteRef = useRef('/workspace');
  const autoResumeAttemptedRef = useRef(false);
  const autoResumeTimerRef = useRef<ReturnType<typeof setTimeout> | null>(null);
  const {
    state,
    isOnline,
    isConnecting,
    errorCount,
    lastChecked,
    shouldShowOfflineGame,
    checkNetworkStatus,
    acknowledgeOfflinePrompt,
  } =
    useNetworkStatus({
      checkInterval: 10000,
      timeout: 4000,
      failureThreshold: 2,
      recoverySuccessThreshold: 2,
      promptCooldownMs: 45000,
    });

  const showOfflineGame = useCallback(() => {
    setIsOfflineGameVisible(true);
  }, []);

  const getCurrentRoute = useCallback(() => {
    if (typeof window === 'undefined') {
      return pathname || '/workspace';
    }
    const query = window.location.search || '';
    return `${pathname || '/workspace'}${query}`;
  }, [pathname]);

  const isOfflineRoute = useCallback((route: string) => {
    return route.startsWith('/offline-dino') || route.startsWith('/offline-demo');
  }, []);

  const navigateBackToCapturedContext = useCallback(
    (trigger: 'auto' | 'manual') => {
      const target = returnRouteRef.current || '/workspace';
      const currentRoute = getCurrentRoute();
      if (!target || target === currentRoute) return;
      logOfflineEvent({
        event: 'offline_resume_primary_task',
        payload: {
          trigger,
          target,
          from: currentRoute,
          state,
        },
      });
      router.push(target);
    },
    [getCurrentRoute, router, state],
  );

  const hideOfflineGame = useCallback(() => {
    setIsOfflineGameVisible(false);
    logOfflineEvent({
      event: 'offline_modal_closed',
      payload: {
        reason: 'manual_close',
        state,
      },
    });
  }, [state]);

  const hideOfflineGameByRecovery = useCallback(() => {
    setIsOfflineGameVisible(false);
    logOfflineEvent({
      event: 'offline_modal_closed',
      payload: {
        reason: 'network_recovered',
        state,
      },
    });
  }, [state]);

  const retryNetworkCheck = useCallback(() => {
    logOfflineEvent({
      event: 'offline_retry_clicked',
      payload: { state },
    });
    checkNetworkStatus();
  }, [checkNetworkStatus, state]);

  React.useEffect(() => {
    let active = true;
    fetchOfflineExperimentConfig().then((config) => {
      if (!active) return;
      setExpConfig(config);
      setExperiment(getOfflineExperimentAssignment(config));
    });
    return () => {
      active = false;
    };
  }, []);

  React.useEffect(() => {
    if (shouldShowOfflineGame && !isOfflineGameVisible) {
      if (experiment.triggerVariant === 'delayed_modal') {
        showDelayTimerRef.current = setTimeout(() => {
          setIsOfflineGameVisible(true);
        }, 2500);
      } else {
        setIsOfflineGameVisible(true);
      }
      acknowledgeOfflinePrompt();
      logOfflineEvent({
        event: 'offline_modal_shown',
        payload: {
          state,
          errorCount,
          triggerVariant: experiment.triggerVariant,
          contentVariant: experiment.contentVariant,
        },
      });
    }
    if (!shouldShowOfflineGame && showDelayTimerRef.current) {
      clearTimeout(showDelayTimerRef.current);
      showDelayTimerRef.current = null;
    }
    return () => {
      if (showDelayTimerRef.current) {
        clearTimeout(showDelayTimerRef.current);
        showDelayTimerRef.current = null;
      }
    };
  }, [
    acknowledgeOfflinePrompt,
    shouldShowOfflineGame,
    isOfflineGameVisible,
    state,
    errorCount,
    experiment.triggerVariant,
    experiment.contentVariant,
  ]);

  // 网络恢复后自动收起离线游戏弹窗。
  React.useEffect(() => {
    if (isOnline && isOfflineGameVisible) {
      hideOfflineGameByRecovery();
    }
  }, [isOnline, isOfflineGameVisible, hideOfflineGameByRecovery]);

  // 进入 offline 时记录原路由；进入 recovering 时提示可回到原网站。
  React.useEffect(() => {
    const currentRoute = getCurrentRoute();
    if (state === 'offline') {
      if (!isOfflineRoute(currentRoute)) {
        returnRouteRef.current = currentRoute || '/workspace';
      }
      autoResumeAttemptedRef.current = false;
      setIsAutoReturning(false);
      if (autoResumeTimerRef.current) {
        clearTimeout(autoResumeTimerRef.current);
        autoResumeTimerRef.current = null;
      }
      setIsRecoveryPromptVisible(false);
    }
    if (state === 'recovering') {
      const target = returnRouteRef.current;
      const canAutoResume =
        Boolean(target) &&
        target !== currentRoute &&
        !isOfflineRoute(target) &&
        !autoResumeAttemptedRef.current;

      setIsRecoveryPromptVisible(true);
      if (canAutoResume) {
        autoResumeAttemptedRef.current = true;
        setIsAutoReturning(true);
        logOfflineEvent({
          event: 'offline_resume_business_funnel',
          payload: {
            source: 'auto_resume_scheduled',
            target,
            from: currentRoute,
          },
        });
        autoResumeTimerRef.current = setTimeout(() => {
          setIsAutoReturning(false);
          setIsRecoveryPromptVisible(false);
          navigateBackToCapturedContext('auto');
        }, 1200);
      }
    }
  }, [state, getCurrentRoute, isOfflineRoute, navigateBackToCapturedContext]);

  React.useEffect(() => {
    return () => {
      if (autoResumeTimerRef.current) {
        clearTimeout(autoResumeTimerRef.current);
        autoResumeTimerRef.current = null;
      }
    };
  }, []);

  React.useEffect(() => {
    logOfflineEvent({
      event: 'offline_experiment_assigned',
      payload: experiment,
    });
  }, [experiment]);

  React.useEffect(() => {
    const previous = prevStateRef.current;
    if (previous && previous !== state) {
      logOfflineEvent({
        event: 'offline_state_transition',
        payload: {
          from: previous,
          to: state,
          errorCount,
        },
      });
    }
    prevStateRef.current = state;

    if (state === 'offline' && offlineStartedAtRef.current === null) {
      offlineStartedAtRef.current = Date.now();
    }

    if (state === 'online' && offlineStartedAtRef.current !== null) {
      const offlineDurationMs = Date.now() - offlineStartedAtRef.current;
      recoveredAtRef.current = Date.now();
      reportedResumeRef.current = false;
      logOfflineEvent({
        event: 'offline_recovered',
        payload: {
          offlineDurationMs,
          triggerVariant: experiment.triggerVariant,
          contentVariant: experiment.contentVariant,
        },
      });
      offlineStartedAtRef.current = null;
    }
  }, [state, errorCount, experiment.triggerVariant, experiment.contentVariant]);

  React.useEffect(() => {
    if (!recoveredAtRef.current || reportedResumeRef.current) return;
    const recentlyRecovered = Date.now() - recoveredAtRef.current < 120000;
    if (!recentlyRecovered) return;

    const funnelMatched =
      pathname.startsWith('/explore/chat') ||
      pathname.startsWith('/studio/new') ||
      pathname.startsWith('/agents') ||
      pathname.startsWith('/workspace');
    if (!funnelMatched) return;

    logOfflineEvent({
      event: 'offline_resume_business_funnel',
      payload: {
        pathname,
      },
    });
    reportedResumeRef.current = true;
  }, [pathname]);

  const NetworkStatusIndicatorWrapper = useMemo(() => {
    return function SimpleNetworkStatusIndicator({ className }: { className?: string }) {
      return (
        <NetworkStatusIndicator 
          isOnline={isOnline}
          state={state}
          isConnecting={isConnecting}
          errorCount={errorCount}
          lastChecked={lastChecked}
          onRetry={retryNetworkCheck}
          showOfflineGame={showOfflineGame}
          className={className}
        />
      );
    };
  }, [errorCount, isConnecting, isOnline, lastChecked, retryNetworkCheck, showOfflineGame, state]);

  const contextValue: OfflineGameContextType = useMemo(() => ({
    showOfflineGame,
    hideOfflineGame,
    isOfflineGameVisible,
    retryNetworkCheck,
    NetworkStatusIndicator: NetworkStatusIndicatorWrapper
  }), [showOfflineGame, hideOfflineGame, isOfflineGameVisible, retryNetworkCheck, NetworkStatusIndicatorWrapper]);

  return (
    <OfflineGameContext.Provider value={contextValue}>
      {children}
      
      {/* 离线游戏组件 */}
      <OfflineGame
        isVisible={isOfflineGameVisible}
        gameScriptPath={expConfig.activeGameScript}
        contentMode={experiment.contentVariant === 'game_modal' ? 'game' : 'prompt'}
        onClose={hideOfflineGame}
        onRetry={() => {
          retryNetworkCheck();
        }}
        onStartGame={() => {
          logOfflineEvent({
            event: 'offline_game_started',
            payload: experiment,
          });
        }}
        onResumeTask={() => {
          logOfflineEvent({
            event: 'offline_resume_primary_task',
            payload: experiment,
          });
        }}
      />

      <Dialog open={isRecoveryPromptVisible} onOpenChange={setIsRecoveryPromptVisible}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>网络恢复中</DialogTitle>
            <DialogDescription>
              已检测到网络正在恢复
              {isAutoReturning ? '，即将自动返回离线前的任务页面。' : '，你可以立即返回离线前的任务页面。'}
            </DialogDescription>
          </DialogHeader>
          <DialogFooter>
            <Button
              variant="outline"
              onClick={() => {
                if (autoResumeTimerRef.current) {
                  clearTimeout(autoResumeTimerRef.current);
                  autoResumeTimerRef.current = null;
                  setIsAutoReturning(false);
                }
                setIsRecoveryPromptVisible(false);
              }}
            >
              {isAutoReturning ? '取消自动返回' : '暂不返回'}
            </Button>
            <Button
              onClick={() => {
                if (autoResumeTimerRef.current) {
                  clearTimeout(autoResumeTimerRef.current);
                  autoResumeTimerRef.current = null;
                }
                setIsAutoReturning(false);
                setIsRecoveryPromptVisible(false);
                navigateBackToCapturedContext('manual');
              }}
            >
              返回原网站
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </OfflineGameContext.Provider>
  );
}
