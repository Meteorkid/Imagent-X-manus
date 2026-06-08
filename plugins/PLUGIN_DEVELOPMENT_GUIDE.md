# 🔌 插件开发指南

## 📋 概述

本指南介绍如何为 ImagentX 开发插件。

## 🚀 快速开始

### 1. 创建插件项目

```bash
# 创建插件目录
mkdir imagentx-plugin-myplugin
cd imagentx-plugin-myplugin

# 创建标准目录结构
mkdir -p src/main/java/com/imagentx/plugin/myplugin
mkdir -p src/main/resources
```

### 2. 创建插件配置文件

创建 `plugin.yml`：

```yaml
id: imagentx-plugin-myplugin
name: My Plugin
version: 1.0.0
description: 我的自定义插件
author: Your Name
type: extension
entryClass: com.imagentx.plugin.myplugin.MyPlugin
minSystemVersion: 1.0.0
dependencies: []
config:
  setting1: "default value"
  setting2: 123
```

### 3. 实现插件类

```java
package com.imagentx.plugin.myplugin;

import org.xhy.domain.plugin.Plugin;
import org.xhy.domain.plugin.PluginContext;
import org.xhy.domain.plugin.PluginLifecycle;
import org.xhy.domain.plugin.model.PluginInfo;

public class MyPlugin implements Plugin, PluginLifecycle {
    
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
        context.getLogger().info("My Plugin 初始化完成");
    }
    
    @Override
    public void start() {
        context.getLogger().info("My Plugin 启动");
        
        // 获取配置
        String setting1 = context.getConfigString("setting1", "default");
        
        // 注册服务
        context.registerService(MyService.class, new MyServiceImpl(context));
    }
    
    @Override
    public void stop() {
        context.getLogger().info("My Plugin 停止");
    }
    
    @Override
    public void destroy() {
        context.getLogger().info("My Plugin 销毁");
    }
    
    private PluginInfo loadPluginInfo() {
        PluginInfo info = new PluginInfo();
        info.setId("imagentx-plugin-myplugin");
        info.setName("My Plugin");
        info.setVersion("1.0.0");
        info.setDescription("我的自定义插件");
        info.setAuthor("Your Name");
        info.setType(org.xhy.domain.plugin.constant.PluginType.EXTENSION);
        info.setStatus(org.xhy.domain.plugin.constant.PluginStatus.ENABLED);
        info.setConfig(context.getConfig());
        return info;
    }
}
```

### 4. 构建插件

```bash
mvn clean package
```

### 5. 安装插件

将生成的 `imagentx-plugin-myplugin-1.0.0.jar` 复制到 ImagentX 的 `plugins` 目录。

## 📚 核心概念

### 插件接口

每个插件必须实现 `Plugin` 接口：

```java
public interface Plugin {
    PluginInfo getPluginInfo();      // 获取插件信息
    void initialize(PluginContext context);  // 初始化
    void start();                    // 启动
    void stop();                     // 停止
    void destroy();                  // 销毁
}
```

### 插件生命周期

```
安装 → 加载 → 启用 → 运行 → 禁用 → 卸载
  │      │      │      │      │      │
  ▼      ▼      ▼      ▼      ▼      ▼
INSTALLED → LOADING → ENABLED → RUNNING → DISABLED → UNINSTALLING
```

### 插件上下文

`PluginContext` 提供插件运行环境：

```java
public interface PluginContext {
    PluginInfo getPluginInfo();           // 获取插件信息
    Map<String, Object> getConfig();     // 获取配置
    Path getDataDirectory();             // 获取数据目录
    Logger getLogger();                  // 获取日志器
    <T> T getService(Class<T> serviceClass);  // 获取服务
    void registerService(Class<T> serviceClass, T service);  // 注册服务
    void publishEvent(Object event);     // 发布事件
    void subscribeEvent(Class<?> eventType, EventListener listener);  // 订阅事件
}
```

## 🔧 高级功能

### 1. 事件系统

```java
// 发布事件
context.publishEvent(new MyEvent("data"));

// 订阅事件
context.subscribeEvent(MyEvent.class, event -> {
    context.getLogger().info("收到事件: " + event.getData());
});
```

### 2. 服务注册

