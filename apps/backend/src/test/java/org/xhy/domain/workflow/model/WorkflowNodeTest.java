package org.xhy.domain.workflow.model;

import org.junit.jupiter.api.Test;

import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import static org.junit.jupiter.api.Assertions.*;

class WorkflowNodeTest {

    @Test
    void workflowNode_ShouldCreateWithRequiredFields() {
        // Arrange & Act
        WorkflowNode node = new WorkflowNode();
        node.setId("node-1");
        node.setName("Start Node");
        node.setType(WorkflowNode.NodeType.START);

        // Assert
        assertEquals("node-1", node.getId());
        assertEquals("Start Node", node.getName());
        assertEquals(WorkflowNode.NodeType.START, node.getType());
    }

    @Test
    void workflowNode_ShouldSupportConfig() {
        // Arrange
        WorkflowNode node = new WorkflowNode();
        Map<String, Object> config = new HashMap<>();
        config.put("handler", "validateUser");
        config.put("timeout", 60);

        // Act
        node.setConfig(config);

        // Assert
        assertNotNull(node.getConfig());
        assertEquals("validateUser", node.getConfig().get("handler"));
        assertEquals(60, node.getConfig().get("timeout"));
    }

    @Test
    void workflowNode_ShouldSupportInputsOutputs() {
        // Arrange
        WorkflowNode node = new WorkflowNode();
        Map<String, Object> inputs = new HashMap<>();
        inputs.put("email", "${input.email}");
        Map<String, Object> outputs = new HashMap<>();
        outputs.put("userId", "${createUser.result.id}");

        // Act
        node.setInputs(inputs);
        node.setOutputs(outputs);

        // Assert
        assertNotNull(node.getInputs());
        assertNotNull(node.getOutputs());
        assertEquals("${input.email}", node.getInputs().get("email"));
    }

    @Test
    void workflowNode_ShouldSupportNextNodes() {
        // Arrange
        WorkflowNode node = new WorkflowNode();
        List<String> nextNodes = Arrays.asList("node-2", "node-3");

        // Act
        node.setNextNodes(nextNodes);

        // Assert
        assertNotNull(node.getNextNodes());
        assertEquals(2, node.getNextNodes().size());
        assertTrue(node.getNextNodes().contains("node-2"));
    }

    @Test
    void workflowNode_ShouldSupportCondition() {
        // Arrange
        WorkflowNode node = new WorkflowNode();

        // Act
        node.setCondition("${validate.result.exists} == false");

        // Assert
        assertEquals("${validate.result.exists} == false", node.getCondition());
    }

    @Test
    void nodeType_ShouldHaveCorrectValues() {
        // Assert
        assertEquals("start", WorkflowNode.NodeType.START.getCode());
        assertEquals("end", WorkflowNode.NodeType.END.getCode());
        assertEquals("task", WorkflowNode.NodeType.TASK.getCode());
        assertEquals("condition", WorkflowNode.NodeType.CONDITION.getCode());
        assertEquals("parallel", WorkflowNode.NodeType.PARALLEL.getCode());
        assertEquals("loop", WorkflowNode.NodeType.LOOP.getCode());
        assertEquals("human", WorkflowNode.NodeType.HUMAN.getCode());
        assertEquals("subprocess", WorkflowNode.NodeType.SUBPROCESS.getCode());
    }

    @Test
    void nodeType_ShouldHaveCorrectDescriptions() {
        // Assert
        assertEquals("开始节点", WorkflowNode.NodeType.START.getDescription());
        assertEquals("结束节点", WorkflowNode.NodeType.END.getDescription());
        assertEquals("任务节点", WorkflowNode.NodeType.TASK.getDescription());
        assertEquals("条件节点", WorkflowNode.NodeType.CONDITION.getDescription());
    }
}
