import { offlineDbEnabled, queryDb } from './offline-db';

export interface OfflineAuditLogInput {
  actor: string;
  action: string;
  target: string;
  actionSource?: string;
  executionResult?: 'success' | 'failed';
  actionMeta?: Record<string, unknown>;
  sourceIp: string;
  beforeData: unknown;
  afterData: unknown;
  requestId?: string;
}

type MemoryAuditRecord = OfflineAuditLogInput & { loggedAt: number };
const inMemoryLogs: MemoryAuditRecord[] = [];
const MAX_IN_MEMORY_AUDIT_LOGS = 500;

function pushMemoryLog(input: OfflineAuditLogInput) {
  inMemoryLogs.push({
    ...input,
    loggedAt: Date.now(),
  });
  if (inMemoryLogs.length > MAX_IN_MEMORY_AUDIT_LOGS) {
    inMemoryLogs.splice(0, inMemoryLogs.length - MAX_IN_MEMORY_AUDIT_LOGS);
  }
}

export async function writeOfflineAuditLog(input: OfflineAuditLogInput): Promise<void> {
  pushMemoryLog(input);
  if (!offlineDbEnabled()) return;
  await queryDb(
    `
      INSERT INTO offline_admin_audit_logs (
        actor,
        action,
        target,
        action_source,
        execution_result,
        action_meta,
        source_ip,
        before_data,
        after_data,
        request_id
      ) VALUES ($1, $2, $3, $4, $5, $6::jsonb, $7, $8::jsonb, $9::jsonb, $10)
    `,
    [
      input.actor,
      input.action,
      input.target,
      input.actionSource || 'manual_admin_ui',
      input.executionResult || 'success',
      JSON.stringify(input.actionMeta || {}),
      input.sourceIp,
      JSON.stringify(input.beforeData || {}),
      JSON.stringify(input.afterData || {}),
      input.requestId || null,
    ],
  );
}

export function listInMemoryAuditLogs() {
  return [...inMemoryLogs];
}

export interface OfflineAuditLogRow {
  id: string;
  actor: string;
  action: string;
  actionType: string | null;
  target: string;
  actionSource: string;
  executionResult: 'success' | 'failed';
  actionMeta: Record<string, unknown>;
  sourceIp: string;
  beforeData: unknown;
  afterData: unknown;
  requestId: string | null;
  createdAt: string;
}

export interface ListOfflineAuditLogsOptions {
  page: number;
  pageSize: number;
  target?: string;
  action?: string;
  actionSource?: string;
  executionResult?: 'success' | 'failed';
  actionType?: string;
}

export interface OfflineAuditLogFilterOptions {
  target?: string;
  action?: string;
  actionSource?: string;
  executionResult?: 'success' | 'failed';
  actionType?: string;
}

export interface ListOfflineAuditLogsResult {
  rows: OfflineAuditLogRow[];
  total: number;
  page: number;
  pageSize: number;
  source: 'database' | 'memory';
}

function normalizePage(page: number) {
  return Number.isFinite(page) && page >= 1 ? Math.floor(page) : 1;
}

function normalizePageSize(size: number) {
  const n = Number.isFinite(size) ? Math.floor(size) : 20;
  return Math.min(100, Math.max(1, n));
}

function normalizeExportLimit(size: number) {
  const n = Number.isFinite(size) ? Math.floor(size) : 1000;
  return Math.min(5000, Math.max(1, n));
}

