import { cn } from "@/lib/utils"

describe("cn", () => {
  it("merges class names", () => {
    expect(cn("a", "b")).toBe("a b")
  })

  it("handles tailwind conflicts via tailwind-merge", () => {
    expect(cn("px-2", "px-4")).toBe("px-4")
  })
})
