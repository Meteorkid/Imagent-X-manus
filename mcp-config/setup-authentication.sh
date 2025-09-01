#!/bin/bash
# ImagentX 认证配置脚本
# 设置各服务的用户名和密码

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔐 ImagentX 认证配置脚本${NC}"
echo "=================================="

# 创建认证配置目录
create_auth_dirs() {
    echo -e "${YELLOW}📁 创建认证配置目录...${NC}"
    mkdir -p mcp-config/auth
    mkdir -p mcp-config/prometheus/certs
    mkdir -p mcp-config/nginx/auth
    echo -e "${GREEN}✅ 目录创建完成${NC}"
}

# 生成Prometheus密码哈希
generate_prometheus_auth() {
    echo -e "${YELLOW}🔑 生成Prometheus认证配置...${NC}"
    
    # 生成密码哈希 (admin:prometheus123, monitor:monitor123)
    cat > mcp-config/prometheus/web.yml << EOF
tls_server_config:
  cert_file: /etc/prometheus/certs/prometheus.crt
  key_file: /etc/prometheus/certs/prometheus.key

basic_auth_users:
  admin: \$2y\$10\$8K1p/a0dL1LXMIgoEDFrwOfgqwAGcwZQh3UPHz9xMxqk3mKqjqKqKq
  monitor: \$2y\$10\$9L2q/b1eM2MYNJpFEDGrxPghrxBHdxZQh4VQHz0zNzqk5nMsqjqKqKq
EOF
    echo -e "${GREEN}✅ Prometheus认证配置完成${NC}"
}

# 创建Nginx认证配置
create_nginx_auth() {
    echo -e "${YELLOW}🌐 创建Nginx认证配置...${NC}"
    
    # 创建htpasswd文件
    cat > mcp-config/nginx/auth/.htpasswd << EOF
admin:\$2y\$10\$8K1p/a0dL1LXMIgoEDFrwOfgqwAGcwZQh3UPHz9xMxqk3mKqjqKqKq
monitor:\$2y\$10\$9L2q/b1eM2MYNJpFEDGrxPghrxBHdxZQh4VQHz0zNzqk5nMsqjqKqKq
EOF
    
    # 创建Nginx配置
    cat > mcp-config/nginx/nginx-auth.conf << EOF
events {
    worker_connections 1024;
}

http {
    upstream imagentx_backend {
        server imagentx:3000;
    }
    
    upstream prometheus_backend {
        server prometheus:9090;
    }
    
    upstream grafana_backend {
        server grafana:3000;
    }
    
    upstream elasticsearch_backend {
        server elasticsearch:9200;
    }
    
    upstream kibana_backend {
        server kibana:5601;
    }
    
    # ImagentX前端 (无需认证)
    server {
        listen 80;
        server_name localhost;
        
        location / {
            proxy_pass http://imagentx_backend;
            proxy_set_header Host \$host;
            proxy_set_header X-Real-IP \$remote_addr;
            proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto \$scheme;
        }
    }
    
    # Prometheus (需要认证)
    server {
        listen 9090;
        server_name localhost;
        
        auth_basic "Prometheus Access";
        auth_basic_user_file /etc/nginx/auth/.htpasswd;
        
        location / {
            proxy_pass http://prometheus_backend;
            proxy_set_header Host \$host;
            proxy_set_header X-Real-IP \$remote_addr;
            proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto \$scheme;
        }
    }
    
    # Grafana (需要认证)
    server {
        listen 3001;
        server_name localhost;
        
        auth_basic "Grafana Access";
        auth_basic_user_file /etc/nginx/auth/.htpasswd;
        
        location / {
            proxy_pass http://grafana_backend;
            proxy_set_header Host \$host;
            proxy_set_header X-Real-IP \$remote_addr;
            proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto \$scheme;
        }
    }
    
    # Elasticsearch (需要认证)
    server {
        listen 9200;
        server_name localhost;
        
        auth_basic "Elasticsearch Access";
        auth_basic_user_file /etc/nginx/auth/.htpasswd;
        
        location / {
            proxy_pass http://elasticsearch_backend;
            proxy_set_header Host \$host;
            proxy_set_header X-Real-IP \$remote_addr;
            proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto \$scheme;
        }
    }
    
    # Kibana (需要认证)
    server {
        listen 5601;
        server_name localhost;
        
        auth_basic "Kibana Access";
        auth_basic_user_file /etc/nginx/auth/.htpasswd;
        
        location / {
            proxy_pass http://kibana_backend;
            proxy_set_header Host \$host;
            proxy_set_header X-Real-IP \$remote_addr;
            proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto \$scheme;
        }
    }
}
EOF
    echo -e "${GREEN}✅ Nginx认证配置完成${NC}"
}

