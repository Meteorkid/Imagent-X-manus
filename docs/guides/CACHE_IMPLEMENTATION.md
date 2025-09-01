# ImagentX 缓存实施指南

## 🎯 概述

本指南详细说明如何在ImagentX项目中实施缓存策略，提升系统性能和用户体验。

## 🚀 已部署的缓存服务

### Redis服务状态
- **服务地址**: localhost:6379
- **管理界面**: http://localhost:8081 (Redis Commander)
- **内存限制**: 256MB
- **策略**: LRU (Least Recently Used)
- **持久化**: RDB + AOF

### 服务验证
```bash
# 检查服务状态
./scripts/deploy-redis.sh status

# 测试连接
./scripts/deploy-redis.sh test

# 性能测试
./scripts/deploy-redis.sh perf
```

## 🔧 缓存实施策略

### 1. 会话缓存 (Session Cache)

#### 实现方式
```java
// Spring Boot 配置
@Configuration
@EnableCaching
public class CacheConfig {
    
    @Bean
    public RedisCacheManager cacheManager(RedisConnectionFactory factory) {
        RedisCacheConfiguration config = RedisCacheConfiguration.defaultCacheConfig()
            .entryTtl(Duration.ofMinutes(30))
            .serializeKeysWith(RedisSerializationContext.SerializationPair.fromSerializer(new StringRedisSerializer()))
            .serializeValuesWith(RedisSerializationContext.SerializationPair.fromSerializer(new GenericJackson2JsonRedisSerializer()));
        
        return RedisCacheManager.builder(factory)
            .cacheDefaults(config)
            .build();
    }
}
```

#### 使用示例
```java
@Service
public class UserService {
    
    @Cacheable(value = "users", key = "#userId")
    public User getUserById(Long userId) {
        // 从数据库获取用户信息
        return userRepository.findById(userId);
    }
    
    @CacheEvict(value = "users", key = "#user.id")
    public void updateUser(User user) {
        // 更新用户信息
        userRepository.save(user);
        // 缓存会自动失效
    }
}
```

### 2. API响应缓存 (API Response Cache)

#### 实现方式
```java
@RestController
@RequestMapping("/api/agents")
public class AgentController {
    
    @Cacheable(value = "agent_responses", key = "#request.hashCode()")
    public ResponseEntity<AgentResponse> processAgentRequest(@RequestBody AgentRequest request) {
        // 处理智能体请求
        AgentResponse response = agentService.process(request);
        return ResponseEntity.ok(response);
    }
    
    @CacheEvict(value = "agent_responses", allEntries = true)
    public ResponseEntity<String> clearCache() {
        // 清除所有缓存
        return ResponseEntity.ok("Cache cleared");
    }
}
```

#### 缓存键设计
```
agent_responses:{request_hash}
conversation:{conversation_id}
user_preferences:{user_id}
model_configs:{model_id}
```

### 3. 计算结果缓存 (Computation Cache)

#### 实现方式
```java
@Service
public class AIService {
    
    @Cacheable(value = "ai_responses", key = "#prompt.hashCode()")
    public AIResponse generateResponse(String prompt) {
        // AI模型推理
        return aiModel.infer(prompt);
    }
    
    @Cacheable(value = "embeddings", key = "#text.hashCode()")
    public List<Float> generateEmbedding(String text) {
        // 生成文本嵌入向量
        return embeddingModel.embed(text);
    }
}
```

### 4. 数据库查询缓存 (Database Query Cache)

#### 实现方式
```java
@Repository
public class ConversationRepository {
    
    @Cacheable(value = "conversations", key = "#conversationId")
    public Conversation findById(Long conversationId) {
        return conversationRepository.findById(conversationId);
    }
    
    @Cacheable(value = "conversation_messages", key = "#conversationId")
    public List<Message> findMessagesByConversationId(Long conversationId) {
        return messageRepository.findByConversationId(conversationId);
    }
}
```

## 📊 缓存监控和指标

### 1. Redis监控指标

#### 关键指标
- **内存使用率**: `used_memory / maxmemory`
- **缓存命中率**: `keyspace_hits / (keyspace_hits + keyspace_misses)`
- **连接数**: `connected_clients`
- **命令执行数**: `total_commands_processed`

#### 监控命令
```bash
# 查看Redis信息
docker exec imagentx-redis redis-cli info

# 查看内存使用
docker exec imagentx-redis redis-cli info memory

# 查看统计信息
docker exec imagentx-redis redis-cli info stats

# 实时监控
docker exec imagentx-redis redis-cli monitor
```

### 2. 应用层监控

#### 缓存命中率监控
```java
@Component
public class CacheMetrics {
    
    private final MeterRegistry meterRegistry;
    private final Counter cacheHits;
    private final Counter cacheMisses;
    
    public CacheMetrics(MeterRegistry meterRegistry) {
        this.meterRegistry = meterRegistry;
        this.cacheHits = Counter.builder("cache.hits")
            .description("Cache hit count")
            .register(meterRegistry);
        this.cacheMisses = Counter.builder("cache.misses")
            .description("Cache miss count")
            .register(meterRegistry);
    }
    
    public void recordHit() {
        cacheHits.increment();
    }
    
    public void recordMiss() {
        cacheMisses.increment();
    }
    
    public double getHitRate() {
        double total = cacheHits.count() + cacheMisses.count();
        return total > 0 ? cacheHits.count() / total : 0.0;
    }
}
```

## 🎨 前端缓存策略

### 1. 浏览器缓存

#### HTTP缓存头
```nginx
# Nginx配置
location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
    expires 1y;
    add_header Cache-Control "public, immutable";
}

location ~* \.(html|json)$ {
    expires 1h;
    add_header Cache-Control "public, must-revalidate";
}
```

