package org.xhy.domain.plugin.model;

import lombok.Data;
import java.time.LocalDateTime;
import java.util.Map;

/**
 * 插件信息实体
 */
@Data
public class PluginInfo {

    /**
     * 插件ID
     */
    private String id;

    /**
     * 插件名称
     */
    private String name;

    /**
     * 插件版本
     */
    private String version;

    /**
     * 插件描述
     */
    private String description;

    /**
     * 插件作者
     */
    private String author;

    /**
     * 插件类型
     */
    private PluginType type;

    /**
     * 插件状态
     */
    private PluginStatus status;

    /**
     * 插件配置
     */
    private Map<String, Object> config;

    /**
     * 插件入口类
     */
    private String entryClass;

    /**
     * 插件依赖
     */
    private String[] dependencies;

    /**
     * 最小系统版本要求
     */
    private String minSystemVersion;

    /**
     * 插件图标URL
     */
    private String iconUrl;

    /**
     * 插件主页
     */
    private String homepage;

    /**
     * 创建时间
     */
    private LocalDateTime createdAt;

    /**
     * 更新时间
     */
    private LocalDateTime updatedAt;

    /**
     * 安装时间
     */
    private LocalDateTime installedAt;

    /**
     * 最后启动时间
     */
    private LocalDateTime lastStartedAt;
}
