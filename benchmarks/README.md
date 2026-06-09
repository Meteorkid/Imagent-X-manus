# 📊 性能基准测试

## 📋 概述

本目录包含 ImagentX 项目的性能基准测试套件。

## 🎯 测试目标

### 1. API 性能
- 响应时间
- 吞吐量
- 并发处理能力

### 2. 数据库性能
- 查询响应时间
- 连接池性能
- 索引效率

### 3. 前端性能
- 页面加载时间
- 交互响应时间
- 资源加载性能

### 4. 系统性能
- CPU 使用率
- 内存使用率
- 磁盘 I/O

## 🚀 运行测试

### 1. API 性能测试

```bash
# 使用 Apache Bench
ab -n 1000 -c 10 http://localhost:8088/api/health

# 使用 wrk
wrk -t12 -c400 -d30s http://localhost:8088/api/health
```

### 2. 数据库性能测试

```bash
# 使用 pgbench
pgbench -i -s 50 imagentx
pgbench -c 10 -j 2 -T 60 imagentx
```

### 3. 前端性能测试

```bash
# 使用 Lighthouse
lighthouse http://localhost:3000 --output=html

# 使用 WebPageTest
# 访问 https://www.webpagetest.org/
```

### 4. 系统性能测试

```bash
# 使用 sysbench
sysbench cpu --threads=4 --time=30 run
sysbench memory --threads=4 --time=30 run
sysbench fileio --file-total-size=10G --file-test-mode=rndrw --time=60 run
```

## 📈 性能指标

### API 指标
- 平均响应时间 < 100ms
- 95% 响应时间 < 200ms
- 99% 响应时间 < 500ms
- 吞吐量 > 1000 req/s

### 数据库指标
- 查询响应时间 < 10ms
- 连接池使用率 < 80%
- 索引命中率 > 95%

### 前端指标
- FCP (First Contentful Paint) < 1.5s
- LCP (Largest Contentful Paint) < 2.5s
- FID (First Input Delay) < 100ms
- CLS (Cumulative Layout Shift) < 0.1

### 系统指标
- CPU 使用率 < 70%
- 内存使用率 < 80%
- 磁盘 I/O 等待时间 < 10ms

## 📝 测试报告

测试报告将生成在 `reports/` 目录下。

## 🔧 测试工具

- Apache Bench (ab)
- wrk
- pgbench
- Lighthouse
- WebPageTest
- sysbench
- JMeter
