import { offlineDbEnabled, queryDb } from './offline-db';
import { listOfflineAuditLogsForExport, type OfflineAuditLogFilterOptions } from './offline-audit-log';

export type OfflineAuditExportFormat = 'json' | 'csv';
export type OfflineAuditExportJobStatus = 'pending' | 'processing' | 'completed' | 'failed' | 'cancelled';

export interface OfflineAuditExportJobItem {
  partNo: number;
  offset: number;
  limit: number;
  filename: string;
  downloadQuery: string;
}

export interface OfflineAuditExportJob {
  id: string;
  actor: string;
  sourceIp: string;
  format: OfflineAuditExportFormat;
  chunkSize: number;
  includeArchived: boolean;
  status: OfflineAuditExportJobStatus;
  totalRows: number;
  totalChunks: number;
  retryCount: number;
  filters: OfflineAuditLogFilterOptions;
  errorMessage?: string;
  processingStartedAt?: string;
  processingDurationMs?: number;
  createdAt: string;
  completedAt?: string;
  items: OfflineAuditExportJobItem[];
}

interface CreateExportJobInput {
  actor: string;
  sourceIp: string;
  format: OfflineAuditExportFormat;
  chunkSize?: number;
  includeArchived?: boolean;
  filters: OfflineAuditLogFilterOptions;
}

const inMemoryJobs: OfflineAuditExportJob[] = [];
const MAX_IN_MEMORY_JOBS = 200;
const PROCESS_RETRY_MAX_ATTEMPTS = 3;

function nowIso() {
  return new Date().toISOString();
}

function buildJobId() {
  return `audit-export-${Date.now()}-${Math.random().toString(36).slice(2, 8)}`;
}

function normalizeChunkSize(size: number | undefined) {
  if (!Number.isFinite(size)) return 1000;
  return Math.min(2000, Math.max(200, Math.floor(size as number)));
}

function buildDownloadQuery(
  format: OfflineAuditExportFormat,
  filters: OfflineAuditLogFilterOptions,
  includeArchived: boolean,
  offset: number,
  limit: number,
) {
  const qs = new URLSearchParams();
  qs.set('mode', 'export');
  qs.set('format', format);
  qs.set('offset', String(offset));
  qs.set('limit', String(limit));
  qs.set('includeArchived', includeArchived ? 'true' : 'false');
  if (filters.target) qs.set('target', filters.target);
  if (filters.action) qs.set('action', filters.action);
  if (filters.actionSource) qs.set('actionSource', filters.actionSource);
  if (filters.executionResult) qs.set('executionResult', filters.executionResult);
  if (filters.actionType) qs.set('actionType', filters.actionType);
  return qs.toString();
}

function pushMemoryJob(job: OfflineAuditExportJob) {
  inMemoryJobs.unshift(job);
  if (inMemoryJobs.length > MAX_IN_MEMORY_JOBS) {
    inMemoryJobs.splice(MAX_IN_MEMORY_JOBS);
  }
}

async function insertJobToDb(job: OfflineAuditExportJob) {
  if (!offlineDbEnabled()) return;
  await queryDb(
    `
      INSERT INTO offline_audit_export_jobs (
        id, actor, source_ip, format, chunk_size, include_archived, status,
        total_rows, total_chunks, retry_count, filters, error_message,
        processing_started_at, processing_duration_ms, created_at, completed_at
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11::jsonb, $12, $13::timestamptz, $14, $15::timestamptz, $16::timestamptz)
    `,
    [
      job.id,
      job.actor,
      job.sourceIp,
      job.format,
      job.chunkSize,
      job.includeArchived,
      job.status,
      job.totalRows,
      job.totalChunks,
      job.retryCount,
      JSON.stringify(job.filters || {}),
      job.errorMessage || null,
      job.processingStartedAt || null,
      job.processingDurationMs || null,
      job.createdAt,
      job.completedAt || null,
    ],
  );
}

