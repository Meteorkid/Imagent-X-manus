'use client';

import { useEffect, useMemo, useState } from 'react';
import Link from 'next/link';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { useToast } from '@/hooks/use-toast';

interface WeeklyDashboardResponse {
  ok: boolean;
  data: {
    dashboard: {
      headline: {
        windowDays: number;
        totalEvents: number;
        sessionsCovered: number;
      };
      kpi: {
        recoveryRate: number;
        resumedAfterRecoveryRate: number;
        businessFunnelResumeRate: number;
        waitingLossRate: number;
        avgOfflineDurationMs: number;
        offlineTriggerRate: number;
        gameOpenRate: number;
        recoveryReturnRate: number;
        scriptLoadFailureRate: number;
        swCacheHitRate: number;
        swFetchFailureRate: number;
      };
      abInsights: {
        trigger: {
          winner: string;
          winnerReason: string;
          variants: Record<
            string,
            { shown: number; recovered: number; resumed: number; recoveryRate: number; resumeAfterRecoveryRate: number }
          >;
        };
        content: {
          winner: string;
          winnerReason: string;
          variants: Record<
            string,
            { shown: number; recovered: number; resumed: number; recoveryRate: number; resumeAfterRecoveryRate: number }
          >;
        };
      };
      recommendations: string[];
      actionItems: Array<{
        priority: 'P0' | 'P1' | 'P2';
        type: 'rollback_version' | 'route_investigation' | 'cache_policy_tuning' | 'recovery_experience_tuning';
        title: string;
        reason: string;
        recommendation: string;
        target: string;
        adminPath?: string;
        executeApi?: {
          endpoint: string;
          method: 'PUT' | 'POST';
          body?: Record<string, unknown>;
        };
      }>;
      alerts: Array<{
        level: 'warn' | 'critical';
        code: string;
        message: string;
        currentValue: number;
        threshold: number;
      }>;
      drilldowns: {
        byScriptVersion: Array<{
          key: string;
          events: number;
          sessions: number;
          swAlertCount: number;
          scriptLoadFailureRate: number;
          swCacheHitRate: number;
          swFetchFailureRate: number;
          recoveryReturnRate: number;
        }>;
        byRoute: Array<{
          key: string;
          events: number;
          sessions: number;
          swAlertCount: number;
          scriptLoadFailureRate: number;
          swCacheHitRate: number;
          swFetchFailureRate: number;
          recoveryReturnRate: number;
        }>;
      };
      trends: {
        byScriptVersion: Array<{
          key: string;
          totalEvents: number;
          points: Array<{
            day: string;
            events: number;
            scriptLoadFailureRate: number;
            swCacheHitRate: number;
            swFetchFailureRate: number;
            recoveryReturnRate: number;
          }>;
        }>;
        byRoute: Array<{
          key: string;
          totalEvents: number;
          points: Array<{
            day: string;
            events: number;
            scriptLoadFailureRate: number;
            swCacheHitRate: number;
            swFetchFailureRate: number;
            recoveryReturnRate: number;
          }>;
        }>;
      };
    };
  };
}

function formatPercent(value: number): string {
  return `${(value * 100).toFixed(2)}%`;
}

function formatDelta(latest: number, base: number): string {
  const diff = latest - base;
  const sign = diff > 0 ? '+' : '';
  return `${sign}${(diff * 100).toFixed(2)}%`;
}

