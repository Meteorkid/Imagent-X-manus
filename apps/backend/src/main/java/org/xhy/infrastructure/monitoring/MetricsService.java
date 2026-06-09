package org.xhy.infrastructure.monitoring;

import io.micrometer.core.instrument.MeterRegistry;
import io.micrometer.core.instrument.Timer;
import io.micrometer.core.instrument.Counter;
import org.springframework.stereotype.Service;

import java.util.concurrent.TimeUnit;

/**
 * 指标服务
 */
@Service
public class MetricsService {

    private final MeterRegistry meterRegistry;
    private final Counter pluginCounter;
    private final Counter workflowExecutionCounter;
    private final Timer apiRequestTimer;

    public MetricsService(MeterRegistry meterRegistry,
                          Counter pluginCounter,
                          Counter workflowExecutionCounter,
                          Timer apiRequestTimer) {
        this.meterRegistry = meterRegistry;
        this.pluginCounter = pluginCounter;
        this.workflowExecutionCounter = workflowExecutionCounter;
        this.apiRequestTimer = apiRequestTimer;
    }

    /**
     * 记录插件安装
     */
    public void recordPluginInstalled() {
        pluginCounter.increment();
    }

    /**
     * 记录插件卸载
     */
    public void recordPluginUninstalled() {
        pluginCounter.decrement();
    }

    /**
     * 记录工作流执行
     */
    public void recordWorkflowExecution() {
        workflowExecutionCounter.increment();
    }

    /**
     * 记录 API 请求
     */
    public void recordApiRequest(String endpoint, long duration, TimeUnit unit) {
        apiRequestTimer.record(duration, unit);
        meterRegistry.counter("api.requests", "endpoint", endpoint).increment();
    }

    /**
     * 记录 API 错误
     */
    public void recordApiError(String endpoint, String error) {
        meterRegistry.counter("api.errors", "endpoint", endpoint, "error", error).increment();
    }

    /**
     * 记录数据库查询
     */
    public void recordDatabaseQuery(String operation, long duration, TimeUnit unit) {
        Timer.builder("database.queries")
            .tag("operation", operation)
            .register(meterRegistry)
            .record(duration, unit);
    }

    /**
     * 记录缓存命中
     */
    public void recordCacheHit(String cacheName) {
        meterRegistry.counter("cache.hits", "cache", cacheName).increment();
    }

    /**
     * 记录缓存未命中
     */
    public void recordCacheMiss(String cacheName) {
        meterRegistry.counter("cache.misses", "cache", cacheName).increment();
    }

    /**
     * 增加活跃连接数
     */
    public void incrementActiveConnections() {
        meterRegistry.gauge("connections.active",
            meterRegistry.find("connections.active").gauge(),
            gauge -> gauge.value() + 1);
    }

    /**
     * 减少活跃连接数
     */
    public void decrementActiveConnections() {
        meterRegistry.gauge("connections.active",
            meterRegistry.find("connections.active").gauge(),
            gauge -> gauge.value() - 1);
    }

    /**
     * 获取指标快照
     */
    public MetricsSnapshot getSnapshot() {
        return new MetricsSnapshot(
            pluginCounter.count(),
            workflowExecutionCounter.count(),
            getActiveConnections()
        );
    }

    private double getActiveConnections() {
        var gauge = meterRegistry.find("connections.active").gauge();
        return gauge != null ? gauge.value() : 0;
    }

    /**
     * 指标快照
     */
    public static class MetricsSnapshot {
        private final double totalPlugins;
        private final double totalWorkflowExecutions;
        private final double activeConnections;

        public MetricsSnapshot(double totalPlugins, double totalWorkflowExecutions, double activeConnections) {
            this.totalPlugins = totalPlugins;
            this.totalWorkflowExecutions = totalWorkflowExecutions;
            this.activeConnections = activeConnections;
        }

        public double getTotalPlugins() {
            return totalPlugins;
        }

        public double getTotalWorkflowExecutions() {
            return totalWorkflowExecutions;
        }

        public double getActiveConnections() {
            return activeConnections;
        }
    }
}
