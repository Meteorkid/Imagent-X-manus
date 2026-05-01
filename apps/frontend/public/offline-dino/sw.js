const CACHE_PREFIX = 'offline-dino-cache';
const DEFAULT_ACTIVE_VERSION = 'v3';
const DEFAULT_ROLLBACK_VERSION = 'v2';
const OFFLINE_FALLBACK = '/offline-dino/offline.html';
const CONFIG_ENDPOINT = '/api/offline-sw/config';
const CONFIG_REFRESH_INTERVAL_MS = 60 * 1000;
const RUNTIME_CACHE_MAX_ENTRIES = 60;
const RUNTIME_CACHE_MAX_BYTES = 30 * 1024 * 1024;
const METRICS_FLUSH_INTERVAL_MS = 60 * 1000;
const METRICS_FLUSH_MIN_REQUESTS = 10;

/** 仅预缓存默认离线体验；其它游戏脚本版本供开发/配置切换，不列入 install 预缓存 */
const PRECACHE_URLS = [
  '/offline-dino/dino.html',
  '/offline-dino/dino-game-fixed.js',
  '/offline-dino/manifest.json',
  '/offline-dino/offline.html',
  '/offline-dino/verify-offline.html',
];

const runtimeConfig = {
  enabled: true,
  emergencyDisable: false,
  activeCacheVersion: DEFAULT_ACTIVE_VERSION,
  rollbackCacheVersion: DEFAULT_ROLLBACK_VERSION,
  fetchedAt: 0,
};

const swMetrics = {
  requests: 0,
  cacheHits: 0,
  networkFetches: 0,
  fetchFailures: 0,
  lastFlushedAt: 0,
};

function cacheName(version) {
  return `${CACHE_PREFIX}-${version}`;
}

function allowedCaches() {
  return [cacheName(runtimeConfig.activeCacheVersion), cacheName(runtimeConfig.rollbackCacheVersion)];
}

async function notifyAlert(code, detail) {
  const windows = await self.clients.matchAll({ type: 'window', includeUncontrolled: true });
  for (const client of windows) {
    client.postMessage({
      type: 'offline-sw-alert',
      code,
      detail,
      timestamp: Date.now(),
    });
  }
}

async function broadcast(type, detail) {
  const windows = await self.clients.matchAll({ type: 'window', includeUncontrolled: true });
  for (const client of windows) {
    client.postMessage({
      type,
      ...detail,
      timestamp: Date.now(),
    });
  }
}

async function flushMetricsIfNeeded(force = false) {
  const now = Date.now();
  const shouldFlushByCount = swMetrics.requests >= METRICS_FLUSH_MIN_REQUESTS;
  const shouldFlushByTime = now - swMetrics.lastFlushedAt > METRICS_FLUSH_INTERVAL_MS;
  if (!force && !shouldFlushByCount && !shouldFlushByTime) return;
  swMetrics.lastFlushedAt = now;
  const payload = {
    requests: swMetrics.requests,
    cacheHits: swMetrics.cacheHits,
    networkFetches: swMetrics.networkFetches,
    fetchFailures: swMetrics.fetchFailures,
    cacheHitRate: swMetrics.requests > 0 ? swMetrics.cacheHits / swMetrics.requests : 0,
  };
  await broadcast('offline-sw-metrics', payload);
  swMetrics.requests = 0;
  swMetrics.cacheHits = 0;
  swMetrics.networkFetches = 0;
  swMetrics.fetchFailures = 0;
}

async function refreshRuntimeConfig(force = false) {
  const needRefresh = force || Date.now() - runtimeConfig.fetchedAt > CONFIG_REFRESH_INTERVAL_MS;
  if (!needRefresh) return;
  runtimeConfig.fetchedAt = Date.now();
  try {
    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), 2000);
    const response = await fetch(CONFIG_ENDPOINT, {
      method: 'GET',
      cache: 'no-store',
      signal: controller.signal,
    });
    clearTimeout(timeoutId);
    if (!response.ok) {
      await notifyAlert('config_fetch_failed', { status: response.status });
      return;
    }
    const json = await response.json();
    if (!json?.ok || !json?.data) return;
    runtimeConfig.enabled = json.data.enabled !== false;
    runtimeConfig.emergencyDisable = json.data.emergencyDisable === true;
    runtimeConfig.activeCacheVersion = json.data.activeCacheVersion || DEFAULT_ACTIVE_VERSION;
    runtimeConfig.rollbackCacheVersion = json.data.rollbackCacheVersion || DEFAULT_ROLLBACK_VERSION;
  } catch (error) {
    await notifyAlert('config_fetch_error', { message: String(error) });
  }
}

self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(cacheName(runtimeConfig.activeCacheVersion)).then((cache) => cache.addAll(PRECACHE_URLS)),
  );
  self.skipWaiting();
});

