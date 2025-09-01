#!/bin/bash

# DNS配置检查脚本
# 用于验证域名DNS解析是否正确配置

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 域名配置
DOMAIN="imagentx.top"
WWW_DOMAIN="www.imagentx.top"

# 显示帮助信息
show_help() {
    echo -e "${BLUE}🌐 DNS配置检查脚本${NC}"
    echo "================================"
    echo -e "${GREEN}用法: ./check-dns.sh [选项]${NC}"
    echo ""
    echo -e "${CYAN}检查选项:${NC}"
    echo -e "  ${GREEN}--check${NC}        检查DNS解析"
    echo -e "  ${GREEN}--monitor${NC}      持续监控DNS解析"
    echo -e "  ${GREEN}--help${NC}         显示此帮助信息"
    echo ""
    echo -e "${CYAN}示例:${NC}"
    echo -e "  ./check-dns.sh --check      # 检查DNS解析"
    echo -e "  ./check-dns.sh --monitor    # 持续监控DNS解析"
    echo ""
}

# 检查命令是否存在
check_command() {
    if ! command -v $1 &> /dev/null; then
        echo -e "${YELLOW}⚠️  命令 $1 未安装，跳过相关检查${NC}"
        return 1
    fi
    return 0
}

# 使用nslookup检查DNS解析
check_nslookup() {
    echo -e "${CYAN}🔍 使用nslookup检查DNS解析...${NC}"
    
    if check_command nslookup; then
        echo -e "${BLUE}检查主域名: ${DOMAIN}${NC}"
        nslookup $DOMAIN
        
        echo -e "${BLUE}检查www子域名: ${WWW_DOMAIN}${NC}"
        nslookup $WWW_DOMAIN
    fi
}

# 使用dig检查DNS解析
check_dig() {
    echo -e "${CYAN}🔍 使用dig检查DNS解析...${NC}"
    
    if check_command dig; then
        echo -e "${BLUE}检查主域名: ${DOMAIN}${NC}"
        dig $DOMAIN +short
        
        echo -e "${BLUE}检查www子域名: ${WWW_DOMAIN}${NC}"
        dig $WWW_DOMAIN +short
    fi
}

# 使用curl检查HTTP响应
check_http() {
    echo -e "${CYAN}🌐 检查HTTP响应...${NC}"
    
    if check_command curl; then
        echo -e "${BLUE}检查主域名HTTP响应:${NC}"
        curl -I --connect-timeout 10 http://$DOMAIN 2>/dev/null || echo -e "${YELLOW}⚠️  HTTP访问失败（可能DNS未生效或服务未启动）${NC}"
        
        echo -e "${BLUE}检查www子域名HTTP响应:${NC}"
        curl -I --connect-timeout 10 http://$WWW_DOMAIN 2>/dev/null || echo -e "${YELLOW}⚠️  HTTP访问失败（可能DNS未生效或服务未启动）${NC}"
    fi
}

# 检查DNS服务器
check_dns_servers() {
    echo -e "${CYAN}🔧 检查DNS服务器配置...${NC}"
    
    echo -e "${BLUE}当前DNS服务器:${NC}"
    cat /etc/resolv.conf | grep nameserver
    
    echo -e "${BLUE}阿里云DNS服务器:${NC}"
    echo "dns27.hichina.com"
    echo "dns28.hichina.com"
}

# 检查本地DNS缓存
check_dns_cache() {
    echo -e "${CYAN}🗂️  检查本地DNS缓存...${NC}"
    
    if check_command systemd-resolve; then
        echo -e "${BLUE}刷新DNS缓存:${NC}"
        sudo systemd-resolve --flush-caches
        echo -e "${GREEN}✅ DNS缓存已刷新${NC}"
    elif check_command dscacheutil; then
        echo -e "${BLUE}刷新DNS缓存:${NC}"
        sudo dscacheutil -flushcache
        echo -e "${GREEN}✅ DNS缓存已刷新${NC}"
    else
        echo -e "${YELLOW}⚠️  无法刷新DNS缓存（请手动清除）${NC}"
    fi
}

# 检查端口连通性
check_ports() {
    echo -e "${CYAN}🔌 检查端口连通性...${NC}"
    
    if check_command nc; then
        # 获取解析的IP地址
        IP=$(dig +short $DOMAIN | head -1)
        if [ -n "$IP" ]; then
            echo -e "${BLUE}解析到的IP: ${IP}${NC}"
            echo -e "${BLUE}检查80端口:${NC}"
            nc -zv $IP 80 2>/dev/null && echo -e "${GREEN}✅ 80端口开放${NC}" || echo -e "${RED}❌ 80端口关闭${NC}"
            echo -e "${BLUE}检查443端口:${NC}"
            nc -zv $IP 443 2>/dev/null && echo -e "${GREEN}✅ 443端口开放${NC}" || echo -e "${RED}❌ 443端口关闭${NC}"
        else
            echo -e "${RED}❌ 无法解析域名IP地址${NC}"
        fi
    else
        echo -e "${YELLOW}⚠️  netcat未安装，跳过端口检查${NC}"
    fi
}

# 在线DNS查询
online_dns_check() {
    echo -e "${CYAN}🌍 在线DNS查询建议...${NC}"
    echo -e "${BLUE}您可以使用以下在线工具验证DNS解析:${NC}"
    echo -e "${CYAN}1. https://tool.chinaz.com/dns/${NC}"
    echo -e "${CYAN}2. https://dnschecker.org/${NC}"
    echo -e "${CYAN}3. https://www.whatsmydns.net/${NC}"
    echo ""
    echo -e "${YELLOW}在这些工具中输入域名: ${DOMAIN}${NC}"
}

# 执行完整检查
full_check() {
    echo -e "${BLUE}🌐 DNS配置完整检查${NC}"
    echo "=================================="
    
    check_dns_servers
    echo ""
    
    check_nslookup
    echo ""
    
    check_dig
    echo ""
    
    check_ports
    echo ""
    
    check_http
    echo ""
    
    online_dns_check
    echo ""
    
    echo -e "${GREEN}✅ DNS配置检查完成${NC}"
}

# 持续监控DNS解析
monitor_dns() {
    echo -e "${BLUE}📊 持续监控DNS解析${NC}"
    echo "=================================="
    echo -e "${YELLOW}按 Ctrl+C 停止监控${NC}"
    echo ""
    
    while true; do
        echo -e "${CYAN}[$(date '+%Y-%m-%d %H:%M:%S')] 检查DNS解析...${NC}"
        
        # 获取解析的IP
        IP=$(dig +short $DOMAIN | head -1)
        
        if [ -n "$IP" ]; then
            echo -e "${GREEN}✅ ${DOMAIN} -> ${IP}${NC}"
        else
            echo -e "${RED}❌ ${DOMAIN} -> 解析失败${NC}"
        fi
        
        # 等待30秒
        sleep 30
    done
}

# 主函数
main() {
    case "${1:-}" in
        --check)
            full_check
            ;;
        --monitor)
            monitor_dns
            ;;
        --help|*)
            show_help
            ;;
    esac
}

# 运行主函数
main "$@"