export async function listOfflineAuditLogs(
  options: ListOfflineAuditLogsOptions,
): Promise<ListOfflineAuditLogsResult> {
  const page = normalizePage(options.page);
  const pageSize = normalizePageSize(options.pageSize);
  const targetFilter = options.target?.trim() || undefined;
  const actionFilter = options.action?.trim() || undefined;
  const actionSourceFilter = options.actionSource?.trim() || undefined;
  const executionResultFilter = options.executionResult?.trim() || undefined;
  const actionTypeFilter = options.actionType?.trim() || undefined;

  if (!offlineDbEnabled()) {
    let filtered = [...inMemoryLogs];
    if (targetFilter) {
      filtered = filtered.filter((r) => r.target.includes(targetFilter));
    }
    if (actionFilter) {
      filtered = filtered.filter((r) => r.action === actionFilter);
    }
    if (actionSourceFilter) {
      filtered = filtered.filter((r) => (r.actionSource || 'manual_admin_ui') === actionSourceFilter);
    }
    if (executionResultFilter) {
      filtered = filtered.filter((r) => (r.executionResult || 'success') === executionResultFilter);
    }
    if (actionTypeFilter) {
      filtered = filtered.filter((r) => {
        const actionType =
          typeof r.actionMeta?.actionType === 'string' ? (r.actionMeta.actionType as string) : '';
        return actionType === actionTypeFilter;
      });
    }
    filtered.sort((a, b) => b.loggedAt - a.loggedAt);
    const total = filtered.length;
    const offset = (page - 1) * pageSize;
    const slice = filtered.slice(offset, offset + pageSize);
    const rows: OfflineAuditLogRow[] = slice.map((r, i) => ({
      id: `mem-${offset + i}`,
      actor: r.actor,
      action: r.action,
      actionType: typeof r.actionMeta?.actionType === 'string' ? (r.actionMeta.actionType as string) : null,
      target: r.target,
      actionSource: r.actionSource || 'manual_admin_ui',
      executionResult: r.executionResult || 'success',
      actionMeta: r.actionMeta || {},
      sourceIp: r.sourceIp,
      beforeData: r.beforeData,
      afterData: r.afterData,
      requestId: r.requestId ?? null,
      createdAt: new Date(r.loggedAt).toISOString(),
    }));
    return { rows, total, page, pageSize, source: 'memory' };
  }

  const conditions: string[] = ['1=1'];
  const params: unknown[] = [];
  let nextParam = 1;
  if (targetFilter) {
    conditions.push(`target ILIKE $${nextParam++}`);
    params.push(`%${targetFilter}%`);
  }
  if (actionFilter) {
    conditions.push(`action = $${nextParam++}`);
    params.push(actionFilter);
  }
  if (actionSourceFilter) {
    conditions.push(`action_source = $${nextParam++}`);
    params.push(actionSourceFilter);
  }
  if (executionResultFilter) {
    conditions.push(`execution_result = $${nextParam++}`);
    params.push(executionResultFilter);
  }
  if (actionTypeFilter) {
    conditions.push(`COALESCE(action_meta->>'actionType', '') = $${nextParam++}`);
    params.push(actionTypeFilter);
  }
  const where = conditions.join(' AND ');

  const countRows = await queryDb<{ count: string }>(
    `SELECT COUNT(*)::text AS count FROM offline_admin_audit_logs WHERE ${where}`,
    params,
  );
  const total = Number(countRows[0]?.count || 0);

  const listParams = [...params, pageSize, (page - 1) * pageSize];
  const limitPh = `$${nextParam++}`;
  const offsetPh = `$${nextParam++}`;

  const dataRows = await queryDb<{
    id: string;
    actor: string;
    action: string;
    action_type: string | null;
    target: string;
    action_source: string;
    execution_result: 'success' | 'failed';
    action_meta: Record<string, unknown> | null;
    source_ip: string;
    before_data: unknown;
    after_data: unknown;
    request_id: string | null;
    created_at: Date;
  }>(
    `
      SELECT
        id,
        actor,
        action,
        action_meta->>'actionType' AS action_type,
        target,
        action_source,
        execution_result,
        action_meta,
        source_ip,
        before_data,
        after_data,
        request_id,
        created_at
      FROM ${baseFrom}
      WHERE ${where}
      ORDER BY created_at DESC
      LIMIT ${limitPh} OFFSET ${offsetPh}
    `,
    listParams,
  );

  const rows: OfflineAuditLogRow[] = dataRows.map((r) => ({
    id: String(r.id),
    actor: r.actor,
    action: r.action,
    actionType: r.action_type || null,
    target: r.target,
    actionSource: r.action_source || 'manual_admin_ui',
    executionResult: (r.execution_result || 'success') as 'success' | 'failed',
    actionMeta: r.action_meta || {},
    sourceIp: r.source_ip,
    beforeData: r.before_data,
    afterData: r.after_data,
    requestId: r.request_id,
    createdAt:
      r.created_at instanceof Date ? r.created_at.toISOString() : String(r.created_at),
  }));

  return { rows, total, page, pageSize, source: 'database' };
}

