"use client"

import { useState, useEffect } from "react"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Badge } from "@/components/ui/badge"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"
import { Dialog, DialogContent, DialogDescription, DialogFooter, DialogHeader, DialogTitle } from "@/components/ui/dialog"
import { Label } from "@/components/ui/label"
import { Textarea } from "@/components/ui/textarea"
import { toast } from "@/hooks/use-toast"
import { WorkflowCard } from "@/components/workflow/workflow-card"
import { WorkflowEditor } from "@/components/workflow/workflow-editor"
import {
  getWorkflowsWithToast,
  createWorkflowWithToast,
  deleteWorkflowWithToast,
  type Workflow
} from "@/lib/workflow-service"

export default function WorkflowsPage() {
  const [workflows, setWorkflows] = useState<Workflow[]>([])
  const [loading, setLoading] = useState(true)
  const [searchQuery, setSearchQuery] = useState("")
  const [activeTab, setActiveTab] = useState("all")
  const [selectedWorkflow, setSelectedWorkflow] = useState<Workflow | null>(null)
  const [isEditorOpen, setIsEditorOpen] = useState(false)
  const [isCreateDialogOpen, setIsCreateDialogOpen] = useState(false)
  const [newWorkflow, setNewWorkflow] = useState({ name: "", description: "" })

  // 获取工作流列表
  const fetchWorkflows = async () => {
    try {
      setLoading(true)
      const response = await getWorkflowsWithToast()
      if (response.code === 200) {
        setWorkflows(response.data)
      }
    } catch (error) {
      console.error("获取工作流列表失败:", error)
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => {
    fetchWorkflows()
  }, [])

  // 过滤工作流
  const filteredWorkflows = workflows.filter(workflow => {
    const matchesSearch = workflow.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
                         workflow.description.toLowerCase().includes(searchQuery.toLowerCase())
    const matchesTab = activeTab === "all" ||
                      (activeTab === "draft" && workflow.status === "draft") ||
                      (activeTab === "published" && workflow.status === "published") ||
                      (activeTab === "archived" && workflow.status === "archived")
    return matchesSearch && matchesTab
  })

  // 创建新工作流
  const handleCreateWorkflow = async () => {
    try {
      if (!newWorkflow.name.trim()) {
        toast({ description: "工作流名称不能为空", variant: "destructive" })
        return
      }

      const response = await createWorkflowWithToast({
        name: newWorkflow.name,
        description: newWorkflow.description,
        definition: JSON.stringify({
          nodes: [
            { id: "start", name: "开始", type: "start", nextNodes: ["end"] },
            { id: "end", name: "结束", type: "end" }
          ]
        })
      })

      if (response.code === 200) {
        toast({ description: "工作流创建成功" })
        setIsCreateDialogOpen(false)
        setNewWorkflow({ name: "", description: "" })
        fetchWorkflows()
      }
    } catch (error) {
      toast({ description: "创建工作流失败", variant: "destructive" })
    }
  }

  // 编辑工作流
  const handleEditWorkflow = (workflow: Workflow) => {
    setSelectedWorkflow(workflow)
    setIsEditorOpen(true)
  }

  // 删除工作流
  const handleDeleteWorkflow = async (workflow: Workflow) => {
    try {
      await deleteWorkflowWithToast(workflow.id)
      toast({ description: "工作流已删除" })
      fetchWorkflows()
    } catch (error) {
      toast({ description: "删除工作流失败", variant: "destructive" })
    }
  }

  // 统计信息
  const stats = {
    total: workflows.length,
    draft: workflows.filter(w => w.status === "draft").length,
    published: workflows.filter(w => w.status === "published").length,
    archived: workflows.filter(w => w.status === "archived").length
  }

  return (
    <div className="container mx-auto py-6">
      <div className="flex justify-between items-center mb-6">
        <div>
          <h1 className="text-3xl font-bold">工作流管理</h1>
          <p className="text-muted-foreground">创建和管理工作流</p>
        </div>
        <Button onClick={() => setIsCreateDialogOpen(true)}>
          创建工作流
        </Button>
      </div>

      {/* 统计卡片 */}
      <div className="grid grid-cols-4 gap-4 mb-6">
        <Card>
          <CardHeader className="pb-2">
            <CardTitle className="text-sm font-medium">总工作流数</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{stats.total}</div>
          </CardContent>
        </Card>
        <Card>
          <CardHeader className="pb-2">
            <CardTitle className="text-sm font-medium">草稿</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-gray-600">{stats.draft}</div>
          </CardContent>
        </Card>
        <Card>
          <CardHeader className="pb-2">
            <CardTitle className="text-sm font-medium">已发布</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-green-600">{stats.published}</div>
          </CardContent>
        </Card>
        <Card>
          <CardHeader className="pb-2">
            <CardTitle className="text-sm font-medium">已归档</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-yellow-600">{stats.archived}</div>
          </CardContent>
        </Card>
      </div>

      {/* 搜索和过滤 */}
      <div className="flex gap-4 mb-6">
        <Input
          placeholder="搜索工作流..."
          value={searchQuery}
          onChange={(e) => setSearchQuery(e.target.value)}
          className="max-w-sm"
        />
        <Tabs value={activeTab} onValueChange={setActiveTab}>
          <TabsList>
            <TabsTrigger value="all">全部</TabsTrigger>
            <TabsTrigger value="draft">草稿</TabsTrigger>
            <TabsTrigger value="published">已发布</TabsTrigger>
            <TabsTrigger value="archived">已归档</TabsTrigger>
          </TabsList>
        </Tabs>
      </div>

      {/* 工作流列表 */}
      {loading ? (
        <div className="text-center py-8">加载中...</div>
      ) : filteredWorkflows.length === 0 ? (
        <div className="text-center py-8 text-muted-foreground">
          没有找到工作流
        </div>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
          {filteredWorkflows.map(workflow => (
            <WorkflowCard
              key={workflow.id}
              workflow={workflow}
              onEdit={() => handleEditWorkflow(workflow)}
              onDelete={() => handleDeleteWorkflow(workflow)}
            />
          ))}
        </div>
      )}

      {/* 创建工作流对话框 */}
      <Dialog open={isCreateDialogOpen} onOpenChange={setIsCreateDialogOpen}>
        <DialogContent className="sm:max-w-[500px]">
          <DialogHeader>
            <DialogTitle>创建工作流</DialogTitle>
            <DialogDescription>
              创建新的工作流
            </DialogDescription>
          </DialogHeader>

          <div className="space-y-4">
            <div className="space-y-2">
              <Label>工作流名称</Label>
              <Input
                placeholder="输入工作流名称"
                value={newWorkflow.name}
                onChange={(e) => setNewWorkflow({ ...newWorkflow, name: e.target.value })}
              />
            </div>
            <div className="space-y-2">
              <Label>工作流描述</Label>
              <Textarea
                placeholder="输入工作流描述"
                value={newWorkflow.description}
                onChange={(e) => setNewWorkflow({ ...newWorkflow, description: e.target.value })}
              />
            </div>
          </div>

          <DialogFooter>
            <Button variant="outline" onClick={() => setIsCreateDialogOpen(false)}>
              取消
            </Button>
            <Button onClick={handleCreateWorkflow}>
              创建
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      {/* 工作流编辑器对话框 */}
      <WorkflowEditor
        workflow={selectedWorkflow}
        open={isEditorOpen}
        onOpenChange={setIsEditorOpen}
        onSave={fetchWorkflows}
      />
    </div>
  )
}
