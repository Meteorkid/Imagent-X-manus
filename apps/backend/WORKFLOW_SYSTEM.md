# 🔄 工作流系统

## 📋 概述

ImagentX 工作流系统提供了一个强大的工作流引擎，支持可视化创建工作流和自动化执行。

## 🏗️ 架构设计

### 核心组件

```
┌─────────────────────────────────────────────────────────────┐
│                    工作流系统架构                              │
├─────────────────────────────────────────────────────────────┤
│  WorkflowService (服务层)                                     │
│  ├── 创建/更新/删除工作流                                      │
│  ├── 执行工作流                                               │
│  └── 管理执行记录                                             │
├─────────────────────────────────────────────────────────────┤
│  WorkflowEngine (引擎层)                                      │
│  ├── 解析工作流定义                                           │
│  ├── 执行工作流节点                                           │
│  └── 管理执行上下文                                           │
├─────────────────────────────────────────────────────────────┤
│  WorkflowRepository (持久层)                                  │
│  ├── 工作流存储                                               │
│  └── 执行记录存储                                             │
└─────────────────────────────────────────────────────────────┘
```

### 工作流节点类型

| 类型 | 说明 | 使用场景 |
|------|------|----------|
| START | 开始节点 | 工作流入口 |
| END | 结束节点 | 工作流出口 |
| TASK | 任务节点 | 执行具体任务 |
| CONDITION | 条件节点 | 条件分支 |
| PARALLEL | 并行节点 | 并行执行 |
| LOOP | 循环节点 | 循环执行 |
| HUMAN | 人工节点 | 人工审批 |
| SUBPROCESS | 子流程节点 | 调用子流程 |

### 工作流状态

```
草稿 → 已发布 → 已归档
  │      │
  └──────┴→ 已禁用
```

### 执行状态

```
等待执行 → 执行中 → 已完成
    │        │
    │        └→ 执行失败
    │
    └→ 已取消
    └→ 暂停中
```

## 📝 工作流定义格式

### JSON 格式

```json
{
  "id": "workflow-123",
  "name": "用户注册流程",
  "version": "1.0.0",
  "nodes": [
    {
      "id": "start",
      "name": "开始",
      "type": "start",
      "nextNodes": ["validate"]
    },
    {
      "id": "validate",
      "name": "验证用户信息",
      "type": "task",
      "config": {
        "handler": "validateUser",
        "params": {
          "email": "${input.email}",
          "password": "${input.password}"
        }
      },
      "nextNodes": ["check"]
    },
    {
      "id": "check",
      "name": "检查用户是否存在",
      "type": "condition",
      "config": {
        "condition": "${validate.result.exists} == false"
      },
      "nextNodes": {
        "true": ["create"],
        "false": ["error"]
      }
    },
    {
      "id": "create",
      "name": "创建用户",
      "type": "task",
      "config": {
        "handler": "createUser",
        "params": {
          "email": "${input.email}",
          "password": "${input.password}"
        }
      },
      "nextNodes": ["notify"]
    },
    {
      "id": "notify",
      "name": "发送欢迎邮件",
      "type": "task",
      "config": {
        "handler": "sendEmail",
        "params": {
          "to": "${input.email}",
          "template": "welcome"
        }
      },
      "nextNodes": ["end"]
    },
    {
      "id": "error",
      "name": "错误处理",
      "type": "task",
      "config": {
        "handler": "handleError"
      },
      "nextNodes": ["end"]
    },
    {
      "id": "end",
      "name": "结束",
      "type": "end"
    }
  ]
}
```

### YAML 格式

