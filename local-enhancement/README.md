# ImagentX 本地增强功能

## 概述

本目录包含ImagentX项目的本地增强功能，包括监控、缓存、性能测试等。

## 目录结构

```
local-enhancement/
├── monitoring/          # 监控相关
│   ├── monitor.sh      # 服务状态监控
│   └── log-monitor.sh  # 日志监控
├── cache/              # 缓存相关
│   ├── application-cache-local.yml  # 缓存配置
│   └── test-cache.py   # 缓存测试
├── performance/        # 性能测试
│   └── api-benchmark.py # API性能测试
├── manage.sh           # 管理脚本
└── README.md           # 本文档
```

## 快速开始

### 1. 检查服务状态
```bash
./manage.sh status
```

### 2. 启动实时监控
```bash
./manage.sh monitor
```

### 3. 监控日志
```bash
./manage.sh logs
```

### 4. 测试缓存功能
```bash
./manage.sh cache-test
```

### 5. 运行性能测试
```bash
./manage.sh performance
```

## 功能说明

### 监控功能
- **服务状态监控**: 检查后端、前端、数据库、消息队列状态
- **端口占用检查**: 显示各服务端口占用情况
- **进程状态**: 显示相关进程运行状态
- **系统资源**: 显示CPU、内存使用情况

### 缓存功能
- **本地缓存**: 使用内存缓存替代Redis
- **缓存测试**: 测试缓存读写性能
- **过期机制**: 支持TTL过期时间
- **统计信息**: 显示缓存命中率等信息

### 性能测试
- **API基准测试**: 测试各API接口响应时间
- **并发测试**: 测试并发请求处理能力
- **统计分析**: 提供详细的性能统计信息

## 配置说明

### 缓存配置
编辑 `cache/application-cache-local.yml` 文件来调整缓存设置：

```yaml
cache:
  session:
    ttl: 3600000  # 1小时
    max-size: 1000
  query:
    ttl: 300000   # 5分钟
    max-size: 500
```

### 监控配置
- 监控间隔: 5秒 (monitor.sh)
- 日志监控间隔: 10秒 (log-monitor.sh)

## 故障排除

### 常见问题

1. **服务未启动**
   - 检查后端服务: `curl http://localhost:8088/api/health`
   - 检查前端服务: `curl http://localhost:3000`

2. **权限问题**
   - 确保脚本有执行权限: `chmod +x *.sh`

3. **依赖问题**
   - 确保Python 3已安装
   - 安装requests库: `pip3 install requests`

## 扩展功能

### 添加新的监控项
在 `monitoring/monitor.sh` 中添加新的检查项。

### 添加新的性能测试
在 `performance/api-benchmark.py` 中添加新的测试方法。

### 集成到Spring Boot
将 `cache/application-cache-local.yml` 配置集成到Spring Boot应用中。
