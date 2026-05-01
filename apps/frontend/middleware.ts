import { NextResponse } from "next/server"
import type { NextRequest } from "next/server"

/**
 * 无需登录即可访问的路径（精确匹配或前缀）。
 * 管理员权限仍以服务端 API 校验为准；此处仅保证「已登录」壳层。
 */
const PUBLIC_EXACT = new Set<string>([
  "/login",
  "/register",
  "/reset-password",
  "/offline-demo",
  "/offline-report",
  "/offline-dino/dino",
  "/offline-dino/verify-offline",
  "/offline-dino/test-service-worker",
])

const PUBLIC_PREFIXES = ["/sso/", "/offline-dino/"]

function isPublicPath(pathname: string): boolean {
  if (PUBLIC_EXACT.has(pathname)) return true
  if (PUBLIC_PREFIXES.some((p) => pathname.startsWith(p))) return true
  // 开发/调试页（若存在）
  if (pathname === "/test-static") return true
  return false
}

function hasSessionToken(request: NextRequest): boolean {
  const cookieToken = request.cookies.get("token")?.value
  if (cookieToken) return true
  const auth = request.headers.get("authorization")
  if (auth?.startsWith("Bearer ")) return true
  return false
}

export function middleware(request: NextRequest) {
  const { pathname } = request.nextUrl

  // BFF 代理与 Next 内部资源：不做 HTML 登录重定向，避免破坏 JSON/API
  if (pathname.startsWith("/api") || pathname.startsWith("/_next") || pathname.startsWith("/favicon")) {
    return NextResponse.next()
  }

  // 带扩展名的静态资源（如 .svg、.ico、离线小游戏资源等）
  if (/\.[a-zA-Z0-9]+$/.test(pathname) && !pathname.endsWith(".html")) {
    return NextResponse.next()
  }

  const token = hasSessionToken(request)

  if (isPublicPath(pathname)) {
    if (token && (pathname === "/login" || pathname === "/register")) {
      return NextResponse.redirect(new URL("/", request.url))
    }
    return NextResponse.next()
  }

  if (!token) {
    const loginUrl = new URL("/login", request.url)
    loginUrl.searchParams.set("callbackUrl", pathname + request.nextUrl.search)
    return NextResponse.redirect(loginUrl)
  }

  return NextResponse.next()
}

export const config = {
  matcher: [
    /*
     * 排除 _next 静态资源与常见文件；其余页面路由走鉴权。
     */
    "/((?!_next/static|_next/image|favicon.ico).*)",
  ],
}
