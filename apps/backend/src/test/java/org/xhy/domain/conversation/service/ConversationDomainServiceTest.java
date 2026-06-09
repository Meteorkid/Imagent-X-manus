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

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
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
    void saveMessage_ShouldInsertMessage() {
        // Act
        MessageEntity result = conversationDomainService.saveMessage(testMessage);

        // Assert
        assertNotNull(result);
        assertEquals(testMessage, result);
        verify(messageRepository, times(1)).insert(testMessage);
    }

    @Test
    void deleteConversationMessages_ShouldDeleteMessages() {
        // Act
        conversationDomainService.deleteConversationMessages(testSessionId);

        // Assert
        verify(messageRepository, times(1)).delete(any());
    }
}
