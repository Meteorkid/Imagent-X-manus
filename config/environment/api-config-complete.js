// ImagentX 完整 API 配置 - 前端专用
// 包含所有接口地址、请求方法和参数说明

// 基础配置
const API_BASE_CONFIG = {
  // 自动适配环境
  BASE_URL: typeof window !== 'undefined' 
    ? `${window.location.protocol}//${window.location.hostname}:8088/api`
    : 'http://localhost:8088/api',
  
  TIMEOUT: 30000,
  RETRY_COUNT: 3,
  RETRY_DELAY: 1000
};

// 认证配置
const AUTH_CONFIG = {
  TOKEN_KEY: 'auth_token',
  REFRESH_TOKEN_KEY: 'refresh_token',
  USER_INFO_KEY: 'user_info'
};

// 完整的 API 端点映射
export const API_ENDPOINTS = {
  // ==================== 系统健康检查 ====================
  HEALTH: {
    CHECK: '/health',
    DB: '/health/db',
    REDIS: '/health/redis'
  },

  // ==================== 用户认证 ====================
  AUTH: {
    LOGIN: '/auth/login',
    REGISTER: '/auth/register',
    REFRESH: '/auth/refresh',
    LOGOUT: '/auth/logout'
  },

  // ==================== 用户管理 ====================
  USERS: {
    ME: '/users/me',
    PASSWORD: '/users/password'
  },

  // ==================== Agent 管理 ====================
  AGENTS: {
    // 基础操作
    LIST_PUBLISHED: '/agents/published',
    LIST_BY_USER: (userId) => `/agents/user/${userId}`,
    CREATE: '/agents',
    DETAIL: (agentId) => `/agents/${agentId}`,
    UPDATE: (agentId) => `/agents/${agentId}`,
    DELETE: (agentId) => `/agents/${agentId}`,
    
    // 版本管理
    VERSIONS: (agentId) => `/agents/${agentId}/versions`,
    PUBLISH: (agentId) => `/agents/${agentId}/publish`,
    LATEST_VERSION: (agentId) => `/agents/${agentId}/versions/latest`,
    
    // 系统提示词
    GENERATE_PROMPT: '/agents/generate-system-prompt',
    
    // 工作区
    WORKSPACE: '/agents/workspaces',
    ADD_TO_WORKSPACE: (agentId) => `/agents/workspaces/${agentId}`,
    MODEL_CONFIG: (agentId) => `/agents/workspaces/${agentId}/model-config`,
    SET_MODEL_CONFIG: (agentId) => `/agents/workspaces/${agentId}/model/config`
  },

  // ==================== 会话管理 ====================
  SESSIONS: {
    LIST: '/agents/sessions',
    CREATE: '/agents/sessions',
    DELETE: (sessionId) => `/agents/sessions/${sessionId}`,
    MESSAGES: (sessionId) => `/agents/sessions/${sessionId}/messages`,
    SEND_MESSAGE: (sessionId) => `/agents/sessions/${sessionId}/message`,
    STREAM_CHAT: (sessionId) => `/agents/sessions/${sessionId}/stream-chat`
  },

  // ==================== 任务管理 ====================
  TASKS: {
    SESSION_TASKS: (sessionId) => `/tasks/session/${sessionId}/latest`,
    DETAIL: (taskId) => `/tasks/${taskId}`
  },

  // ==================== LLM 提供商 ====================
  LLM_PROVIDERS: {
    LIST: '/llms/providers',
    CREATE: '/llms/providers',
    DETAIL: (providerId) => `/llms/providers/${providerId}`,
    UPDATE: '/llms/providers',
    DELETE: (providerId) => `/llms/providers/${providerId}`,
    PROTOCOLS: '/llms/providers/protocols',
    TOGGLE_STATUS: (providerId) => `/llms/providers/${providerId}/status`
  },

  // ==================== LLM 模型 ====================
  LLM_MODELS: {
    LIST: '/llms/models',
    CREATE: '/llms/models',
    DEFAULT: '/llms/models/default',
    DETAIL: (modelId) => `/llms/models/${modelId}`,
    UPDATE: '/llms/models',
    DELETE: (modelId) => `/llms/models/${modelId}`,
    TYPES: '/llms/models/types',
    TOGGLE_STATUS: (modelId) => `/llms/models/${modelId}/status`
  },

  // ==================== 工具市场 ====================
  TOOLS: {
    // 市场相关
    MARKET_LIST: '/tools/market',
    MARKET_DETAIL: (toolId) => `/tools/market/${toolId}`,
    MARKET_VERSIONS: (toolId) => `/tools/market/${toolId}/versions`,
    MARKET_LABELS: '/tools/market/labels',
    
    // 推荐和安装
    RECOMMEND: '/tools/recommend',
    INSTALL: (toolId, version) => `/tools/install/${toolId}/${version}`,
    UNINSTALL: (toolId) => `/tools/uninstall/${toolId}`,
    
    // 用户工具
    USER_TOOLS: '/tools/user',
    INSTALLED_TOOLS: '/tools/installed',
    UPLOAD: '/tools',
    DETAIL: (toolId) => `/tools/${toolId}`,
    UPDATE: (toolId) => `/tools/${toolId}`,
    DELETE: (toolId) => `/tools/${toolId}`,
    LATEST_VERSION: (toolId) => `/tools/${toolId}/latest`,
    PUBLISH_TO_MARKET: '/tools/market'
  },

  // ==================== RAG 知识库 ====================
  RAG: {
    // 数据集管理
    DATASETS: '/rag/datasets',
    ALL_DATASETS: '/rag/datasets/all',
    DATASET_DETAIL: (datasetId) => `/rag/datasets/${datasetId}`,
    
    // 文件操作
    UPLOAD_FILE: '/rag/datasets/files',
    DATASET_FILES: (datasetId) => `/rag/datasets/${datasetId}/files`,
    ALL_DATASET_FILES: (datasetId) => `/rag/datasets/${datasetId}/files/all`,
    DELETE_FILE: (datasetId, fileId) => `/rag/datasets/${datasetId}/files/${fileId}`,
    
    // 文件处理
    PROCESS_FILE: '/rag/datasets/files/process',
    FILE_PROGRESS: (fileId) => `/rag/datasets/files/${fileId}/progress`,
    DATASET_PROGRESS: (datasetId) => `/rag/datasets/${datasetId}/files/progress`,
    
    // 搜索和聊天
    SEARCH: '/rag/search',
    SEARCH_BY_USER_RAG: (userRagId) => `/rag/search/user-rag/${userRagId}`,
    STREAM_CHAT: '/rag/search/stream-chat',
    STREAM_CHAT_BY_USER_RAG: (userRagId) => `/rag/search/user-rag/${userRagId}/stream-chat`,
    
    // 文件详情
    FILE_INFO: (fileId) => `/rag/files/${fileId}/info`,
    DOCUMENT_UNITS: '/rag/files/document-units/list',
    UPDATE_DOCUMENT_UNIT: '/rag/files/document-units',
    DELETE_DOCUMENT_UNIT: (unitId) => `/rag/files/document-units/${unitId}`,
    FILE_DETAIL: '/rag/files/detail',
    FILE_CONTENT: '/rag/files/content'
  },

  // ==================== API 密钥 ====================
  API_KEYS: {
    LIST: '/api-keys',
    CREATE: '/api-keys',
    DETAIL: (apiKeyId) => `/api-keys/${apiKeyId}`,
    UPDATE_STATUS: (apiKeyId) => `/api-keys/${apiKeyId}/status`,
    DELETE: (apiKeyId) => `/api-keys/${apiKeyId}`,
    RESET: (apiKeyId) => `/api-keys/${apiKeyId}/reset`,
    USAGE: (apiKeyId) => `/api-keys/${apiKeyId}/usage`,
    AGENT_KEYS: (agentId) => `/api-keys/agent/${agentId}`
  },

  // ==================== 订单管理 ====================
  ORDERS: {
    LIST: '/orders',
    DETAIL: (orderId) => `/orders/${orderId}`
  },

  // ==================== 管理员接口 ====================
  ADMIN: {
    USERS: '/admin/users',
    AGENTS: '/admin/agents',
    AGENT_STATISTICS: '/admin/agents/statistics',
    ORDERS: '/admin/orders',
    ORDER_DETAIL: (orderId) => `/admin/orders/${orderId}`
  }
};

