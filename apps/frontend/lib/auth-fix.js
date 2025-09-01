// 认证问题修复脚本
// 用于解决401认证错误

// 默认登录凭据
const DEFAULT_CREDENTIALS = {
  account: 'admin@imagentx.top',
  password: 'admin123'
};

// 自动登录函数
export async function autoLogin() {
  try {
    console.log('[AuthFix] 尝试自动登录...');
    
    const response = await fetch('/api/login', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(DEFAULT_CREDENTIALS),
    });
    
    const data = await response.json();
    
    if (data.code === 200 && data.data?.token) {
      // 保存token
      localStorage.setItem('auth_token', data.data.token);
      console.log('[AuthFix] 自动登录成功');
      return data.data.token;
    } else {
      console.error('[AuthFix] 自动登录失败:', data.message);
      return null;
    }
  } catch (error) {
    console.error('[AuthFix] 自动登录异常:', error);
    return null;
  }
}

// 检查并修复认证状态
export async function checkAndFixAuth() {
  const token = localStorage.getItem('auth_token');
  
  if (!token) {
    console.log('[AuthFix] 未找到认证token，尝试自动登录');
    return await autoLogin();
  }
  
  // 验证token是否有效
  try {
    const response = await fetch('/api/accounts/current', {
      headers: {
        'Authorization': `Bearer ${token}`
      }
    });
    
    if (response.status === 401) {
      console.log('[AuthFix] Token已过期，尝试重新登录');
      localStorage.removeItem('auth_token');
      return await autoLogin();
    }
    
    return token;
  } catch (error) {
    console.error('[AuthFix] Token验证失败:', error);
    return await autoLogin();
  }
}

// 初始化认证修复
export function initAuthFix() {
  if (typeof window !== 'undefined') {
    // 页面加载时检查认证状态
    window.addEventListener('load', () => {
      setTimeout(checkAndFixAuth, 1000);
    });
    
    // 监听401错误
    const originalFetch = window.fetch;
    window.fetch = async function(...args) {
      const response = await originalFetch.apply(this, args);
      
      if (response.status === 401) {
        console.log('[AuthFix] 检测到401错误，尝试重新认证');
        const newToken = await checkAndFixAuth();
        if (newToken) {
          // 重试原请求
          const [url, config] = args;
          const newConfig = {
            ...config,
            headers: {
              ...config?.headers,
              'Authorization': `Bearer ${newToken}`
            }
          };
          return originalFetch.apply(this, [url, newConfig]);
        }
      }
      
      return response;
    };
  }
}
