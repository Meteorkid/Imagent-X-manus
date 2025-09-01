#!/bin/bash

# ImagentX 完整沙箱环境启动脚本
# 包含所有安全隔离、监控、审计功能

set -e

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🛡️ 启动ImagentX完整沙箱环境...${NC}"

# 检查Docker服务
check_docker() {
    if ! docker info >/dev/null 2>&1; then
        echo -e "${RED}❌ Docker服务未运行${NC}"
        exit 1
    fi
    echo -e "${GREEN}✅ Docker服务正常运行${NC}"
}

# 创建沙箱网络
create_sandbox_networks() {
    echo -e "${BLUE}🌐 创建沙箱网络...${NC}"
    
    # 创建沙箱网络
    docker network create --driver bridge --internal sandbox-network 2>/dev/null || true
    docker network create --driver bridge --internal user-isolated-network 2>/dev/null || true
    
    echo -e "${GREEN}✅ 沙箱网络创建完成${NC}"
}

# 创建必要的目录
create_directories() {
    echo -e "${BLUE}📁 创建沙箱目录...${NC}"
    
    mkdir -p mcp-config/grafana/provisioning/{datasources,dashboards}
    mkdir -p mcp-config/configs
    mkdir -p mcp-config/scheduler
    mkdir -p /docker/users
    mkdir -p /docker/temp
    
    # 设置目录权限
    chmod 755 /docker/users
    chmod 755 /docker/temp
    
    echo -e "${GREEN}✅ 沙箱目录创建完成${NC}"
}

# 启动完整沙箱系统
start_sandbox_system() {
    echo -e "${BLUE}🔧 启动完整沙箱系统...${NC}"
    
    # 停止现有服务
    docker-compose -f mcp-config/docker-compose.sandbox.yml down 2>/dev/null || true
    
    # 启动沙箱系统
    docker-compose -f mcp-config/docker-compose.sandbox.yml up -d
    
    echo -e "${GREEN}✅ 沙箱系统启动完成${NC}"
}

# 等待服务启动
wait_for_services() {
    echo -e "${BLUE}⏳ 等待沙箱服务启动...${NC}"
    
    services=(
        "http://localhost:3000"      # ImagentX前端
        "http://localhost:8088/api/health"  # ImagentX后端
        "http://localhost:9090/-/healthy"   # Prometheus
        "http://localhost:3001/api/health"  # Grafana
        "http://localhost:9200"      # Elasticsearch
        "http://localhost:5601"      # Kibana
        "http://localhost:8080"      # MCP网关
        "http://localhost:8082"      # 沙箱代理
    )
    
    for service in "${services[@]}"; do
        echo -e "${YELLOW}等待服务: $service${NC}"
        for i in {1..60}; do
            if curl -s "$service" >/dev/null 2>&1; then
                echo -e "${GREEN}✅ $service 启动成功${NC}"
                break
            fi
            if [ $i -eq 60 ]; then
                echo -e "${RED}❌ $service 启动超时${NC}"
            fi
            sleep 2
        done
    done
}

# 配置Grafana数据源
configure_grafana() {
    echo -e "${BLUE}📊 配置Grafana数据源...${NC}"
    
    # 等待Grafana启动
    sleep 10
    
    # 添加Prometheus数据源
    curl -X POST "http://admin:admin123@localhost:3001/api/datasources" \
        -H "Content-Type: application/json" \
        -d '{
            "name": "Prometheus",
            "type": "prometheus",
            "url": "http://prometheus:9090",
            "access": "proxy",
            "isDefault": true
        }' 2>/dev/null || true
    
    echo -e "${GREEN}✅ Grafana数据源配置完成${NC}"
}

# 创建沙箱仪表板
create_sandbox_dashboard() {
    echo -e "${BLUE}📈 创建沙箱监控仪表板...${NC}"
    
    # 创建沙箱监控仪表板
    cat > mcp-config/grafana/provisioning/dashboards/sandbox-dashboard.json << 'EOF'
{
  "dashboard": {
    "title": "ImagentX 沙箱监控",
    "panels": [
      {
        "title": "容器安全评分",
        "type": "stat",
        "targets": [
          {
            "expr": "sandbox_security_score",
            "legendFormat": "{{container_name}}"
          }
        ]
      },
      {
        "title": "安全违规统计",
        "type": "graph",
        "targets": [
          {
            "expr": "rate(sandbox_security_violations_total[5m])",
            "legendFormat": "{{container_name}} - {{violation_type}}"
          }
        ]
      },
      {
        "title": "异常行为检测",
        "type": "graph",
        "targets": [
          {
            "expr": "rate(sandbox_anomaly_detections_total[5m])",
            "legendFormat": "{{container_name}} - {{anomaly_type}}"
          }
        ]
      },
      {
        "title": "资源使用率",
        "type": "graph",
        "targets": [
          {
            "expr": "sandbox_resource_usage{resource_type=\"memory\"}",
            "legendFormat": "{{container_name}} - 内存"
          },
          {
            "expr": "sandbox_resource_usage{resource_type=\"cpu\"}",
            "legendFormat": "{{container_name}} - CPU"
          }
        ]
      }
    ]
  }
}
EOF
    
    echo -e "${GREEN}✅ 沙箱仪表板创建完成${NC}"
}

