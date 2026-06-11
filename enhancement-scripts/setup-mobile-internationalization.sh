#!/bin/bash

# ImagentX 移动端和国际化设置脚本
# 用于实施响应式设计、多语言支持、移动端优化

set -e

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # 无颜色

echo -e "${BLUE}📱 设置ImagentX移动端和国际化功能...${NC}"

# 检查环境
check_environment() {
    echo -e "${BLUE}🔍 检查开发环境...${NC}"
    
    if node --version >/dev/null 2>&1; then
        echo -e "${GREEN}✅ Node.js 已安装${NC}"
    else
        echo -e "${RED}❌ Node.js 未安装${NC}"
        exit 1
    fi
}

# 创建移动端和国际化目录结构
create_mobile_structure() {
    echo -e "${BLUE}📁 创建移动端和国际化目录结构...${NC}"
    
    mkdir -p imagentx-frontend-plus/{mobile,internationalization,responsive}
    mkdir -p imagentx-frontend-plus/mobile/{components,hooks,utils}
    mkdir -p imagentx-frontend-plus/internationalization/{locales,components,utils}
    mkdir -p imagentx-frontend-plus/responsive/{breakpoints,components,styles}
    
    echo -e "${GREEN}✅ 移动端和国际化目录结构创建完成${NC}"
}