async function updateJobInDb(job: OfflineAuditExportJob) {
  if (!offlineDbEnabled()) return;
  await queryDb(
    `
      UPDATE offline_audit_export_jobs
      SET status = $2,
          total_rows = $3,
          total_chunks = $4,
          retry_count = $5,
          error_message = $6,
          processing_started_at = $7::timestamptz,
          processing_duration_ms = $8,
          completed_at = $9::timestamptz
      WHERE id = $1
    `,
    [
      job.id,
      job.status,
      job.totalRows,
      job.totalChunks,
      job.retryCount,
      job.errorMessage || null,
      job.processingStartedAt || null,
      job.processingDurationMs || null,
      job.completedAt || null,
    ],
  );
  await queryDb(`DELETE FROM offline_audit_export_job_items WHERE job_id = $1`, [job.id]);
  for (const item of job.items) {
    await queryDb(
      `
        INSERT INTO offline_audit_export_job_items (job_id, part_no, offset_rows, limit_rows, filename, download_query)
        VALUES ($1, $2, $3, $4, $5, $6)
      `,
      [job.id, item.partNo, item.offset, item.limit, item.filename, item.downloadQuery],
    );
  }
}

function updateMemoryJob(next: OfflineAuditExportJob) {
  const idx = inMemoryJobs.findIndex((item) => item.id === next.id);
  if (idx >= 0) {
    inMemoryJobs[idx] = next;
  } else {
    pushMemoryJob(next);
  }
}

function findMemoryJob(jobId: string) {
  return inMemoryJobs.find((item) => item.id === jobId);
}

async function processJob(job: OfflineAuditExportJob): Promise<void> {
  const startedAtMs = Date.now();
  const processingStartedAt = nowIso();
  try {
    const latest = findMemoryJob(job.id);
    if (latest?.status === 'cancelled') return;
    const processing: OfflineAuditExportJob = {
      ...job,
      status: 'processing',
      retryCount: 0,
      errorMessage: undefined,
      processingStartedAt,
      processingDurationMs: undefined,
      items: [],
    };
    updateMemoryJob(processing);
    await updateJobInDb(processing);

    let totalRows = 0;
    let totalChunks = 0;
    let items: OfflineAuditExportJobItem[] = [];
    let lastError: string | undefined;
    for (let attempt = 1; attempt <= PROCESS_RETRY_MAX_ATTEMPTS; attempt += 1) {
      try {
        const totalProbe = await listOfflineAuditLogsForExport({
          ...processing.filters,
          includeArchived: processing.includeArchived,
          limit: 1,
          offset: 0,
        });
        totalRows = totalProbe.total;
        totalChunks = Math.max(1, Math.ceil(totalRows / processing.chunkSize));
        items = [];
        for (let i = 0; i < totalChunks; i += 1) {
          const latestLoop = findMemoryJob(job.id);
          if (latestLoop?.status === 'cancelled') {
            return;
          }
          const offset = i * processing.chunkSize;
          const query = buildDownloadQuery(
            processing.format,
            processing.filters,
            processing.includeArchived,
            offset,
            processing.chunkSize,
          );
          items.push({
            partNo: i + 1,
            offset,
            limit: processing.chunkSize,
            filename: `offline-audit-${processing.id}-part-${i + 1}.${processing.format}`,
            downloadQuery: query,
          });
        }
        const update = findMemoryJob(job.id);
        const base = update || processing;
        const retriedJob: OfflineAuditExportJob = {
          ...base,
          retryCount: attempt - 1,
          processingStartedAt,
          processingDurationMs: Date.now() - startedAtMs,
        };
        updateMemoryJob(retriedJob);
        await updateJobInDb(retriedJob);
        lastError = undefined;
        break;
      } catch (error) {
        lastError = error instanceof Error ? error.message : 'export_job_failed';
        const update = findMemoryJob(job.id);
        const base = update || processing;
        const retriedJob: OfflineAuditExportJob = {
          ...base,
          retryCount: attempt,
          errorMessage: `attempt_${attempt}_failed:${lastError}`,
          processingStartedAt,
          processingDurationMs: Date.now() - startedAtMs,
        };
        updateMemoryJob(retriedJob);
        await updateJobInDb(retriedJob);
        if (attempt < PROCESS_RETRY_MAX_ATTEMPTS) {
          await new Promise((resolve) => setTimeout(resolve, 300 * Math.pow(2, attempt - 1)));
        }
      }
    }
    if (lastError) {
      throw new Error(lastError);
    }

    const latestBeforeDone = findMemoryJob(job.id);
    if (latestBeforeDone?.status === 'cancelled') {
      return;
    }
    const completed: OfflineAuditExportJob = {
      ...(latestBeforeDone || processing),
      status: 'completed',
      totalRows,
      totalChunks,
      processingStartedAt,
      processingDurationMs: Date.now() - startedAtMs,
      completedAt: nowIso(),
      items,
    };
    updateMemoryJob(completed);
    await updateJobInDb(completed);
  } catch (error) {
    const failed: OfflineAuditExportJob = {
      ...(findMemoryJob(job.id) || job),
      status: 'failed',
      errorMessage: error instanceof Error ? error.message : 'export_job_failed',
      processingStartedAt,
      processingDurationMs: Date.now() - startedAtMs,
      completedAt: nowIso(),
      items: [],
    };
    updateMemoryJob(failed);
    await updateJobInDb(failed);
  }
}

