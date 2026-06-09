/**
 * 主题定义
 */

export interface Theme {
  id: string
  name: string
  description: string
  colors: ThemeColors
}

export interface ThemeColors {
  // 主色调
  primary: string
  primaryForeground: string

  // 次要色调
  secondary: string
  secondaryForeground: string

  // 背景色
  background: string
  foreground: string

  // 卡片色
  card: string
  cardForeground: string

  // 弹出框色
  popover: string
  popoverForeground: string

  // 主要边框色
  border: string
  input: string
  ring: string

  // 状态色
  destructive: string
  destructiveForeground: string

  // 警告色
  warning: string
  warningForeground: string

  // 成功色
  success: string
  successForeground: string

  // 信息色
  info: string
  infoForeground: string

  // 侧边栏色
  sidebar: string
  sidebarForeground: string
  sidebarAccent: string
  sidebarAccentForeground: string
  sidebarBorder: string
  sidebarRing: string
}

/**
 * 默认主题（亮色）
 */
export const lightTheme: Theme = {
  id: "light",
  name: "亮色",
  description: "默认亮色主题",
  colors: {
    primary: "hsl(222.2 84% 4.9%)",
    primaryForeground: "hsl(210 40% 98%)",

    secondary: "hsl(210 40% 96.1%)",
    secondaryForeground: "hsl(222.2 47.4% 11.2%)",

    background: "hsl(0 0% 100%)",
    foreground: "hsl(222.2 84% 4.9%)",

    card: "hsl(0 0% 100%)",
    cardForeground: "hsl(222.2 84% 4.9%)",

    popover: "hsl(0 0% 100%)",
    popoverForeground: "hsl(222.2 84% 4.9%)",

    border: "hsl(214.3 31.8% 91.4%)",
    input: "hsl(214.3 31.8% 91.4%)",
    ring: "hsl(222.2 84% 4.9%)",

    destructive: "hsl(0 84.2% 60.2%)",
    destructiveForeground: "hsl(210 40% 98%)",

    warning: "hsl(38 92% 50%)",
    warningForeground: "hsl(48 96% 89%)",

    success: "hsl(142 76% 36%)",
    successForeground: "hsl(355.7 100% 97.3%)",

    info: "hsl(217 91% 60%)",
    infoForeground: "hsl(210 40% 98%)",

    sidebar: "hsl(0 0% 98%)",
    sidebarForeground: "hsl(240 5.3% 26.1%)",
    sidebarAccent: "hsl(240 4.8% 95.9%)",
    sidebarAccentForeground: "hsl(240 5.9% 10%)",
    sidebarBorder: "hsl(220 13% 91%)",
    sidebarRing: "hsl(217.2 91.2% 59.8%)",
  },
}

/**
 * 暗色主题
 */
export const darkTheme: Theme = {
  id: "dark",
  name: "暗色",
  description: "护眼暗色主题",
  colors: {
    primary: "hsl(210 40% 98%)",
    primaryForeground: "hsl(222.2 47.4% 11.2%)",

    secondary: "hsl(217.2 32.6% 17.5%)",
    secondaryForeground: "hsl(210 40% 98%)",

    background: "hsl(222.2 84% 4.9%)",
    foreground: "hsl(210 40% 98%)",

    card: "hsl(222.2 84% 4.9%)",
    cardForeground: "hsl(210 40% 98%)",

    popover: "hsl(222.2 84% 4.9%)",
    popoverForeground: "hsl(210 40% 98%)",

    border: "hsl(217.2 32.6% 17.5%)",
    input: "hsl(217.2 32.6% 17.5%)",
    ring: "hsl(212.7 26.8% 83.9%)",

    destructive: "hsl(0 62.8% 30.6%)",
    destructiveForeground: "hsl(210 40% 98%)",

    warning: "hsl(38 92% 50%)",
    warningForeground: "hsl(48 96% 89%)",

    success: "hsl(142 76% 36%)",
    successForeground: "hsl(355.7 100% 97.3%)",

    info: "hsl(217 91% 60%)",
    infoForeground: "hsl(210 40% 98%)",

    sidebar: "hsl(240 5.9% 10%)",
    sidebarForeground: "hsl(240 4.8% 95.9%)",
    sidebarAccent: "hsl(240 3.7% 15.9%)",
    sidebarAccentForeground: "hsl(240 4.8% 95.9%)",
    sidebarBorder: "hsl(240 3.7% 15.9%)",
    sidebarRing: "hsl(217.2 91.2% 59.8%)",
  },
}

