package org.xhy.application.conversation.service.message;

import dev.langchain4j.rag.content.Content;
import org.xhy.application.billing.service.BillingService;
import org.xhy.application.conversation.service.handler.context.ChatContext;
import org.xhy.application.conversation.service.handler.context.TracingChatContext;
import org.xhy.application.conversation.service.message.pipeline.ModelCompletionStage;
import org.xhy.application.conversation.service.message.pipeline.ModelErrorStage;
import org.xhy.application.conversation.service.message.agent.tool.RagToolManager;
import org.xhy.application.conversation.service.message.pipeline.ToolExecutionStage;
import org.xhy.application.conversation.service.message.tracing.ChatTraceOrchestrator;
import org.xhy.domain.agent.model.AgentEntity;
import org.xhy.domain.conversation.model.MessageEntity;
import org.xhy.domain.conversation.service.MessageDomainService;
import org.xhy.domain.conversation.service.SessionDomainService;
import org.xhy.domain.llm.service.HighAvailabilityDomainService;
import org.xhy.domain.llm.service.LLMDomainService;
import org.xhy.domain.trace.constant.ExecutionPhase;
import org.xhy.domain.trace.model.ModelCallInfo;
import org.xhy.domain.trace.model.ToolCallInfo;
import org.xhy.domain.trace.model.TraceContext;
import org.xhy.domain.user.service.AccountDomainService;
import org.xhy.domain.user.service.UserSettingsDomainService;
import org.xhy.infrastructure.llm.LLMServiceFactory;
import dev.langchain4j.memory.chat.MessageWindowChatMemory;
import dev.langchain4j.model.chat.StreamingChatModel;
import dev.langchain4j.model.chat.response.ChatResponse;
import dev.langchain4j.service.TokenStream;
import dev.langchain4j.service.tool.ToolExecution;
import dev.langchain4j.service.tool.ToolProvider;

import java.util.List;
import java.util.function.Consumer;

/** 带追踪功能的消息处理器基类 在关键节点集成链路追踪逻辑
 * 
 * 线程上下文传递说明： - 使用 InheritableThreadLocal 将追踪上下文传递到子线程 - 适用于直接创建子线程的场景（如 tokenStream 回调）
 * 
 * 重要警告 - 线程池环境： 如果项目中引入了线程池（如 @Async、ThreadPoolExecutor、CompletableFuture 等）， InheritableThreadLocal 会导致线程复用时的上下文污染问题。
 * 
 * 线程池场景解决方案： 请使用阿里巴巴的 TransmittableThreadLocal (TTL) 替代： 1. 添加依赖：com.alibaba:transmittable-thread-local 2. 将
 * InheritableThreadLocal 替换为 TransmittableThreadLocal 3. 使用 TtlExecutors.getTtlExecutor() 包装线程池
 * 参考文档：https://github.com/alibaba/transmittable-thread-local
 *
 * 但是目前使用了 langchan4j 的 tokenStream，内置的线程池，不方便改，就算了 */
public abstract class TracingMessageHandler extends AbstractMessageHandler {

    private final ChatTraceOrchestrator chatTraceOrchestrator;

    public TracingMessageHandler(LLMServiceFactory llmServiceFactory, MessageDomainService messageDomainService,
            HighAvailabilityDomainService highAvailabilityDomainService, SessionDomainService sessionDomainService,
            UserSettingsDomainService userSettingsDomainService, LLMDomainService llmDomainService,
            RagToolManager ragToolManager, ModelCompletionStage modelCompletionStage,
            ModelErrorStage modelErrorStage, ToolExecutionStage toolExecutionStage, BillingService billingService,
            AccountDomainService accountDomainService, ChatTraceOrchestrator chatTraceOrchestrator) {
        super(llmServiceFactory, messageDomainService, highAvailabilityDomainService, sessionDomainService,
                userSettingsDomainService, llmDomainService, ragToolManager, modelCompletionStage, modelErrorStage,
                toolExecutionStage, billingService, accountDomainService);
        this.chatTraceOrchestrator = chatTraceOrchestrator;
    }

    @Override
    protected void onChatStart(ChatContext chatContext) {
        chatTraceOrchestrator.onChatStart(chatContext);
    }

    @Override
    protected void onUserMessageProcessed(ChatContext chatContext, MessageEntity userMessage) {
        chatTraceOrchestrator.onUserMessageProcessed(chatContext, userMessage);
    }

    @Override
    protected void onModelCallCompleted(ChatContext chatContext, ChatResponse chatResponse,
            ModelCallInfo modelCallInfo) {
        chatTraceOrchestrator.onModelCallCompleted(chatContext, chatResponse, modelCallInfo);
    }

    @Override
    protected void onToolCallCompleted(ChatContext chatContext, ToolCallInfo toolCallInfo) {
        chatTraceOrchestrator.onToolCallCompleted(chatContext, toolCallInfo);
    }

    @Override
    protected void onChatCompleted(ChatContext chatContext, boolean success, String errorMessage) {
        chatTraceOrchestrator.onChatCompleted(chatContext, success, errorMessage);
    }

    @Override
    protected void onChatError(ChatContext chatContext, ExecutionPhase errorPhase, Throwable throwable) {
        chatTraceOrchestrator.onChatError(chatContext, errorPhase, throwable);
    }