export default function OfflineReportPage() {
  const { toast } = useToast();
  const [days, setDays] = useState(7);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [executingActionKey, setExecutingActionKey] = useState<string | null>(null);
  const [dashboard, setDashboard] = useState<WeeklyDashboardResponse['data']['dashboard'] | null>(null);

  const loadReport = async (windowDays: number) => {
    setLoading(true);
    setError(null);
    try {
      const response = await fetch(`/api/offline-events/weekly?days=${windowDays}`, {
        cache: 'no-store',
      });
      const json = (await response.json()) as WeeklyDashboardResponse;
      if (!json.ok) {
        throw new Error('接口返回失败');
      }
      setDashboard(json.data.dashboard);
    } catch (e) {
      setError(e instanceof Error ? e.message : '加载失败');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadReport(days);
  }, [days]);

  const executeAction = async (
    actionKey: string,
    actionItem: WeeklyDashboardResponse['data']['dashboard']['actionItems'][number],
    executeApi: NonNullable<WeeklyDashboardResponse['data']['dashboard']['actionItems'][number]['executeApi']>,
  ) => {
    setExecutingActionKey(actionKey);
    try {
      const response = await fetch(executeApi.endpoint, {
        method: executeApi.method,
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          ...(executeApi.body || {}),
          auditContext: {
            source: 'offline_report_action',
            actionType: actionItem.type,
            actionTitle: actionItem.title,
            actionTarget: actionItem.target,
            actionPriority: actionItem.priority,
          },
        }),
      });
      const json = await response.json();
      if (!response.ok || !json?.ok) {
        throw new Error(json?.error || `HTTP ${response.status}`);
      }
      toast({
        title: '动作执行成功',
        description: '配置已更新，报表正在刷新',
      });
      await loadReport(days);
    } catch (err) {
      toast({
        title: '动作执行失败',
        description: err instanceof Error ? err.message : '未知错误',
        variant: 'destructive',
      });
    } finally {
      setExecutingActionKey(null);
    }
  };

  const triggerRows = useMemo(() => Object.entries(dashboard?.abInsights.trigger.variants || {}), [dashboard]);
  const contentRows = useMemo(() => Object.entries(dashboard?.abInsights.content.variants || {}), [dashboard]);
  const scriptRows = useMemo(() => dashboard?.drilldowns.byScriptVersion || [], [dashboard]);
  const routeRows = useMemo(() => dashboard?.drilldowns.byRoute || [], [dashboard]);
  const scriptTrendRows = useMemo(() => dashboard?.trends.byScriptVersion || [], [dashboard]);
  const routeTrendRows = useMemo(() => dashboard?.trends.byRoute || [], [dashboard]);

  return (
    <div className="container mx-auto max-w-6xl px-4 py-8">
      <div className="mb-6 flex flex-wrap items-center justify-between gap-3">
        <div>
          <h1 className="text-3xl font-bold tracking-tight">离线体验周报看板</h1>
          <p className="text-sm text-muted-foreground">用于评估离线能力稳定性与 A/B 实验收益</p>
        </div>
        <div className="flex items-center gap-2">
          {[7, 14, 30].map((window) => (
            <Button key={window} variant={days === window ? 'default' : 'outline'} onClick={() => setDays(window)}>
              最近 {window} 天
            </Button>
          ))}
        </div>
      </div>

      {loading && <p className="text-sm text-muted-foreground">加载中...</p>}
      {error && <p className="text-sm text-red-500">{error}</p>}

      {!loading && !error && dashboard && (
        <div className="space-y-6">
          <div className="grid grid-cols-1 gap-4 md:grid-cols-6">
            <Card>
              <CardHeader className="pb-2">
                <CardDescription>恢复率</CardDescription>
                <CardTitle>{formatPercent(dashboard.kpi.recoveryRate)}</CardTitle>
              </CardHeader>
            </Card>
            <Card>
              <CardHeader className="pb-2">
                <CardDescription>恢复后继续率</CardDescription>
                <CardTitle>{formatPercent(dashboard.kpi.resumedAfterRecoveryRate)}</CardTitle>
              </CardHeader>
            </Card>
            <Card>
              <CardHeader className="pb-2">
                <CardDescription>等待流失率</CardDescription>
                <CardTitle>{formatPercent(dashboard.kpi.waitingLossRate)}</CardTitle>
              </CardHeader>
            </Card>
            <Card>
              <CardHeader className="pb-2">
                <CardDescription>业务漏斗恢复率</CardDescription>
                <CardTitle>{formatPercent(dashboard.kpi.businessFunnelResumeRate)}</CardTitle>
              </CardHeader>
            </Card>
            <Card>
              <CardHeader className="pb-2">
                <CardDescription>平均离线时长</CardDescription>
                <CardTitle>{Math.round(dashboard.kpi.avgOfflineDurationMs / 1000)}s</CardTitle>
              </CardHeader>
            </Card>
            <Card>
              <CardHeader className="pb-2">
                <CardDescription>离线触发率</CardDescription>
                <CardTitle>{formatPercent(dashboard.kpi.offlineTriggerRate)}</CardTitle>
              </CardHeader>
            </Card>
            <Card>
              <CardHeader className="pb-2">
                <CardDescription>游戏打开率</CardDescription>
                <CardTitle>{formatPercent(dashboard.kpi.gameOpenRate)}</CardTitle>
              </CardHeader>
            </Card>
            <Card>
              <CardHeader className="pb-2">
                <CardDescription>恢复后回流率</CardDescription>
                <CardTitle>{formatPercent(dashboard.kpi.recoveryReturnRate)}</CardTitle>
              </CardHeader>
            </Card>
            <Card>
              <CardHeader className="pb-2">
                <CardDescription>脚本加载失败率</CardDescription>
                <CardTitle>{formatPercent(dashboard.kpi.scriptLoadFailureRate)}</CardTitle>
              </CardHeader>
            </Card>
            <Card>
              <CardHeader className="pb-2">
                <CardDescription>SW 缓存命中率</CardDescription>
                <CardTitle>{formatPercent(dashboard.kpi.swCacheHitRate)}</CardTitle>
              </CardHeader>
            </Card>
            <Card>
              <CardHeader className="pb-2">
                <CardDescription>SW 回源失败率</CardDescription>
                <CardTitle>{formatPercent(dashboard.kpi.swFetchFailureRate)}</CardTitle>
              </CardHeader>
            </Card>
          </div>

          <div className="grid grid-cols-1 gap-6 lg:grid-cols-2">
            <Card>
              <CardHeader>
                <CardTitle>A/B：触发策略</CardTitle>
                <CardDescription>{dashboard.abInsights.trigger.winnerReason}</CardDescription>
              </CardHeader>
              <CardContent className="space-y-3">
                <Badge>当前建议：{dashboard.abInsights.trigger.winner}</Badge>
                {triggerRows.map(([key, value]) => (
                  <div key={key} className="rounded border p-3 text-sm">
                    <div className="font-medium">{key}</div>
                    <div className="text-muted-foreground">
                      展示 {value.shown} / 恢复 {value.recovered} / 继续 {value.resumed}
                    </div>
                    <div className="text-muted-foreground">
                      恢复率 {formatPercent(value.recoveryRate)}，恢复后继续率{' '}
                      {formatPercent(value.resumeAfterRecoveryRate)}
                    </div>
                  </div>
                ))}
              </CardContent>
            </Card>

            <Card>
              <CardHeader>
                <CardTitle>A/B：内容策略</CardTitle>
                <CardDescription>{dashboard.abInsights.content.winnerReason}</CardDescription>
              </CardHeader>
              <CardContent className="space-y-3">
                <Badge>当前建议：{dashboard.abInsights.content.winner}</Badge>
                {contentRows.map(([key, value]) => (
                  <div key={key} className="rounded border p-3 text-sm">
                    <div className="font-medium">{key}</div>
                    <div className="text-muted-foreground">
                      展示 {value.shown} / 恢复 {value.recovered} / 继续 {value.resumed}
                    </div>
                    <div className="text-muted-foreground">
                      恢复率 {formatPercent(value.recoveryRate)}，恢复后继续率{' '}
                      {formatPercent(value.resumeAfterRecoveryRate)}
                    </div>
                  </div>
                ))}
              </CardContent>
            </Card>
          </div>

          <Card>
            <CardHeader>
              <CardTitle>告警状态</CardTitle>
              <CardDescription>按阈值规则自动生成，便于快速发现风险</CardDescription>
            </CardHeader>
            <CardContent className="space-y-3 text-sm">
              {dashboard.alerts.length === 0 ? (
                <div className="text-muted-foreground">当前窗口内未触发告警</div>
              ) : (
                dashboard.alerts.map((alert) => (
                  <div key={alert.code} className="rounded border p-3">
                    <div className="flex items-center gap-2">
                      <Badge variant={alert.level === 'critical' ? 'destructive' : 'secondary'}>
                        {alert.level.toUpperCase()}
                      </Badge>
                      <span className="font-medium">{alert.code}</span>
                    </div>
                    <div className="mt-1 text-muted-foreground">{alert.message}</div>
                    <div className="mt-1 text-muted-foreground">
                      当前值 {alert.currentValue} / 阈值 {alert.threshold}
                    </div>
                  </div>
                ))
              )}
            </CardContent>
          </Card>

          <Card>
            <CardHeader>
              <CardTitle>自动动作建议</CardTitle>
              <CardDescription>基于告警 + 版本/路由下钻自动生成，按优先级执行</CardDescription>
            </CardHeader>
            <CardContent className="space-y-3 text-sm">
              {dashboard.actionItems.length === 0 ? (
                <div className="text-muted-foreground">当前窗口内暂无自动动作建议</div>
              ) : (
                dashboard.actionItems.map((item) => (
                  <div key={`${item.type}-${item.target}`} className="rounded border p-3">
                    <div className="flex items-center gap-2">
                      <Badge variant={item.priority === 'P0' ? 'destructive' : 'secondary'}>{item.priority}</Badge>
                      <span className="font-medium">{item.title}</span>
                    </div>
                    <div className="mt-1 text-muted-foreground">目标：{item.target}</div>
                    <div className="mt-1 text-muted-foreground">触发原因：{item.reason}</div>
                    <div className="mt-1">建议动作：{item.recommendation}</div>
                    <div className="mt-3 flex flex-wrap gap-2">
                      {item.executeApi && (
                        <Button
                          size="sm"
                          onClick={() => executeAction(`${item.type}-${item.target}`, item, item.executeApi!)}
                          disabled={executingActionKey === `${item.type}-${item.target}`}
                        >
                          {executingActionKey === `${item.type}-${item.target}` ? '执行中...' : '一键执行'}
                        </Button>
                      )}
                      {item.adminPath && (
                        <Button size="sm" variant="outline" asChild>
                          <Link href={item.adminPath}>前往管理页</Link>
                        </Button>
                      )}
                    </div>
                  </div>
                ))
              )}
            </CardContent>
          </Card>

          <div className="grid grid-cols-1 gap-6 lg:grid-cols-2">
            <Card>
              <CardHeader>
                <CardTitle>下钻：脚本版本维度</CardTitle>
                <CardDescription>用于定位某个版本导致的失败率或告警异常</CardDescription>
              </CardHeader>
              <CardContent className="space-y-3 text-sm">
                {scriptRows.length === 0 ? (
                  <div className="text-muted-foreground">暂无脚本版本维度数据</div>
                ) : (
                  scriptRows.map((row) => (
                    <div key={row.key} className="rounded border p-3">
                      <div className="flex items-center justify-between">
                        <div className="font-medium">{row.key}</div>
                        <Badge variant={row.swAlertCount > 0 ? 'destructive' : 'secondary'}>
                          告警 {row.swAlertCount}
                        </Badge>
                      </div>
                      <div className="mt-1 text-muted-foreground">
                        事件 {row.events} / 会话 {row.sessions}
                      </div>
                      <div className="mt-1 text-muted-foreground">
                        脚本失败率 {formatPercent(row.scriptLoadFailureRate)}，恢复回流率{' '}
                        {formatPercent(row.recoveryReturnRate)}
                      </div>
                      <div className="mt-1 text-muted-foreground">
                        SW 命中率 {formatPercent(row.swCacheHitRate)}，SW 回源失败率{' '}
                        {formatPercent(row.swFetchFailureRate)}
                      </div>
                    </div>
                  ))
                )}
              </CardContent>
            </Card>

          <div className="grid grid-cols-1 gap-6 lg:grid-cols-2">
            <Card>
              <CardHeader>
                <CardTitle>趋势：脚本版本（日维度）</CardTitle>
                <CardDescription>按天对比版本质量变化，便于判断是否回滚</CardDescription>
              </CardHeader>
              <CardContent className="space-y-3 text-sm">
                {scriptTrendRows.length === 0 ? (
                  <div className="text-muted-foreground">暂无脚本趋势数据</div>
                ) : (
                  scriptTrendRows.map((row) => {
                    const first = row.points[0];
                    const last = row.points[row.points.length - 1];
                    return (
                      <div key={row.key} className="rounded border p-3">
                        <div className="flex items-center justify-between">
                          <div className="font-medium">{row.key}</div>
                          <Badge variant="outline">事件 {row.totalEvents}</Badge>
                        </div>
                        <div className="mt-1 text-muted-foreground">
                          脚本失败率 {formatPercent(last?.scriptLoadFailureRate || 0)}
                          {first ? `（较首日 ${formatDelta(last?.scriptLoadFailureRate || 0, first.scriptLoadFailureRate)}）` : ''}
                        </div>
                        <div className="mt-1 text-muted-foreground">
                          SW 命中率 {formatPercent(last?.swCacheHitRate || 0)}
                          {first ? `（较首日 ${formatDelta(last?.swCacheHitRate || 0, first.swCacheHitRate)}）` : ''}
                        </div>
                        <div className="mt-1 text-muted-foreground">
                          最近采样日：{last?.day || '-'}，覆盖天数 {row.points.length}
                        </div>
                      </div>
                    );
                  })
                )}
              </CardContent>
            </Card>

            <Card>
              <CardHeader>
                <CardTitle>趋势：路由（日维度）</CardTitle>
                <CardDescription>按天对比页面路径质量变化，便于发现问题页面</CardDescription>
              </CardHeader>
              <CardContent className="space-y-3 text-sm">
                {routeTrendRows.length === 0 ? (
                  <div className="text-muted-foreground">暂无路由趋势数据</div>
                ) : (
                  routeTrendRows.map((row) => {
                    const first = row.points[0];
                    const last = row.points[row.points.length - 1];
                    return (
                      <div key={row.key} className="rounded border p-3">
                        <div className="flex items-center justify-between gap-3">
                          <div className="truncate font-medium">{row.key}</div>
                          <Badge variant="outline">事件 {row.totalEvents}</Badge>
                        </div>
                        <div className="mt-1 text-muted-foreground">
                          SW 回源失败率 {formatPercent(last?.swFetchFailureRate || 0)}
                          {first ? `（较首日 ${formatDelta(last?.swFetchFailureRate || 0, first.swFetchFailureRate)}）` : ''}
                        </div>
                        <div className="mt-1 text-muted-foreground">
                          恢复回流率 {formatPercent(last?.recoveryReturnRate || 0)}
                          {first ? `（较首日 ${formatDelta(last?.recoveryReturnRate || 0, first.recoveryReturnRate)}）` : ''}
                        </div>
                        <div className="mt-1 text-muted-foreground">
                          最近采样日：{last?.day || '-'}，覆盖天数 {row.points.length}
                        </div>
                      </div>
                    );
                  })
                )}
              </CardContent>
            </Card>
          </div>

            <Card>
              <CardHeader>
                <CardTitle>下钻：路由维度</CardTitle>
                <CardDescription>用于定位某类页面导致的告警集中与质量下降</CardDescription>
              </CardHeader>
              <CardContent className="space-y-3 text-sm">
                {routeRows.length === 0 ? (
                  <div className="text-muted-foreground">暂无路由维度数据</div>
                ) : (
                  routeRows.map((row) => (
                    <div key={row.key} className="rounded border p-3">
                      <div className="flex items-center justify-between gap-3">
                        <div className="truncate font-medium">{row.key}</div>
                        <Badge variant={row.swAlertCount > 0 ? 'destructive' : 'secondary'}>
                          告警 {row.swAlertCount}
                        </Badge>
                      </div>
                      <div className="mt-1 text-muted-foreground">
                        事件 {row.events} / 会话 {row.sessions}
                      </div>
                      <div className="mt-1 text-muted-foreground">
                        脚本失败率 {formatPercent(row.scriptLoadFailureRate)}，恢复回流率{' '}
                        {formatPercent(row.recoveryReturnRate)}
                      </div>
                      <div className="mt-1 text-muted-foreground">
                        SW 命中率 {formatPercent(row.swCacheHitRate)}，SW 回源失败率{' '}
                        {formatPercent(row.swFetchFailureRate)}
                      </div>
                    </div>
                  ))
                )}
              </CardContent>
            </Card>
          </div>

          <Card>
            <CardHeader>
              <CardTitle>建议动作</CardTitle>
              <CardDescription>
                窗口 {dashboard.headline.windowDays} 天，覆盖会话 {dashboard.headline.sessionsCovered}，事件总数{' '}
                {dashboard.headline.totalEvents}
              </CardDescription>
            </CardHeader>
            <CardContent className="space-y-2 text-sm">
              {dashboard.recommendations.map((item) => (
                <div key={item}>- {item}</div>
              ))}
            </CardContent>
          </Card>
        </div>
      )}
    </div>
  );
}

