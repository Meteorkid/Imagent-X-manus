package org.xhy.domain.plugin;

import org.xhy.domain.plugin.constant.PluginStatus;
import org.xhy.domain.plugin.constant.PluginType;
import org.xhy.domain.plugin.model.PluginInfo;

import java.nio.file.Path;
import java.util.List;
import java.util.Map;
import java.util.Optional;

/**
 * 插件服务接口
 * 提供高层次的插件操作
 */
public interface PluginService {

    /**
     * 从文件安装插件
     *
     * @param pluginFile 插件文件路径
     * @return 插件信息
     */
    PluginInfo installFromFile(Path pluginFile);

    /**
     * 从URL安装插件
     *
     * @param pluginUrl 插件下载URL
     * @return 插件信息
     */
    PluginInfo installFromUrl(String pluginUrl);

    /**
     * 卸载插件
     *
     * @param pluginId 插件ID
     * @param force 是否强制卸载
     */
    void uninstall(String pluginId, boolean force);

    /**
     * 启用插件
     *
     * @param pluginId 插件ID
     */
    void enable(String pluginId);

    /**
     * 禁用插件
     *
     * @param pluginId 插件ID
     */
    void disable(String pluginId);

    /**
     * 获取插件信息
     *
     * @param pluginId 插件ID
     * @return 插件信息
     */
    Optional<PluginInfo> getPluginInfo(String pluginId);

    /**
     * 获取所有插件
     *
     * @return 插件列表
     */
    List<PluginInfo> getAllPlugins();

    /**
     * 按类型获取插件
     *
     * @param type 插件类型
     * @return 插件列表
     */
    List<PluginInfo> getPluginsByType(PluginType type);

    /**
     * 按状态获取插件
     *
     * @param status 插件状态
     * @return 插件列表
     */
    List<PluginInfo> getPluginsByStatus(PluginStatus status);

    /**
     * 获取已启用的插件
     *
     * @return 插件列表
     */
    List<PluginInfo> getEnabledPlugins();

    /**
     * 更新插件配置
     *
     * @param pluginId 插件ID
     * @param config 新配置
     */
    void updateConfig(String pluginId, Map<String, Object> config);

    /**
     * 获取插件配置
     *
     * @param pluginId 插件ID
     * @return 配置映射
     */
    Map<String, Object> getConfig(String pluginId);

    /**
     * 获取插件日志
     *
     * @param pluginId 插件ID
     * @param lines 行数限制
     * @return 日志内容
     */
    List<String> getLogs(String pluginId, int lines);

    /**
     * 检查插件更新
     *
     * @param pluginId 插件ID
     * @return 是否有更新
     */
    boolean checkForUpdates(String pluginId);

    /**
     * 更新插件
     *
     * @param pluginId 插件ID
     * @return 新版本信息
     */
    PluginInfo updatePlugin(String pluginId);

    /**
     * 获取插件统计信息
     *
     * @return 统计信息
     */
    PluginStatistics getStatistics();

    /**
     * 插件统计信息
     */
    class PluginStatistics {
        private final long totalPlugins;
        private final long enabledPlugins;
        private final long disabledPlugins;
        private final long errorPlugins;
        private final Map<PluginType, Long> pluginsByType;

        public PluginStatistics(long totalPlugins, long enabledPlugins, long disabledPlugins,
                               long errorPlugins, Map<PluginType, Long> pluginsByType) {
            this.totalPlugins = totalPlugins;
            this.enabledPlugins = enabledPlugins;
            this.disabledPlugins = disabledPlugins;
            this.errorPlugins = errorPlugins;
            this.pluginsByType = pluginsByType;
        }

        public long getTotalPlugins() {
            return totalPlugins;
        }

        public long getEnabledPlugins() {
            return enabledPlugins;
        }

        public long getDisabledPlugins() {
            return disabledPlugins;
        }

        public long getErrorPlugins() {
            return errorPlugins;
        }

        public Map<PluginType, Long> getPluginsByType() {
            return pluginsByType;
        }
    }
}
