#!/bin/bash
# ImagentX 认证测试脚本
# 测试各服务的认证功能

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🧪 ImagentX 认证测试脚本${NC}"
echo "=================================="

# 等待服务启动
wait_for_services() {
    echo -e "${YELLOW}⏳ 等待服务启动...${NC}"
    sleep 30
}

# 测试Prometheus认证
test_prometheus_auth() {
    echo -e "${YELLOW}🔍 测试Prometheus认证...${NC}"
    
    # 测试无认证访问 (应该失败)
    if curl -s -o /dev/null -w "%{http_code}" http://localhost:9090/api/v1/query?query=up | grep -q "401"; then
        echo -e "${GREEN}✅ Prometheus无认证访问被正确拒绝${NC}"
    else
        echo -e "${RED}❌ Prometheus无认证访问未被拒绝${NC}"
    fi
    
    # 测试正确认证访问 (应该成功)
    if curl -s -u admin:prometheus123 http://localhost:9090/api/v1/query?query=up | grep -q "result"; then
        echo -e "${GREEN}✅ Prometheus认证访问成功${NC}"
    else
        echo -e "${RED}❌ Prometheus认证访问失败${NC}"
    fi
}

# 测试Grafana认证
test_grafana_auth() {
    echo -e "${YELLOW}🔍 测试Grafana认证...${NC}"
    
    # 测试无认证访问 (应该失败)
    if curl -s -o /dev/null -w "%{http_code}" http://localhost:3001/api/health | grep -q "401"; then
        echo -e "${GREEN}✅ Grafana无认证访问被正确拒绝${NC}"
    else
        echo -e "${RED}❌ Grafana无认证访问未被拒绝${NC}"
    fi
    
    # 测试正确认证访问 (应该成功)
    if curl -s -u admin:admin123 http://localhost:3001/api/health | grep -q "ok"; then
        echo -e "${GREEN}✅ Grafana认证访问成功${NC}"
    else
        echo -e "${RED}❌ Grafana认证访问失败${NC}"
    fi
}

# 测试Elasticsearch认证
test_elasticsearch_auth() {
    echo -e "${YELLOW}🔍 测试Elasticsearch认证...${NC}"
    
    # 测试无认证访问 (应该失败)
    if curl -s -o /dev/null -w "%{http_code}" http://localhost:9200/_cluster/health | grep -q "401"; then
        echo -e "${GREEN}✅ Elasticsearch无认证访问被正确拒绝${NC}"
    else
        echo -e "${RED}❌ Elasticsearch无认证访问未被拒绝${NC}"
    fi
    
    # 测试正确认证访问 (应该成功)
    if curl -s -u elastic:elastic123 http://localhost:9200/_cluster/health | grep -q "cluster_name"; then
        echo -e "${GREEN}✅ Elasticsearch认证访问成功${NC}"
    else
        echo -e "${RED}❌ Elasticsearch认证访问失败${NC}"
    fi
}

# 测试Kibana认证
test_kibana_auth() {
    echo -e "${YELLOW}🔍 测试Kibana认证...${NC}"
    
    # 测试无认证访问 (应该失败)
    if curl -s -o /dev/null -w "%{http_code}" http://localhost:5601/api/status | grep -q "401"; then
        echo -e "${GREEN}✅ Kibana无认证访问被正确拒绝${NC}"
    else
        echo -e "${RED}❌ Kibana无认证访问未被拒绝${NC}"
    fi
    
    # 测试正确认证访问 (应该成功)
    if curl -s -u elastic:elastic123 http://localhost:5601/api/status | grep -q "status"; then
        echo -e "${GREEN}✅ Kibana认证访问成功${NC}"
    else
        echo -e "${RED}❌ Kibana认证访问失败${NC}"
    fi
}

# 测试监控API认证
test_monitoring_api_auth() {
    echo -e "${YELLOW}🔍 测试监控API认证...${NC}"
    
    # 测试无认证访问 (应该失败)
    if curl -s -o /dev/null -w "%{http_code}" http://localhost:5000/api/security/scores | grep -q "401"; then
        echo -e "${GREEN}✅ 监控API无认证访问被正确拒绝${NC}"
    else
        echo -e "${RED}❌ 监控API无认证访问未被拒绝${NC}"
    fi
    
    # 测试正确认证访问 (应该成功)
    if curl -s -u admin:api123 http://localhost:5000/api/security/scores | grep -q "success"; then
        echo -e "${GREEN}✅ 监控API认证访问成功${NC}"
    else
        echo -e "${RED}❌ 监控API认证访问失败${NC}"
    fi
}

