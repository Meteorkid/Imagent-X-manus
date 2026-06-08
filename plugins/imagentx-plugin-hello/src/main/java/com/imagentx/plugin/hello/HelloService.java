package com.imagentx.plugin.hello;

/**
 * Hello 服务接口
 * 提供问候功能
 */
public interface HelloService {

    /**
     * 发送问候
     *
     * @param name 名称
     * @return 问候消息
     */
    String greet(String name);

    /**
     * 获取插件状态
     *
     * @return 状态信息
     */
    String getStatus();

    /**
     * 获取运行时间
     *
     * @return 运行时间（毫秒）
     */
    long getUptime();
}