# 显示沙箱信息
show_sandbox_info() {
    echo -e "\n${BLUE}📊 ImagentX完整沙箱环境信息:${NC}"
    echo -e "${GREEN}• ImagentX前端: http://localhost:3000${NC}"
    echo -e "${GREEN}• ImagentX后端: http://localhost:8088${NC}"
    echo -e "${GREEN}• Prometheus监控: http://localhost:9090${NC}"
    echo -e "${GREEN}• Grafana可视化: http://localhost:3001 (admin/admin123)${NC}"
    echo -e "${GREEN}• Elasticsearch: http://localhost:9200${NC}"
    echo -e "${GREEN}• Kibana日志: http://localhost:5601${NC}"
    echo -e "${GREEN}• MCP网关: http://localhost:8080${NC}"
    echo -e "${GREEN}• 沙箱代理: http://localhost:8082${NC}"
    echo -e "${GREEN}• 沙箱安全监控: http://localhost:8001${NC}"
    echo -e "${GREEN}• RabbitMQ管理: http://localhost:15672 (guest/guest)${NC}"
}

# 显示安全特性
show_security_features() {
    echo -e "\n${BLUE}🛡️ 沙箱安全特性:${NC}"
    echo -e "${GREEN}✅ 容器隔离: 每个用户独立容器${NC}"
    echo -e "${GREEN}✅ 资源限制: 内存、CPU、进程数限制${NC}"
    echo -e "${GREEN}✅ 权限控制: 最小权限原则${NC}"
    echo -e "${GREEN}✅ 文件系统: 只读文件系统 + 临时目录${NC}"
    echo -e "${GREEN}✅ 网络隔离: 内部网络 + 端口控制${NC}"
    echo -e "${GREEN}✅ 实时监控: 资源使用 + 安全事件${NC}"
    echo -e "${GREEN}✅ 日志审计: 完整操作日志记录${NC}"
    echo -e "${GREEN}✅ 告警系统: 异常行为自动告警${NC}"
    echo -e "${GREEN}✅ 安全评分: 实时安全状态评估${NC}"
}

# 显示管理命令
show_management_commands() {
    echo -e "\n${BLUE}🔧 沙箱管理命令:${NC}"
    echo -e "${YELLOW}• 查看所有服务: docker-compose -f mcp-config/docker-compose.sandbox.yml ps${NC}"
    echo -e "${YELLOW}• 查看日志: docker-compose -f mcp-config/docker-compose.sandbox.yml logs -f${NC}"
    echo -e "${YELLOW}• 停止服务: docker-compose -f mcp-config/docker-compose.sandbox.yml down${NC}"
    echo -e "${YELLOW}• 重启服务: docker-compose -f mcp-config/docker-compose.sandbox.yml restart${NC}"
    echo -e "${YELLOW}• 安全测试: ./mcp-config/test-sandbox-security.sh${NC}"
    echo -e "${YELLOW}• 查看安全评分: curl http://localhost:8001/metrics | grep sandbox_security_score${NC}"
    echo -e "${YELLOW}• 查看告警: curl http://localhost:9090/api/v1/alerts${NC}"
}

# 运行安全测试
run_security_tests() {
    echo -e "\n${BLUE}🧪 运行沙箱安全测试...${NC}"
    
    if [ -f "mcp-config/test-sandbox-security.sh" ]; then
        chmod +x mcp-config/test-sandbox-security.sh
        ./mcp-config/test-sandbox-security.sh
    else
        echo -e "${YELLOW}⚠️ 安全测试脚本不存在，跳过测试${NC}"
    fi
}

# 主函数
main() {
    echo -e "${BLUE}===== ImagentX 完整沙箱环境启动 =====${NC}"
    
    check_docker
    create_sandbox_networks
    create_directories
    start_sandbox_system
    wait_for_services
    configure_grafana
    create_sandbox_dashboard
    show_sandbox_info
    show_security_features
    show_management_commands
    run_security_tests
    
    echo -e "\n${GREEN}🎉 ImagentX完整沙箱环境启动完成！${NC}"
    echo -e "${BLUE}📋 安全隔离已启用，所有用户操作都在沙箱环境中执行${NC}"
}

# 执行主函数
main "$@"
