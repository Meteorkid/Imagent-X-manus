package org.xhy.infrastructure.rag.config;

import dev.langchain4j.data.segment.TextSegment;
import dev.langchain4j.store.embedding.EmbeddingStore;
import dev.langchain4j.store.embedding.EmbeddingSearchRequest;
import dev.langchain4j.store.embedding.EmbeddingSearchResult;
import dev.langchain4j.data.embedding.Embedding;
import java.util.Collections;
import java.util.List;
import org.springframework.context.annotation.Primary;
import org.springframework.stereotype.Component;

/**
 * 无操作的EmbeddingStore实现，用于在没有真实向量存储时提供基本功能
 * @author system
 */
@Component
@Primary
public class NoOpEmbeddingStore implements EmbeddingStore<TextSegment> {

    @Override
    public String add(Embedding embedding) {
        return "no-op-id";
    }

    @Override
    public void add(String id, Embedding embedding) {
        // 无操作
    }

    @Override
    public String add(Embedding embedding, TextSegment textSegment) {
        return "no-op-id";
    }

    @Override
    public List<String> addAll(List<Embedding> embeddings) {
        return Collections.emptyList();
    }

    @Override
    public List<String> addAll(List<Embedding> embeddings, List<TextSegment> textSegments) {
        return Collections.emptyList();
    }

    @Override
    public EmbeddingSearchResult<TextSegment> search(EmbeddingSearchRequest embeddingSearchRequest) {
        return new EmbeddingSearchResult<>(Collections.emptyList());
    }
}