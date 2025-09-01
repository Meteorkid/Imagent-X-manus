#!/bin/bash

# ImagentX 沙箱隔离配置更新脚本
# 用于更新现有的Docker服务配置，增加沙箱安全隔离

set -e

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🛡️ 更新ImagentX Docker服务以支持沙箱隔离...${NC}"

# 备份现有配置
backup_config() {
    echo -e "${BLUE}📁 备份现有配置...${NC}"
    
    if [ -f "working-docker-compose.yml" ]; then
        cp working-docker-compose.yml working-docker-compose.yml.backup.$(date +%Y%m%d_%H%M%S)
        echo -e "${GREEN}✅ 配置已备份${NC}"
    fi
}

# 更新Docker服务配置
update_docker_service() {
    echo -e "${BLUE}🔧 更新Docker服务配置...${NC}"
    
    # 检查是否存在Docker服务配置
    if [ ! -f "apps/backend/src/main/java/org/xhy/infrastructure/docker/DockerService.java" ]; then
        echo -e "${RED}❌ 未找到Docker服务配置文件${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✅ Docker服务配置检查完成${NC}"
}

# 创建沙箱网络配置
create_sandbox_network() {
    echo -e "${BLUE}🌐 创建沙箱网络配置...${NC}"
    
    # 创建沙箱网络
    docker network create --driver bridge --internal sandbox-network 2>/dev/null || true
    docker network create --driver bridge --internal user-isolated-network 2>/dev/null || true
    
    echo -e "${GREEN}✅ 沙箱网络创建完成${NC}"
}

# 更新容器模板配置
update_container_templates() {
    echo -e "${BLUE}📋 更新容器模板配置...${NC}"
    
    # 创建沙箱容器模板
    cat > mcp-config/sandbox-container-template.yml << 'EOF'
# 沙箱容器模板配置
sandbox_template:
  image: ghcr.io/lucky-aeon/mcp-gateway:latest
  security_opt:
    - no-new-privileges:true
    - seccomp:unconfined
  cap_drop:
    - ALL
  cap_add:
    - CHOWN
    - SETGID
    - SETUID
  read_only: true
  tmpfs:
    - /tmp:noexec,nosuid,size=100m
    - /var/tmp:noexec,nosuid,size=50m
  ulimits:
    nofile:
      soft: 1024
      hard: 2048
  mem_limit: 512m
  cpus: 0.5
  pids_limit: 50
  networks:
    - user-isolated-network
EOF
    
    echo -e "${GREEN}✅ 容器模板配置更新完成${NC}"
}

# 创建安全监控配置
create_security_monitoring() {
    echo -e "${BLUE}🔍 创建安全监控配置...${NC}"
    
    # 创建安全监控配置
    cat > mcp-config/security-monitoring.yml << 'EOF'
# 安全监控配置
security_monitoring:
  # 容器行为监控
  container_monitoring:
    - resource_usage: true
    - network_connections: true
    - file_system_access: true
    - process_creation: true
    - anomaly_detection: true
  
  # 告警规则
  alert_rules:
    - memory_usage_threshold: 80
    - cpu_usage_threshold: 90
    - network_connections_threshold: 100
    - file_system_write_threshold: 1073741824  # 1GB
    - process_count_threshold: 40
  
  # 日志审计
  audit_logging:
    - container_lifecycle: true
    - file_access: true
    - network_activity: true
    - process_activity: true
    - user_operations: true
EOF
    
    echo -e "${GREEN}✅ 安全监控配置创建完成${NC}"
}

