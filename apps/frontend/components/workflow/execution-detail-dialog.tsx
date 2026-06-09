"use client"

import { Dialog, DialogContent, DialogDescription, DialogHeader, DialogTitle } from "@/components/ui/dialog"
import { Badge } from "@/components/ui/badge"
import { Separator } from "@/components/ui/separator"
import { ScrollArea } from "@/components/ui/scroll-area"
import { type WorkflowExecution } from "@/lib/workflow-service"

interface ExecutionDetailDialogProps {
  execution: WorkflowExecution | null
  open: boolean
  onOpenChange: (open: boolean) => void
}

export function ExecutionDetailDialog({ execution, open, onOpenChange }: ExecutionDetailDialogProps) {
  if (!execution) return null

  const getStatusBadge = (status: string) => {
    switch (status) {
      case "running":
        return <Badge className="bg-blue-500">执行中</Badge>
      case "completed":
        return <Badge className="bg-green-500">已完成</Badge>
      case "failed":
        return <Badge className="bg-red-500">失败</Badge>
      case "pending":
        return <Badge className="bg-yellow-500">等待中</Badge>
      case "cancelled":
        return <Badge className="bg-gray-500">已取消</Badge>
      case "paused":
        return <Badge className="bg-orange-500">暂停中</Badge>
      default:
        return <Badge>{status}</Badge>
    }
  }

  const formatDuration = (ms: number) => {
    if (!ms) return "未知"
    const seconds = Math.floor(ms / 1000)
    const minutes = Math.floor(seconds / 60)
    const hours = Math.floor(minutes / 60)

    if (hours > 0) {
      return `${hours}小时${minutes % 60}分钟`
    } else if (minutes > 0) {
      return `${minutes}分钟${seconds % 60}秒`
    } else {
      return `${seconds}秒`
    }
  }

  const formatDate = (dateString: string) => {
    if (!dateString) return "未知"
    return new Date(dateString).toLocaleString("zh-CN")
  }

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="sm:max-w-[700px] max-h-[80vh]">
        <DialogHeader>
          <DialogTitle>执行详情</DialogTitle>
          <DialogDescription>
            执行 ID: {execution.id}
          </DialogDescription>
        </DialogHeader>

        <ScrollArea className="max-h-[60vh]">
          <div className="space-y-4">
            {/* 基本信息 */}
            <div className="grid grid-cols-2 gap-4">
              <div>
                <div className="text-sm font-medium text-muted-foreground">状态</div>
                <div>{getStatusBadge(execution.status)}</div>
              </div>
              <div>
                <div className="text-sm font-medium text-muted-foreground">工作流ID</div>
                <div className="text-sm">{execution.workflowId}</div>
              </div>
              <div>
                <div className="text-sm font-medium text-muted-foreground">当前节点</div>
                <div>{execution.currentNodeId || "无"}</div>
              </div>
              <div>
                <div className="text-sm font-medium text-muted-foreground">耗时</div>
                <div>{formatDuration(execution.duration)}</div>
              </div>
            </div>

            <Separator />

            {/* 时间信息 */}
            <div className="grid grid-cols-2 gap-4">
              <div>
                <div className="text-sm font-medium text-muted-foreground">开始时间</div>
                <div className="text-sm">{formatDate(execution.startTime)}</div>
              </div>
              <div>
                <div className="text-sm font-medium text-muted-foreground">结束时间</div>
                <div className="text-sm">{formatDate(execution.endTime)}</div>
              </div>
              <div>
                <div className="text-sm font-medium text-muted-foreground">执行者</div>
                <div>{execution.executedBy || "系统"}</div>
              </div>
              <div>
                <div className="text-sm font-medium text-muted-foreground">重试次数</div>
                <div>{execution.retryCount}</div>
              </div>
            </div>

            <Separator />

            {/* 输入参数 */}
            {execution.inputs && Object.keys(execution.inputs).length > 0 && (
              <div>
                <div className="text-sm font-medium text-muted-foreground mb-2">输入参数</div>
                <div className="bg-muted p-3 rounded-md text-sm">
                  <pre className="whitespace-pre-wrap">
                    {JSON.stringify(execution.inputs, null, 2)}
                  </pre>
                </div>
              </div>
            )}

            {/* 输出参数 */}
            {execution.outputs && Object.keys(execution.outputs).length > 0 && (
              <div>
                <div className="text-sm font-medium text-muted-foreground mb-2">输出参数</div>
                <div className="bg-muted p-3 rounded-md text-sm">
                  <pre className="whitespace-pre-wrap">
                    {JSON.stringify(execution.outputs, null, 2)}
                  </pre>
                </div>
              </div>
            )}

            {/* 错误信息 */}
            {execution.errorMessage && (
              <div>
                <div className="text-sm font-medium text-muted-foreground mb-2">错误信息</div>
                <div className="bg-red-50 p-3 rounded-md text-sm text-red-600">
                  {execution.errorMessage}
                </div>
              </div>
            )}

            {/* 执行日志 */}
            {execution.logs && (
              <div>
                <div className="text-sm font-medium text-muted-foreground mb-2">执行日志</div>
                <div className="bg-muted p-3 rounded-md text-sm">
                  <pre className="whitespace-pre-wrap text-xs">{execution.logs}</pre>
                </div>
              </div>
            )}
          </div>
        </ScrollArea>
      </DialogContent>
    </Dialog>
  )
}
