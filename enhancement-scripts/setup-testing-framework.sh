#!/bin/bash

# ImagentX 测试体系设置脚本
# 用于建立完整的测试框架，提升代码质量到80%+覆盖率

set -e

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # 无颜色

echo -e "${BLUE}🧪 设置ImagentX测试体系...${NC}"

# 检查Java和Maven环境
check_environment() {
    echo -e "${BLUE}🔍 检查开发环境...${NC}"
    
    # 检查Java版本
    if java -version 2>&1 | grep -q "version \"17"; then
        echo -e "${GREEN}✅ Java 17 已安装${NC}"
    else
        echo -e "${RED}❌ 需要Java 17，当前版本:${NC}"
        java -version
        exit 1
    fi
    
    # 检查Maven
    if mvn -version >/dev/null 2>&1; then
        echo -e "${GREEN}✅ Maven 已安装${NC}"
    else
        echo -e "${RED}❌ Maven 未安装${NC}"
        exit 1
    fi
}

# 创建测试目录结构
create_test_structure() {
    echo -e "${BLUE}📁 创建测试目录结构...${NC}"
    
    # 后端测试目录
    mkdir -p ImagentX/src/test/java/org/xhy/{application,domain,infrastructure}
    mkdir -p ImagentX/src/test/resources/{test-data,test-config}
    
    # 前端测试目录
    mkdir -p imagentx-frontend-plus/{__tests__,cypress}
    mkdir -p imagentx-frontend-plus/cypress/{e2e,fixtures,support}
    
    # 集成测试目录
    mkdir -p integration-tests/{api,ui,performance}
    
    echo -e "${GREEN}✅ 测试目录结构创建完成${NC}"
}

# 创建后端测试配置
create_backend_test_config() {
    echo -e "${BLUE}⚙️  创建后端测试配置...${NC}"
    
    # 创建测试配置文件
    cat > ImagentX/src/test/resources/application-test.yml << 'EOF'
# 测试环境配置
spring:
  profiles:
    active: test
  
  datasource:
    url: jdbc:h2:mem:testdb;DB_CLOSE_DELAY=-1;DB_CLOSE_ON_EXIT=FALSE
    driver-class-name: org.h2.Driver
    username: sa
    password: 
  
  jpa:
    hibernate:
      ddl-auto: create-drop
    show-sql: true
    properties:
      hibernate:
        format_sql: true
  
  cache:
    type: simple
  
  rabbitmq:
    host: localhost
    port: 5672
    username: guest
    password: guest

# 测试配置
test:
  mock:
    enabled: true
  database:
    cleanup: true
  api:
    base-url: http://localhost:8088/api
    timeout: 5000

# 日志配置
logging:
  level:
    org.xhy: DEBUG
    org.springframework: INFO
    org.hibernate: INFO
EOF

    # 创建测试数据
    cat > ImagentX/src/test/resources/test-data/init.sql << 'EOF'
-- 测试数据初始化脚本

-- 用户测试数据
INSERT INTO users (id, username, email, password, status, created_at, updated_at) VALUES
(1, 'testuser1', 'test1@example.com', '$2a$10$test', 'ACTIVE', NOW(), NOW()),
(2, 'testuser2', 'test2@example.com', '$2a$10$test', 'ACTIVE', NOW(), NOW()),
(3, 'admin', 'admin@imagentx.ai', '$2a$10$test', 'ACTIVE', NOW(), NOW());

-- Agent测试数据
INSERT INTO agents (id, name, description, model, status, created_by, created_at, updated_at) VALUES
(1, 'Test Agent 1', '测试Agent 1', 'gpt-3.5-turbo', 'PUBLISHED', 1, NOW(), NOW()),
(2, 'Test Agent 2', '测试Agent 2', 'gpt-4', 'DRAFT', 1, NOW(), NOW());

-- 工具测试数据
INSERT INTO tools (id, name, description, type, status, created_by, created_at, updated_at) VALUES
(1, 'Test Tool 1', '测试工具 1', 'FUNCTION', 'PUBLISHED', 1, NOW(), NOW()),
(2, 'Test Tool 2', '测试工具 2', 'API', 'DRAFT', 1, NOW(), NOW());
EOF

    echo -e "${GREEN}✅ 后端测试配置创建完成${NC}"
}

