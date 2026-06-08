#!/bin/bash

# ImagentX 监控系统设置脚本
# 用于快速部署Prometheus + Grafana + ELK监控栈

set -e

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # 无颜色

echo -e "${BLUE}🚀 设置ImagentX监控系统...${NC}"

# 检查Docker服务
check_docker() {
    if ! docker info >/dev/null 2>&1; then
        echo -e "${RED}❌ Docker服务未运行，请先启动Docker${NC}"
        exit 1
    fi
    echo -e "${GREEN}✅ Docker服务正常运行${NC}"
}

# 创建监控网络
create_network() {
    echo -e "${BLUE}📦 创建监控网络...${NC}"
    docker network create monitoring 2>/dev/null || echo -e "${YELLOW}⚠️  监控网络已存在${NC}"
}

# 创建监控配置目录
create_directories() {
    echo -e "${BLUE}📁 创建监控配置目录...${NC}"
    mkdir -p monitoring/{prometheus,grafana,elasticsearch,logstash,kibana}
    mkdir -p monitoring/prometheus/{configs,data}
    mkdir -p monitoring/grafana/{data,provisioning}
    mkdir -p monitoring/elasticsearch/data
    mkdir -p monitoring/logstash/{config,pipeline}
    mkdir -p monitoring/kibana/config
}

# 创建Prometheus配置
create_prometheus_config() {
    echo -e "${BLUE}⚙️  创建Prometheus配置...${NC}"
    
    cat > monitoring/prometheus/configs/prometheus.yml << 'EOF'
global:
  scrape_interval: 15s
  evaluation_interval: 15s

rule_files:
  - "alert_rules.yml"

alerting:
  alertmanagers:
    - static_configs:
        - targets:
          - alertmanager:9093

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'imagentx-backend'
    static_configs:
      - targets: ['host.docker.internal:8088']
    metrics_path: '/actuator/prometheus'
    scrape_interval: 10s

  - job_name: 'imagentx-frontend'
    static_configs:
      - targets: ['host.docker.internal:3000']
    metrics_path: '/api/health'
    scrape_interval: 30s

  - job_name: 'postgres'
    static_configs:
      - targets: ['host.docker.internal:5432']
    scrape_interval: 30s

  - job_name: 'rabbitmq'
    static_configs:
      - targets: ['host.docker.internal:5672']
    scrape_interval: 30s
EOF

    cat > monitoring/prometheus/configs/alert_rules.yml << 'EOF'
groups:
  - name: imagentx_alerts
    rules:
      - alert: HighErrorRate
        expr: rate(http_requests_total{status=~"5.."}[5m]) > 0.1
        for: 2m
        labels:
          severity: warning
        annotations:
          summary: "High error rate detected"
          description: "Error rate is {{ $value }} errors per second"

      - alert: HighResponseTime
        expr: histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m])) > 1
        for: 2m
        labels:
          severity: warning
        annotations:
          summary: "High response time detected"
          description: "95th percentile response time is {{ $value }} seconds"

      - alert: ServiceDown
        expr: up == 0
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "Service is down"
          description: "Service {{ $labels.job }} is down"
EOF
}

# 创建Grafana配置
create_grafana_config() {
    echo -e "${BLUE}📊 创建Grafana配置...${NC}"
    
    cat > monitoring/grafana/provisioning/datasources/datasources.yml << 'EOF'
apiVersion: 1

datasources:
  - name: Prometheus
    type: prometheus
    access: proxy
    url: http://prometheus:9090
    isDefault: true

  - name: Elasticsearch
    type: elasticsearch
    access: proxy
    url: http://elasticsearch:9200
    database: "logstash-*"
    jsonData:
      timeField: "@timestamp"
      esVersion: 7.0.0
EOF

    cat > monitoring/grafana/provisioning/dashboards/dashboards.yml << 'EOF'
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
      path: /var/lib/grafana/dashboards
EOF
}

# 创建ELK配置
create_elk_config() {
    echo -e "${BLUE}📝 创建ELK配置...${NC}"
    
    cat > monitoring/logstash/config/logstash.yml << 'EOF'
http.host: "0.0.0.0"
xpack.monitoring.elasticsearch.hosts: [ "http://elasticsearch:9200" ]
EOF

    cat > monitoring/logstash/pipeline/logstash.conf << 'EOF'
input {
  beats {
    port => 5044
  }
}

filter {
  if [fields][service] == "imagentx-backend" {
    grok {
      match => { "message" => "%{TIMESTAMP_ISO8601:timestamp} %{LOGLEVEL:level} %{GREEDYDATA:message}" }
    }
    date {
      match => [ "timestamp", "yyyy-MM-dd HH:mm:ss.SSS" ]
    }
  }
}

output {
  elasticsearch {
    hosts => ["elasticsearch:9200"]
    index => "logstash-%{+YYYY.MM.dd}"
  }
}
EOF

    cat > monitoring/kibana/config/kibana.yml << 'EOF'
server.name: kibana
server.host: "0.0.0.0"
elasticsearch.hosts: [ "http://elasticsearch:9200" ]
monitoring.ui.container.elasticsearch.enabled: true
EOF
}

