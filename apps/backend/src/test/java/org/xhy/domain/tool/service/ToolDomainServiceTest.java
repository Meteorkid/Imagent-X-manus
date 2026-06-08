package org.xhy.domain.tool.service;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.xhy.domain.tool.constant.ToolStatus;
import org.xhy.domain.tool.model.ToolEntity;
import org.xhy.domain.tool.model.ToolOperationResult;
import org.xhy.domain.tool.repository.ToolRepository;
import org.xhy.domain.tool.repository.ToolVersionRepository;
import org.xhy.domain.tool.repository.UserToolRepository;
import org.xhy.domain.user.repository.UserRepository;
import org.xhy.infrastructure.exception.BusinessException;

import java.time.LocalDateTime;
import java.util.Arrays;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class ToolDomainServiceTest {

    @Mock
    private ToolRepository toolRepository;

    @Mock
    private ToolVersionRepository toolVersionRepository;

    @Mock
    private UserToolRepository userToolRepository;

    @Mock
    private UserRepository userRepository;

    @InjectMocks
    private ToolDomainService toolDomainService;

    private ToolEntity testTool;
    private String testUserId;

    @BeforeEach
    void setUp() {
        testUserId = "user-123";
        testTool = new ToolEntity();
        testTool.setId("tool-123");
        testTool.setUserId(testUserId);
        testTool.setName("Test Tool");
        testTool.setDescription("A test tool");
        testTool.setStatus(ToolStatus.WAITING_REVIEW);
        testTool.setCreatedAt(LocalDateTime.now());
        testTool.setUpdatedAt(LocalDateTime.now());
    }

    @Test
    void createTool_ShouldCreateTool() {
        // Arrange
        when(toolRepository.checkInsert(any(ToolEntity.class))).thenReturn(true);

        // Act
        ToolOperationResult result = toolDomainService.createTool(testTool);

        // Assert
        assertNotNull(result);
        assertEquals(testTool, result.getTool());
        assertEquals(ToolStatus.WAITING_REVIEW, testTool.getStatus());
        verify(toolRepository, times(1)).checkInsert(testTool);
    }

    @Test
    void getTool_ShouldReturnTool() {
        // Arrange
        when(toolRepository.selectOne(any())).thenReturn(testTool);

        // Act
        ToolEntity result = toolDomainService.getTool(testTool.getId(), testUserId);

        // Assert
        assertNotNull(result);
        assertEquals(testTool, result);
        verify(toolRepository, times(1)).selectOne(any());
    }

    @Test
    void getTool_WhenToolNotFound_ShouldThrowException() {
        // Arrange
        when(toolRepository.selectOne(any())).thenReturn(null);

        // Act & Assert
        assertThrows(BusinessException.class, () -> {
            toolDomainService.getTool("non-existent-tool", testUserId);
        });
        verify(toolRepository, times(1)).selectOne(any());
    }

    @Test
    void getUserTools_ShouldReturnUserTools() {
        // Arrange
        List<ToolEntity> expectedTools = Arrays.asList(testTool);
        when(toolRepository.selectList(any())).thenReturn(expectedTools);

        // Act
        List<ToolEntity> result = toolDomainService.getUserTools(testUserId);

        // Assert
        assertNotNull(result);
        assertEquals(1, result.size());
        assertEquals(testTool, result.get(0));
        verify(toolRepository, times(1)).selectList(any());
    }

    @Test
    void updateApprovedToolStatus_ShouldUpdateStatus() {
        // Arrange
        ToolEntity updatedTool = new ToolEntity();
        updatedTool.setId(testTool.getId());
        updatedTool.setStatus(ToolStatus.APPROVED);
        when(toolRepository.selectById(testTool.getId())).thenReturn(updatedTool);

        // Act
        ToolEntity result = toolDomainService.updateApprovedToolStatus(testTool.getId(), ToolStatus.APPROVED);

        // Assert
        assertNotNull(result);
        assertEquals(ToolStatus.APPROVED, result.getStatus());
        verify(toolRepository, times(1)).checkedUpdate(any());
        verify(toolRepository, times(1)).selectById(testTool.getId());
    }

    @Test
    void updateTool_WhenToolNotFound_ShouldThrowException() {
        // Arrange
        when(toolRepository.selectById(testTool.getId())).thenReturn(null);

        // Act & Assert
        assertThrows(BusinessException.class, () -> {
            toolDomainService.updateTool(testTool);
        });
        verify(toolRepository, times(1)).selectById(testTool.getId());
    }
}
