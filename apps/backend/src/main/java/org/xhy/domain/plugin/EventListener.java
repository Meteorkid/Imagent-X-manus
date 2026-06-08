package org.xhy.domain.plugin;

/**
 * 事件监听器接口
 */
@FunctionalInterface
public interface EventListener<T> {

    /**
     * 处理事件
     *
     * @param event 事件对象
     */
    void onEvent(T event);
}