# 创建响应式设计配置
create_responsive_design() {
    echo -e "${BLUE}📐 创建响应式设计配置...${NC}"
    
    # 创建响应式断点配置
    cat > imagentx-frontend-plus/responsive/breakpoints/breakpoints.ts << 'EOF'
// 响应式断点配置

export const breakpoints = {
  xs: '320px',
  sm: '576px',
  md: '768px',
  lg: '992px',
  xl: '1200px',
  xxl: '1400px',
} as const

export const mediaQueries = {
  xs: `@media (min-width: ${breakpoints.xs})`,
  sm: `@media (min-width: ${breakpoints.sm})`,
  md: `@media (min-width: ${breakpoints.md})`,
  lg: `@media (min-width: ${breakpoints.lg})`,
  xl: `@media (min-width: ${breakpoints.xl})`,
  xxl: `@media (min-width: ${breakpoints.xxl})`,
} as const

// 设备类型检测
export const deviceTypes = {
  mobile: 'mobile',
  tablet: 'tablet',
  desktop: 'desktop',
} as const

// 响应式工具函数
export const useResponsive = () => {
  const [deviceType, setDeviceType] = useState(deviceTypes.desktop)
  const [isMobile, setIsMobile] = useState(false)
  const [isTablet, setIsTablet] = useState(false)
  const [isDesktop, setIsDesktop] = useState(true)

  useEffect(() => {
    const handleResize = () => {
      const width = window.innerWidth
      
      if (width < 768) {
        setDeviceType(deviceTypes.mobile)
        setIsMobile(true)
        setIsTablet(false)
        setIsDesktop(false)
      } else if (width < 1024) {
        setDeviceType(deviceTypes.tablet)
        setIsMobile(false)
        setIsTablet(true)
        setIsDesktop(false)
      } else {
        setDeviceType(deviceTypes.desktop)
        setIsMobile(false)
        setIsTablet(false)
        setIsDesktop(true)
      }
    }

    handleResize()
    window.addEventListener('resize', handleResize)
    
    return () => window.removeEventListener('resize', handleResize)
  }, [])

  return {
    deviceType,
    isMobile,
    isTablet,
    isDesktop,
  }
}
EOF

    # 创建响应式组件
    cat > imagentx-frontend-plus/responsive/components/ResponsiveContainer.tsx << 'EOF'
'use client'

import React from 'react'
import { useResponsive } from '../breakpoints/breakpoints'

interface ResponsiveContainerProps {
  children: React.ReactNode
  mobile?: React.ReactNode
  tablet?: React.ReactNode
  desktop?: React.ReactNode
  className?: string
}

export function ResponsiveContainer({
  children,
  mobile,
  tablet,
  desktop,
  className = '',
}: ResponsiveContainerProps) {
  const { isMobile, isTablet, isDesktop } = useResponsive()

  // 根据设备类型渲染不同内容
  if (isMobile && mobile) {
    return <div className={`mobile-container ${className}`}>{mobile}</div>
  }

  if (isTablet && tablet) {
    return <div className={`tablet-container ${className}`}>{tablet}</div>
  }

  if (isDesktop && desktop) {
    return <div className={`desktop-container ${className}`}>{desktop}</div>
  }

  // 默认渲染
  return <div className={`responsive-container ${className}`}>{children}</div>
}

// 响应式网格组件
export function ResponsiveGrid({
  children,
  cols = { mobile: 1, tablet: 2, desktop: 3 },
  gap = { mobile: 4, tablet: 6, desktop: 8 },
  className = '',
}: {
  children: React.ReactNode
  cols?: { mobile: number; tablet: number; desktop: number }
  gap?: { mobile: number; tablet: number; desktop: number }
  className?: string
}) {
  const { isMobile, isTablet, isDesktop } = useResponsive()

  const getCols = () => {
    if (isMobile) return cols.mobile
    if (isTablet) return cols.tablet
    return cols.desktop
  }

  const getGap = () => {
    if (isMobile) return gap.mobile
    if (isTablet) return gap.tablet
    return gap.desktop
  }

  return (
    <div
      className={`grid grid-cols-${getCols()} gap-${getGap()} ${className}`}
    >
      {children}
    </div>
  )
}

// 响应式文本组件
export function ResponsiveText({
  children,
  sizes = { mobile: 'sm', tablet: 'base', desktop: 'lg' },
  className = '',
}: {
  children: React.ReactNode
  sizes?: { mobile: string; tablet: string; desktop: string }
  className?: string
}) {
  const { isMobile, isTablet, isDesktop } = useResponsive()

  const getSize = () => {
    if (isMobile) return sizes.mobile
    if (isTablet) return sizes.tablet
    return sizes.desktop
  }

  return (
    <div className={`text-${getSize()} ${className}`}>
      {children}
    </div>
  )
}
EOF

    # 创建响应式样式
    cat > imagentx-frontend-plus/responsive/styles/responsive.css << 'EOF'
/* 响应式样式 */

/* 移动端样式 */
@media (max-width: 767px) {
  .mobile-container {
    padding: 1rem;
  }
  
  .mobile-hidden {
    display: none !important;
  }
  
  .mobile-full-width {
    width: 100% !important;
  }
  
  .mobile-text-center {
    text-align: center !important;
  }
  
  .mobile-stack {
    flex-direction: column !important;
  }
}

/* 平板样式 */
@media (min-width: 768px) and (max-width: 1023px) {
  .tablet-container {
    padding: 1.5rem;
  }
  
  .tablet-hidden {
    display: none !important;
  }
  
  .tablet-half-width {
    width: 50% !important;
  }
}

/* 桌面样式 */
@media (min-width: 1024px) {
  .desktop-container {
    padding: 2rem;
  }
  
  .desktop-hidden {
    display: none !important;
  }
  
  .desktop-sidebar {
    width: 250px !important;
  }
  
  .desktop-main {
    margin-left: 250px !important;
  }
}

/* 通用响应式工具类 */
.responsive-container {
  max-width: 100%;
  margin: 0 auto;
}

.responsive-image {
  max-width: 100%;
  height: auto;
}

.responsive-table {
  overflow-x: auto;
}

.responsive-nav {
  position: fixed;
  bottom: 0;
  left: 0;
  right: 0;
  z-index: 1000;
}

/* 触摸优化 */
@media (hover: none) and (pointer: coarse) {
  .touch-target {
    min-height: 44px;
    min-width: 44px;
  }
  
  .touch-spacing {
    margin: 0.5rem 0;
  }
}
EOF

    echo -e "${GREEN}✅ 响应式设计配置创建完成${NC}"
}