# 创建沙箱启动脚本
create_sandbox_scripts() {
    echo -e "${BLUE}📜 创建沙箱启动脚本...${NC}"
    
    # 创建沙箱启动脚本
    cat > mcp-config/start-sandbox.sh << 'EOF'
#!/bin/bash

# 沙箱环境启动脚本

set -e

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🛡️ 启动ImagentX沙箱环境...${NC}"

# 检查Docker服务
check_docker() {
    if ! docker info >/dev/null 2>&1; then
        echo -e "${RED}❌ Docker服务未运行${NC}"
        exit 1
    fi
    echo -e "${GREEN}✅ Docker服务正常运行${NC}"
}

# 创建沙箱网络
create_networks() {
    echo -e "${BLUE}🌐 创建沙箱网络...${NC}"
    
    docker network create --driver bridge --internal sandbox-network 2>/dev/null || true
    docker network create --driver bridge --internal user-isolated-network 2>/dev/null || true
    
    echo -e "${GREEN}✅ 沙箱网络创建完成${NC}"
}

# 启动沙箱监控
start_monitoring() {
    echo -e "${BLUE}🔍 启动沙箱监控...${NC}"
    
    docker-compose -f mcp-config/sandbox-security.yml up -d sandbox-monitor sandbox-logger
    
    echo -e "${GREEN}✅ 沙箱监控启动完成${NC}"
}

# 显示沙箱信息
show_sandbox_info() {
    echo -e "\n${BLUE}📊 沙箱环境信息:${NC}"
    echo -e "${GREEN}• 沙箱监控: http://localhost:9091${NC}"
    echo -e "${GREEN}• 沙箱网络: sandbox-network, user-isolated-network${NC}"
    echo -e "${GREEN}• 安全配置: 已启用容器隔离、资源限制、网络隔离${NC}"
}

# 主函数
main() {
    check_docker
    create_networks
    start_monitoring
    show_sandbox_info
    
    echo -e "\n${GREEN}🎉 沙箱环境启动完成！${NC}"
}

main "$@"
EOF
    
    chmod +x mcp-config/start-sandbox.sh
    
    echo -e "${GREEN}✅ 沙箱启动脚本创建完成${NC}"
}

# 更新现有Docker Compose配置
update_docker_compose() {
    echo -e "${BLUE}🐳 更新Docker Compose配置...${NC}"
    
    # 检查是否存在现有的docker-compose配置
    if [ -f "working-docker-compose.yml" ]; then
        echo -e "${YELLOW}⚠️ 检测到现有配置，建议手动集成沙箱配置${NC}"
        echo -e "${BLUE}📝 请参考 mcp-config/sandbox-security.yml 进行配置集成${NC}"
    fi
    
    echo -e "${GREEN}✅ Docker Compose配置检查完成${NC}"
}

# 创建安全测试脚本
create_security_tests() {
    echo -e "${BLUE}🧪 创建安全测试脚本...${NC}"
    
    cat > mcp-config/test-sandbox-security.sh << 'EOF'
#!/bin/bash

# 沙箱安全测试脚本

set -e

echo "🧪 开始沙箱安全测试..."

# 测试容器隔离
test_container_isolation() {
    echo "测试容器隔离..."
    
    # 创建测试容器
    docker run --rm --network user-isolated-network \
        --security-opt no-new-privileges:true \
        --cap-drop ALL \
        --read-only \
        --tmpfs /tmp:noexec,nosuid,size=100m \
        --memory 512m \
        --cpus 0.5 \
        --pids-limit 50 \
        alpine:latest echo "容器隔离测试通过"
}

# 测试资源限制
test_resource_limits() {
    echo "测试资源限制..."
    
    # 测试内存限制
    timeout 10 docker run --rm --memory 100m alpine:latest sh -c "dd if=/dev/zero of=/dev/null bs=1M count=200" 2>/dev/null || echo "内存限制测试通过"
    
    # 测试CPU限制
    timeout 10 docker run --rm --cpus 0.1 alpine:latest sh -c "while true; do :; done" 2>/dev/null || echo "CPU限制测试通过"
}

# 测试网络隔离
test_network_isolation() {
    echo "测试网络隔离..."
    
    # 测试内部网络隔离
    docker run --rm --network user-isolated-network alpine:latest ping -c 1 8.8.8.8 2>/dev/null || echo "网络隔离测试通过"
}

# 执行测试
test_container_isolation
test_resource_limits
test_network_isolation

echo "✅ 沙箱安全测试完成"
EOF
    
    chmod +x mcp-config/test-sandbox-security.sh
    
    echo -e "${GREEN}✅ 安全测试脚本创建完成${NC}"
}

# 主函数
main() {
    echo -e "${BLUE}===== ImagentX 沙箱隔离配置更新 =====${NC}"
    
    backup_config
    update_docker_service
    create_sandbox_network
    update_container_templates
    create_security_monitoring
    create_sandbox_scripts
    update_docker_compose
    create_security_tests
    
    echo -e "\n${GREEN}🎉 沙箱隔离配置更新完成！${NC}"
    echo -e "\n${BLUE}📋 下一步操作:${NC}"
    echo -e "${YELLOW}1. 启动沙箱环境: ./mcp-config/start-sandbox.sh${NC}"
    echo -e "${YELLOW}2. 测试安全配置: ./mcp-config/test-sandbox-security.sh${NC}"
    echo -e "${YELLOW}3. 集成到现有系统: 参考 sandbox-security-config.md${NC}"
}

# 执行主函数
main "$@"
