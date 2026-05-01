import { NextRequest, NextResponse } from 'next/server';
import { assertAdmin, resolveClientIp } from '@/app/api/_utils/admin-auth';
import { listOfflineAuditLogs, listOfflineAuditLogsForExport } from '@/lib/server/offline-audit-log';
import { checkRateLimit } from '@/lib/server/api-rate-limit';

function toCsvValue(value: unknown): string {
  const raw = value == null ? '' : typeof value === 'string' ? value : JSON.stringify(value);
  const escaped = raw.replace(/"/g, '""');
  return `"${escaped}"`;
}

export async function GET(request: NextRequest) {
  const admin = await assertAdmin(request);
  if (!admin.ok) {
    return NextResponse.json({ ok: false, error: admin.reason }, { status: 403 });
  }

  const { searchParams } = new URL(request.url);
  const page = Number(searchParams.get('page') || '1');
  const pageSize = Number(searchParams.get('pageSize') || '20');
  const target = searchParams.get('target')?.trim() || undefined;
  const action = searchParams.get('action')?.trim() || undefined;
  const actionSource = searchParams.get('actionSource')?.trim() || undefined;
  const executionResult = (searchParams.get('executionResult')?.trim() || undefined) as
    | 'success'
    | 'failed'
    | undefined;
  const actionType = searchParams.get('actionType')?.trim() || undefined;
  const mode = searchParams.get('mode')?.trim() || '';
  const format = searchParams.get('format')?.trim() || 'json';
  const clientIp = resolveClientIp(request);

  if (mode === 'export') {
    const rate = checkRateLimit(`offline-audit-export:${clientIp}`, 120, 60_000);
    if (!rate.ok) {
      return NextResponse.json(
        {
          ok: false,
          error: 'rate_limited',
          retryAfterMs: rate.retryAfterMs,
        },
        {
          status: 429,
          headers: {
            'Retry-After': String(Math.ceil(rate.retryAfterMs / 1000)),
            'X-RateLimit-Limit': String(rate.limit),
            'X-RateLimit-Remaining': String(rate.remaining),
          },
        },
      );
    }

    const exportLimit = Number(searchParams.get('limit') || '1000');
    const exportOffset = Number(searchParams.get('offset') || '0');
    const includeArchived = searchParams.get('includeArchived') === 'true';
    const data = await listOfflineAuditLogsForExport({
      target,
      action,
      actionSource,
      executionResult,
      actionType,
      limit: exportLimit,
      offset: exportOffset,
      includeArchived,
    });

    if (format === 'csv') {
      const headers = [
        'id',
        'createdAt',
        'actor',
        'action',
        'actionType',
        'target',
        'actionSource',
        'executionResult',
        'sourceIp',
        'requestId',
        'actionMeta',
        'beforeData',
        'afterData',
      ];
      const lines = [headers.join(',')];
      for (const row of data.rows) {
        lines.push(
          [
            toCsvValue(row.id),
            toCsvValue(row.createdAt),
            toCsvValue(row.actor),
            toCsvValue(row.action),
            toCsvValue(row.actionType || ''),
            toCsvValue(row.target),
            toCsvValue(row.actionSource),
            toCsvValue(row.executionResult),
            toCsvValue(row.sourceIp),
            toCsvValue(row.requestId || ''),
            toCsvValue(row.actionMeta || {}),
            toCsvValue(row.beforeData || {}),
            toCsvValue(row.afterData || {}),
          ].join(','),
        );
      }
      const csv = lines.join('\n');
      return new NextResponse(csv, {
        status: 200,
        headers: {
          'Content-Type': 'text/csv; charset=utf-8',
          'Content-Disposition': `attachment; filename="offline-audit-${Date.now()}.csv"`,
          'X-Offline-Audit-Total': String(data.total),
          'X-Offline-Audit-Source': data.source,
          'X-Offline-Audit-Has-More': data.hasMore ? 'true' : 'false',
          'X-Offline-Audit-Next-Offset': data.nextOffset != null ? String(data.nextOffset) : '',
        },
      });
    }

    return NextResponse.json({
      ok: true,
      data: {
        rows: data.rows,
        total: data.total,
        source: data.source,
        offset: data.offset,
        limit: data.limit,
        hasMore: data.hasMore,
        nextOffset: data.nextOffset,
      },
    });
  }

  const data = await listOfflineAuditLogs({
    page,
    pageSize,
    target,
    action,
    actionSource,
    executionResult,
    actionType,
  });

  return NextResponse.json({ ok: true, data });
}
