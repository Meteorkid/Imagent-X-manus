package org.xhy.application.conversation.service.message.agent;

import dev.langchain4j.service.tool.ToolProvider;
import org.xhy.application.conversation.service.handler.context.ChatContext;

/**
 * 工具提供能力端口：编排层只依赖该端口，不直接依赖具体 MCP 实现。
 */
public interface AgentToolProviderPort {

    ToolProvider resolve(ChatContext chatContext);
}
