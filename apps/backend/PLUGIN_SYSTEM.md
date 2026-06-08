# 🔌 插件系统架构

## 📋 概述

ImagentX 插件系统提供了一个可扩展的架构，允许开发者通过插件扩展平台功能。

## 🏗️ 架构设计

### 核心组件

```
┌─────────────────────────────────────────────────────────────┐
│                    插件系统架构                              │
├─────────────────────────────────────────────────────────────┤
│  PluginService (服务层)                                      │
│  ├── 安装/卸载插件                                           │
│  ├── 启用/禁用插件                                           │
│  └── 管理插件配置                                            │
├─────────────────────────────────────────────────────────────┤
│  PluginManager (管理层)                                      │
│  ├── 插件生命周期管理                                         │
│  ├── 插件实例管理                                            │
│  └── 插件依赖检查                                            │
├─────────────────────────────────────────────────────────────┤
│  PluginLoader (加载层)                                       │
│  ├── 插件类加载                                              │
│  ├── 插件验证                                               │
│  └── 插件元数据解析                                          │
├─────────────────────────────────────────────────────────────┤
│  PluginRepository (持久层)                                   │
│  ├── 插件信息存储                                            │
│  └── 插件状态管理                                            │
└─────────────────────────────────────────────────────────────┘
```

### 插件类型

| 类型 | 说明 | 使用场景 |
|------|------|----------|
| TOOL | 工具插件 | 提供额外的工具功能 |
| CONNECTOR | 连接器插件 | 连接外部服务（API、数据库等） |
| PROCESSOR | 处理器插件 | 数据处理和转换 |
| EXTENSION | 扩展插件 | 系统功能扩展 |
| UI | UI插件 | 用户界面扩展 |

### 插件生命周期

```
安装 → 加载 → 启用 → 运行 → 禁用 → 卸载
  │      │      │      │      │      │
  ▼      ▼      ▼      ▼      ▼      ▼
INSTALLED → LOADING → ENABLED → RUNNING → DISABLED → UNINSTALLING
```

## 📁 目录结构

```
plugins/
├── imagentx-plugin-hello/          # 插件目录
│   ├── plugin.yml                  # 插件配置文件
│   ├── plugin.jar                  # 插件JAR包
│   └── lib/                        # 插件依赖
├── imagentx-plugin-weather/        # 另一个插件
│   ├── plugin.yml
│   ├── plugin.jar
│   └── lib/
└── ...
```

## 📝 插件配置文件

### plugin.yml 示例

```yaml
id: imagentx-plugin-hello
name: Hello Plugin
version: 1.0.0
description: 一个简单的示例插件
author: ImagentX Team
type: extension
entryClass: com.example.HelloPlugin
minSystemVersion: 1.0.0
dependencies:
  - id: imagentx-plugin-core
    version: ">=1.0.0"
config:
  greeting: "Hello, World!"
  language: "en"
```

## 🔧 核心接口

### Plugin 接口

所有插件必须实现此接口：

```java
public interface Plugin {
    PluginInfo getPluginInfo();
    void initialize(PluginContext context);
    void start();
    void stop();
    void destroy();
}
```

### PluginContext 接口

提供插件运行环境：

```java
public interface PluginContext {
    PluginInfo getPluginInfo();
    Map<String, Object> getConfig();
    Path getDataDirectory();
    Logger getLogger();
    <T> T getService(Class<T> serviceClass);
    void publishEvent(Object event);
    void subscribeEvent(Class<?> eventType, EventListener listener);
}
```

### PluginLifecycle 接口

定义生命周期钩子：

```java
public interface PluginLifecycle {
    boolean onLoad();
    void afterLoad();
    boolean onEnable();
    void afterEnable();
    boolean onDisable();
    void afterDisable();
    boolean onUnload();
    void afterUnload();
}
```

## 🚀 使用示例

### 创建插件

