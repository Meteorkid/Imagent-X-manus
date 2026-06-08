package org.xhy.domain.conversation.service;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.xhy.domain.conversation.constant.Role;
import org.xhy.domain.conversation.model.MessageEntity;
import org.xhy.domain.conversation.repository.MessageRepository;

import java.time.LocalDateTime;
import java.util.Arrays;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class ConversationDomainServiceTest {

    @Mock
    private MessageRepository messageRepository;

    @InjectMocks
    private ConversationDomainService conversationDomainService;

    private MessageEntity testMessage;
    private String testSessionId;

    @BeforeEach
    void setUp() {
        testSessionId = "test-session-123";
        testMessage = new MessageEntity();
        testMessage.setId("msg-123");
        testMessage.setSessionId(testSessionId);
        testMessage.setRole(Role.USER);
        testMessage.setContent("Hello, world!");
        testMessage.setCreatedAt(LocalDateTime.now());
    }

    @Test
    void getConversationMessages_ShouldReturnMessages() {
        // Arrange
        List<MessageEntity> expectedMessages = Arrays.asList(testMessage);
        when(messageRepository.selectList(any())).thenReturn(expectedMessages);

        // Act
        List<MessageEntity> result = conversationDomainService.getConversationMessages(testSessionId);

        // Assert
        assertNotNull(result);
        assertEquals(1, result.size());
        assertEquals(testMessage, result.get(0));
        verify(messageRepository, times(1)).selectList(any());
    }

    @Test
    void saveMessage_ShouldInsertMessage() {
        // Arrange
        when(messageRepository.insert(any(MessageEntity.class))).thenReturn(true);

        // Act
        MessageEntity result = conversationDomainService.saveMessage(testMessage);

        // Assert
        assertNotNull(result);
        assertEquals(testMessage, result);
        verify(messageRepository, times(1)).insert(testMessage);
    }

    @Test
    void deleteConversationMessages_ShouldDeleteMessages() {
        // Arrange
        doNothing().when(messageRepository).delete(any());

        // Act
        conversationDomainService.deleteConversationMessages(testSessionId);

        // Assert
        verify(messageRepository, times(1)).delete(any());
    }

    @Test
    void deleteConversationMessages_WithMultipleSessionIds_ShouldDeleteMessages() {
        // Arrange
        List<String> sessionIds = Arrays.asList("session-1", "session-2");
        doNothing().when(messageRepository).checkedDelete(any());

        // Act
        conversationDomainService.deleteConversationMessages(sessionIds);

        // Assert
        verify(messageRepository, times(1)).checkedDelete(any());
    }

    @Test
    void updateMessageTokenCount_ShouldUpdateMessage() {
        // Arrange
        testMessage.setTokenCount(100);
        doNothing().when(messageRepository).checkedUpdateById(any(MessageEntity.class));

        // Act
        conversationDomainService.updateMessageTokenCount(testMessage);

        // Assert
        verify(messageRepository, times(1)).checkedUpdateById(testMessage);
    }

    @Test
    void insertBathMessage_ShouldInsertMultipleMessages() {
        // Arrange
        List<MessageEntity> messages = Arrays.asList(testMessage, new MessageEntity());
        when(messageRepository.insert(messages)).thenReturn(true);

        // Act
        conversationDomainService.insertBathMessage(messages);

        // Assert
        verify(messageRepository, times(1)).insert(messages);
    }
}
