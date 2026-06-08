package org.xhy.domain.plugin;

/**
 * 插件生命周期接口
 * 定义插件生命周期钩子
 */
public interface PluginLifecycle {

    /**
     * 插件加载前钩子
     *
     * @return 是否继续加载
     */
    default boolean onLoad() {
        return true;
    }

    /**
     * 插件加载后钩子
     */
    default void afterLoad() {
    }

    /**
     * 插件启用前钩子
     *
     * @return 是否继续启用
     */
    default boolean onEnable() {
        return true;
    }

    /**
     * 插件启用后钩子
     */
    default void afterEnable() {
    }

    /**
     * 插件禁用前钩子
     *
     * @return 是否继续禁用
     */
    default boolean onDisable() {
        return true;
    }

    /**
     * 插件禁用后钩子
     */
    default void afterDisable() {
    }

    /**
     * 插件卸载前钩子
     *
     * @return 是否继续卸载
     */
    default boolean onUnload() {
        return true;
    }

    /**
     * 插件卸载后钩子
     */
    default void afterUnload() {
    }

    /**
     * 插件配置更新钩子
     *
     * @param key 配置键
     * @param oldValue 旧值
     * @param newValue 新值
     */
    default void onConfigUpdate(String key, Object oldValue, Object newValue) {
    }
}
