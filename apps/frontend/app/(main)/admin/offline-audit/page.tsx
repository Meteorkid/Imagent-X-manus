"use client";

import React, { useCallback, useEffect, useMemo, useRef, useState } from "react";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { Badge } from "@/components/ui/badge";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import { ScrollArea } from "@/components/ui/scroll-area";
import { useToast } from "@/hooks/use-toast";
import { ChevronLeft, ChevronRight, Eye } from "lucide-react";

type OfflineAuditLogRow = {
  id: string;
  actor: string;
  action: string;
  actionType: string | null;
  target: string;
  actionSource: string;
  executionResult: "success" | "failed";
  actionMeta: Record<string, unknown>;
  sourceIp: string;
  beforeData: unknown;
  afterData: unknown;
  requestId: string | null;
  createdAt: string;
};

type ListResponse = {
  ok: boolean;
  data?: {
    rows: OfflineAuditLogRow[];
    total: number;
    page: number;
    pageSize: number;
    source: "database" | "memory";
  };
  error?: string;
};

type ExportJobItem = {
  partNo: number;
  offset: number;
  limit: number;
  filename: string;
  downloadQuery: string;
};

type ExportJob = {
  id: string;
  actor: string;
  sourceIp: string;
  format: "json" | "csv";
  chunkSize: number;
  includeArchived: boolean;
  status: "pending" | "processing" | "completed" | "failed" | "cancelled";
  totalRows: number;
  totalChunks: number;
  retryCount: number;
  errorMessage?: string;
  processingStartedAt?: string;
  processingDurationMs?: number;
  createdAt: string;
  completedAt?: string;
  items: ExportJobItem[];
};

type DownloadJobMetrics = {
  attempts: number;
  retries: number;
  success: number;
  failed: number;
  totalDurationMs: number;
  lastError?: string;
};

type DownloadCenterAlert = {
  level: "warn" | "critical";
  code: string;
  currentValue: string;
  threshold: string;
  message: string;
  suggestion: string;
};

type DownloadCenterStats = {
  backendTotalRetry: number;
  backendFailedJobs: number;
  backendAvgDurationMs: number;
  backendFailedRate: number;
  backendRetryPerJob: number;
  localAttempts: number;
  localRetries: number;
  localSuccess: number;
  localFailed: number;
  localFailedRate: number;
  localRetryRate: number;
};

type AlertBatchPayload = {
  signature: string;
  alerts: DownloadCenterAlert[];
  stats: DownloadCenterStats;
  createdAt: number;
};

const DOWNLOAD_ALERT_THRESHOLDS = {
  backendFailedJobRate: 0.15,
  backendAvgDurationMs: 90_000,
  backendRetryPerJob: 2,
  frontendFailedRate: 0.1,
  frontendRetryRate: 0.2,
};

const DOWNLOAD_ALERT_NOISE_CONTROL = {
  debounceMs: 12_000,
  cooldownMs: 90_000,
  maxAlertsPerBatch: 8,
};

