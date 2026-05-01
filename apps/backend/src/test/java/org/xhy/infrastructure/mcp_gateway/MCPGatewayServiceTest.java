package org.xhy.infrastructure.mcp_gateway;

import static org.assertj.core.api.Assertions.assertThat;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.xhy.infrastructure.config.MCPGatewayProperties;

class MCPGatewayServiceTest {

    @Test
    @DisplayName("应正确构建用户容器与全局 MCP URL")
    void shouldBuildMcpUrls() {
        MCPGatewayProperties properties = new MCPGatewayProperties();
        properties.setApiKey("test-key");
        properties.setBaseUrl("http://gateway.example.com");

        MCPGatewayService service = new MCPGatewayService(properties);

        String userUrl = service.buildUserContainerUrl("weather", "10.0.0.2", 8081);
        String globalUrl = service.buildGlobalSSEUrl("weather");

        assertThat(userUrl).isEqualTo("http://10.0.0.2:8081/weather/sse?api_key=test-key");
        assertThat(globalUrl).isEqualTo("http://gateway.example.com/weather/sse?api_key=test-key");
    }
}