# 创建单元测试模板
create_unit_test_templates() {
    echo -e "${BLUE}📝 创建单元测试模板...${NC}"
    
    # 创建Service层测试模板
    cat > ImagentX/src/test/java/org/xhy/application/BaseServiceTest.java << 'EOF'
package org.xhy.application;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.test.context.ActiveProfiles;

/**
 * 服务层测试基类
 */
@ExtendWith(MockitoExtension.class)
@ActiveProfiles("test")
public abstract class BaseServiceTest {
    
    @BeforeEach
    void setUp() {
        // 通用测试设置
    }
    
    /**
     * 创建测试用户
     */
    protected User createTestUser() {
        User user = new User();
        user.setId(1L);
        user.setUsername("testuser");
        user.setEmail("test@example.com");
        user.setStatus(UserStatus.ACTIVE);
        return user;
    }
    
    /**
     * 创建测试Agent
     */
    protected Agent createTestAgent() {
        Agent agent = new Agent();
        agent.setId(1L);
        agent.setName("Test Agent");
        agent.setDescription("Test Description");
        agent.setModel("gpt-3.5-turbo");
        agent.setStatus(AgentStatus.PUBLISHED);
        return agent;
    }
}
EOF

    # 创建Controller层测试模板
    cat > ImagentX/src/test/java/org/xhy/application/BaseControllerTest.java << 'EOF'
package org.xhy.application;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.BeforeEach;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureWebMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;
import org.springframework.web.context.WebApplicationContext;

/**
 * Controller层测试基类
 */
@SpringBootTest
@AutoConfigureWebMvc
@ActiveProfiles("test")
public abstract class BaseControllerTest {
    
    @Autowired
    protected WebApplicationContext webApplicationContext;
    
    @Autowired
    protected ObjectMapper objectMapper;
    
    protected MockMvc mockMvc;
    
    @BeforeEach
    void setUp() {
        mockMvc = MockMvcBuilders
            .webAppContextSetup(webApplicationContext)
            .build();
    }
    
    /**
     * 创建测试用户Token
     */
    protected String createTestToken() {
        // 这里应该创建JWT token用于测试
        return "test-token";
    }
}
EOF

    # 创建Repository层测试模板
    cat > ImagentX/src/test/java/org/xhy/infrastructure/BaseRepositoryTest.java << 'EOF'
package org.xhy.infrastructure;

import org.junit.jupiter.api.BeforeEach;
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.transaction.annotation.Transactional;

/**
 * Repository层测试基类
 */
@DataJpaTest
@ActiveProfiles("test")
@Transactional
public abstract class BaseRepositoryTest {
    
    @BeforeEach
    void setUp() {
        // 数据库测试设置
    }
    
    /**
     * 清理测试数据
     */
    protected void cleanTestData() {
        // 清理测试数据的逻辑
    }
}
EOF

    echo -e "${GREEN}✅ 单元测试模板创建完成${NC}"
}

