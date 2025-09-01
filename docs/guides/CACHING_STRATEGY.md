# ImagentX 缓存策略指南

## 缓存层级

### 1. 浏览器缓存
- **静态资源**: CSS、JS、图片等
- **缓存策略**: Cache-Control: max-age=31536000
- **版本控制**: 文件名包含哈希值

### 2. CDN缓存
- **静态资源分发**: 全球CDN节点
- **缓存策略**: 边缘节点缓存
- **失效策略**: 基于TTL自动失效

### 3. 应用层缓存
- **Redis缓存**: 会话、API响应、计算结果
- **本地缓存**: Caffeine本地缓存
- **缓存策略**: LRU + TTL

### 4. 数据库缓存
- **查询缓存**: 常用查询结果
- **连接池**: 数据库连接复用
- **索引缓存**: 索引结构缓存

## 缓存键设计

### 用户相关
```
user:profile:{userId}
user:preferences:{userId}
user:sessions:{sessionId}
```

### 智能体相关
```
agent:info:{agentId}
agent:conversations:{agentId}:{userId}
agent:models:{agentId}
```

### 对话相关
```
conversation:{conversationId}
conversation:messages:{conversationId}
conversation:summary:{conversationId}
```

## 缓存失效策略

### 1. TTL策略
- **短期缓存**: 5分钟 - 1小时
- **中期缓存**: 1小时 - 24小时
- **长期缓存**: 24小时以上

### 2. 事件驱动失效
- **用户操作**: 用户修改数据时失效相关缓存
- **系统事件**: 系统配置变更时失效相关缓存
- **定时任务**: 定期清理过期缓存

## 性能指标

### 缓存命中率
- **目标**: > 90%
- **监控**: 实时监控缓存命中率
- **告警**: 命中率低于80%时告警

### 响应时间
- **缓存命中**: < 10ms
- **缓存未命中**: < 100ms
- **数据库查询**: < 50ms
