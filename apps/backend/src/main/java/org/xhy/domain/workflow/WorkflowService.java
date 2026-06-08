package org.xhy.domain.workflow;

import org.xhy.domain.workflow.constant.ExecutionStatus;
import org.xhy.domain.workflow.constant.WorkflowStatus;
import org.xhy.domain.workflow.model.Workflow;
import org.xhy.domain.workflow.model.WorkflowExecution;

import java.util.List;
import java.util.Map;

/**
 * 工作流服务接口
 */
public interface WorkflowService {

    /**
     * 创建工作流
     *
     * @param workflow 工作流
     * @return 创建的工作流
     */
    Workflow createWorkflow(Workflow workflow);

    /**
     * 更新工作流
     *
     * @param workflow 工作流
     * @return 更新的工作流
     */
    Workflow updateWorkflow(Workflow workflow);

    /**
     * 删除工作流
     *
     * @param workflowId 工作流ID
     */
    void deleteWorkflow(String workflowId);

    /**
     * 获取工作流
     *
     * @param workflowId 工作流ID
     * @return 工作流
     */
    Workflow getWorkflow(String workflowId);

    /**
     * 获取所有工作流
     *
     * @return 工作流列表
     */
    List<Workflow> getAllWorkflows();

    /**
     * 按状态获取工作流
     *
     * @param status 状态
     * @return 工作流列表
     */
    List<Workflow> getWorkflowsByStatus(WorkflowStatus status);

    /**
     * 发布工作流
     *
     * @param workflowId 工作流ID
     */
    void publishWorkflow(String workflowId);

    /**
     * 归档工作流
     *
     * @param workflowId 工作流ID
     */
    void archiveWorkflow(String workflowId);

    /**
     * 执行工作流
     *
     * @param workflowId 工作流ID
     * @param inputs 输入参数
     * @return 执行记录
     */
    WorkflowExecution executeWorkflow(String workflowId, Map<String, Object> inputs);

    /**
     * 获取执行记录
     *
     * @param executionId 执行ID
     * @return 执行记录
     */
    WorkflowExecution getExecution(String executionId);

    /**
     * 获取工作流的所有执行记录
     *
     * @param workflowId 工作流ID
     * @return 执行记录列表
     */
    List<WorkflowExecution> getWorkflowExecutions(String workflowId);

    /**
     * 取消执行
     *
     * @param executionId 执行ID
     */
    void cancelExecution(String executionId);

    /**
     * 暂停执行
     *
     * @param executionId 执行ID
     */
    void pauseExecution(String executionId);

    /**
     * 恢复执行
     *
     * @param executionId 执行ID
     */
    void resumeExecution(String executionId);

    /**
     * 重试执行
     *
     * @param executionId 执行ID
     * @return 新的执行记录
     */
    WorkflowExecution retryExecution(String executionId);

    /**
     * 获取执行日志
     *
     * @param executionId 执行ID
     * @return 日志内容
     */
    String getExecutionLogs(String executionId);

    /**
     * 获取工作流统计信息
     *
     * @param workflowId 工作流ID
     * @return 统计信息
     */
    WorkflowStatistics getStatistics(String workflowId);

    /**
     * 工作流统计信息
     */
    class WorkflowStatistics {
        private final long totalExecutions;
        private final long successfulExecutions;
        private final long failedExecutions;
        private final long runningExecutions;
        private final double averageDuration;

        public WorkflowStatistics(long totalExecutions, long successfulExecutions,
                                  long failedExecutions, long runningExecutions, double averageDuration) {
            this.totalExecutions = totalExecutions;
            this.successfulExecutions = successfulExecutions;
            this.failedExecutions = failedExecutions;
            this.runningExecutions = runningExecutions;
            this.averageDuration = averageDuration;
        }

        public long getTotalExecutions() {
            return totalExecutions;
        }

        public long getSuccessfulExecutions() {
            return successfulExecutions;
        }

        public long getFailedExecutions() {
            return failedExecutions;
        }

        public long getRunningExecutions() {
            return runningExecutions;
        }

        public double getAverageDuration() {
            return averageDuration;
        }
    }
}
