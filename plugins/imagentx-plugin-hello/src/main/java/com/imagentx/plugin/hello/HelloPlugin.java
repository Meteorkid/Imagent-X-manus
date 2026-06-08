package com.imagentx.plugin.hello;

import org.xhy.domain.plugin.Plugin;
import org.xhy.domain.plugin.PluginContext;
import org.xhy.domain.plugin.PluginLifecycle;
import org.xhy.domain.plugin.model.PluginInfo;

import java.util.HashMap;
import java.util.Map;

/**
 * Hello Plugin - 示例插件
 * 演示插件系统的基本功能
 */
public class HelloPlugin implements Plugin, PluginLifecycle {

    private PluginContext context;
    private PluginInfo pluginInfo;
    private Map<String, Object> runtimeData;

    @Override
    public PluginInfo getPluginInfo() {
        return pluginInfo;
    }

    @Override
    public void initialize(PluginContext context) {
        this.context = context;
        this.runtimeData = new HashMap<>();

        // 加载插件信息
        this.pluginInfo = loadPluginInfo();

        // 记录初始化日志
        context.getLogger().info("Hello Plugin 初始化完成");
        context.getLogger().info("插件版本: " + pluginInfo.getVersion());
        context.getRuntimeData().put("initialized", true);
    }

    @Override
    public void start() {
        context.getLogger().info("Hello Plugin 启动");

        // 获取配置
        String greeting = context.getConfigString("greeting", "Hello!");
        String language = context.getConfigString("language", "zh-CN");
        boolean showNotification = (boolean) context.getConfig("showNotification", true);

        // 执行问候
        String message = greeting + " (语言: " + language + ")";
        context.getLogger().info(message);

        // 显示通知
        if (showNotification) {
            showNotification(message);
        }

        // 注册服务
        context.registerService(HelloService.class, new HelloServiceImpl(context));

        // 订阅事件
        context.subscribeEvent(String.class, this::handleEvent);

        runtimeData.put("started", true);
        runtimeData.put("startTime", System.currentTimeMillis());
    }

    @Override
    public void stop() {
        context.getLogger().info("Hello Plugin 停止");
        runtimeData.put("started", false);
    }

    @Override
    public void destroy() {
        context.getLogger().info("Hello Plugin 销毁");
        runtimeData.clear();
    }

    @Override
    public boolean onLoad() {
        context.getLogger().info("Hello Plugin 加载前检查");
        return true;
    }

    @Override
    public void afterLoad() {
        context.getLogger().info("Hello Plugin 加载完成");
    }

    @Override
    public boolean onEnable() {
        context.getLogger().info("Hello Plugin 启用前检查");
        return true;
    }

    @Override
    public void afterEnable() {
        context.getLogger().info("Hello Plugin 启用完成");
    }

    @Override
    public boolean onDisable() {
        context.getLogger().info("Hello Plugin 禁用前检查");
        return true;
    }

    @Override
    public void afterDisable() {
        context.getLogger().info("Hello Plugin 禁用完成");
    }

    @Override
    public boolean onUnload() {
        context.getLogger().info("Hello Plugin 卸载前检查");
        return true;
    }

    @Override
    public void afterUnload() {
        context.getLogger().info("Hello Plugin 卸载完成");
    }

    @Override
    public void onConfigUpdate(String key, Object oldValue, Object newValue) {
        context.getLogger().info("配置更新: " + key + " = " + newValue);
    }

    private PluginInfo loadPluginInfo() {
        PluginInfo info = new PluginInfo();
        info.setId("imagentx-plugin-hello");
        info.setName("Hello Plugin");
        info.setVersion("1.0.0");
        info.setDescription("一个简单的示例插件");
        info.setAuthor("ImagentX Team");
        info.setType(org.xhy.domain.plugin.constant.PluginType.EXTENSION);
        info.setStatus(org.xhy.domain.plugin.constant.PluginStatus.ENABLED);
        info.setConfig(context.getConfig());
        info.setIconUrl("/plugins/hello/icon.png");
        info.setHomepage("https://github.com/Meteorkid/Imagent-X-manus");
        return info;
    }

    private void showNotification(String message) {
        // 发布通知事件
        context.publishEvent(new NotificationEvent(message));
    }

    private void handleEvent(Object event) {
        context.getLogger().info("收到事件: " + event);
    }

    /**
     * 通知事件
     */
    public static class NotificationEvent {
        private final String message;

        public NotificationEvent(String message) {
            this.message = message;
        }

        public String getMessage() {
            return message;
        }
    }
}
