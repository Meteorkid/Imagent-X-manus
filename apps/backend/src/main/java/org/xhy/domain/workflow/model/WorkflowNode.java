package org.xhy.domain.workflow.model;

import lombok.Data;
import java.util.List;
import java.util.Map;

/**
 * 工作流节点
 */
@Data
public class WorkflowNode {

    /**
     * 节点ID
     */
    private String id;

    /**
     * 节点名称
     */
    private String name;

    /**
     * 节点类型
     */
    private NodeType type;

    /**
     * 节点配置
     */
    private Map<String, Object> config;

    /**
     * 输入参数
     */
    private Map<String, Object> inputs;

    /**
     * 输出参数
     */
    private Map<String, Object> outputs;

    /**
     * 下一个节点ID列表
     */
    private List<String> nextNodes;

    /**
     * 条件表达式
     */
    private String condition;

    /**
     * 节点描述
     */
    private String description;

    /**
     * 节点类型枚举
     */
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

        public String getCode() {
            return code;
        }

        public String getDescription() {
            return description;
        }
    }
}
