package org.xhy.domain.workflow.model;

import org.junit.jupiter.api.Test;
import org.xhy.domain.workflow.constant.ExecutionStatus;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;

import static org.junit.jupiter.api.Assertions.*;

class WorkflowExecutionTest {

    @Test
    void workflowExecution_ShouldCreateWithRequiredFields() {
        // Arrange & Act
        WorkflowExecution execution = new WorkflowExecution();
        execution.setId("exec-123");
        execution.setWorkflowId("workflow-456");
        execution.setStatus(ExecutionStatus.RUNNING);

        // Assert
        assertEquals("exec-123", execution.getId());
        assertEquals("workflow-456", execution.getWorkflowId());
        assertEquals(ExecutionStatus.RUNNING, execution.getStatus());
    }

    @Test
    void workflowExecution_ShouldSupportInputsOutputs() {
        // Arrange
        WorkflowExecution execution = new WorkflowExecution();
        Map<String, Object> inputs = new HashMap<>();
        inputs.put("email", "test@example.com");
        Map<String, Object> outputs = new HashMap<>();
        outputs.put("userId", "user-123");

        // Act
        execution.setInputs(inputs);
        execution.setOutputs(outputs);

        // Assert
        assertNotNull(execution.getInputs());
        assertNotNull(execution.getOutputs());
        assertEquals("test@example.com", execution.getInputs().get("email"));
        assertEquals("user-123", execution.getOutputs().get("userId"));
    }

    @Test
    void workflowExecution_ShouldTrackCurrentNode() {
        // Arrange
        WorkflowExecution execution = new WorkflowExecution();

        // Act
        execution.setCurrentNodeId("node-validate");

        // Assert
        assertEquals("node-validate", execution.getCurrentNodeId());
    }

    @Test
    void workflowExecution_ShouldTrackError() {
        // Arrange
        WorkflowExecution execution = new WorkflowExecution();

        // Act
        execution.setErrorMessage("Connection timeout");
        execution.setErrorStack("java.lang.RuntimeException: ...");

        // Assert
        assertEquals("Connection timeout", execution.getErrorMessage());
        assertNotNull(execution.getErrorStack());
    }

    @Test
    void workflowExecution_ShouldTrackTiming() {
        // Arrange
        WorkflowExecution execution = new WorkflowExecution();
        LocalDateTime start = LocalDateTime.now();
        LocalDateTime end = start.plusMinutes(5);

        // Act
        execution.setStartTime(start);
        execution.setEndTime(end);
        execution.setDuration(300000); // 5 minutes in milliseconds

        // Assert
        assertEquals(start, execution.getStartTime());
        assertEquals(end, execution.getEndTime());
        assertEquals(300000, execution.getDuration());
    }

    @Test
    void workflowExecution_ShouldTrackRetryCount() {
        // Arrange
        WorkflowExecution execution = new WorkflowExecution();

        // Act
        execution.setRetryCount(3);

        // Assert
        assertEquals(3, execution.getRetryCount());
    }

    @Test
    void executionStatus_ShouldHaveCorrectValues() {
        // Assert
        assertEquals("pending", ExecutionStatus.PENDING.getCode());
        assertEquals("running", ExecutionStatus.RUNNING.getCode());
        assertEquals("completed", ExecutionStatus.COMPLETED.getCode());
        assertEquals("failed", ExecutionStatus.FAILED.getCode());
        assertEquals("cancelled", ExecutionStatus.CANCELLED.getCode());
        assertEquals("paused", ExecutionStatus.PAUSED.getCode());
    }
}
