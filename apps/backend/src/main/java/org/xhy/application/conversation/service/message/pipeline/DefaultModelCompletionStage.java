package org.xhy.application.conversation.service.message.pipeline;

import dev.langchain4j.model.chat.response.ChatResponse;
import org.springframework.stereotype.Component;
import org.xhy.application.conversation.dto.AgentChatResponse;
import org.xhy.application.conversation.service.handler.context.ChatContext;
import org.xhy.domain.conversation.constant.MessageType;
import org.xhy.domain.conversation.model.MessageEntity;
import org.xhy.domain.conversation.service.MessageDomainService;
import org.xhy.domain.llm.service.HighAvailabilityDomainService;
import org.xhy.domain.trace.model.ModelCallInfo;
import org.xhy.infrastructure.transport.MessageTransport;

import java.util.Collections;
import java.util.function.BiFunction;
import java.util.function.Consumer;

/**
 * 默认模型完成阶段实现。
 */
@Component
public class DefaultModelCompletionStage implements ModelCompletionStage {

    private final MessageDomainService messageDomainService;
    private final HighAvailabilityDomainService highAvailabilityDomainService;

    public DefaultModelCompletionStage(
            MessageDomainService messageDomainService,
            HighAvailabilityDomainService highAvailabilityDomainService) {
        this.messageDomainService = messageDomainService;
        this.highAvailabilityDomainService = highAvailabilityDomainService;
    }

    @Override
    public <T> void handle(
            ChatContext chatContext,
            ChatResponse chatResponse,
            long latency,
            MessageEntity userEntity,
            MessageEntity llmEntity,
            MessageTransport<T> transport,
            T connection,
            BiFunction<ChatResponse, Long, ModelCallInfo> modelCallInfoBuilder,
            Consumer<ModelCallInfo> traceHook) {

        messageDomainService.updateMessage(userEntity);
        messageDomainService.saveMessageAndUpdateContext(
                Collections.singletonList(llmEntity), chatContext.getContextEntity());

        transport.sendEndMessage(connection, AgentChatResponse.buildEndMessage(MessageType.TEXT));

        highAvailabilityDomainService.reportCallResult(
                chatContext.getInstanceId(), chatContext.getModel().getId(), true, latency, null);

        traceHook.accept(modelCallInfoBuilder.apply(chatResponse, latency));
    }
}
