import type { NextRequest } from 'next/server';

function backendUrl() {
  return process.env.BACKEND_URL || 'http://localhost:8088';
}

function collectForwardHeaders(request: NextRequest) {
  const headers = new Headers();
  const cookie = request.headers.get('cookie');
  const authorization = request.headers.get('authorization');
  if (cookie) headers.set('cookie', cookie);
  if (authorization) headers.set('authorization', authorization);
  return headers;
}

export async function assertAdmin(request: NextRequest): Promise<{ ok: true } | { ok: false; reason: string }> {
  try {
    const probeUrl = `${backendUrl()}/api/admin/agents/statistics`;
    const response = await fetch(probeUrl, {
      method: 'GET',
      headers: collectForwardHeaders(request),
      cache: 'no-store',
    });
    if (response.status === 200) return { ok: true };
    if (response.status === 401) return { ok: false, reason: 'unauthorized' };
    if (response.status === 403) return { ok: false, reason: 'forbidden' };
    return { ok: false, reason: `admin_probe_failed_${response.status}` };
  } catch (error) {
    return { ok: false, reason: 'admin_probe_network_error' };
  }
}

export async function resolveAdminActor(request: NextRequest): Promise<string> {
  try {
    const url = `${backendUrl()}/api/accounts/current`;
    const response = await fetch(url, {
      method: 'GET',
      headers: collectForwardHeaders(request),
      cache: 'no-store',
    });
    if (!response.ok) return 'admin:unknown';
    const json = await response.json();
    const data = json?.data || {};
    const id = data?.userId || data?.id || data?.accountId;
    const email = data?.email;
    if (id && email) return `admin:${id}:${email}`;
    if (id) return `admin:${id}`;
    if (email) return `admin:${email}`;
    return 'admin:unknown';
  } catch (_) {
    return 'admin:unknown';
  }
}

export function resolveClientIp(request: NextRequest): string {
  return (
    request.headers.get('x-forwarded-for')?.split(',')[0]?.trim() ||
    request.headers.get('x-real-ip') ||
    'unknown'
  );
}

