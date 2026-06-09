"use client"

import { createContext, useContext, useEffect, useState, ReactNode } from "react"
import { zhCN, TranslationKeys } from "./locales/zh-CN"
import { enUS } from "./locales/en-US"

export type Locale = "zh-CN" | "en-US"

const locales: Record<Locale, TranslationKeys> = {
  "zh-CN": zhCN,
  "en-US": enUS,
}

interface I18nContextType {
  locale: Locale
  setLocale: (locale: Locale) => void
  t: TranslationKeys
  locales: Locale[]
}

const I18nContext = createContext<I18nContextType>({
  locale: "zh-CN",
  setLocale: () => {},
  t: zhCN,
  locales: ["zh-CN", "en-US"],
})

export function useI18n() {
  return useContext(I18nContext)
}

interface I18nProviderProps {
  children: ReactNode
  defaultLocale?: Locale
}

export function I18nProvider({ children, defaultLocale = "zh-CN" }: I18nProviderProps) {
  const [locale, setLocaleState] = useState<Locale>(() => {
    // 从 localStorage 读取语言
    if (typeof window !== "undefined") {
      const savedLocale = localStorage.getItem("locale") as Locale
      if (savedLocale && locales[savedLocale]) {
        return savedLocale
      }
    }
    return defaultLocale
  })

  const setLocale = (newLocale: Locale) => {
    setLocaleState(newLocale)
    localStorage.setItem("locale", newLocale)

    // 更新 document lang 属性
    document.documentElement.lang = newLocale
  }

  useEffect(() => {
    // 设置初始 lang 属性
    document.documentElement.lang = locale
  }, [locale])

  const t = locales[locale]

  return (
    <I18nContext.Provider value={{ locale, setLocale, t, locales: ["zh-CN", "en-US"] }}>
      {children}
    </I18nContext.Provider>
  )
}
