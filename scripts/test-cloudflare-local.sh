#!/bin/bash

# ImagentX Cloudflare本地测试脚本
# 用于测试Cloudflare配置和性能

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${BLUE}☁️ ImagentX Cloudflare本地测试脚本${NC}"
echo "=================================="
echo -e "${CYAN}域名: imagent.top${NC}"
echo -e "${CYAN}CDN: Cloudflare${NC}"
echo ""

# 检查必要的工具
echo -e "${YELLOW}🔍 检查必要工具...${NC}"

if ! command -v curl &> /dev/null; then
    echo -e "${RED}❌ curl未安装${NC}"
    exit 1
fi

if ! command -v jq &> /dev/null; then
    echo -e "${YELLOW}⚠️ jq未安装，正在安装...${NC}"
    if [[ "$OSTYPE" == "darwin"* ]]; then
        brew install jq
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        sudo apt-get update && sudo apt-get install -y jq
    fi
fi

echo -e "${GREEN}✅ 工具检查完成${NC}"
echo ""

# 检查环境变量
echo -e "${YELLOW}🔍 检查环境变量...${NC}"

if [ -z "$CLOUDFLARE_API_TOKEN" ]; then
    echo -e "${YELLOW}⚠️ 未设置CLOUDFLARE_API_TOKEN${NC}"
    echo -e "${YELLOW}💡 可以跳过API测试，仅进行基础连接测试${NC}"
    API_TEST=false
else
    echo -e "${GREEN}✅ CLOUDFLARE_API_TOKEN已设置${NC}"
    API_TEST=true
fi

if [ -z "$CLOUDFLARE_ZONE_ID" ]; then
    echo -e "${YELLOW}⚠️ 未设置CLOUDFLARE_ZONE_ID${NC}"
    ZONE_TEST=false
else
    echo -e "${GREEN}✅ CLOUDFLARE_ZONE_ID已设置${NC}"
    ZONE_TEST=true
fi

echo ""

# 测试DNS解析
echo -e "${YELLOW}🌐 测试DNS解析...${NC}"

# 测试主域名
if nslookup imagent.top &> /dev/null; then
    echo -e "${GREEN}✅ imagent.top DNS解析正常${NC}"
    
    # 获取IP地址
    DOMAIN_IP=$(nslookup imagent.top | grep -A 1 "Name:" | tail -1 | awk '{print $2}')
    echo -e "${CYAN}   IP地址: $DOMAIN_IP${NC}"
    
    # 检查是否为Cloudflare IP
    if [[ $DOMAIN_IP =~ ^104\.|^108\.|^141\.|^162\.|^172\.|^188\.|^190\.|^197\.|^198\. ]]; then
        echo -e "${GREEN}✅ 使用Cloudflare IP地址${NC}"
    else
        echo -e "${YELLOW}⚠️ 可能未使用Cloudflare代理${NC}"
    fi
else
    echo -e "${RED}❌ imagent.top DNS解析失败${NC}"
fi

# 测试www子域名
if nslookup www.imagent.top &> /dev/null; then
    echo -e "${GREEN}✅ www.imagent.top DNS解析正常${NC}"
else
    echo -e "${RED}❌ www.imagent.top DNS解析失败${NC}"
fi

echo ""

# 测试HTTP/HTTPS连接
echo -e "${YELLOW}🔗 测试HTTP/HTTPS连接...${NC}"

# 测试HTTP连接
HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://imagent.top 2>/dev/null || echo "000")
if [ "$HTTP_STATUS" = "200" ] || [ "$HTTP_STATUS" = "301" ] || [ "$HTTP_STATUS" = "302" ]; then
    echo -e "${GREEN}✅ HTTP连接正常 (状态码: $HTTP_STATUS)${NC}"
else
    echo -e "${RED}❌ HTTP连接失败 (状态码: $HTTP_STATUS)${NC}"
fi

