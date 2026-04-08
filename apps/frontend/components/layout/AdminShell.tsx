"use client"

import type React from "react"

interface AdminShellProps {
  sidebar: React.ReactNode
  title: string
  children: React.ReactNode
}

export function AdminShell({ sidebar, title, children }: AdminShellProps) {
  return (
    <div className="flex min-h-svh w-full bg-background text-foreground">
      {sidebar}
      <div className="flex min-w-0 flex-1 flex-col">
        <header className="flex-shrink-0 border-b bg-card shadow-sm">
          <div className="px-6 py-4">
            <h1 className="text-xl font-semibold">{title}</h1>
          </div>
        </header>
        <main className="flex-1 overflow-auto p-6">{children}</main>
      </div>
    </div>
  )
}
