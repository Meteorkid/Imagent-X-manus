package org.xhy.domain.task.service;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.xhy.domain.task.model.TaskAggregate;
import org.xhy.domain.task.model.TaskEntity;
import org.xhy.domain.task.repository.TaskRepository;

import java.time.LocalDateTime;
import java.util.Arrays;
import java.util.List;

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
    private String testSessionId;
    private String testUserId;

    @BeforeEach
    void setUp() {
        testSessionId = "session-123";
        testUserId = "user-123";
        testTask = new TaskEntity();
        testTask.setId("task-123");
        testTask.setSessionId(testSessionId);
        testTask.setUserId(testUserId);
        testTask.setParentTaskId("0");
        testTask.setContent("Test task");
        testTask.setCreatedAt(LocalDateTime.now());
    }

    @Test
    void addTask_ShouldAddTask() {
        // Arrange
        when(taskRepository.checkInsert(any(TaskEntity.class))).thenReturn(true);

        // Act
        TaskEntity result = taskDomainService.addTask(testTask);

        // Assert
        assertNotNull(result);
        assertEquals(testTask, result);
        assertNotNull(result.getStartTime());
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

    @Test
    void getCurrentSessionTask_ShouldReturnTaskAggregate() {
        // Arrange
        List<TaskEntity> subTasks = Arrays.asList(
            createSubTask("sub-task-1", testTask.getId()),
            createSubTask("sub-task-2", testTask.getId())
        );
        when(taskRepository.selectOne(any())).thenReturn(testTask);
        when(taskRepository.selectList(any())).thenReturn(subTasks);

        // Act
        TaskAggregate result = taskDomainService.getCurrentSessionTask(testSessionId, testUserId);

        // Assert
        assertNotNull(result);
        assertEquals(testTask, result.getTask());
        assertEquals(2, result.getSubTasks().size());
        verify(taskRepository, times(1)).selectOne(any());
        verify(taskRepository, times(1)).selectList(any());
    }

    @Test
    void getSubTasks_ShouldReturnSubTasks() {
        // Arrange
        List<TaskEntity> expectedSubTasks = Arrays.asList(
            createSubTask("sub-task-1", testTask.getId()),
            createSubTask("sub-task-2", testTask.getId())
        );
        when(taskRepository.selectList(any())).thenReturn(expectedSubTasks);

        // Act
        List<TaskEntity> result = taskDomainService.getSubTasks(testTask.getId());

        // Assert
        assertNotNull(result);
        assertEquals(2, result.size());
        verify(taskRepository, times(1)).selectList(any());
    }

    private TaskEntity createSubTask(String id, String parentTaskId) {
        TaskEntity subTask = new TaskEntity();
        subTask.setId(id);
        subTask.setParentTaskId(parentTaskId);
        subTask.setSessionId(testSessionId);
        subTask.setUserId(testUserId);
        subTask.setContent("Sub task " + id);
        subTask.setCreatedAt(LocalDateTime.now());
        return subTask;
    }
}
