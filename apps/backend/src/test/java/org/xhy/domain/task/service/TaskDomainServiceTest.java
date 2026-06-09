package org.xhy.domain.task.service;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.xhy.domain.task.model.TaskEntity;
import org.xhy.domain.task.repository.TaskRepository;

import java.time.LocalDateTime;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class TaskDomainServiceTest {

    @Mock
    private TaskRepository taskRepository;

    @InjectMocks
    private TaskDomainService taskDomainService;

    private TaskEntity testTask;

    @BeforeEach
    void setUp() {
        testTask = new TaskEntity();
        testTask.setId("task-123");
        testTask.setSessionId("session-123");
        testTask.setUserId("user-123");
        testTask.setParentTaskId("0");
    }

    @Test
    void addTask_ShouldAddTask() {
        // Arrange
        doNothing().when(taskRepository).checkInsert(any(TaskEntity.class));

        // Act
        TaskEntity result = taskDomainService.addTask(testTask);

        // Assert
        assertNotNull(result);
        assertEquals(testTask, result);
        verify(taskRepository, times(1)).checkInsert(testTask);
    }

    @Test
    void updateTask_ShouldUpdateTask() {
        // Arrange
        doNothing().when(taskRepository).checkedUpdateById(any(TaskEntity.class));

        // Act
        TaskEntity result = taskDomainService.updateTask(testTask);

        // Assert
        assertNotNull(result);
        assertEquals(testTask, result);
        verify(taskRepository, times(1)).checkedUpdateById(testTask);
    }
}