# 创建多语言支持
create_internationalization() {
    echo -e "${BLUE}🌍 创建多语言支持...${NC}"
    
    # 创建国际化配置
    cat > imagentx-frontend-plus/internationalization/config/i18n.ts << 'EOF'
// 国际化配置

import i18n from 'i18next'
import { initReactI18next } from 'react-i18next'
import LanguageDetector from 'i18next-browser-languagedetector'

// 支持的语言
export const supportedLanguages = {
  'zh-CN': '简体中文',
  'zh-TW': '繁體中文',
  'en-US': 'English',
  'ja-JP': '日本語',
  'ko-KR': '한국어',
  'fr-FR': 'Français',
  'de-DE': 'Deutsch',
  'es-ES': 'Español',
} as const

export type SupportedLanguage = keyof typeof supportedLanguages

// 默认语言
export const defaultLanguage: SupportedLanguage = 'zh-CN'

// 语言资源
const resources = {
  'zh-CN': {
    translation: {
      // 通用
      common: {
        loading: '加载中...',
        error: '错误',
        success: '成功',
        cancel: '取消',
        confirm: '确认',
        save: '保存',
        delete: '删除',
        edit: '编辑',
        add: '添加',
        search: '搜索',
        filter: '筛选',
        sort: '排序',
        refresh: '刷新',
        export: '导出',
        import: '导入',
      },
      
      // 导航
      navigation: {
        home: '首页',
        dashboard: '仪表板',
        agents: '智能助手',
        sessions: '会话',
        tools: '工具',
        settings: '设置',
        profile: '个人资料',
        logout: '退出登录',
      },
      
      // 认证
      auth: {
        login: '登录',
        register: '注册',
        email: '邮箱',
        password: '密码',
        confirmPassword: '确认密码',
        forgotPassword: '忘记密码',
        rememberMe: '记住我',
        loginSuccess: '登录成功',
        loginFailed: '登录失败',
        registerSuccess: '注册成功',
        registerFailed: '注册失败',
      },
      
      // Agent
      agent: {
        create: '创建助手',
        edit: '编辑助手',
        delete: '删除助手',
        name: '助手名称',
        description: '助手描述',
        systemPrompt: '系统提示词',
        model: 'AI模型',
        tools: '工具',
        status: '状态',
        published: '已发布',
        draft: '草稿',
        archived: '已归档',
      },
      
      // 会话
      session: {
        new: '新会话',
        history: '会话历史',
        clear: '清空会话',
        export: '导出会话',
        title: '会话标题',
        lastMessage: '最后消息',
        createdAt: '创建时间',
        updatedAt: '更新时间',
      },
      
      // 工具
      tool: {
        name: '工具名称',
        description: '工具描述',
        type: '工具类型',
        category: '工具分类',
        version: '版本',
        author: '作者',
        install: '安装',
        uninstall: '卸载',
        update: '更新',
        configure: '配置',
      },
      
      // 设置
      settings: {
        general: '通用设置',
        account: '账户设置',
        security: '安全设置',
        notification: '通知设置',
        language: '语言设置',
        theme: '主题设置',
        privacy: '隐私设置',
        about: '关于',
      },
    },
  },
  
  'en-US': {
    translation: {
      // Common
      common: {
        loading: 'Loading...',
        error: 'Error',
        success: 'Success',
        cancel: 'Cancel',
        confirm: 'Confirm',
        save: 'Save',
        delete: 'Delete',
        edit: 'Edit',
        add: 'Add',
        search: 'Search',
        filter: 'Filter',
        sort: 'Sort',
        refresh: 'Refresh',
        export: 'Export',
        import: 'Import',
      },
      
      // Navigation
      navigation: {
        home: 'Home',
        dashboard: 'Dashboard',
        agents: 'Agents',
        sessions: 'Sessions',
        tools: 'Tools',
        settings: 'Settings',
        profile: 'Profile',
        logout: 'Logout',
      },
      
      // Auth
      auth: {
        login: 'Login',
        register: 'Register',
        email: 'Email',
        password: 'Password',
        confirmPassword: 'Confirm Password',
        forgotPassword: 'Forgot Password',
        rememberMe: 'Remember Me',
        loginSuccess: 'Login successful',
        loginFailed: 'Login failed',
        registerSuccess: 'Registration successful',
        registerFailed: 'Registration failed',
      },
      
      // Agent
      agent: {
        create: 'Create Agent',
        edit: 'Edit Agent',
        delete: 'Delete Agent',
        name: 'Agent Name',
        description: 'Description',
        systemPrompt: 'System Prompt',
        model: 'AI Model',
        tools: 'Tools',
        status: 'Status',
        published: 'Published',
        draft: 'Draft',
        archived: 'Archived',
      },
      
      // Session
      session: {
        new: 'New Session',
        history: 'Session History',
        clear: 'Clear Session',
        export: 'Export Session',
        title: 'Session Title',
        lastMessage: 'Last Message',
        createdAt: 'Created At',
        updatedAt: 'Updated At',
      },
      
      // Tool
      tool: {
        name: 'Tool Name',
        description: 'Description',
        type: 'Tool Type',
        category: 'Category',
        version: 'Version',
        author: 'Author',
        install: 'Install',
        uninstall: 'Uninstall',
        update: 'Update',
        configure: 'Configure',
      },
      
      // Settings
      settings: {
        general: 'General',
        account: 'Account',
        security: 'Security',
        notification: 'Notifications',
        language: 'Language',
        theme: 'Theme',
        privacy: 'Privacy',
        about: 'About',
      },
    },
  },
}

// 初始化i18n
i18n
  .use(LanguageDetector)
  .use(initReactI18next)
  .init({
    resources,
    fallbackLng: defaultLanguage,
    debug: process.env.NODE_ENV === 'development',
    
    interpolation: {
      escapeValue: false,
    },
    
    detection: {
      order: ['localStorage', 'navigator', 'htmlTag'],
      caches: ['localStorage'],
    },
  })

export default i18n
EOF

    # 创建语言切换组件
    cat > imagentx-frontend-plus/internationalization/components/LanguageSwitcher.tsx << 'EOF'
'use client'

import React from 'react'
import { useTranslation } from 'react-i18next'
import { supportedLanguages, SupportedLanguage } from '../config/i18n'

export function LanguageSwitcher() {
  const { i18n } = useTranslation()

  const handleLanguageChange = (language: SupportedLanguage) => {
    i18n.changeLanguage(language)
    localStorage.setItem('i18nextLng', language)
  }

  return (
    <div className="language-switcher">
      <select
        value={i18n.language}
        onChange={(e) => handleLanguageChange(e.target.value as SupportedLanguage)}
        className="language-select"
      >
        {Object.entries(supportedLanguages).map(([code, name]) => (
          <option key={code} value={code}>
            {name}
          </option>
        ))}
      </select>
    </div>
  )
}

// 国际化文本组件
export function I18nText({ 
  key, 
  values, 
  className = '' 
}: { 
  key: string
  values?: Record<string, any>
  className?: string 
}) {
  const { t } = useTranslation()

  return (
    <span className={className}>
      {t(key, values)}
    </span>
  )
}

// 国际化按钮组件
export function I18nButton({ 
  key, 
  onClick, 
  className = '',
  disabled = false,
  children 
}: { 
  key: string
  onClick?: () => void
  className?: string
  disabled?: boolean
  children?: React.ReactNode
}) {
  const { t } = useTranslation()

  return (
    <button
      onClick={onClick}
      className={className}
      disabled={disabled}
    >
      {children || t(key)}
    </button>
  )
}
EOF

    echo -e "${GREEN}✅ 多语言支持创建完成${NC}"
}

