/**
 * 中文语言包
 */
export const zhCN = {
  // 通用
  common: {
    loading: "加载中...",
    save: "保存",
    cancel: "取消",
    confirm: "确认",
    delete: "删除",
    edit: "编辑",
    create: "创建",
    search: "搜索",
    refresh: "刷新",
    back: "返回",
    next: "下一步",
    previous: "上一步",
    submit: "提交",
    reset: "重置",
    close: "关闭",
    open: "打开",
    yes: "是",
    no: "否",
    ok: "确定",
    error: "错误",
    success: "成功",
    warning: "警告",
    info: "信息",
    noData: "暂无数据",
    noResult: "没有找到结果",
  },

  // 导航
  nav: {
    home: "首页",
    dashboard: "仪表盘",
    agents: "智能体",
    conversations: "对话",
    knowledge: "知识库",
    tools: "工具",
    workflows: "工作流",
    plugins: "插件",
    settings: "设置",
    admin: "管理后台",
    profile: "个人资料",
    logout: "退出登录",
  },

  // 智能体
  agent: {
    title: "智能体",
    create: "创建智能体",
    edit: "编辑智能体",
    delete: "删除智能体",
    name: "名称",
    description: "描述",
    status: "状态",
    enabled: "已启用",
    disabled: "已禁用",
    preview: "预览",
    publish: "发布",
    unpublish: "取消发布",
  },

  // 对话
  conversation: {
    title: "对话",
    new: "新建对话",
    delete: "删除对话",
    rename: "重命名",
    empty: "暂无对话",
    placeholder: "输入消息...",
    send: "发送",
    typing: "正在输入...",
  },

  // 知识库
  knowledge: {
    title: "知识库",
    create: "创建知识库",
    upload: "上传文件",
    documents: "文档",
    chunks: "分块",
    empty: "暂无知识库",
  },

  // 工具
  tool: {
    title: "工具",
    install: "安装工具",
    uninstall: "卸载工具",
    configure: "配置工具",
    enabled: "已启用",
    disabled: "已禁用",
    empty: "暂无工具",
  },

  // 工作流
  workflow: {
    title: "工作流",
    create: "创建工作流",
    edit: "编辑工作流",
    delete: "删除工作流",
    execute: "执行工作流",
    monitor: "监控工作流",
    status: {
      draft: "草稿",
      published: "已发布",
      archived: "已归档",
      disabled: "已禁用",
    },
    execution: {
      pending: "等待执行",
      running: "执行中",
      completed: "已完成",
      failed: "失败",
      cancelled: "已取消",
      paused: "暂停中",
    },
  },

  // 插件
  plugin: {
    title: "插件",
    install: "安装插件",
    uninstall: "卸载插件",
    enable: "启用插件",
    disable: "禁用插件",
    configure: "配置插件",
    empty: "暂无插件",
  },

  // 设置
  settings: {
    title: "设置",
    general: "通用",
    appearance: "外观",
    language: "语言",
    theme: "主题",
    notifications: "通知",
    security: "安全",
    api: "API",
    about: "关于",
  },

  // 认证
  auth: {
    login: "登录",
    register: "注册",
    logout: "退出",
    email: "邮箱",
    password: "密码",
    confirmPassword: "确认密码",
    forgotPassword: "忘记密码",
    resetPassword: "重置密码",
    rememberMe: "记住我",
    orContinueWith: "或继续使用",
  },

  // 错误
  error: {
    required: "此字段为必填项",
    invalidEmail: "请输入有效的邮箱地址",
    passwordMismatch: "两次输入的密码不一致",
    minLength: "最少需要 {min} 个字符",
    maxLength: "最多 {max} 个字符",
    network: "网络错误，请检查网络连接",
    server: "服务器错误，请稍后重试",
    unauthorized: "未授权，请重新登录",
    forbidden: "没有权限访问",
    notFound: "资源不存在",
  },
} as const

export type TranslationKeys = typeof zhCN
