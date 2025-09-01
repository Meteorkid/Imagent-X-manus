# ImagentX 数据库性能优化计划

## 📊 项目现状分析

### 当前数据库架构
- **数据库类型**: PostgreSQL 15 + pgvector扩展
- **连接池**: HikariCP (最大20连接，最小5连接)
- **监控系统**: Prometheus + Grafana + ELK Stack
- **主要表**: users, agents, sessions, messages, tools, accounts等

### 性能瓶颈识别
1. **索引不完整**: 部分查询字段缺少索引
2. **连接池配置**: 当前配置可能不适合高并发场景
3. **监控覆盖**: 数据库性能监控不够完善
4. **查询优化**: 存在潜在的慢查询问题

---

## 🎯 优化目标

### 短期目标 (本周剩余时间)
- ✅ **性能验证**: 在实际查询中验证索引效果
- ✅ **监控完善**: 完善数据库性能监控
- ✅ **参数调优**: 根据实际负载调整数据库参数

### 中期目标 (下周)
- 🔄 **查询优化**: 优化慢查询和复杂查询
- 🔄 **连接池优化**: 优化数据库连接池配置
- 🔄 **备份策略**: 实施数据库备份和恢复策略

### 长期目标 (本月)
- 📈 **读写分离**: 考虑实施读写分离
- 📈 **分库分表**: 评估分库分表需求
- 📈 **性能基准**: 建立长期性能基准

---

## 🚀 短期目标实施方案

### 1. 性能验证 - 索引效果验证

#### 1.1 创建索引验证脚本
```sql
-- 性能验证脚本
-- 验证现有索引效果

-- 1. 检查现有索引
SELECT 
    schemaname,
    tablename,
    indexname,
    indexdef
FROM pg_indexes 
WHERE schemaname = 'public'
ORDER BY tablename, indexname;

-- 2. 分析查询性能
EXPLAIN (ANALYZE, BUFFERS) 
SELECT * FROM users WHERE email = 'test@example.com';

-- 3. 检查索引使用情况
SELECT 
    schemaname,
    tablename,
    indexname,
    idx_scan,
    idx_tup_read,
    idx_tup_fetch
FROM pg_stat_user_indexes 
ORDER BY idx_scan DESC;
```

#### 1.2 创建性能测试工具
```java
// 性能测试工具类
@Component
public class DatabasePerformanceTester {
    
    @Autowired
    private JdbcTemplate jdbcTemplate;
    
    public PerformanceResult testQueryPerformance(String query, int iterations) {
        long startTime = System.currentTimeMillis();
        List<Map<String, Object>> results = new ArrayList<>();
        
        for (int i = 0; i < iterations; i++) {
            long queryStart = System.currentTimeMillis();
            List<Map<String, Object>> result = jdbcTemplate.queryForList(query);
            long queryEnd = System.currentTimeMillis();
            results.add(Map.of("iteration", i, "duration", queryEnd - queryStart));
        }
        
        long endTime = System.currentTimeMillis();
        return new PerformanceResult(startTime, endTime, results);
    }
}
```

### 2. 监控完善 - 数据库性能监控

#### 2.1 创建数据库监控配置
```yaml
# 数据库监控配置
spring:
  datasource:
    hikari:
      # 连接池监控
      register-mbeans: true
      pool-name: ImagentXHikariCP
      
  # 数据库性能监控
  jpa:
    properties:
      hibernate:
        # 启用统计信息
        generate_statistics: true
        # 慢查询日志
        session_factory:
          observer_class: org.hibernate.stat.Statistics
```

#### 2.2 创建监控指标收集器
```java
@Component
public class DatabaseMetricsCollector {
    
    @Autowired
    private MeterRegistry meterRegistry;
    
    @Autowired
    private DataSource dataSource;
    
    @Scheduled(fixedRate = 30000) // 每30秒收集一次
    public void collectDatabaseMetrics() {
        if (dataSource instanceof HikariDataSource) {
            HikariDataSource hikariDS = (HikariDataSource) dataSource;
            HikariPoolMXBean poolMXBean = hikariDS.getHikariPoolMXBean();
            
            // 连接池指标
            Gauge.builder("database.connections.active", poolMXBean, HikariPoolMXBean::getActiveConnections)
                .register(meterRegistry);
            Gauge.builder("database.connections.idle", poolMXBean, HikariPoolMXBean::getIdleConnections)
                .register(meterRegistry);
            Gauge.builder("database.connections.total", poolMXBean, HikariPoolMXBean::getTotalConnections)
                .register(meterRegistry);
        }
    }
}
```

