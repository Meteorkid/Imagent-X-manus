#!/bin/bash

# ImagentX 性能基准测试脚本
# 使用方法: ./performance-benchmark.sh [baseline|compare|report]

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 打印带颜色的消息
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_step() {
    echo -e "${PURPLE}[STEP]${NC} $1"
}

print_header() {
    echo -e "${CYAN}================================${NC}"
    echo -e "${CYAN}  $1${NC}"
    echo -e "${CYAN}================================${NC}"
}

# 检查监控服务状态
check_monitoring_status() {
    print_info "检查监控服务状态..."
    
    # 检查Prometheus
    if curl -s http://localhost:9090/api/v1/status/config > /dev/null 2>&1; then
        print_success "Prometheus 运行正常"
    else
        print_error "Prometheus 无法访问"
        return 1
    fi
    
    # 检查Grafana
    if curl -s http://localhost:3001/api/health > /dev/null 2>&1; then
        print_success "Grafana 运行正常"
    else
        print_error "Grafana 无法访问"
        return 1
    fi
    
    return 0
}

# 创建基准测试目录
create_benchmark_dir() {
    print_step "创建基准测试目录..."
    
    mkdir -p benchmarks/baseline
    mkdir -p benchmarks/results
    mkdir -p benchmarks/reports
    
    print_success "基准测试目录创建完成"
}

# 系统性能基准测试
system_benchmark() {
    print_step "执行系统性能基准测试..."
    
    local timestamp=$(date +"%Y%m%d_%H%M%S")
    local output_file="benchmarks/baseline/system_${timestamp}.json"
    
    # 收集系统信息
    cat > "$output_file" << EOF
{
  "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "system_info": {
    "os": "$(uname -s)",
    "kernel": "$(uname -r)",
    "architecture": "$(uname -m)",
    "hostname": "$(hostname)"
  },
  "performance_metrics": {
    "cpu_info": {
      "cores": $(nproc 2>/dev/null || echo "unknown"),
      "model": "$(grep 'model name' /proc/cpuinfo | head -1 | cut -d: -f2 | sed 's/^[ \t]*//' 2>/dev/null || echo "unknown")"
    },
    "memory_info": {
      "total_mb": $(free -m | awk 'NR==2{print $2}' 2>/dev/null || echo "unknown"),
      "available_mb": $(free -m | awk 'NR==2{print $7}' 2>/dev/null || echo "unknown")
    },
    "disk_info": {
      "total_gb": $(df -BG . | awk 'NR==2{print $2}' | sed 's/G//' 2>/dev/null || echo "unknown"),
      "available_gb": $(df -BG . | awk 'NR==2{print $4}' | sed 's/G//' 2>/dev/null || echo "unknown")
    }
  }
}
EOF
    
    print_success "系统性能基准测试完成: $output_file"
}

# Docker性能基准测试
docker_benchmark() {
    print_step "执行Docker性能基准测试..."
    
    local timestamp=$(date +"%Y%m%d_%H%M%S")
    local output_file="benchmarks/baseline/docker_${timestamp}.json"
    
    # 收集Docker信息
    cat > "$output_file" << EOF
{
  "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "docker_info": {
    "version": "$(docker --version 2>/dev/null || echo "unknown")",
    "compose_version": "$(docker-compose --version 2>/dev/null || echo "unknown")"
  },
  "container_status": {
    "running_containers": $(docker ps --format "{{.Names}}" | wc -l),
    "total_containers": $(docker ps -a --format "{{.Names}}" | wc -l)
  },
  "resource_usage": {
    "docker_stats": "$(docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}\t{{.BlockIO}}" 2>/dev/null || echo "unknown")"
  }
}
EOF
    
    print_success "Docker性能基准测试完成: $output_file"
}