    /** 获取当前线程的追踪上下文
     * 
     * @return 追踪上下文，可能为null */
    protected TraceContext getCurrentTraceContext() {
        return chatTraceOrchestrator.current();
    }

    /** 将ChatContext包装为TracingChatContext
     * 
     * @param chatContext 原始上下文
     * @return 追踪上下文 */
    protected TracingChatContext wrapWithTracingContext(ChatContext chatContext) {
        if (chatContext instanceof TracingChatContext) {
            return (TracingChatContext) chatContext;
        }

        TracingChatContext tracingContext = TracingChatContext.from(chatContext);
        TraceContext traceContext = getCurrentTraceContext();
        if (traceContext != null) {
            tracingContext.setTraceContext(traceContext);
        }
        return tracingContext;
    }

    @Override
    protected Agent buildStreamingAgent(StreamingChatModel model, MessageWindowChatMemory memory,
            ToolProvider toolProvider, AgentEntity agent) {

        // 调用父类方法，获取原始 Agent
        Agent originalAgent = super.buildStreamingAgent(model, memory, toolProvider, agent);

        // 捕获当前线程的 TraceContext
        TraceContext currentTrace = getCurrentTraceContext();

        // 返回包装后的 Agent
        return new TracingAgentWrapper(originalAgent, currentTrace);
    }

    /** 带追踪功能的 Agent 包装器 */
    private class TracingAgentWrapper implements Agent {
        private final Agent originalAgent;
        private final TraceContext capturedTraceContext;

        public TracingAgentWrapper(Agent originalAgent, TraceContext traceContext) {
            this.originalAgent = originalAgent;
            this.capturedTraceContext = traceContext;
        }

        @Override
        public TokenStream chat(String message) {
            // 调用原始 Agent 的 chat 方法
            TokenStream originalTokenStream = originalAgent.chat(message);

            // 返回包装后的 TokenStream
            return new TracingTokenStreamWrapper(originalTokenStream, capturedTraceContext);
        }
    }

    /** 带追踪功能的 TokenStream 包装器 */
    private class TracingTokenStreamWrapper implements TokenStream {
        private final TokenStream originalStream;
        private final TraceContext capturedTraceContext;

        public TracingTokenStreamWrapper(TokenStream originalStream, TraceContext traceContext) {
            this.originalStream = originalStream;
            this.capturedTraceContext = traceContext;
        }

        @Override
        public TokenStream onCompleteResponse(Consumer<ChatResponse> responseHandler) {
            // 包装原始的 responseHandler
            Consumer<ChatResponse> wrappedHandler = response -> {
                // 在回调开始时设置 TraceContext
                if (capturedTraceContext != null) {
                    chatTraceOrchestrator.setCurrent(capturedTraceContext);
                }
                try {
                    // 调用原始处理器
                    responseHandler.accept(response);
                } finally {
                    // 清理 ThreadLocal
                    chatTraceOrchestrator.clear();
                }
            };

            // 调用原始 TokenStream 的方法
            return originalStream.onCompleteResponse(wrappedHandler);
        }

        @Override
        public TokenStream onToolExecuted(Consumer<ToolExecution> toolExecutionHandler) {
            // 类似的包装逻辑
            Consumer<ToolExecution> wrappedHandler = toolExecution -> {
                if (capturedTraceContext != null) {
                    chatTraceOrchestrator.setCurrent(capturedTraceContext);
                }
                try {
                    toolExecutionHandler.accept(toolExecution);
                } finally {
                    chatTraceOrchestrator.clear();
                }
            };

            return originalStream.onToolExecuted(wrappedHandler);
        }

        @Override
        public TokenStream onError(Consumer<Throwable> errorHandler) {
            Consumer<Throwable> wrappedHandler = throwable -> {
                if (capturedTraceContext != null) {
                    chatTraceOrchestrator.setCurrent(capturedTraceContext);
                }
                try {
                    errorHandler.accept(throwable);
                } finally {
                    chatTraceOrchestrator.clear();
                }
            };

            return originalStream.onError(wrappedHandler);
        }

        @Override
        public TokenStream ignoreErrors() {
            return originalStream.ignoreErrors();
        }

        @Override
        public TokenStream onPartialResponse(Consumer<String> partialResponseHandler) {
            Consumer<String> wrappedHandler = partialResponse -> {
                if (capturedTraceContext != null) {
                    chatTraceOrchestrator.setCurrent(capturedTraceContext);
                }
                try {
                    partialResponseHandler.accept(partialResponse);
                } finally {
                    chatTraceOrchestrator.clear();
                }
            };

            return originalStream.onPartialResponse(wrappedHandler);
        }

        @Override
        public TokenStream onRetrieved(Consumer<List<Content>> consumer) {
            Consumer<List<Content>> wrappedHandler = contents -> {
                if (capturedTraceContext != null) {
                    chatTraceOrchestrator.setCurrent(capturedTraceContext);
                }
                try {
                    consumer.accept(contents);
                } finally {
                    chatTraceOrchestrator.clear();
                }
            };
            return originalStream.onRetrieved(wrappedHandler);
        }

        @Override
        public void start() {
            originalStream.start();
        }
    }
}