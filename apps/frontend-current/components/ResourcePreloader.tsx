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
