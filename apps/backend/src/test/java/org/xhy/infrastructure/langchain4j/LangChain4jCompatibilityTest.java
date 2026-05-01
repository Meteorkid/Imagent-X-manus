package org.xhy.infrastructure.langchain4j;

import static org.assertj.core.api.Assertions.assertThat;

import dev.langchain4j.data.document.parser.apache.poi.ApachePoiDocumentParser;
import dev.langchain4j.mcp.client.transport.http.HttpMcpTransport;
import dev.langchain4j.model.chat.ChatModel;
import dev.langchain4j.model.chat.StreamingChatModel;
import java.time.Duration;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.xhy.infrastructure.llm.config.ProviderConfig;
import org.xhy.infrastructure.llm.factory.LLMProviderFactory;
import org.xhy.infrastructure.llm.protocol.enums.ProviderProtocol;

class LangChain4jCompatibilityTest {

    @Test
    @DisplayName("LLM provider factory should create OpenAI models")
    void shouldCreateOpenAiModels() {
        ProviderConfig config =
                new ProviderConfig("dummy-key", "https://api.openai.com/v1", "gpt-4o-mini", ProviderProtocol.OPENAI);

        ChatModel chatModel = LLMProviderFactory.getLLMProvider(ProviderProtocol.OPENAI, config);
        StreamingChatModel streaming = LLMProviderFactory.getLLMProviderByStream(ProviderProtocol.OPENAI, config);

        assertThat(chatModel).isNotNull();
        assertThat(streaming).isNotNull();
    }

    @Test
    @DisplayName("RAG pgvector store and document parser should be instantiable")
    void shouldInstantiateRagComponents() throws Exception {
        Class<?> pgVectorBuilderClass =
                Class.forName("dev.langchain4j.store.embedding.pgvector.PgVectorEmbeddingStore$PgVectorEmbeddingStoreBuilder");
        ApachePoiDocumentParser parser = new ApachePoiDocumentParser();

        assertThat(pgVectorBuilderClass).isNotNull();
        assertThat(parser).isNotNull();
    }

    @Test
    @DisplayName("MCP client transport should be buildable")
    void shouldBuildMcpClient() throws Exception {
        HttpMcpTransport transport = new HttpMcpTransport.Builder().sseUrl("http://127.0.0.1:65535/sse")
                .timeout(Duration.ofSeconds(1)).build();
        Class<?> builderClass = Class.forName("dev.langchain4j.mcp.client.DefaultMcpClient$Builder");

        assertThat(transport).isNotNull();
        assertThat(builderClass).isNotNull();
    }
}