#### 2.3 创建Grafana仪表板
```json
{
  "dashboard": {
    "title": "ImagentX Database Performance",
    "panels": [
      {
        "title": "Database Connections",
        "type": "graph",
        "targets": [
          {
            "expr": "database_connections_active",
            "legendFormat": "Active Connections"
          },
          {
            "expr": "database_connections_idle",
            "legendFormat": "Idle Connections"
          }
        ]
      },
      {
        "title": "Query Response Time",
        "type": "graph",
        "targets": [
          {
            "expr": "rate(database_query_duration_seconds_sum[5m])",
            "legendFormat": "Query Duration"
          }
        ]
      }
    ]
  }
}
```

### 3. 参数调优 - 数据库参数优化

#### 3.1 PostgreSQL参数优化
```sql
-- PostgreSQL性能参数优化
-- 内存配置
SET shared_buffers = '256MB';  -- 系统内存的25%
SET effective_cache_size = '1GB';  -- 系统内存的75%
SET work_mem = '4MB';  -- 排序和哈希操作内存
SET maintenance_work_mem = '64MB';  -- 维护操作内存

-- 连接配置
SET max_connections = 100;  -- 最大连接数
SET superuser_reserved_connections = 3;  -- 保留连接

-- 查询优化
SET random_page_cost = 1.1;  -- SSD存储
SET effective_io_concurrency = 200;  -- 并发I/O
SET checkpoint_completion_target = 0.9;  -- 检查点完成目标

-- 日志配置
SET log_min_duration_statement = 1000;  -- 慢查询日志阈值(毫秒)
SET log_checkpoints = on;  -- 记录检查点
SET log_connections = on;  -- 记录连接
SET log_disconnections = on;  -- 记录断开连接
```

#### 3.2 连接池参数优化
```yaml
spring:
  datasource:
    hikari:
      # 连接池优化配置
      maximum-pool-size: 30  # 根据CPU核心数调整
      minimum-idle: 10
      connection-timeout: 20000  # 20秒
      idle-timeout: 300000  # 5分钟
      max-lifetime: 1200000  # 20分钟
      leak-detection-threshold: 60000  # 1分钟
      connection-test-query: SELECT 1
      validation-timeout: 5000  # 5秒
```

---

## 🔄 中期目标实施方案

### 1. 查询优化 - 慢查询优化

#### 1.1 慢查询分析工具
```java
@Component
public class SlowQueryAnalyzer {
    
    @Autowired
    private JdbcTemplate jdbcTemplate;
    
    public List<SlowQueryInfo> analyzeSlowQueries() {
        String sql = """
            SELECT 
                query,
                calls,
                total_time,
                mean_time,
                rows
            FROM pg_stat_statements 
            WHERE mean_time > 100  -- 超过100ms的查询
            ORDER BY mean_time DESC
            LIMIT 20
            """;
        
        return jdbcTemplate.query(sql, (rs, rowNum) -> 
            new SlowQueryInfo(
                rs.getString("query"),
                rs.getLong("calls"),
                rs.getDouble("total_time"),
                rs.getDouble("mean_time"),
                rs.getLong("rows")
            )
        );
    }
}
```

#### 1.2 查询优化建议生成器
```java
@Component
public class QueryOptimizer {
    
    public List<OptimizationSuggestion> generateSuggestions(String query) {
        List<OptimizationSuggestion> suggestions = new ArrayList<>();
        
        // 分析查询计划
        String explainQuery = "EXPLAIN (ANALYZE, BUFFERS, FORMAT JSON) " + query;
        // 解析执行计划并生成建议
        
        return suggestions;
    }
}
```

### 2. 连接池优化 - 高级配置

#### 2.1 动态连接池调整
```java
@Component
public class DynamicConnectionPoolManager {
    
    @Autowired
    private DataSource dataSource;
    
    @EventListener
    public void handleLoadChange(LoadChangeEvent event) {
        if (dataSource instanceof HikariDataSource) {
            HikariDataSource hikariDS = (HikariDataSource) dataSource;
            
            // 根据负载动态调整连接池大小
            int currentLoad = event.getCurrentLoad();
            int optimalPoolSize = calculateOptimalPoolSize(currentLoad);
            
            hikariDS.setMaximumPoolSize(optimalPoolSize);
        }
    }
    
    private int calculateOptimalPoolSize(int load) {
        // 根据负载计算最优连接池大小
        return Math.max(10, Math.min(50, load * 2));
    }
}
```

### 3. 备份策略 - 自动化备份

