package com.imagentx.plugin.hello;

import org.xhy.domain.plugin.PluginContext;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

/**
 * Hello 服务实现
 */
public class HelloServiceImpl implements HelloService {

    private final PluginContext context;
    private final long startTime;

    public HelloServiceImpl(PluginContext context) {
        this.context = context;
        this.startTime = System.currentTimeMillis();
    }

    @Override
    public String greet(String name) {
        String greeting = context.getConfigString("greeting", "Hello!");
        String message = greeting + ", " + name + "!";
        context.getLogger().info("发送问候: " + message);
        return message;
    }

    @Override
    public String getStatus() {
        long uptime = getUptime();
        String uptimeStr = formatUptime(uptime);
        return String.format("Hello Plugin 正在运行 - 运行时间: %s", uptimeStr);
    }

    @Override
    public long getUptime() {
        return System.currentTimeMillis() - startTime;
    }

    private String formatUptime(long milliseconds) {
        long seconds = milliseconds / 1000;
        long minutes = seconds / 60;
        long hours = minutes / 60;

        if (hours > 0) {
            return String.format("%d小时%d分钟", hours, minutes % 60);
        } else if (minutes > 0) {
            return String.format("%d分钟", minutes);
        } else {
            return String.format("%d秒", seconds);
        }
    }
}
