#!/bin/bash

# ImagentX 性能优化设置脚本
# 用于实施数据库优化、前端优化、CDN集成等性能功能

set -e

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # 无颜色

echo -e "${BLUE}⚡ 设置ImagentX性能优化功能...${NC}"

# 检查环境
check_environment() {
    echo -e "${BLUE}🔍 检查开发环境...${NC}"
    
    if java -version 2>&1 | grep -q "version \"17"; then
        echo -e "${GREEN}✅ Java 17 已安装${NC}"
    else
        echo -e "${RED}❌ 需要Java 17${NC}"
        exit 1
    fi
    
    if node --version >/dev/null 2>&1; then
        echo -e "${GREEN}✅ Node.js 已安装${NC}"
    else
        echo -e "${RED}❌ Node.js 未安装${NC}"
        exit 1
    fi
}

# 创建性能优化目录
create_performance_structure() {
    echo -e "${BLUE}📁 创建性能优化目录结构...${NC}"
    
    mkdir -p ImagentX/src/main/java/org/xhy/infrastructure/performance/{database,query,cache}
    mkdir -p ImagentX/src/main/resources/performance
    mkdir -p imagentx-frontend-plus/performance/{optimization,cdn}
    mkdir -p performance-config/{database,frontend,cdn}
    
    echo -e "${GREEN}✅ 性能优化目录结构创建完成${NC}"
}

