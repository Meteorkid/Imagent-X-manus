#!/bin/bash

# MCP网关集成测试脚本
# 用于测试ImagentX与MCP网关的集成

set -e

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # 无颜色

echo -e "${BLUE}🧪 MCP网关集成测试${NC}"

# 测试MCP网关服务
test_mcp_gateway() {
    echo -e "\n${BLUE}1. 测试MCP网关服务...${NC}"
    
    # 测试健康检查
    if curl -s http://localhost:8081/health >/dev/null 2>&1; then
        echo -e "${GREEN}✅ MCP网关健康检查通过${NC}"
    else
        echo -e "${RED}❌ MCP网关健康检查失败${NC}"
        return 1
    fi
    
    # 测试API健康检查
    if curl -s http://localhost:8081/api/health >/dev/null 2>&1; then
        echo -e "${GREEN}✅ MCP网关API健康检查通过${NC}"
    else
        echo -e "${RED}❌ MCP网关API健康检查失败${NC}"
        return 1
    fi
    
    # 测试工具列表
    if curl -s http://localhost:8081/mcp/tools >/dev/null 2>&1; then
        echo -e "${GREEN}✅ MCP网关工具列表获取成功${NC}"
    else
        echo -e "${RED}❌ MCP网关工具列表获取失败${NC}"
        return 1
    fi
    
    return 0
}

# 测试ImagentX后端服务
test_imagentx_backend() {
    echo -e "\n${BLUE}2. 测试ImagentX后端服务...${NC}"
    
    # 测试后端健康检查
    if curl -s http://localhost:8088/api/health >/dev/null 2>&1; then
        echo -e "${GREEN}✅ ImagentX后端健康检查通过${NC}"
    else
        echo -e "${RED}❌ ImagentX后端健康检查失败${NC}"
        return 1
    fi
    
    return 0
}

# 测试MCP配置
test_mcp_config() {
    echo -e "\n${BLUE}3. 测试MCP配置...${NC}"
    
    # 检查配置文件
    if grep -q "mcp:" ImagentX/src/main/resources/application.yml; then
        echo -e "${GREEN}✅ MCP配置已添加到application.yml${NC}"
    else
        echo -e "${RED}❌ MCP配置未找到${NC}"
        return 1
    fi
    
    # 检查环境变量
    if grep -q "MCP_GATEWAY_URL" deploy/.env; then
        echo -e "${GREEN}✅ MCP环境变量已配置${NC}"
    else
        echo -e "${RED}❌ MCP环境变量未配置${NC}"
        return 1
    fi
    
    return 0
}

# 测试MCP工具部署
test_mcp_deploy() {
    echo -e "\n${BLUE}4. 测试MCP工具部署...${NC}"
    
    # 测试工具部署
    response=$(curl -s -X POST http://localhost:8081/deploy \
        -H "Content-Type: application/json" \
        -d '{"toolId": "test-tool", "toolName": "测试工具", "version": "1.0.0"}')
    
    if echo "$response" | grep -q '"code": 200'; then
        echo -e "${GREEN}✅ MCP工具部署测试成功${NC}"
    else
        echo -e "${RED}❌ MCP工具部署测试失败${NC}"
        echo -e "${YELLOW}响应: $response${NC}"
        return 1
    fi
    
    return 0
}

# 显示服务状态
show_status() {
    echo -e "\n${BLUE}📊 服务状态概览:${NC}"
    echo -e "${GREEN}• MCP网关服务: http://localhost:8081${NC}"
    echo -e "${GREEN}• ImagentX后端: http://localhost:8088${NC}"
    echo -e "${GREEN}• ImagentX前端: http://localhost:3000${NC}"
    echo -e "${GREEN}• PostgreSQL数据库: localhost:5432${NC}"
    echo -e "${GREEN}• RabbitMQ消息队列: localhost:5672${NC}"
}

# 显示MCP网关信息
show_mcp_info() {
    echo -e "\n${BLUE}🔧 MCP网关信息:${NC}"
    echo -e "${GREEN}• 网关地址: http://localhost:8081${NC}"
    echo -e "${GREEN}• API密钥: default-api-key-1234567890${NC}"
    echo -e "${GREEN}• 健康检查: http://localhost:8081/health${NC}"
    echo -e "${GREEN}• API健康检查: http://localhost:8081/api/health${NC}"
    echo -e "${GREEN}• 工具列表: http://localhost:8081/mcp/tools${NC}"
    echo -e "${GREEN}• 工具部署: POST http://localhost:8081/deploy${NC}"
}

# 主函数
main() {
    echo -e "${BLUE}===== MCP网关集成测试 =====${NC}"
    
    local all_tests_passed=true
    
    # 执行测试
    test_mcp_gateway || all_tests_passed=false
    test_imagentx_backend || all_tests_passed=false
    test_mcp_config || all_tests_passed=false
    test_mcp_deploy || all_tests_passed=false
    
    # 显示结果
    if [ "$all_tests_passed" = true ]; then
        echo -e "\n${GREEN}🎉 所有测试通过！MCP网关集成成功！${NC}"
        show_status
        show_mcp_info
    else
        echo -e "\n${RED}❌ 部分测试失败，请检查相关服务${NC}"
        show_status
        exit 1
    fi
}

# 执行主函数
main "$@"
