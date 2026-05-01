package org.xhy.application.conversation.service.message.agent;

import dev.langchain4j.service.tool.ToolProvider;
import org.springframework.stereotype.Component;
import org.xhy.application.conversation.service.handler.context.ChatContext;

/**
 * 默认工具端口适配：复用现有 AgentToolManager 实现。
 */
@Component
public class DefaultAgentToolProviderAdapter implements AgentToolProviderPort {

    private final AgentToolManager agentToolManager;

    public DefaultAgentToolProviderAdapter(AgentToolManager agentToolManager) {
        this.agentToolManager = agentToolManager;
    }

    @Override
    public ToolProvider resolve(ChatContext chatContext) {
        return agentToolManager.createToolProvider(
                agentToolManager.getAvailableTools(chatContext),
                chatContext.getAgent().getToolPresetParams(),
                chatContext.getUserId());
    }
}