#### 前端缓存策略
```typescript
// 缓存配置
const cacheConfig = {
  // 静态资源缓存
  static: {
    maxAge: 365 * 24 * 60 * 60 * 1000, // 1年
    immutable: true
  },
  
  // API响应缓存
  api: {
    maxAge: 5 * 60 * 1000, // 5分钟
    staleWhileRevalidate: 60 * 1000 // 1分钟
  }
};

// 缓存实现
class CacheManager {
  private cache = new Map();
  
  async get(key: string): Promise<any> {
    const item = this.cache.get(key);
    if (item && Date.now() < item.expiry) {
      return item.value;
    }
    return null;
  }
  
  set(key: string, value: any, ttl: number): void {
    this.cache.set(key, {
      value,
      expiry: Date.now() + ttl
    });
  }
}
```

### 2. 服务工作者缓存 (Service Worker)

#### 离线缓存策略
```typescript
// service-worker.js
const CACHE_NAME = 'imagentx-v1';
const urlsToCache = [
  '/',
  '/static/js/bundle.js',
  '/static/css/main.css',
  '/api/agents'
];

self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME)
      .then((cache) => cache.addAll(urlsToCache))
  );
});

self.addEventListener('fetch', (event) => {
  event.respondWith(
    caches.match(event.request)
      .then((response) => {
        if (response) {
          return response;
        }
        return fetch(event.request);
      })
  );
});
```

## 🔄 缓存失效策略

### 1. 时间失效 (TTL)

#### 配置示例
```java
@Cacheable(value = "short_term", key = "#id")
@CacheExpiration(expireAfterWrite = 5, timeUnit = TimeUnit.MINUTES)
public Data getShortTermData(String id) {
    return dataService.findById(id);
}

@Cacheable(value = "long_term", key = "#id")
@CacheExpiration(expireAfterWrite = 1, timeUnit = TimeUnit.HOURS)
public Data getLongTermData(String id) {
    return dataService.findById(id);
}
```

### 2. 事件驱动失效

#### 实现示例
```java
@Component
public class CacheEventListener {
    
    @EventListener
    public void handleUserUpdate(UserUpdatedEvent event) {
        // 用户更新时，清除相关缓存
        cacheManager.evict("users", event.getUserId());
        cacheManager.evict("user_preferences", event.getUserId());
    }
    
    @EventListener
    public void handleConversationUpdate(ConversationUpdatedEvent event) {
        // 对话更新时，清除相关缓存
        cacheManager.evict("conversations", event.getConversationId());
        cacheManager.evict("conversation_messages", event.getConversationId());
    }
}
```

### 3. 手动失效

#### 管理接口
```java
@RestController
@RequestMapping("/api/cache")
public class CacheManagementController {
    
    @DeleteMapping("/clear/{cacheName}")
    public ResponseEntity<String> clearCache(@PathVariable String cacheName) {
        cacheManager.evict(cacheName);
        return ResponseEntity.ok("Cache cleared: " + cacheName);
    }
    
    @DeleteMapping("/clear/all")
    public ResponseEntity<String> clearAllCaches() {
        cacheManager.clearAll();
        return ResponseEntity.ok("All caches cleared");
    }
    
    @GetMapping("/stats")
    public ResponseEntity<CacheStats> getCacheStats() {
        return ResponseEntity.ok(cacheManager.getStats());
    }
}
```

## 📈 性能优化建议

### 1. 缓存预热

#### 实现方式
```java
@Component
public class CacheWarmupService {
    
    @PostConstruct
    public void warmupCache() {
        // 系统启动时预热缓存
        List<Long> popularUserIds = userService.getPopularUserIds();
        popularUserIds.forEach(id -> userService.getUserById(id));
        
        List<Long> activeConversationIds = conversationService.getActiveConversationIds();
        activeConversationIds.forEach(id -> conversationService.getConversationById(id));
    }
}
```

### 2. 缓存分层

#### 多层缓存策略
```
L1: 本地缓存 (Caffeine) - 最快，容量小
L2: Redis缓存 - 中等，容量大
L3: 数据库 - 最慢，容量无限
```

#### 实现示例
```java
@Service
public class MultiLevelCacheService {
    
    @Autowired
    private CaffeineCacheManager localCache;
    
    @Autowired
    private RedisCacheManager redisCache;
    
    public Data getData(String key) {
        // L1: 本地缓存
        Data data = localCache.get(key);
        if (data != null) {
            return data;
        }
        
        // L2: Redis缓存
        data = redisCache.get(key);
        if (data != null) {
            localCache.put(key, data);
            return data;
        }
        
        // L3: 数据库
        data = dataService.findById(key);
        if (data != null) {
            redisCache.put(key, data);
            localCache.put(key, data);
        }
        
        return data;
    }
}
```

## 🚨 注意事项

### 1. 内存管理
- 监控Redis内存使用率
- 设置合理的TTL值
- 定期清理过期缓存

### 2. 数据一致性
- 缓存更新策略
- 缓存失效时机
- 数据同步机制

### 3. 安全性
- 缓存数据加密
- 访问权限控制
- 敏感信息过滤

## 🔮 下一步计划

### 短期目标
1. **完善缓存配置**: 优化TTL和内存策略
2. **监控集成**: 将缓存指标集成到Prometheus
3. **性能测试**: 验证缓存效果

### 长期目标
1. **智能缓存**: 基于使用模式的自动优化
2. **分布式缓存**: 多节点Redis集群
3. **缓存分析**: 深度分析缓存使用模式

---

**重要提醒**: 缓存是性能优化的关键，但需要平衡性能提升和系统复杂性。建议逐步实施，持续监控效果。
