#!/bin/bash

# ImagentX 本地增强设置脚本
# 用于在本地开发环境中设置监控和缓存功能

set -e

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # 无颜色

echo -e "${BLUE}🚀 设置ImagentX本地增强功能...${NC}"

# 检查服务状态
check_services() {
    echo -e "${BLUE}🔍 检查当前服务状态...${NC}"
    
    # 检查后端服务
    if curl -s http://localhost:8088/api/health >/dev/null 2>&1; then
        echo -e "${GREEN}✅ 后端服务运行正常 (http://localhost:8088)${NC}"
    else
        echo -e "${RED}❌ 后端服务未运行${NC}"
        return 1
    fi
    
    # 检查前端服务
    if curl -s http://localhost:3000 >/dev/null 2>&1; then
        echo -e "${GREEN}✅ 前端服务运行正常 (http://localhost:3000)${NC}"
    else
        echo -e "${RED}❌ 前端服务未运行${NC}"
        return 1
    fi
    
    # 检查数据库
    if brew services list | grep postgresql | grep started >/dev/null 2>&1; then
        echo -e "${GREEN}✅ PostgreSQL数据库运行正常${NC}"
    else
        echo -e "${YELLOW}⚠️  PostgreSQL数据库未运行${NC}"
    fi
    
    # 检查RabbitMQ
    if brew services list | grep rabbitmq | grep started >/dev/null 2>&1; then
        echo -e "${GREEN}✅ RabbitMQ消息队列运行正常${NC}"
    else
        echo -e "${YELLOW}⚠️  RabbitMQ消息队列未运行${NC}"
    fi
}

# 创建本地监控配置
create_local_monitoring() {
    echo -e "${BLUE}📊 创建本地监控配置...${NC}"
    
    mkdir -p local-enhancement/monitoring
    
    # 创建简单的监控脚本
    cat > local-enhancement/monitoring/monitor.sh << 'EOF'
#!/bin/bash

# 简单的本地监控脚本

echo "=== ImagentX 本地监控 ==="
echo "时间: $(date)"
echo ""

# 检查服务状态
echo "🔍 服务状态检查:"
if curl -s http://localhost:8088/api/health >/dev/null 2>&1; then
    echo "✅ 后端服务: 正常"
else
    echo "❌ 后端服务: 异常"
fi

if curl -s http://localhost:3000 >/dev/null 2>&1; then
    echo "✅ 前端服务: 正常"
else
    echo "❌ 前端服务: 异常"
fi

# 检查端口占用
echo ""
echo "🌐 端口占用情况:"
lsof -i :8088 | head -3
lsof -i :3000 | head -3
lsof -i :5432 | head -3
lsof -i :5672 | head -3

# 检查进程状态
echo ""
echo "⚙️  进程状态:"
ps aux | grep -E "(java.*ImagentX|node.*next)" | grep -v grep

# 检查系统资源
echo ""
echo "💻 系统资源:"
top -l 1 | grep -E "(CPU usage|Load Avg|PhysMem)"
EOF

    chmod +x local-enhancement/monitoring/monitor.sh
    
    # 创建日志监控脚本
    cat > local-enhancement/monitoring/log-monitor.sh << 'EOF'
#!/bin/bash

# 日志监控脚本

LOG_DIR="logs"
if [ ! -d "$LOG_DIR" ]; then
    echo "日志目录不存在: $LOG_DIR"
    exit 1
fi

echo "=== ImagentX 日志监控 ==="
echo "时间: $(date)"
echo ""

# 显示最新的错误日志
echo "🚨 最新错误日志:"
find "$LOG_DIR" -name "*.log" -type f -exec grep -l "ERROR\|Exception\|Failed" {} \; | head -5 | while read logfile; do
    echo "文件: $logfile"
    tail -10 "$logfile" | grep -E "(ERROR|Exception|Failed)" | tail -3
    echo ""
done

# 显示最新的访问日志
echo "📝 最新访问日志:"
find "$LOG_DIR" -name "*.log" -type f -exec grep -l "GET\|POST\|PUT\|DELETE" {} \; | head -3 | while read logfile; do
    echo "文件: $logfile"
    tail -5 "$logfile" | grep -E "(GET|POST|PUT|DELETE)" | tail -3
    echo ""
done
EOF

    chmod +x local-enhancement/monitoring/log-monitor.sh
}

