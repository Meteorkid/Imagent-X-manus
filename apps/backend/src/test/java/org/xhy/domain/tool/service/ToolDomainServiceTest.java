package org.xhy.domain.tool.service;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.xhy.domain.tool.constant.ToolStatus;
import org.xhy.domain.tool.model.ToolEntity;
import org.xhy.domain.tool.repository.ToolRepository;
import org.xhy.domain.tool.repository.ToolVersionRepository;
import org.xhy.domain.tool.repository.UserToolRepository;
import org.xhy.domain.user.repository.UserRepository;

import java.time.LocalDateTime;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
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

    @BeforeEach
    void setUp() {
        testTool = new ToolEntity();
        testTool.setId("tool-123");
        testTool.setUserId("user-123");
        testTool.setName("Test Tool");
        testTool.setDescription("A test tool");
        testTool.setStatus(ToolStatus.WAITING_REVIEW);
        testTool.setCreatedAt(LocalDateTime.now());
        testTool.setUpdatedAt(LocalDateTime.now());
    }

    @Test
    void getTool_WhenToolNotFound_ShouldThrowException() {
        // Arrange
        when(toolRepository.selectOne(any())).thenReturn(null);

        // Act & Assert
        assertThrows(Exception.class, () -> {
            toolDomainService.getTool("non-existent-tool", "user-123");
        });
    }
}
