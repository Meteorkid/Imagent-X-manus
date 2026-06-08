package org.xhy.domain.workflow.model;

import lombok.Data;
import org.xhy.domain.workflow.constant.ExecutionStatus;
import java.time.LocalDateTime;
import java.util.Map;

/**
 * 工作流执行记录
 */
@Data
public class WorkflowExecution {

    /**
     * 执行ID
     */
    private String id;

    /**
     * 工作流ID
     */
    private String workflowId;

    /**
     * 执行状态
     */
    private ExecutionStatus status;

    /**
     * 输入参数
     */
    private Map<String, Object> inputs;

    /**
     * 输出参数
     */
    private Map<String, Object> outputs;

    /**
     * 当前节点ID
     */
    private String currentNodeId;

    /**
     * 错误信息
     */
    private String errorMessage;

    /**
     * 错误堆栈
     */
    private String errorStack;

    /**
     * 开始时间
     */
    private LocalDateTime startTime;

    /**
     * 结束时间
     */
    private LocalDateTime endTime;

    /**
     * 耗时（毫秒）
     */
    private long duration;

    /**
     * 重试次数
     */
    private int retryCount;

    /**
     * 执行者ID
     */
    private String executedBy;

    /**
     * 执行日志
     */
    private String logs;
}
