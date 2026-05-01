import { NextRequest, NextResponse } from 'next/server';
import { assertAdmin, resolveAdminActor, resolveClientIp } from '@/app/api/_utils/admin-auth';
import { writeOfflineAuditLog } from '@/lib/server/offline-audit-log';
import { notifyOfflineAlert } from '@/lib/server/offline-alert-notifier';

export async function POST(request: NextRequest) {
  const admin = await assertAdmin(request);
  if (!admin.ok) {
    return NextResponse.json({ ok: false, error: admin.reason }, { status: 403 });
  }

  const actor = await resolveAdminActor(request);
  const sourceIp = resolveClientIp(request);

  try {
    const body = (await request.json()) as Record<string, unknown>;
    const alerts = Array.isArray(body.alerts) ? body.alerts : [];
    const stats = typeof body.stats === 'object' && body.stats !== null ? body.stats : {};
    const aggregation =
      typeof body.aggregation === 'object' && body.aggregation !== null ? body.aggregation : {};
    const signature = typeof body.signature === 'string' ? body.signature : `alerts-${Date.now()}`;
    const inAppNotification =
      typeof body.inAppNotification === 'object' && body.inAppNotification !== null
        ? body.inAppNotification
        : {};

    const externalDelivery = await notifyOfflineAlert({
      signature,
      alerts: alerts as Array<{
        code: string;
        level: 'warn' | 'critical';
        message: string;
        currentValue: string;
        threshold: string;
        suggestion: string;
        hitCount?: number;
      }>,
      stats: stats as Record<string, unknown>,
      aggregation: aggregation as Record<string, unknown>,
    });

    await writeOfflineAuditLog({
      actor,
      action: 'alert',
      target: 'offline_download_center_alert',
      actionSource: 'download_center_alert_engine',
      executionResult: externalDelivery.attempted && !externalDelivery.delivered ? 'failed' : 'success',
      actionMeta: {
        actionType: 'download_center_alert',
        signature,
        alertCount: alerts.length,
        alerts,
        stats,
        aggregation,
        channels: {
          inApp: inAppNotification,
          external: externalDelivery,
        },
        endpoint: '/api/offline-admin/audit/alerts',
      },
      sourceIp,
      beforeData: null,
      afterData: {
        signature,
        alertCount: alerts.length,
        aggregation,
        channels: {
          inApp: inAppNotification,
          external: externalDelivery,
        },
      },
      requestId: request.headers.get('x-request-id') || undefined,
    });

    if (externalDelivery.deadLettered) {
      await writeOfflineAuditLog({
        actor,
        action: 'dead_letter',
        target: 'offline_download_center_alert',
        actionSource: 'download_center_alert_engine',
        executionResult: 'failed',
        actionMeta: {
          actionType: 'download_center_dead_letter',
          signature,
          alertCount: alerts.length,
          deadLetterReason: externalDelivery.deadLetterReason || 'retry_exhausted',
          externalDelivery,
          endpoint: '/api/offline-admin/audit/alerts',
        },
        sourceIp,
        beforeData: null,
        afterData: {
          signature,
          alertCount: alerts.length,
          deadLetterReason: externalDelivery.deadLetterReason || 'retry_exhausted',
          queueJobId: externalDelivery.queueJobId,
          retryCount: externalDelivery.retryCount,
        },
        requestId: request.headers.get('x-request-id') || undefined,
      });
    }

    return NextResponse.json({
      ok: true,
      data: {
        externalDelivery,
      },
    });
  } catch (error) {
    try {
      await writeOfflineAuditLog({
        actor,
        action: 'alert',
        target: 'offline_download_center_alert',
        actionSource: 'download_center_alert_engine',
        executionResult: 'failed',
        actionMeta: {
          actionType: 'download_center_alert',
          error: error instanceof Error ? error.message : 'invalid_payload',
          endpoint: '/api/offline-admin/audit/alerts',
        },
        sourceIp,
        beforeData: null,
        afterData: null,
        requestId: request.headers.get('x-request-id') || undefined,
      });
    } catch (_) {
      // ignore
    }
    return NextResponse.json({ ok: false, error: 'invalid_payload' }, { status: 400 });
  }
}
