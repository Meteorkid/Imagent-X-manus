package org.xhy.domain.plugin;

import org.xhy.domain.plugin.model.PluginInfo;

/**
 * 插件接口
 * 所有插件必须实现此接口
 */
public interface Plugin {

    /**
     * 获取插件信息
     *
     * @return 插件信息
     */
    PluginInfo getPluginInfo();

    /**
     * 插件初始化
     * 在插件加载时调用
     *
     * @param context 插件上下文
     */
    void initialize(PluginContext context);

    /**
     * 插件启动
     * 在插件启用时调用
     */
    void start();

    /**
     * 插件停止
     * 在插件禁用时调用
     */
    void stop();

    /**
     * 插件销毁
     * 在插件卸载时调用
     */
    void destroy();

    /**
     * 获取插件版本
     *
     * @return 版本号
     */
    default String getVersion() {
        return getPluginInfo().getVersion();
    }

    /**
     * 获取插件名称
     *
     * @return 插件名称
     */
    default String getName() {
        return getPluginInfo().getName();
    }
}
