import { act, renderHook, waitFor } from '@testing-library/react';
import { useNetworkStatus } from '@/hooks/useNetworkStatus';

type Deferred<T> = {
  promise: Promise<T>;
  resolve: (value: T) => void;
  reject: (reason?: unknown) => void;
};

function createDeferred<T>(): Deferred<T> {
  let resolve!: (value: T) => void;
  let reject!: (reason?: unknown) => void;
  const promise = new Promise<T>((res, rej) => {
    resolve = res;
    reject = rej;
  });
  return { promise, resolve, reject };
}

function mockFetchResponse(ok: boolean) {
  return Promise.resolve({
    ok,
  } as Response);
}

describe('useNetworkStatus state machine', () => {
  let onlineValue = true;

  beforeAll(() => {
    Object.defineProperty(window.navigator, 'onLine', {
      configurable: true,
      get: () => onlineValue,
    });
  });

  beforeEach(() => {
    jest.useRealTimers();
    onlineValue = true;
    jest.clearAllMocks();
    (global.fetch as jest.Mock).mockReset();
  });

  it('ignores stale probe result from older request', async () => {
    const firstManual = createDeferred<Response>();
    const secondManual = createDeferred<Response>();
    let callCount = 0;

    (global.fetch as jest.Mock).mockImplementation(() => {
      callCount += 1;
      if (callCount === 1) return mockFetchResponse(true); // mount probe
      if (callCount === 2) return firstManual.promise; // older request
      if (callCount === 3) return secondManual.promise; // latest request
      return mockFetchResponse(true);
    });

    const { result } = renderHook(() =>
      useNetworkStatus({
        checkInterval: 60000,
        timeout: 1000,
        failureThreshold: 1,
        recoverySuccessThreshold: 1,
      }),
    );

    await waitFor(() => expect(result.current.state).toBe('online'));

    await act(async () => {
      result.current.checkNetworkStatus();
      result.current.checkNetworkStatus();
    });

    await act(async () => {
      secondManual.resolve({ ok: false } as Response);
      await Promise.resolve();
    });

    await waitFor(() => expect(result.current.state).toBe('unstable'));

    await act(async () => {
      firstManual.resolve({ ok: true } as Response);
      await Promise.resolve();
    });

    // 较老请求的成功结果不应把状态回写为 online
    expect(result.current.state).toBe('unstable');
  });

  it('keeps recovering during dwell window, then can fallback to offline', async () => {
    jest.useFakeTimers();
    jest.setSystemTime(new Date('2026-04-14T00:00:00.000Z'));
    onlineValue = false;

    (global.fetch as jest.Mock).mockImplementation(() => mockFetchResponse(false));

    const { result } = renderHook(() =>
      useNetworkStatus({
        checkInterval: 60000,
        timeout: 1000,
        failureThreshold: 1,
        recoverySuccessThreshold: 2,
        recoveringMinDwellMs: 5000,
        recoveringFailureTolerance: 0,
      }),
    );

    await waitFor(() => expect(result.current.state).toBe('offline'));

    await act(async () => {
      onlineValue = true;
      window.dispatchEvent(new Event('online'));
      await Promise.resolve();
    });

    // 在恢复最短停留窗口内，即便探测失败也应保持 recovering
    await waitFor(() => expect(result.current.state).toBe('recovering'));

    await act(async () => {
      jest.advanceTimersByTime(6000);
      await Promise.resolve();
      result.current.checkNetworkStatus();
      await Promise.resolve();
    });

    await waitFor(() => expect(result.current.state).toBe('offline'));
  });

  it('escalates offline poll step and caps at max step', async () => {
    onlineValue = false;
    (global.fetch as jest.Mock).mockImplementation(() => mockFetchResponse(false));

    const { result } = renderHook(() =>
      useNetworkStatus({
        checkInterval: 60000,
        timeout: 1000,
        failureThreshold: 1,
        recoverySuccessThreshold: 1,
      }),
    );

    // 首次探测失败后处于 offline，且开始离线退避阶梯
    await waitFor(() => {
      expect(result.current.state).toBe('offline');
      expect(result.current.offlinePollStep).toBe(1);
    });

    const expectedSteps = [2, 3, 3];
    for (const expected of expectedSteps) {
      await act(async () => {
        result.current.checkNetworkStatus();
        await Promise.resolve();
      });
      await waitFor(() => expect(result.current.offlinePollStep).toBe(expected));
    }
  });
});
