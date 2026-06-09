package org.xhy.infrastructure.monitoring;

import io.micrometer.core.instrument.MeterRegistry;
import io.micrometer.core.instrument.Timer;
import io.micrometer.core.instrument.Counter;
import io.micrometer.core.instrument.Gauge;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicInteger;

/**
 * 指标配置
 */
@Configuration
public class MetricsConfig {

    /**
     * 插件计数器
     */
    @Bean
    public Counter pluginCounter(MeterRegistry registry) {
        return Counter.builder("plugins.total")
            .description("Total number of plugins")
            .register(registry);
    }

    /**
     * 工作流执行计数器
     */
    @Bean
    public Counter workflowExecutionCounter(MeterRegistry registry) {
        return Counter.builder("workflows.executions.total")
            .description("Total workflow executions")
            .register(registry);
    }

    /**
     * API 请求计时器
     */
    @Bean
    public Timer apiRequestTimer(MeterRegistry registry) {
        return Timer.builder("api.requests.duration")
            .description("API request duration")
            .publishPercentiles(0.5, 0.95, 0.99)
            .register(registry);
    }

    /**
     * 活跃连接数
     */
    @Bean
    public AtomicInteger activeConnections(MeterRegistry registry) {
        AtomicInteger connections = new AtomicInteger(0);
        Gauge.builder("connections.active", connections, AtomicInteger::doubleValue)
            .description("Active connections")
            .register(registry);
        return connections;
    }

    /**
     * 系统内存使用
     */
    @Bean
    public Gauge memoryUsage(MeterRegistry registry) {
        return Gauge.builder("system.memory.usage", Runtime.getRuntime(), runtime -> {
            long used = runtime.totalMemory() - runtime.freeMemory();
            return (double) used / runtime.maxMemory() * 100;
        })
        .description("Memory usage percentage")
        .register(registry);
    }

    /**
     * 系统 CPU 使用
     */
    @Bean
    public Gauge cpuUsage(MeterRegistry registry) {
        return Gauge.builder("system.cpu.usage", () -> {
            return ManagementFactory.getOperatingSystemMXBean().getSystemLoadAverage();
        })
        .description("CPU usage")
        .register(registry);
    }
}
