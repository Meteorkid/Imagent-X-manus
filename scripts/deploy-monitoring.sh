#!/bin/bash

# ImagentX 监控系统部署脚本
# 使用方法: ./deploy-monitoring.sh [start|stop|status|restart]

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
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

# 检查Docker和Docker Compose
check_requirements() {
    print_info "检查系统要求..."
    
    if ! command -v docker &> /dev/null; then
        print_error "Docker未安装，请先安装Docker"
        exit 1
    fi
    
    if ! command -v docker-compose &> /dev/null; then
        print_error "Docker Compose未安装，请先安装Docker Compose"
        exit 1
    fi
    
    print_success "系统要求检查完成"
}

# 创建监控配置
create_monitoring_config() {
    print_step "创建监控配置..."
    
    # 创建监控目录
    mkdir -p config/monitoring/grafana/provisioning/dashboards
    mkdir -p config/monitoring/grafana/provisioning/datasources
    
    # 创建Grafana数据源配置
    cat > config/monitoring/grafana/provisioning/datasources/prometheus.yml << 'EOF'
apiVersion: 1

datasources:
  - name: Prometheus
    type: prometheus
    access: proxy
    url: http://prometheus:9090
    isDefault: true
    editable: true
EOF
    
    # 创建Grafana仪表板配置
    cat > config/monitoring/grafana/provisioning/dashboards/dashboards.yml << 'EOF'
apiVersion: 1

providers:
  - name: 'default'
    orgId: 1
    folder: ''
    type: file
    disableDeletion: false
    updateIntervalSeconds: 10
    allowUiUpdates: true
    options:
      path: /etc/grafana/provisioning/dashboards
EOF
    
    # 创建ImagentX概览仪表板
    cat > config/monitoring/grafana/provisioning/dashboards/imagentx-overview.json << 'EOF'
{
  "dashboard": {
    "id": null,
    "title": "ImagentX 系统概览",
    "tags": ["imagentx", "overview"],
    "style": "dark",
    "timezone": "browser",
    "panels": [
      {
        "id": 1,
        "title": "系统性能概览",
        "type": "stat",
        "gridPos": {"h": 8, "w": 12, "x": 0, "y": 0},
        "targets": [
          {
            "expr": "rate(http_requests_total[5m])",
            "legendFormat": "请求速率"
          }
        ],
        "fieldConfig": {
          "defaults": {
            "color": {"mode": "palette-classic"},
            "custom": {"displayMode": "gradient"},
            "mappings": [],
            "thresholds": {
              "steps": [
                {"color": "green", "value": null},
                {"color": "red", "value": 80}
              ]
            }
          }
        }
      },
      {
        "id": 2,
        "title": "响应时间分布",
        "type": "histogram",
        "gridPos": {"h": 8, "w": 12, "x": 12, "y": 0},
        "targets": [
          {
            "expr": "rate(http_request_duration_seconds_bucket[5m])",
            "legendFormat": "{{le}}"
          }
        ]
      },
      {
        "id": 3,
        "title": "错误率",
        "type": "stat",
        "gridPos": {"h": 8, "w": 12, "x": 0, "y": 8},
        "targets": [
          {
            "expr": "rate(http_requests_total{status=~\"5..\"}[5m]) / rate(http_requests_total[5m]) * 100",
            "legendFormat": "错误率 %"
          }
        ],
        "fieldConfig": {
          "defaults": {
            "color": {"mode": "palette-classic"},
            "custom": {"displayMode": "gradient"},
            "thresholds": {
              "steps": [
                {"color": "green", "value": null},
                {"color": "yellow", "value": 1},
                {"color": "red", "value": 5}
              ]
            }
          }
        }
      },
      {
        "id": 4,
        "title": "内存使用率",
        "type": "stat",
        "gridPos": {"h": 8, "w": 12, "x": 12, "y": 8},
        "targets": [
          {
            "expr": "(container_memory_usage_bytes / container_spec_memory_limit_bytes) * 100",
            "legendFormat": "内存使用率 %"
          }
        ],
        "fieldConfig": {
          "defaults": {
            "color": {"mode": "palette-classic"},
            "custom": {"displayMode": "gradient"},
            "thresholds": {
              "steps": [
                {"color": "green", "value": null},
                {"color": "yellow", "value": 70},
                {"color": "red", "value": 90}
              ]
            }
          }
        }
      }
    ],
    "time": {
      "from": "now-1h",
      "to": "now"
    },
    "refresh": "30s"
  }
}
EOF
    
    print_success "监控配置创建完成"
}