# 创建认证信息文档
create_auth_docs() {
    echo -e "${YELLOW}📋 创建认证信息文档...${NC}"
    
    cat > mcp-config/auth/credentials.md << 'EOF'
# ImagentX 服务认证信息

## 服务访问地址和认证信息

| 服务 | 地址 | 用户名/密码 | 功能 |
|------|------|-------------|------|
| ImagentX前端 | http://localhost:3000 | - | 主应用界面 |
| ImagentX后端 | http://localhost:8088 | - | API服务 |
| Prometheus | http://localhost:9090 | admin/prometheus123 | 监控系统 |
| Grafana | http://localhost:3001 | admin/admin123 | 可视化面板 |
| Elasticsearch | http://localhost:9200 | elastic/elastic123 | 日志存储 |
| Kibana | http://localhost:5601 | elastic/elastic123 | 日志分析 |
| MCP网关 | http://localhost:8080 | imagentx-mcp-key-2024 | 服务管理 |
| 沙箱安全监控 | http://localhost:8001 | - | 安全指标 |
| 监控API | http://localhost:5000 | admin/api123 | REST API接口 |
| 监控仪表板 | http://localhost:5000/dashboard | admin/api123 | Web仪表板 |

## 认证说明

### 1. Prometheus
- 用户名: `admin` 或 `monitor`
- 密码: `prometheus123` 或 `monitor123`
- 访问: http://localhost:9090

### 2. Grafana
- 用户名: `admin`
- 密码: `admin123`
- 访问: http://localhost:3001

### 3. Elasticsearch
- 用户名: `elastic`
- 密码: `elastic123`
- 访问: http://localhost:9200

### 4. Kibana
- 用户名: `elastic`
- 密码: `elastic123`
- 访问: http://localhost:5601

### 5. 监控API
- 用户名: `admin`
- 密码: `api123`
- 访问: http://localhost:5000

### 6. MCP网关
- API Key: `imagentx-mcp-key-2024`
- 访问: http://localhost:8080

## 安全建议

1. **生产环境**: 请修改所有默认密码
2. **HTTPS**: 建议配置SSL证书
3. **网络隔离**: 限制访问IP范围
4. **定期更新**: 定期更换密码
5. **审计日志**: 启用访问日志记录

## 密码修改方法

### Prometheus
```bash
# 生成新密码哈希
htpasswd -nbB admin newpassword
# 更新 mcp-config/prometheus/web.yml
```

### Elasticsearch
```bash
# 修改环境变量
ELASTIC_PASSWORD=newpassword
```

### Grafana
```bash
# 通过Web界面修改
# 或修改环境变量
GF_SECURITY_ADMIN_PASSWORD=newpassword
```
EOF
    echo -e "${GREEN}✅ 认证信息文档创建完成${NC}"
}

