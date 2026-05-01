# Imagent X Frontend Plus

## 项目概述

Imagent X的前端项目，基于Next.js开发。

## 技术栈

- Next.js
- React
- TypeScript
- Tailwind CSS
- Shadcn/ui

## API响应Toast提示功能

### 功能介绍

为了提升用户体验，我们在API请求成功或失败时会自动展示Toast消息。API响应的格式如下：

```typescript
{
    "code": 200,
    "message": "操作成功",
    "data": null,
    "timestamp": 1742872711904
}
```

### 使用方法

#### 1. 直接使用带Toast的API函数

```typescript
import { createSessionWithToast } from "@/lib/api-services";

// 在组件中使用
async function handleCreateSession() {
  try {
    // 自动处理成功/失败提示
    const response = await createSessionWithToast({ title: "新会话" });
    
    if (response.code === 200) {
      // 处理成功后的逻辑
    }
  } catch (error) {
    // 额外的错误处理（可选）
  }
}
```

#### 2. 使用handleApiResponse包装已有的接口响应

```typescript
import { handleApiResponse } from "@/lib/toast-utils";
import { createSession } from "@/lib/api-services";

async function handleCreateSession() {
  try {
    const response = await createSession({ title: "新会话" });
    
    // 手动处理Toast显示
    handleApiResponse(response, {
      successTitle: "自定义成功标题",
      errorTitle: "自定义错误标题"
    });
    
    if (response.code === 200) {
      // 处理成功后的逻辑
    }
  } catch (error) {
    // 错误处理
  }
}
```

#### 3. 使用withToast高阶函数包装自定义API函数

```typescript
import { withToast } from "@/lib/toast-utils";

// 自定义API函数
async function customApiCall(): Promise<ApiResponse<any>> {
  // 实现逻辑...
}

// 包装为带Toast的函数
const customApiCallWithToast = withToast(customApiCall, {
  successTitle: "自定义操作成功",
  errorTitle: "自定义操作失败"
});

// 使用
async function handleCustomAction() {
  const response = await customApiCallWithToast();
  // 处理逻辑...
}
```

### 配置选项

`handleApiResponse`和`withToast`函数支持以下配置选项：

- `showSuccessToast`: 是否显示成功提示，默认为`true`
- `showErrorToast`: 是否显示错误提示，默认为`true`
- `successTitle`: 成功提示的标题，默认为`"操作成功"`
- `errorTitle`: 错误提示的标题，默认为`"操作失败"`

### 注意事项

1. 对于不需要展示成功提示的API（如获取列表等），已经预设`showSuccessToast: false`
2. Toast会自动使用API响应中的`message`字段作为提示内容
3. 错误状态的Toast会使用红色样式

## 离线事件与配置审计（环境变量）

为启用 **PostgreSQL 持久化**（生产环境推荐），请配置：

- **`OFFLINE_EVENTS_DATABASE_URL`**（推荐）或 **`DATABASE_URL`**  
  用于离线埋点表、实验/SW 配置表及管理员审计表（`offline_admin_audit_logs`）等。
- 可选：**`OFFLINE_EVENTS_RETENTION_DAYS`**（默认 **30**）  
  用于控制埋点事件表 `offline_events` 的保留天数（定期清理）；审计日志不依赖该值。
- 可选：下载中心告警外发通道（Webhook/企业IM）
  - **`OFFLINE_ALERT_WEBHOOK_ENABLED`**：是否启用外发（默认 `true`）
  - **`OFFLINE_ALERT_WEBHOOK_URL`**：单个 Webhook 地址
  - **`OFFLINE_ALERT_WEBHOOK_URLS`**：多个 Webhook 地址，英文逗号分隔（优先于单个 URL）
  - **`OFFLINE_ALERT_WEBHOOK_PROVIDER`**：`generic` / `wecom` / `feishu` / `dingtalk`
  - **`OFFLINE_ALERT_WEBHOOK_MIN_LEVEL`**：`warn` / `critical`（默认 `critical`）
  - **`OFFLINE_ALERT_WEBHOOK_TIMEOUT_MS`**：请求超时毫秒（默认 `5000`）
  - **`OFFLINE_ALERT_RETRY_MAX_ATTEMPTS`**：最大尝试次数（含首次发送，默认 `3`）
  - **`OFFLINE_ALERT_RETRY_BASE_DELAY_MS`**：指数退避基准延迟（默认 `1200`）
  - **`OFFLINE_ALERT_RETRY_MAX_DELAY_MS`**：指数退避最大延迟（默认 `30000`）

未配置数据库时，埋点与审计可在内存中短期保留，不适合生产核对「谁改了配置」。