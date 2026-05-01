package org.xhy.application.conversation.service.message.pipeline;

import dev.langchain4j.service.tool.ToolExecution;
import org.xhy.application.conversation.service.handler.context.ChatContext;
import org.xhy.domain.conversation.model.MessageEntity;
import org.xhy.domain.trace.model.ToolCallInfo;
import org.xhy.infrastructure.transport.MessageTransport;

import java.util.concurrent.atomic.AtomicReference;
import java.util.function.Consumer;
import java.util.function.Function;

/**
 * 工具执行流水线阶段：负责工具执行消息落库、传输消息与追踪回调触发。
 */
public interface ToolExecutionStage {

    <T> void handle(
            ChatContext chatContext,
            ToolExecution toolExecution,
            AtomicReference<StringBuilder> messageBuilder,
            MessageEntity llmEntity,
            MessageTransport<T> transport,
            T connection,
            Function<ToolExecution, ToolCallInfo> toolCallInfoBuilder,
            Consumer<ToolCallInfo> traceHook);
}