# 创建监控docker-compose配置
create_monitoring_compose() {
    print_step "创建监控Docker Compose配置..."
    
    cat > config/monitoring/docker-compose.monitoring.yml << 'EOF'
version: '3.8'

services:
  prometheus:
    image: prom/prometheus:latest
    container_name: imagentx-prometheus
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
      - prometheus_data:/prometheus
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
      - '--web.console.libraries=/etc/prometheus/console_libraries'
      - '--web.console.templates=/etc/prometheus/consoles'
      - '--storage.tsdb.retention.time=200h'
      - '--web.enable-lifecycle'
    restart: unless-stopped
    networks:
      - monitoring

  grafana:
    image: grafana/grafana:latest
    container_name: imagentx-grafana
    ports:
      - "3001:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin123
      - GF_USERS_ALLOW_SIGN_UP=false
    volumes:
      - grafana_data:/var/lib/grafana
      - ./grafana/provisioning:/etc/grafana/provisioning
    restart: unless-stopped
    networks:
      - monitoring
    depends_on:
      - prometheus

  alertmanager:
    image: prom/alertmanager:latest
    container_name: imagentx-alertmanager
    ports:
      - "9093:9093"
    volumes:
      - ./alertmanager.yml:/etc/alertmanager/alertmanager.yml
      - alertmanager_data:/alertmanager
    command:
      - '--config.file=/etc/alertmanager/alertmanager.yml'
      - '--storage.path=/alertmanager'
      - '--web.console.libraries=/etc/alertmanager/console_libraries'
      - '--web.console.templates=/etc/alertmanager/consoles'
      - '--web.enable-lifecycle'
    restart: unless-stopped
    networks:
      - monitoring

volumes:
  prometheus_data:
    driver: local
  grafana_data:
    driver: local
  alertmanager_data:
    driver: local

networks:
  monitoring:
    driver: bridge
    ipam:
      config:
        - subnet: 172.21.0.0/16
EOF
    
    # 创建Alertmanager配置
    cat > config/monitoring/alertmanager.yml << 'EOF'
global:
  resolve_timeout: 5m

route:
  group_by: ['alertname']
  group_wait: 10s
  group_interval: 10s
  repeat_interval: 1h
  receiver: 'web.hook'

receivers:
  - name: 'web.hook'
    webhook_configs:
      - url: 'http://127.0.0.1:5001/'

inhibit_rules:
  - source_match:
      severity: 'critical'
    target_match:
      severity: 'warning'
    equal: ['alertname', 'dev', 'instance']
EOF
    
    print_success "监控Docker Compose配置创建完成"
}

# 启动监控服务
start_monitoring() {
    print_step "启动监控服务..."
    
    cd config/monitoring
    
    # 启动监控服务
    docker-compose -f docker-compose.monitoring.yml up -d
    
    cd ../..
    
    print_success "监控服务启动完成"
    print_info "访问地址："
    print_info "  - Prometheus: http://localhost:9090"
    print_info "  - Grafana: http://localhost:3001 (admin/admin123)"
    print_info "  - Alertmanager: http://localhost:9093"
}

# 停止监控服务
stop_monitoring() {
    print_step "停止监控服务..."
    
    cd config/monitoring
    
    # 停止监控服务
    docker-compose -f docker-compose.monitoring.yml down
    
    cd ../..
    
    print_success "监控服务已停止"
}

# 查看监控服务状态
status_monitoring() {
    print_step "查看监控服务状态..."
    
    cd config/monitoring
    
    # 查看服务状态
    docker-compose -f docker-compose.monitoring.yml ps
    
    cd ../..
    
    print_info "监控服务状态查询完成"
}

# 重启监控服务
restart_monitoring() {
    print_step "重启监控服务..."
    
    stop_monitoring
    sleep 2
    start_monitoring
    
    print_success "监控服务重启完成"
}

# 显示帮助信息
show_help() {
    echo "ImagentX 监控系统部署脚本"
    echo ""
    echo "使用方法:"
    echo "  $0 [命令]"
    echo ""
    echo "命令:"
    echo "  start     启动监控服务"
    echo "  stop      停止监控服务"
    echo "  status    查看服务状态"
    echo "  restart   重启监控服务"
    echo "  help      显示此帮助信息"
    echo ""
    echo "示例:"
    echo "  $0 start     启动监控服务"
    echo "  $0 status    查看服务状态"
}

# 主函数
main() {
    local command=$1
    
    case "$command" in
        "start")
            check_requirements
            create_monitoring_config
            create_monitoring_compose
            start_monitoring
            ;;
        "stop")
            stop_monitoring
            ;;
        "status")
            status_monitoring
            ;;
        "restart")
            restart_monitoring
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