export async function createOfflineAuditExportJob(input: CreateExportJobInput): Promise<OfflineAuditExportJob> {
  const job: OfflineAuditExportJob = {
    id: buildJobId(),
    actor: input.actor,
    sourceIp: input.sourceIp,
    format: input.format,
    chunkSize: normalizeChunkSize(input.chunkSize),
    includeArchived: input.includeArchived !== false,
    status: 'pending',
    totalRows: 0,
    totalChunks: 0,
    retryCount: 0,
    filters: input.filters,
    createdAt: nowIso(),
    items: [],
  };
  pushMemoryJob(job);
  await insertJobToDb(job);
  void processJob(job);
  return job;
}

export async function listOfflineAuditExportJobs(limit = 20): Promise<OfflineAuditExportJob[]> {
  const safeLimit = Math.min(100, Math.max(1, Math.floor(limit)));
  if (!offlineDbEnabled()) {
    return inMemoryJobs.slice(0, safeLimit);
  }

  const rows = await queryDb<{
    id: string;
    actor: string;
    source_ip: string;
    format: OfflineAuditExportFormat;
    chunk_size: number;
    include_archived: boolean;
    status: OfflineAuditExportJobStatus;
    total_rows: number;
    total_chunks: number;
    retry_count: number;
    filters: Record<string, unknown> | null;
    error_message: string | null;
    processing_started_at: Date | null;
    processing_duration_ms: number | null;
    created_at: Date;
    completed_at: Date | null;
    }>(
    `
      SELECT
        id, actor, source_ip, format, chunk_size, include_archived, status,
        total_rows, total_chunks, retry_count, filters, error_message,
        processing_started_at, processing_duration_ms, created_at, completed_at
      FROM offline_audit_export_jobs
      ORDER BY created_at DESC
      LIMIT $1
    `,
    [safeLimit],
  );

  const items = await queryDb<{
    job_id: string;
    part_no: number;
    offset_rows: number;
    limit_rows: number;
    filename: string;
    download_query: string;
  }>(
    `
      SELECT job_id, part_no, offset_rows, limit_rows, filename, download_query
      FROM offline_audit_export_job_items
      WHERE job_id = ANY($1::text[])
      ORDER BY job_id, part_no
    `,
    [rows.map((row) => row.id)],
  );
  const itemMap = new Map<string, OfflineAuditExportJobItem[]>();
  for (const item of items) {
    const list = itemMap.get(item.job_id) || [];
    list.push({
      partNo: item.part_no,
      offset: item.offset_rows,
      limit: item.limit_rows,
      filename: item.filename,
      downloadQuery: item.download_query,
    });
    itemMap.set(item.job_id, list);
  }

  return rows.map((row) => ({
    id: row.id,
    actor: row.actor,
    sourceIp: row.source_ip,
    format: row.format,
    chunkSize: Number(row.chunk_size) || 1000,
    includeArchived: row.include_archived === true,
    status: row.status,
    totalRows: Number(row.total_rows) || 0,
    totalChunks: Number(row.total_chunks) || 0,
    retryCount: Number(row.retry_count) || 0,
    filters: (row.filters || {}) as OfflineAuditLogFilterOptions,
    errorMessage: row.error_message || undefined,
    processingStartedAt:
      row.processing_started_at == null
        ? undefined
        : row.processing_started_at instanceof Date
          ? row.processing_started_at.toISOString()
          : String(row.processing_started_at),
    processingDurationMs:
      row.processing_duration_ms == null ? undefined : Number(row.processing_duration_ms),
    createdAt: row.created_at instanceof Date ? row.created_at.toISOString() : String(row.created_at),
    completedAt:
      row.completed_at == null
        ? undefined
        : row.completed_at instanceof Date
          ? row.completed_at.toISOString()
          : String(row.completed_at),
    items: itemMap.get(row.id) || [],
  }));
}

