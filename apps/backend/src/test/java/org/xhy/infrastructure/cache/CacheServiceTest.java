package org.xhy.infrastructure.cache;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.cache.Cache;
import org.springframework.cache.CacheManager;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class CacheServiceTest {

    @Mock
    private CacheManager cacheManager;

    @Mock
    private Cache cache;

    @InjectMocks
    private CacheService cacheService;

    private static final String CACHE_NAME = "test-cache";
    private static final String CACHE_KEY = "test-key";

    @BeforeEach
    void setUp() {
        lenient().when(cacheManager.getCache(CACHE_NAME)).thenReturn(cache);
    }

    @Test
    void get_WhenCacheExists_ShouldReturnValue() {
        // Arrange
        String expectedValue = "test-value";
        Cache.ValueWrapper wrapper = mock(Cache.ValueWrapper.class);
        when(cache.get(CACHE_KEY)).thenReturn(wrapper);
        when(wrapper.get()).thenReturn(expectedValue);

        // Act
        String result = cacheService.get(CACHE_NAME, CACHE_KEY, String.class);

        // Assert
        assertEquals(expectedValue, result);
        verify(cacheManager).getCache(CACHE_NAME);
        verify(cache).get(CACHE_KEY);
    }

    @Test
    void get_WhenCacheNotExists_ShouldReturnNull() {
        // Arrange
        when(cacheManager.getCache(CACHE_NAME)).thenReturn(null);

        // Act
        String result = cacheService.get(CACHE_NAME, CACHE_KEY, String.class);

        // Assert
        assertNull(result);
    }

    @Test
    void get_WhenKeyNotInCache_ShouldReturnNull() {
        // Arrange
        when(cache.get(CACHE_KEY)).thenReturn(null);

        // Act
        String result = cacheService.get(CACHE_NAME, CACHE_KEY, String.class);

        // Assert
        assertNull(result);
    }

    @Test
    void put_ShouldStoreValue() {
        // Arrange
        String value = "test-value";

        // Act
        cacheService.put(CACHE_NAME, CACHE_KEY, value);

        // Assert
        verify(cacheManager).getCache(CACHE_NAME);
        verify(cache).put(CACHE_KEY, value);
    }

    @Test
    void put_WhenCacheNotExists_ShouldNotThrow() {
        // Arrange
        when(cacheManager.getCache(CACHE_NAME)).thenReturn(null);

        // Act & Assert
        assertDoesNotThrow(() -> cacheService.put(CACHE_NAME, CACHE_KEY, "value"));
    }

    @Test
    void evict_ShouldRemoveValue() {
        // Act
        cacheService.evict(CACHE_NAME, CACHE_KEY);

        // Assert
        verify(cacheManager).getCache(CACHE_NAME);
        verify(cache).evict(CACHE_KEY);
    }

    @Test
    void clear_ShouldClearCache() {
        // Act
        cacheService.clear(CACHE_NAME);

        // Assert
        verify(cacheManager).getCache(CACHE_NAME);
        verify(cache).clear();
    }

    @Test
    void clearAll_ShouldClearAllCaches() {
        // Arrange
        when(cacheManager.getCacheNames()).thenReturn(java.util.List.of("cache1", "cache2"));
        when(cacheManager.getCache("cache1")).thenReturn(cache);
        when(cacheManager.getCache("cache2")).thenReturn(cache);

        // Act
        cacheService.clearAll();

        // Assert
        verify(cacheManager).getCacheNames();
        verify(cache, times(2)).clear();
    }
}