```yaml
id: workflow-123
name: 用户注册流程
version: 1.0.0
nodes:
  - id: start
    name: 开始
    type: start
    nextNodes:
      - validate

  - id: validate
    name: 验证用户信息
    type: task
    config:
      handler: validateUser
      params:
        email: ${input.email}
        password: ${input.password}
    nextNodes:
      - check

  - id: check
    name: 检查用户是否存在
    type: condition
    config:
      condition: "${validate.result.exists} == false"
    nextNodes:
      true:
        - create
      false:
        - error

  - id: create
    name: 创建用户
    type: task
    config:
      handler: createUser
      params:
        email: ${input.email}
        password: ${input.password}
    nextNodes:
      - notify

  - id: notify
    name: 发送欢迎邮件
    type: task
    config:
      handler: sendEmail
      params:
        to: ${input.email}
        template: welcome
    nextNodes:
      - end

  - id: error
    name: 错误处理
    type: task
    config:
      handler: handleError
    nextNodes:
      - end

  - id: end
    name: 结束
    type: end
```

## 🚀 使用示例

### 1. 创建工作流

```java
@Service
public class MyWorkflowService {
    private final WorkflowService workflowService;

    public void createRegistrationWorkflow() {
        Workflow workflow = new Workflow();
        workflow.setName("用户注册流程");
        workflow.setDescription("处理用户注册的自动化流程");
        workflow.setDefinition(workflowDefinitionJson);

        Workflow created = workflowService.createWorkflow(workflow);
        System.out.println("工作流已创建: " + created.getId());
    }
}
```

### 2. 执行工作流

```java
@Service
public class MyWorkflowService {
    private final WorkflowService workflowService;

    public void executeRegistration(String email, String password) {
        Map<String, Object> inputs = Map.of(
            "email", email,
            "password", password
        );

        WorkflowExecution execution = workflowService.executeWorkflow(
            "workflow-123", inputs
        );

        System.out.println("工作流已启动: " + execution.getId());
    }
}
```

### 3. 监控执行状态

```java
@Service
public class MyWorkflowService {
    private final WorkflowService workflowService;

    public void monitorExecution(String executionId) {
        WorkflowExecution execution = workflowService.getExecution(executionId);

        System.out.println("执行状态: " + execution.getStatus());
        System.out.println("当前节点: " + execution.getCurrentNodeId());
        System.out.println("执行日志: " + execution.getLogs());
    }
}
```

## 📊 执行流程

### 1. 工作流解析

```
JSON/YAML 定义 → 解析器 → 工作流对象 → 验证 → 可执行工作流
```

### 2. 工作流执行

```
开始节点 → 获取下一个节点 → 执行节点 → 检查结果 → 获取下一个节点 → ... → 结束节点
```

### 3. 节点执行

```
获取节点配置 → 准备输入参数 → 执行任务 → 获取输出参数 → 保存结果 → 返回下一步
```

## 🔧 配置

### application.yml 配置

```yaml
workflow:
  enabled: true
  definition-directory: workflows/definitions
  execution-directory: workflows/executions
  log-directory: workflows/logs
  max-concurrent-executions: 10
  execution-timeout: 3600
  retry-enabled: true
  retry-max-attempts: 3
  retry-delay: 1000
```

## 🎯 最佳实践

### 1. 工作流设计

- **单一职责**: 每个工作流只做一件事
- **清晰命名**: 节点名称要清晰表达其功能
- **错误处理**: 添加错误处理节点
- **日志记录**: 在关键节点添加日志

### 2. 节点设计

- **原子性**: 每个节点只做一件事
- **幂等性**: 节点执行应该是幂等的
- **超时控制**: 设置合理的超时时间
- **重试机制**: 对于可重试的操作添加重试

### 3. 错误处理

- **捕获异常**: 在节点中捕获所有异常
- **记录错误**: 记录详细的错误信息
- **通知机制**: 在失败时发送通知
- **恢复机制**: 提供手动恢复能力

## 📚 相关文档

- [工作流开发指南](WORKFLOW_DEVELOPMENT_GUIDE.md)
- [工作流 API 参考](WORKFLOW_API_REFERENCE.md)
- [工作流示例](WORKFLOW_EXAMPLES.md)
