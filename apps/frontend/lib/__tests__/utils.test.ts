import { cn } from "@/lib/utils"
import { deleteCookie, formatDate, getCookie, setCookie } from "@/lib/utils"

describe("cn", () => {
  it("merges class names", () => {
    expect(cn("a", "b")).toBe("a b")
  })

  it("handles tailwind conflicts via tailwind-merge", () => {
    expect(cn("px-2", "px-4")).toBe("px-4")
  })
})

describe("cookie utils", () => {
  afterEach(() => {
    deleteCookie("token")
  })

  it("sets and gets cookie values", () => {
    setCookie("token", "abc123", 1)
    expect(getCookie("token")).toBe("abc123")
  })

  it("deletes cookie values", () => {
    setCookie("token", "abc123", 1)
    deleteCookie("token")
    expect(getCookie("token")).toBeNull()
  })
})

describe("formatDate", () => {
  it("formats date as yyyy-mm-dd", () => {
    expect(formatDate(new Date("2026-04-13T09:10:11.000Z"))).toBe("2026-04-13")
  })
})