export async function listOfflineAuditExportJobsFiltered(
  options: { limit?: number; q?: string; status?: OfflineAuditExportJobStatus | '' } = {},
): Promise<OfflineAuditExportJob[]> {
  const jobs = await listOfflineAuditExportJobs(options.limit || 20);
  const q = (options.q || '').trim().toLowerCase();
  const status = options.status || '';
  return jobs.filter((job) => {
    if (status && job.status !== status) return false;
    if (!q) return true;
    const haystack = [
      job.id,
      job.actor,
      job.sourceIp,
      job.format,
      JSON.stringify(job.filters || {}),
    ]
      .join(' ')
      .toLowerCase();
    return haystack.includes(q);
  });
}

export async function cancelOfflineAuditExportJob(jobId: string): Promise<OfflineAuditExportJob | null> {
  if (!jobId.trim()) return null;
  const existed = findMemoryJob(jobId);
  if (existed && (existed.status === 'completed' || existed.status === 'failed' || existed.status === 'cancelled')) {
    return existed;
  }
  if (existed) {
    const cancelled: OfflineAuditExportJob = {
      ...existed,
      status: 'cancelled',
      completedAt: nowIso(),
      errorMessage: existed.errorMessage || 'cancelled_by_user',
      items: [],
      totalChunks: 0,
      totalRows: 0,
    };
    updateMemoryJob(cancelled);
    await updateJobInDb(cancelled);
    return cancelled;
  }

  if (!offlineDbEnabled()) return null;
  const rows = await queryDb<{
    id: string;
    actor: string;
    source_ip: string;
    format: OfflineAuditExportFormat;
    chunk_size: number;
    include_archived: boolean;
    status: OfflineAuditExportJobStatus;
    total_rows: number;
    total_chunks: number;
    retry_count: number;
    filters: Record<string, unknown> | null;
    error_message: string | null;
    processing_started_at: Date | null;
    processing_duration_ms: number | null;
    created_at: Date;
    completed_at: Date | null;
  }>(
    `
      SELECT
        id, actor, source_ip, format, chunk_size, include_archived, status,
        total_rows, total_chunks, retry_count, filters, error_message,
        processing_started_at, processing_duration_ms, created_at, completed_at
      FROM offline_audit_export_jobs
      WHERE id = $1
      LIMIT 1
    `,
    [jobId],
  );
  if (!rows.length) return null;
  const row = rows[0];
  const cancelled: OfflineAuditExportJob = {
    id: row.id,
    actor: row.actor,
    sourceIp: row.source_ip,
    format: row.format,
    chunkSize: Number(row.chunk_size) || 1000,
    includeArchived: row.include_archived === true,
    status:
      row.status === 'completed' || row.status === 'failed' || row.status === 'cancelled'
        ? row.status
        : 'cancelled',
    totalRows: row.status === 'completed' ? Number(row.total_rows) || 0 : 0,
    totalChunks: row.status === 'completed' ? Number(row.total_chunks) || 0 : 0,
    retryCount: Number(row.retry_count) || 0,
    filters: (row.filters || {}) as OfflineAuditLogFilterOptions,
    errorMessage: row.status === 'completed' ? row.error_message || undefined : 'cancelled_by_user',
    processingStartedAt:
      row.processing_started_at == null
        ? undefined
        : row.processing_started_at instanceof Date
          ? row.processing_started_at.toISOString()
          : String(row.processing_started_at),
    processingDurationMs:
      row.processing_duration_ms == null ? undefined : Number(row.processing_duration_ms),
    createdAt: row.created_at instanceof Date ? row.created_at.toISOString() : String(row.created_at),
    completedAt: nowIso(),
    items: [],
  };
  await updateJobInDb(cancelled);
  updateMemoryJob(cancelled);
  return cancelled;
}
