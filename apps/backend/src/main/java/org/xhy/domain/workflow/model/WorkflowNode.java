package org.xhy.domain.workflow.model;

import java.util.List;
import java.util.Map;

/**
 * 工作流节点
 */
public class WorkflowNode {

    private String id;
    private String name;
    private NodeType type;
    private Map<String, Object> config;
    private Map<String, Object> inputs;
    private Map<String, Object> outputs;
    private List<String> nextNodes;
    private String condition;
    private String description;

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public NodeType getType() { return type; }
    public void setType(NodeType type) { this.type = type; }

    public Map<String, Object> getConfig() { return config; }
    public void setConfig(Map<String, Object> config) { this.config = config; }

    public Map<String, Object> getInputs() { return inputs; }
    public void setInputs(Map<String, Object> inputs) { this.inputs = inputs; }

    public Map<String, Object> getOutputs() { return outputs; }
    public void setOutputs(Map<String, Object> outputs) { this.outputs = outputs; }

    public List<String> getNextNodes() { return nextNodes; }
    public void setNextNodes(List<String> nextNodes) { this.nextNodes = nextNodes; }

    public String getCondition() { return condition; }
    public void setCondition(String condition) { this.condition = condition; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public enum NodeType {
        START("start", "开始节点"),
        END("end", "结束节点"),
        TASK("task", "任务节点"),
        CONDITION("condition", "条件节点"),
        PARALLEL("parallel", "并行节点"),
        LOOP("loop", "循环节点"),
        HUMAN("human", "人工节点"),
        SUBPROCESS("subprocess", "子流程节点");

        private final String code;
        private final String description;

        NodeType(String code, String description) {
            this.code = code;
            this.description = description;
        }

        public String getCode() { return code; }
        public String getDescription() { return description; }
    }
}
