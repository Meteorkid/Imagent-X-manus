"use client"

import { useState, useEffect } from "react"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"
import { toast } from "@/hooks/use-toast"
import { ExecutionCard } from "@/components/workflow/execution-card"
import { ExecutionDetailDialog } from "@/components/workflow/execution-detail-dialog"
import {
  getExecutionsWithToast,
  cancelExecutionWithToast,
  retryExecutionWithToast,
  type WorkflowExecution
} from "@/lib/workflow-service"

export default function WorkflowMonitorPage() {
  const [executions, setExecutions] = useState<WorkflowExecution[]>([])
  const [loading, setLoading] = useState(true)
  const [searchQuery, setSearchQuery] = useState("")
  const [activeTab, setActiveTab] = useState("all")
  const [selectedExecution, setSelectedExecution] = useState<WorkflowExecution | null>(null)
  const [isDetailOpen, setIsDetailOpen] = useState(false)

  // 获取执行记录列表
  const fetchExecutions = async () => {
    try {
      setLoading(true)
      const response = await getExecutionsWithToast()
      if (response.code === 200) {
        setExecutions(response.data)
      }
    } catch (error) {
      console.error("获取执行记录失败:", error)
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => {
    fetchExecutions()
    // 每30秒刷新一次
    const interval = setInterval(fetchExecutions, 30000)
    return () => clearInterval(interval)
  }, [])

  // 过滤执行记录
  const filteredExecutions = executions.filter(execution => {
    const matchesSearch = execution.workflowId.toLowerCase().includes(searchQuery.toLowerCase()) ||
                         execution.id.toLowerCase().includes(searchQuery.toLowerCase())
    const matchesTab = activeTab === "all" ||
                      (activeTab === "running" && execution.status === "running") ||
                      (activeTab === "completed" && execution.status === "completed") ||
                      (activeTab === "failed" && execution.status === "failed") ||
                      (activeTab === "pending" && execution.status === "pending")
    return matchesSearch && matchesTab
  })

  // 取消执行
  const handleCancelExecution = async (execution: WorkflowExecution) => {
    try {
      await cancelExecutionWithToast(execution.id)
      toast({ description: "执行已取消" })
      fetchExecutions()
    } catch (error) {
      toast({ description: "取消执行失败", variant: "destructive" })
    }
  }

  // 重试执行
  const handleRetryExecution = async (execution: WorkflowExecution) => {
    try {
      await retryExecutionWithToast(execution.id)
      toast({ description: "执行已重试" })
      fetchExecutions()
    } catch (error) {
      toast({ description: "重试执行失败", variant: "destructive" })
    }
  }

  // 查看详情
  const handleViewDetail = (execution: WorkflowExecution) => {
    setSelectedExecution(execution)
    setIsDetailOpen(true)
  }

  // 统计信息
  const stats = {
    total: executions.length,
    running: executions.filter(e => e.status === "running").length,
    completed: executions.filter(e => e.status === "completed").length,
    failed: executions.filter(e => e.status === "failed").length,
    pending: executions.filter(e => e.status === "pending").length
  }

  return (
    <div className="container mx-auto py-6">
      <div className="flex justify-between items-center mb-6">
        <div>
          <h1 className="text-3xl font-bold">工作流监控</h1>
          <p className="text-muted-foreground">实时监控工作流执行状态</p>
        </div>
        <Button onClick={fetchExecutions}>
          刷新
        </Button>
      </div>

      {/* 统计卡片 */}
      <div className="grid grid-cols-5 gap-4 mb-6">
        <Card>
          <CardHeader className="pb-2">
            <CardTitle className="text-sm font-medium">总执行数</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{stats.total}</div>
          </CardContent>
        </Card>
        <Card>
          <CardHeader className="pb-2">
            <CardTitle className="text-sm font-medium">执行中</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-blue-600">{stats.running}</div>
          </CardContent>
        </Card>
        <Card>
          <CardHeader className="pb-2">
            <CardTitle className="text-sm font-medium">已完成</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-green-600">{stats.completed}</div>
          </CardContent>
        </Card>
        <Card>
          <CardHeader className="pb-2">
            <CardTitle className="text-sm font-medium">失败</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-red-600">{stats.failed}</div>
          </CardContent>
        </Card>
        <Card>
          <CardHeader className="pb-2">
            <CardTitle className="text-sm font-medium">等待中</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-yellow-600">{stats.pending}</div>
          </CardContent>
        </Card>
      </div>

      {/* 搜索和过滤 */}
      <div className="flex gap-4 mb-6">
        <Input
          placeholder="搜索执行记录..."
          value={searchQuery}
          onChange={(e) => setSearchQuery(e.target.value)}
          className="max-w-sm"
        />
        <Tabs value={activeTab} onValueChange={setActiveTab}>
          <TabsList>
            <TabsTrigger value="all">全部</TabsTrigger>
            <TabsTrigger value="running">执行中</TabsTrigger>
            <TabsTrigger value="completed">已完成</TabsTrigger>
            <TabsTrigger value="failed">失败</TabsTrigger>
            <TabsTrigger value="pending">等待中</TabsTrigger>
          </TabsList>
        </Tabs>
      </div>

      {/* 执行记录列表 */}
      {loading ? (
        <div className="text-center py-8">加载中...</div>
      ) : filteredExecutions.length === 0 ? (
        <div className="text-center py-8 text-muted-foreground">
          没有找到执行记录
        </div>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
          {filteredExecutions.map(execution => (
            <ExecutionCard
              key={execution.id}
              execution={execution}
              onCancel={() => handleCancelExecution(execution)}
              onRetry={() => handleRetryExecution(execution)}
              onViewDetail={() => handleViewDetail(execution)}
            />
          ))}
        </div>
      )}

      {/* 执行详情对话框 */}
      <ExecutionDetailDialog
        execution={selectedExecution}
        open={isDetailOpen}
        onOpenChange={setIsDetailOpen}
      />
    </div>
  )
}
