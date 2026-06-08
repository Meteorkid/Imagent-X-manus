package org.xhy.domain.plugin;

import java.nio.file.Path;
import java.util.Map;

/**
 * 插件配置管理器接口
 * 管理插件的配置存储和读取
 */
public interface PluginConfigManager {

    /**
     * 获取插件配置目录
     *
     * @param pluginId 插件ID
     * @return 配置目录路径
     */
    Path getPluginConfigDirectory(String pluginId);

    /**
     * 加载插件配置
     *
     * @param pluginId 插件ID
     * @return 配置映射
     */
    Map<String, Object> loadConfig(String pluginId);

    /**
     * 保存插件配置
     *
     * @param pluginId 插件ID
     * @param config 配置映射
     */
    void saveConfig(String pluginId, Map<String, Object> config);

    /**
     * 获取配置值
     *
     * @param pluginId 插件ID
     * @param key 配置键
     * @return 配置值
     */
    Object getConfig(String pluginId, String key);

    /**
     * 获取配置值（带默认值）
     *
     * @param pluginId 插件ID
     * @param key 配置键
     * @param defaultValue 默认值
     * @return 配置值
     */
    Object getConfig(String pluginId, String key, Object defaultValue);

    /**
     * 设置配置值
     *
     * @param pluginId 插件ID
     * @param key 配置键
     * @param value 配置值
     */
    void setConfig(String pluginId, String key, Object value);

    /**
     * 删除配置值
     *
     * @param pluginId 插件ID
     * @param key 配置键
     */
    void deleteConfig(String pluginId, String key);

    /**
     * 检查配置是否存在
     *
     * @param pluginId 插件ID
     * @param key 配置键
     * @return 是否存在
     */
    boolean hasConfig(String pluginId, String key);

    /**
     * 获取所有配置键
     *
     * @param pluginId 插件ID
     * @return 配置键列表
     */
    java.util.Set<String> getConfigKeys(String pluginId);

    /**
     * 清空插件配置
     *
     * @param pluginId 插件ID
     */
    void clearConfig(String pluginId);

    /**
     * 备份插件配置
     *
     * @param pluginId 插件ID
     * @return 备份路径
     */
    Path backupConfig(String pluginId);

    /**
     * 恢复插件配置
     *
     * @param pluginId 插件ID
     * @param backupPath 备份路径
     */
    void restoreConfig(String pluginId, Path backupPath);
}
