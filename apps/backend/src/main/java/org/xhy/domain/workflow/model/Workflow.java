package org.xhy.domain.workflow.model;

import lombok.Data;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

/**
 * 工作流实体
 */
@Data
public class Workflow {

    /**
     * 工作流ID
     */
    private String id;

    /**
     * 工作流名称
     */
    private String name;

    /**
     * 工作流描述
     */
    private String description;

    /**
     * 工作流版本
     */
    private String version;

    /**
     * 工作流定义（JSON格式）
     */
    private String definition;

    /**
     * 工作流状态
     */
    private WorkflowStatus status;

    /**
     * 创建者ID
     */
    private String createdBy;

    /**
     * 标签
     */
    private List<String> tags;

    /**
     * 配置参数
     */
    private Map<String, Object> config;

    /**
     * 创建时间
     */
    private LocalDateTime createdAt;

    /**
     * 更新时间
     */
    private LocalDateTime updatedAt;

    /**
     * 最后执行时间
     */
    private LocalDateTime lastExecutedAt;

    /**
     * 执行次数
     */
    private long executionCount;
}
