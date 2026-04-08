'use client';

import React, { createContext, useContext, useState, useCallback, useMemo } from 'react';
import OfflineGame from './OfflineGame';
import NetworkStatusIndicator from './NetworkStatusIndicator';

interface OfflineGameContextType {
  showOfflineGame: () => void;
  hideOfflineGame: () => void;
  isOfflineGameVisible: boolean;
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
  const [isOfflineGameVisible, setIsOfflineGameVisible] = useState(false);
  
  // 暂时禁用自动网络检测，避免无限递归
  // const { shouldShowOfflineGame } = useNetworkStatus({
  //   checkInterval: 15000,
  //   timeout: 5000,
  //   maxRetries: 2
  // });

  const showOfflineGame = useCallback(() => {
    setIsOfflineGameVisible(true);
  }, []);

  const hideOfflineGame = useCallback(() => {
    setIsOfflineGameVisible(false);
  }, []);

  // 暂时禁用自动显示逻辑
  // React.useEffect(() => {
  //   if (shouldShowOfflineGame && !isOfflineGameVisible) {
  //     const timer = setTimeout(() => {
  //       setIsOfflineGameVisible(true);
  //     }, 2000);
      
  //     return () => clearTimeout(timer);
  //   }
  // }, [shouldShowOfflineGame, isOfflineGameVisible]);

  // 简化的网络状态指示器组件
  const NetworkStatusIndicatorWrapper = useMemo(() => {
    return function SimpleNetworkStatusIndicator({ className }: { className?: string }) {
      return (
        <NetworkStatusIndicator 
          showOfflineGame={showOfflineGame}
          className={className}
        />
      );
    };
  }, [showOfflineGame]);

  const contextValue: OfflineGameContextType = useMemo(() => ({
    showOfflineGame,
    hideOfflineGame,
    isOfflineGameVisible,
    NetworkStatusIndicator: NetworkStatusIndicatorWrapper
  }), [showOfflineGame, hideOfflineGame, isOfflineGameVisible, NetworkStatusIndicatorWrapper]);

  return (
    <OfflineGameContext.Provider value={contextValue}>
      {children}
      
      {/* 离线游戏组件 */}
      <OfflineGame
        isVisible={isOfflineGameVisible}
        onClose={hideOfflineGame}
        onRetry={() => {
          hideOfflineGame();
        }}
      />
    </OfflineGameContext.Provider>
  );
}
