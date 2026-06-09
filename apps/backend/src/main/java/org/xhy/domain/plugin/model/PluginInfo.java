package org.xhy.domain.plugin.model;

import org.xhy.domain.plugin.constant.PluginStatus;
import org.xhy.domain.plugin.constant.PluginType;

import java.time.LocalDateTime;
import java.util.Map;

/**
 * 插件信息实体
 */
public class PluginInfo {

    private String id;
    private String name;
    private String version;
    private String description;
    private String author;
    private PluginType type;
    private PluginStatus status;
    private Map<String, Object> config;
    private String entryClass;
    private String[] dependencies;
    private String minSystemVersion;
    private String iconUrl;
    private String homepage;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private LocalDateTime installedAt;
    private LocalDateTime lastStartedAt;

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getVersion() { return version; }
    public void setVersion(String version) { this.version = version; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public String getAuthor() { return author; }
    public void setAuthor(String author) { this.author = author; }

    public PluginType getType() { return type; }
    public void setType(PluginType type) { this.type = type; }

    public PluginStatus getStatus() { return status; }
    public void setStatus(PluginStatus status) { this.status = status; }

    public Map<String, Object> getConfig() { return config; }
    public void setConfig(Map<String, Object> config) { this.config = config; }

    public String getEntryClass() { return entryClass; }
    public void setEntryClass(String entryClass) { this.entryClass = entryClass; }

    public String[] getDependencies() { return dependencies; }
    public void setDependencies(String[] dependencies) { this.dependencies = dependencies; }

    public String getMinSystemVersion() { return minSystemVersion; }
    public void setMinSystemVersion(String minSystemVersion) { this.minSystemVersion = minSystemVersion; }

    public String getIconUrl() { return iconUrl; }
    public void setIconUrl(String iconUrl) { this.iconUrl = iconUrl; }

    public String getHomepage() { return homepage; }
    public void setHomepage(String homepage) { this.homepage = homepage; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }

    public LocalDateTime getInstalledAt() { return installedAt; }
    public void setInstalledAt(LocalDateTime installedAt) { this.installedAt = installedAt; }

    public LocalDateTime getLastStartedAt() { return lastStartedAt; }
    public void setLastStartedAt(LocalDateTime lastStartedAt) { this.lastStartedAt = lastStartedAt; }
}
