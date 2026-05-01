(() => {
  if (typeof window === "undefined" || window.__imagentxOfflineBridgeInitialized) {
    return;
  }
  window.__imagentxOfflineBridgeInitialized = true;

  const HEALTH_ENDPOINT = "/api/health";
  const CHECK_INTERVAL_MS = 15000;
  let destroyed = false;
  let currentOnline = navigator.onLine;
  let intervalId = null;

  function emitNetworkChange(online, source) {
    window.dispatchEvent(
      new CustomEvent("imagentx:network-change", {
        detail: {
          online,
          source,
          timestamp: Date.now(),
        },
      }),
    );
  }

  function sendAlertTelemetry(code, detail) {
    const body = JSON.stringify({
      event: "offline_sw_alert",
      payload: { code, detail },
      timestamp: Date.now(),
      route: window.location.pathname,
      userAgent: navigator.userAgent,
    });
    if (navigator.sendBeacon) {
      const blob = new Blob([body], { type: "application/json" });
      navigator.sendBeacon("/api/offline-events", blob);
      return;
    }
    fetch("/api/offline-events", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body,
      keepalive: true,
    }).catch(() => {});
  }

  function sendMetricsTelemetry(payload) {
    const body = JSON.stringify({
      event: "offline_sw_metrics",
      payload,
      timestamp: Date.now(),
      route: window.location.pathname,
      userAgent: navigator.userAgent,
    });
    if (navigator.sendBeacon) {
      const blob = new Blob([body], { type: "application/json" });
      navigator.sendBeacon("/api/offline-events", blob);
      return;
    }
    fetch("/api/offline-events", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body,
      keepalive: true,
    }).catch(() => {});
  }

  async function probeHealth() {
    if (destroyed) return;
    const controller = new AbortController();
    const timeoutId = window.setTimeout(() => controller.abort(), 3000);

    try {
      const response = await fetch(HEALTH_ENDPOINT, {
        method: "HEAD",
        cache: "no-cache",
        signal: controller.signal,
      });
      const nextOnline = response.ok;
      if (nextOnline !== currentOnline) {
        currentOnline = nextOnline;
        emitNetworkChange(nextOnline, "health-check");
      }
    } catch (_) {
      if (currentOnline) {
        currentOnline = false;
        emitNetworkChange(false, "health-check");
      }
    } finally {
      window.clearTimeout(timeoutId);
    }
  }

  const onlineHandler = () => {
    currentOnline = true;
    emitNetworkChange(true, "browser-event");
  };

  const offlineHandler = () => {
    currentOnline = false;
    emitNetworkChange(false, "browser-event");
  };

  window.addEventListener("online", onlineHandler);
  window.addEventListener("offline", offlineHandler);
  if (navigator.serviceWorker) {
    navigator.serviceWorker.addEventListener("message", (event) => {
      const data = event.data;
      if (!data) return;
      if (data.type === "offline-sw-alert") {
        sendAlertTelemetry(data.code, data.detail || {});
        return;
      }
      if (data.type === "offline-sw-metrics") {
        const requests = typeof data.requests === "number" ? data.requests : 0;
        const cacheHits = typeof data.cacheHits === "number" ? data.cacheHits : 0;
        const networkFetches = typeof data.networkFetches === "number" ? data.networkFetches : 0;
        const fetchFailures = typeof data.fetchFailures === "number" ? data.fetchFailures : 0;
        const cacheHitRate = typeof data.cacheHitRate === "number" ? data.cacheHitRate : 0;
        sendMetricsTelemetry({
          requests,
          cacheHits,
          networkFetches,
          fetchFailures,
          cacheHitRate,
        });
        if (requests > 0) {
          const failureRate = fetchFailures / requests;
          if (failureRate > 0.02) {
            sendAlertTelemetry("sw_fetch_failure_rate_high", {
              failureRate,
              requests,
              fetchFailures,
            });
          }
          if (requests >= 20 && cacheHitRate < 0.6) {
            sendAlertTelemetry("sw_cache_hit_rate_low", {
              cacheHitRate,
              requests,
              cacheHits,
              networkFetches,
            });
          }
        }
      }
    });
  }
  intervalId = window.setInterval(probeHealth, CHECK_INTERVAL_MS);
  probeHealth();

  window.ImagentXOfflineGame = {
    checkNow: probeHealth,
    destroy: () => {
      if (destroyed) return;
      destroyed = true;
      if (intervalId) {
        window.clearInterval(intervalId);
      }
      window.removeEventListener("online", onlineHandler);
      window.removeEventListener("offline", offlineHandler);
    },
  };
})();