// 请求方法映射
export const HTTP_METHODS = {
  GET: 'GET',
  POST: 'POST',
  PUT: 'PUT',
  DELETE: 'DELETE',
  PATCH: 'PATCH'
};

// 请求头配置
export const REQUEST_HEADERS = {
  JSON: { 'Content-Type': 'application/json' },
  FORM_DATA: {}, // FormData不需要设置Content-Type
  MULTIPART: { 'Content-Type': 'multipart/form-data' },
  STREAM: { 'Accept': 'text/event-stream' }
};

// 认证工具类
export class AuthManager {
  static getToken() {
    return localStorage.getItem(AUTH_CONFIG.TOKEN_KEY);
  }

  static setToken(token) {
    localStorage.setItem(AUTH_CONFIG.TOKEN_KEY, token);
  }

  static removeToken() {
    localStorage.removeItem(AUTH_CONFIG.TOKEN_KEY);
  }

  static getAuthHeaders() {
    const token = this.getToken();
    return token ? { 'Authorization': `Bearer ${token}` } : {};
  }

  static isAuthenticated() {
    return !!this.getToken();
  }
}

// URL构建工具
export class UrlBuilder {
  static buildUrl(endpoint, params = {}) {
    const url = new URL(endpoint, API_BASE_CONFIG.BASE_URL);
    
    Object.keys(params).forEach(key => {
      if (params[key] !== null && params[key] !== undefined) {
        url.searchParams.append(key, params[key]);
      }
    });
    
    return url.toString();
  }

