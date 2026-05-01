package org.xhy.application.conversation.service.message.tracing;

import dev.langchain4j.model.chat.response.ChatResponse;
import org.xhy.application.conversation.service.handler.context.ChatContext;
import org.xhy.domain.conversation.model.MessageEntity;
import org.xhy.domain.trace.constant.ExecutionPhase;
import org.xhy.domain.trace.model.ModelCallInfo;
import org.xhy.domain.trace.model.ToolCallInfo;
import org.xhy.domain.trace.model.TraceContext;

/**
 * 对话追踪编排端口：处理 trace 生命周期与上下文传播。
 */
public interface ChatTraceOrchestrator {

    void onChatStart(ChatContext chatContext);

    void onUserMessageProcessed(ChatContext chatContext, MessageEntity userMessage);

    void onModelCallCompleted(ChatContext chatContext, ChatResponse chatResponse, ModelCallInfo modelCallInfo);

    void onToolCallCompleted(ChatContext chatContext, ToolCallInfo toolCallInfo);

    void onChatCompleted(ChatContext chatContext, boolean success, String errorMessage);

    void onChatError(ChatContext chatContext, ExecutionPhase errorPhase, Throwable throwable);

    TraceContext current();

    void setCurrent(TraceContext traceContext);

    void clear();
}
