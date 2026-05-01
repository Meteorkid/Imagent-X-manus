import { NextRequest, NextResponse } from 'next/server';
import { assertAdmin, resolveAdminActor, resolveClientIp } from '@/app/api/_utils/admin-auth';
import {
  cancelOfflineAuditExportJob,
  createOfflineAuditExportJob,
  listOfflineAuditExportJobsFiltered,
  type OfflineAuditExportFormat,
  type OfflineAuditExportJobStatus,
} from '@/lib/server/offline-audit-export-jobs';
import { checkRateLimit } from '@/lib/server/api-rate-limit';

function resolveFormat(value: unknown): OfflineAuditExportFormat {
  return value === 'csv' ? 'csv' : 'json';
}

export async function GET(request: NextRequest) {
  const admin = await assertAdmin(request);
  if (!admin.ok) {
    return NextResponse.json({ ok: false, error: admin.reason }, { status: 403 });
  }
  const ip = resolveClientIp(request);
  const rate = checkRateLimit(`offline-audit-export-jobs:list:${ip}`, 90, 60_000);
  if (!rate.ok) {
    return NextResponse.json(
      { ok: false, error: 'rate_limited', retryAfterMs: rate.retryAfterMs },
      { status: 429, headers: { 'Retry-After': String(Math.ceil(rate.retryAfterMs / 1000)) } },
    );
  }
  const { searchParams } = new URL(request.url);
  const limit = Number(searchParams.get('limit') || '20');
  const q = searchParams.get('q')?.trim() || '';
  const status = (searchParams.get('status')?.trim() || '') as OfflineAuditExportJobStatus | '';
  const jobs = await listOfflineAuditExportJobsFiltered({ limit, q, status });
  return NextResponse.json({ ok: true, data: { jobs } });
}

export async function POST(request: NextRequest) {
  const admin = await assertAdmin(request);
  if (!admin.ok) {
    return NextResponse.json({ ok: false, error: admin.reason }, { status: 403 });
  }
  const ip = resolveClientIp(request);
  const rate = checkRateLimit(`offline-audit-export-jobs:create:${ip}`, 12, 60_000);
  if (!rate.ok) {
    return NextResponse.json(
      { ok: false, error: 'rate_limited', retryAfterMs: rate.retryAfterMs },
      { status: 429, headers: { 'Retry-After': String(Math.ceil(rate.retryAfterMs / 1000)) } },
    );
  }
  try {
    const body = (await request.json()) as Record<string, unknown>;
    const filters = (body.filters || {}) as Record<string, unknown>;
    const job = await createOfflineAuditExportJob({
      actor: await resolveAdminActor(request),
      sourceIp: resolveClientIp(request),
      format: resolveFormat(body.format),
      chunkSize: typeof body.chunkSize === 'number' ? body.chunkSize : undefined,
      includeArchived: body.includeArchived !== false,
      filters: {
        target: typeof filters.target === 'string' ? filters.target : undefined,
        action: typeof filters.action === 'string' ? filters.action : undefined,
        actionSource: typeof filters.actionSource === 'string' ? filters.actionSource : undefined,
        executionResult:
          filters.executionResult === 'failed' || filters.executionResult === 'success'
            ? filters.executionResult
            : undefined,
        actionType: typeof filters.actionType === 'string' ? filters.actionType : undefined,
      },
    });
    return NextResponse.json({ ok: true, data: { job } });
  } catch (error) {
    return NextResponse.json({ ok: false, error: 'invalid_payload' }, { status: 400 });
  }
}

export async function DELETE(request: NextRequest) {
  const admin = await assertAdmin(request);
  if (!admin.ok) {
    return NextResponse.json({ ok: false, error: admin.reason }, { status: 403 });
  }
  const ip = resolveClientIp(request);
  const rate = checkRateLimit(`offline-audit-export-jobs:cancel:${ip}`, 30, 60_000);
  if (!rate.ok) {
    return NextResponse.json(
      { ok: false, error: 'rate_limited', retryAfterMs: rate.retryAfterMs },
      { status: 429, headers: { 'Retry-After': String(Math.ceil(rate.retryAfterMs / 1000)) } },
    );
  }
  const { searchParams } = new URL(request.url);
  const jobId = searchParams.get('jobId')?.trim() || '';
  if (!jobId) {
    return NextResponse.json({ ok: false, error: 'missing_job_id' }, { status: 400 });
  }
  const job = await cancelOfflineAuditExportJob(jobId);
  if (!job) {
    return NextResponse.json({ ok: false, error: 'job_not_found' }, { status: 404 });
  }
  return NextResponse.json({ ok: true, data: { job } });
}
