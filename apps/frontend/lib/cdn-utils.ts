// CDN工具类

interface CDNConfig {
  static: string
  images: string
  fonts: string
  api: string
}

const CDN_CONFIG: CDNConfig = {
  static: 'https://cdn.imagentx.top',
  images: 'https://img.imagentx.top',
  fonts: 'https://fonts.imagentx.top',
  api: 'https://api.imagentx.top',
}

/**
 * 获取CDN URL
 */
export function getCDNUrl(path: string, type: keyof CDNConfig = 'static'): string {
  const baseUrl = CDN_CONFIG[type]
  const cleanPath = path.startsWith('/') ? path : `/${path}`
  return `${baseUrl}${cleanPath}`
}

/**
 * 获取图片CDN URL
 */
export function getImageCDNUrl(path: string, width?: number, format?: string): string {
  let url = getCDNUrl(path, 'images')
  
  if (width) {
    url += `?w=${width}`
  }
  
  if (format) {
    url += `${width ? '&' : '?'}f=${format}`
  }
  
  return url
}

/**
 * 获取字体CDN URL
 */
export function getFontCDNUrl(fontName: string, format: 'woff2' | 'woff' | 'ttf' = 'woff2'): string {
  return getCDNUrl(`fonts/${fontName}.${format}`, 'fonts')
}

/**
 * 预加载CDN资源
 */
export function preloadCDNResource(url: string, as: string): void {
  if (typeof window === 'undefined') return
  
  const link = document.createElement('link')
  link.rel = 'preload'
  link.as = as
  link.href = url
  document.head.appendChild(link)
}

/**
 * 批量预加载CDN资源
 */
export function preloadCDNResources(resources: Array<{ url: string; as: string }>): void {
  resources.forEach(({ url, as }) => preloadCDNResource(url, as))
}

/**
 * 检查CDN可用性
 */
export async function checkCDNAvailability(): Promise<boolean> {
  try {
    const response = await fetch(`${CDN_CONFIG.static}/health`, {
      method: 'HEAD',
      cache: 'no-cache',
    })
    return response.ok
  } catch {
    return false
  }
}

/**
 * 获取最佳CDN节点
 */
export async function getOptimalCDNNode(): Promise<string> {
  // 实现CDN节点选择逻辑
  const nodes = [
      'https://cdn1.imagentx.top',
  'https://cdn2.imagentx.top',
  'https://cdn3.imagentx.top',
  ]
  
  // 简单的延迟测试
  const promises = nodes.map(async (node) => {
    const start = performance.now()
    try {
      await fetch(`${node}/ping`, { method: 'HEAD' })
      return { node, latency: performance.now() - start }
    } catch {
      return { node, latency: Infinity }
    }
  })
  
  const results = await Promise.all(promises)
  const bestNode = results.reduce((best, current) => 
    current.latency < best.latency ? current : best
  )
  
  return bestNode.node
}
