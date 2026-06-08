package org.xhy.domain.workflow;

import org.xhy.domain.workflow.model.Workflow;
import org.xhy.domain.workflow.model.WorkflowExecution;
import org.xhy.domain.workflow.model.WorkflowNode;

import java.util.Map;

/**
 * 工作流引擎接口
 * 负责工作流的解析和执行
 */
public interface WorkflowEngine {

    /**
     * 解析工作流定义
     *
     * @param definition 工作流定义（JSON格式）
     * @return 解析后的工作流
     */
    Workflow parseWorkflow(String definition);

    /**
     * 验证工作流定义
     *
     * @param definition 工作流定义
     * @return 验证结果
     */
    ValidationResult validateWorkflow(String definition);

    /**
     * 执行工作流
     *
     * @param workflow 工作流
     * @param inputs 输入参数
     * @return 执行记录
     */
    WorkflowExecution execute(Workflow workflow, Map<String, Object> inputs);

    /**
     * 执行单个节点
     *
     * @param node 工作流节点
     * @param context 执行上下文
     * @return 节点执行结果
     */
    NodeExecutionResult executeNode(WorkflowNode node, ExecutionContext context);

    /**
     * 获取下一个节点
     *
     * @param currentNode 当前节点
     * @param context 执行上下文
     * @return 下一个节点
     */
    WorkflowNode getNextNode(WorkflowNode currentNode, ExecutionContext context);

    /**
     * 验证结果
     */
    class ValidationResult {
        private final boolean valid;
        private final java.util.List<String> errors;
        private final java.util.List<String> warnings;

        public ValidationResult(boolean valid, java.util.List<String> errors, java.util.List<String> warnings) {
            this.valid = valid;
            this.errors = errors;
            this.warnings = warnings;
        }

        public boolean isValid() {
            return valid;
        }

        public java.util.List<String> getErrors() {
            return errors;
        }

        public java.util.List<String> getWarnings() {
            return warnings;
        }
    }

    /**
     * 节点执行结果
     */
    class NodeExecutionResult {
        private final boolean success;
        private final Object output;
        private final String error;
        private final long duration;

        public NodeExecutionResult(boolean success, Object output, String error, long duration) {
            this.success = success;
            this.output = output;
            this.error = error;
            this.duration = duration;
        }

        public boolean isSuccess() {
            return success;
        }

        public Object getOutput() {
            return output;
        }

        public String getError() {
            return error;
        }

        public long getDuration() {
            return duration;
        }
    }

    /**
     * 执行上下文
     */
    class ExecutionContext {
        private final WorkflowExecution execution;
        private final Map<String, Object> variables;
        private final StringBuilder logs;

        public ExecutionContext(WorkflowExecution execution, Map<String, Object> variables) {
            this.execution = execution;
            this.variables = variables;
            this.logs = new StringBuilder();
        }

        public WorkflowExecution getExecution() {
            return execution;
        }

        public Map<String, Object> getVariables() {
            return variables;
        }

        public Object getVariable(String name) {
            return variables.get(name);
        }

        public void setVariable(String name, Object value) {
            variables.put(name, value);
        }

        public String getLogs() {
            return logs.toString();
        }

        public void appendLog(String log) {
            logs.append(log).append("\n");
        }
    }
}
