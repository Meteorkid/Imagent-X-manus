"use client"

import { Card, CardContent, CardDescription, CardFooter, CardHeader, CardTitle } from "@/components/ui/card"
import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import { DropdownMenu, DropdownMenuContent, DropdownMenuItem, DropdownMenuTrigger } from "@/components/ui/dropdown-menu"
import { MoreHorizontal, Edit, Trash2, Play, Copy } from "lucide-react"
import { type Workflow } from "@/lib/workflow-service"

interface WorkflowCardProps {
  workflow: Workflow
  onEdit: () => void
  onDelete: () => void
}

export function WorkflowCard({ workflow, onEdit, onDelete }: WorkflowCardProps) {
  const getStatusBadge = (status: string) => {
    switch (status) {
      case "draft":
        return <Badge className="bg-gray-500">草稿</Badge>
      case "published":
        return <Badge className="bg-green-500">已发布</Badge>
      case "archived":
        return <Badge className="bg-yellow-500">已归档</Badge>
      case "disabled":
        return <Badge className="bg-red-500">已禁用</Badge>
      default:
        return <Badge>{status}</Badge>
    }
  }

  const formatDate = (dateString: string) => {
    if (!dateString) return "未知"
    const date = new Date(dateString)
    return date.toLocaleDateString("zh-CN", {
      year: "numeric",
      month: "2-digit",
      day: "2-digit",
      hour: "2-digit",
      minute: "2-digit"
    })
  }

  return (
    <Card className="relative">
      <CardHeader className="pb-2">
        <div className="flex justify-between items-start">
          <div className="flex-1">
            <CardTitle className="text-lg">{workflow.name}</CardTitle>
            <CardDescription className="text-sm">{workflow.version || "1.0.0"}</CardDescription>
          </div>
          <DropdownMenu>
            <DropdownMenuTrigger asChild>
              <Button variant="ghost" size="icon" className="h-8 w-8">
                <MoreHorizontal className="h-4 w-4" />
              </Button>
            </DropdownMenuTrigger>
            <DropdownMenuContent align="end">
              <DropdownMenuItem onClick={onEdit}>
                <Edit className="mr-2 h-4 w-4" />
                编辑
              </DropdownMenuItem>
              <DropdownMenuItem>
                <Copy className="mr-2 h-4 w-4" />
                复制
              </DropdownMenuItem>
              <DropdownMenuItem>
                <Play className="mr-2 h-4 w-4" />
                执行
              </DropdownMenuItem>
              <DropdownMenuItem onClick={onDelete} className="text-red-600">
                <Trash2 className="mr-2 h-4 w-4" />
                删除
              </DropdownMenuItem>
            </DropdownMenuContent>
          </DropdownMenu>
        </div>
      </CardHeader>
      <CardContent className="pb-2">
        <p className="text-sm text-muted-foreground mb-3 line-clamp-2">
          {workflow.description || "暂无描述"}
        </p>
        <div className="flex gap-2">
          {getStatusBadge(workflow.status)}
        </div>
      </CardContent>
      <CardFooter className="pt-2">
        <div className="flex justify-between items-center w-full text-sm text-muted-foreground">
          <span>执行次数: {workflow.executionCount || 0}</span>
          <span>{formatDate(workflow.updatedAt || workflow.createdAt)}</span>
        </div>
      </CardFooter>
    </Card>
  )
}
