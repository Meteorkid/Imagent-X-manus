package org.xhy.application.conversation.service.message.agent;

import dev.langchain4j.service.tool.ToolProvider;
import dev.langchain4j.service.tool.ToolProviderRequest;
import dev.langchain4j.service.tool.ToolProviderResult;

import java.util.HashSet;
import java.util.List;
import java.util.Set;

/** 将多个 {@link ToolProvider} 的结果合并为一次 {@link ToolProviderResult}（与多 MCP client 并列暴露工具语义一致）。 */
final class AggregatingToolProvider implements ToolProvider {

    private final List<ToolProvider> delegates;

    AggregatingToolProvider(List<ToolProvider> delegates) {
        this.delegates = List.copyOf(delegates);
    }

    @Override
    public ToolProviderResult provideTools(ToolProviderRequest request) {
        ToolProviderResult.Builder builder = ToolProviderResult.builder();
        Set<String> immediate = new HashSet<>();
        for (ToolProvider p : delegates) {
            ToolProviderResult part = p.provideTools(request);
            builder.addAll(part.tools());
            immediate.addAll(part.immediateReturnToolNames());
        }
        return builder.immediateReturnToolNames(immediate).build();
    }
}