# 创建移动端优化
create_mobile_optimization() {
    echo -e "${BLUE}📱 创建移动端优化...${NC}"
    
    # 创建移动端组件
    cat > imagentx-frontend-plus/mobile/components/MobileNav.tsx << 'EOF'
'use client'

import React, { useState } from 'react'
import { useTranslation } from 'react-i18next'

export function MobileNav() {
  const [isOpen, setIsOpen] = useState(false)
  const { t } = useTranslation()

  const navItems = [
    { key: 'navigation.home', href: '/', icon: '🏠' },
    { key: 'navigation.dashboard', href: '/dashboard', icon: '📊' },
    { key: 'navigation.agents', href: '/agents', icon: '🤖' },
    { key: 'navigation.sessions', href: '/sessions', icon: '💬' },
    { key: 'navigation.tools', href: '/tools', icon: '🔧' },
    { key: 'navigation.settings', href: '/settings', icon: '⚙️' },
  ]

  return (
    <>
      {/* 移动端导航栏 */}
      <nav className="mobile-nav">
        <div className="mobile-nav-header">
          <button
            className="mobile-nav-toggle"
            onClick={() => setIsOpen(!isOpen)}
          >
            <span className="hamburger"></span>
          </button>
          <div className="mobile-nav-brand">
            ImagentX
          </div>
        </div>

        {/* 移动端菜单 */}
        {isOpen && (
          <div className="mobile-nav-menu">
            {navItems.map((item) => (
              <a
                key={item.key}
                href={item.href}
                className="mobile-nav-item"
                onClick={() => setIsOpen(false)}
              >
                <span className="mobile-nav-icon">{item.icon}</span>
                <span className="mobile-nav-text">{t(item.key)}</span>
              </a>
            ))}
          </div>
        )}
      </nav>

      {/* 底部导航栏 */}
      <nav className="mobile-bottom-nav">
        {navItems.slice(0, 4).map((item) => (
          <a
            key={item.key}
            href={item.href}
            className="mobile-bottom-nav-item"
          >
            <span className="mobile-bottom-nav-icon">{item.icon}</span>
            <span className="mobile-bottom-nav-text">{t(item.key)}</span>
          </a>
        ))}
      </nav>
    </>
  )
}

// 移动端卡片组件
export function MobileCard({
  children,
  className = '',
  onClick,
}: {
  children: React.ReactNode
  className?: string
  onClick?: () => void
}) {
  return (
    <div
      className={`mobile-card ${className}`}
      onClick={onClick}
    >
      {children}
    </div>
  )
}

// 移动端列表组件
export function MobileList({
  items,
  renderItem,
  className = '',
}: {
  items: any[]
  renderItem: (item: any, index: number) => React.ReactNode
  className?: string
}) {
  return (
    <div className={`mobile-list ${className}`}>
      {items.map((item, index) => (
        <div key={index} className="mobile-list-item">
          {renderItem(item, index)}
        </div>
      ))}
    </div>
  )
}
EOF

    # 创建移动端样式
    cat > imagentx-frontend-plus/mobile/styles/mobile.css << 'EOF'
/* 移动端样式 */

/* 移动端导航栏 */
.mobile-nav {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  background: white;
  border-bottom: 1px solid #e5e7eb;
  z-index: 1000;
  padding: 0.75rem 1rem;
}

.mobile-nav-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.mobile-nav-toggle {
  background: none;
  border: none;
  padding: 0.5rem;
  cursor: pointer;
}

.hamburger {
  display: block;
  width: 20px;
  height: 2px;
  background: #374151;
  position: relative;
}

.hamburger::before,
.hamburger::after {
  content: '';
  position: absolute;
  width: 20px;
  height: 2px;
  background: #374151;
  transition: transform 0.3s;
}

.hamburger::before {
  top: -6px;
}

.hamburger::after {
  bottom: -6px;
}

.mobile-nav-menu {
  position: absolute;
  top: 100%;
  left: 0;
  right: 0;
  background: white;
  border-top: 1px solid #e5e7eb;
  box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
}

.mobile-nav-item {
  display: flex;
  align-items: center;
  padding: 1rem;
  text-decoration: none;
  color: #374151;
  border-bottom: 1px solid #f3f4f6;
}

.mobile-nav-icon {
  margin-right: 0.75rem;
  font-size: 1.25rem;
}

/* 底部导航栏 */
.mobile-bottom-nav {
  position: fixed;
  bottom: 0;
  left: 0;
  right: 0;
  background: white;
  border-top: 1px solid #e5e7eb;
  display: flex;
  z-index: 1000;
}

.mobile-bottom-nav-item {
  flex: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 0.5rem;
  text-decoration: none;
  color: #6b7280;
  font-size: 0.75rem;
}

.mobile-bottom-nav-item.active {
  color: #3b82f6;
}

.mobile-bottom-nav-icon {
  font-size: 1.5rem;
  margin-bottom: 0.25rem;
}

/* 移动端卡片 */
.mobile-card {
  background: white;
  border-radius: 0.75rem;
  padding: 1rem;
  margin-bottom: 1rem;
  box-shadow: 0 1px 3px 0 rgba(0, 0, 0, 0.1);
  border: 1px solid #e5e7eb;
}

.mobile-card:active {
  transform: scale(0.98);
}

/* 移动端列表 */
.mobile-list {
  padding: 1rem;
}

.mobile-list-item {
  background: white;
  border-radius: 0.5rem;
  padding: 1rem;
  margin-bottom: 0.5rem;
  border: 1px solid #e5e7eb;
}

/* 移动端表单 */
.mobile-form {
  padding: 1rem;
}

.mobile-form-group {
  margin-bottom: 1rem;
}

.mobile-form-label {
  display: block;
  margin-bottom: 0.5rem;
  font-weight: 500;
  color: #374151;
}

.mobile-form-input {
  width: 100%;
  padding: 0.75rem;
  border: 1px solid #d1d5db;
  border-radius: 0.5rem;
  font-size: 1rem;
}

.mobile-form-button {
  width: 100%;
  padding: 0.75rem;
  background: #3b82f6;
  color: white;
  border: none;
  border-radius: 0.5rem;
  font-size: 1rem;
  font-weight: 500;
  cursor: pointer;
}

.mobile-form-button:active {
  background: #2563eb;
}

/* 移动端模态框 */
.mobile-modal {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.5);
  z-index: 2000;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 1rem;
}