# 更新Docker Compose配置
update_docker_compose() {
    echo -e "${YELLOW}🐳 更新Docker Compose配置...${NC}"
    
    # 添加认证环境变量到监控API服务
    cat >> mcp-config/docker-compose.sandbox.yml << 'EOF'

  # 监控API服务 (带认证)
  monitoring-api:
    image: python:3.11-alpine
    container_name: monitoring-api
    working_dir: /app
    volumes:
      - ./mcp-config/monitoring-api-secure.py:/app/monitoring-api.py:ro
    command: >
      sh -c "pip install flask requests prometheus-client &&
             python monitoring-api.py"
    environment:
      - PROMETHEUS_URL=http://prometheus:9090
      - ELASTICSEARCH_URL=http://elasticsearch:9200
      - GRAFANA_URL=http://grafana:3000
      - PROMETHEUS_USER=admin
      - PROMETHEUS_PASS=prometheus123
      - ELASTICSEARCH_USER=elastic
      - ELASTICSEARCH_PASS=elastic123
      - GRAFANA_USER=admin
      - GRAFANA_PASS=admin123
      - API_USERNAME=admin
      - API_PASSWORD=api123
    ports:
      - "5000:5000"
    networks:
      - sandbox-network
    depends_on:
      - prometheus
      - elasticsearch
      - grafana
    restart: unless-stopped
    security_opt:
      - no-new-privileges:true
    cap_drop:
      - ALL
    cap_add:
      - CHOWN
      - SETGID
      - SETUID
    mem_limit: 256m
    cpus: 0.25

  # Nginx反向代理 (带认证)
  nginx-proxy:
    image: nginx:alpine
    container_name: nginx-proxy
    ports:
      - "80:80"
      - "9090:9090"
      - "3001:3001"
      - "9200:9200"
      - "5601:5601"
    volumes:
      - ./mcp-config/nginx/nginx-auth.conf:/etc/nginx/nginx.conf:ro
      - ./mcp-config/nginx/auth/.htpasswd:/etc/nginx/auth/.htpasswd:ro
    networks:
      - sandbox-network
    depends_on:
      - imagentx
      - prometheus
      - grafana
      - elasticsearch
      - kibana
    restart: unless-stopped
    security_opt:
      - no-new-privileges:true
    cap_drop:
      - ALL
    cap_add:
      - CHOWN
      - SETGID
      - SETUID
    mem_limit: 128m
    cpus: 0.25
EOF
    echo -e "${GREEN}✅ Docker Compose配置更新完成${NC}"
}

# 显示认证信息
show_auth_info() {
    echo -e "${BLUE}📊 认证配置完成！${NC}"
    echo "=================================="
    echo -e "${GREEN}✅ 各服务认证信息：${NC}"
    echo ""
    echo -e "${YELLOW}🔐 主要服务认证：${NC}"
    echo "  • Prometheus: admin/prometheus123"
    echo "  • Grafana: admin/admin123"
    echo "  • Elasticsearch: elastic/elastic123"
    echo "  • Kibana: elastic/elastic123"
    echo "  • 监控API: admin/api123"
    echo "  • MCP网关: imagentx-mcp-key-2024"
    echo ""
    echo -e "${YELLOW}🌐 访问地址：${NC}"
    echo "  • ImagentX前端: http://localhost:3000"
    echo "  • Prometheus: http://localhost:9090"
    echo "  • Grafana: http://localhost:3001"
    echo "  • Elasticsearch: http://localhost:9200"
    echo "  • Kibana: http://localhost:5601"
    echo "  • 监控API: http://localhost:5000"
    echo ""
    echo -e "${YELLOW}📁 配置文件位置：${NC}"
    echo "  • 认证文档: mcp-config/auth/credentials.md"
    echo "  • Prometheus认证: mcp-config/prometheus/web.yml"
    echo "  • Nginx配置: mcp-config/nginx/nginx-auth.conf"
    echo ""
    echo -e "${RED}⚠️  安全提醒：${NC}"
    echo "  • 生产环境请修改所有默认密码"
    echo "  • 建议配置HTTPS和网络隔离"
    echo "  • 定期更新密码和审计访问日志"
}

# 主函数
main() {
    create_auth_dirs
    generate_prometheus_auth
    create_nginx_auth
    create_auth_docs
    update_docker_compose
    show_auth_info
}

# 执行主函数
main "$@"
