export type NetworkState = 'online' | 'unstable' | 'offline' | 'recovering';

export interface NetworkStatus {
  state: NetworkState;
  isConnecting: boolean;
  lastChecked: Date | null;
  consecutiveFailures: number;
  consecutiveSuccesses: number;
  lastTransitionAt: Date;
  nextPromptAllowedAt: number;
  pendingOfflinePrompt: boolean;
  offlinePollStep: number;
}

export interface NetworkStateMachineOptions {
  failureThreshold: number;
  recoverySuccessThreshold: number;
  promptCooldownMs: number;
  recoveringMinDwellMs: number;
  recoveringFailureTolerance: number;
}

export type NetworkEvent =
  | { type: 'PROBE_STARTED' }
  | { type: 'PROBE_RESULT'; ok: boolean; now: number }
  | { type: 'BROWSER_ONLINE'; now: number }
  | { type: 'BROWSER_OFFLINE'; now: number }
  | { type: 'ACK_OFFLINE_PROMPT'; now: number };

type TransitionContext = {
  status: NetworkStatus;
  failures: number;
  successes: number;
  now: number;
  options: NetworkStateMachineOptions;
};

type TransitionHandler = (ctx: TransitionContext) => NetworkState;

const probeTransitionTable: Record<NetworkState, Record<'success' | 'failure', NetworkState | TransitionHandler>> = {
  online: {
    success: 'online',
    failure: 'unstable',
  },
  unstable: {
    success: 'online',
    failure: (ctx) =>
      ctx.failures >= ctx.options.failureThreshold ? 'offline' : 'unstable',
  },
  offline: {
    success: (ctx) =>
      ctx.successes >= ctx.options.recoverySuccessThreshold ? 'online' : 'recovering',
    failure: 'offline',
  },
  recovering: {
    success: (ctx) =>
      ctx.successes >= ctx.options.recoverySuccessThreshold ? 'online' : 'recovering',
    failure: (ctx) => {
      const recoveringElapsed = ctx.now - ctx.status.lastTransitionAt.getTime();
      const withinDwellWindow = recoveringElapsed < ctx.options.recoveringMinDwellMs;
      const toleratedFailure = ctx.failures <= ctx.options.recoveringFailureTolerance;
      return withinDwellWindow || toleratedFailure ? 'recovering' : 'offline';
    },
  },
};

function resolveTransition(
  current: NetworkState,
  outcome: 'success' | 'failure',
  ctx: TransitionContext,
): NetworkState {
  const rule = probeTransitionTable[current][outcome];
  return typeof rule === 'function' ? rule(ctx) : rule;
}

export function createInitialNetworkStatus(params: {
  now: number;
  initialOnline: boolean;
  failureThreshold: number;
}): NetworkStatus {
  return {
    state: params.initialOnline ? 'online' : 'offline',
    isConnecting: false,
    lastChecked: null,
    consecutiveFailures: params.initialOnline ? 0 : params.failureThreshold,
    consecutiveSuccesses: params.initialOnline ? 1 : 0,
    lastTransitionAt: new Date(params.now),
    nextPromptAllowedAt: params.now,
    pendingOfflinePrompt: !params.initialOnline,
    offlinePollStep: 0,
  };
}

export function reduceNetworkStatus(
  status: NetworkStatus,
  event: NetworkEvent,
  options: NetworkStateMachineOptions,
): NetworkStatus {
  if (event.type === 'PROBE_STARTED') {
    return {
      ...status,
      isConnecting: true,
    };
  }

  if (event.type === 'BROWSER_ONLINE') {
    return {
      ...status,
      state: status.state === 'offline' ? 'recovering' : 'online',
      consecutiveSuccesses: Math.max(status.consecutiveSuccesses, 1),
      lastTransitionAt: new Date(event.now),
      pendingOfflinePrompt: false,
    };
  }

  if (event.type === 'BROWSER_OFFLINE') {
    return {
      ...status,
      state: 'offline',
      consecutiveFailures: Math.max(status.consecutiveFailures, options.failureThreshold),
      consecutiveSuccesses: 0,
      isConnecting: false,
      lastChecked: new Date(event.now),
      lastTransitionAt: new Date(event.now),
      pendingOfflinePrompt: true,
    };
  }

  if (event.type === 'ACK_OFFLINE_PROMPT') {
    return {
      ...status,
      pendingOfflinePrompt: false,
      nextPromptAllowedAt: event.now + options.promptCooldownMs,
    };
  }

  const failures = event.ok ? 0 : status.consecutiveFailures + 1;
  const successes = event.ok ? status.consecutiveSuccesses + 1 : 0;
  const nextState = resolveTransition(
    status.state,
    event.ok ? 'success' : 'failure',
    {
      status,
      failures,
      successes,
      now: event.now,
      options,
    },
  );

  let pendingOfflinePrompt = status.pendingOfflinePrompt;
  let lastTransitionAt = status.lastTransitionAt;
  let offlinePollStep = status.offlinePollStep;

  if (nextState !== status.state) {
    lastTransitionAt = new Date(event.now);
    if (nextState === 'offline') pendingOfflinePrompt = true;
    if (nextState === 'online') pendingOfflinePrompt = false;
  }

  if (nextState === 'offline') {
    if (status.state === 'offline' && !event.ok) {
      offlinePollStep = Math.min(status.offlinePollStep + 1, 3);
    } else {
      offlinePollStep = 0;
    }
    if (!pendingOfflinePrompt && event.now >= status.nextPromptAllowedAt) {
      pendingOfflinePrompt = true;
    }
  } else {
    offlinePollStep = 0;
  }

  return {
    ...status,
    state: nextState,
    isConnecting: false,
    lastChecked: new Date(event.now),
    consecutiveFailures: failures,
    consecutiveSuccesses: successes,
    lastTransitionAt,
    pendingOfflinePrompt,
    offlinePollStep,
  };
}
