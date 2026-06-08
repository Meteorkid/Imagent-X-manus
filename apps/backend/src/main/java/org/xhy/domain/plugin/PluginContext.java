package org.xhy.domain.plugin;

import org.xhy.domain.plugin.model.PluginInfo;

import java.nio.file.Path;
import java.util.Map;
import java.util.logging.Logger;

/**
 * 插件上下文
 * 提供插件运行所需的环境和资源
 */
public interface PluginContext {

    /**
     * 获取插件信息
     *
     * @return 插件信息
     */
    PluginInfo getPluginInfo();

    /**
     * 获取插件配置
     *
     * @return 配置映射
     */
    Map<String, Object> getConfig();

    /**
     * 获取插件配置值
     *
     * @param key 配置键
     * @param defaultValue 默认值
     * @return 配置值
     */
    default Object getConfig(String key, Object defaultValue) {
        return getConfig().getOrDefault(key, defaultValue);
    }

    /**
     * 获取插件配置值（字符串）
     *
     * @param key 配置键
     * @param defaultValue 默认值
     * @return 配置值
     */
    default String getConfigString(String key, String defaultValue) {
        Object value = getConfig().get(key);
        return value != null ? value.toString() : defaultValue;
    }

    /**
     * 获取插件数据目录
     *
     * @return 数据目录路径
     */
    Path getDataDirectory();

    /**
     * 获取插件日志记录器
     *
     * @return 日志记录器
     */
    Logger getLogger();

    /**
     * 获取系统服务
     *
     * @param serviceClass 服务接口类
     * @param <T> 服务类型
     * @return 服务实例
     */
    <T> T getService(Class<T> serviceClass);

    /**
     * 注册插件服务
     *
     * @param serviceClass 服务接口类
     * @param service 实现实例
     * @param <T> 服务类型
     */
    <T> void registerService(Class<T> serviceClass, T service);

    /**
     * 发布事件
     *
     * @param event 事件对象
     */
    void publishEvent(Object event);

    /**
     * 订阅事件
     *
     * @param eventType 事件类型
     * @param listener 事件监听器
     */
    void subscribeEvent(Class<?> eventType, EventListener listener);

    /**
     * 获取插件目录路径
     *
     * @return 插件目录路径
     */
    Path getPluginDirectory();

    /**
     * 获取临时目录
     *
     * @return 临时目录路径
     */
    Path getTempDirectory();

    /**
     * 获取日志目录
     *
     * @return 日志目录路径
     */
    Path getLogDirectory();
}