# 测试MCP网关认证
test_mcp_gateway_auth() {
    echo -e "${YELLOW}🔍 测试MCP网关认证...${NC}"
    
    # 测试无API Key访问 (应该失败)
    if curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/health | grep -q "401"; then
        echo -e "${GREEN}✅ MCP网关无API Key访问被正确拒绝${NC}"
    else
        echo -e "${RED}❌ MCP网关无API Key访问未被拒绝${NC}"
    fi
    
    # 测试正确API Key访问 (应该成功)
    if curl -s -H "X-API-Key: imagentx-mcp-key-2024" http://localhost:8080/health | grep -q "status"; then
        echo -e "${GREEN}✅ MCP网关API Key访问成功${NC}"
    else
        echo -e "${RED}❌ MCP网关API Key访问失败${NC}"
    fi
}

# 测试ImagentX前端登录
test_imagentx_frontend() {
    echo -e "${YELLOW}🔍 测试ImagentX前端登录...${NC}"
    
    # 测试登录页面访问
    if curl -s -o /dev/null -w "%{http_code}" http://localhost:3000/login | grep -q "200"; then
        echo -e "${GREEN}✅ ImagentX前端登录页面访问成功${NC}"
    else
        echo -e "${RED}❌ ImagentX前端登录页面访问失败${NC}"
    fi
    
    # 测试登录API
    LOGIN_RESPONSE=$(curl -s -X POST http://localhost:8088/api/login \
        -H "Content-Type: application/json" \
        -d '{"account":"admin@imagentx.top","password":"admin123"}')
    
    if echo "$LOGIN_RESPONSE" | grep -q "token"; then
        echo -e "${GREEN}✅ ImagentX登录API测试成功${NC}"
        # 提取token用于后续测试
        TOKEN=$(echo "$LOGIN_RESPONSE" | grep -o '"token":"[^"]*"' | cut -d'"' -f4)
        export IMAGENTX_TOKEN="$TOKEN"
    else
        echo -e "${RED}❌ ImagentX登录API测试失败${NC}"
        echo "响应: $LOGIN_RESPONSE"
    fi
}

# 测试ImagentX后端API认证
test_imagentx_backend() {
    echo -e "${YELLOW}🔍 测试ImagentX后端API认证...${NC}"
    
    if [ -z "$IMAGENTX_TOKEN" ]; then
        echo -e "${RED}❌ 无法测试后端API，未获取到token${NC}"
        return
    fi
    
    # 测试无token访问 (应该失败)
    if curl -s -o /dev/null -w "%{http_code}" http://localhost:8088/api/users/me | grep -q "401"; then
        echo -e "${GREEN}✅ ImagentX后端无token访问被正确拒绝${NC}"
    else
        echo -e "${RED}❌ ImagentX后端无token访问未被拒绝${NC}"
    fi
    
    # 测试有token访问 (应该成功)
    if curl -s -H "Authorization: Bearer $IMAGENTX_TOKEN" http://localhost:8088/api/users/me | grep -q "email"; then
        echo -e "${GREEN}✅ ImagentX后端token认证访问成功${NC}"
    else
        echo -e "${RED}❌ ImagentX后端token认证访问失败${NC}"
    fi
}

# 显示认证信息
show_credentials() {
    echo -e "${BLUE}📋 认证信息汇总：${NC}"
    echo "=================================="
    echo -e "${YELLOW}🔐 服务认证信息：${NC}"
    echo "  • ImagentX前端: admin@imagentx.top/admin123"
    echo "  • ImagentX后端: admin@imagentx.top/admin123"
    echo "  • Prometheus: admin/prometheus123"
    echo "  • Grafana: admin/admin123"
    echo "  • Elasticsearch: elastic/elastic123"
    echo "  • Kibana: elastic/elastic123"
    echo "  • 监控API: admin/api123"
    echo "  • MCP网关: imagentx-mcp-key-2024"
    echo "  • 测试用户: test@imagentx.top/test123"
    echo ""
    echo -e "${YELLOW}🌐 访问地址：${NC}"
    echo "  • ImagentX前端: http://localhost:3000"
    echo "  • ImagentX登录: http://localhost:3000/login"
    echo "  • ImagentX后端: http://localhost:8088"
    echo "  • Prometheus: http://localhost:9090"
    echo "  • Grafana: http://localhost:3001"
    echo "  • Elasticsearch: http://localhost:9200"
    echo "  • Kibana: http://localhost:5601"
    echo "  • 监控API: http://localhost:5000"
    echo "  • MCP网关: http://localhost:8080"
}

# 主函数
main() {
    wait_for_services
    test_imagentx_frontend
    test_imagentx_backend
    test_prometheus_auth
    test_grafana_auth
    test_elasticsearch_auth
    test_kibana_auth
    test_monitoring_api_auth
    test_mcp_gateway_auth
    show_credentials
    echo -e "${GREEN}🎉 认证测试完成！${NC}"
}

# 执行主函数
main "$@"
