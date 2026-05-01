type Bucket = {
  count: number;
  windowStartMs: number;
};

const buckets = new Map<string, Bucket>();
const MAX_BUCKETS = 5000;

export interface RateLimitResult {
  ok: boolean;
  limit: number;
  remaining: number;
  retryAfterMs: number;
}

export function checkRateLimit(key: string, limit: number, windowMs: number): RateLimitResult {
  const now = Date.now();
  const safeLimit = Math.max(1, Math.floor(limit));
  const safeWindowMs = Math.max(1000, Math.floor(windowMs));
  const bucket = buckets.get(key);

  if (!bucket || now - bucket.windowStartMs >= safeWindowMs) {
    if (buckets.size > MAX_BUCKETS) {
      const oldestKey = buckets.keys().next().value;
      if (oldestKey) buckets.delete(oldestKey);
    }
    buckets.set(key, { count: 1, windowStartMs: now });
    return {
      ok: true,
      limit: safeLimit,
      remaining: safeLimit - 1,
      retryAfterMs: 0,
    };
  }

  if (bucket.count >= safeLimit) {
    return {
      ok: false,
      limit: safeLimit,
      remaining: 0,
      retryAfterMs: Math.max(0, safeWindowMs - (now - bucket.windowStartMs)),
    };
  }

  bucket.count += 1;
  buckets.set(key, bucket);
  return {
    ok: true,
    limit: safeLimit,
    remaining: Math.max(0, safeLimit - bucket.count),
    retryAfterMs: 0,
  };
}
