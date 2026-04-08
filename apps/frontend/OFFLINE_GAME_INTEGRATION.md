# 🎮 ImagentX 离线游戏集成指南

## 📋 概述

本指南详细说明如何将离线小游戏集成到 ImagentX 前端应用中，实现网络故障时的自动游戏显示功能。

## 🚀 功能特性

### ✨ 核心功能
- **自动网络检测**: 每10秒自动检测网络状态
- **智能故障判断**: 连续2次检测失败后自动显示游戏
- **离线游戏**: 完全离线运行的外星人小男孩游戏
- **状态指示器**: 实时显示网络状态和操作按钮
- **手动控制**: 支持手动显示/隐藏游戏

### 🎯 使用场景
- 网络连接不稳定时
- 服务器暂时不可用时
- 用户主动选择离线模式时
- 网络完全断开时

## 🏗️ 技术架构

### 组件结构
```
OfflineGameProvider (根提供者)
├── useNetworkStatus (网络状态Hook)
├── NetworkStatusIndicator (状态指示器)
├── OfflineGame (游戏组件)
└── OfflineGameContext (上下文管理)
```

### 核心文件
- `hooks/useNetworkStatus.ts` - 网络状态检测Hook
- `components/offline/OfflineGameProvider.tsx` - 根提供者
- `components/offline/OfflineGame.tsx` - 游戏组件
- `components/offline/NetworkStatusIndicator.tsx` - 状态指示器
- `app/api/health/route.ts` - 健康检查API

## 📦 安装和配置

### 1. 复制游戏文件
```bash
# 将游戏引擎复制到公共目录
cp offline-dino/dino-game-fixed.js apps/frontend/public/offline-dino/
```

### 2. 更新应用提供者
在 `app/providers.tsx` 中添加 `OfflineGameProvider`:

```tsx
import OfflineGameProvider from "@/components/offline/OfflineGameProvider"

export function Providers({ children }: { children: React.ReactNode }) {
  return (
    <AccountProvider>
      <OfflineGameProvider>
        {children}
        <Toaster />
      </OfflineGameProvider>
    </AccountProvider>
  )
}
```

### 3. 创建健康检查API
确保 `app/api/health/route.ts` 文件存在并正确配置。

## 🎮 使用方法

### 基础使用

#### 在页面中使用网络状态指示器
```tsx
import { useOfflineGame } from '@/components/offline/OfflineGameProvider';

export default function MyPage() {
  const { NetworkStatusIndicator } = useOfflineGame();
  
  return (
    <div>
      <h1>我的页面</h1>
      <NetworkStatusIndicator className="ml-auto" />
    </div>
  );
}
```

#### 手动控制离线游戏
```tsx
import { useOfflineGame } from '@/components/offline/OfflineGameProvider';

export default function MyPage() {
  const { showOfflineGame, hideOfflineGame, isOfflineGameVisible } = useOfflineGame();
  
  return (
    <div>
      <button onClick={showOfflineGame}>显示游戏</button>
      <button onClick={hideOfflineGame}>隐藏游戏</button>
      <p>游戏状态: {isOfflineGameVisible ? '显示中' : '隐藏中'}</p>
    </div>
  );
}
```

### 高级配置

#### 自定义网络检测参数
```tsx
// 在 OfflineGameProvider 中自定义配置
const { shouldShowOfflineGame } = useNetworkStatus({
  checkInterval: 15000,    // 15秒检查一次
  timeout: 8000,          // 8秒超时
  maxRetries: 3,          // 3次失败后显示游戏
  healthCheckUrl: '/api/custom-health' // 自定义健康检查端点
});
```

#### 自定义游戏显示逻辑
```tsx
// 在 OfflineGameProvider 中自定义自动显示逻辑
React.useEffect(() => {
  if (shouldShowOfflineGame && !isOfflineGameVisible) {
    // 自定义延迟时间
    const timer = setTimeout(() => {
      showOfflineGame();
    }, 5000); // 5秒后显示
    
    return () => clearTimeout(timer);
  }
}, [shouldShowOfflineGame, isOfflineGameVisible, showOfflineGame]);
```

## 🔧 自定义和扩展