```java
// 注册服务
context.registerService(MyService.class, new MyServiceImpl());

// 获取服务
MyService service = context.getService(MyService.class);
```

### 3. 配置管理

```java
// 获取配置
String value = context.getConfigString("key", "default");
int number = (int) context.getConfig("number", 0);

// 更新配置（通过 PluginConfigManager）
context.getService(PluginConfigManager.class).setConfig(pluginId, "key", "newValue");
```

### 4. 文件操作

```java
// 获取插件数据目录
Path dataDir = context.getDataDirectory();

// 获取临时目录
Path tempDir = context.getTempDirectory();

// 获取日志目录
Path logDir = context.getLogDirectory();
```

## 📝 最佳实践

### 1. 错误处理

```java
@Override
public void start() {
    try {
        // 初始化代码
    } catch (Exception e) {
        context.getLogger().error("初始化失败", e);
        throw new RuntimeException("插件启动失败", e);
    }
}
```

### 2. 资源清理

```java
@Override
public void destroy() {
    // 清理资源
    if (connection != null) {
        connection.close();
    }
    if (executor != null) {
        executor.shutdown();
    }
}
```

### 3. 配置验证

```java
@Override
public void initialize(PluginContext context) {
    // 验证配置
    String required = context.getConfigString("required", null);
    if (required == null) {
        throw new IllegalArgumentException("缺少必需配置: required");
    }
}
```

### 4. 日志记录

```java
context.getLogger().info("普通日志");
context.getLogger().warn("警告日志");
context.getLogger().error("错误日志", exception);
```

## 🧪 测试插件

### 单元测试

```java
@Test
public void testInitialize() {
    PluginContext mockContext = mock(PluginContext.class);
    when(mockContext.getLogger()).thenReturn(LoggerFactory.getLogger("test"));
    when(mockContext.getConfig()).thenReturn(new HashMap<>());
    
    MyPlugin plugin = new MyPlugin();
    plugin.initialize(mockContext);
    
    assertNotNull(plugin.getPluginInfo());
}
```

### 集成测试

```java
@Test
public void testStartAndStop() {
    // 使用真实插件上下文
    PluginContext context = createTestContext();
    
    MyPlugin plugin = new MyPlugin();
    plugin.initialize(context);
    plugin.start();
    
    // 验证插件状态
    assertTrue(plugin.isRunning());
    
    plugin.stop();
    assertFalse(plugin.isRunning());
}
```

## 📦 发布插件

### 1. 打包插件

```bash
mvn clean package
```

### 2. 创建发布包

```bash
# 创建发布目录
mkdir release
cp target/imagentx-plugin-myplugin-1.0.0.jar release/
cp plugin.yml release/

# 打包
tar -czf imagentx-plugin-myplugin-1.0.0.tar.gz -C release .
```

### 3. 发布到仓库

```bash
# 上传到插件仓库
curl -X POST https://plugins.imagentx.top/api/plugins \
  -F "file=@imagentx-plugin-myplugin-1.0.0.tar.gz"
```

## 🔍 调试技巧

### 1. 启用调试日志

```yaml
# application.yml
logging:
  level:
    com.imagentx.plugin: DEBUG
```

### 2. 使用插件日志

```java
// 插件专用日志文件
context.getLogger().info("这会记录到插件日志文件");
```

### 3. 检查插件状态

```bash
# 查看插件列表
curl http://localhost:8088/api/plugins

# 查看插件日志
curl http://localhost:8088/api/plugins/{pluginId}/logs
```

## 📚 示例插件

参考 `plugins/imagentx-plugin-hello/` 目录中的示例插件。

## ❓ 常见问题

### Q: 插件加载失败怎么办？
A: 检查日志文件，常见原因：
- 依赖缺失
- 配置错误
- 版本不兼容

### Q: 如何调试插件？
A: 
1. 启用 DEBUG 日志级别
2. 使用插件专用日志
3. 检查系统日志

### Q: 插件如何访问数据库？
A: 通过 `context.getService()` 获取数据库服务。

### Q: 插件如何与其他插件通信？
A: 通过事件系统或服务注册。

## 📞 获取帮助

- 查看示例插件
- 阅读插件 API 文档
- 提交 Issue 到 GitHub