# 创建集成测试配置
create_integration_test_config() {
    echo -e "${BLUE}🔗 创建集成测试配置...${NC}"
    
    # 创建API集成测试
    cat > integration-tests/api/ApiIntegrationTest.java << 'EOF'
package integration.tests.api;

import io.restassured.RestAssured;
import io.restassured.http.ContentType;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.server.LocalServerPort;
import org.springframework.test.context.ActiveProfiles;

import static io.restassured.RestAssured.given;
import static org.hamcrest.Matchers.*;

/**
 * API集成测试
 */
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@ActiveProfiles("test")
public class ApiIntegrationTest {
    
    @LocalServerPort
    private int port;
    
    @BeforeAll
    static void setUp() {
        RestAssured.enableLoggingOfRequestAndResponseIfValidationFails();
    }
    
    @Test
    void testHealthCheck() {
        given()
            .port(port)
        .when()
            .get("/api/health")
        .then()
            .statusCode(200)
            .body("code", equalTo(200))
            .body("message", equalTo("ok"));
    }
    
    @Test
    void testAgentList() {
        given()
            .port(port)
            .header("Authorization", "Bearer test-token")
        .when()
            .get("/api/agents/published")
        .then()
            .statusCode(200)
            .body("code", equalTo(200));
    }
}
EOF

    # 创建性能测试
    cat > integration-tests/performance/PerformanceTest.java << 'EOF'
package integration.tests.performance;

import io.restassured.RestAssured;
import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.server.LocalServerPort;
import org.springframework.test.context.ActiveProfiles;

import java.util.concurrent.TimeUnit;

import static io.restassured.RestAssured.given;
import static org.hamcrest.Matchers.lessThan;

/**
 * 性能测试
 */
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@ActiveProfiles("test")
public class PerformanceTest {
    
    @LocalServerPort
    private int port;
    
    @Test
    void testHealthCheckPerformance() {
        given()
            .port(port)
        .when()
            .get("/api/health")
        .then()
            .time(lessThan(200L), TimeUnit.MILLISECONDS)
            .statusCode(200);
    }
    
    @Test
    void testConcurrentRequests() {
        // 并发测试逻辑
        // 这里可以使用多线程或专门的并发测试工具
    }
}
EOF

    echo -e "${GREEN}✅ 集成测试配置创建完成${NC}"
}

# 创建前端测试配置
create_frontend_test_config() {
    echo -e "${BLUE}🎨 创建前端测试配置...${NC}"
    
    # 创建Jest配置
    cat > imagentx-frontend-plus/jest.config.js << 'EOF'
const nextJest = require('next/jest')

const createJestConfig = nextJest({
  // Provide the path to your Next.js app to load next.config.js and .env files
  dir: './',
})

// Add any custom config to be passed to Jest
const customJestConfig = {
  setupFilesAfterEnv: ['<rootDir>/jest.setup.js'],
  testEnvironment: 'jest-environment-jsdom',
  moduleNameMapping: {
    '^@/(.*)$': '<rootDir>/$1',
  },
  collectCoverageFrom: [
    'src/**/*.{js,jsx,ts,tsx}',
    '!src/**/*.d.ts',
    '!src/**/*.stories.{js,jsx,ts,tsx}',
  ],
  coverageThreshold: {
    global: {
      branches: 80,
      functions: 80,
      lines: 80,
      statements: 80,
    },
  },
}

// createJestConfig is exported this way to ensure that next/jest can load the Next.js config which is async
module.exports = createJestConfig(customJestConfig)
EOF

    # 创建Jest设置文件
    cat > imagentx-frontend-plus/jest.setup.js << 'EOF'
import '@testing-library/jest-dom'

// Mock Next.js router
jest.mock('next/router', () => ({
  useRouter() {
    return {
      route: '/',
      pathname: '/',
      query: {},
      asPath: '/',
      push: jest.fn(),
      pop: jest.fn(),
      reload: jest.fn(),
      back: jest.fn(),
      prefetch: jest.fn().mockResolvedValue(undefined),
      beforePopState: jest.fn(),
      events: {
        on: jest.fn(),
        off: jest.fn(),
        emit: jest.fn(),
      },
      isFallback: false,
    }
  },
}))

// Mock fetch
global.fetch = jest.fn()

// Mock localStorage
const localStorageMock = {
  getItem: jest.fn(),
  setItem: jest.fn(),
  removeItem: jest.fn(),
  clear: jest.fn(),
}
global.localStorage = localStorageMock
EOF

    # 创建Cypress配置
    cat > imagentx-frontend-plus/cypress.config.js << 'EOF'
const { defineConfig } = require('cypress')

module.exports = defineConfig({
  e2e: {
    baseUrl: 'http://localhost:3000',
    supportFile: 'cypress/support/e2e.js',
    specPattern: 'cypress/e2e/**/*.cy.{js,jsx,ts,tsx}',
    video: false,
    screenshotOnRunFailure: true,
    defaultCommandTimeout: 10000,
    viewportWidth: 1280,
    viewportHeight: 720,
  },
  component: {
    devServer: {
      framework: 'next',
      bundler: 'webpack',
    },
  },
})
EOF

    # 创建示例E2E测试
    cat > imagentx-frontend-plus/cypress/e2e/login.cy.js << 'EOF'
describe('Login Page', () => {
  beforeEach(() => {
    cy.visit('/login')
  })

  it('should display login form', () => {
    cy.get('[data-testid=login-form]').should('be.visible')
    cy.get('[data-testid=email-input]').should('be.visible')
    cy.get('[data-testid=password-input]').should('be.visible')
    cy.get('[data-testid=login-button]').should('be.visible')
  })

  it('should login with valid credentials', () => {
    cy.get('[data-testid=email-input]').type('admin@imagentx.ai')
    cy.get('[data-testid=password-input]').type('admin123')
    cy.get('[data-testid=login-button]').click()
    
    // 验证登录成功
    cy.url().should('include', '/dashboard')
    cy.get('[data-testid=user-menu]').should('be.visible')
  })

  it('should show error with invalid credentials', () => {
    cy.get('[data-testid=email-input]').type('invalid@example.com')
    cy.get('[data-testid=password-input]').type('wrongpassword')
    cy.get('[data-testid=login-button]').click()
    
    // 验证错误信息
    cy.get('[data-testid=error-message]').should('be.visible')
  })
})
EOF

    echo -e "${GREEN}✅ 前端测试配置创建完成${NC}"
}

