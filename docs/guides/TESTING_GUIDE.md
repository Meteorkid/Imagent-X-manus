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