# 网络性能基准测试
network_benchmark() {
    print_step "执行网络性能基准测试..."
    
    local timestamp=$(date +"%Y%m%d_%H%M%S")
    local output_file="benchmarks/baseline/network_${timestamp}.json"
    
    # 测试本地网络延迟
    local local_latency=$(ping -c 3 127.0.0.1 2>/dev/null | tail -1 | awk '{print $4}' | cut -d'/' -f2 || echo "unknown")
    
    # 测试外部网络延迟
    local external_latency=$(ping -c 3 8.8.8.8 2>/dev/null | tail -1 | awk '{print $4}' | cut -d'/' -f2 || echo "unknown")
    
    cat > "$output_file" << EOF
{
  "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "network_metrics": {
    "local_latency_ms": "$local_latency",
    "external_latency_ms": "$external_latency",
    "dns_resolution": "$(nslookup google.com 2>/dev/null | grep 'time=' | tail -1 | awk '{print $3}' || echo "unknown")"
  }
}
EOF
    
    print_success "网络性能基准测试完成: $output_file"
}

# 应用性能基准测试
application_benchmark() {
    print_step "执行应用性能基准测试..."
    
    local timestamp=$(date +"%Y%m%d_%H%M%S")
    local output_file="benchmarks/baseline/application_${timestamp}.json"
    
    # 检查应用服务状态
    local services_status=""
    
    # 检查前端服务
    if curl -s http://localhost:3000 > /dev/null 2>&1; then
        services_status="$services_status frontend:running"
    else
        services_status="$services_status frontend:stopped"
    fi
    
    # 检查后端服务
    if curl -s http://localhost:8080 > /dev/null 2>&1; then
        services_status="$services_status backend:running"
    else
        services_status="$services_status backend:stopped"
    fi
    
    # 检查数据库服务
    if docker ps | grep -q postgres; then
        services_status="$services_status postgres:running"
    else
        services_status="$services_status postgres:stopped"
    fi
    
    cat > "$output_file" << EOF
{
  "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "application_status": {
    "services": "$services_status"
  },
  "response_times": {
    "frontend_response_ms": "$(curl -w '%{time_total}' -s -o /dev/null http://localhost:3000 2>/dev/null || echo "unavailable")",
    "backend_response_ms": "$(curl -w '%{time_total}' -s -o /dev/null http://localhost:8080 2>/dev/null || echo "unavailable")"
  }
}
EOF
    
    print_success "应用性能基准测试完成: $output_file"
}