.mobile-modal-content {
  background: white;
  border-radius: 0.75rem;
  padding: 1.5rem;
  max-width: 100%;
  max-height: 90vh;
  overflow-y: auto;
}

/* 移动端工具提示 */
.mobile-tooltip {
  position: relative;
}

.mobile-tooltip-content {
  position: absolute;
  bottom: 100%;
  left: 50%;
  transform: translateX(-50%);
  background: #374151;
  color: white;
  padding: 0.5rem;
  border-radius: 0.25rem;
  font-size: 0.75rem;
  white-space: nowrap;
  z-index: 1000;
}

/* 移动端加载状态 */
.mobile-loading {
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 2rem;
  color: #6b7280;
}

.mobile-loading-spinner {
  width: 2rem;
  height: 2rem;
  border: 2px solid #e5e7eb;
  border-top: 2px solid #3b82f6;
  border-radius: 50%;
  animation: spin 1s linear infinite;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

/* 移动端空状态 */
.mobile-empty {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 3rem 1rem;
  color: #6b7280;
  text-align: center;
}

.mobile-empty-icon {
  font-size: 3rem;
  margin-bottom: 1rem;
}

.mobile-empty-text {
  font-size: 1rem;
  margin-bottom: 0.5rem;
}

.mobile-empty-subtext {
  font-size: 0.875rem;
  color: #9ca3af;
}
EOF

    echo -e "${GREEN}✅ 移动端优化创建完成${NC}"
}