# 创建测试脚本
create_test_scripts() {
    echo -e "${BLUE}📜 创建测试脚本...${NC}"
    
    # 创建测试运行脚本
    cat > run-tests.sh << 'EOF'
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
EOF

    chmod +x run-tests.sh
    
    echo -e "${GREEN}✅ 测试脚本创建完成${NC}"
}

# 更新Maven配置
update_maven_config() {
    echo -e "${BLUE}📦 更新Maven配置...${NC}"
    
    # 检查pom.xml是否存在
    if [ ! -f "ImagentX/pom.xml" ]; then
        echo -e "${YELLOW}⚠️  pom.xml不存在，跳过Maven配置更新${NC}"
        return
    fi
    
    # 添加测试依赖到pom.xml
    cat >> ImagentX/pom.xml << 'EOF'

    <!-- 测试依赖 -->
    <dependencies>
        <!-- JUnit 5 -->
        <dependency>
            <groupId>org.junit.jupiter</groupId>
            <artifactId>junit-jupiter</artifactId>
            <scope>test</scope>
        </dependency>
        
        <!-- Mockito -->
        <dependency>
            <groupId>org.mockito</groupId>
            <artifactId>mockito-core</artifactId>
            <scope>test</scope>
        </dependency>
        <dependency>
            <groupId>org.mockito</groupId>
            <artifactId>mockito-junit-jupiter</artifactId>
            <scope>test</scope>
        </dependency>
        
        <!-- Spring Boot Test -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-test</artifactId>
            <scope>test</scope>
        </dependency>
        
        <!-- TestContainers -->
        <dependency>
            <groupId>org.testcontainers</groupId>
            <artifactId>junit-jupiter</artifactId>
            <scope>test</scope>
        </dependency>
        <dependency>
            <groupId>org.testcontainers</groupId>
            <artifactId>postgresql</artifactId>
            <scope>test</scope>
        </dependency>
        
        <!-- H2 Database for Testing -->
        <dependency>
            <groupId>com.h2database</groupId>
            <artifactId>h2</artifactId>
            <scope>test</scope>
        </dependency>
        
        <!-- REST Assured -->
        <dependency>
            <groupId>io.rest-assured</groupId>
            <artifactId>rest-assured</artifactId>
            <scope>test</scope>
        </dependency>
        
        <!-- JaCoCo for Coverage -->
        <dependency>
            <groupId>org.jacoco</groupId>
            <artifactId>jacoco-maven-plugin</artifactId>
            <version>0.8.11</version>
            <scope>test</scope>
        </dependency>
    </dependencies>

    <build>
        <plugins>
            <!-- JaCoCo Plugin -->
            <plugin>
                <groupId>org.jacoco</groupId>
                <artifactId>jacoco-maven-plugin</artifactId>
                <version>0.8.11</version>
                <executions>
                    <execution>
                        <goals>
                            <goal>prepare-agent</goal>
                        </goals>
                    </execution>
                    <execution>
                        <id>report</id>
                        <phase>test</phase>
                        <goals>
                            <goal>report</goal>
                        </goals>
                    </execution>
                </executions>
            </plugin>
            
            <!-- Surefire Plugin -->
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-surefire-plugin</artifactId>
                <version>3.2.2</version>
                <configuration>
                    <includes>
                        <include>**/*Test.java</include>
                        <include>**/*Tests.java</include>
                    </includes>
                    <excludes>
                        <exclude>**/*IntegrationTest.java</exclude>
                    </excludes>
                </configuration>
            </plugin>
            
            <!-- Failsafe Plugin for Integration Tests -->
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-failsafe-plugin</artifactId>
                <version>3.2.2</version>
                <executions>
                    <execution>
                        <goals>
                            <goal>integration-test</goal>
                            <goal>verify</goal>
                        </goals>
                        <configuration>
                            <includes>
                                <include>**/*IntegrationTest.java</include>
                            </includes>
                        </configuration>
                    </execution>
                </executions>
            </plugin>
        </plugins>
    </build>
EOF

    echo -e "${GREEN}✅ Maven配置更新完成${NC}"
}

