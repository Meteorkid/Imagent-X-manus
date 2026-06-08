#!/bin/bash

# ImagentX 测试运行脚本

set -e

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🧪 ImagentX 测试套件${NC}"

case "$1" in
    unit)
        echo -e "${BLUE}运行单元测试...${NC}"
        cd ImagentX
        mvn test -Dtest="**/*Test" -DfailIfNoTests=false
        ;;
    integration)
        echo -e "${BLUE}运行集成测试...${NC}"
        cd ImagentX
        mvn test -Dtest="**/*IntegrationTest" -DfailIfNoTests=false
        ;;
    e2e)
        echo -e "${BLUE}运行端到端测试...${NC}"
        cd imagentx-frontend-plus
        npm run test:e2e
        ;;
    coverage)
        echo -e "${BLUE}生成测试覆盖率报告...${NC}"
        cd ImagentX
        mvn jacoco:report
        echo -e "${GREEN}覆盖率报告已生成: target/site/jacoco/index.html${NC}"
        ;;
    all)
        echo -e "${BLUE}运行所有测试...${NC}"
        ./run-tests.sh unit
        ./run-tests.sh integration
        ./run-tests.sh coverage
        ;;
    frontend)
        echo -e "${BLUE}运行前端测试...${NC}"
        cd imagentx-frontend-plus
        npm test -- --coverage --watchAll=false
        ;;
    performance)
        echo -e "${BLUE}运行性能测试...${NC}"
        cd integration-tests/performance
        mvn test -Dtest="PerformanceTest"
        ;;
    help)
        echo "ImagentX 测试套件"
        echo ""
        echo "用法: $0 {unit|integration|e2e|coverage|all|frontend|performance|help}"
        echo ""
        echo "命令:"
        echo "  unit        - 运行单元测试"
        echo "  integration - 运行集成测试"
        echo "  e2e         - 运行端到端测试"
        echo "  coverage    - 生成覆盖率报告"
        echo "  all         - 运行所有测试"
        echo "  frontend    - 运行前端测试"
        echo "  performance - 运行性能测试"
        echo "  help        - 显示帮助信息"
        ;;
    *)
        echo "用法: $0 {unit|integration|e2e|coverage|all|frontend|performance|help}"
        exit 1
        ;;
esac
