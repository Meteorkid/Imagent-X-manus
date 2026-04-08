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

  const colsClassMap: Record<number, string> = {
    1: 'grid-cols-1',
    2: 'grid-cols-2',
    3: 'grid-cols-3',
    4: 'grid-cols-4',
    5: 'grid-cols-5',
    6: 'grid-cols-6',
    7: 'grid-cols-7',
    8: 'grid-cols-8',
    9: 'grid-cols-9',
    10: 'grid-cols-10',
    11: 'grid-cols-11',
    12: 'grid-cols-12',
  }

  const gapClassMap: Record<number, string> = {
    0: 'gap-0',
    1: 'gap-1',
    2: 'gap-2',
    3: 'gap-3',
    4: 'gap-4',
    5: 'gap-5',
    6: 'gap-6',
    7: 'gap-7',
    8: 'gap-8',
    9: 'gap-9',
    10: 'gap-10',
    11: 'gap-11',
    12: 'gap-12',
  }

  const colsClass = colsClassMap[getCols()] ?? 'grid-cols-1'
  const gapClass = gapClassMap[getGap()] ?? 'gap-4'

  return (
    <div
      className={`grid ${colsClass} ${gapClass} ${className}`}
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

  const textClassMap: Record<string, string> = {
    xs: 'text-xs',
    sm: 'text-sm',
    base: 'text-base',
    lg: 'text-lg',
    xl: 'text-xl',
    '2xl': 'text-2xl',
    '3xl': 'text-3xl',
    '4xl': 'text-4xl',
  }

  const textClass = textClassMap[getSize()] ?? 'text-base'

  return (
    <div className={`${textClass} ${className}`}>
      {children}
    </div>
  )
}
