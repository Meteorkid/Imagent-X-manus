package org.xhy.application.conversation.service.message.pipeline;

import dev.langchain4j.service.tool.ToolExecution;
import org.springframework.stereotype.Component;
import org.xhy.application.conversation.dto.AgentChatResponse;
import org.xhy.application.conversation.service.handler.context.ChatContext;
import org.xhy.domain.conversation.constant.MessageType;
import org.xhy.domain.conversation.model.MessageEntity;
import org.xhy.domain.conversation.service.MessageDomainService;
import org.xhy.domain.trace.model.ToolCallInfo;
import org.xhy.infrastructure.transport.MessageTransport;

import java.util.Collections;
import java.util.concurrent.atomic.AtomicReference;
import java.util.function.Consumer;
import java.util.function.Function;

/**
 * 默认工具执行阶段实现。
 */
@Component
public class DefaultToolExecutionStage implements ToolExecutionStage {

    private final MessageDomainService messageDomainService;

    public DefaultToolExecutionStage(MessageDomainService messageDomainService) {
        this.messageDomainService = messageDomainService;
    }

    @Override
    public <T> void handle(
            ChatContext chatContext,
            ToolExecution toolExecution,
            AtomicReference<StringBuilder> messageBuilder,
            MessageEntity llmEntity,
            MessageTransport<T> transport,
            T connection,
            Function<ToolExecution, ToolCallInfo> toolCallInfoBuilder,
            Consumer<ToolCallInfo> traceHook) {

        if (!messageBuilder.get().isEmpty()) {
            transport.sendMessage(connection, AgentChatResponse.buildEndMessage(MessageType.TEXT));
            llmEntity.setContent(messageBuilder.get().toString());
            messageDomainService.saveMessageAndUpdateContext(
                    Collections.singletonList(llmEntity), chatContext.getContextEntity());
            messageBuilder.set(new StringBuilder());
        }

        String message = "执行工具：" + toolExecution.request().name();
        MessageEntity toolMessage = createToolMessage(chatContext, message);
        messageDomainService.saveMessageAndUpdateContext(
                Collections.singletonList(toolMessage), chatContext.getContextEntity());

        transport.sendMessage(connection, AgentChatResponse.buildEndMessage(message, MessageType.TOOL_CALL));
        traceHook.accept(toolCallInfoBuilder.apply(toolExecution));
    }

    private MessageEntity createToolMessage(ChatContext chatContext, String content) {
        MessageEntity messageEntity = new MessageEntity();
        messageEntity.setSessionId(chatContext.getSessionId());
        messageEntity.setModel(chatContext.getModel().getModelId());
        messageEntity.setProvider(chatContext.getProvider().getId());
        messageEntity.setMessageType(MessageType.TOOL_CALL);
        messageEntity.setContent(content);
        return messageEntity;
    }
}
