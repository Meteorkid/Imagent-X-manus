# 🧪 测试指南

## 📋 概述

本指南提供 ImagentX 项目的测试策略和流程。

## 🎯 测试目标

### 1. 测试覆盖率
- 单元测试覆盖率 > 80%
- 集成测试覆盖率 > 70%
- 端到端测试覆盖率 > 60%

### 2. 测试质量
- 测试用例有效性 > 95%
- 测试执行成功率 > 99%
- 测试维护成本 < 20%

### 3. 测试效率
- 测试执行时间 < 10 分钟
- 测试反馈时间 < 5 分钟
- 测试部署时间 < 10 分钟

## 📊 测试类型

### 1. 单元测试
**目标**: 测试单个函数或方法

**工具**:
- Java: JUnit 5 + Mockito
- TypeScript: Jest + React Testing Library

**示例**:
```java
// Java 单元测试
@Test
void shouldCreateUser() {
    // Given
    UserService userService = new UserService();
    UserDTO userDTO = new UserDTO("test@example.com", "password");
    
    // When
    User user = userService.createUser(userDTO);
    
    // Then
    assertNotNull(user);
    assertEquals("test@example.com", user.getEmail());
}
```

```typescript
// TypeScript 单元测试
describe('UserService', () => {
  it('should create user', () => {
    // Given
    const userService = new UserService();
    const userDTO = { email: 'test@example.com', password: 'password' };
    
    // When
    const user = userService.createUser(userDTO);
    
    // Then
    expect(user).toBeDefined();
    expect(user.email).toBe('test@example.com');
  });
});
```

### 2. 集成测试
**目标**: 测试模块之间的交互

**工具**:
- Java: Spring Boot Test
- TypeScript: Jest + Supertest

**示例**:
```java
// Java 集成测试
@SpringBootTest
@AutoConfigureMockMvc
class UserControllerIntegrationTest {
    
    @Autowired
    private MockMvc mockMvc;
    
    @Test
    void shouldCreateUser() throws Exception {
        // Given
        UserDTO userDTO = new UserDTO("test@example.com", "password");
        
        // When & Then
        mockMvc.perform(post("/api/users")
            .contentType(MediaType.APPLICATION_JSON)
            .content(objectMapper.writeValueAsString(userDTO)))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.email").value("test@example.com"));
    }
}
```

### 3. 端到端测试
**目标**: 测试完整的用户流程

**工具**:
- Playwright
- Cypress

**示例**:
```typescript
// Playwright 端到端测试
test('user can login', async ({ page }) => {
  // Given
  await page.goto('http://localhost:3000/login');
  
  // When
  await page.fill('[data-testid="email-input"]', 'test@example.com');
  await page.fill('[data-testid="password-input"]', 'password');
  await page.click('[data-testid="login-button"]');
  
  // Then
  await expect(page).toHaveURL('http://localhost:3000/dashboard');
});
```

### 4. 性能测试
**目标**: 测试系统性能

**工具**:
- JMeter
- Gatling
- k6

**示例**:
```javascript
// k6 性能测试
import http from 'k6/http';
import { check, sleep } from 'k6';

export const options = {
  vus: 10,
  duration: '30s',
};

export default function () {
  const res = http.get('http://localhost:8088/api/health');
  check(res, { 'status was 200': (r) => r.status == 200 });
  sleep(1);
}
```

## 🔧 测试流程

### 1. 测试计划
- 确定测试范围
- 制定测试策略
- 分配测试资源

### 2. 测试设计
- 编写测试用例
- 设计测试数据
- 准备测试环境

### 3. 测试执行
- 运行测试用例
- 记录测试结果
- 报告缺陷

### 4. 测试评估
- 分析测试结果
- 评估测试覆盖率
- 优化测试策略

## 📈 测试覆盖率

### 1. 覆盖率指标
- **行覆盖率**: 代码行被执行的比例
- **分支覆盖率**: 代码分支被执行的比例
- **函数覆盖率**: 函数被调用的比例
- **类覆盖率**: 类被实例化的比例

### 2. 覆盖率工具
- **Java**: JaCoCo
- **TypeScript**: Istanbul

### 3. 覆盖率报告
```bash
# Java
mvn jacoco:report

# TypeScript
npm run test:coverage
```

## 🎯 测试最佳实践

### 1. 测试原则
- **FIRST**: Fast, Independent, Repeatable, Self-validating, Timely
- **AAA**: Arrange, Act, Assert
- **DRY**: Don't Repeat Yourself

### 2. 测试命名
```java
// 好的命名
@Test
void shouldReturnUserWhenEmailExists() { }

// 不好的命名
@Test
void test1() { }
```

### 3. 测试数据
- 使用测试数据工厂
- 避免硬编码测试数据
- 清理测试数据

### 4. 测试维护
- 定期重构测试
- 删除过时的测试
- 更新测试文档

## 📊 测试报告

### 1. 测试结果
- 测试执行数量
- 测试通过率
- 测试失败原因

### 2. 覆盖率报告
- 覆盖率趋势
- 未覆盖代码
- 覆盖率目标

### 3. 性能报告
- 响应时间
- 吞吐量
- 资源使用

## 📞 获取帮助

如果您在测试过程中遇到问题，请：
1. 查看本文档
2. 搜索 [GitHub Issues](https://github.com/Meteorkid/Imagent-X-manus/issues)
3. 创建新的 Issue
4. 联系开发团队