# 创建Docker Compose文件
create_docker_compose() {
    echo -e "${BLUE}🐳 创建监控Docker Compose配置...${NC}"
    
    cat > monitoring/docker-compose.monitoring.yml << 'EOF'
version: '3.8'

networks:
  monitoring:
    external: true

services:
  prometheus:
    image: prom/prometheus:latest
    container_name: prometheus
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus/configs:/etc/prometheus
      - ./prometheus/data:/prometheus
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
      - '--web.console.libraries=/etc/prometheus/console_libraries'
      - '--web.console.templates=/etc/prometheus/consoles'
      - '--storage.tsdb.retention.time=200h'
      - '--web.enable-lifecycle'
    networks:
      - monitoring
    restart: unless-stopped

  grafana:
    image: grafana/grafana:latest
    container_name: grafana
    ports:
      - "3001:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin123
      - GF_USERS_ALLOW_SIGN_UP=false
    volumes:
      - ./grafana/data:/var/lib/grafana
      - ./grafana/provisioning:/etc/grafana/provisioning
    networks:
      - monitoring
    restart: unless-stopped
    depends_on:
      - prometheus

  alertmanager:
    image: prom/alertmanager:latest
    container_name: alertmanager
    ports:
      - "9093:9093"
    volumes:
      - ./alertmanager:/etc/alertmanager
    command:
      - '--config.file=/etc/alertmanager/alertmanager.yml'
      - '--storage.path=/alertmanager'
    networks:
      - monitoring
    restart: unless-stopped

  elasticsearch:
    image: docker.elastic.co/elasticsearch/elasticsearch:7.17.0
    container_name: elasticsearch
    environment:
      - discovery.type=single-node
      - "ES_JAVA_OPTS=-Xms512m -Xmx512m"
    ports:
      - "9200:9200"
    volumes:
      - ./elasticsearch/data:/usr/share/elasticsearch/data
    networks:
      - monitoring
    restart: unless-stopped

  logstash:
    image: docker.elastic.co/logstash/logstash:7.17.0
    container_name: logstash
    ports:
      - "5044:5044"
    volumes:
      - ./logstash/config:/usr/share/logstash/config
      - ./logstash/pipeline:/usr/share/logstash/pipeline
    networks:
      - monitoring
    restart: unless-stopped
    depends_on:
      - elasticsearch

  kibana:
    image: docker.elastic.co/kibana/kibana:7.17.0
    container_name: kibana
    ports:
      - "5601:5601"
    volumes:
      - ./kibana/config:/usr/share/kibana/config
    networks:
      - monitoring
    restart: unless-stopped
    depends_on:
      - elasticsearch

  filebeat:
    image: docker.elastic.co/beats/filebeat:7.17.0
    container_name: filebeat
    user: root
    volumes:
      - ./filebeat.yml:/usr/share/filebeat/filebeat.yml:ro
      - /var/lib/docker/containers:/var/lib/docker/containers:ro
      - /var/log/docker:/var/log/docker:ro
    networks:
      - monitoring
    restart: unless-stopped
    depends_on:
      - logstash
EOF

    cat > monitoring/filebeat.yml << 'EOF'
filebeat.inputs:
- type: container
  paths:
    - '/var/lib/docker/containers/*/*.log'

processors:
- add_docker_metadata:
    host: "unix:///var/run/docker.sock"

output.logstash:
  hosts: ["logstash:5044"]
EOF

    cat > monitoring/alertmanager/alertmanager.yml << 'EOF'
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
EOF
}

# 启动监控服务
start_monitoring() {
    echo -e "${BLUE}🚀 启动监控服务...${NC}"
    cd monitoring
    docker-compose -f docker-compose.monitoring.yml up -d
    
    echo -e "${GREEN}✅ 监控服务启动完成！${NC}"
    echo -e "${BLUE}📊 访问地址:${NC}"
    echo -e "  - Prometheus: http://localhost:9090"
    echo -e "  - Grafana: http://localhost:3001 (admin/admin123)"
    echo -e "  - AlertManager: http://localhost:9093"
    echo -e "  - Kibana: http://localhost:5601"
    echo -e "  - Elasticsearch: http://localhost:9200"
}

# 创建监控脚本
create_monitoring_scripts() {
    echo -e "${BLUE}📜 创建监控管理脚本...${NC}"
    
    cat > monitoring/monitor.sh << 'EOF'
#!/bin/bash

# 监控服务管理脚本

case "$1" in
    start)
        docker-compose -f docker-compose.monitoring.yml up -d
        echo "监控服务已启动"
        ;;
    stop)
        docker-compose -f docker-compose.monitoring.yml down
        echo "监控服务已停止"
        ;;
    restart)
        docker-compose -f docker-compose.monitoring.yml restart
        echo "监控服务已重启"
        ;;
    status)
        docker-compose -f docker-compose.monitoring.yml ps
        ;;
    logs)
        docker-compose -f docker-compose.monitoring.yml logs -f
        ;;
    *)
        echo "用法: $0 {start|stop|restart|status|logs}"
        exit 1
        ;;
esac
EOF

    chmod +x monitoring/monitor.sh
}

# 主函数
main() {
    echo -e "${BLUE}🔍 检查环境...${NC}"
    check_docker
    
    echo -e "${BLUE}📦 创建监控网络...${NC}"
    create_network
    
    echo -e "${BLUE}📁 创建目录结构...${NC}"
    create_directories
    
    echo -e "${BLUE}⚙️  生成配置文件...${NC}"
    create_prometheus_config
    create_grafana_config
    create_elk_config
    create_docker_compose
    create_monitoring_scripts
    
    echo -e "${BLUE}🚀 启动监控服务...${NC}"
    start_monitoring
    
    echo -e "${GREEN}🎉 监控系统设置完成！${NC}"
    echo -e "${YELLOW}📝 使用以下命令管理监控服务:${NC}"
    echo -e "  cd monitoring"
    echo -e "  ./monitor.sh {start|stop|restart|status|logs}"
}

# 执行主函数
main "$@"
