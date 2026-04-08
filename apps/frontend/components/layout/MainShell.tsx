"use client"

import type React from "react"

interface MainShellProps {
  header?: React.ReactNode
  children: React.ReactNode
}

export function MainShell({ header, children }: MainShellProps) {
  return (
    <div className="relative flex min-h-svh flex-col bg-background text-foreground">
      {header}
      <main className="flex min-h-0 flex-1">
        <div className="flex w-full min-h-0 flex-1">{children}</div>
      </main>
    </div>
  )
}
