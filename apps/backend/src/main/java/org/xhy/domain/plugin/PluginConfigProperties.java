package org.xhy.domain.plugin;

import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.HashMap;
import java.util.Map;

/**
 * 插件配置属性
 */
@Component
@ConfigurationProperties(prefix = "plugin")
public class PluginConfigProperties {

    private Path directory = Paths.get("plugins");
    private Path configDirectory = Paths.get("config/plugins");
    private Path logDirectory = Paths.get("logs/plugins");
    private Path tempDirectory = Paths.get("temp/plugins");
    private boolean enabled = true;
    private boolean autoLoad = true;
    private boolean autoEnable = false;
    private int maxParallelLoad = 5;
    private int loadTimeout = 30;
    private int unloadTimeout = 10;
    private boolean sandboxEnabled = true;
    private SandboxConfig sandbox = new SandboxConfig();
    private Map<String, Object> globalConfig = new HashMap<>();

    public Path getDirectory() { return directory; }
    public void setDirectory(Path directory) { this.directory = directory; }

    public Path getConfigDirectory() { return configDirectory; }
    public void setConfigDirectory(Path configDirectory) { this.configDirectory = configDirectory; }

    public Path getLogDirectory() { return logDirectory; }
    public void setLogDirectory(Path logDirectory) { this.logDirectory = logDirectory; }

    public Path getTempDirectory() { return tempDirectory; }
    public void setTempDirectory(Path tempDirectory) { this.tempDirectory = tempDirectory; }

    public boolean isEnabled() { return enabled; }
    public void setEnabled(boolean enabled) { this.enabled = enabled; }

    public boolean isAutoLoad() { return autoLoad; }
    public void setAutoLoad(boolean autoLoad) { this.autoLoad = autoLoad; }

    public boolean isAutoEnable() { return autoEnable; }
    public void setAutoEnable(boolean autoEnable) { this.autoEnable = autoEnable; }

    public int getMaxParallelLoad() { return maxParallelLoad; }
    public void setMaxParallelLoad(int maxParallelLoad) { this.maxParallelLoad = maxParallelLoad; }

    public int getLoadTimeout() { return loadTimeout; }
    public void setLoadTimeout(int loadTimeout) { this.loadTimeout = loadTimeout; }

    public int getUnloadTimeout() { return unloadTimeout; }
    public void setUnloadTimeout(int unloadTimeout) { this.unloadTimeout = unloadTimeout; }

    public boolean isSandboxEnabled() { return sandboxEnabled; }
    public void setSandboxEnabled(boolean sandboxEnabled) { this.sandboxEnabled = sandboxEnabled; }

    public SandboxConfig getSandbox() { return sandbox; }
    public void setSandbox(SandboxConfig sandbox) { this.sandbox = sandbox; }

    public Map<String, Object> getGlobalConfig() { return globalConfig; }
    public void setGlobalConfig(Map<String, Object> globalConfig) { this.globalConfig = globalConfig; }

    public static class SandboxConfig {
        private boolean restrictFileAccess = true;
        private boolean restrictNetworkAccess = false;
        private boolean restrictSystemCalls = true;
        private boolean restrictMemory = true;
        private int maxMemory = 256;
        private boolean restrictCpu = false;
        private int maxCpu = 50;

        public boolean isRestrictFileAccess() { return restrictFileAccess; }
        public void setRestrictFileAccess(boolean restrictFileAccess) { this.restrictFileAccess = restrictFileAccess; }

        public boolean isRestrictNetworkAccess() { return restrictNetworkAccess; }
        public void setRestrictNetworkAccess(boolean restrictNetworkAccess) { this.restrictNetworkAccess = restrictNetworkAccess; }

        public boolean isRestrictSystemCalls() { return restrictSystemCalls; }
        public void setRestrictSystemCalls(boolean restrictSystemCalls) { this.restrictSystemCalls = restrictSystemCalls; }

        public boolean isRestrictMemory() { return restrictMemory; }
        public void setRestrictMemory(boolean restrictMemory) { this.restrictMemory = restrictMemory; }

        public int getMaxMemory() { return maxMemory; }
        public void setMaxMemory(int maxMemory) { this.maxMemory = maxMemory; }

        public boolean isRestrictCpu() { return restrictCpu; }
        public void setRestrictCpu(boolean restrictCpu) { this.restrictCpu = restrictCpu; }

        public int getMaxCpu() { return maxCpu; }
        public void setMaxCpu(int maxCpu) { this.maxCpu = maxCpu; }
    }
}