# 创建本地缓存配置
create_local_cache() {
    echo -e "${BLUE}💾 创建本地缓存配置...${NC}"
    
    mkdir -p local-enhancement/cache
    
    # 创建Spring Boot缓存配置
    cat > local-enhancement/cache/application-cache-local.yml << 'EOF'
# 本地开发环境缓存配置
spring:
  cache:
    type: simple
    cache-names:
      - user-session
      - config
      - query-result
      - tool-info
      - rag-cache

# 缓存配置
cache:
  # 用户会话缓存
  session:
    ttl: 3600000 # 1小时
    max-size: 1000
  
  # 配置信息缓存
  config:
    ttl: 1800000 # 30分钟
    max-size: 100
  
  # 查询结果缓存
  query:
    ttl: 300000 # 5分钟
    max-size: 500
  
  # 工具信息缓存
  tool:
    ttl: 900000 # 15分钟
    max-size: 200
  
  # RAG知识库缓存
  rag:
    ttl: 600000 # 10分钟
    max-size: 300
EOF

    # 创建缓存测试脚本
    cat > local-enhancement/cache/test-cache.py << 'EOF'
#!/usr/bin/env python3
"""
本地缓存测试脚本
"""

import time
import json
from datetime import datetime

class LocalCache:
    def __init__(self):
        self.cache = {}
        self.timestamps = {}
    
    def set(self, key, value, ttl=300):
        """设置缓存"""
        self.cache[key] = value
        self.timestamps[key] = time.time() + ttl
    
    def get(self, key):
        """获取缓存"""
        if key in self.cache:
            if time.time() < self.timestamps[key]:
                return self.cache[key]
            else:
                # 过期，删除
                del self.cache[key]
                del self.timestamps[key]
        return None
    
    def delete(self, key):
        """删除缓存"""
        if key in self.cache:
            del self.cache[key]
            del self.timestamps[key]
    
    def clear(self):
        """清空缓存"""
        self.cache.clear()
        self.timestamps.clear()
    
    def info(self):
        """缓存信息"""
        valid_keys = [k for k, v in self.timestamps.items() if time.time() < v]
        return {
            'total_keys': len(self.cache),
            'valid_keys': len(valid_keys),
            'expired_keys': len(self.cache) - len(valid_keys)
        }

def test_cache():
    """测试缓存功能"""
    print("🧪 本地缓存测试开始...")
    
    cache = LocalCache()
    
    # 测试基本操作
    print("\n🔧 测试基本操作...")
    cache.set('test:string', 'Hello ImagentX!')
    value = cache.get('test:string')
    print(f"字符串操作: {value}")
    
    # 测试复杂对象
    user_data = {
        'user_id': '12345',
        'username': 'testuser',
        'login_time': datetime.now().isoformat(),
        'permissions': ['read', 'write', 'admin']
    }
    cache.set('user:12345', user_data, ttl=3600)
    cached_user = cache.get('user:12345')
    print(f"用户数据缓存: {cached_user['username'] if cached_user else 'None'}")
    
    # 测试过期时间
    cache.set('test:expire', 'Will expire in 3 seconds', ttl=3)
    print(f"过期测试: {cache.get('test:expire')}")
    print("等待4秒...")
    time.sleep(4)
    print(f"过期后: {cache.get('test:expire')}")
    
    # 测试性能
    print("\n⚡ 测试性能...")
    start_time = time.time()
    for i in range(1000):
        cache.set(f'perf:key:{i}', f'value:{i}')
    write_time = time.time() - start_time
    print(f"批量写入1000条记录耗时: {write_time:.3f}秒")
    
    start_time = time.time()
    for i in range(1000):
        cache.get(f'perf:key:{i}')
    read_time = time.time() - start_time
    print(f"批量读取1000条记录耗时: {read_time:.3f}秒")
    
    # 显示缓存信息
    info = cache.info()
    print(f"\n📊 缓存信息: {info}")
    
    print("\n🎉 本地缓存测试完成！")

if __name__ == "__main__":
    test_cache()
EOF

    chmod +x local-enhancement/cache/test-cache.py
}

