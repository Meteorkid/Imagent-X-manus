package org.xhy.domain.workflow.model;

import org.xhy.domain.workflow.constant.WorkflowStatus;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

/**
 * 工作流实体
 */
public class Workflow {

    private String id;
    private String name;
    private String description;
    private String version;
    private String definition;
    private WorkflowStatus status;
    private String createdBy;
    private List<String> tags;
    private Map<String, Object> config;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private LocalDateTime lastExecutedAt;
    private long executionCount;

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public String getVersion() { return version; }
    public void setVersion(String version) { this.version = version; }

    public String getDefinition() { return definition; }
    public void setDefinition(String definition) { this.definition = definition; }

    public WorkflowStatus getStatus() { return status; }
    public void setStatus(WorkflowStatus status) { this.status = status; }

    public String getCreatedBy() { return createdBy; }
    public void setCreatedBy(String createdBy) { this.createdBy = createdBy; }

    public List<String> getTags() { return tags; }
    public void setTags(List<String> tags) { this.tags = tags; }

    public Map<String, Object> getConfig() { return config; }
    public void setConfig(Map<String, Object> config) { this.config = config; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }

    public LocalDateTime getLastExecutedAt() { return lastExecutedAt; }
    public void setLastExecutedAt(LocalDateTime lastExecutedAt) { this.lastExecutedAt = lastExecutedAt; }

    public long getExecutionCount() { return executionCount; }
    public void setExecutionCount(long executionCount) { this.executionCount = executionCount; }
}