# 创建移动端和国际化文档
create_mobile_documentation() {
    echo -e "${BLUE}📚 创建移动端和国际化文档...${NC}"
    
    cat > MOBILE_INTERNATIONALIZATION_GUIDE.md << 'EOF'
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
EOF

    echo -e "${GREEN}✅ 移动端和国际化文档创建完成${NC}"
}

# 主函数
main() {
    echo -e "${BLUE}🔍 检查开发环境...${NC}"
    check_environment
    
    echo -e "${BLUE}📁 创建移动端和国际化目录结构...${NC}"
    create_mobile_structure
    
    echo -e "${BLUE}📐 创建响应式设计配置...${NC}"
    create_responsive_design
    
    echo -e "${BLUE}🌍 创建多语言支持...${NC}"
    create_internationalization
    
    echo -e "${BLUE}📱 创建移动端优化...${NC}"
    create_mobile_optimization
    
    echo -e "${BLUE}📚 创建移动端和国际化文档...${NC}"
    create_mobile_documentation
    
    echo -e "${GREEN}🎉 移动端和国际化功能设置完成！${NC}"
    echo -e ""
    echo -e "${BLUE}📝 已创建的功能:${NC}"
    echo -e "  - 响应式设计 (断点配置、响应式组件、样式)"
    echo -e "  - 多语言支持 (8种语言、语言切换、翻译组件)"
    echo -e "  - 移动端优化 (移动导航、卡片组件、触摸优化)"
    echo -e ""
    echo -e "${YELLOW}📚 文档:${NC}"
    echo -e "  - 移动端和国际化指南: MOBILE_INTERNATIONALIZATION_GUIDE.md"
    echo -e ""
    echo -e "${BLUE}💡 下一步:${NC}"
    echo -e "  1. 集成到现有前端"
    echo -e "  2. 进行移动端测试"
    echo -e "  3. 部署到生产环境"
}

# 执行主函数
main "$@"