#### 3.1 备份脚本
```bash
#!/bin/bash
# 数据库备份脚本

BACKUP_DIR="/backup/postgresql"
DATE=$(date +%Y%m%d_%H%M%S)
DB_NAME="imagentx"
DB_USER="imagentx_user"

# 创建备份目录
mkdir -p $BACKUP_DIR

# 执行备份
pg_dump -h localhost -U $DB_USER -d $DB_NAME \
    --format=custom \
    --compress=9 \
    --file=$BACKUP_DIR/imagentx_$DATE.backup

# 清理旧备份（保留7天）
find $BACKUP_DIR -name "*.backup" -mtime +7 -delete

# 验证备份
pg_restore --list $BACKUP_DIR/imagentx_$DATE.backup > /dev/null
if [ $? -eq 0 ]; then
    echo "备份成功: imagentx_$DATE.backup"
else
    echo "备份失败"
    exit 1
fi
```

#### 3.2 备份监控
```java
@Component
public class BackupMonitor {
    
    @Scheduled(cron = "0 2 * * *") // 每天凌晨2点执行
    public void performBackup() {
        try {
            // 执行备份
            ProcessBuilder pb = new ProcessBuilder("./backup.sh");
            Process process = pb.start();
            
            // 监控备份过程
            boolean success = process.waitFor(30, TimeUnit.MINUTES);
            
            if (success && process.exitValue() == 0) {
                log.info("数据库备份成功");
            } else {
                log.error("数据库备份失败");
                // 发送告警
                sendBackupFailureAlert();
            }
        } catch (Exception e) {
            log.error("备份过程异常", e);
        }
    }
}
```

---

## 📈 长期目标实施方案

### 1. 读写分离 - 主从架构

#### 1.1 读写分离配置
```yaml
spring:
  datasource:
    # 主数据源（写操作）
    master:
      jdbc-url: jdbc:postgresql://master:5432/imagentx
      username: imagentx_user
      password: imagentx_pass
      hikari:
        maximum-pool-size: 20
        minimum-idle: 5
    
    # 从数据源（读操作）
    slave:
      jdbc-url: jdbc:postgresql://slave:5432/imagentx
      username: imagentx_user
      password: imagentx_pass
      hikari:
        maximum-pool-size: 30
        minimum-idle: 10
```

#### 1.2 数据源路由
```java
@Component
public class DataSourceRouter extends AbstractRoutingDataSource {
    
    @Override
    protected Object determineCurrentLookupKey() {
        return TransactionSynchronizationManager.isCurrentTransactionReadOnly() 
            ? "slave" : "master";
    }
}
```

### 2. 分库分表 - 水平分片

#### 2.1 分片策略
```java
@Component
public class ShardingStrategy {
    
    public String determineShard(String userId) {
        // 基于用户ID的哈希分片
        int hash = userId.hashCode();
        int shardIndex = Math.abs(hash) % 4; // 4个分片
        return "shard_" + shardIndex;
    }
    
    public List<String> getAllShards() {
        return Arrays.asList("shard_0", "shard_1", "shard_2", "shard_3");
    }
}
```

#### 2.2 分片数据源管理
```java
@Component
public class ShardingDataSourceManager {
    
    private Map<String, DataSource> shardDataSources = new ConcurrentHashMap<>();
    
    public DataSource getDataSource(String shardName) {
        return shardDataSources.computeIfAbsent(shardName, this::createDataSource);
    }
    
    private DataSource createDataSource(String shardName) {
        // 创建分片数据源
        HikariConfig config = new HikariConfig();
        config.setJdbcUrl("jdbc:postgresql://" + shardName + ":5432/imagentx");
        config.setUsername("imagentx_user");
        config.setPassword("imagentx_pass");
        return new HikariDataSource(config);
    }
}
```

### 3. 性能基准 - 长期监控

#### 3.1 性能基准测试
```java
@Component
public class PerformanceBenchmark {
    
    @Autowired
    private JdbcTemplate jdbcTemplate;
    
    public BenchmarkResult runBenchmark() {
        BenchmarkResult result = new BenchmarkResult();
        
        // 测试查询性能
        result.setQueryPerformance(testQueryPerformance());
        
        // 测试并发性能
        result.setConcurrencyPerformance(testConcurrencyPerformance());
        
        // 测试写入性能
        result.setWritePerformance(testWritePerformance());
        
        return result;
    }
    
    private QueryPerformance testQueryPerformance() {
        long startTime = System.currentTimeMillis();
        
        // 执行标准查询集
        List<String> testQueries = Arrays.asList(
            "SELECT * FROM users WHERE email = ?",
            "SELECT * FROM agents WHERE created_by = ?",
            "SELECT * FROM sessions WHERE user_id = ?"
        );
        
        // 执行查询并记录时间
        // ...
        
        long endTime = System.currentTimeMillis();
        return new QueryPerformance(endTime - startTime);
    }
}
```

