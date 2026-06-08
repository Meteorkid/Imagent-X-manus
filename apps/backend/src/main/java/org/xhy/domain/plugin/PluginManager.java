package org.xhy.domain.plugin;

import org.xhy.domain.plugin.constant.PluginStatus;
import org.xhy.domain.plugin.constant.PluginType;
import org.xhy.domain.plugin.model.PluginInfo;

import java.nio.file.Path;
import java.util.List;
import java.util.Map;
import java.util.Optional;

/**
 * 插件管理器接口
 * 提供插件的管理功能
 */
public interface PluginManager {

    /**
     * 安装插件
     *
     * @param pluginPath 插件路径
     * @return 插件信息
     */
    PluginInfo installPlugin(Path pluginPath);

    /**
     * 卸载插件
     *
     * @param pluginId 插件ID
     */
    void uninstallPlugin(String pluginId);

    /**
     * 启用插件
     *
     * @param pluginId 插件ID
     */
    void enablePlugin(String pluginId);

    /**
     * 禁用插件
     *
     * @param pluginId 插件ID
     */
    void disablePlugin(String pluginId);

    /**
     * 获取插件信息
     *
     * @param pluginId 插件ID
     * @return 插件信息
     */
    Optional<PluginInfo> getPlugin(String pluginId);

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
     * 获取插件实例
     *
     * @param pluginId 插件ID
     * @param pluginClass 插件接口类
     * @param <T> 插件类型
     * @return 插件实例
     */
    <T extends Plugin> Optional<T> getPluginInstance(String pluginId, Class<T> pluginClass);

    /**
     * 更新插件配置
     *
     * @param pluginId 插件ID
     * @param config 新配置
     */
    void updatePluginConfig(String pluginId, Map<String, Object> config);

    /**
     * 检查插件依赖
     *
     * @param pluginId 插件ID
     * @return 依赖检查结果
     */
    DependencyCheckResult checkDependencies(String pluginId);

    /**
     * 检查插件更新
     *
     * @param pluginId 插件ID
     * @return 是否有更新
     */
    boolean checkForUpdates(String pluginId);

    /**
     * 获取插件日志
     *
     * @param pluginId 插件ID
     * @param lines 行数限制
     * @return 日志内容
     */
    List<String> getPluginLogs(String pluginId, int lines);

    /**
     * 插件依赖检查结果
     */
    class DependencyCheckResult {
        private final boolean satisfied;
        private final List<String> missingDependencies;
        private final List<String> incompatibleDependencies;

        public DependencyCheckResult(boolean satisfied, List<String> missingDependencies,
                                     List<String> incompatibleDependencies) {
            this.satisfied = satisfied;
            this.missingDependencies = missingDependencies;
            this.incompatibleDependencies = incompatibleDependencies;
        }

        public boolean isSatisfied() {
            return satisfied;
        }

        public List<String> getMissingDependencies() {
            return missingDependencies;
        }

        public List<String> getIncompatibleDependencies() {
            return incompatibleDependencies;
        }
    }
}
