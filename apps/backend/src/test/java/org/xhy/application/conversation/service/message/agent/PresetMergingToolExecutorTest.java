package org.xhy.application.conversation.service.message.agent;

import org.junit.jupiter.api.Test;

import java.util.Map;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;

class PresetMergingToolExecutorTest {

    @Test
    void merge_fillsMissingKeys_modelWinsOnConflict() {
        String llm = "{\"a\":\"from_model\",\"b\":\"2\"}";
        Map<String, String> preset = Map.of("b", "preset_b", "c", "preset_c");
        String merged = PresetMergingToolExecutor.mergeJsonArguments(llm, preset);
        assertTrue(merged.contains("\"a\":\"from_model\""));
        assertTrue(merged.contains("\"b\":\"2\""));
        assertTrue(merged.contains("\"c\":\"preset_c\""));
    }

    @Test
    void merge_handlesNullOrEmptyLlmJson() {
        Map<String, String> preset = Map.of("x", "y");
        String merged = PresetMergingToolExecutor.mergeJsonArguments(null, preset);
        assertEquals("{\"x\":\"y\"}", merged);
    }
}
