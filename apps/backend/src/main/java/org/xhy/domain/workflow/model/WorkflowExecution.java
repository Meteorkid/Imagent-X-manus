package org.xhy.domain.workflow.model;

import org.xhy.domain.workflow.constant.ExecutionStatus;

import java.time.LocalDateTime;
import java.util.Map;

/**
 * 工作流执行记录
 */
public class WorkflowExecution {

    private String id;
    private String workflowId;
    private ExecutionStatus status;
    private Map<String, Object> inputs;
    private Map<String, Object> outputs;
    private String currentNodeId;
    private String errorMessage;
    private String errorStack;
    private LocalDateTime startTime;
    private LocalDateTime endTime;
    private long duration;
    private int retryCount;
    private String executedBy;
    private String logs;

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getWorkflowId() { return workflowId; }
    public void setWorkflowId(String workflowId) { this.workflowId = workflowId; }

    public ExecutionStatus getStatus() { return status; }
    public void setStatus(ExecutionStatus status) { this.status = status; }

    public Map<String, Object> getInputs() { return inputs; }
    public void setInputs(Map<String, Object> inputs) { this.inputs = inputs; }

    public Map<String, Object> getOutputs() { return outputs; }
    public void setOutputs(Map<String, Object> outputs) { this.outputs = outputs; }

    public String getCurrentNodeId() { return currentNodeId; }
    public void setCurrentNodeId(String currentNodeId) { this.currentNodeId = currentNodeId; }

    public String getErrorMessage() { return errorMessage; }
    public void setErrorMessage(String errorMessage) { this.errorMessage = errorMessage; }

    public String getErrorStack() { return errorStack; }
    public void setErrorStack(String errorStack) { this.errorStack = errorStack; }

    public LocalDateTime getStartTime() { return startTime; }
    public void setStartTime(LocalDateTime startTime) { this.startTime = startTime; }

    public LocalDateTime getEndTime() { return endTime; }
    public void setEndTime(LocalDateTime endTime) { this.endTime = endTime; }

    public long getDuration() { return duration; }
    public void setDuration(long duration) { this.duration = duration; }

    public int getRetryCount() { return retryCount; }
    public void setRetryCount(int retryCount) { this.retryCount = retryCount; }

    public String getExecutedBy() { return executedBy; }
    public void setExecutedBy(String executedBy) { this.executedBy = executedBy; }

    public String getLogs() { return logs; }
    public void setLogs(String logs) { this.logs = logs; }
}
