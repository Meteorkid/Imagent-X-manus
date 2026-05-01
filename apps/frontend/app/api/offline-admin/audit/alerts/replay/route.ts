import { NextRequest, NextResponse } from 'next/server';
import { assertAdmin, resolveAdminActor, resolveClientIp } from '@/app/api/_utils/admin-auth';
import { replayDeadLetterAlertDelivery } from '@/lib/server/offline-alert-notifier';
import { writeOfflineAuditLog } from '@/lib/server/offline-audit-log';

export async function POST(request: NextRequest) {
  const admin = await assertAdmin(request);
  if (!admin.ok) {
    return NextResponse.json({ ok: false, error: admin.reason }, { status: 403 });
  }

  const actor = await resolveAdminActor(request);
  const sourceIp = resolveClientIp(request);
  let body: Record<string, unknown> = {};
  try {
    body = (await request.json()) as Record<string, unknown>;
    const jobId = typeof body.jobId === 'string' ? body.jobId.trim() : '';
    if (!jobId) {
      return NextResponse.json({ ok: false, error: 'job_id_required' }, { status: 400 });
    }

    const replay = await replayDeadLetterAlertDelivery(jobId);
    if (!replay.ok) {
      await writeOfflineAuditLog({
        actor,
        action: 'replay_dead_letter',
        target: 'offline_download_center_alert',
        actionSource: 'manual_admin_ui',
        executionResult: 'failed',
        actionMeta: {
          actionType: 'download_center_dead_letter_replay',
          endpoint: '/api/offline-admin/audit/alerts/replay',
          jobId,
          reason: replay.reason || 'unknown',
        },
        sourceIp,
        beforeData: null,
        afterData: replay,
        requestId: request.headers.get('x-request-id') || undefined,
      });
      return NextResponse.json({ ok: false, error: replay.reason || 'replay_failed' }, { status: 400 });
    }

    await writeOfflineAuditLog({
      actor,
      action: 'replay_dead_letter',
      target: 'offline_download_center_alert',
      actionSource: 'manual_admin_ui',
      executionResult: 'success',
      actionMeta: {
        actionType: 'download_center_dead_letter_replay',
        endpoint: '/api/offline-admin/audit/alerts/replay',
        jobId,
        replayJobId: replay.replayJobId,
      },
      sourceIp,
      beforeData: { jobId },
      afterData: replay,
      requestId: request.headers.get('x-request-id') || undefined,
    });

    return NextResponse.json({
      ok: true,
      data: replay,
    });
  } catch (error) {
    try {
      await writeOfflineAuditLog({
        actor,
        action: 'replay_dead_letter',
        target: 'offline_download_center_alert',
        actionSource: 'manual_admin_ui',
        executionResult: 'failed',
        actionMeta: {
          actionType: 'download_center_dead_letter_replay',
          endpoint: '/api/offline-admin/audit/alerts/replay',
          error: error instanceof Error ? error.message : 'invalid_payload',
        },
        sourceIp,
        beforeData: null,
        afterData: body,
        requestId: request.headers.get('x-request-id') || undefined,
      });
    } catch (_) {
      // ignore
    }
    return NextResponse.json({ ok: false, error: 'invalid_payload' }, { status: 400 });
  }
}
