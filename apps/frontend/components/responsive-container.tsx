"use client"

import { ReactNode } from "react"
import { cn } from "@/lib/utils"

interface ResponsiveContainerProps {
  children: ReactNode
  className?: string
  maxWidth?: "sm" | "md" | "lg" | "xl" | "2xl" | "full"
  padding?: boolean
}

/**
 * 响应式容器组件
 */
export function ResponsiveContainer({
  children,
  className,
  maxWidth = "xl",
  padding = true,
}: ResponsiveContainerProps) {
  const maxWidthClasses = {
    sm: "max-w-screen-sm",
    md: "max-w-screen-md",
    lg: "max-w-screen-lg",
    xl: "max-w-screen-xl",
    "2xl": "max-w-screen-2xl",
    full: "max-w-full",
  }

  return (
    <div
      className={cn(
        "mx-auto w-full",
        maxWidthClasses[maxWidth],
        padding && "px-4 sm:px-6 lg:px-8",
        className
      )}
    >
      {children}
    </div>
  )
}

interface ResponsiveGridProps {
  children: ReactNode
  className?: string
  cols?: {
    sm?: number
    md?: number
    lg?: number
    xl?: number
  }
  gap?: number
}

/**
 * 响应式网格组件
 */
export function ResponsiveGrid({
  children,
  className,
  cols = { sm: 1, md: 2, lg: 3, xl: 4 },
  gap = 4,
}: ResponsiveGridProps) {
  const gridClasses = {
    1: "grid-cols-1",
    2: "grid-cols-2",
    3: "grid-cols-3",
    4: "grid-cols-4",
    5: "grid-cols-5",
    6: "grid-cols-6",
  }

  return (
    <div
      className={cn(
        "grid",
        gridClasses[cols.sm || 1],
        cols.md && `md:grid-cols-${cols.md}`,
        cols.lg && `lg:grid-cols-${cols.lg}`,
        cols.xl && `xl:grid-cols-${cols.xl}`,
        `gap-${gap}`,
        className
      )}
    >
      {children}
    </div>
  )
}

interface ResponsiveSidebarProps {
  children: ReactNode
  className?: string
  sidebar: ReactNode
  sidebarWidth?: "sm" | "md" | "lg"
  collapsed?: boolean
}

/**
 * 响应式侧边栏布局
 */
export function ResponsiveSidebar({
  children,
  className,
  sidebar,
  sidebarWidth = "md",
  collapsed = false,
}: ResponsiveSidebarProps) {
  const widthClasses = {
    sm: "w-48",
    md: "w-64",
    lg: "w-80",
  }

  const collapsedWidthClasses = {
    sm: "w-16",
    md: "w-16",
    lg: "w-16",
  }

  return (
    <div className={cn("flex min-h-screen", className)}>
      {/* 侧边栏 */}
      <aside
        className={cn(
          "flex-shrink-0 transition-all duration-300",
          collapsed ? collapsedWidthClasses[sidebarWidth] : widthClasses[sidebarWidth],
          "hidden md:block"
        )}
      >
        {sidebar}
      </aside>

      {/* 主内容区 */}
      <main className="flex-1 overflow-auto">{children}</main>
    </div>
  )
}