  static buildPaginatedUrl(endpoint, page = 1, size = 20, otherParams = {}) {
    return this.buildUrl(endpoint, {
      page,
      size,
      ...otherParams
    });
  }
}

// 错误处理工具
export class ErrorHandler {
  static handleApiError(error) {
    if (error.response) {
      const { status, data } = error.response;
      
      switch (status) {
        case 400:
          return new Error(data.message || '请求参数错误');
        case 401:
          AuthManager.removeToken();
          window.location.href = '/login';
          return new Error('登录已过期，请重新登录');
        case 403:
          return new Error('没有权限访问此资源');
        case 404:
          return new Error('请求的资源不存在');
        case 500:
          return new Error('服务器内部错误');
        default:
          return new Error(data.message || '网络请求失败');
      }
    } else if (error.request) {
      return new Error('网络连接失败，请检查网络设置');
    } else {
      return new Error('请求配置错误');
    }
  }
}

// 分页配置
export const PAGINATION_CONFIG = {
  DEFAULT_PAGE: 1,
  DEFAULT_SIZE: 20,
  PAGE_SIZE_OPTIONS: [10, 20, 50, 100]
};

// 文件上传配置
export const UPLOAD_CONFIG = {
  MAX_FILE_SIZE: 50 * 1024 * 1024, // 50MB
  ALLOWED_TYPES: [
    'text/plain',
    'text/markdown',
    'application/pdf',
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    'application/vnd.openxmlformats-officedocument.presentationml.presentation'
  ],
  CHUNK_SIZE: 1024 * 1024 // 1MB分片
};

// 流式响应配置
export const STREAM_CONFIG = {
  RETRY_TIMEOUT: 5000,
  MAX_RETRIES: 3,
  HEARTBEAT_INTERVAL: 30000
};

// 导出默认配置
export default {
  API_BASE_CONFIG,
  API_ENDPOINTS,
  HTTP_METHODS,
  REQUEST_HEADERS,
  AUTH_CONFIG,
  PAGINATION_CONFIG,
  UPLOAD_CONFIG,
  STREAM_CONFIG
};