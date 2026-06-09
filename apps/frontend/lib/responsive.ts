/**
 * 响应式工具函数
 */

/**
 * 断点定义
 */
export const breakpoints = {
  sm: 640,
  md: 768,
  lg: 1024,
  xl: 1280,
  "2xl": 1536,
} as const

/**
 * 媒体查询字符串
 */
export const mediaQueries = {
  sm: `(min-width: ${breakpoints.sm}px)`,
  md: `(min-width: ${breakpoints.md}px)`,
  lg: `(min-width: ${breakpoints.lg}px)`,
  xl: `(min-width: ${breakpoints.xl}px)`,
  "2xl": `(min-width: ${breakpoints["2xl"]}px)`,
} as const

/**
 * 检查是否匹配媒体查询
 */
export function matchesMedia(query: string): boolean {
  if (typeof window === "undefined") {
    return false
  }
  return window.matchMedia(query).matches
}

/**
 * 检查是否为移动设备
 */
export function isMobile(): boolean {
  return !matchesMedia(mediaQueries.md)
}

/**
 * 检查是否为平板设备
 */
export function isTablet(): boolean {
  return matchesMedia(mediaQueries.md) && !matchesMedia(mediaQueries.lg)
}

/**
 * 检查是否为桌面设备
 */
export function isDesktop(): boolean {
  return matchesMedia(mediaQueries.lg)
}

/**
 * 获取当前断点
 */
export function getCurrentBreakpoint(): keyof typeof breakpoints {
  if (matchesMedia(mediaQueries["2xl"])) return "2xl"
  if (matchesMedia(mediaQueries.xl)) return "xl"
  if (matchesMedia(mediaQueries.lg)) return "lg"
  if (matchesMedia(mediaQueries.md)) return "md"
  return "sm"
}

/**
 * 响应式 Hook：监听窗口大小
 */
export function useWindowSize() {
  if (typeof window === "undefined") {
    return { width: 0, height: 0 }
  }

  const [size, setSize] = useState({
    width: window.innerWidth,
    height: window.innerHeight,
  })

  useEffect(() => {
    const handleResize = () => {
      setSize({
        width: window.innerWidth,
        height: window.innerHeight,
      })
    }

    window.addEventListener("resize", handleResize)
    return () => window.removeEventListener("resize", handleResize)
  }, [])

  return size
}

/**
 * 响应式 Hook：监听媒体查询
 */
export function useMediaQuery(query: string): boolean {
  const [matches, setMatches] = useState(false)

  useEffect(() => {
    const media = window.matchMedia(query)
    setMatches(media.matches)

    const listener = (e: MediaQueryListEvent) => setMatches(e.matches)
    media.addEventListener("change", listener)
    return () => media.removeEventListener("change", listener)
  }, [query])

  return matches
}

/**
 * 响应式 Hook：是否为移动设备
 */
export function useIsMobile(): boolean {
  return useMediaQuery(mediaQueries.md)
}

/**
 * 响应式 Hook：是否为平板设备
 */
export function useIsTablet(): boolean {
  const isMd = useMediaQuery(mediaQueries.md)
  const isLg = useMediaQuery(mediaQueries.lg)
  return isMd && !isLg
}

/**
 * 响应式 Hook：是否为桌面设备
 */
export function useIsDesktop(): boolean {
  return useMediaQuery(mediaQueries.lg)
}

import { useState, useEffect } from "react"
