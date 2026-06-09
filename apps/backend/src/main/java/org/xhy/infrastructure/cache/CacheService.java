package org.xhy.infrastructure.cache;

import org.springframework.cache.Cache;
import org.springframework.cache.CacheManager;
import org.springframework.stereotype.Service;

import java.util.concurrent.Callable;

/**
 * 缓存服务
 */
@Service
public class CacheService {

    private final CacheManager cacheManager;

    public CacheService(CacheManager cacheManager) {
        this.cacheManager = cacheManager;
    }

    /**
     * 获取缓存值
     */
    public <T> T get(String cacheName, String key, Class<T> type) {
        Cache cache = cacheManager.getCache(cacheName);
        if (cache == null) {
            return null;
        }
        Cache.ValueWrapper wrapper = cache.get(key);
        if (wrapper == null) {
            return null;
        }
        return type.cast(wrapper.get());
    }

    /**
     * 获取缓存值，如果不存在则执行 Callable
     */
    public <T> T get(String cacheName, String key, Class<T> type, Callable<T> valueLoader) {
        Cache cache = cacheManager.getCache(cacheName);
        if (cache == null) {
            try {
                return valueLoader.call();
            } catch (Exception e) {
                throw new RuntimeException("Failed to load value", e);
            }
        }
        Cache.ValueWrapper wrapper = cache.get(key);
        if (wrapper != null) {
            return type.cast(wrapper.get());
        }
        T value = cache.get(key, type);
        if (value == null) {
            try {
                value = valueLoader.call();
                put(cacheName, key, value);
            } catch (Exception e) {
                throw new RuntimeException("Failed to load value", e);
            }
        }
        return value;
    }

    /**
     * 设置缓存值
     */
    public void put(String cacheName, String key, Object value) {
        Cache cache = cacheManager.getCache(cacheName);
        if (cache != null) {
            cache.put(key, value);
        }
    }

    /**
     * 删除缓存值
     */
    public void evict(String cacheName, String key) {
        Cache cache = cacheManager.getCache(cacheName);
        if (cache != null) {
            cache.evict(key);
        }
    }

    /**
     * 清空缓存
     */
    public void clear(String cacheName) {
        Cache cache = cacheManager.getCache(cacheName);
        if (cache != null) {
            cache.clear();
        }
    }

    /**
     * 清空所有缓存
     */
    public void clearAll() {
        cacheManager.getCacheNames().forEach(this::clear);
    }
}