/**
 * 蓝色主题
 */
export const blueTheme: Theme = {
  id: "blue",
  name: "蓝色",
  description: "专业蓝色主题",
  colors: {
    primary: "hsl(221 83% 53%)",
    primaryForeground: "hsl(210 40% 98%)",

    secondary: "hsl(210 40% 96.1%)",
    secondaryForeground: "hsl(222.2 47.4% 11.2%)",

    background: "hsl(0 0% 100%)",
    foreground: "hsl(222.2 84% 4.9%)",

    card: "hsl(0 0% 100%)",
    cardForeground: "hsl(222.2 84% 4.9%)",

    popover: "hsl(0 0% 100%)",
    popoverForeground: "hsl(222.2 84% 4.9%)",

    border: "hsl(214.3 31.8% 91.4%)",
    input: "hsl(214.3 31.8% 91.4%)",
    ring: "hsl(221 83% 53%)",

    destructive: "hsl(0 84.2% 60.2%)",
    destructiveForeground: "hsl(210 40% 98%)",

    warning: "hsl(38 92% 50%)",
    warningForeground: "hsl(48 96% 89%)",

    success: "hsl(142 76% 36%)",
    successForeground: "hsl(355.7 100% 97.3%)",

    info: "hsl(217 91% 60%)",
    infoForeground: "hsl(210 40% 98%)",

    sidebar: "hsl(210 40% 98%)",
    sidebarForeground: "hsl(222.2 47.4% 11.2%)",
    sidebarAccent: "hsl(210 40% 96.1%)",
    sidebarAccentForeground: "hsl(222.2 47.4% 11.2%)",
    sidebarBorder: "hsl(214.3 31.8% 91.4%)",
    sidebarRing: "hsl(221 83% 53%)",
  },
}

/**
 * 绿色主题
 */
export const greenTheme: Theme = {
  id: "green",
  name: "绿色",
  description: "自然绿色主题",
  colors: {
    primary: "hsl(142 76% 36%)",
    primaryForeground: "hsl(355.7 100% 97.3%)",

    secondary: "hsl(210 40% 96.1%)",
    secondaryForeground: "hsl(222.2 47.4% 11.2%)",

    background: "hsl(0 0% 100%)",
    foreground: "hsl(222.2 84% 4.9%)",

    card: "hsl(0 0% 100%)",
    cardForeground: "hsl(222.2 84% 4.9%)",

    popover: "hsl(0 0% 100%)",
    popoverForeground: "hsl(222.2 84% 4.9%)",

    border: "hsl(214.3 31.8% 91.4%)",
    input: "hsl(214.3 31.8% 91.4%)",
    ring: "hsl(142 76% 36%)",

    destructive: "hsl(0 84.2% 60.2%)",
    destructiveForeground: "hsl(210 40% 98%)",

    warning: "hsl(38 92% 50%)",
    warningForeground: "hsl(48 96% 89%)",

    success: "hsl(142 76% 36%)",
    successForeground: "hsl(355.7 100% 97.3%)",

    info: "hsl(217 91% 60%)",
    infoForeground: "hsl(210 40% 98%)",

    sidebar: "hsl(142 76% 97%)",
    sidebarForeground: "hsl(142 76% 20%)",
    sidebarAccent: "hsl(142 76% 94%)",
    sidebarAccentForeground: "hsl(142 76% 20%)",
    sidebarBorder: "hsl(142 76% 90%)",
    sidebarRing: "hsl(142 76% 36%)",
  },
}

/**
 * 所有可用主题
 */
export const themes: Theme[] = [lightTheme, darkTheme, blueTheme, greenTheme]

/**
 * 根据ID获取主题
 */
export function getThemeById(id: string): Theme {
  return themes.find(theme => theme.id === id) || lightTheme
}
