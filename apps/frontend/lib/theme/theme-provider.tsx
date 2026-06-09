"use client"

import { createContext, useContext, useEffect, useState, ReactNode } from "react"
import { Theme, themes, getThemeById, lightTheme } from "./themes"

interface ThemeContextType {
  theme: Theme
  setTheme: (themeId: string) => void
  themes: Theme[]
}

const ThemeContext = createContext<ThemeContextType>({
  theme: lightTheme,
  setTheme: () => {},
  themes: themes,
})

export function useTheme() {
  return useContext(ThemeContext)
}

interface ThemeProviderProps {
  children: ReactNode
  defaultTheme?: string
}

export function ThemeProvider({ children, defaultTheme = "light" }: ThemeProviderProps) {
  const [theme, setThemeState] = useState<Theme>(() => {
    // 从 localStorage 读取主题
    if (typeof window !== "undefined") {
      const savedTheme = localStorage.getItem("theme")
      if (savedTheme) {
        return getThemeById(savedTheme)
      }
    }
    return getThemeById(defaultTheme)
  })

  const setTheme = (themeId: string) => {
    const newTheme = getThemeById(themeId)
    setThemeState(newTheme)
    localStorage.setItem("theme", themeId)

    // 更新 CSS 变量
    applyTheme(newTheme)
  }

  const applyTheme = (theme: Theme) => {
    const root = document.documentElement
    const colors = theme.colors

    root.style.setProperty("--primary", colors.primary)
    root.style.setProperty("--primary-foreground", colors.primaryForeground)
    root.style.setProperty("--secondary", colors.secondary)
    root.style.setProperty("--secondary-foreground", colors.secondaryForeground)
    root.style.setProperty("--background", colors.background)
    root.style.setProperty("--foreground", colors.foreground)
    root.style.setProperty("--card", colors.card)
    root.style.setProperty("--card-foreground", colors.cardForeground)
    root.style.setProperty("--popover", colors.popover)
    root.style.setProperty("--popover-foreground", colors.popoverForeground)
    root.style.setProperty("--border", colors.border)
    root.style.setProperty("--input", colors.input)
    root.style.setProperty("--ring", colors.ring)
    root.style.setProperty("--destructive", colors.destructive)
    root.style.setProperty("--destructive-foreground", colors.destructiveForeground)
    root.style.setProperty("--warning", colors.warning)
    root.style.setProperty("--warning-foreground", colors.warningForeground)
    root.style.setProperty("--success", colors.success)
    root.style.setProperty("--success-foreground", colors.successForeground)
    root.style.setProperty("--info", colors.info)
    root.style.setProperty("--info-foreground", colors.infoForeground)
    root.style.setProperty("--sidebar", colors.sidebar)
    root.style.setProperty("--sidebar-foreground", colors.sidebarForeground)
    root.style.setProperty("--sidebar-accent", colors.sidebarAccent)
    root.style.setProperty("--sidebar-accent-foreground", colors.sidebarAccentForeground)
    root.style.setProperty("--sidebar-border", colors.sidebarBorder)
    root.style.setProperty("--sidebar-ring", colors.sidebarRing)

    // 更新 data-theme 属性
    root.setAttribute("data-theme", theme.id)

    // 更新 class
    root.classList.remove("light", "dark")
    if (theme.id === "dark") {
      root.classList.add("dark")
    } else {
      root.classList.add("light")
    }
  }

  useEffect(() => {
    applyTheme(theme)
  }, [theme])

  return (
    <ThemeContext.Provider value={{ theme, setTheme, themes }}>
      {children}
    </ThemeContext.Provider>
  )
}
