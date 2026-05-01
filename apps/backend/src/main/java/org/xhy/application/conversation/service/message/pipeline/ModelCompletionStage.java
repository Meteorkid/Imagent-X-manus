package org.xhy.application.conversation.service.message.pipeline;

import dev.langchain4j.model.chat.response.ChatResponse;
import org.xhy.application.conversation.service.handler.context.ChatContext;
import org.xhy.domain.conversation.model.MessageEntity;
import org.xhy.domain.trace.model.ModelCallInfo;
import org.xhy.infrastructure.transport.MessageTransport;

import java.util.function.BiFunction;
import java.util.function.Consumer;

/**
 * 模型完成流水线阶段：负责响应落库、传输结束消息、可用性上报与追踪回调触发。
 */
public interface ModelCompletionStage {

    <T> void handle(
            ChatContext chatContext,
            ChatResponse chatResponse,
            long latency,
            MessageEntity userEntity,
            MessageEntity llmEntity,
            MessageTransport<T> transport,
            T connection,
            BiFunction<ChatResponse, Long, ModelCallInfo> modelCallInfoBuilder,
            Consumer<ModelCallInfo> traceHook);
}
