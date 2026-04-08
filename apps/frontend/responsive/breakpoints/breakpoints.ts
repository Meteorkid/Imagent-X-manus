import { useEffect, useState } from "react"

// 与 Tailwind 默认断点保持一致
export const breakpoints = {
  sm: "640px",
  md: "768px",
  lg: "1024px",
  xl: "1280px",
  "2xl": "1536px",
} as const

export const mediaQueries = {
  sm: `@media (min-width: ${breakpoints.sm})`,
  md: `@media (min-width: ${breakpoints.md})`,
  lg: `@media (min-width: ${breakpoints.lg})`,
  xl: `@media (min-width: ${breakpoints.xl})`,
  "2xl": `@media (min-width: ${breakpoints["2xl"]})`,
} as const

export const deviceTypes = {
  mobile: "mobile",
  tablet: "tablet",
  desktop: "desktop",
} as const

export const useResponsive = () => {
  const [deviceType, setDeviceType] = useState(deviceTypes.desktop)
  const [isMobile, setIsMobile] = useState(false)
  const [isTablet, setIsTablet] = useState(false)
  const [isDesktop, setIsDesktop] = useState(true)

  useEffect(() => {
    const handleResize = () => {
      const width = window.innerWidth

      if (width < 768) {
        setDeviceType(deviceTypes.mobile)
        setIsMobile(true)
        setIsTablet(false)
        setIsDesktop(false)
      } else if (width < 1024) {
        setDeviceType(deviceTypes.tablet)
        setIsMobile(false)
        setIsTablet(true)
        setIsDesktop(false)
      } else {
        setDeviceType(deviceTypes.desktop)
        setIsMobile(false)
        setIsTablet(false)
        setIsDesktop(true)
      }
    }

    handleResize()
    window.addEventListener("resize", handleResize)

    return () => window.removeEventListener("resize", handleResize)
  }, [])

  return {
    deviceType,
    isMobile,
    isTablet,
    isDesktop,
  }
}
