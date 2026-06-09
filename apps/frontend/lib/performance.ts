/**
 * 性能优化工具
 */

/**
 * 防抖函数
 */
export function debounce<T extends (...args: any[]) => any>(
  func: T,
  wait: number,
  immediate?: boolean
): (...args: Parameters<T>) => void {
  let timeout: NodeJS.Timeout | null = null

  return function executedFunction(...args: Parameters<T>) {
    const later = () => {
      timeout = null
      if (!immediate) func(...args)
    }

    const callNow = immediate && !timeout

    if (timeout) clearTimeout(timeout)
    timeout = setTimeout(later, wait)

    if (callNow) func(...args)
  }
}

/**
 * 节流函数
 */
export function throttle<T extends (...args: any[]) => any>(
  func: T,
  limit: number
): (...args: Parameters<T>) => void {
  let inThrottle: boolean

  return function executedFunction(...args: Parameters<T>) {
    if (!inThrottle) {
      func(...args)
      inThrottle = true
      setTimeout(() => (inThrottle = false), limit)
    }
  }
}

/**
 * 懒加载 Hook
 */
export function useLazyLoad(options?: IntersectionObserverInit) {
  const [isVisible, setIsVisible] = useState(false)
  const ref = useCallback((node: HTMLElement | null) => {
    if (node === null) return

    const observer = new IntersectionObserver(([entry]) => {
      if (entry.isIntersecting) {
        setIsVisible(true)
        observer.disconnect()
      }
    }, options)

    observer.observe(node)
  }, [])

  return { ref, isVisible }
}

/**
 * 虚拟滚动 Hook
 */
export function useVirtualScroll<T>(
  items: T[],
  itemHeight: number,
  containerHeight: number
) {
  const [scrollTop, setScrollTop] = useState(0)

  const visibleCount = Math.ceil(containerHeight / itemHeight)
  const startIndex = Math.floor(scrollTop / itemHeight)
  const endIndex = Math.min(startIndex + visibleCount + 1, items.length)

  const visibleItems = items.slice(startIndex, endIndex).map((item, index) => ({
    item,
    index: startIndex + index,
    style: {
      position: "absolute" as const,
      top: (startIndex + index) * itemHeight,
      height: itemHeight,
    },
  }))

  const totalHeight = items.length * itemHeight

  const handleScroll = useCallback((e: React.UIEvent<HTMLDivElement>) => {
    setScrollTop(e.currentTarget.scrollTop)
  }, [])

  return {
    visibleItems,
    totalHeight,
    handleScroll,
  }
}

import { useState, useCallback } from "react"

/**
 * 图片懒加载 Hook
 */
export function useImageLazyLoad(src: string) {
  const [loaded, setLoaded] = useState(false)
  const [error, setError] = useState(false)

  const { ref, isVisible } = useLazyLoad()

  useEffect(() => {
    if (!isVisible || !src) return

    const img = new Image()
    img.src = src

    img.onload = () => setLoaded(true)
    img.onerror = () => setError(true)
  }, [isVisible, src])

  return { ref, loaded, error }
}

import { useEffect } from "react"

/**
 * 性能监控 Hook
 */
export function usePerformanceMonitor(name: string) {
  useEffect(() => {
    const start = performance.now()

    return () => {
      const end = performance.now()
      const duration = end - start
      console.log(`[Performance] ${name}: ${duration.toFixed(2)}ms`)
    }
  }, [name])
}

/**
 * Web Vitals 监控
 */
export function reportWebVitals() {
  if (typeof window === "undefined") return

  // FCP (First Contentful Paint)
  const paintObserver = new PerformanceObserver((list) => {
    for (const entry of list.getEntries()) {
      if (entry.name === "first-contentful-paint") {
        console.log(`[Web Vitals] FCP: ${entry.startTime.toFixed(2)}ms`)
      }
    }
  })
  paintObserver.observe({ type: "paint", buffered: true })

  // LCP (Largest Contentful Paint)
  const lcpObserver = new PerformanceObserver((list) => {
    const entries = list.getEntries()
    const lastEntry = entries[entries.length - 1]
    console.log(`[Web Vitals] LCP: ${lastEntry.startTime.toFixed(2)}ms`)
  })
  lcpObserver.observe({ type: "largest-contentful-paint", buffered: true })

  // FID (First Input Delay)
  const fidObserver = new PerformanceObserver((list) => {
    for (const entry of list.getEntries()) {
      const fid = (entry as any).processingStart - entry.startTime
      console.log(`[Web Vitals] FID: ${fid.toFixed(2)}ms`)
    }
  })
  fidObserver.observe({ type: "first-input", buffered: true })

  // CLS (Cumulative Layout Shift)
  let clsValue = 0
  const clsObserver = new PerformanceObserver((list) => {
    for (const entry of list.getEntries()) {
      if (!(entry as any).hadRecentInput) {
        clsValue += (entry as any).value
      }
    }
    console.log(`[Web Vitals] CLS: ${clsValue.toFixed(4)}`)
  })
  clsObserver.observe({ type: "layout-shift", buffered: true })
}
