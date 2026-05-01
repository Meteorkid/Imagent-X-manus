package org.xhy.application.conversation.service.message.agent;

import dev.langchain4j.service.tool.ToolProvider;
import org.xhy.application.conversation.service.handler.context.ChatContext;
import org.xhy.application.conversation.service.message.TracingMessageHandler;
import org.xhy.application.conversation.service.message.tracing.ChatTraceOrchestrator;
import org.xhy.application.conversation.service.message.agent.tool.RagToolManager;
import org.xhy.application.conversation.service.message.pipeline.ModelCompletionStage;
import org.xhy.application.conversation.service.message.pipeline.ModelErrorStage;
import org.xhy.application.conversation.service.message.pipeline.ToolExecutionStage;
import org.springframework.stereotype.Component;
import org.xhy.domain.conversation.service.MessageDomainService;
import org.xhy.domain.conversation.service.SessionDomainService;
import org.xhy.domain.llm.service.HighAvailabilityDomainService;
import org.xhy.domain.llm.service.LLMDomainService;
import org.xhy.domain.user.service.UserSettingsDomainService;
import org.xhy.infrastructure.llm.LLMServiceFactory;
import org.xhy.application.billing.service.BillingService;
import org.xhy.domain.user.service.AccountDomainService;

/** Agent消息处理器 用于支持工具调用的对话模式 实现任务拆分、执行和结果汇总的工作流 使用事件驱动架构进行状态转换 */
@Component(value = "agentMessageHandler")
public class AgentMessageHandler extends TracingMessageHandler {

    private final AgentToolProviderPort agentToolProviderPort;

    public AgentMessageHandler(LLMServiceFactory llmServiceFactory, MessageDomainService messageDomainService,
            HighAvailabilityDomainService highAvailabilityDomainService, SessionDomainService sessionDomainService,
            UserSettingsDomainService userSettingsDomainService, LLMDomainService llmDomainService,
            RagToolManager ragToolManager, ModelCompletionStage modelCompletionStage,
            ModelErrorStage modelErrorStage, ToolExecutionStage toolExecutionStage, BillingService billingService,
            AccountDomainService accountDomainService, ChatTraceOrchestrator chatTraceOrchestrator,
            AgentToolProviderPort agentToolProviderPort) {
        super(llmServiceFactory, messageDomainService, highAvailabilityDomainService, sessionDomainService,
                userSettingsDomainService, llmDomainService, ragToolManager, modelCompletionStage, modelErrorStage,
                toolExecutionStage, billingService, accountDomainService, chatTraceOrchestrator);
        this.agentToolProviderPort = agentToolProviderPort;
    }

    @Override
    protected ToolProvider provideTools(ChatContext chatContext) {
        return agentToolProviderPort.resolve(chatContext);
    }
}