#### 3.2 性能报告生成
```java
@Component
public class PerformanceReportGenerator {
    
    @Autowired
    private PerformanceBenchmark benchmark;
    
    @Scheduled(cron = "0 0 2 * * 1") // 每周一凌晨2点
    public void generateWeeklyReport() {
        BenchmarkResult result = benchmark.runBenchmark();
        
        // 生成报告
        String report = generateReport(result);
        
        // 保存报告
        saveReport(report);
        
        // 发送报告
        sendReport(report);
    }
    
    private String generateReport(BenchmarkResult result) {
        StringBuilder report = new StringBuilder();
        report.append("# ImagentX 性能周报\n\n");
        report.append("## 查询性能\n");
        report.append("- 平均响应时间: ").append(result.getQueryPerformance().getAverageResponseTime()).append("ms\n");
        report.append("- 95%响应时间: ").append(result.getQueryPerformance().getP95ResponseTime()).append("ms\n");
        // ... 更多指标
        
        return report.toString();
    }
}
```

---

## 📊 监控和告警

### 1. 关键指标监控
```yaml
# 关键性能指标
metrics:
  database:
    # 连接池指标
    - active_connections
    - idle_connections
    - total_connections
    
    # 查询性能指标
    - query_duration_p95
    - query_duration_p99
    - slow_query_count
    
    # 系统资源指标
    - cpu_usage
    - memory_usage
    - disk_io
    
    # 业务指标
    - transactions_per_second
    - error_rate
    - cache_hit_rate
```

### 2. 告警规则
```yaml
alerts:
  - name: "High Database Response Time"
    condition: "query_duration_p95 > 1000ms"
    severity: "warning"
    
  - name: "Database Connection Pool Exhausted"
    condition: "active_connections / total_connections > 0.9"
    severity: "critical"
    
  - name: "High Error Rate"
    condition: "error_rate > 0.05"
    severity: "critical"
    
  - name: "Slow Query Detected"
    condition: "slow_query_count > 10 per 5m"
    severity: "warning"
```

---

## 🛠️ 实施工具和脚本

### 1. 自动化部署脚本
```bash
#!/bin/bash
# 数据库优化部署脚本

echo "🚀 开始部署数据库性能优化..."

# 1. 备份当前配置
echo "📦 备份当前配置..."
cp application.yml application.yml.backup

# 2. 应用优化配置
echo "⚙️  应用优化配置..."
cp performance-config/database-pool.yml application.yml

# 3. 创建索引
echo "🔍 创建性能索引..."
psql -h localhost -U imagentx_user -d imagentx -f performance-config/database/optimize-indexes.sql

# 4. 重启服务
echo "🔄 重启服务..."
docker-compose restart imagentx-backend

# 5. 验证优化效果
echo "✅ 验证优化效果..."
./scripts/verify-optimization.sh

echo "🎉 数据库性能优化部署完成！"
```

### 2. 性能验证脚本
```bash
#!/bin/bash
# 性能验证脚本

echo "🔍 验证数据库性能优化效果..."

# 1. 检查索引
echo "检查索引状态..."
psql -h localhost -U imagentx_user -d imagentx -c "
SELECT 
    schemaname,
    tablename,
    indexname,
    idx_scan,
    idx_tup_read
FROM pg_stat_user_indexes 
ORDER BY idx_scan DESC;
"

# 2. 检查连接池
echo "检查连接池状态..."
curl -s http://localhost:8088/actuator/health | jq '.components.db'

# 3. 执行性能测试
echo "执行性能测试..."
./scripts/performance-test.sh

echo "✅ 性能验证完成！"
```

---

## 📈 预期效果

### 短期效果 (1周内)
- ✅ 查询响应时间减少 30-50%
- ✅ 连接池利用率提升 20%
- ✅ 慢查询数量减少 60%

### 中期效果 (1个月内)
- 🔄 系统并发处理能力提升 100%
- 🔄 数据库错误率降低 80%
- 🔄 备份恢复时间缩短 50%

### 长期效果 (3个月内)
- 📈 支持 10倍用户增长
- 📈 系统可用性达到 99.9%
- 📈 运维成本降低 40%

---

## 🔧 维护和持续优化

### 1. 定期维护任务
```yaml
maintenance:
  daily:
    - "数据库备份"
    - "慢查询分析"
    - "性能指标收集"
  
  weekly:
    - "索引使用情况分析"
    - "连接池配置优化"
    - "性能报告生成"
  
  monthly:
    - "数据库参数调优"
    - "分片策略评估"
    - "容量规划"
```

### 2. 持续监控
- 📊 实时性能监控
- 🔔 自动化告警
- 📈 趋势分析
- 🎯 性能基准对比

---

## 📞 技术支持

如有问题，请联系：
- **性能优化团队**: performance@imagentx.ai
- **数据库团队**: database@imagentx.ai
- **运维团队**: ops@imagentx.ai

---

*最后更新时间: 2024年12月*
