package org.xhy.application.conversation.service.message.pipeline;

import org.springframework.stereotype.Component;
import org.xhy.application.conversation.dto.AgentChatResponse;
import org.xhy.application.conversation.service.handler.context.ChatContext;
import org.xhy.domain.conversation.constant.MessageType;
import org.xhy.domain.llm.service.HighAvailabilityDomainService;
import org.xhy.domain.trace.constant.ExecutionPhase;
import org.xhy.infrastructure.transport.MessageTransport;

import java.util.function.BiConsumer;
import java.util.function.Consumer;

/**
 * 默认模型错误阶段实现。
 */
@Component
public class DefaultModelErrorStage implements ModelErrorStage {

    private final HighAvailabilityDomainService highAvailabilityDomainService;

    public DefaultModelErrorStage(HighAvailabilityDomainService highAvailabilityDomainService) {
        this.highAvailabilityDomainService = highAvailabilityDomainService;
    }

    @Override
    public <T> void handle(
            ChatContext chatContext,
            Throwable throwable,
            long latency,
            MessageTransport<T> transport,
            T connection,
            BiConsumer<ExecutionPhase, Throwable> traceErrorHook,
            Consumer<String> completionHook) {

        String errorMessage = throwable.getMessage();
        transport.sendMessage(connection, AgentChatResponse.buildEndMessage(errorMessage, MessageType.TEXT));

        highAvailabilityDomainService.reportCallResult(
                chatContext.getInstanceId(), chatContext.getModel().getId(), false, latency, errorMessage);

        traceErrorHook.accept(ExecutionPhase.MODEL_CALL, throwable);
        completionHook.accept(errorMessage);
    }
}
