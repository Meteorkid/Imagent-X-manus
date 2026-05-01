package org.xhy.application.conversation.service.message.tracing;

import dev.langchain4j.model.chat.response.ChatResponse;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;
import org.xhy.application.conversation.service.handler.context.ChatContext;
import org.xhy.application.conversation.service.handler.context.TracingChatContext;
import org.xhy.application.trace.collector.TraceCollector;
import org.xhy.domain.conversation.constant.MessageType;
import org.xhy.domain.conversation.model.MessageEntity;
import org.xhy.domain.trace.constant.ExecutionPhase;
import org.xhy.domain.trace.model.ModelCallInfo;
import org.xhy.domain.trace.model.ToolCallInfo;
import org.xhy.domain.trace.model.TraceContext;

/**
 * 追踪端口默认实现：基于 TraceCollector + InheritableThreadLocal。
 */
@Component
public class TraceCollectorChatTraceOrchestrator implements ChatTraceOrchestrator {

    private static final Logger logger = LoggerFactory.getLogger(TraceCollectorChatTraceOrchestrator.class);

    private final TraceCollector traceCollector;
    private static final InheritableThreadLocal<TraceContext> CURRENT = new InheritableThreadLocal<>();

    public TraceCollectorChatTraceOrchestrator(TraceCollector traceCollector) {
        this.traceCollector = traceCollector;
    }

    @Override
    public void onChatStart(ChatContext chatContext) {
        try {
            TraceContext traceContext = traceCollector.getOrStartExecution(
                    chatContext.getUserId(),
                    chatContext.getSessionId(),
                    chatContext.getAgent().getId(),
                    chatContext.getUserMessage(),
                    MessageType.TEXT.name());
            setCurrent(traceContext);
            if (chatContext instanceof TracingChatContext) {
                chatContext.setTraceContext(traceContext);
            }
        } catch (Exception e) {
            logger.error("❌ [TRACE-DEBUG] 启动对话追踪失败: {}", e.getMessage(), e);
        }
    }

    @Override
    public void onUserMessageProcessed(ChatContext chatContext, MessageEntity userMessage) {
        TraceContext traceContext = current();
        if (traceContext != null && traceContext.isTraceEnabled()) {
            logger.debug("用户消息已处理 - TraceId: {}, 消息长度: {}",
                    traceContext.getTraceId(), userMessage.getContent().length());
        }
    }

    @Override
    public void onModelCallCompleted(ChatContext chatContext, ChatResponse chatResponse, ModelCallInfo modelCallInfo) {
        TraceContext traceContext = current();
        if (traceContext == null || !traceContext.isTraceEnabled()) {
            return;
        }
        try {
            if (modelCallInfo.getInputTokens() != null) {
                traceCollector.updateUserMessageTokens(traceContext, modelCallInfo.getInputTokens());
            }
            String aiResponse = chatResponse.aiMessage().text();
            traceCollector.recordModelCall(traceContext, aiResponse, modelCallInfo);
            logger.debug("模型调用完成 - TraceId: {}, 输入Token: {}, 输出Token: {}",
                    traceContext.getTraceId(), modelCallInfo.getInputTokens(), modelCallInfo.getOutputTokens());
        } catch (Exception e) {
            logger.warn("记录模型调用信息失败: {}", e.getMessage());
        }
    }

    @Override
    public void onToolCallCompleted(ChatContext chatContext, ToolCallInfo toolCallInfo) {
        TraceContext traceContext = current();
        if (traceContext == null || !traceContext.isTraceEnabled()) {
            return;
        }
        try {
            traceCollector.recordToolCall(traceContext, toolCallInfo);
            logger.debug("工具调用完成 - TraceId: {}, 工具名称: {}",
                    traceContext.getTraceId(), toolCallInfo.getToolName());
        } catch (Exception e) {
            logger.warn("记录工具调用信息失败: {}", e.getMessage());
        }
    }

    @Override
    public void onChatCompleted(ChatContext chatContext, boolean success, String errorMessage) {
        TraceContext traceContext = current();
        if (traceContext != null && traceContext.isTraceEnabled()) {
            try {
                if (success) {
                    traceCollector.recordSuccess(traceContext);
                    logger.debug("对话完成 - TraceId: {}, 状态: 成功", traceContext.getTraceId());
                } else {
                    traceCollector.recordFailure(traceContext, ExecutionPhase.RESULT_PROCESSING, errorMessage);
                    logger.debug("对话完成 - TraceId: {}, 状态: 失败, 错误: {}",
                            traceContext.getTraceId(), errorMessage);
                }
            } catch (Exception e) {
                logger.warn("完成对话追踪失败: {}", e.getMessage());
            } finally {
                clear();
            }
        } else {
            clear();
        }
    }

    @Override
    public void onChatError(ChatContext chatContext, ExecutionPhase errorPhase, Throwable throwable) {
        TraceContext traceContext = current();
        if (traceContext == null || !traceContext.isTraceEnabled()) {
            return;
        }
        try {
            traceCollector.recordFailure(traceContext, errorPhase, throwable);
            traceCollector.recordErrorDetail(traceContext, errorPhase, throwable);
            logger.debug("对话异常 - TraceId: {}, 阶段: {}, 异常: {}",
                    traceContext.getTraceId(), errorPhase.getDescription(), throwable.getMessage());
        } catch (Exception e) {
            logger.warn("记录对话异常失败: {}", e.getMessage());
        }
    }

    @Override
    public TraceContext current() {
        return CURRENT.get();
    }

    @Override
    public void setCurrent(TraceContext traceContext) {
        CURRENT.set(traceContext);
    }

    @Override
    public void clear() {
        CURRENT.remove();
    }
}
