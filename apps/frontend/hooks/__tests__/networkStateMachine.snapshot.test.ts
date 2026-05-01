import {
  createInitialNetworkStatus,
  reduceNetworkStatus,
  type NetworkEvent,
  type NetworkStateMachineOptions,
  type NetworkStatus,
} from "@/hooks/networkStateMachine";

const options: NetworkStateMachineOptions = {
  failureThreshold: 2,
  recoverySuccessThreshold: 2,
  promptCooldownMs: 60000,
  recoveringMinDwellMs: 1500,
  recoveringFailureTolerance: 1,
};

function toSerializable(status: NetworkStatus) {
  return {
    ...status,
    lastChecked: status.lastChecked ? status.lastChecked.toISOString() : null,
    lastTransitionAt: status.lastTransitionAt.toISOString(),
  };
}

describe("networkStateMachine transition snapshots", () => {
  it("matches core transition matrix snapshots", () => {
    const base = createInitialNetworkStatus({
      now: Date.parse("2026-04-14T00:00:00.000Z"),
      initialOnline: true,
      failureThreshold: options.failureThreshold,
    });

    const scenarios: Array<{
      name: string;
      initial: NetworkStatus;
      event: NetworkEvent;
    }> = [
      {
        name: "online + failure => unstable",
        initial: { ...base, state: "online", consecutiveFailures: 0, consecutiveSuccesses: 3 },
        event: { type: "PROBE_RESULT", ok: false, now: Date.parse("2026-04-14T00:00:10.000Z") },
      },
      {
        name: "unstable + failure below threshold => unstable",
        initial: { ...base, state: "unstable", consecutiveFailures: 0, consecutiveSuccesses: 0 },
        event: { type: "PROBE_RESULT", ok: false, now: Date.parse("2026-04-14T00:00:11.000Z") },
      },
      {
        name: "unstable + failure reach threshold => offline",
        initial: { ...base, state: "unstable", consecutiveFailures: 1, consecutiveSuccesses: 0 },
        event: { type: "PROBE_RESULT", ok: false, now: Date.parse("2026-04-14T00:00:12.000Z") },
      },
      {
        name: "offline + success below recovery threshold => recovering",
        initial: { ...base, state: "offline", consecutiveFailures: 3, consecutiveSuccesses: 0 },
        event: { type: "PROBE_RESULT", ok: true, now: Date.parse("2026-04-14T00:00:13.000Z") },
      },
      {
        name: "offline + success reach threshold => online",
        initial: { ...base, state: "offline", consecutiveFailures: 3, consecutiveSuccesses: 1 },
        event: { type: "PROBE_RESULT", ok: true, now: Date.parse("2026-04-14T00:00:14.000Z") },
      },
      {
        name: "recovering + failure within dwell => recovering",
        initial: {
          ...base,
          state: "recovering",
          consecutiveFailures: 0,
          consecutiveSuccesses: 1,
          lastTransitionAt: new Date("2026-04-14T00:00:15.000Z"),
        },
        event: { type: "PROBE_RESULT", ok: false, now: Date.parse("2026-04-14T00:00:16.000Z") },
      },
      {
        name: "recovering + failure after dwell => offline",
        initial: {
          ...base,
          state: "recovering",
          consecutiveFailures: 2,
          consecutiveSuccesses: 1,
          lastTransitionAt: new Date("2026-04-14T00:00:00.000Z"),
        },
        event: { type: "PROBE_RESULT", ok: false, now: Date.parse("2026-04-14T00:00:20.000Z") },
      },
      {
        name: "ack offline prompt sets cooldown window",
        initial: {
          ...base,
          state: "offline",
          pendingOfflinePrompt: true,
          nextPromptAllowedAt: Date.parse("2026-04-14T00:00:00.000Z"),
        },
        event: { type: "ACK_OFFLINE_PROMPT", now: Date.parse("2026-04-14T00:01:00.000Z") },
      },
    ];

    const result = scenarios.map((s) => ({
      name: s.name,
      next: toSerializable(reduceNetworkStatus(s.initial, s.event, options)),
    }));

    expect(result).toMatchSnapshot();
  });
});