# 创建测试文档
create_test_documentation() {
    echo -e "${BLUE}📚 创建测试文档...${NC}"
    
    cat > TESTING_GUIDE.md << 'EOF'
# ImagentX 测试指南

## 概述

本文档介绍ImagentX项目的测试体系，包括单元测试、集成测试、端到端测试和性能测试。

## 测试架构

```
ImagentX/
├── src/
│   ├── main/java/          # 主代码
│   └── test/java/          # 测试代码
│       ├── application/    # 应用层测试
│       ├── domain/         # 领域层测试
│       └── infrastructure/ # 基础设施层测试
├── src/test/resources/     # 测试资源
└── integration-tests/      # 集成测试

imagentx-frontend-plus/
├── __tests__/             # 前端测试
├── cypress/               # E2E测试
└── jest.config.js         # Jest配置
```

## 测试类型

### 1. 单元测试 (Unit Tests)

**目标**: 测试单个方法或类的功能
**覆盖率要求**: 80%+
**工具**: JUnit 5 + Mockito

```bash
# 运行单元测试
./run-tests.sh unit

# 生成覆盖率报告
./run-tests.sh coverage
```

### 2. 集成测试 (Integration Tests)

**目标**: 测试组件间的交互
**工具**: Spring Boot Test + TestContainers

```bash
# 运行集成测试
./run-tests.sh integration
```

### 3. 端到端测试 (E2E Tests)

**目标**: 测试完整的用户流程
**工具**: Cypress

```bash
# 运行E2E测试
./run-tests.sh e2e
```

### 4. 性能测试 (Performance Tests)

**目标**: 测试系统性能指标
**工具**: JMeter + REST Assured

```bash
# 运行性能测试
./run-tests.sh performance
```

## 测试最佳实践

### 1. 测试命名规范

```java
// 测试类命名: {ClassName}Test
public class UserServiceTest {
    
    // 测试方法命名: should_{ExpectedBehavior}_when_{Condition}
    @Test
    void should_CreateUser_When_ValidUserData() {
        // 测试逻辑
    }
    
    @Test
    void should_ThrowException_When_InvalidEmail() {
        // 测试逻辑
    }
}
```

### 2. 测试结构 (AAA模式)

```java
@Test
void testUserCreation() {
    // Arrange (准备)
    User user = createTestUser();
    when(userRepository.save(any())).thenReturn(user);
    
    // Act (执行)
    User result = userService.createUser(user);
    
    // Assert (断言)
    assertThat(result).isNotNull();
    assertThat(result.getEmail()).isEqualTo(user.getEmail());
    verify(userRepository).save(user);
}
```

### 3. 测试数据管理

```java
// 使用@BeforeEach设置测试数据
@BeforeEach
void setUp() {
    testUser = createTestUser();
    testAgent = createTestAgent();
}

// 使用@AfterEach清理测试数据
@AfterEach
void tearDown() {
    // 清理测试数据
}
```

## 覆盖率要求

### 后端覆盖率目标

- **总体覆盖率**: 80%+
- **业务逻辑覆盖率**: 90%+
- **API接口覆盖率**: 85%+
- **数据库操作覆盖率**: 75%+

### 前端覆盖率目标

- **组件覆盖率**: 80%+
- **工具函数覆盖率**: 90%+
- **页面覆盖率**: 70%+

## 持续集成

### GitHub Actions配置

```yaml
name: Tests
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Set up JDK 17
        uses: actions/setup-java@v3
        with:
          java-version: '17'
      - name: Run tests
        run: ./run-tests.sh all
      - name: Upload coverage
        uses: codecov/codecov-action@v3
```

## 故障排除

### 常见问题

1. **测试失败**
   - 检查测试环境配置
   - 验证测试数据
   - 查看详细错误日志

2. **覆盖率不达标**
   - 添加缺失的测试用例
   - 检查测试质量
   - 优化测试策略

3. **性能测试超时**
   - 调整超时设置
   - 检查系统资源
   - 优化测试数据

## 测试工具

### 后端工具

- **JUnit 5**: 测试框架
- **Mockito**: Mock框架
- **Spring Boot Test**: 集成测试
- **TestContainers**: 容器化测试
- **JaCoCo**: 覆盖率工具
- **REST Assured**: API测试

### 前端工具

- **Jest**: 测试框架
- **React Testing Library**: 组件测试
- **Cypress**: E2E测试
- **Playwright**: 浏览器测试

## 总结

通过完善的测试体系，我们可以：

1. **提高代码质量**: 及早发现和修复问题
2. **增强系统稳定性**: 减少生产环境故障
3. **提升开发效率**: 快速验证功能正确性
4. **降低维护成本**: 减少回归测试工作量

建议定期运行测试套件，保持测试覆盖率在目标水平以上。
EOF

    echo -e "${GREEN}✅ 测试文档创建完成${NC}"
}

