package org.xhy.domain.plugin;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.HashMap;
import java.util.Map;

/**
 * 插件配置属性
 */
@Data
@Component
@ConfigurationProperties(prefix = "plugin")
public class PluginConfigProperties {

    /**
     * 插件目录
     */
    private Path directory = Paths.get("plugins");

    /**
     * 配置目录
     */
    private Path configDirectory = Paths.get("config/plugins");

    /**
     * 日志目录
     */
    private Path logDirectory = Paths.get("logs/plugins");

    /**
     * 临时目录
     */
    private Path tempDirectory = Paths.get("temp/plugins");

    /**
     * 是否启用插件系统
     */
    private boolean enabled = true;

    /**
     * 是否自动加载插件
     */
    private boolean autoLoad = true;

    /**
     * 是否自动启用插件
     */
    private boolean autoEnable = false;

    /**
     * 最大并行加载插件数
     */
    private int maxParallelLoad = 5;

    /**
     * 插件加载超时时间（秒）
     */
    private int loadTimeout = 30;

    /**
     * 插件卸载超时时间（秒）
     */
    private int unloadTimeout = 10;

    /**
     * 是否启用插件沙箱
     */
    private boolean sandboxEnabled = true;

    /**
     * 沙箱限制配置
     */
    private SandboxConfig sandbox = new SandboxConfig();

    /**
     * 全局插件配置
     */
    private Map<String, Object> globalConfig = new HashMap<>();

    /**
     * 沙箱配置
     */
    @Data
    public static class SandboxConfig {
        /**
         * 是否限制文件访问
         */
        private boolean restrictFileAccess = true;

        /**
         * 是否限制网络访问
         */
        private boolean restrictNetworkAccess = false;

        /**
         * 是否限制系统调用
         */
        private boolean restrictSystemCalls = true;

        /**
         * 是否限制内存使用
         */
        private boolean restrictMemory = true;

        /**
         * 最大内存使用量（MB）
         */
        private int maxMemory = 256;

        /**
         * 是否限制CPU使用
         */
        private boolean restrictCpu = false;

        /**
         * 最大CPU使用率（%）
         */
        private int maxCpu = 50;
    }
}
