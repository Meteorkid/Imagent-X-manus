package org.xhy.domain.workflow.model;

import org.junit.jupiter.api.Test;
import org.xhy.domain.workflow.constant.WorkflowStatus;

import java.time.LocalDateTime;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import static org.junit.jupiter.api.Assertions.*;

class WorkflowTest {

    @Test
    void workflow_ShouldCreateWithRequiredFields() {
        // Arrange & Act
        Workflow workflow = new Workflow();
        workflow.setId("workflow-123");
        workflow.setName("Test Workflow");
        workflow.setDescription("A test workflow");
        workflow.setVersion("1.0.0");
        workflow.setStatus(WorkflowStatus.DRAFT);

        // Assert
        assertEquals("workflow-123", workflow.getId());
        assertEquals("Test Workflow", workflow.getName());
        assertEquals("A test workflow", workflow.getDescription());
        assertEquals("1.0.0", workflow.getVersion());
        assertEquals(WorkflowStatus.DRAFT, workflow.getStatus());
    }

    @Test
    void workflow_ShouldSupportTags() {
        // Arrange
        Workflow workflow = new Workflow();
        List<String> tags = Arrays.asList("automation", "test", "demo");

        // Act
        workflow.setTags(tags);

        // Assert
        assertNotNull(workflow.getTags());
        assertEquals(3, workflow.getTags().size());
        assertTrue(workflow.getTags().contains("automation"));
    }

    @Test
    void workflow_ShouldSupportConfig() {
        // Arrange
        Workflow workflow = new Workflow();
        Map<String, Object> config = new HashMap<>();
        config.put("timeout", 300);
        config.put("retries", 3);

        // Act
        workflow.setConfig(config);

        // Assert
        assertNotNull(workflow.getConfig());
        assertEquals(300, workflow.getConfig().get("timeout"));
        assertEquals(3, workflow.getConfig().get("retries"));
    }

    @Test
    void workflow_ShouldTrackExecutionCount() {
        // Arrange
        Workflow workflow = new Workflow();

        // Act
        workflow.setExecutionCount(10);

        // Assert
        assertEquals(10, workflow.getExecutionCount());
    }

    @Test
    void workflow_ShouldTrackTimestamps() {
        // Arrange
        Workflow workflow = new Workflow();
        LocalDateTime now = LocalDateTime.now();

        // Act
        workflow.setCreatedAt(now);
        workflow.setUpdatedAt(now);
        workflow.setLastExecutedAt(now);

        // Assert
        assertEquals(now, workflow.getCreatedAt());
        assertEquals(now, workflow.getUpdatedAt());
        assertEquals(now, workflow.getLastExecutedAt());
    }
}
