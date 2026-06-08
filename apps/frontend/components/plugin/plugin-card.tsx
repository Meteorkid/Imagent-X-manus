"use client"

import { Card, CardContent, CardDescription, CardFooter, CardHeader, CardTitle } from "@/components/ui/card"
import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import { Switch } from "@/components/ui/switch"
import { DropdownMenu, DropdownMenuContent, DropdownMenuItem, DropdownMenuTrigger } from "@/components/ui/dropdown-menu"
import { MoreHorizontal, Settings, Trash2, Eye } from "lucide-react"
import { type PluginInfo } from "@/lib/plugin-service"

interface PluginCardProps {
  plugin: PluginInfo
  onToggle: () => void
  onUninstall: () => void
  onViewDetail: () => void
}

export function PluginCard({ plugin, onToggle, onUninstall, onViewDetail }: PluginCardProps) {
  const getStatusBadge = (status: string) => {
    switch (status) {
      case "enabled":
        return <Badge className="bg-green-500">已启用</Badge>
      case "disabled":
        return <Badge className="bg-gray-500">已禁用</Badge>
      case "error":
        return <Badge className="bg-red-500">错误</Badge>
      case "loading":
        return <Badge className="bg-yellow-500">加载中</Badge>
      default:
        return <Badge>{status}</Badge>
    }
  }

  const getTypeBadge = (type: string) => {
    switch (type) {
      case "tool":
        return <Badge variant="outline">工具</Badge>
      case "connector":
        return <Badge variant="outline">连接器</Badge>
      case "processor":
        return <Badge variant="outline">处理器</Badge>
      case "extension":
        return <Badge variant="outline">扩展</Badge>
      case "ui":
        return <Badge variant="outline">UI</Badge>
      default:
        return <Badge variant="outline">{type}</Badge>
    }
  }

  return (
    <Card className="relative">
      <CardHeader className="pb-2">
        <div className="flex justify-between items-start">
          <div className="flex-1">
            <CardTitle className="text-lg">{plugin.name}</CardTitle>
            <CardDescription className="text-sm">{plugin.version}</CardDescription>
          </div>
          <DropdownMenu>
            <DropdownMenuTrigger asChild>
              <Button variant="ghost" size="icon" className="h-8 w-8">
                <MoreHorizontal className="h-4 w-4" />
              </Button>
            </DropdownMenuTrigger>
            <DropdownMenuContent align="end">
              <DropdownMenuItem onClick={onViewDetail}>
                <Eye className="mr-2 h-4 w-4" />
                查看详情
              </DropdownMenuItem>
              <DropdownMenuItem>
                <Settings className="mr-2 h-4 w-4" />
                配置
              </DropdownMenuItem>
              <DropdownMenuItem onClick={onUninstall} className="text-red-600">
                <Trash2 className="mr-2 h-4 w-4" />
                卸载
              </DropdownMenuItem>
            </DropdownMenuContent>
          </DropdownMenu>
        </div>
      </CardHeader>
      <CardContent className="pb-2">
        <p className="text-sm text-muted-foreground mb-3 line-clamp-2">
          {plugin.description || "暂无描述"}
        </p>
        <div className="flex gap-2">
          {getStatusBadge(plugin.status)}
          {getTypeBadge(plugin.type)}
        </div>
      </CardContent>
      <CardFooter className="pt-2">
        <div className="flex justify-between items-center w-full">
          <div className="text-sm text-muted-foreground">
            作者: {plugin.author || "未知"}
          </div>
          <Switch
            checked={plugin.status === "enabled"}
            onCheckedChange={onToggle}
            disabled={plugin.status === "error"}
          />
        </div>
      </CardFooter>
    </Card>
  )
}