async function fromCurrentOrRollback(request) {
  const current = await caches.open(cacheName(runtimeConfig.activeCacheVersion));
  const hit = await current.match(request);
  if (hit) return hit;

  const previous = await caches.open(cacheName(runtimeConfig.rollbackCacheVersion));
  return previous.match(request);
}

async function cacheCurrent(request, response) {
  if (!response || response.status !== 200 || response.type === 'opaque') return;
  const cache = await caches.open(cacheName(runtimeConfig.activeCacheVersion));
  await cache.put(request, response.clone());
  await enforceRuntimeCacheBudget(cache);
}

async function estimateCacheBytes(cache, keys) {
  let total = 0;
  for (const req of keys) {
    const resp = await cache.match(req);
    if (!resp) continue;
    const len = Number(resp.headers.get('content-length') || 0);
    if (Number.isFinite(len) && len > 0) total += len;
  }
  return total;
}

async function enforceRuntimeCacheBudget(cache) {
  const keys = await cache.keys();
  let overflowByEntries = Math.max(0, keys.length - RUNTIME_CACHE_MAX_ENTRIES);
  let overflowByBytes = 0;
  try {
    const totalBytes = await estimateCacheBytes(cache, keys);
    overflowByBytes = Math.max(0, totalBytes - RUNTIME_CACHE_MAX_BYTES);
  } catch (_) {
    overflowByBytes = 0;
  }
  if (!overflowByEntries && !overflowByBytes) return;
  // Cache.keys() 顺序可近似视为最旧到最新，超预算时从最旧开始删。
  for (const req of keys) {
    if (overflowByEntries <= 0 && overflowByBytes <= 0) break;
    const resp = await cache.match(req);
    const len = Number(resp?.headers?.get('content-length') || 0);
    await cache.delete(req);
    overflowByEntries -= 1;
    if (Number.isFinite(len) && len > 0) {
      overflowByBytes -= len;
    }
  }
}

function isOfflineDinoNavigation(request) {
  return request.mode === 'navigate' && new URL(request.url).pathname.startsWith('/offline-dino');
}

self.addEventListener('fetch', (event) => {
  const { request } = event;
  const url = new URL(request.url);
  const isOfflineDinoAsset = url.pathname.startsWith('/offline-dino');

  if (!isOfflineDinoAsset) {
    return;
  }

  event.respondWith(
    (async () => {
      swMetrics.requests += 1;
      await refreshRuntimeConfig(false);
      if (!runtimeConfig.enabled || runtimeConfig.emergencyDisable) {
        swMetrics.networkFetches += 1;
        await flushMetricsIfNeeded();
        return fetch(request);
      }

      // 导航请求优先走网络，失败回退离线页面。
      if (isOfflineDinoNavigation(request)) {
        try {
          const networkResponse = await fetch(request);
          swMetrics.networkFetches += 1;
          await cacheCurrent(request, networkResponse);
          await flushMetricsIfNeeded();
          return networkResponse;
        } catch (error) {
          swMetrics.fetchFailures += 1;
          const fallback = await fromCurrentOrRollback(OFFLINE_FALLBACK);
          if (fallback) {
            swMetrics.cacheHits += 1;
            await flushMetricsIfNeeded();
            return fallback;
          }
          await notifyAlert('navigation_fallback_missing', { pathname: url.pathname });
          await flushMetricsIfNeeded(true);
          throw error;
        }
      }

      // 静态资源采用 cache-first，未命中再回源并写入当前缓存。
      const cacheResponse = await fromCurrentOrRollback(request);
      if (cacheResponse) {
        swMetrics.cacheHits += 1;
        await flushMetricsIfNeeded();
        return cacheResponse;
      }

      try {
        const networkResponse = await fetch(request);
        swMetrics.networkFetches += 1;
        await cacheCurrent(request, networkResponse);
        await flushMetricsIfNeeded();
        return networkResponse;
      } catch (error) {
        swMetrics.fetchFailures += 1;
        await notifyAlert('asset_fetch_failed', { pathname: url.pathname });
        await flushMetricsIfNeeded(true);
        throw error;
      }
    })(),
  );
});

self.addEventListener('activate', (event) => {
  event.waitUntil(
    (async () => {
      await refreshRuntimeConfig(true);
      const cacheNames = await caches.keys();
      const keepSet = new Set(allowedCaches());
      await Promise.all(
        cacheNames.map((cacheName) => {
          if (!cacheName.startsWith(CACHE_PREFIX)) return Promise.resolve();
          if (keepSet.has(cacheName)) return Promise.resolve();
          return caches.delete(cacheName);
        }),
      );
    })(),
  );
  self.clients.claim();
});