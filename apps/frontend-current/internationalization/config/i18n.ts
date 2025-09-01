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
