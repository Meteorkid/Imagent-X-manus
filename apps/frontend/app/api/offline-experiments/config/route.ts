import { NextRequest, NextResponse } from 'next/server';
import { getOfflineExperimentConfig, updateOfflineExperimentConfig } from '@/lib/server/offline-experiment-config';
import { assertAdmin, resolveAdminActor, resolveClientIp } from '@/app/api/_utils/admin-auth';
import { writeOfflineAuditLog } from '@/lib/server/offline-audit-log';

function resolveAuditContext(body: Record<string, unknown>) {
  const raw = body.auditContext;
  const ctx = typeof raw === 'object' && raw !== null ? (raw as Record<string, unknown>) : {};
  const source = typeof ctx.source === 'string' && ctx.source.trim() ? ctx.source.trim() : 'manual_admin_ui';
  return { source, meta: ctx };
}

export async function GET() {
  return NextResponse.json({
    ok: true,
    data: await getOfflineExperimentConfig(),
  });
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
    const before = await getOfflineExperimentConfig();
    const updated = await updateOfflineExperimentConfig({
      enabled: typeof body.enabled === 'boolean' ? body.enabled : undefined,
      triggerWeights: body.triggerWeights,
      contentWeights: body.contentWeights,
      forceTrigger: body.forceTrigger ?? undefined,
      forceContent: body.forceContent ?? undefined,
      activeGameVersion: typeof body.activeGameVersion === 'string' ? body.activeGameVersion : undefined,
      activeGameScript: typeof body.activeGameScript === 'string' ? body.activeGameScript : undefined,
    });
    await writeOfflineAuditLog({
      actor,
      action: 'update',
      target: 'offline_experiment_config',
      actionSource: auditSource,
      executionResult: 'success',
      actionMeta: {
        ...auditMeta,
        endpoint: '/api/offline-experiments/config',
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
        target: 'offline_experiment_config',
        actionSource: auditSource,
        executionResult: 'failed',
        actionMeta: {
          ...auditMeta,
          endpoint: '/api/offline-experiments/config',
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