```java
public class HelloPlugin implements Plugin, PluginLifecycle {
    private PluginContext context;
    private PluginInfo pluginInfo;

    @Override
    public PluginInfo getPluginInfo() {
        return pluginInfo;
    }

    @Override
    public void initialize(PluginContext context) {
        this.context = context;
        this.pluginInfo = loadPluginInfo();
        context.getLogger().info("Hello Plugin initialized");
    }

    @Override
    public void start() {
        String greeting = context.getConfigString("greeting", "Hello!");
        context.getLogger().info(greeting);
    }

    @Override
    public void stop() {
        context.getLogger().info("Hello Plugin stopped");
    }

    @Override
    public void destroy() {
        context.getLogger().info("Hello Plugin destroyed");
    }

    @Override
    public boolean onEnable() {
        // 启用前检查
        return true;
    }

    @Override
    public void afterEnable() {
        // 启用后处理
    }
}
```

### 使用插件服务

```java
@Service
public class MyService {
    private final PluginService pluginService;

    public MyService(PluginService pluginService) {
        this.pluginService = pluginService;
    }

    public void example() {
        // 安装插件
        PluginInfo plugin = pluginService.installFromFile(Paths.get("path/to/plugin.jar"));

        // 启用插件
        pluginService.enable(plugin.getId());

        // 获取插件配置
        Map<String, Object> config = pluginService.getConfig(plugin.getId());

        // 更新配置
        pluginService.updateConfig(plugin.getId(), Map.of("greeting", "Hi!"));
    }
}
```

## ⚙️ 配置

### application.yml 配置

```yaml
plugin:
  enabled: true
  directory: plugins
  config-directory: config/plugins
  log-directory: logs/plugins
  temp-directory: temp/plugins
  auto-load: true
  auto-enable: false
  max-parallel-load: 5
  load-timeout: 30
  unload-timeout: 10
  sandbox-enabled: true
  sandbox:
    restrict-file-access: true
    restrict-network-access: false
    restrict-system-calls: true
    restrict-memory: true
    max-memory: 256
    restrict-cpu: false
    max-cpu: 50
  global-config: {}
```

## 🔒 安全机制

### 沙箱隔离

- 文件系统访问限制
- 网络访问控制
- 系统调用过滤
- 内存使用限制
- CPU 使用限制

### 依赖检查

- 版本兼容性检查
- 循环依赖检测
- 缺失依赖检查

## 📊 监控和日志

### 插件日志

每个插件都有独立的日志文件：

```
logs/plugins/
├── imagentx-plugin-hello.log
├── imagentx-plugin-weather.log
└── ...
```

### 插件统计

```java
PluginStatistics stats = pluginService.getStatistics();
// totalPlugins: 总插件数
// enabledPlugins: 已启用插件数
// disabledPlugins: 已禁用插件数
// errorPlugins: 错误插件数
// pluginsByType: 按类型统计
```

## 🎯 最佳实践

### 插件开发

1. **单一职责**: 每个插件只做一件事
2. **松耦合**: 插件之间尽量减少依赖
3. **配置驱动**: 通过配置文件管理插件行为
4. **错误处理**: 完善的异常处理和日志记录
5. **资源清理**: 在 `destroy()` 中清理所有资源

### 插件配置

1. **默认值**: 为所有配置提供默认值
2. **类型安全**: 使用类型安全的配置访问
3. **验证**: 在初始化时验证配置
4. **文档**: 为配置项提供清晰的文档

### 插件安全

1. **最小权限**: 插件只请求必要的权限
2. **输入验证**: 验证所有外部输入
3. **敏感数据**: 不在日志中输出敏感信息
4. **依赖管理**: 定期更新依赖库

## 📚 相关文档

- [插件开发指南](PLUGIN_DEVELOPMENT_GUIDE.md)
- [插件API参考](PLUGIN_API_REFERENCE.md)
- [插件示例](PLUGIN_EXAMPLES.md)
