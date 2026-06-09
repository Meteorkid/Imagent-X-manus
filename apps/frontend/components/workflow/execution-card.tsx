"use client"

import { Card, CardContent, CardDescription, CardFooter, CardHeader, CardTitle } from "@/components/ui/card"
import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import { DropdownMenu, DropdownMenuContent, DropdownMenuItem, DropdownMenuTrigger } from "@/components/ui/dropdown-menu"
import { MoreHorizontal, Eye, X, RefreshCw } from "lucide-react"
import { type WorkflowExecution } from "@/lib/workflow-service"

interface ExecutionCardProps {
  execution: WorkflowExecution
  onCancel: () => void
  onRetry: () => void
  onViewDetail: () => void
}

export function ExecutionCard({ execution, onCancel, onRetry, onViewDetail }: ExecutionCardProps) {
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
    const date = new Date(dateString)
    return date.toLocaleString("zh-CN")
  }

  return (
    <Card className="relative">
      <CardHeader className="pb-2">
        <div className="flex justify-between items-start">
          <div className="flex-1">
            <CardTitle className="text-sm font-medium">执行 ID: {execution.id.slice(0, 8)}...</CardTitle>
            <CardDescription className="text-xs">
              工作流: {execution.workflowId.slice(0, 8)}...
            </CardDescription>
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
              {execution.status === "running" && (
                <DropdownMenuItem onClick={onCancel} className="text-red-600">
                  <X className="mr-2 h-4 w-4" />
                  取消
                </DropdownMenuItem>
              )}
              {execution.status === "failed" && (
                <DropdownMenuItem onClick={onRetry}>
                  <RefreshCw className="mr-2 h-4 w-4" />
                  重试
                </DropdownMenuItem>
              )}
            </DropdownMenuContent>
          </DropdownMenu>
        </div>
      </CardHeader>
      <CardContent className="pb-2">
        <div className="flex justify-between items-center mb-2">
          {getStatusBadge(execution.status)}
          <span className="text-sm text-muted-foreground">
            耗时: {formatDuration(execution.duration)}
          </span>
        </div>
        {execution.errorMessage && (
          <div className="text-sm text-red-500 truncate">
            错误: {execution.errorMessage}
          </div>
        )}
      </CardContent>
      <CardFooter className="pt-2">
        <div className="flex justify-between items-center w-full text-xs text-muted-foreground">
          <span>开始: {formatDate(execution.startTime)}</span>
          <span>重试: {execution.retryCount}次</span>
        </div>
      </CardFooter>
    </Card>
  )
}
