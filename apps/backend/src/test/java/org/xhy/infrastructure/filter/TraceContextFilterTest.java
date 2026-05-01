package org.xhy.infrastructure.filter;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.header;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.http.ResponseEntity;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

class TraceContextFilterTest {

    @RestController
    static class TestController {
        @GetMapping("/ping")
        ResponseEntity<String> ping() {
            return ResponseEntity.ok("pong");
        }
    }

    @Test
    @DisplayName("无 request-id 时过滤器应生成并回写头")
    void shouldGenerateRequestIdHeader() throws Exception {
        MockMvc mockMvc = MockMvcBuilders.standaloneSetup(new TestController()).addFilters(new TraceContextFilter())
                .build();

        mockMvc.perform(get("/ping")).andExpect(status().isOk()).andExpect(header().exists("X-Request-Id"));
    }

    @Test
    @DisplayName("有 request-id 时过滤器应透传")
    void shouldKeepProvidedRequestIdHeader() throws Exception {
        MockMvc mockMvc = MockMvcBuilders.standaloneSetup(new TestController()).addFilters(new TraceContextFilter())
                .build();

        mockMvc.perform(get("/ping").header("X-Request-Id", "req-123")).andExpect(status().isOk())
                .andExpect(header().string("X-Request-Id", "req-123"));
    }

    @Test
    @DisplayName("有 idempotency-key 时过滤器应透传")
    void shouldKeepProvidedIdempotencyKeyHeader() throws Exception {
        MockMvc mockMvc = MockMvcBuilders.standaloneSetup(new TestController()).addFilters(new TraceContextFilter())
                .build();

        mockMvc.perform(get("/ping").header("X-Idempotency-Key", "idem-123")).andExpect(status().isOk())
                .andExpect(header().string("X-Idempotency-Key", "idem-123"));
    }
}
