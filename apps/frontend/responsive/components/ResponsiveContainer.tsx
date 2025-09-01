'use client'

import React from 'react'
import { useResponsive } from '../breakpoints/breakpoints'

interface ResponsiveContainerProps {
  children: React.ReactNode
  mobile?: React.ReactNode
  tablet?: React.ReactNode
  desktop?: React.ReactNode
  className?: string
}

export function ResponsiveContainer({
  children,
  mobile,
  tablet,
  desktop,
  className = '',
}: ResponsiveContainerProps) {
  const { isMobile, isTablet, isDesktop } = useResponsive()

  // 根据设备类型渲染不同内容
  if (isMobile && mobile) {
    return <div className={`mobile-container ${className}`}>{mobile}</div>
  }

  if (isTablet && tablet) {
    return <div className={`tablet-container ${className}`}>{tablet}</div>
  }

  if (isDesktop && desktop) {
    return <div className={`desktop-container ${className}`}>{desktop}</div>
  }

  // 默认渲染
  return <div className={`responsive-container ${className}`}>{children}</div>
}

// 响应式网格组件
export function ResponsiveGrid({
  children,
  cols = { mobile: 1, tablet: 2, desktop: 3 },
  gap = { mobile: 4, tablet: 6, desktop: 8 },
  className = '',
}: {
  children: React.ReactNode
  cols?: { mobile: number; tablet: number; desktop: number }
  gap?: { mobile: number; tablet: number; desktop: number }
  className?: string
}) {
  const { isMobile, isTablet, isDesktop } = useResponsive()

  const getCols = () => {
    if (isMobile) return cols.mobile
    if (isTablet) return cols.tablet
    return cols.desktop
  }

  const getGap = () => {
    if (isMobile) return gap.mobile
    if (isTablet) return gap.tablet
    return gap.desktop
  }

  return (
    <div
      className={`grid grid-cols-${getCols()} gap-${getGap()} ${className}`}
    >
      {children}
    </div>
  )
}

// 响应式文本组件
export function ResponsiveText({
  children,
  sizes = { mobile: 'sm', tablet: 'base', desktop: 'lg' },
  className = '',
}: {
  children: React.ReactNode
  sizes?: { mobile: string; tablet: string; desktop: string }
  className?: string
}) {
  const { isMobile, isTablet, isDesktop } = useResponsive()

  const getSize = () => {
    if (isMobile) return sizes.mobile
    if (isTablet) return sizes.tablet
    return sizes.desktop
  }

  return (
    <div className={`text-${getSize()} ${className}`}>
      {children}
    </div>
  )
}
