"use client"

import { Dialog, DialogContent, DialogDescription, DialogFooter, DialogHeader, DialogTitle } from "@/components/ui/dialog"
import { Button } from "@/components/ui/button"
import { Badge } from "@/components/ui/badge"
import { Switch } from "@/components/ui/switch"
import { Separator } from "@/components/ui/separator"
import { type PluginInfo } from "@/lib/plugin-service"

interface PluginDetailDialogProps {
  plugin: PluginInfo | null
  open: boolean
  onOpenChange: (open: boolean) => void
  onToggle: (plugin: PluginInfo) => void
  onUninstall: (plugin: PluginInfo) => void
}

export function PluginDetailDialog({
  plugin,
  open,
  onOpenChange,
  onToggle,
  onUninstall
}: PluginDetailDialogProps) {
  if (!plugin) return null

  const getStatusBadge = (status: string) => {
    switch (status) {
      case "enabled":
        return <Badge className="bg-green-500">已启用</Badge>
      case "disabled":
        return <Badge className="bg-gray-500">已禁用</Badge>
      case "error":
        return <Badge className="bg-red-500">错误</Badge>
      default:
        return <Badge>{status}</Badge>
    }
  }

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="sm:max-w-[500px]">
        <DialogHeader>
          <DialogTitle>{plugin.name}</DialogTitle>
          <DialogDescription>{plugin.description || "暂无描述"}</DialogDescription>
        </DialogHeader>

        <div className="space-y-4">
          {/* 基本信息 */}
          <div className="grid grid-cols-2 gap-4">
            <div>
              <div className="text-sm font-medium text-muted-foreground">版本</div>
              <div>{plugin.version}</div>
            </div>
            <div>
              <div className="text-sm font-medium text-muted-foreground">作者</div>
              <div>{plugin.author || "未知"}</div>
            </div>
            <div>
              <div className="text-sm font-medium text-muted-foreground">类型</div>
              <div>{plugin.type}</div>
            </div>
            <div>
              <div className="text-sm font-medium text-muted-foreground">状态</div>
              <div>{getStatusBadge(plugin.status)}</div>
            </div>
          </div>

          <Separator />

          {/* 状态控制 */}
          <div className="flex items-center justify-between">
            <div>
              <div className="font-medium">启用插件</div>
              <div className="text-sm text-muted-foreground">
                {plugin.status === "enabled" ? "插件正在运行" : "插件已停止"}
              </div>
            </div>
            <Switch
              checked={plugin.status === "enabled"}
              onCheckedChange={() => onToggle(plugin)}
              disabled={plugin.status === "error"}
            />
          </div>

          <Separator />

          {/* 配置信息 */}
          {plugin.config && Object.keys(plugin.config).length > 0 && (
            <div>
              <div className="text-sm font-medium text-muted-foreground mb-2">配置</div>
              <div className="bg-muted p-3 rounded-md text-sm">
                {Object.entries(plugin.config).map(([key, value]) => (
                  <div key={key} className="flex justify-between">
                    <span>{key}:</span>
                    <span className="text-muted-foreground">{String(value)}</span>
                  </div>
                ))}
              </div>
            </div>
          )}

          {/* 依赖信息 */}
          {plugin.dependencies && plugin.dependencies.length > 0 && (
            <div>
              <div className="text-sm font-medium text-muted-foreground mb-2">依赖</div>
              <div className="flex flex-wrap gap-2">
                {plugin.dependencies.map((dep, index) => (
                  <Badge key={index} variant="outline">{dep}</Badge>
                ))}
              </div>
            </div>
          )}

          {/* 时间信息 */}
          <div className="grid grid-cols-2 gap-4 text-sm text-muted-foreground">
            <div>
              <div>安装时间</div>
              <div>{plugin.installedAt || "未知"}</div>
            </div>
            <div>
              <div>最后启动</div>
              <div>{plugin.lastStartedAt || "未知"}</div>
            </div>
          </div>
        </div>

        <DialogFooter>
          <Button variant="outline" onClick={() => onOpenChange(false)}>
            关闭
          </Button>
          <Button
            variant="destructive"
            onClick={() => {
              onUninstall(plugin)
              onOpenChange(false)
            }}
          >
            卸载插件
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  )
}