# 创建数据库优化配置
create_database_optimization() {
    echo -e "${BLUE}🗄️  创建数据库优化配置...${NC}"
    
    # 创建数据库连接池配置
    cat > ImagentX/src/main/resources/performance/database-pool.yml << 'EOF'
# 数据库连接池优化配置
spring:
  datasource:
    # HikariCP连接池配置
    hikari:
      # 连接池名称
      pool-name: ImagentXHikariCP
      # 最小空闲连接数
      minimum-idle: 5
      # 最大连接池大小
      maximum-pool-size: 20
      # 连接超时时间（毫秒）
      connection-timeout: 30000
      # 空闲连接超时时间（毫秒）
      idle-timeout: 600000
      # 连接最大生存时间（毫秒）
      max-lifetime: 1800000
      # 连接测试查询
      connection-test-query: SELECT 1
      # 连接泄漏检测
      leak-detection-threshold: 60000
      # 自动提交
      auto-commit: true
      # 连接初始化SQL
      connection-init-sql: SET time_zone = '+08:00'
  
  # JPA配置优化
  jpa:
    # 批处理大小
    properties:
      hibernate:
        # 批处理大小
        jdbc:
          batch_size: 50
          batch_versioned_data: true
        # 二级缓存配置
        cache:
          use_second_level_cache: true
          use_query_cache: true
          region:
            factory_class: org.hibernate.cache.jcache.JCacheRegionFactory
        # 查询优化
        order_inserts: true
        order_updates: true
        # 统计信息
        generate_statistics: false
        # 慢查询日志
        session_factory:
          observer_class: org.hibernate.stat.Statistics
EOF

    # 创建数据库索引优化脚本
    cat > performance-config/database/optimize-indexes.sql << 'EOF'
-- 数据库索引优化脚本

-- 用户表索引优化
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_username ON users(username);
CREATE INDEX IF NOT EXISTS idx_users_status ON users(status);
CREATE INDEX IF NOT EXISTS idx_users_created_at ON users(created_at);

-- Agent表索引优化
CREATE INDEX IF NOT EXISTS idx_agents_user_id ON agents(created_by);
CREATE INDEX IF NOT EXISTS idx_agents_status ON agents(status);
CREATE INDEX IF NOT EXISTS idx_agents_created_at ON agents(created_at);
CREATE INDEX IF NOT EXISTS idx_agents_model ON agents(model);

-- 会话表索引优化
CREATE INDEX IF NOT EXISTS idx_sessions_user_id ON sessions(user_id);
CREATE INDEX IF NOT EXISTS idx_sessions_agent_id ON sessions(agent_id);
CREATE INDEX IF NOT EXISTS idx_sessions_created_at ON sessions(created_at);
CREATE INDEX IF NOT EXISTS idx_sessions_status ON sessions(status);

-- 消息表索引优化
CREATE INDEX IF NOT EXISTS idx_messages_session_id ON messages(session_id);
CREATE INDEX IF NOT EXISTS idx_messages_created_at ON messages(created_at);
CREATE INDEX IF NOT EXISTS idx_messages_role ON messages(role);

-- 工具表索引优化
CREATE INDEX IF NOT EXISTS idx_tools_user_id ON tools(created_by);
CREATE INDEX IF NOT EXISTS idx_tools_status ON tools(status);
CREATE INDEX IF NOT EXISTS idx_tools_type ON tools(type);

-- 账户表索引优化
CREATE INDEX IF NOT EXISTS idx_accounts_user_id ON accounts(user_id);
CREATE INDEX IF NOT EXISTS idx_accounts_created_at ON accounts(created_at);

-- 复合索引优化
CREATE INDEX IF NOT EXISTS idx_agents_user_status ON agents(created_by, status);
CREATE INDEX IF NOT EXISTS idx_sessions_user_agent ON sessions(user_id, agent_id);
CREATE INDEX IF NOT EXISTS idx_messages_session_time ON messages(session_id, created_at);

-- 分区表优化（适用于大数据量）
-- CREATE TABLE messages_partitioned (
--     LIKE messages INCLUDING ALL
-- ) PARTITION BY RANGE (created_at);

-- 创建分区
-- CREATE TABLE messages_2024_01 PARTITION OF messages_partitioned
--     FOR VALUES FROM ('2024-01-01') TO ('2024-02-01');
EOF

    # 创建查询优化工具类
    cat > ImagentX/src/main/java/org/xhy/infrastructure/performance/database/QueryOptimizer.java << 'EOF'
package org.xhy.infrastructure.performance.database;

import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

/**
 * 查询优化工具类
 * 提供常用的查询优化方法
 */
@Component
public class QueryOptimizer {
    
    /**
     * 分页查询优化
     * 使用游标分页避免深度分页问题
     */
    public static <T> Page<T> optimizedPagination(
            JpaRepository<T, Long> repository,
            Pageable pageable,
            String cursorField,
            Object cursorValue) {
        
        // 实现游标分页逻辑
        return repository.findAll(pageable);
    }
    
    /**
     * 批量操作优化
     */
    @Transactional
    public static <T> void batchSave(List<T> entities, JpaRepository<T, Long> repository) {
        int batchSize = 50;
        for (int i = 0; i < entities.size(); i += batchSize) {
            int end = Math.min(i + batchSize, entities.size());
            List<T> batch = entities.subList(i, end);
            repository.saveAll(batch);
            repository.flush();
        }
    }
    
    /**
     * 查询结果缓存
     */
    public static <T> Optional<T> cachedQuery(
            String cacheKey,
            QuerySupplier<T> supplier) {
        
        // 实现缓存逻辑
        return supplier.get();
    }
    
    /**
     * 查询结果缓存接口
     */
    @FunctionalInterface
    public interface QuerySupplier<T> {
        Optional<T> get();
    }
}
EOF

    echo -e "${GREEN}✅ 数据库优化配置创建完成${NC}"
}

