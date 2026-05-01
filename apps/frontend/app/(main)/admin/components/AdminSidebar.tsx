"use client";

import React from "react";
import Link from "next/link";
import { usePathname } from "next/navigation";
import { cn } from "@/lib/utils";
import { 
  Users, 
  Wrench, 
  Bot, 
  Server,
  Settings,
  Home,
  Shield,
  Container,
  CreditCard,
  BookOpen,
  Database,
  Package,
  FileText,
  FlaskConical
} from "lucide-react";

interface MenuItemProps {
  href: string;
  icon: React.ComponentType<{ className?: string }>;
  label: string;
  isActive: boolean;
}

function MenuItem({ href, icon: Icon, label, isActive }: MenuItemProps) {
  return (
    <Link
      href={href}
      className={cn(
        "flex items-center px-4 py-3 text-sm font-medium rounded-lg transition-colors",
        isActive
          ? "border-r-2 border-primary bg-primary/10 text-primary"
          : "text-muted-foreground hover:bg-muted/30 hover:text-foreground"
      )}
    >
      <Icon className={cn("mr-3 h-5 w-5", isActive ? "text-primary" : "text-muted-foreground")} />
      {label}
    </Link>
  );
}

export function AdminSidebar() {
  const pathname = usePathname();

  const menuItems = [
    {
      href: "/admin",
      icon: Home,
      label: "管理首页",
    },
    {
      href: "/admin/users",
      icon: Users,
      label: "用户列表",
    },
    {
      href: "/admin/tools",
      icon: Wrench,
      label: "工具列表",
    },
    {
      href: "/admin/agents",
      icon: Bot,
      label: "Agent列表",
    },
    {
      href: "/admin/rags",
      icon: Database,
      label: "RAG管理",
    },
    {
      href: "/admin/providers",
      icon: Server,
      label: "服务商管理",
    },
    {
      href: "/admin/containers",
      icon: Container,
      label: "容器管理",
    },
    {
      href: "/admin/products",
      icon: CreditCard,
      label: "商品管理",
    },
    {
      href: "/admin/orders",
      icon: Package,
      label: "订单管理",
    },
    {
      href: "/admin/rules",
      icon: BookOpen,
      label: "规则管理",
    },
    {
      href: "/admin/offline-audit",
      icon: FileText,
      label: "离线配置审计",
    },
    {
      href: "/admin/offline-experiments",
      icon: FlaskConical,
      label: "离线实验配置",
    },
    {
      href: "/admin/auth-settings",
      icon: Shield,
      label: "认证配置",
    },
  ];

  return (
    <div className="flex h-full min-h-svh w-64 flex-col border-r border-border bg-card shadow-sm">
      {/* Logo区域 */}
      <div className="p-6 border-b border-border flex-shrink-0">
        <div className="flex items-center">
          <div className="flex h-8 w-8 items-center justify-center rounded-lg bg-primary">
            <Settings className="w-5 h-5 text-white" />
          </div>
          <span className="ml-3 text-lg font-semibold text-foreground">Imagent X Admin</span>
        </div>
      </div>

      {/* 菜单列表 */}
      <nav className="p-4 space-y-1 flex-1 overflow-y-auto">
        {menuItems.map((item) => (
          <MenuItem
            key={item.href}
            href={item.href}
            icon={item.icon}
            label={item.label}
            isActive={
              pathname === item.href || 
              (item.href === "/admin" && pathname === "/admin") ||
              (item.href !== "/admin" && pathname.startsWith(item.href))
            }
          />
        ))}
      </nav>

      {/* 底部信息 */}
      <div className="p-4 border-t border-border flex-shrink-0">
        <div className="text-xs text-muted-foreground text-center">
          Imagent X 管理后台
          <br />
          v1.0.0
        </div>
      </div>
    </div>
  );
}