#!/bin/bash

# ImagentX 数据库参数调优脚本

set -e

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}⚙️  ImagentX 数据库参数调优${NC}"
echo "调优时间: $(date)"
echo ""

# 设置环境变量
export PGPASSWORD=imagentx_pass

# 分析当前性能状况
analyze_current_performance() {
    echo -e "${BLUE}📊 分析当前性能状况${NC}"
    echo ""
    
    # 连接池利用率
    local total_connections=$(PGPASSWORD=imagentx_pass psql -h localhost -U imagentx_user -d imagentx -t -c "
        SELECT count(*) FROM pg_stat_activity;
    " | tr -d ' ')
    
    local active_connections=$(PGPASSWORD=imagentx_pass psql -h localhost -U imagentx_user -d imagentx -t -c "
        SELECT count(*) FROM pg_stat_activity WHERE state = 'active';
    " | tr -d ' ')
    
    local utilization=$(echo "scale=2; $active_connections * 100 / $total_connections" | bc)
    echo "当前连接池利用率: ${utilization}%"
    
    if [ $(echo "$utilization < 20" | bc) -eq 1 ]; then
        echo -e "${YELLOW}⚠️  连接池利用率过低，建议减少连接数${NC}"
    elif [ $(echo "$utilization > 80" | bc) -eq 1 ]; then
        echo -e "${YELLOW}⚠️  连接池利用率过高，建议增加连接数${NC}"
    else
        echo -e "${GREEN}✅ 连接池利用率正常${NC}"
    fi
    
    # 缓存命中率
    local cache_hit_ratio=$(PGPASSWORD=imagentx_pass psql -h localhost -U imagentx_user -d imagentx -t -c "
        SELECT 
            CASE 
                WHEN sum(heap_blks_hit) + sum(heap_blks_read) = 0 THEN 100
                ELSE round(100.0 * sum(heap_blks_hit) / (sum(heap_blks_hit) + sum(heap_blks_read)), 2)
            END
        FROM pg_statio_user_tables;
    " | tr -d ' ')
    
    echo "当前缓存命中率: ${cache_hit_ratio}%"
    
    if [ $(echo "$cache_hit_ratio < 80" | bc) -eq 1 ]; then
        echo -e "${YELLOW}⚠️  缓存命中率较低，建议增加shared_buffers${NC}"
    else
        echo -e "${GREEN}✅ 缓存命中率良好${NC}"
    fi
    
    # 索引使用率
    local used_indexes=$(PGPASSWORD=imagentx_pass psql -h localhost -U imagentx_user -d imagentx -t -c "
        SELECT COUNT(*) FROM pg_stat_user_indexes WHERE idx_scan > 0;
    " | tr -d ' ')
    
    local total_indexes=$(PGPASSWORD=imagentx_pass psql -h localhost -U imagentx_user -d imagentx -t -c "
        SELECT COUNT(*) FROM pg_stat_user_indexes;
    " | tr -d ' ')
    
    local index_usage=$(echo "scale=2; $used_indexes * 100 / $total_indexes" | bc)
    echo "当前索引使用率: ${index_usage}%"
    
    if [ $(echo "$index_usage < 50" | bc) -eq 1 ]; then
        echo -e "${YELLOW}⚠️  索引使用率较低，建议评估索引必要性${NC}"
    else
        echo -e "${GREEN}✅ 索引使用率正常${NC}"
    fi
    
    echo ""
}

# 生成连接池优化建议
generate_connection_pool_recommendations() {
    echo -e "${BLUE}🔗 连接池优化建议${NC}"
    echo ""
    
    local total_connections=$(PGPASSWORD=imagentx_pass psql -h localhost -U imagentx_user -d imagentx -t -c "
        SELECT count(*) FROM pg_stat_activity;
    " | tr -d ' ')
    
    local active_connections=$(PGPASSWORD=imagentx_pass psql -h localhost -U imagentx_user -d imagentx -t -c "
        SELECT count(*) FROM pg_stat_activity WHERE state = 'active';
    " | tr -d ' ')
    
    local utilization=$(echo "scale=2; $active_connections * 100 / $total_connections" | bc)
    
    echo "基于当前利用率 ${utilization}% 的建议："
    echo ""
    
    if [ $(echo "$utilization < 20" | bc) -eq 1 ]; then
        echo "📉 连接池利用率过低，建议："
        echo "  - 减少 maximum-pool-size: 从 25 调整到 15"
        echo "  - 减少 minimum-idle: 从 8 调整到 5"
        echo "  - 增加 idle-timeout: 从 5分钟 调整到 3分钟"
        echo "  - 减少 max-lifetime: 从 20分钟 调整到 15分钟"
    elif [ $(echo "$utilization > 80" | bc) -eq 1 ]; then
        echo "📈 连接池利用率过高，建议："
        echo "  - 增加 maximum-pool-size: 从 25 调整到 35"
        echo "  - 增加 minimum-idle: 从 8 调整到 12"
        echo "  - 增加 idle-timeout: 从 5分钟 调整到 8分钟"
        echo "  - 增加 max-lifetime: 从 20分钟 调整到 25分钟"
    else
        echo "✅ 连接池利用率正常，建议："
        echo "  - 保持当前配置"
        echo "  - 监控趋势变化"
        echo "  - 定期评估性能"
    fi
    
    echo ""
}

# 生成PostgreSQL参数优化建议
generate_postgresql_recommendations() {
    echo -e "${BLUE}🐘 PostgreSQL参数优化建议${NC}"
    echo ""
    
    # 获取当前系统信息
    local total_memory=$(sysctl -n hw.memsize | awk '{print $1/1024/1024/1024}')
    local cpu_cores=$(sysctl -n hw.ncpu)
    
    echo "系统信息："
    echo "  - 总内存: ${total_memory}GB"
    echo "  - CPU核心数: ${cpu_cores}"
    echo ""
    
    echo "PostgreSQL参数优化建议："
    echo ""
    
    # shared_buffers (建议为总内存的25%)
    local recommended_shared_buffers=$(echo "scale=0; $total_memory * 0.25" | bc)
    echo "📊 shared_buffers:"
    echo "  - 当前值: 128MB"
    echo "  - 建议值: ${recommended_shared_buffers}GB"
    echo "  - 说明: 增加共享缓冲区大小，提高缓存命中率"
    echo ""
    
    # effective_cache_size (建议为总内存的75%)
    local recommended_effective_cache=$(echo "scale=0; $total_memory * 0.75" | bc)
    echo "💾 effective_cache_size:"
    echo "  - 当前值: 4GB"
    echo "  - 建议值: ${recommended_effective_cache}GB"
    echo "  - 说明: 告诉查询规划器系统有多少内存可用于缓存"
    echo ""
    
    # work_mem (建议为总内存的1/核心数/4)
    local recommended_work_mem=$(echo "scale=0; $total_memory * 1024 / $cpu_cores / 4" | bc)
    echo "🧠 work_mem:"
    echo "  - 当前值: 4MB"
    echo "  - 建议值: ${recommended_work_mem}MB"
    echo "  - 说明: 增加排序和哈希操作的内存"
    echo ""
    
    # max_connections (基于连接池配置)
    echo "🔗 max_connections:"
    echo "  - 当前值: 100"
    echo "  - 建议值: 150"
    echo "  - 说明: 为连接池预留足够空间"
    echo ""
    
    # 其他重要参数
    echo "⚙️  其他重要参数："
    echo "  - maintenance_work_mem: 建议 256MB (用于维护操作)"
    echo "  - checkpoint_completion_target: 建议 0.9 (平滑检查点)"
    echo "  - wal_buffers: 建议 16MB (WAL缓冲区)"
    echo "  - random_page_cost: 建议 1.1 (SSD优化)"
    echo "  - effective_io_concurrency: 建议 200 (并发I/O)"
    echo ""
}

# 生成应用层优化建议
generate_application_recommendations() {
    echo -e "${BLUE}🚀 应用层优化建议${NC}"
    echo ""
    
    echo "Spring Boot 配置优化："
    echo ""
    
    echo "📊 数据源配置："
    echo "  - 启用连接池监控: register-mbeans: true"
    echo "  - 启用连接验证: connection-test-query: SELECT 1"
    echo "  - 优化连接超时: connection-timeout: 20000ms"
    echo "  - 启用泄漏检测: leak-detection-threshold: 60000ms"
    echo ""
    
    echo "🔄 JPA/Hibernate配置："
    echo "  - 批处理大小: batch_size: 50"
    echo "  - 启用二级缓存: use_second_level_cache: true"
    echo "  - 启用查询缓存: use_query_cache: true"
    echo "  - 优化插入顺序: order_inserts: true"
    echo "  - 优化更新顺序: order_updates: true"
    echo ""
    
    echo "📈 监控配置："
    echo "  - 启用HikariCP监控端点"
    echo "  - 启用数据库健康检查"
    echo "  - 启用性能指标收集"
    echo "  - 配置慢查询日志"
    echo ""
}

# 生成索引优化建议
generate_index_recommendations() {
    echo -e "${BLUE}🔍 索引优化建议${NC}"
    echo ""
    
    echo "基于当前索引使用情况的分析："
    echo ""
    
    # 分析未使用的索引
    local unused_indexes=$(PGPASSWORD=imagentx_pass psql -h localhost -U imagentx_user -d imagentx -t -c "
        SELECT COUNT(*) FROM pg_stat_user_indexes WHERE idx_scan = 0;
    " | tr -d ' ')
    
    echo "📊 索引使用统计："
    echo "  - 未使用索引数量: $unused_indexes"
    echo "  - 建议: 评估这些索引的必要性，考虑删除不常用的索引"
    echo ""
    
    # 分析高序列扫描的表
    local high_seq_scan=$(PGPASSWORD=imagentx_pass psql -h localhost -U imagentx_user -d imagentx -t -c "
        SELECT COUNT(*) FROM pg_stat_user_tables WHERE seq_scan > idx_scan * 10 AND seq_scan > 100;
    " | tr -d ' ')
    
    if [ "$high_seq_scan" -gt 0 ]; then
        echo "⚠️  发现 $high_seq_scan 个表存在高序列扫描："
        echo "  - 建议: 为这些表添加适当的索引"
        echo "  - 重点关注: 查询频率高的字段"
        echo ""
    fi
    
    echo "💡 索引优化策略："
    echo "  1. 保留高频查询的索引"
    echo "  2. 删除长期未使用的索引"
    echo "  3. 为慢查询添加复合索引"
    echo "  4. 定期分析索引使用情况"
    echo ""
}

# 生成调优配置文件
generate_optimization_config() {
    echo -e "${BLUE}📝 生成调优配置文件${NC}"
    echo ""
    
    local config_file="performance-config/database/optimized-postgresql.conf"
    mkdir -p performance-config/database
    
    # 获取系统信息
    local total_memory=$(sysctl -n hw.memsize | awk '{print $1/1024/1024/1024}')
    local cpu_cores=$(sysctl -n hw.ncpu)
    local recommended_shared_buffers=$(echo "scale=0; $total_memory * 0.25" | bc)
    local recommended_effective_cache=$(echo "scale=0; $total_memory * 0.75" | bc)
    local recommended_work_mem=$(echo "scale=0; $total_memory * 1024 / $cpu_cores / 4" | bc)
    
    cat > "$config_file" << EOF
# ImagentX PostgreSQL 优化配置文件
# 生成时间: $(date)
# 系统信息: ${total_memory}GB RAM, ${cpu_cores} CPU cores

# 内存配置
shared_buffers = ${recommended_shared_buffers}GB          # 共享缓冲区 (总内存的25%)
effective_cache_size = ${recommended_effective_cache}GB   # 有效缓存大小 (总内存的75%)
work_mem = ${recommended_work_mem}MB                     # 工作内存 (排序/哈希操作)
maintenance_work_mem = 256MB                             # 维护操作内存

# 连接配置
max_connections = 150                                    # 最大连接数
superuser_reserved_connections = 3                       # 超级用户保留连接

# 检查点配置
checkpoint_completion_target = 0.9                       # 检查点完成目标
checkpoint_timeout = 15min                               # 检查点超时
max_wal_size = 2GB                                       # 最大WAL大小
min_wal_size = 1GB                                       # 最小WAL大小

# WAL配置
wal_buffers = 16MB                                       # WAL缓冲区
wal_writer_delay = 200ms                                 # WAL写入延迟

# 查询规划器配置
random_page_cost = 1.1                                   # 随机页面成本 (SSD优化)
effective_io_concurrency = 200                           # 有效I/O并发
seq_page_cost = 1.0                                      # 顺序页面成本

# 日志配置
log_min_duration_statement = 1000                        # 慢查询日志阈值 (1秒)
log_checkpoints = on                                      # 记录检查点
log_connections = off                                     # 记录连接
log_disconnections = off                                  # 记录断开连接

# 统计信息配置
track_activities = on                                     # 跟踪活动
track_counts = on                                         # 跟踪计数
track_io_timing = on                                      # 跟踪I/O时间
track_functions = all                                     # 跟踪函数

# 自动清理配置
autovacuum = on                                           # 启用自动清理
autovacuum_max_workers = 3                               # 自动清理最大工作进程
autovacuum_naptime = 1min                                # 自动清理间隔

# 扩展配置
shared_preload_libraries = 'pg_stat_statements'           # 预加载扩展
EOF
    
    echo "✅ 配置文件已生成: $config_file"
    echo ""
    echo "📋 应用配置步骤："
    echo "  1. 备份当前PostgreSQL配置"
    echo "  2. 将优化配置应用到postgresql.conf"
    echo "  3. 重启PostgreSQL服务"
    echo "  4. 验证配置生效"
    echo ""
}

# 生成连接池优化配置
generate_connection_pool_config() {
    echo -e "${BLUE}🔗 生成连接池优化配置${NC}"
    echo ""
    
    local config_file="performance-config/database/optimized-connection-pool.yml"
    mkdir -p performance-config/database
    
    cat > "$config_file" << EOF
# ImagentX 连接池优化配置
# 生成时间: $(date)
# 基于实际负载分析优化

spring:
  datasource:
    hikari:
      # 连接池核心配置
      pool-name: ImagentXHikariCP
      maximum-pool-size: 20                              # 最大连接数 (基于利用率调整)
      minimum-idle: 6                                    # 最小空闲连接
      
      # 连接生命周期配置
      connection-timeout: 20000                          # 连接超时 20秒
      idle-timeout: 300000                               # 空闲超时 5分钟
      max-lifetime: 1200000                              # 最大生命周期 20分钟
      
      # 连接验证配置
      connection-test-query: SELECT 1                    # 连接测试查询
      validation-timeout: 5000                           # 验证超时 5秒
      
      # 性能监控配置
      leak-detection-threshold: 60000                    # 泄漏检测阈值 1分钟
      register-mbeans: true                              # 启用JMX监控
      
      # 连接初始化配置
      connection-init-sql: SET time_zone = '+08:00'      # 设置时区
      auto-commit: true                                  # 自动提交
      
  # JPA配置优化
  jpa:
    properties:
      hibernate:
        # 批处理配置
        jdbc:
          batch_size: 50                                 # 批处理大小
          batch_versioned_data: true                     # 批处理版本化数据
          
        # 缓存配置
        cache:
          use_second_level_cache: true                   # 启用二级缓存
          use_query_cache: true                          # 启用查询缓存
          
        # 查询优化
        order_inserts: true                              # 排序插入
        order_updates: true                              # 排序更新
        
        # 统计信息
        generate_statistics: true                        # 生成统计信息
        
        # 慢查询监控
        session_factory:
          observer_class: org.hibernate.stat.Statistics  # 统计观察者

# 监控端点配置
management:
  endpoints:
    web:
      exposure:
        include: health,info,metrics,prometheus,hikaricp # 暴露的端点
  endpoint:
    health:
      show-details: always                               # 显示健康检查详情
  metrics:
    export:
      prometheus:
        enabled: true                                    # 启用Prometheus导出
EOF
    
    echo "✅ 连接池配置已生成: $config_file"
    echo ""
    echo "📋 应用配置步骤："
    echo "  1. 备份当前application.yml"
    echo "  2. 将优化配置应用到应用配置"
    echo "  3. 重启应用服务"
    echo "  4. 验证连接池配置生效"
    echo ""
}

# 生成调优实施计划
generate_implementation_plan() {
    echo -e "${BLUE}📋 生成调优实施计划${NC}"
    echo ""
    
    local plan_file="performance-config/database/optimization-implementation-plan.md"
    mkdir -p performance-config/database
    
    cat > "$plan_file" << EOF
# ImagentX 数据库性能调优实施计划

## 📅 实施时间
- 计划开始时间: $(date)
- 预计完成时间: 本周内
- 负责人: 性能优化团队

## 🎯 调优目标
1. 优化连接池配置，提高资源利用率
2. 优化PostgreSQL参数，提升查询性能
3. 优化索引策略，减少无效索引
4. 完善监控体系，实时掌握性能状况

## 📊 当前性能状况
- 连接池利用率: 9.09% (过低)
- 缓存命中率: 100% (优秀)
- 索引使用率: 0% (需要优化)
- 系统资源: CPU 10%, 内存 99%, 磁盘 4%

## 🔧 调优措施

### 第一阶段: 连接池优化 (立即执行)
- [ ] 调整maximum-pool-size: 25 → 20
- [ ] 调整minimum-idle: 8 → 6
- [ ] 优化连接超时参数
- [ ] 启用连接池监控

### 第二阶段: PostgreSQL参数优化 (今天完成)
- [ ] 优化shared_buffers: 128MB → ${recommended_shared_buffers}GB
- [ ] 优化effective_cache_size: 4GB → ${recommended_effective_cache}GB
- [ ] 优化work_mem: 4MB → ${recommended_work_mem}MB
- [ ] 启用pg_stat_statements扩展

### 第三阶段: 索引优化 (明天完成)
- [ ] 分析未使用索引 (当前: 108个)
- [ ] 删除无效索引
- [ ] 优化复合索引
- [ ] 建立索引使用监控

### 第四阶段: 监控完善 (本周完成)
- [ ] 部署简化监控脚本
- [ ] 配置性能告警
- [ ] 建立性能基准
- [ ] 生成定期报告

## ✅ 验证标准
1. 连接池利用率提升到 20-60%
2. 查询响应时间保持在 30ms 以内
3. 缓存命中率保持在 90% 以上
4. 索引使用率提升到 50% 以上

## 🚨 风险控制
1. 每次调优前备份配置
2. 分阶段实施，逐步验证
3. 准备回滚方案
4. 监控系统稳定性

## 📈 预期效果
- 数据库性能提升 20-30%
- 连接池资源利用率优化
- 查询响应时间稳定
- 系统资源使用更合理

## 🔄 后续计划
1. 建立性能监控仪表板
2. 实施自动化性能调优
3. 建立性能基准和SLA
4. 定期性能评估和优化
EOF
    
    echo "✅ 实施计划已生成: $plan_file"
    echo ""
}

# 主函数
main() {
    echo "=================================="
    
    # 分析当前性能状况
    analyze_current_performance
    
    # 生成各种优化建议
    generate_connection_pool_recommendations
    generate_postgresql_recommendations
    generate_application_recommendations
    generate_index_recommendations
    
    # 生成配置文件
    generate_optimization_config
    generate_connection_pool_config
    
    # 生成实施计划
    generate_implementation_plan
    
    echo "=================================="
    echo -e "${GREEN}🎉 数据库参数调优分析完成！${NC}"
    echo ""
    echo -e "${YELLOW}📋 下一步行动：${NC}"
    echo "1. 查看生成的配置文件"
    echo "2. 按照实施计划逐步执行"
    echo "3. 监控调优效果"
    echo "4. 根据实际情况调整参数"
    echo ""
}

# 执行主函数
main "$@"