# 测试HTTPS连接
HTTPS_STATUS=$(curl -s -o /dev/null -w "%{http_code}" https://imagent.top 2>/dev/null || echo "000")
if [ "$HTTPS_STATUS" = "200" ]; then
    echo -e "${GREEN}✅ HTTPS连接正常 (状态码: $HTTPS_STATUS)${NC}"
else
    echo -e "${RED}❌ HTTPS连接失败 (状态码: $HTTPS_STATUS)${NC}"
fi

echo ""

# 测试Cloudflare特性
echo -e "${YELLOW}☁️ 测试Cloudflare特性...${NC}"

# 检查Cloudflare Headers
CF_HEADERS=$(curl -s -I https://imagent.top 2>/dev/null | grep -i "cf-" || echo "")
if [ -n "$CF_HEADERS" ]; then
    echo -e "${GREEN}✅ 检测到Cloudflare Headers${NC}"
    echo -e "${CYAN}   $CF_HEADERS${NC}"
else
    echo -e "${YELLOW}⚠️ 未检测到Cloudflare Headers${NC}"
fi

# 检查SSL证书
SSL_INFO=$(echo | openssl s_client -connect imagent.top:443 -servername imagent.top 2>/dev/null | openssl x509 -noout -issuer 2>/dev/null || echo "")
if echo "$SSL_INFO" | grep -q "Cloudflare"; then
    echo -e "${GREEN}✅ 使用Cloudflare SSL证书${NC}"
else
    echo -e "${YELLOW}⚠️ 未使用Cloudflare SSL证书${NC}"
fi

echo ""

# 性能测试
echo -e "${YELLOW}⚡ 性能测试...${NC}"

# 测试响应时间
RESPONSE_TIME=$(curl -s -o /dev/null -w "%{time_total}" https://imagent.top 2>/dev/null || echo "0")
if [ "$RESPONSE_TIME" != "0" ]; then
    echo -e "${GREEN}✅ 响应时间: ${RESPONSE_TIME}s${NC}"
    
    # 判断性能等级
    if (( $(echo "$RESPONSE_TIME < 1.0" | bc -l) )); then
        echo -e "${GREEN}   🚀 性能优秀${NC}"
    elif (( $(echo "$RESPONSE_TIME < 2.0" | bc -l) )); then
        echo -e "${YELLOW}   ⚡ 性能良好${NC}"
    else
        echo -e "${RED}   🐌 性能需要优化${NC}"
    fi
else
    echo -e "${RED}❌ 无法测试响应时间${NC}"
fi

echo ""

# API测试（如果配置了API Token）
if [ "$API_TEST" = true ] && [ "$ZONE_TEST" = true ]; then
    echo -e "${YELLOW}🔧 测试Cloudflare API...${NC}"
    
    # 测试API连接
    API_RESPONSE=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$CLOUDFLARE_ZONE_ID" \
        -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
        -H "Content-Type: application/json" 2>/dev/null || echo "")
    
    if echo "$API_RESPONSE" | jq -r '.success' 2>/dev/null | grep -q "true"; then
        echo -e "${GREEN}✅ Cloudflare API连接正常${NC}"
        
        # 获取域名信息
        DOMAIN_NAME=$(echo "$API_RESPONSE" | jq -r '.result.name' 2>/dev/null)
        DOMAIN_STATUS=$(echo "$API_RESPONSE" | jq -r '.result.status' 2>/dev/null)
        echo -e "${CYAN}   域名: $DOMAIN_NAME${NC}"
        echo -e "${CYAN}   状态: $DOMAIN_STATUS${NC}"
        
        # 获取DNS记录
        DNS_RECORDS=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$CLOUDFLARE_ZONE_ID/dns_records" \
            -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
            -H "Content-Type: application/json" 2>/dev/null || echo "")
        
        if [ -n "$DNS_RECORDS" ]; then
            RECORD_COUNT=$(echo "$DNS_RECORDS" | jq -r '.result | length' 2>/dev/null)
            echo -e "${CYAN}   DNS记录数: $RECORD_COUNT${NC}"
        fi
    else
        echo -e "${RED}❌ Cloudflare API连接失败${NC}"
    fi
else
    echo -e "${YELLOW}⚠️ 跳过API测试（未配置API Token或Zone ID）${NC}"
fi

echo ""

# 生成测试报告
echo -e "${GREEN}📊 测试报告${NC}"
echo "=================================="

# 计算总分
SCORE=0
TOTAL_TESTS=6

# DNS解析测试
if nslookup imagent.top &> /dev/null; then
    SCORE=$((SCORE + 1))
fi

# HTTP连接测试
if [ "$HTTP_STATUS" = "200" ] || [ "$HTTP_STATUS" = "301" ] || [ "$HTTP_STATUS" = "302" ]; then
    SCORE=$((SCORE + 1))
fi

# HTTPS连接测试
if [ "$HTTPS_STATUS" = "200" ]; then
    SCORE=$((SCORE + 1))
fi

# Cloudflare Headers测试
if [ -n "$CF_HEADERS" ]; then
    SCORE=$((SCORE + 1))
fi

# SSL证书测试
if echo "$SSL_INFO" | grep -q "Cloudflare"; then
    SCORE=$((SCORE + 1))
fi

# 性能测试
if [ "$RESPONSE_TIME" != "0" ] && (( $(echo "$RESPONSE_TIME < 2.0" | bc -l) )); then
    SCORE=$((SCORE + 1))
fi

# 显示评分
PERCENTAGE=$((SCORE * 100 / TOTAL_TESTS))
echo -e "${CYAN}测试得分: $SCORE/$TOTAL_TESTS ($PERCENTAGE%)${NC}"

if [ $PERCENTAGE -ge 80 ]; then
    echo -e "${GREEN}🎉 配置优秀！Cloudflare工作正常${NC}"
elif [ $PERCENTAGE -ge 60 ]; then
    echo -e "${YELLOW}⚠️ 配置良好，但还有优化空间${NC}"
else
    echo -e "${RED}❌ 配置需要检查，请查看上述错误信息${NC}"
fi

echo ""
echo -e "${YELLOW}💡 优化建议：${NC}"
echo -e "${YELLOW}   - 确保域名使用Cloudflare代理（橙色云朵）${NC}"
echo -e "${YELLOW}   - 检查SSL/TLS设置为Flexible模式${NC}"
echo -e "${YELLOW}   - 启用Always Use HTTPS${NC}"
echo -e "${YELLOW}   - 配置适当的缓存规则${NC}"
echo ""
echo -e "${GREEN}✨ 测试完成！${NC}"



