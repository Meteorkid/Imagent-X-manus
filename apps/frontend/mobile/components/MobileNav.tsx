'use client'

import React, { useState } from 'react'
import { useTranslation } from 'react-i18next'

export function MobileNav() {
  const [isOpen, setIsOpen] = useState(false)
  const { t } = useTranslation()

  const navItems = [
    { key: 'navigation.home', href: '/', icon: '🏠' },
    { key: 'navigation.dashboard', href: '/dashboard', icon: '📊' },
    { key: 'navigation.agents', href: '/agents', icon: '🤖' },
    { key: 'navigation.sessions', href: '/sessions', icon: '💬' },
    { key: 'navigation.tools', href: '/tools', icon: '🔧' },
    { key: 'navigation.settings', href: '/settings', icon: '⚙️' },
  ]

  return (
    <>
      {/* 移动端导航栏 */}
      <nav className="mobile-nav">
        <div className="mobile-nav-header">
          <button
            className="mobile-nav-toggle"
            onClick={() => setIsOpen(!isOpen)}
          >
            <span className="hamburger"></span>
          </button>
          <div className="mobile-nav-brand">
            Imagent X
          </div>
        </div>

        {/* 移动端菜单 */}
        {isOpen && (
          <div className="mobile-nav-menu">
            {navItems.map((item) => (
              <a
                key={item.key}
                href={item.href}
                className="mobile-nav-item"
                onClick={() => setIsOpen(false)}
              >
                <span className="mobile-nav-icon">{item.icon}</span>
                <span className="mobile-nav-text">{t(item.key)}</span>
              </a>
            ))}
          </div>
        )}
      </nav>

      {/* 底部导航栏 */}
      <nav className="mobile-bottom-nav">
        {navItems.slice(0, 4).map((item) => (
          <a
            key={item.key}
            href={item.href}
            className="mobile-bottom-nav-item"
          >
            <span className="mobile-bottom-nav-icon">{item.icon}</span>
            <span className="mobile-bottom-nav-text">{t(item.key)}</span>
          </a>
        ))}
      </nav>
    </>
  )
}

// 移动端卡片组件
export function MobileCard({
  children,
  className = '',
  onClick,
}: {
  children: React.ReactNode
  className?: string
  onClick?: () => void
}) {
  return (
    <div
      className={`mobile-card ${className}`}
      onClick={onClick}
    >
      {children}
    </div>
  )
}

// 移动端列表组件
export function MobileList({
  items,
  renderItem,
  className = '',
}: {
  items: any[]
  renderItem: (item: any, index: number) => React.ReactNode
  className?: string
}) {
  return (
    <div className={`mobile-list ${className}`}>
      {items.map((item, index) => (
        <div key={index} className="mobile-list-item">
          {renderItem(item, index)}
        </div>
      ))}
    </div>
  )
}