### 添加新的网络检测方法
```tsx
// 在 useNetworkStatus Hook 中添加自定义检测逻辑
const checkCustomNetworkStatus = useCallback(async () => {
  try {
    // 自定义网络检测逻辑
    const response = await fetch('/api/custom-endpoint');
    if (response.ok) {
      // 网络正常
    } else {
      // 网络异常
    }
  } catch (error) {
    // 处理错误
  }
}, []);
```

### 集成其他离线游戏
```tsx
// 在 OfflineGame 组件中添加游戏选择
const [selectedGame, setSelectedGame] = useState('dino');

const loadGameScript = async () => {
  const gameScripts = {
    dino: '/offline-dino/dino-game-fixed.js',
    puzzle: '/offline-puzzle/puzzle-game.js',
    arcade: '/offline-arcade/arcade-game.js'
  };
  
  const script = document.createElement('script');
  script.src = gameScripts[selectedGame];
  // ... 加载逻辑
};
```

## 📱 响应式设计

### 移动端优化
- 触摸友好的游戏控制
- 自适应屏幕尺寸
- 移动端手势支持

### 桌面端优化
- 键盘快捷键支持
- 鼠标操作优化
- 大屏幕显示优化

## 🧪 测试和调试

### 测试网络断开
```tsx
// 模拟网络断开
window.dispatchEvent(new Event('offline'));

// 模拟网络恢复
window.dispatchEvent(new Event('online'));
```

### 测试健康检查失败
```tsx
// 在浏览器控制台中模拟API失败
fetch('/api/health').then(() => {
  // 正常响应
}).catch(() => {
  // 模拟失败
});
```

### 调试网络状态
```tsx
// 在组件中监听网络状态变化
const { isOnline, errorCount, shouldShowOfflineGame } = useNetworkStatus();

useEffect(() => {
  console.log('网络状态:', { isOnline, errorCount, shouldShowOfflineGame });
}, [isOnline, errorCount, shouldShowOfflineGame]);
```

## 🚨 故障排除

### 常见问题

#### 游戏无法加载
- 检查游戏文件路径是否正确
- 确认 `dino-game-fixed.js` 已复制到公共目录
- 检查浏览器控制台错误信息

#### 网络检测不准确
- 调整检测间隔和超时时间
- 检查健康检查API是否正常工作
- 确认网络环境配置

#### 游戏显示异常
- 检查Canvas支持
- 确认游戏脚本正确加载
- 验证组件状态管理

### 调试技巧
1. 使用浏览器开发者工具监控网络请求
2. 检查Service Worker状态
3. 查看控制台日志信息
4. 测试不同的网络环境

## 📈 性能优化

### 游戏加载优化
- 延迟加载游戏脚本
- 使用动态导入
- 实现游戏资源预加载

### 网络检测优化
- 智能检测间隔调整
- 缓存检测结果
- 减少不必要的API调用

## 🔒 安全考虑

### 离线游戏安全
- 游戏脚本来源验证
- 防止恶意代码注入
- 限制游戏权限范围

### 网络检测安全
- 健康检查端点保护
- 防止检测端点滥用
- 合理的重试限制

## 📚 相关资源

### 文档链接
- [Next.js 官方文档](https://nextjs.org/docs)
- [React Hooks 文档](https://react.dev/reference/react/hooks)
- [Canvas API 文档](https://developer.mozilla.org/en-US/docs/Web/API/Canvas_API)

### 示例代码
- 完整集成示例: `app/offline-demo/page.tsx`
- 组件使用示例: `components/offline/`
- Hook 使用示例: `hooks/useNetworkStatus.ts`

## 🤝 贡献指南

### 代码规范
- 使用 TypeScript 编写
- 遵循 React 最佳实践
- 添加适当的注释和文档

### 测试要求
- 单元测试覆盖
- 集成测试验证
- 跨浏览器兼容性测试

---

## 📞 技术支持

如果您在使用过程中遇到问题，请：

1. 查看本文档的故障排除部分
2. 检查浏览器控制台错误信息
3. 验证配置文件设置
4. 联系开发团队获取帮助

**离线游戏功能**: 🟢 **已集成完成**  
**推荐使用**: ✅ **可以正常使用**







