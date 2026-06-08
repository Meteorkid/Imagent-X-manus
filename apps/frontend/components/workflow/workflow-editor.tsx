"use client"

import { useState, useEffect } from "react"
import { Dialog, DialogContent, DialogDescription, DialogFooter, DialogHeader, DialogTitle } from "@/components/ui/dialog"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { Textarea } from "@/components/ui/textarea"
import { toast } from "@/hooks/use-toast"
import { updateWorkflowWithToast, type Workflow } from "@/lib/workflow-service"

interface WorkflowEditorProps {
  workflow: Workflow | null
  open: boolean
  onOpenChange: (open: boolean) => void
  onSave: () => void
}

export function WorkflowEditor({ workflow, open, onOpenChange, onSave }: WorkflowEditorProps) {
  const [name, setName] = useState("")
  const [description, setDescription] = useState("")
  const [definition, setDefinition] = useState("")
  const [saving, setSaving] = useState(false)

  useEffect(() => {
    if (workflow) {
      setName(workflow.name)
      setDescription(workflow.description)
      setDefinition(workflow.definition || "")
    }
  }, [workflow])

  const handleSave = async () => {
    if (!workflow) return

    try {
      setSaving(true)

      // 验证 JSON 格式
      try {
        JSON.parse(definition)
      } catch (e) {
        toast({ description: "工作流定义格式错误", variant: "destructive" })
        return
      }

      const response = await updateWorkflowWithToast(workflow.id, {
        name,
        description,
        definition
      })

      if (response.code === 200) {
        toast({ description: "工作流保存成功" })
        onSave()
        onOpenChange(false)
      }
    } catch (error) {
      toast({ description: "保存工作流失败", variant: "destructive" })
    } finally {
      setSaving(false)
    }
  }

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="sm:max-w-[800px] max-h-[80vh]">
        <DialogHeader>
          <DialogTitle>编辑工作流</DialogTitle>
          <DialogDescription>
            可视化编辑工作流定义
          </DialogDescription>
        </DialogHeader>

        <div className="space-y-4 overflow-y-auto max-h-[60vh]">
          <div className="space-y-2">
            <Label>工作流名称</Label>
            <Input
              value={name}
              onChange={(e) => setName(e.target.value)}
              placeholder="输入工作流名称"
            />
          </div>

          <div className="space-y-2">
            <Label>工作流描述</Label>
            <Textarea
              value={description}
              onChange={(e) => setDescription(e.target.value)}
              placeholder="输入工作流描述"
              rows={3}
            />
          </div>

          <div className="space-y-2">
            <Label>工作流定义 (JSON)</Label>
            <Textarea
              value={definition}
              onChange={(e) => setDefinition(e.target.value)}
              placeholder='{"nodes": [...]}'
              rows={15}
              className="font-mono text-sm"
            />
          </div>

          {/* 可视化编辑区域（简化版本） */}
          <div className="border rounded-lg p-4">
            <div className="text-sm font-medium mb-2">可视化预览</div>
            <div className="text-muted-foreground text-sm">
              可视化编辑器正在开发中，目前支持 JSON 编辑。
              <br />
              在 JSON 编辑器中修改工作流定义，然后保存。
            </div>
          </div>
        </div>

        <DialogFooter>
          <Button variant="outline" onClick={() => onOpenChange(false)}>
            取消
          </Button>
          <Button onClick={handleSave} disabled={saving}>
            {saving ? "保存中..." : "保存"}
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  )
}