# 主函数
main() {
    echo -e "${BLUE}🔍 检查开发环境...${NC}"
    check_environment
    
    echo -e "${BLUE}📁 创建测试目录结构...${NC}"
    create_test_structure
    
    echo -e "${BLUE}⚙️  创建测试配置...${NC}"
    create_backend_test_config
    create_unit_test_templates
    create_integration_test_config
    create_frontend_test_config
    
    echo -e "${BLUE}📜 创建测试脚本...${NC}"
    create_test_scripts
    
    echo -e "${BLUE}📦 更新Maven配置...${NC}"
    update_maven_config
    
    echo -e "${BLUE}📚 创建测试文档...${NC}"
    create_test_documentation
    
    echo -e "${GREEN}🎉 测试体系设置完成！${NC}"
    echo -e "${BLUE}📊 使用以下命令运行测试:${NC}"
    echo -e "  ./run-tests.sh help    # 查看帮助"
    echo -e "  ./run-tests.sh unit    # 运行单元测试"
    echo -e "  ./run-tests.sh all     # 运行所有测试"
    echo -e ""
    echo -e "${YELLOW}📝 下一步:${NC}"
    echo -e "  1. 编写具体的测试用例"
    echo -e "  2. 运行测试验证覆盖率"
    echo -e "  3. 集成到CI/CD流程"
}

# 执行主函数
main "$@"
