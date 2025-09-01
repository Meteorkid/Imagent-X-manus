// 响应式断点配置

export const breakpoints = {
  xs: '320px',
  sm: '576px',
  md: '768px',
  lg: '992px',
  xl: '1200px',
  xxl: '1400px',
} as const

export const mediaQueries = {
  xs: `@media (min-width: ${breakpoints.xs})`,
  sm: `@media (min-width: ${breakpoints.sm})`,
  md: `@media (min-width: ${breakpoints.md})`,
  lg: `@media (min-width: ${breakpoints.lg})`,
  xl: `@media (min-width: ${breakpoints.xl})`,
  xxl: `@media (min-width: ${breakpoints.xxl})`,
} as const

// 设备类型检测
export const deviceTypes = {
  mobile: 'mobile',
  tablet: 'tablet',
  desktop: 'desktop',
} as const

// 响应式工具函数
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
    window.addEventListener('resize', handleResize)
    
    return () => window.removeEventListener('resize', handleResize)
  }, [])

  return {
    deviceType,
    isMobile,
    isTablet,
    isDesktop,
  }
}
