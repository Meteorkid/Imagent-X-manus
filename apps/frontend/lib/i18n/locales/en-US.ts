/**
 * English language pack
 */
export const enUS = {
  // Common
  common: {
    loading: "Loading...",
    save: "Save",
    cancel: "Cancel",
    confirm: "Confirm",
    delete: "Delete",
    edit: "Edit",
    create: "Create",
    search: "Search",
    refresh: "Refresh",
    back: "Back",
    next: "Next",
    previous: "Previous",
    submit: "Submit",
    reset: "Reset",
    close: "Close",
    open: "Open",
    yes: "Yes",
    no: "No",
    ok: "OK",
    error: "Error",
    success: "Success",
    warning: "Warning",
    info: "Info",
    noData: "No data",
    noResult: "No results found",
  },

  // Navigation
  nav: {
    home: "Home",
    dashboard: "Dashboard",
    agents: "Agents",
    conversations: "Conversations",
    knowledge: "Knowledge",
    tools: "Tools",
    workflows: "Workflows",
    plugins: "Plugins",
    settings: "Settings",
    admin: "Admin",
    profile: "Profile",
    logout: "Logout",
  },

  // Agent
  agent: {
    title: "Agent",
    create: "Create Agent",
    edit: "Edit Agent",
    delete: "Delete Agent",
    name: "Name",
    description: "Description",
    status: "Status",
    enabled: "Enabled",
    disabled: "Disabled",
    preview: "Preview",
    publish: "Publish",
    unpublish: "Unpublish",
  },

  // Conversation
  conversation: {
    title: "Conversation",
    new: "New Conversation",
    delete: "Delete Conversation",
    rename: "Rename",
    empty: "No conversations",
    placeholder: "Type a message...",
    send: "Send",
    typing: "Typing...",
  },

  // Knowledge
  knowledge: {
    title: "Knowledge",
    create: "Create Knowledge Base",
    upload: "Upload File",
    documents: "Documents",
    chunks: "Chunks",
    empty: "No knowledge bases",
  },

  // Tool
  tool: {
    title: "Tool",
    install: "Install Tool",
    uninstall: "Uninstall Tool",
    configure: "Configure Tool",
    enabled: "Enabled",
    disabled: "Disabled",
    empty: "No tools",
  },

  // Workflow
  workflow: {
    title: "Workflow",
    create: "Create Workflow",
    edit: "Edit Workflow",
    delete: "Delete Workflow",
    execute: "Execute Workflow",
    monitor: "Monitor Workflow",
    status: {
      draft: "Draft",
      published: "Published",
      archived: "Archived",
      disabled: "Disabled",
    },
    execution: {
      pending: "Pending",
      running: "Running",
      completed: "Completed",
      failed: "Failed",
      cancelled: "Cancelled",
      paused: "Paused",
    },
  },

  // Plugin
  plugin: {
    title: "Plugin",
    install: "Install Plugin",
    uninstall: "Uninstall Plugin",
    enable: "Enable Plugin",
    disable: "Disable Plugin",
    configure: "Configure Plugin",
    empty: "No plugins",
  },

  // Settings
  settings: {
    title: "Settings",
    general: "General",
    appearance: "Appearance",
    language: "Language",
    theme: "Theme",
    notifications: "Notifications",
    security: "Security",
    api: "API",
    about: "About",
  },

  // Auth
  auth: {
    login: "Login",
    register: "Register",
    logout: "Logout",
    email: "Email",
    password: "Password",
    confirmPassword: "Confirm Password",
    forgotPassword: "Forgot Password",
    resetPassword: "Reset Password",
    rememberMe: "Remember me",
    orContinueWith: "Or continue with",
  },

  // Error
  error: {
    required: "This field is required",
    invalidEmail: "Please enter a valid email address",
    passwordMismatch: "Passwords do not match",
    minLength: "Minimum {min} characters required",
    maxLength: "Maximum {max} characters allowed",
    network: "Network error, please check your connection",
    server: "Server error, please try again later",
    unauthorized: "Unauthorized, please login again",
    forbidden: "Access forbidden",
    notFound: "Resource not found",
  },
} as const

export type TranslationKeys = typeof enUS