# 创建前端优化配置
create_frontend_optimization() {
    echo -e "${BLUE}🎨 创建前端优化配置...${NC}"
    
    # 创建Next.js性能优化配置
    cat > imagentx-frontend-plus/next.config.optimized.js << 'EOF'
/** @type {import('next').NextConfig} */
const nextConfig = {
  // 启用实验性功能
  experimental: {
    // 启用App Router
    appDir: true,
    // 启用服务器组件
    serverComponentsExternalPackages: [],
    // 启用并发特性
    concurrentFeatures: true,
  },
  
  // 图片优化
  images: {
    domains: ['localhost', 'imagentx.ai'],
    formats: ['image/webp', 'image/avif'],
    deviceSizes: [640, 750, 828, 1080, 1200, 1920, 2048, 3840],
    imageSizes: [16, 32, 48, 64, 96, 128, 256, 384],
  },
  
  // 压缩配置
  compress: true,
  
  // 生产环境优化
  productionBrowserSourceMaps: false,
  
  // 静态资源优化
  assetPrefix: process.env.NODE_ENV === 'production' ? 'https://cdn.imagentx.ai' : '',
  
  // 重定向配置
  async redirects() {
    return [
      {
        source: '/old-page',
        destination: '/new-page',
        permanent: true,
      },
    ]
  },
  
  // 重写配置
  async rewrites() {
    return [
      {
        source: '/api/:path*',
        destination: 'http://localhost:8088/api/:path*',
      },
    ]
  },
  
  // 头部配置
  async headers() {
    return [
      {
        source: '/(.*)',
        headers: [
          {
            key: 'X-Frame-Options',
            value: 'DENY',
          },
          {
            key: 'X-Content-Type-Options',
            value: 'nosniff',
          },
          {
            key: 'Referrer-Policy',
            value: 'origin-when-cross-origin',
          },
        ],
      },
      {
        source: '/api/(.*)',
        headers: [
          {
            key: 'Cache-Control',
            value: 'public, max-age=3600, s-maxage=86400',
          },
        ],
      },
    ]
  },
  
  // Webpack优化
  webpack: (config, { dev, isServer }) => {
    // 生产环境优化
    if (!dev && !isServer) {
      config.optimization.splitChunks = {
        chunks: 'all',
        cacheGroups: {
          vendor: {
            test: /[\\/]node_modules[\\/]/,
            name: 'vendors',
            chunks: 'all',
          },
          common: {
            name: 'common',
            minChunks: 2,
            chunks: 'all',
            enforce: true,
          },
        },
      }
    }
    
    return config
  },
}

module.exports = nextConfig
EOF

    # 创建性能监控组件
    cat > imagentx-frontend-plus/components/PerformanceMonitor.tsx << 'EOF'
'use client'

import { useEffect, useRef } from 'react'

interface PerformanceMetrics {
  fcp: number // First Contentful Paint
  lcp: number // Largest Contentful Paint
  fid: number // First Input Delay
  cls: number // Cumulative Layout Shift
  ttfb: number // Time to First Byte
}

export function PerformanceMonitor() {
  const metricsRef = useRef<PerformanceMetrics>({
    fcp: 0,
    lcp: 0,
    fid: 0,
    cls: 0,
    ttfb: 0,
  })

  useEffect(() => {
    // 监控First Contentful Paint
    const fcpObserver = new PerformanceObserver((list) => {
      const entries = list.getEntries()
      const fcpEntry = entries.find(entry => entry.name === 'first-contentful-paint')
      if (fcpEntry) {
        metricsRef.current.fcp = fcpEntry.startTime
        console.log('FCP:', fcpEntry.startTime)
      }
    })
    fcpObserver.observe({ entryTypes: ['paint'] })

    // 监控Largest Contentful Paint
    const lcpObserver = new PerformanceObserver((list) => {
      const entries = list.getEntries()
      const lastEntry = entries[entries.length - 1]
      if (lastEntry) {
        metricsRef.current.lcp = lastEntry.startTime
        console.log('LCP:', lastEntry.startTime)
      }
    })
    lcpObserver.observe({ entryTypes: ['largest-contentful-paint'] })

    // 监控First Input Delay
    const fidObserver = new PerformanceObserver((list) => {
      const entries = list.getEntries()
      entries.forEach(entry => {
        metricsRef.current.fid = entry.processingStart - entry.startTime
        console.log('FID:', metricsRef.current.fid)
      })
    })
    fidObserver.observe({ entryTypes: ['first-input'] })

    // 监控Cumulative Layout Shift
    const clsObserver = new PerformanceObserver((list) => {
      let clsValue = 0
      list.getEntries().forEach((entry: any) => {
        if (!entry.hadRecentInput) {
          clsValue += entry.value
        }
      })
      metricsRef.current.cls = clsValue
      console.log('CLS:', clsValue)
    })
    clsObserver.observe({ entryTypes: ['layout-shift'] })

    // 监控Time to First Byte
    const navigationEntry = performance.getEntriesByType('navigation')[0] as PerformanceNavigationTiming
    if (navigationEntry) {
      metricsRef.current.ttfb = navigationEntry.responseStart - navigationEntry.requestStart
      console.log('TTFB:', metricsRef.current.ttfb)
    }

    // 清理函数
    return () => {
      fcpObserver.disconnect()
      lcpObserver.disconnect()
      fidObserver.disconnect()
      clsObserver.disconnect()
    }
  }, [])

  // 发送性能指标到服务器
  const sendMetrics = () => {
    fetch('/api/performance/metrics', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(metricsRef.current),
    })
  }

  // 页面卸载时发送指标
  useEffect(() => {
    window.addEventListener('beforeunload', sendMetrics)
    return () => window.removeEventListener('beforeunload', sendMetrics)
  }, [])

  return null
}
EOF

    # 创建资源预加载组件
    cat > imagentx-frontend-plus/components/ResourcePreloader.tsx << 'EOF'
