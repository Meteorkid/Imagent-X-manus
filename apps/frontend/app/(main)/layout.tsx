"use client"

import type React from "react"
import { usePathname } from "next/navigation"
import { NavigationBar } from "@/components/navigation-bar"
import { MainShell } from "@/components/layout/MainShell"
import { WorkspaceProvider } from "@/contexts/workspace-context"

export default function MainLayout({ children }: { children: React.ReactNode }) {
  const pathname = usePathname()
  const isAdminPage = pathname?.startsWith("/admin")

  return (
    <WorkspaceProvider>
      <MainShell header={!isAdminPage ? <NavigationBar /> : undefined}>{children}</MainShell>
    </WorkspaceProvider>
  )
}