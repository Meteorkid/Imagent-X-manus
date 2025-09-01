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