export default function OfflineAuditPage() {
  const { toast } = useToast();
  const [loading, setLoading] = useState(true);
  const [rows, setRows] = useState<OfflineAuditLogRow[]>([]);
  const [total, setTotal] = useState(0);
  const [page, setPage] = useState(1);
  const [pageSize] = useState(20);
  const [source, setSource] = useState<"database" | "memory">("memory");
  const [targetFilter, setTargetFilter] = useState<string>("");
  const [actionFilter, setActionFilter] = useState<string>("");
  const [actionSourceFilter, setActionSourceFilter] = useState<string>("");
  const [executionResultFilter, setExecutionResultFilter] = useState<string>("");
  const [actionTypeFilter, setActionTypeFilter] = useState<string>("");
  const [detailOpen, setDetailOpen] = useState(false);
  const [detailRow, setDetailRow] = useState<OfflineAuditLogRow | null>(null);
  const [exporting, setExporting] = useState<"" | "json" | "csv">("");
  const [chunkExporting, setChunkExporting] = useState<"" | "json" | "csv">("");
  const [includeArchivedExport, setIncludeArchivedExport] = useState(true);
  const [jobsLoading, setJobsLoading] = useState(false);
  const [jobs, setJobs] = useState<ExportJob[]>([]);
  const [creatingJob, setCreatingJob] = useState<"" | "json" | "csv">("");
  const [jobSearch, setJobSearch] = useState("");
  const [jobStatusFilter, setJobStatusFilter] = useState<string>("");
  const [cancellingJobId, setCancellingJobId] = useState("");
  const [batchDownloadingJobId, setBatchDownloadingJobId] = useState("");
  const [downloadingItemKey, setDownloadingItemKey] = useState("");
  const [downloadStats, setDownloadStats] = useState<Record<string, DownloadJobMetrics>>({});
  const [replayingDeadLetterJobId, setReplayingDeadLetterJobId] = useState("");
  const alertDebounceTimerRef = useRef<ReturnType<typeof setTimeout> | null>(null);
  const pendingAlertBatchesRef = useRef<AlertBatchPayload[]>([]);
  const alertCooldownRef = useRef<Record<string, number>>({});

  const load = useCallback(async () => {
    setLoading(true);
    try {
      const qs = new URLSearchParams();
      qs.set("page", String(page));
      qs.set("pageSize", String(pageSize));
      if (targetFilter) qs.set("target", targetFilter);
      if (actionFilter) qs.set("action", actionFilter);
      if (actionSourceFilter) qs.set("actionSource", actionSourceFilter);
      if (executionResultFilter) qs.set("executionResult", executionResultFilter);
      if (actionTypeFilter) qs.set("actionType", actionTypeFilter);

      const res = await fetch(`/api/offline-admin/audit?${qs.toString()}`, {
        credentials: "include",
        cache: "no-store",
      });
      const json: ListResponse = await res.json();
      if (!res.ok || !json.ok || !json.data) {
        toast({
          title: "加载失败",
          description: json.error || `HTTP ${res.status}`,
          variant: "destructive",
        });
        setRows([]);
        setTotal(0);
        return;
      }
      setRows(json.data.rows);
      setTotal(json.data.total);
      setSource(json.data.source);
    } catch {
      toast({
        title: "加载失败",
        description: "网络错误",
        variant: "destructive",
      });
      setRows([]);
      setTotal(0);
    } finally {
      setLoading(false);
    }
  }, [page, pageSize, targetFilter, actionFilter, actionSourceFilter, executionResultFilter, actionTypeFilter, toast]);

  useEffect(() => {
    load();
  }, [load]);

  const totalPages = Math.max(1, Math.ceil(total / pageSize));

  const formatTime = (iso: string) => {
    try {
      return new Date(iso).toLocaleString("zh-CN");
    } catch {
      return iso;
    }
  };

  const formatDuration = (ms?: number) => {
    if (!ms || ms <= 0) return "—";
    if (ms < 1000) return `${ms}ms`;
    return `${(ms / 1000).toFixed(2)}s`;
  };

  const updateDownloadMetrics = useCallback(
    (
      jobId: string,
      patch: Partial<DownloadJobMetrics> & { retriesDelta?: number; attemptsDelta?: number; successDelta?: number; failedDelta?: number },
    ) => {
      setDownloadStats((prev) => {
        const current = prev[jobId] || {
          attempts: 0,
          retries: 0,
          success: 0,
          failed: 0,
          totalDurationMs: 0,
        };
        return {
          ...prev,
          [jobId]: {
            attempts: current.attempts + (patch.attemptsDelta || 0),
            retries: current.retries + (patch.retriesDelta || 0),
            success: current.success + (patch.successDelta || 0),
            failed: current.failed + (patch.failedDelta || 0),
            totalDurationMs: current.totalDurationMs + (patch.totalDurationMs || 0),
            lastError: patch.lastError ?? current.lastError,
          },
        };
      });
    },
    [],
  );

  const openDetail = (row: OfflineAuditLogRow) => {
    setDetailRow(row);
    setDetailOpen(true);
  };

  const loadExportJobs = useCallback(async () => {
    setJobsLoading(true);
    try {
      const qs = new URLSearchParams();
      qs.set("limit", "30");
      if (jobSearch.trim()) qs.set("q", jobSearch.trim());
      if (jobStatusFilter) qs.set("status", jobStatusFilter);
      const response = await fetch(`/api/offline-admin/audit/export-jobs?${qs.toString()}`, {
        credentials: "include",
        cache: "no-store",
      });
      const json = await response.json();
      if (!response.ok || !json?.ok) {
        throw new Error(json?.error || `HTTP ${response.status}`);
      }
      setJobs(json?.data?.jobs || []);
    } catch (error) {
      toast({
        title: "加载导出任务失败",
        description: error instanceof Error ? error.message : "未知错误",
        variant: "destructive",
      });
    } finally {
      setJobsLoading(false);
    }
  }, [jobSearch, jobStatusFilter, toast]);

  useEffect(() => {
    void loadExportJobs();
  }, [loadExportJobs]);

  const createExportJob = async (format: "json" | "csv") => {
    setCreatingJob(format);
    try {
      const response = await fetch("/api/offline-admin/audit/export-jobs", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        credentials: "include",
        body: JSON.stringify({
          format,
          chunkSize: 1000,
          includeArchived: includeArchivedExport,
          filters: {
            target: targetFilter || undefined,
            action: actionFilter || undefined,
            actionSource: actionSourceFilter || undefined,
            executionResult: executionResultFilter || undefined,
            actionType: actionTypeFilter || undefined,
          },
        }),
      });
      const json = await response.json();
      if (!response.ok || !json?.ok) {
        throw new Error(json?.error || `HTTP ${response.status}`);
      }
      toast({
        title: "导出任务已创建",
        description: "可在下载中心查看进度与分片文件",
      });
      await loadExportJobs();
    } catch (error) {
      toast({
        title: "创建导出任务失败",
        description: error instanceof Error ? error.message : "未知错误",
        variant: "destructive",
      });
    } finally {
      setCreatingJob("");
    }
  };

  const sleep = (ms: number) => new Promise((resolve) => setTimeout(resolve, ms));

  const downloadJobItemWithRetry = async (item: ExportJobItem, retries = 3) => {
    const url = `/api/offline-admin/audit?${item.downloadQuery}`;
    let attempt = 0;
    const startedAt = Date.now();
    while (attempt <= retries) {
      try {
        const response = await fetch(url, {
          credentials: "include",
          cache: "no-store",
        });
        if (response.ok) {
          const blob = await response.blob();
          const downloadUrl = URL.createObjectURL(blob);
          const link = document.createElement("a");
          link.href = downloadUrl;
          link.download = item.filename;
          document.body.appendChild(link);
          link.click();
          link.remove();
          URL.revokeObjectURL(downloadUrl);
          return {
            attempts: attempt + 1,
            retries: Math.max(0, attempt),
            durationMs: Date.now() - startedAt,
          };
        }

        const retryAfter = Number(response.headers.get("Retry-After") || "0");
        const shouldRetry = response.status === 429 || response.status >= 500;
        if (!shouldRetry || attempt >= retries) {
          throw new Error(`HTTP ${response.status}`);
        }
        const backoffMs = retryAfter > 0 ? retryAfter * 1000 : 400 * Math.pow(2, attempt);
        await sleep(backoffMs);
      } catch (error) {
        if (attempt >= retries) {
          throw {
            error: error instanceof Error ? error : new Error("download_failed"),
            attempts: attempt + 1,
            retries: Math.max(0, attempt),
            durationMs: Date.now() - startedAt,
          };
        }
        await sleep(400 * Math.pow(2, attempt));
      }
      attempt += 1;
    }
    return {
      attempts: attempt,
      retries: Math.max(0, attempt - 1),
      durationMs: Date.now() - startedAt,
    };
  };

  const downloadSingleItem = async (jobId: string, item: ExportJobItem) => {
    const key = `${jobId}-${item.partNo}`;
    setDownloadingItemKey(key);
    try {
      const stat = await downloadJobItemWithRetry(item, 3);
      updateDownloadMetrics(jobId, {
        attemptsDelta: stat.attempts,
        retriesDelta: stat.retries,
        successDelta: 1,
        totalDurationMs: stat.durationMs,
      });
      toast({
        title: "下载成功",
        description: `${item.filename} 已下载`,
      });
    } catch (error) {
      const errObj = error as { error?: Error; attempts?: number; retries?: number; durationMs?: number };
      const reason =
        errObj?.error instanceof Error
          ? errObj.error.message
          : error instanceof Error
            ? error.message
            : "未知错误";
      updateDownloadMetrics(jobId, {
        attemptsDelta: errObj.attempts || 1,
        retriesDelta: errObj.retries || 0,
        failedDelta: 1,
        totalDurationMs: errObj.durationMs || 0,
        lastError: reason,
      });
      toast({
        title: "下载失败",
        description: `${item.filename} 下载失败：${reason}`,
        variant: "destructive",
      });
    } finally {
      setDownloadingItemKey("");
    }
  };

  const downloadAllJobItems = async (job: ExportJob) => {
    if (!job.items.length) return;
    setBatchDownloadingJobId(job.id);
    try {
      for (const item of job.items) {
        const stat = await downloadJobItemWithRetry(item, 3);
        updateDownloadMetrics(job.id, {
          attemptsDelta: stat.attempts,
          retriesDelta: stat.retries,
          successDelta: 1,
          totalDurationMs: stat.durationMs,
        });
        await sleep(220);
      }
      toast({
        title: "批量下载完成",
        description: `任务 ${job.id} 的 ${job.items.length} 个分片下载完成`,
      });
    } catch (error) {
      const errObj = error as { error?: Error; attempts?: number; retries?: number; durationMs?: number };
      const reason =
        errObj?.error instanceof Error
          ? errObj.error.message
          : error instanceof Error
            ? error.message
            : "未知错误";
      updateDownloadMetrics(job.id, {
        attemptsDelta: errObj.attempts || 1,
        retriesDelta: errObj.retries || 0,
        failedDelta: 1,
        totalDurationMs: errObj.durationMs || 0,
        lastError: reason,
      });
      toast({
        title: "批量下载失败",
        description: reason,
        variant: "destructive",
      });
    } finally {
      setBatchDownloadingJobId("");
    }
  };

  const cancelJob = async (jobId: string) => {
    setCancellingJobId(jobId);
    try {
      const response = await fetch(`/api/offline-admin/audit/export-jobs?jobId=${encodeURIComponent(jobId)}`, {
        method: "DELETE",
        credentials: "include",
      });
      const json = await response.json();
      if (!response.ok || !json?.ok) {
        throw new Error(json?.error || `HTTP ${response.status}`);
      }
      toast({
        title: "任务已取消",
        description: `任务 ${jobId} 已标记为取消`,
      });
      await loadExportJobs();
    } catch (error) {
      toast({
        title: "取消任务失败",
        description: error instanceof Error ? error.message : "未知错误",
        variant: "destructive",
      });
    } finally {
      setCancellingJobId("");
    }
  };

  const replayDeadLetterJob = async (jobId: string) => {
    if (!jobId) return;
    setReplayingDeadLetterJobId(jobId);
    try {
      const response = await fetch("/api/offline-admin/audit/alerts/replay", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        credentials: "include",
        body: JSON.stringify({ jobId }),
      });
      const json = await response.json();
      if (!response.ok || !json?.ok) {
        throw new Error(json?.error || `HTTP ${response.status}`);
      }
      toast({
        title: "死信重放已触发",
        description: `原任务 ${jobId} 已进入重放队列`,
      });
      await load();
    } catch (error) {
      toast({
        title: "死信重放失败",
        description: error instanceof Error ? error.message : "未知错误",
        variant: "destructive",
      });
    } finally {
      setReplayingDeadLetterJobId("");
    }
  };

  const exportAudit = async (format: "json" | "csv") => {
    setExporting(format);
    try {
      const qs = new URLSearchParams();
      qs.set("mode", "export");
      qs.set("format", format);
      qs.set("limit", "5000");
      qs.set("offset", "0");
      qs.set("includeArchived", includeArchivedExport ? "true" : "false");
      if (targetFilter) qs.set("target", targetFilter);
      if (actionFilter) qs.set("action", actionFilter);
      if (actionSourceFilter) qs.set("actionSource", actionSourceFilter);
      if (executionResultFilter) qs.set("executionResult", executionResultFilter);
      if (actionTypeFilter) qs.set("actionType", actionTypeFilter);

      const response = await fetch(`/api/offline-admin/audit?${qs.toString()}`, {
        credentials: "include",
        cache: "no-store",
      });
      if (!response.ok) {
        throw new Error(`导出失败: HTTP ${response.status}`);
      }
      const blob = await response.blob();
      const ext = format === "csv" ? "csv" : "json";
      const url = URL.createObjectURL(blob);
      const link = document.createElement("a");
      link.href = url;
      link.download = `offline-audit-export-${Date.now()}.${ext}`;
      document.body.appendChild(link);
      link.click();
      link.remove();
      URL.revokeObjectURL(url);
      toast({
        title: "导出成功",
        description: `已导出 ${format.toUpperCase()} 文件`,
      });
    } catch (error) {
      toast({
        title: "导出失败",
        description: error instanceof Error ? error.message : "未知错误",
        variant: "destructive",
      });
    } finally {
      setExporting("");
    }
  };

  const exportAuditChunked = async (format: "json" | "csv") => {
    setChunkExporting(format);
    const chunkSize = 1000;
    let offset = 0;
    let part = 1;
    try {
      while (true) {
        const qs = new URLSearchParams();
        qs.set("mode", "export");
        qs.set("format", format);
        qs.set("limit", String(chunkSize));
        qs.set("offset", String(offset));
        qs.set("includeArchived", includeArchivedExport ? "true" : "false");
        if (targetFilter) qs.set("target", targetFilter);
        if (actionFilter) qs.set("action", actionFilter);
        if (actionSourceFilter) qs.set("actionSource", actionSourceFilter);
        if (executionResultFilter) qs.set("executionResult", executionResultFilter);
        if (actionTypeFilter) qs.set("actionType", actionTypeFilter);

        const response = await fetch(`/api/offline-admin/audit?${qs.toString()}`, {
          credentials: "include",
          cache: "no-store",
        });
        if (!response.ok) {
          throw new Error(`分片导出失败: HTTP ${response.status}`);
        }

        if (format === "json") {
          const json = await response.json();
          if (!json?.ok || !json?.data?.rows) {
            throw new Error("分片导出失败: 无效 JSON 响应");
          }
          const blob = new Blob([JSON.stringify(json.data, null, 2)], {
            type: "application/json;charset=utf-8",
          });
          const url = URL.createObjectURL(blob);
          const link = document.createElement("a");
          link.href = url;
          link.download = `offline-audit-export-part-${part}.json`;
          document.body.appendChild(link);
          link.click();
          link.remove();
          URL.revokeObjectURL(url);

          if (!json.data.hasMore) break;
          offset = Number(json.data.nextOffset || 0);
        } else {
          const blob = await response.blob();
          const url = URL.createObjectURL(blob);
          const link = document.createElement("a");
          link.href = url;
          link.download = `offline-audit-export-part-${part}.csv`;
          document.body.appendChild(link);
          link.click();
          link.remove();
          URL.revokeObjectURL(url);
          const hasMore = response.headers.get("X-Offline-Audit-Has-More") === "true";
          const nextOffset = Number(response.headers.get("X-Offline-Audit-Next-Offset") || "0");
          if (!hasMore) break;
          offset = nextOffset;
        }
        part += 1;
      }

      toast({
        title: "分片导出完成",
        description: `共导出 ${part} 个分片文件`,
      });
    } catch (error) {
      toast({
        title: "分片导出失败",
        description: error instanceof Error ? error.message : "未知错误",
        variant: "destructive",
      });
    } finally {
      setChunkExporting("");
    }
  };

  const downloadCenterStats = useMemo<DownloadCenterStats>(() => {
    const backendTotalRetry = jobs.reduce((sum, job) => sum + (job.retryCount || 0), 0);
    const backendFailedJobs = jobs.filter((job) => job.status === "failed").length;
    const backendAvgDurationMs =
      jobs.filter((job) => typeof job.processingDurationMs === "number" && (job.processingDurationMs || 0) > 0)
        .reduce((sum, job, _, arr) => sum + (job.processingDurationMs || 0) / Math.max(1, arr.length), 0);

    const local = Object.values(downloadStats).reduce(
      (acc, item) => ({
        attempts: acc.attempts + item.attempts,
        retries: acc.retries + item.retries,
        success: acc.success + item.success,
        failed: acc.failed + item.failed,
      }),
      { attempts: 0, retries: 0, success: 0, failed: 0 },
    );

    return {
      backendTotalRetry,
      backendFailedJobs,
      backendAvgDurationMs: Math.round(backendAvgDurationMs),
      backendFailedRate: jobs.length > 0 ? backendFailedJobs / jobs.length : 0,
      backendRetryPerJob: jobs.length > 0 ? backendTotalRetry / jobs.length : 0,
      localAttempts: local.attempts,
      localRetries: local.retries,
      localSuccess: local.success,
      localFailed: local.failed,
      localFailedRate: local.attempts > 0 ? local.failed / local.attempts : 0,
      localRetryRate: local.attempts > 0 ? local.retries / local.attempts : 0,
    };
  }, [jobs, downloadStats]);

  const downloadCenterAlerts = useMemo<DownloadCenterAlert[]>(() => {
    const alerts: DownloadCenterAlert[] = [];

    if (jobs.length >= 5 && downloadCenterStats.backendFailedRate > DOWNLOAD_ALERT_THRESHOLDS.backendFailedJobRate) {
      alerts.push({
        level: "critical",
        code: "export_job_failed_rate_high",
        currentValue: `${(downloadCenterStats.backendFailedRate * 100).toFixed(2)}%`,
        threshold: `${(DOWNLOAD_ALERT_THRESHOLDS.backendFailedJobRate * 100).toFixed(2)}%`,
        message: "后台导出任务失败率过高",
        suggestion: "优先检查数据库负载、筛选条件复杂度和导出任务并发量",
      });
    }

    if (
      jobs.length >= 5 &&
      downloadCenterStats.backendAvgDurationMs > DOWNLOAD_ALERT_THRESHOLDS.backendAvgDurationMs
    ) {
      alerts.push({
        level: "warn",
        code: "export_job_duration_high",
        currentValue: formatDuration(downloadCenterStats.backendAvgDurationMs),
        threshold: formatDuration(DOWNLOAD_ALERT_THRESHOLDS.backendAvgDurationMs),
        message: "后台导出任务平均耗时偏高",
        suggestion: "建议缩小单任务分片大小，或减少 includeArchived 的默认范围",
      });
    }

    if (jobs.length >= 5 && downloadCenterStats.backendRetryPerJob > DOWNLOAD_ALERT_THRESHOLDS.backendRetryPerJob) {
      alerts.push({
        level: "warn",
        code: "export_job_retry_per_task_high",
        currentValue: downloadCenterStats.backendRetryPerJob.toFixed(2),
        threshold: DOWNLOAD_ALERT_THRESHOLDS.backendRetryPerJob.toFixed(2),
        message: "后台任务平均重试次数偏高",
        suggestion: "建议检查导出查询稳定性并调低单位时间内任务创建频率",
      });
    }

    if (
      downloadCenterStats.localAttempts >= 20 &&
      downloadCenterStats.localFailedRate > DOWNLOAD_ALERT_THRESHOLDS.frontendFailedRate
    ) {
      alerts.push({
        level: "critical",
        code: "download_failed_rate_high",
        currentValue: `${(downloadCenterStats.localFailedRate * 100).toFixed(2)}%`,
        threshold: `${(DOWNLOAD_ALERT_THRESHOLDS.frontendFailedRate * 100).toFixed(2)}%`,
        message: "前端下载失败率过高",
        suggestion: "建议先降低批量下载速度，必要时切换为后台导出任务模式",
      });
    }

    if (
      downloadCenterStats.localAttempts >= 20 &&
      downloadCenterStats.localRetryRate > DOWNLOAD_ALERT_THRESHOLDS.frontendRetryRate
    ) {
      alerts.push({
        level: "warn",
        code: "download_retry_rate_high",
        currentValue: `${(downloadCenterStats.localRetryRate * 100).toFixed(2)}%`,
        threshold: `${(DOWNLOAD_ALERT_THRESHOLDS.frontendRetryRate * 100).toFixed(2)}%`,
        message: "前端下载重试率偏高",
        suggestion: "建议排查网络质量与限流触发频率，必要时延长批量下载间隔",
      });
    }

    return alerts;
  }, [downloadCenterStats, jobs.length]);

  const downloadCenterAlertSignature = useMemo(() => {
    if (downloadCenterAlerts.length === 0) return "";
    return JSON.stringify(
      downloadCenterAlerts.map((alert) => ({
        code: alert.code,
        level: alert.level,
        currentValue: alert.currentValue,
      })),
    );
  }, [downloadCenterAlerts]);

  const flushAggregatedAlerts = useCallback(() => {
    const pending = pendingAlertBatchesRef.current;
    pendingAlertBatchesRef.current = [];
    if (pending.length === 0) return;

    const mergedMap = new Map<string, DownloadCenterAlert & { hitCount: number }>();
    let observedAlertCount = 0;
    for (const batch of pending) {
      for (const alert of batch.alerts) {
        observedAlertCount += 1;
        const existing = mergedMap.get(alert.code);
        if (!existing) {
          mergedMap.set(alert.code, { ...alert, hitCount: 1 });
          continue;
        }
        const keepCritical = existing.level === "critical" || alert.level === "critical";
        mergedMap.set(alert.code, {
          ...existing,
          ...alert,
          level: keepCritical ? "critical" : "warn",
          hitCount: existing.hitCount + 1,
        });
      }
    }

    const now = Date.now();
    const eligibleAlerts = Array.from(mergedMap.values()).filter((alert) => {
      const last = alertCooldownRef.current[alert.code] || 0;
      const cooledDown = now - last >= DOWNLOAD_ALERT_NOISE_CONTROL.cooldownMs;
      if (cooledDown) {
        alertCooldownRef.current[alert.code] = now;
      }
      return cooledDown;
    });

    const suppressedCount = mergedMap.size - eligibleAlerts.length;
    if (eligibleAlerts.length === 0) return;

    const limitedAlerts = eligibleAlerts.slice(0, DOWNLOAD_ALERT_NOISE_CONTROL.maxAlertsPerBatch);
    const criticalCount = limitedAlerts.filter((item) => item.level === "critical").length;
    const latestStats = pending[pending.length - 1]?.stats || downloadCenterStats;

    toast({
      title: criticalCount > 0 ? "下载中心触发严重告警（聚合）" : "下载中心触发告警（聚合）",
      description: `窗口聚合 ${observedAlertCount} 条，实际通知 ${limitedAlerts.length} 条，冷却抑制 ${suppressedCount} 条`,
      variant: criticalCount > 0 ? "destructive" : "default",
    });

    const reportSignature = JSON.stringify(
      limitedAlerts.map((alert) => ({
        code: alert.code,
        level: alert.level,
        currentValue: alert.currentValue,
      })),
    );

    void fetch("/api/offline-admin/audit/alerts", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      credentials: "include",
      body: JSON.stringify({
        signature: reportSignature,
        alerts: limitedAlerts.map(({ hitCount, ...rest }) => ({
          ...rest,
          hitCount,
        })),
        stats: latestStats,
        aggregation: {
          debounceMs: DOWNLOAD_ALERT_NOISE_CONTROL.debounceMs,
          cooldownMs: DOWNLOAD_ALERT_NOISE_CONTROL.cooldownMs,
          observedAlertCount,
          mergedAlertCount: mergedMap.size,
          notifiedAlertCount: limitedAlerts.length,
          suppressedCount,
          pendingBatchCount: pending.length,
        },
        inAppNotification: {
          channel: "toast",
          delivered: true,
          displayedAt: new Date().toISOString(),
          severity: criticalCount > 0 ? "critical" : "warn",
          notifiedAlertCount: limitedAlerts.length,
        },
      }),
    })
      .then(async (response) => {
        const json = await response.json().catch(() => null);
        if (!response.ok || !json?.ok) return;
        const external = json?.data?.externalDelivery as
          | { attempted?: boolean; delivered?: boolean; skippedReason?: string; provider?: string }
          | undefined;
        if (!external?.attempted) return;
        if (external.delivered) {
          toast({
            title: "外发通知成功",
            description: `告警已推送至外部通道（${external.provider || "webhook"}）`,
          });
          return;
        }
        toast({
          title: "外发通知失败",
          description: `站内通知已送达；外部通道失败（${external.provider || "webhook"}）`,
          variant: "destructive",
        });
      })
      .catch(() => {
        // 网络异常不阻断站内告警链路
      });
  }, [downloadCenterStats, toast]);

  useEffect(() => {
    if (!downloadCenterAlertSignature) return;
    pendingAlertBatchesRef.current.push({
      signature: downloadCenterAlertSignature,
      alerts: downloadCenterAlerts,
      stats: downloadCenterStats,
      createdAt: Date.now(),
    });

    if (alertDebounceTimerRef.current) {
      clearTimeout(alertDebounceTimerRef.current);
    }
    alertDebounceTimerRef.current = setTimeout(() => {
      flushAggregatedAlerts();
      alertDebounceTimerRef.current = null;
    }, DOWNLOAD_ALERT_NOISE_CONTROL.debounceMs);
  }, [downloadCenterAlertSignature, downloadCenterAlerts, downloadCenterStats, flushAggregatedAlerts]);

  useEffect(() => {
    return () => {
      if (alertDebounceTimerRef.current) {
        clearTimeout(alertDebounceTimerRef.current);
      }
    };
  }, []);

  return (
    <div className="space-y-6 p-6">
      <Card>
        <CardHeader>
          <CardTitle>离线实验与 SW 配置审计</CardTitle>
          <CardDescription>
            查看管理员对离线实验配置、Service Worker 配置的变更记录（操作者、目标、变更前后快照）。
            未配置数据库时仅保留最近约 500 条内存记录；生产环境请设置{" "}
            <code className="rounded bg-muted px-1 py-0.5 text-xs">OFFLINE_EVENTS_DATABASE_URL</code>{" "}
            或 <code className="rounded bg-muted px-1 py-0.5 text-xs">DATABASE_URL</code>。
          </CardDescription>
        </CardHeader>
        <CardContent className="flex flex-wrap items-end gap-4">
          <div className="space-y-2">
            <label className="text-sm text-muted-foreground">目标</label>
            <Select
              value={targetFilter || "__all__"}
              onValueChange={(v) => {
                setTargetFilter(v === "__all__" ? "" : v);
                setPage(1);
              }}
            >
              <SelectTrigger className="w-[220px]">
                <SelectValue placeholder="全部" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="__all__">全部</SelectItem>
                <SelectItem value="offline_experiment_config">offline_experiment_config</SelectItem>
                <SelectItem value="offline_sw_config">offline_sw_config</SelectItem>
                <SelectItem value="offline_download_center_alert">offline_download_center_alert</SelectItem>
              </SelectContent>
            </Select>
          </div>
          <div className="space-y-2">
            <label className="text-sm text-muted-foreground">动作</label>
            <Select
              value={actionFilter || "__all__"}
              onValueChange={(v) => {
                setActionFilter(v === "__all__" ? "" : v);
                setPage(1);
              }}
            >
              <SelectTrigger className="w-[160px]">
                <SelectValue placeholder="全部" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="__all__">全部</SelectItem>
                <SelectItem value="update">update</SelectItem>
                <SelectItem value="rollback">rollback</SelectItem>
                <SelectItem value="alert">alert</SelectItem>
                <SelectItem value="dead_letter">dead_letter</SelectItem>
                <SelectItem value="replay_dead_letter">replay_dead_letter</SelectItem>
              </SelectContent>
            </Select>
          </div>
          <div className="space-y-2">
            <label className="text-sm text-muted-foreground">来源</label>
            <Select
              value={actionSourceFilter || "__all__"}
              onValueChange={(v) => {
                setActionSourceFilter(v === "__all__" ? "" : v);
                setPage(1);
              }}
            >
              <SelectTrigger className="w-[220px]">
                <SelectValue placeholder="全部" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="__all__">全部</SelectItem>
                <SelectItem value="manual_admin_ui">manual_admin_ui</SelectItem>
                <SelectItem value="offline_report_action">offline_report_action</SelectItem>
              </SelectContent>
            </Select>
          </div>
          <div className="space-y-2">
            <label className="text-sm text-muted-foreground">结果</label>
            <Select
              value={executionResultFilter || "__all__"}
              onValueChange={(v) => {
                setExecutionResultFilter(v === "__all__" ? "" : v);
                setPage(1);
              }}
            >
              <SelectTrigger className="w-[160px]">
                <SelectValue placeholder="全部" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="__all__">全部</SelectItem>
                <SelectItem value="success">success</SelectItem>
                <SelectItem value="failed">failed</SelectItem>
              </SelectContent>
            </Select>
          </div>
          <div className="space-y-2">
            <label className="text-sm text-muted-foreground">动作类型</label>
            <Select
              value={actionTypeFilter || "__all__"}
              onValueChange={(v) => {
                setActionTypeFilter(v === "__all__" ? "" : v);
                setPage(1);
              }}
            >
              <SelectTrigger className="w-[230px]">
                <SelectValue placeholder="全部" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="__all__">全部</SelectItem>
                <SelectItem value="rollback_version">rollback_version</SelectItem>
                <SelectItem value="route_investigation">route_investigation</SelectItem>
                <SelectItem value="cache_policy_tuning">cache_policy_tuning</SelectItem>
                <SelectItem value="recovery_experience_tuning">recovery_experience_tuning</SelectItem>
                <SelectItem value="download_center_alert">download_center_alert</SelectItem>
                <SelectItem value="download_center_dead_letter">download_center_dead_letter</SelectItem>
                <SelectItem value="download_center_dead_letter_replay">download_center_dead_letter_replay</SelectItem>
              </SelectContent>
            </Select>
          </div>
          <Button variant="outline" size="sm" onClick={() => void load()} disabled={loading}>
            刷新
          </Button>
          <Button
            variant="outline"
            size="sm"
            onClick={() => void exportAudit("json")}
            disabled={loading || exporting !== "" || chunkExporting !== ""}
          >
            {exporting === "json" ? "导出中..." : "导出 JSON"}
          </Button>
          <Button
            variant="outline"
            size="sm"
            onClick={() => void exportAudit("csv")}
            disabled={loading || exporting !== "" || chunkExporting !== ""}
          >
            {exporting === "csv" ? "导出中..." : "导出 CSV"}
          </Button>
          <Button
            variant="outline"
            size="sm"
            onClick={() => void exportAuditChunked("json")}
            disabled={loading || exporting !== "" || chunkExporting !== ""}
          >
            {chunkExporting === "json" ? "分片导出中..." : "分片导出 JSON"}
          </Button>
          <Button
            variant="outline"
            size="sm"
            onClick={() => void exportAuditChunked("csv")}
            disabled={loading || exporting !== "" || chunkExporting !== ""}
          >
            {chunkExporting === "csv" ? "分片导出中..." : "分片导出 CSV"}
          </Button>
          <Button
            variant="outline"
            size="sm"
            onClick={() => void createExportJob("json")}
            disabled={loading || creatingJob !== ""}
          >
            {creatingJob === "json" ? "创建中..." : "创建 JSON 导出任务"}
          </Button>
          <Button
            variant="outline"
            size="sm"
            onClick={() => void createExportJob("csv")}
            disabled={loading || creatingJob !== ""}
          >
            {creatingJob === "csv" ? "创建中..." : "创建 CSV 导出任务"}
          </Button>
          <Button
            variant={includeArchivedExport ? "default" : "outline"}
            size="sm"
            onClick={() => setIncludeArchivedExport((v) => !v)}
            disabled={loading || exporting !== "" || chunkExporting !== ""}
          >
            {includeArchivedExport ? "导出含归档" : "导出仅热数据"}
          </Button>
          <div className="ml-auto flex items-center gap-2 text-sm text-muted-foreground">
            存储：
            <Badge variant={source === "database" ? "default" : "secondary"}>
              {source === "database" ? "PostgreSQL" : "内存（开发/未持久化）"}
            </Badge>
          </div>
        </CardContent>
      </Card>

      <Card>
        <CardContent className="p-0">
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead className="w-[180px]">时间</TableHead>
                <TableHead>操作者</TableHead>
                <TableHead>动作</TableHead>
                <TableHead>动作类型</TableHead>
                <TableHead>目标</TableHead>
                <TableHead>来源</TableHead>
                <TableHead>结果</TableHead>
                <TableHead>来源 IP</TableHead>
                <TableHead className="w-[100px]">详情</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {loading ? (
                <TableRow>
                  <TableCell colSpan={9} className="text-center text-muted-foreground">
                    加载中…
                  </TableCell>
                </TableRow>
              ) : rows.length === 0 ? (
                <TableRow>
                  <TableCell colSpan={9} className="text-center text-muted-foreground">
                    暂无记录
                  </TableCell>
                </TableRow>
              ) : (
                rows.map((row) => (
                  <TableRow key={row.id}>
                    <TableCell className="whitespace-nowrap text-sm">
                      {formatTime(row.createdAt)}
                    </TableCell>
                    <TableCell className="max-w-[200px] truncate text-sm" title={row.actor}>
                      {row.actor}
                    </TableCell>
                    <TableCell>
                      <Badge variant="outline">{row.action}</Badge>
                    </TableCell>
                    <TableCell className="font-mono text-xs">
                      {row.actionType || "—"}
                    </TableCell>
                    <TableCell className="font-mono text-xs">{row.target}</TableCell>
                    <TableCell className="font-mono text-xs">{row.actionSource}</TableCell>
                    <TableCell>
                      <Badge variant={row.executionResult === "success" ? "secondary" : "destructive"}>
                        {row.executionResult}
                      </Badge>
                    </TableCell>
                    <TableCell className="text-xs text-muted-foreground">{row.sourceIp}</TableCell>
                    <TableCell>
                      <Button variant="ghost" size="sm" onClick={() => openDetail(row)}>
                        <Eye className="mr-1 h-4 w-4" />
                        查看
                      </Button>
                    </TableCell>
                  </TableRow>
                ))
              )}
            </TableBody>
          </Table>
        </CardContent>
      </Card>

      <div className="flex items-center justify-between">
        <p className="text-sm text-muted-foreground">
          共 {total} 条，第 {page} / {totalPages} 页
        </p>
        <div className="flex gap-2">
          <Button
            variant="outline"
            size="sm"
            disabled={page <= 1 || loading}
            onClick={() => setPage((p) => Math.max(1, p - 1))}
          >
            <ChevronLeft className="h-4 w-4" />
            上一页
          </Button>
          <Button
            variant="outline"
            size="sm"
            disabled={page >= totalPages || loading}
            onClick={() => setPage((p) => p + 1)}
          >
            下一页
            <ChevronRight className="h-4 w-4" />
          </Button>
        </div>
      </div>

      <Card>
        <CardHeader>
          <CardTitle>导出下载中心</CardTitle>
          <CardDescription>后台任务化导出，支持分片下载与状态追踪</CardDescription>
        </CardHeader>
        <CardContent className="space-y-3">
          <div className="grid grid-cols-1 gap-3 md:grid-cols-4">
            <div className="rounded border p-3 text-sm">
              <div className="text-muted-foreground">任务平均耗时</div>
              <div className="font-medium">{formatDuration(downloadCenterStats.backendAvgDurationMs)}</div>
            </div>
            <div className="rounded border p-3 text-sm">
              <div className="text-muted-foreground">后台任务重试次数</div>
              <div className="font-medium">{downloadCenterStats.backendTotalRetry}</div>
            </div>
            <div className="rounded border p-3 text-sm">
              <div className="text-muted-foreground">后台失败任务数</div>
              <div className="font-medium">{downloadCenterStats.backendFailedJobs}</div>
            </div>
            <div className="rounded border p-3 text-sm">
              <div className="text-muted-foreground">前端下载重试次数</div>
              <div className="font-medium">{downloadCenterStats.localRetries}</div>
            </div>
          </div>
          <div className="rounded border p-3">
            <div className="mb-2 text-sm font-medium">告警规则状态</div>
            {downloadCenterAlerts.length === 0 ? (
              <div className="text-sm text-muted-foreground">当前未触发失败率/超时阈值告警</div>
            ) : (
              <div className="space-y-2">
                {downloadCenterAlerts.map((alert) => (
                  <div key={alert.code} className="rounded border p-2 text-sm">
                    <div className="flex items-center gap-2">
                      <Badge variant={alert.level === "critical" ? "destructive" : "secondary"}>
                        {alert.level.toUpperCase()}
                      </Badge>
                      <span className="font-medium">{alert.code}</span>
                    </div>
                    <div className="mt-1 text-muted-foreground">{alert.message}</div>
                    <div className="mt-1 text-muted-foreground">
                      当前值 {alert.currentValue} / 阈值 {alert.threshold}
                    </div>
                    <div className="mt-1">{alert.suggestion}</div>
                  </div>
                ))}
              </div>
            )}
          </div>
          <div className="flex flex-wrap items-center gap-2">
            <input
              value={jobSearch}
              onChange={(e) => setJobSearch(e.target.value)}
              placeholder="搜索任务ID/执行人/IP"
              className="h-9 w-[240px] rounded-md border px-3 text-sm"
            />
            <Select
              value={jobStatusFilter || "__all__"}
              onValueChange={(v) => setJobStatusFilter(v === "__all__" ? "" : v)}
            >
              <SelectTrigger className="w-[180px]">
                <SelectValue placeholder="全部状态" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="__all__">全部状态</SelectItem>
                <SelectItem value="pending">pending</SelectItem>
                <SelectItem value="processing">processing</SelectItem>
                <SelectItem value="completed">completed</SelectItem>
                <SelectItem value="failed">failed</SelectItem>
                <SelectItem value="cancelled">cancelled</SelectItem>
              </SelectContent>
            </Select>
            <Button variant="outline" size="sm" onClick={() => void loadExportJobs()} disabled={jobsLoading}>
              {jobsLoading ? "刷新中..." : "刷新任务列表"}
            </Button>
            <span className="text-sm text-muted-foreground">最近 {jobs.length} 个任务</span>
          </div>
          {jobs.length === 0 ? (
            <div className="text-sm text-muted-foreground">暂无导出任务</div>
          ) : (
            jobs.map((job) => (
              <div
                key={job.id}
                className={`rounded border p-3 text-sm ${
                  (job.processingDurationMs || 0) > DOWNLOAD_ALERT_THRESHOLDS.backendAvgDurationMs
                    ? "border-yellow-400"
                    : ""
                }`}
              >
                <div className="flex flex-wrap items-center gap-2">
                  <Badge
                    variant={
                      job.status === "completed"
                        ? "secondary"
                        : job.status === "failed"
                          ? "destructive"
                          : job.status === "cancelled"
                            ? "outline"
                            : "outline"
                    }
                  >
                    {job.status}
                  </Badge>
                  <span className="font-mono text-xs">{job.id}</span>
                  <span className="text-muted-foreground">
                    {job.format.toUpperCase()} / 分片 {job.totalChunks} / 总行数 {job.totalRows}
                  </span>
                </div>
                <div className="mt-1 text-xs text-muted-foreground">
                  创建时间：{formatTime(job.createdAt)}，完成时间：{job.completedAt ? formatTime(job.completedAt) : "—"}
                </div>
                <div className="mt-1 text-xs text-muted-foreground">
                  任务处理耗时：{formatDuration(job.processingDurationMs)}，任务重试：{job.retryCount || 0} 次
                </div>
                {job.errorMessage && (
                  <div className="mt-1 text-xs text-red-500">错误：{job.errorMessage}</div>
                )}
                {downloadStats[job.id] && (
                  <div className="mt-1 text-xs text-muted-foreground">
                    下载统计：尝试 {downloadStats[job.id].attempts} 次，重试 {downloadStats[job.id].retries} 次，
                    成功 {downloadStats[job.id].success}，失败 {downloadStats[job.id].failed}
                    {downloadStats[job.id].lastError ? `，最近失败原因：${downloadStats[job.id].lastError}` : ""}
                  </div>
                )}
                {job.status === "completed" && job.items.length > 0 && (
                  <div className="mt-2 flex flex-wrap gap-2">
                    <Button
                      size="sm"
                      onClick={() => void downloadAllJobItems(job)}
                      disabled={batchDownloadingJobId === job.id || downloadingItemKey !== ""}
                    >
                      {batchDownloadingJobId === job.id ? "批量下载中..." : "批量下载全部分片"}
                    </Button>
                    {job.items.map((item) => (
                      <Button
                        key={`${job.id}-${item.partNo}`}
                        size="sm"
                        variant="outline"
                        disabled={batchDownloadingJobId === job.id || downloadingItemKey === `${job.id}-${item.partNo}`}
                        onClick={() => void downloadSingleItem(job.id, item)}
                      >
                        {downloadingItemKey === `${job.id}-${item.partNo}` ? "下载中..." : `下载分片 #${item.partNo}`}
                      </Button>
                    ))}
                  </div>
                )}
                {(job.status === "pending" || job.status === "processing") && (
                  <div className="mt-2">
                    <Button
                      size="sm"
                      variant="destructive"
                      onClick={() => void cancelJob(job.id)}
                      disabled={cancellingJobId === job.id}
                    >
                      {cancellingJobId === job.id ? "取消中..." : "取消任务"}
                    </Button>
                  </div>
                )}
              </div>
            ))
          )}
        </CardContent>
      </Card>

      <Dialog open={detailOpen} onOpenChange={setDetailOpen}>
        <DialogContent className="max-w-3xl">
          <DialogHeader>
            <DialogTitle>变更详情</DialogTitle>
          </DialogHeader>
          {detailRow && (
            <div className="space-y-3 text-sm">
              <div className="grid grid-cols-2 gap-2 text-muted-foreground">
                <span>请求 ID：{detailRow.requestId || "—"}</span>
                <span>时间：{formatTime(detailRow.createdAt)}</span>
                <span>来源：{detailRow.actionSource || "manual_admin_ui"}</span>
                <span>结果：{detailRow.executionResult || "success"}</span>
                <span>动作类型：{detailRow.actionType || "—"}</span>
              </div>
              {detailRow.actionType === "download_center_dead_letter" && (
                <div className="flex items-center gap-2">
                  <Button
                    size="sm"
                    onClick={() => {
                      const idFromAfterData =
                        detailRow.afterData &&
                        typeof detailRow.afterData === "object" &&
                        "queueJobId" in (detailRow.afterData as Record<string, unknown>)
                          ? String((detailRow.afterData as Record<string, unknown>).queueJobId || "")
                          : "";
                      void replayDeadLetterJob(idFromAfterData);
                    }}
                    disabled={replayingDeadLetterJobId !== ""}
                  >
                    {replayingDeadLetterJobId !== "" ? "重放中..." : "重放该死信通知"}
                  </Button>
                  <span className="text-xs text-muted-foreground">
                    仅对死信任务生效，成功后会新增一条 replay_dead_letter 审计记录。
                  </span>
                </div>
              )}
              <div>
                <p className="mb-1 font-medium">动作上下文</p>
                <ScrollArea className="h-[120px] rounded-md border bg-muted/30 p-3">
                  <pre className="whitespace-pre-wrap break-all font-mono text-xs">
                    {JSON.stringify(detailRow.actionMeta || {}, null, 2)}
                  </pre>
                </ScrollArea>
              </div>
              <div>
                <p className="mb-1 font-medium">变更前</p>
                <ScrollArea className="h-[200px] rounded-md border bg-muted/30 p-3">
                  <pre className="whitespace-pre-wrap break-all font-mono text-xs">
                    {JSON.stringify(detailRow.beforeData, null, 2)}
                  </pre>
                </ScrollArea>
              </div>
              <div>
                <p className="mb-1 font-medium">变更后</p>
                <ScrollArea className="h-[200px] rounded-md border bg-muted/30 p-3">
                  <pre className="whitespace-pre-wrap break-all font-mono text-xs">
                    {JSON.stringify(detailRow.afterData, null, 2)}
                  </pre>
                </ScrollArea>
              </div>
            </div>
          )}
        </DialogContent>
      </Dialog>
    </div>
  );
}