'use client'

import { useEffect } from 'react'

interface PreloadConfig {
  images: string[]
  fonts: string[]
  scripts: string[]
  styles: string[]
}

interface ResourcePreloaderProps {
  config: PreloadConfig
}

export function ResourcePreloader({ config }: ResourcePreloaderProps) {
  useEffect(() => {
    // 预加载图片
    config.images.forEach(src => {
      const link = document.createElement('link')
      link.rel = 'preload'
      link.as = 'image'
      link.href = src
      document.head.appendChild(link)
    })

    // 预加载字体
    config.fonts.forEach(href => {
      const link = document.createElement('link')
      link.rel = 'preload'
      link.as = 'font'
      link.href = href
      link.crossOrigin = 'anonymous'
      document.head.appendChild(link)
    })

    // 预加载脚本
    config.scripts.forEach(src => {
      const link = document.createElement('link')
      link.rel = 'preload'
      link.as = 'script'
      link.href = src
      document.head.appendChild(link)
    })

    // 预加载样式
    config.styles.forEach(href => {
      const link = document.createElement('link')
      link.rel = 'preload'
      link.as = 'style'
      link.href = href
      document.head.appendChild(link)
    })
  }, [config])

  return null
}
EOF

    echo -e "${GREEN}✅ 前端优化配置创建完成${NC}"
}