export async function listOfflineAuditLogsForExport(
  options: OfflineAuditLogFilterOptions & { limit?: number; offset?: number; includeArchived?: boolean },
): Promise<{
  rows: OfflineAuditLogRow[];
  total: number;
  source: 'database' | 'memory';
  offset: number;
  limit: number;
  hasMore: boolean;
  nextOffset: number | null;
}> {
  const targetFilter = options.target?.trim() || undefined;
  const actionFilter = options.action?.trim() || undefined;
  const actionSourceFilter = options.actionSource?.trim() || undefined;
  const executionResultFilter = options.executionResult?.trim() || undefined;
  const actionTypeFilter = options.actionType?.trim() || undefined;
  const limit = normalizeExportLimit(options.limit || 1000);
  const offset = Number.isFinite(options.offset) ? Math.max(0, Math.floor(options.offset || 0)) : 0;
  const includeArchived = options.includeArchived === true;

  if (!offlineDbEnabled()) {
    let filtered = [...inMemoryLogs];
    if (targetFilter) {
      filtered = filtered.filter((r) => r.target.includes(targetFilter));
    }
    if (actionFilter) {
      filtered = filtered.filter((r) => r.action === actionFilter);
    }
    if (actionSourceFilter) {
      filtered = filtered.filter((r) => (r.actionSource || 'manual_admin_ui') === actionSourceFilter);
    }
    if (executionResultFilter) {
      filtered = filtered.filter((r) => (r.executionResult || 'success') === executionResultFilter);
    }
    if (actionTypeFilter) {
      filtered = filtered.filter((r) => {
        const actionType =
          typeof r.actionMeta?.actionType === 'string' ? (r.actionMeta.actionType as string) : '';
        return actionType === actionTypeFilter;
      });
    }
    filtered.sort((a, b) => b.loggedAt - a.loggedAt);
    const rows: OfflineAuditLogRow[] = filtered.slice(offset, offset + limit).map((r, i) => ({
      id: `mem-export-${offset + i}`,
      actor: r.actor,
      action: r.action,
      actionType: typeof r.actionMeta?.actionType === 'string' ? (r.actionMeta.actionType as string) : null,
      target: r.target,
      actionSource: r.actionSource || 'manual_admin_ui',
      executionResult: r.executionResult || 'success',
      actionMeta: r.actionMeta || {},
      sourceIp: r.sourceIp,
      beforeData: r.beforeData,
      afterData: r.afterData,
      requestId: r.requestId ?? null,
      createdAt: new Date(r.loggedAt).toISOString(),
    }));
    const total = filtered.length;
    const nextOffset = offset + rows.length;
    return {
      rows,
      total,
      source: 'memory',
      offset,
      limit,
      hasMore: nextOffset < total,
      nextOffset: nextOffset < total ? nextOffset : null,
    };
  }

  const conditions: string[] = ['1=1'];
  const params: unknown[] = [];
  let nextParam = 1;
  if (targetFilter) {
    conditions.push(`target ILIKE $${nextParam++}`);
    params.push(`%${targetFilter}%`);
  }
  if (actionFilter) {
    conditions.push(`action = $${nextParam++}`);
    params.push(actionFilter);
  }
  if (actionSourceFilter) {
    conditions.push(`action_source = $${nextParam++}`);
    params.push(actionSourceFilter);
  }
  if (executionResultFilter) {
    conditions.push(`execution_result = $${nextParam++}`);
    params.push(executionResultFilter);
  }
  if (actionTypeFilter) {
    conditions.push(`COALESCE(action_meta->>'actionType', '') = $${nextParam++}`);
    params.push(actionTypeFilter);
  }
  const where = conditions.join(' AND ');

  const baseFrom = includeArchived
    ? `
      (
        SELECT
          id::text AS id,
          actor,
          action,
          target,
          action_source,
          execution_result,
          action_meta,
          source_ip,
          before_data,
          after_data,
          request_id,
          created_at
        FROM offline_admin_audit_logs
        UNION ALL
        SELECT
          ('archive-' || archive_id)::text AS id,
          actor,
          action,
          target,
          action_source,
          execution_result,
          action_meta,
          source_ip,
          before_data,
          after_data,
          request_id,
          created_at
        FROM offline_admin_audit_logs_archive
      ) audit_rows
    `
    : `offline_admin_audit_logs`;

  const countRows = await queryDb<{ count: string }>(
    `SELECT COUNT(*)::text AS count FROM ${baseFrom} WHERE ${where}`,
    params,
  );
  const total = Number(countRows[0]?.count || 0);
  const listParams = [...params, limit, offset];
  const limitPh = `$${nextParam++}`;
  const offsetPh = `$${nextParam++}`;

  const dataRows = await queryDb<{
    id: string;
    actor: string;
    action: string;
    action_type: string | null;
    target: string;
    action_source: string;
    execution_result: 'success' | 'failed';
    action_meta: Record<string, unknown> | null;
    source_ip: string;
    before_data: unknown;
    after_data: unknown;
    request_id: string | null;
    created_at: Date;
  }>(
    `
      SELECT
        id,
        actor,
        action,
        action_meta->>'actionType' AS action_type,
        target,
        action_source,
        execution_result,
        action_meta,
        source_ip,
        before_data,
        after_data,
        request_id,
        created_at
      FROM offline_admin_audit_logs
      WHERE ${where}
      ORDER BY created_at DESC
      LIMIT ${limitPh} OFFSET ${offsetPh}
    `,
    listParams,
  );

  const rows: OfflineAuditLogRow[] = dataRows.map((r) => ({
    id: String(r.id),
    actor: r.actor,
    action: r.action,
    actionType: r.action_type || null,
    target: r.target,
    actionSource: r.action_source || 'manual_admin_ui',
    executionResult: (r.execution_result || 'success') as 'success' | 'failed',
    actionMeta: r.action_meta || {},
    sourceIp: r.source_ip,
    beforeData: r.before_data,
    afterData: r.after_data,
    requestId: r.request_id,
    createdAt:
      r.created_at instanceof Date ? r.created_at.toISOString() : String(r.created_at),
  }));
  const nextOffset = offset + rows.length;
  return {
    rows,
    total,
    source: 'database',
    offset,
    limit,
    hasMore: nextOffset < total,
    nextOffset: nextOffset < total ? nextOffset : null,
  };
}

