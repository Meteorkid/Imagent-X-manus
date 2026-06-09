package org.xhy.infrastructure.cache;

import org.springframework.cache.CacheManager;
import org.springframework.cache.annotation.EnableCaching;
import org.springframework.cache.concurrent.ConcurrentMapCacheManager;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * 缓存配置
 * 注意：完整实现需要添加 spring-data-redis 依赖
 * 当前为简化版本，使用本地缓存
 */
@Configuration
@EnableCaching
public class CacheConfig {

    /**
     * 本地缓存管理器
     */
    @Bean
    public CacheManager cacheManager() {
        return new ConcurrentMapCacheManager(
            "plugins",
            "workflows",
            "tools",
            "users",
            "config"
        );
    }
}
