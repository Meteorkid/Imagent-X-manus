# ⚡ 性能优化实施指南

## 📋 概述

本指南提供 ImagentX 项目的性能优化实施方案。

## 🎯 优化目标

### 前端优化
- FCP < 1.0s
- LCP < 1.8s
- FID < 50ms
- CLS < 0.05

### 后端优化
- API 响应时间 < 50ms
- 吞吐量 > 2000 req/s
- 错误率 < 0.1%

### 数据库优化
- 查询时间 < 5ms
- 连接池使用率 < 50%
- 索引命中率 > 99%

## 🔧 实施步骤

### 1. 前端优化

#### 1.1 代码分割

```javascript
// next.config.js
module.exports = {
  experimental: {
    optimizePackageImports: ['@mui/material', '@mui/icons-material'],
  },
}

// 组件懒加载
const LazyComponent = dynamic(() => import('./LazyComponent'), {
  loading: () => <Skeleton />,
  ssr: false,
})
```

#### 1.2 图片优化

```javascript
// 使用 Next.js Image 组件
import Image from 'next/image'

<Image
  src="/image.jpg"
  alt="..."
  width={500}
  height={300}
  placeholder="blur"
  blurDataURL="/placeholder.jpg"
/>
```

#### 1.3 CSS 优化

```css
/* 关键 CSS 内联 */
<style dangerouslySetInnerHTML={{ __html: criticalCSS }} />

/* 异步加载非关键 CSS */
<link rel="preload" href="styles.css" as="style" onload="this.onload=null;this.rel='stylesheet'" />
```

### 2. 后端优化

#### 2.1 缓存配置

```java
// Redis 缓存
@Configuration
@EnableCaching
public class CacheConfig {
    @Bean
    public CacheManager cacheManager(RedisConnectionFactory connectionFactory) {
        RedisCacheConfiguration config = RedisCacheConfiguration.defaultCacheConfig()
            .entryTtl(Duration.ofMinutes(30))
            .serializeKeysWith(RedisSerializationContext.SerializationPair.fromSerializer(new StringRedisSerializer()))
            .serializeValuesWith(RedisSerializationContext.SerializationPair.fromSerializer(new GenericJackson2JsonRedisSerializer()));
        
        return RedisCacheManager.builder(connectionFactory)
            .cacheDefaults(config)
            .build();
    }
}
```

#### 2.2 异步处理

```java
// 异步方法
@Async
public CompletableFuture<Result> processAsync(Request request) {
    // 异步处理逻辑
    return CompletableFuture.completedFuture(result);
}

// 线程池配置
@Configuration
public class AsyncConfig {
    @Bean
    public Executor asyncExecutor() {
        ThreadPoolTaskExecutor executor = new ThreadPoolTaskExecutor();
        executor.setCorePoolSize(5);
        executor.setMaxPoolSize(10);
        executor.setQueueCapacity(100);
        executor.setThreadNamePrefix("async-");
        executor.initialize();
        return executor;
    }
}
```

#### 2.3 数据库优化

```java
// 查询优化
@Query("SELECT u FROM User u WHERE u.email = :email")
User findByEmail(@Param("email") String email);

// 分页查询
Page<User> findAll(Pageable pageable);

// 批量操作
@Modifying
@Query("UPDATE User u SET u.status = :status WHERE u.id IN :ids")
int updateStatusByIds(@Param("ids") List<String> ids, @Param("status") String status);
```

### 3. 数据库优化

#### 3.1 索引优化

```sql
-- 添加索引
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_status ON users(status);
CREATE INDEX idx_users_created_at ON users(created_at);

-- 复合索引
CREATE INDEX idx_users_email_status ON users(email, status);

-- 部分索引
CREATE INDEX idx_users_active ON users(email) WHERE status = 'active';
```

#### 3.2 查询优化

```sql
-- 使用 EXPLAIN 分析
EXPLAIN ANALYZE SELECT * FROM users WHERE email = 'test@example.com';

-- 优化子查询
-- 原查询
SELECT * FROM users WHERE id IN (SELECT user_id FROM orders WHERE total > 100);

-- 优化后
SELECT u.* FROM users u
JOIN orders o ON u.id = o.user_id
WHERE o.total > 100;
```

#### 3.3 连接池优化

```yaml
# HikariCP 配置
spring:
  datasource:
    hikari:
      maximum-pool-size: 20
      minimum-idle: 5
      connection-timeout: 30000
      idle-timeout: 600000
      max-lifetime: 1800000
      leak-detection-threshold: 60000
```

## 📊 监控和验证

### 1. 性能监控

```java
// 性能监控
@Component
public class PerformanceMonitor {
    private final MeterRegistry meterRegistry;
    
    public void recordApiCall(String endpoint, long duration) {
        Timer.builder("api.calls")
            .tag("endpoint", endpoint)
            .register(meterRegistry)
            .record(duration, TimeUnit.MILLISECONDS);
    }
}
```

### 2. 性能测试

```bash
# API 性能测试
ab -n 1000 -c 10 http://localhost:8088/api/health

# 数据库性能测试
pgbench -c 10 -j 2 -T 60 imagentx

# 前端性能测试
lighthouse http://localhost:3000
```

## 🎯 预期效果

### 优化前
- FCP: 1.5s
- LCP: 2.5s
- API 响应时间: 100ms
- 查询时间: 10ms

### 优化后
- FCP: 1.0s (↓33%)
- LCP: 1.8s (↓28%)
- API 响应时间: 50ms (↓50%)
- 查询时间: 5ms (↓50%)

## 📝 下一步

1. 实施优化方案
2. 监控优化效果
3. 持续优化和改进