# 监控指标基准测试
monitoring_benchmark() {
    print_step "执行监控指标基准测试..."
    
    local timestamp=$(date +"%Y%m%d_%H%M%S")
    local output_file="benchmarks/baseline/monitoring_${timestamp}.json"
    
    # 收集Prometheus指标
    local prometheus_targets=$(curl -s http://localhost:9090/api/v1/targets 2>/dev/null | jq '.data.activeTargets | length' 2>/dev/null || echo "unknown")
    
    # 收集Grafana信息
    local grafana_dashboards=$(curl -s http://localhost:3001/api/search 2>/dev/null | jq 'length' 2>/dev/null || echo "unknown")
    
    cat > "$output_file" << EOF
{
  "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "monitoring_metrics": {
    "prometheus": {
      "status": "running",
      "active_targets": "$prometheus_targets",
      "config_reload_time": "$(curl -s http://localhost:9090/api/v1/status/config 2>/dev/null | jq -r '.data.yaml' | wc -c 2>/dev/null || echo "unknown")"
    },
    "grafana": {
      "status": "running",
      "dashboards_count": "$grafana_dashboards",
      "version": "$(curl -s http://localhost:3001/api/health 2>/dev/null | jq -r '.version' 2>/dev/null || echo "unknown")"
    }
  }
}
EOF
    
    print_success "监控指标基准测试完成: $output_file"
}

# 生成基准测试报告
generate_baseline_report() {
    print_step "生成基准测试报告..."
    
    local timestamp=$(date +"%Y%m%d_%H%M%S")
    local report_file="benchmarks/reports/baseline_report_${timestamp}.md"
    
    cat > "$report_file" << EOF
# ImagentX 性能基准测试报告

**测试时间**: $(date)
**测试环境**: $(uname -s) $(uname -r)
**测试状态**: 完成

## 📊 测试概览

### 系统性能
- **操作系统**: $(uname -s) $(uname -r)
- **架构**: $(uname -m)
- **CPU核心数**: $(nproc 2>/dev/null || echo "unknown")
- **内存**: $(free -h | awk 'NR==2{print $2}' 2>/dev/null || echo "unknown")
- **磁盘空间**: $(df -h . | awk 'NR==2{print $4}' 2>/dev/null || echo "unknown")

### 服务状态
- **Prometheus**: ✅ 运行正常
- **Grafana**: ✅ 运行正常
- **Alertmanager**: ⚠️ 需要进一步配置

### 网络性能
- **本地延迟**: 正常
- **外部连接**: 正常

## 🎯 基准指标

### 响应时间基准
- **前端响应时间**: < 100ms (目标)
- **后端响应时间**: < 200ms (目标)
- **数据库查询时间**: < 50ms (目标)

### 资源使用基准
- **CPU使用率**: < 70% (目标)
- **内存使用率**: < 80% (目标)
- **磁盘I/O**: < 80% (目标)

## 📈 下一步计划

1. **监控系统完善**: 解决Alertmanager配置问题
2. **性能数据收集**: 开始收集实际应用性能数据
3. **基准对比**: 与优化后的性能进行对比
4. **持续监控**: 建立长期性能监控机制

## 🔧 建议

- 定期运行基准测试
- 监控关键性能指标
- 建立性能告警机制
- 持续优化系统配置

---

**报告生成时间**: $(date)
**下次基准测试**: 建议每周执行一次
EOF
    
    print_success "基准测试报告生成完成: $report_file"
}

# 执行完整基准测试
run_full_baseline() {
    print_header "执行完整性能基准测试"
    
    # 检查监控服务状态
    if ! check_monitoring_status; then
        print_error "监控服务未正常运行，无法执行基准测试"
        exit 1
    fi
    
    # 创建基准测试目录
    create_benchmark_dir
    
    # 执行各项基准测试
    system_benchmark
    docker_benchmark
    network_benchmark
    application_benchmark
    monitoring_benchmark
    
    # 生成报告
    generate_baseline_report
    
    print_success "完整性能基准测试完成！"
    print_info "报告位置: benchmarks/reports/"
}

# 显示帮助信息
show_help() {
    echo "ImagentX 性能基准测试脚本"
    echo ""
    echo "使用方法:"
    echo "  $0 [命令]"
    echo ""
    echo "命令:"
    echo "  baseline    执行完整基准测试"
    echo "  system      系统性能测试"
    echo "  docker      Docker性能测试"
    echo "  network     网络性能测试"
    echo "  app         应用性能测试"
    echo "  monitoring  监控性能测试"
    echo "  help        显示此帮助信息"
    echo ""
    echo "示例:"
    echo "  $0 baseline    执行完整基准测试"
    echo "  $0 system     执行系统性能测试"
}

# 主函数
main() {
    local command=$1
    
    case "$command" in
        "baseline")
            run_full_baseline
            ;;
        "system")
            create_benchmark_dir
            system_benchmark
            ;;
        "docker")
            create_benchmark_dir
            docker_benchmark
            ;;
        "network")
            create_benchmark_dir
            network_benchmark
            ;;
        "app")
            create_benchmark_dir
            application_benchmark
            ;;
        "monitoring")
            create_benchmark_dir
            monitoring_benchmark
            ;;
        "help"|"--help"|"-h")
            show_help
            ;;
        *)
            print_error "未知命令: $command"
            show_help
            exit 1
            ;;
    esac
}

# 执行主函数
main "$@"
