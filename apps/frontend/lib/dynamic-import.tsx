"use client"

import dynamic from "next/dynamic"
import { ComponentType, ReactNode } from "react"
import { Skeleton } from "@/components/ui/skeleton"

/**
 * 加载状态组件
 */
function LoadingSkeleton() {
  return (
    <div className="space-y-4">
      <Skeleton className="h-4 w-[250px]" />
      <Skeleton className="h-4 w-[200px]" />
      <Skeleton className="h-32 w-full" />
    </div>
  )
}

/**
 * 页面级懒加载
 */
export function lazyPage<T extends ComponentType<any>>(
  importFunc: () => Promise<{ default: T }>,
  options?: {
    loading?: ReactNode
    ssr?: boolean
  }
) {
  return dynamic(importFunc, {
    loading: options?.loading || <LoadingSkeleton />,
    ssr: options?.ssr ?? true,
  })
}

/**
 * 组件级懒加载
 */
export function lazyComponent<T extends ComponentType<any>>(
  importFunc: () => Promise<{ default: T }>,
  options?: {
    loading?: ReactNode
    ssr?: boolean
  }
) {
  return dynamic(importFunc, {
    loading: options?.loading || null,
    ssr: options?.ssr ?? false,
  })
}

/**
 * 懒加载包装器
 */
interface LazyWrapperProps {
  children: ReactNode
  fallback?: ReactNode
  loaded: boolean
}

export function LazyWrapper({ children, fallback, loaded }: LazyWrapperProps) {
  if (!loaded) {
    return <>{fallback || <LoadingSkeleton />}</>
  }
  return <>{children}</>
}

/**
 * 预加载组件
 */
export function preloadComponent(importFunc: () => Promise<any>) {
  if (typeof window !== "undefined") {
    importFunc()
  }
}