# 创建性能测试脚本
create_performance_tests() {
    echo -e "${BLUE}⚡ 创建性能测试脚本...${NC}"
    
    mkdir -p local-enhancement/performance
    
    # 创建API性能测试脚本
    cat > local-enhancement/performance/api-benchmark.py << 'EOF'
#!/usr/bin/env python3
"""
API性能测试脚本
"""

import requests
import time
import statistics
from concurrent.futures import ThreadPoolExecutor
import json

class APIBenchmark:
    def __init__(self, base_url="http://localhost:8088/api"):
        self.base_url = base_url
        self.session = requests.Session()
    
    def test_health_check(self, iterations=100):
        """测试健康检查接口"""
        print(f"🏥 测试健康检查接口 ({iterations}次)...")
        
        times = []
        errors = 0
        
        for i in range(iterations):
            start_time = time.time()
            try:
                response = self.session.get(f"{self.base_url}/health")
                if response.status_code == 200:
                    times.append(time.time() - start_time)
                else:
                    errors += 1
            except Exception as e:
                errors += 1
                print(f"错误: {e}")
        
        self._print_results("健康检查", times, errors, iterations)
    
    def test_agent_list(self, iterations=50):
        """测试Agent列表接口"""
        print(f"🤖 测试Agent列表接口 ({iterations}次)...")
        
        times = []
        errors = 0
        
        for i in range(iterations):
            start_time = time.time()
            try:
                response = self.session.get(f"{self.base_url}/agents/published")
                if response.status_code == 200:
                    times.append(time.time() - start_time)
                else:
                    errors += 1
            except Exception as e:
                errors += 1
                print(f"错误: {e}")
        
        self._print_results("Agent列表", times, errors, iterations)
    
    def test_concurrent_requests(self, endpoint="/health", concurrent=10, total=100):
        """测试并发请求"""
        print(f"🔄 测试并发请求 ({concurrent}并发, {total}总请求)...")
        
        def make_request():
            start_time = time.time()
            try:
                response = self.session.get(f"{self.base_url}{endpoint}")
                return time.time() - start_time, response.status_code == 200
            except:
                return time.time() - start_time, False
        
        times = []
        errors = 0
        
        with ThreadPoolExecutor(max_workers=concurrent) as executor:
            futures = [executor.submit(make_request) for _ in range(total)]
            for future in futures:
                response_time, success = future.result()
                times.append(response_time)
                if not success:
                    errors += 1
        
        self._print_results("并发请求", times, errors, total)
    
    def _print_results(self, test_name, times, errors, total):
        """打印测试结果"""
        if not times:
            print(f"❌ {test_name}: 所有请求都失败了")
            return
        
        success_rate = ((total - errors) / total) * 100
        avg_time = statistics.mean(times)
        min_time = min(times)
        max_time = max(times)
        p95_time = statistics.quantiles(times, n=20)[18] if len(times) >= 20 else max_time
        
        print(f"✅ {test_name} 测试结果:")
        print(f"  成功率: {success_rate:.1f}%")
        print(f"  平均响应时间: {avg_time*1000:.2f}ms")
        print(f"  最小响应时间: {min_time*1000:.2f}ms")
        print(f"  最大响应时间: {max_time*1000:.2f}ms")
        print(f"  95%响应时间: {p95_time*1000:.2f}ms")
        print(f"  错误数: {errors}")
        print()

def main():
    """主函数"""
    print("🚀 ImagentX API性能测试开始...")
    print("=" * 50)
    
    benchmark = APIBenchmark()
    
    # 运行各种测试
    benchmark.test_health_check(100)
    benchmark.test_agent_list(50)
    benchmark.test_concurrent_requests("/health", 10, 100)
    
    print("🎉 API性能测试完成！")

if __name__ == "__main__":
    main()
EOF

    chmod +x local-enhancement/performance/api-benchmark.py
}

# 创建增强管理脚本
create_management_scripts() {
    echo -e "${BLUE}📜 创建管理脚本...${NC}"
    
    # 创建主管理脚本
    cat > local-enhancement/manage.sh << 'EOF'
#!/bin/bash

# ImagentX本地增强管理脚本

case "$1" in
    monitor)
        echo "启动实时监控..."
        watch -n 5 ./monitoring/monitor.sh
        ;;
    logs)
        echo "启动日志监控..."
        watch -n 10 ./monitoring/log-monitor.sh
        ;;
    cache-test)
        echo "运行缓存测试..."
        cd cache && python3 test-cache.py
        ;;
    performance)
        echo "运行性能测试..."
        cd performance && python3 api-benchmark.py
        ;;
    status)
        echo "=== ImagentX 服务状态 ==="
        ./monitoring/monitor.sh
        ;;
    help)
        echo "ImagentX本地增强管理工具"
        echo ""
        echo "用法: $0 {monitor|logs|cache-test|performance|status|help}"
        echo ""
        echo "命令:"
        echo "  monitor     - 启动实时监控"
        echo "  logs        - 启动日志监控"
        echo "  cache-test  - 运行缓存测试"
        echo "  performance - 运行性能测试"
        echo "  status      - 查看服务状态"
        echo "  help        - 显示帮助信息"
        ;;
    *)
        echo "用法: $0 {monitor|logs|cache-test|performance|status|help}"
        exit 1
        ;;
esac
EOF

    chmod +x local-enhancement/manage.sh
}

# 创建README文档
create_documentation() {
    echo -e "${BLUE}📚 创建文档...${NC}"
    
    cat > local-enhancement/README.md << 'EOF'
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
EOF
}

# 主函数
main() {
    echo -e "${BLUE}🔍 检查服务状态...${NC}"
    check_services
    
    echo -e "${BLUE}📁 创建目录结构...${NC}"
    mkdir -p local-enhancement/{monitoring,cache,performance}
    
    echo -e "${BLUE}⚙️  生成配置文件...${NC}"
    create_local_monitoring
    create_local_cache
    create_performance_tests
    create_management_scripts
    create_documentation
    
    echo -e "${GREEN}🎉 本地增强功能设置完成！${NC}"
    echo -e "${BLUE}📊 使用以下命令管理增强功能:${NC}"
    echo -e "  cd local-enhancement"
    echo -e "  ./manage.sh help"
    echo -e ""
    echo -e "${YELLOW}📝 快速测试:${NC}"
    echo -e "  ./manage.sh status    # 检查服务状态"
    echo -e "  ./manage.sh cache-test # 测试缓存功能"
    echo -e "  ./manage.sh performance # 运行性能测试"
}

# 执行主函数
main "$@"