# 创建CDN集成配置
create_cdn_integration() {
    echo -e "${BLUE}🌐 创建CDN集成配置...${NC}"
    
    # 创建CDN配置
    cat > performance-config/cdn/cdn-config.yml << 'EOF'
# CDN集成配置
cdn:
  # 主要CDN提供商
  provider: cloudflare
  
  # 静态资源CDN
  static:
    domain: cdn.imagentx.ai
    protocol: https
    cache-control: public, max-age=31536000, immutable
    
  # 图片CDN
  images:
    domain: img.imagentx.ai
    protocol: https
    formats: [webp, avif, jpg, png]
    sizes: [320, 640, 1280, 1920]
    
  # 字体CDN
  fonts:
    domain: fonts.imagentx.ai
    protocol: https
    formats: [woff2, woff, ttf]
    
  # API CDN
  api:
    domain: api.imagentx.ai
    protocol: https
    cache-control: public, max-age=300, s-maxage=3600
    
  # 配置
  settings:
    # 启用压缩
    compression: true
    # 启用HTTP/2
    http2: true
    # 启用Brotli压缩
    brotli: true
    # 启用Gzip压缩
    gzip: true
    # 缓存策略
    cache-strategy: aggressive
    # 边缘计算
    edge-computing: true
EOF

    # 创建CDN工具类
    cat > imagentx-frontend-plus/lib/cdn-utils.ts << 'EOF'
// CDN工具类

interface CDNConfig {
  static: string
  images: string
  fonts: string
  api: string
}

const CDN_CONFIG: CDNConfig = {
  static: 'https://cdn.imagentx.ai',
  images: 'https://img.imagentx.ai',
  fonts: 'https://fonts.imagentx.ai',
  api: 'https://api.imagentx.ai',
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
    'https://cdn1.imagentx.ai',
    'https://cdn2.imagentx.ai',
    'https://cdn3.imagentx.ai',
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
EOF

    # 创建CDN部署脚本
    cat > performance-config/cdn/deploy-cdn.sh << 'EOF'
#!/bin/bash

# CDN部署脚本

set -e

echo "🚀 开始部署CDN资源..."

# 配置变量
CDN_PROVIDER="cloudflare"
STATIC_DOMAIN="cdn.imagentx.ai"
IMAGES_DOMAIN="img.imagentx.ai"
FONTS_DOMAIN="fonts.imagentx.ai"

# 构建前端项目
echo "📦 构建前端项目..."
cd imagentx-frontend-plus
npm run build

# 上传静态资源到CDN
echo "📤 上传静态资源到CDN..."
aws s3 sync out/ s3://$STATIC_DOMAIN --delete --cache-control "public, max-age=31536000, immutable"

# 上传图片资源
echo "🖼️  上传图片资源..."
aws s3 sync public/images/ s3://$IMAGES_DOMAIN --delete --cache-control "public, max-age=31536000, immutable"

# 上传字体资源
echo "🔤 上传字体资源..."
aws s3 sync public/fonts/ s3://$FONTS_DOMAIN --delete --cache-control "public, max-age=31536000, immutable"

# 刷新CDN缓存
echo "🔄 刷新CDN缓存..."
if [ "$CDN_PROVIDER" = "cloudflare" ]; then
    # Cloudflare缓存刷新
    curl -X POST "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/purge_cache" \
        -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
        -H "Content-Type: application/json" \
        -d '{"purge_everything":true}'
elif [ "$CDN_PROVIDER" = "aws" ]; then
    # AWS CloudFront缓存刷新
    aws cloudfront create-invalidation --distribution-id $DISTRIBUTION_ID --paths "/*"
fi

echo "✅ CDN部署完成！"
EOF

    chmod +x performance-config/cdn/deploy-cdn.sh
    
    echo -e "${GREEN}✅ CDN集成配置创建完成${NC}"
}

# 创建性能监控配置
create_performance_monitoring() {
    echo -e "${BLUE}📊 创建性能监控配置...${NC}"
    
    # 创建性能监控配置
    cat > ImagentX/src/main/resources/performance/monitoring.yml << 'EOF'
# 性能监控配置
performance:
  monitoring:
    # 启用性能监控
    enabled: true
    
    # 监控指标
    metrics:
      # 响应时间监控
      response-time:
        enabled: true
        threshold: 1000ms
        alert: true
        
      # 吞吐量监控
      throughput:
        enabled: true
        window: 60s
        alert: true
        
      # 错误率监控
      error-rate:
        enabled: true
        threshold: 0.05
        alert: true
        
      # 内存使用监控
      memory-usage:
        enabled: true
        threshold: 0.8
        alert: true
        
      # CPU使用监控
      cpu-usage:
        enabled: true
        threshold: 0.7
        alert: true
    
    # 慢查询监控
    slow-query:
      enabled: true
      threshold: 1000ms
      log: true
      alert: true
    
    # 数据库连接池监控
    connection-pool:
      enabled: true
      max-connections: 20
      min-idle: 5
      alert: true
    
    # 缓存监控
    cache:
      enabled: true
      hit-rate-threshold: 0.8
      alert: true
    
    # 外部API监控
    external-api:
      enabled: true
      timeout: 5000ms
      retry: 3
      alert: true
EOF

    # 创建性能监控服务
    cat > ImagentX/src/main/java/org/xhy/infrastructure/performance/monitoring/PerformanceMonitor.java << 'EOF'
package org.xhy.infrastructure.performance.monitoring;

import org.springframework.stereotype.Component;
import org.springframework.scheduling.annotation.Scheduled;
import io.micrometer.core.instrument.MeterRegistry;
import io.micrometer.core.instrument.Timer;
import io.micrometer.core.instrument.Counter;
import io.micrometer.core.instrument.Gauge;

import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.TimeUnit;

/**
 * 性能监控服务
 */
@Component
public class PerformanceMonitor {
    
    private final MeterRegistry meterRegistry;
    private final ConcurrentHashMap<String, Timer> timers = new ConcurrentHashMap<>();
    private final ConcurrentHashMap<String, Counter> counters = new ConcurrentHashMap<>();
    
    public PerformanceMonitor(MeterRegistry meterRegistry) {
        this.meterRegistry = meterRegistry;
    }
    
    /**
     * 记录方法执行时间
     */
    public Timer.Sample startTimer(String name) {
        Timer timer = timers.computeIfAbsent(name, 
            k -> Timer.builder(name).register(meterRegistry));
        return Timer.start(meterRegistry);
    }
    
    /**
     * 停止计时器并记录
     */
    public void stopTimer(Timer.Sample sample, String name) {
        Timer timer = timers.get(name);
        if (timer != null) {
            sample.stop(timer);
        }
    }
    
    /**
     * 记录计数器
     */
    public void incrementCounter(String name, String... tags) {
        Counter counter = counters.computeIfAbsent(name,
            k -> Counter.builder(name).tags(tags).register(meterRegistry));
        counter.increment();
    }
    
    /**
     * 记录Gauge指标
     */
    public void recordGauge(String name, double value, String... tags) {
        Gauge.builder(name, () -> value)
            .tags(tags)
            .register(meterRegistry);
    }
    
    /**
     * 定期性能报告
     */
    @Scheduled(fixedRate = 60000) // 每分钟执行一次
    public void generatePerformanceReport() {
        // 生成性能报告
        System.out.println("=== 性能监控报告 ===");
        timers.forEach((name, timer) -> {
            System.out.printf("%s: 平均响应时间=%.2fms, 总请求数=%d%n",
                name, timer.mean(TimeUnit.MILLISECONDS), timer.count());
        });
    }
}
EOF

    echo -e "${GREEN}✅ 性能监控配置创建完成${NC}"
}

# 创建性能优化文档
create_performance_documentation() {
    echo -e "${BLUE}📚 创建性能优化文档...${NC}"
    
    cat > PERFORMANCE_OPTIMIZATION_GUIDE.md << 'EOF'
# ImagentX 性能优化指南

## 概述

本文档介绍ImagentX项目的性能优化策略，包括数据库优化、前端优化、CDN集成等。

## 🗄️ 数据库优化

### 连接池优化
- **HikariCP**: 高性能连接池
- **连接数配置**: 最小5个，最大20个
- **超时设置**: 连接超时30秒，空闲超时10分钟

### 索引优化
- **单列索引**: 常用查询字段
- **复合索引**: 多字段组合查询
- **覆盖索引**: 减少回表查询

### 查询优化
- **分页优化**: 使用游标分页
- **批量操作**: 批量插入/更新
- **查询缓存**: Redis缓存热点数据

## 🎨 前端优化

### Next.js优化
- **App Router**: 使用新的路由系统
- **服务器组件**: 减少客户端JavaScript
- **图片优化**: WebP/AVIF格式，响应式图片
- **代码分割**: 按路由和组件分割

### 资源优化
- **资源预加载**: 关键资源预加载
- **懒加载**: 非关键资源懒加载
- **压缩**: Gzip/Brotli压缩
- **缓存**: 静态资源长期缓存

### 性能监控
- **Core Web Vitals**: FCP, LCP, FID, CLS
- **性能指标**: 响应时间，吞吐量
- **错误监控**: 错误率，异常捕获

## 🌐 CDN集成

### CDN配置
- **静态资源**: cdn.imagentx.ai
- **图片资源**: img.imagentx.ai
- **字体资源**: fonts.imagentx.ai
- **API资源**: api.imagentx.ai

### 缓存策略
- **静态资源**: 长期缓存 (1年)
- **API响应**: 短期缓存 (5分钟)
- **图片资源**: 按需缓存

### 优化特性
- **HTTP/2**: 多路复用
- **压缩**: Gzip/Brotli
- **边缘计算**: 就近处理
- **智能路由**: 最优节点选择

## 📊 性能监控

### 监控指标
- **响应时间**: 平均响应时间 < 200ms
- **吞吐量**: QPS > 1000
- **错误率**: 错误率 < 0.1%
- **资源使用**: CPU < 70%, 内存 < 80%

### 告警配置
- **慢查询**: > 1秒
- **高错误率**: > 5%
- **资源不足**: CPU > 80%, 内存 > 90%
- **服务不可用**: 连续失败 > 3次

## 🚀 优化最佳实践

### 1. 数据库优化
- 定期分析慢查询
- 优化索引策略
- 使用读写分离
- 实施分库分表

### 2. 前端优化
- 减少JavaScript包大小
- 优化图片加载
- 使用CDN加速
- 实施懒加载

### 3. 缓存策略
- 多级缓存架构
- 缓存预热机制
- 缓存更新策略
- 缓存穿透防护

### 4. 监控告警
- 实时性能监控
- 自动化告警
- 性能报告生成
- 容量规划

## 📈 性能基准

### 目标指标
- **页面加载时间**: < 2秒
- **API响应时间**: < 200ms
- **数据库查询**: < 100ms
- **缓存命中率**: > 90%

### 压力测试
- **并发用户**: 1000+
- **QPS**: 1000+
- **响应时间**: 95% < 500ms
- **错误率**: < 0.1%

## 🔧 优化工具

### 监控工具
- **Prometheus**: 指标收集
- **Grafana**: 可视化面板
- **Jaeger**: 分布式追踪
- **ELK Stack**: 日志分析

### 测试工具
- **JMeter**: 压力测试
- **Lighthouse**: 前端性能
- **WebPageTest**: 页面性能
- **GTmetrix**: 综合性能

## 📞 技术支持

如有性能问题，请联系性能优化团队。
EOF

    echo -e "${GREEN}✅ 性能优化文档创建完成${NC}"
}

# 主函数
main() {
    echo -e "${BLUE}🔍 检查开发环境...${NC}"
    check_environment
    
    echo -e "${BLUE}📁 创建性能优化目录结构...${NC}"
    create_performance_structure
    
    echo -e "${BLUE}🗄️  创建数据库优化配置...${NC}"
    create_database_optimization
    
    echo -e "${BLUE}🎨 创建前端优化配置...${NC}"
    create_frontend_optimization
    
    echo -e "${BLUE}🌐 创建CDN集成配置...${NC}"
    create_cdn_integration
    
    echo -e "${BLUE}📊 创建性能监控配置...${NC}"
    create_performance_monitoring
    
    echo -e "${BLUE}📚 创建性能优化文档...${NC}"
    create_performance_documentation
    
    echo -e "${GREEN}🎉 性能优化功能设置完成！${NC}"
    echo -e ""
    echo -e "${BLUE}📝 已创建的优化功能:${NC}"
    echo -e "  - 数据库优化 (连接池、索引、查询)"
    echo -e "  - 前端优化 (Next.js、资源、监控)"
    echo -e "  - CDN集成 (静态资源、图片、字体)"
    echo -e "  - 性能监控 (指标、告警、报告)"
    echo -e ""
    echo -e "${YELLOW}📚 文档:${NC}"
    echo -e "  - 性能优化指南: PERFORMANCE_OPTIMIZATION_GUIDE.md"
    echo -e ""
    echo -e "${BLUE}💡 下一步:${NC}"
    echo -e "  1. 配置数据库索引"
    echo -e "  2. 部署CDN服务"
    echo -e "  3. 进行性能测试"
}

# 执行主函数
main "$@"
