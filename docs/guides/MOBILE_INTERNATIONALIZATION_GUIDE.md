# ImagentX 移动端和国际化指南

## 概述

本文档介绍ImagentX项目的移动端优化和国际化功能，包括响应式设计、多语言支持、移动端优化等。

## 📐 响应式设计

### 断点配置
```typescript
export const breakpoints = {
  xs: '320px',   // 手机
  sm: '576px',   // 大手机
  md: '768px',   // 平板
  lg: '992px',   // 小桌面
  xl: '1200px',  // 桌面
  xxl: '1400px', // 大桌面
}
```

### 响应式组件
```tsx
import { ResponsiveContainer, ResponsiveGrid, ResponsiveText } from './responsive/components'

// 根据设备类型渲染不同内容
<ResponsiveContainer
  mobile={<MobileView />}
  tablet={<TabletView />}
  desktop={<DesktopView />}
>

// 响应式网格
<ResponsiveGrid cols={{ mobile: 1, tablet: 2, desktop: 3 }}>
  {items.map(item => <Card key={item.id} {...item} />)}
</ResponsiveGrid>

// 响应式文本
<ResponsiveText sizes={{ mobile: 'sm', tablet: 'base', desktop: 'lg' }}>
  {content}
</ResponsiveText>
```

### 响应式工具类
```css
/* 移动端隐藏 */
.mobile-hidden { display: none !important; }

/* 桌面端隐藏 */
.desktop-hidden { display: none !important; }

/* 触摸优化 */
.touch-target {
  min-height: 44px;
  min-width: 44px;
}
```

## 🌍 多语言支持

### 支持的语言
- 简体中文 (zh-CN)
- 繁體中文 (zh-TW)
- English (en-US)
- 日本語 (ja-JP)
- 한국어 (ko-KR)
- Français (fr-FR)
- Deutsch (de-DE)
- Español (es-ES)

### 使用方式
```tsx
import { useTranslation } from 'react-i18next'
import { I18nText, I18nButton } from './internationalization/components'

// Hook方式
function MyComponent() {
  const { t } = useTranslation()
  
  return (
    <div>
      <h1>{t('navigation.home')}</h1>
      <p>{t('common.loading')}</p>
    </div>
  )
}

// 组件方式
<I18nText key="auth.login" />
<I18nButton key="common.save" onClick={handleSave} />

// 语言切换
<LanguageSwitcher />
```

### 添加新语言
1. 在 `i18n.ts` 中添加语言配置
2. 创建对应的翻译文件
3. 更新 `supportedLanguages` 对象

## 📱 移动端优化

### 移动端导航
```tsx
import { MobileNav } from './mobile/components'

// 顶部导航栏
<MobileNav />

// 底部导航栏（自动显示）
```

### 移动端组件
```tsx
import { MobileCard, MobileList } from './mobile/components'

// 移动端卡片
<MobileCard onClick={handleClick}>
  <h3>{title}</h3>
  <p>{description}</p>
</MobileCard>

// 移动端列表
<MobileList
  items={items}
  renderItem={(item) => <ListItem {...item} />}
/>
```

### 移动端样式
```css
/* 移动端导航栏 */
.mobile-nav {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  z-index: 1000;
}

/* 底部导航栏 */
.mobile-bottom-nav {
  position: fixed;
  bottom: 0;
  left: 0;
  right: 0;
  z-index: 1000;
}

/* 触摸优化 */
.touch-target {
  min-height: 44px;
  min-width: 44px;
}
```

## 🚀 最佳实践

### 响应式设计
1. **移动优先**: 先设计移动端，再扩展到桌面端
2. **断点选择**: 根据内容选择合适的分界点
3. **性能优化**: 避免不必要的重绘和重排
4. **触摸友好**: 确保触摸目标足够大

### 国际化
1. **文本长度**: 考虑不同语言的文本长度差异
2. **文化差异**: 注意不同文化的习惯和禁忌
3. **日期格式**: 使用本地化的日期和时间格式
4. **数字格式**: 考虑不同地区的数字表示方式

### 移动端优化
1. **性能优化**: 减少JavaScript包大小
2. **网络优化**: 使用懒加载和预加载
3. **电池优化**: 减少不必要的动画和计算
4. **离线支持**: 提供基本的离线功能

## 📊 性能指标

### 移动端性能目标
- **首屏加载时间**: < 3秒
- **交互响应时间**: < 100ms
- **JavaScript包大小**: < 500KB
- **图片优化**: WebP格式，响应式图片

### 国际化性能
- **语言切换时间**: < 200ms
- **翻译加载**: 按需加载
- **缓存策略**: 本地存储翻译数据

## 🔧 开发工具

### 响应式调试
```javascript
// 检测设备类型
const { deviceType, isMobile, isTablet, isDesktop } = useResponsive()

// 调试信息
console.log('Device Type:', deviceType)
console.log('Is Mobile:', isMobile)
```

### 国际化调试
```javascript
// 当前语言
console.log('Current Language:', i18n.language)

// 可用语言
console.log('Available Languages:', i18n.languages)

// 翻译键
console.log('Translation Keys:', Object.keys(i18n.store.data))
```

## 📞 技术支持

如有问题，请联系：
- **移动端开发**: mobile@imagentx.ai
- **国际化支持**: i18n@imagentx.ai
- **响应式设计**: responsive@imagentx.ai
