package org.xhy.application.conversation.service.message.pipeline;

import org.xhy.application.conversation.service.handler.context.ChatContext;
import org.xhy.domain.trace.constant.ExecutionPhase;
import org.xhy.infrastructure.transport.MessageTransport;

import java.util.function.BiConsumer;
import java.util.function.Consumer;

/**
 * 模型错误流水线阶段：负责错误回包、可用性失败上报与追踪错误回调触发。
 */
public interface ModelErrorStage {

    <T> void handle(
            ChatContext chatContext,
            Throwable throwable,
            long latency,
            MessageTransport<T> transport,
            T connection,
            BiConsumer<ExecutionPhase, Throwable> traceErrorHook,
            Consumer<String> completionHook);
}
