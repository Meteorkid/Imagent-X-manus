'use client'

import React from 'react'
import { useTranslation } from 'react-i18next'
import { supportedLanguages, SupportedLanguage } from '../config/i18n'

export function LanguageSwitcher() {
  const { i18n } = useTranslation()

  const handleLanguageChange = (language: SupportedLanguage) => {
    i18n.changeLanguage(language)
    localStorage.setItem('i18nextLng', language)
  }

  return (
    <div className="language-switcher">
      <select
        value={i18n.language}
        onChange={(e) => handleLanguageChange(e.target.value as SupportedLanguage)}
        className="language-select"
      >
        {Object.entries(supportedLanguages).map(([code, name]) => (
          <option key={code} value={code}>
            {name}
          </option>
        ))}
      </select>
    </div>
  )
}

// 国际化文本组件
export function I18nText({ 
  key, 
  values, 
  className = '' 
}: { 
  key: string
  values?: Record<string, any>
  className?: string 
}) {
  const { t } = useTranslation()

  return (
    <span className={className}>
      {t(key, values)}
    </span>
  )
}

// 国际化按钮组件
export function I18nButton({ 
  key, 
  onClick, 
  className = '',
  disabled = false,
  children 
}: { 
  key: string
  onClick?: () => void
  className?: string
  disabled?: boolean
  children?: React.ReactNode
}) {
  const { t } = useTranslation()

  return (
    <button
      onClick={onClick}
      className={className}
      disabled={disabled}
    >
      {children || t(key)}
    </button>
  )
}
