"use client";

import React from "react";
import { AdminSidebar } from "./components/AdminSidebar";
import { AdminShell } from "@/components/layout/AdminShell";

export default function AdminLayout({ children }: { children: React.ReactNode }) {
  return (
    <AdminShell sidebar={<AdminSidebar />} title="管理后台">
      {children}
    </AdminShell>
  );
}