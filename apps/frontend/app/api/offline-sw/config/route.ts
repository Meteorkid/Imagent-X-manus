import { NextRequest, NextResponse } from 'next/server';
import { getOfflineSwConfig, rollbackOfflineSw, updateOfflineSwConfig } from '@/lib/server/offline-sw-config';
import { assertAdmin, resolveAdminActor, resolveClientIp } from '@/app/api/_utils/admin-auth';
import { writeOfflineAuditLog } from '@/lib/server/offline-audit-log';

function resolveAuditContext(body: Record<string, unknown>) {
  const raw = body.auditContext;
  const ctx = typeof raw === 'object' && raw !== null ? (raw as Record<string, unknown>) : {};
  const source = typeof ctx.source === 'string' && ctx.source.trim() ? ctx.source.trim() : 'manual_admin_ui';
  return { source, meta: ctx };
}

export async function GET() {
  return NextResponse.json({ ok: true, data: await getOfflineSwConfig() });
}

export async function PUT(request: NextRequest) {
  const admin = await assertAdmin(request);
  if (!admin.ok) {
    return NextResponse.json({ ok: false, error: admin.reason }, { status: 403 });
  }
  const actor = await resolveAdminActor(request);
  const sourceIp = resolveClientIp(request);
  let body: Record<string, unknown> = {};
  let auditSource = 'manual_admin_ui';
  let auditMeta: Record<string, unknown> = {};
  try {
    body = (await request.json()) as Record<string, unknown>;
    const auditContext = resolveAuditContext(body);
    auditSource = auditContext.source;
    auditMeta = auditContext.meta;
    const before = await getOfflineSwConfig();
    const updated = await updateOfflineSwConfig({
      enabled: typeof body.enabled === 'boolean' ? body.enabled : undefined,
      emergencyDisable: typeof body.emergencyDisable === 'boolean' ? body.emergencyDisable : undefined,
      activeCacheVersion: body.activeCacheVersion,
      rollbackCacheVersion: body.rollbackCacheVersion,
    });
    await writeOfflineAuditLog({
      actor,
      action: 'update',
      target: 'offline_sw_config',
      actionSource: auditSource,
      executionResult: 'success',
      actionMeta: {
        ...auditMeta,
        endpoint: '/api/offline-sw/config',
      },
      sourceIp,
      beforeData: before,
      afterData: updated,
      requestId: request.headers.get('x-request-id') || undefined,
    });
    return NextResponse.json({ ok: true, data: updated });
  } catch (error) {
    try {
      await writeOfflineAuditLog({
        actor,
        action: 'update',
        target: 'offline_sw_config',
        actionSource: auditSource,
        executionResult: 'failed',
        actionMeta: {
          ...auditMeta,
          endpoint: '/api/offline-sw/config',
          error: error instanceof Error ? error.message : 'invalid_payload',
        },
        sourceIp,
        beforeData: null,
        afterData: {
          error: error instanceof Error ? error.message : 'invalid_payload',
          body,
        },
        requestId: request.headers.get('x-request-id') || undefined,
      });
    } catch (_) {
      // ignore audit failure in error path
    }
    return NextResponse.json({ ok: false, error: 'invalid_payload' }, { status: 400 });
  }
}

export async function POST(request: NextRequest) {
  const admin = await assertAdmin(request);
  if (!admin.ok) {
    return NextResponse.json({ ok: false, error: admin.reason }, { status: 403 });
  }
  const actor = await resolveAdminActor(request);
  const sourceIp = resolveClientIp(request);
  let body: Record<string, unknown> = {};
  let auditSource = 'manual_admin_ui';
  let auditMeta: Record<string, unknown> = {};
  try {
    body = (await request.json()) as Record<string, unknown>;
    const auditContext = resolveAuditContext(body);
    auditSource = auditContext.source;
    auditMeta = auditContext.meta;
    if (body?.action === 'rollback') {
      const before = await getOfflineSwConfig();
      const updated = await rollbackOfflineSw();
      await writeOfflineAuditLog({
        actor,
        action: 'rollback',
        target: 'offline_sw_config',
        actionSource: auditSource,
        executionResult: 'success',
        actionMeta: {
          ...auditMeta,
          endpoint: '/api/offline-sw/config',
        },
        sourceIp,
        beforeData: before,
        afterData: updated,
        requestId: request.headers.get('x-request-id') || undefined,
      });
      return NextResponse.json({ ok: true, data: updated });
    }
    await writeOfflineAuditLog({
      actor,
      action: 'rollback',
      target: 'offline_sw_config',
      actionSource: auditSource,
      executionResult: 'failed',
      actionMeta: {
        ...auditMeta,
        endpoint: '/api/offline-sw/config',
        error: 'unsupported_action',
      },
      sourceIp,
      beforeData: null,
      afterData: {
        error: 'unsupported_action',
        body,
      },
      requestId: request.headers.get('x-request-id') || undefined,
    });
    return NextResponse.json({ ok: false, error: 'unsupported_action' }, { status: 400 });
  } catch (error) {
    try {
      await writeOfflineAuditLog({
        actor,
        action: 'rollback',
        target: 'offline_sw_config',
        actionSource: auditSource,
        executionResult: 'failed',
        actionMeta: {
          ...auditMeta,
          endpoint: '/api/offline-sw/config',
          error: error instanceof Error ? error.message : 'invalid_payload',
        },
        sourceIp,
        beforeData: null,
        afterData: {
          error: error instanceof Error ? error.message : 'invalid_payload',
          body,
        },
        requestId: request.headers.get('x-request-id') || undefined,
      });
    } catch (_) {
      // ignore audit failure in error path
    }
    return NextResponse.json({ ok: false, error: 'invalid_payload' }, { status: 400 });
  }
}

