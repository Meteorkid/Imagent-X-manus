package org.xhy.application.conversation.service.message.agent;

import dev.langchain4j.agent.tool.ToolExecutionRequest;
import dev.langchain4j.invocation.InvocationContext;
import dev.langchain4j.service.tool.ToolExecutionResult;
import dev.langchain4j.service.tool.ToolExecutor;
import org.xhy.infrastructure.utils.JsonUtils;

import java.util.LinkedHashMap;
import java.util.Map;

/**
 * 在 MCP 工具执行前合并「预设参数」到模型给出的 arguments JSON：模型已提供的键优先，预设仅补齐缺失键。
 */
final class PresetMergingToolExecutor implements ToolExecutor {

    private final ToolExecutor delegate;
    private final Map<String, Map<String, String>> presetByToolName;

    PresetMergingToolExecutor(ToolExecutor delegate, Map<String, Map<String, String>> presetByToolName) {
        this.delegate = delegate;
        this.presetByToolName = presetByToolName;
    }

    @Override
    public String execute(ToolExecutionRequest request, Object memoryId) {
        return delegate.execute(mergeRequest(request), memoryId);
    }

    @Override
    public ToolExecutionResult executeWithContext(ToolExecutionRequest request, InvocationContext context) {
        return delegate.executeWithContext(mergeRequest(request), context);
    }

    private ToolExecutionRequest mergeRequest(ToolExecutionRequest request) {
        if (presetByToolName == null || presetByToolName.isEmpty()) {
            return request;
        }
        String toolName = request.name();
        Map<String, String> preset = presetByToolName.get(toolName);
        if (preset == null || preset.isEmpty()) {
            return request;
        }
        String merged = mergeJsonArguments(request.arguments(), preset);
        return request.toBuilder().arguments(merged).build();
    }

    static String mergeJsonArguments(String llmArgumentsJson, Map<String, String> preset) {
        Map<String, Object> llm = JsonUtils.parseMap(llmArgumentsJson);
        if (llm == null) {
            llm = new LinkedHashMap<>();
        } else {
            llm = new LinkedHashMap<>(llm);
        }
        for (Map.Entry<String, String> e : preset.entrySet()) {
            llm.putIfAbsent(e.getKey(), e.getValue());
        }
        return JsonUtils.toJsonString(llm);
    }
}
