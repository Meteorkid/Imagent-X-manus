"use client"

import { useState, useRef } from "react"
import { Dialog, DialogContent, DialogDescription, DialogFooter, DialogHeader, DialogTitle } from "@/components/ui/dialog"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { Textarea } from "@/components/ui/textarea"
import { Upload, File, X } from "lucide-react"
import { toast } from "@/hooks/use-toast"
import { installPluginFromUrlWithToast, installPluginFromFileWithToast } from "@/lib/plugin-service"

interface PluginInstallDialogProps {
  open: boolean
  onOpenChange: (open: boolean) => void
  onInstallComplete: () => void
}

export function PluginInstallDialog({
  open,
  onOpenChange,
  onInstallComplete
}: PluginInstallDialogProps) {
  const [installMethod, setInstallMethod] = useState<"file" | "url">("file")
  const [pluginUrl, setPluginUrl] = useState("")
  const [selectedFile, setSelectedFile] = useState<File | null>(null)
  const [installing, setInstalling] = useState(false)
  const fileInputRef = useRef<HTMLInputElement>(null)

  const handleFileSelect = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0]
    if (file) {
      if (!file.name.endsWith(".jar") && !file.name.endsWith(".zip")) {
        toast({
          description: "只支持 .jar 或 .zip 格式的插件文件",
          variant: "destructive"
        })
        return
      }
      setSelectedFile(file)
    }
  }

  const handleInstall = async () => {
    try {
      setInstalling(true)

      if (installMethod === "url") {
        if (!pluginUrl.trim()) {
          toast({ description: "请输入插件下载地址", variant: "destructive" })
          return
        }
        await installPluginFromUrlWithToast(pluginUrl)
      } else {
        if (!selectedFile) {
          toast({ description: "请选择插件文件", variant: "destructive" })
          return
        }
        await installPluginFromFileWithToast(selectedFile)
      }

      toast({ description: "插件安装成功" })
      onInstallComplete()
      onOpenChange(false)
      resetForm()
    } catch (error) {
      toast({ description: "插件安装失败", variant: "destructive" })
    } finally {
      setInstalling(false)
    }
  }

  const resetForm = () => {
    setPluginUrl("")
    setSelectedFile(null)
    if (fileInputRef.current) {
      fileInputRef.current.value = ""
    }
  }

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="sm:max-w-[500px]">
        <DialogHeader>
          <DialogTitle>安装插件</DialogTitle>
          <DialogDescription>
            选择插件安装方式
          </DialogDescription>
        </DialogHeader>

        <div className="space-y-4">
          {/* 安装方式选择 */}
          <div className="flex gap-2">
            <Button
              variant={installMethod === "file" ? "default" : "outline"}
              onClick={() => setInstallMethod("file")}
              className="flex-1"
            >
              <Upload className="mr-2 h-4 w-4" />
              本地文件
            </Button>
            <Button
              variant={installMethod === "url" ? "default" : "outline"}
              onClick={() => setInstallMethod("url")}
              className="flex-1"
            >
              <File className="mr-2 h-4 w-4" />
              在线地址
            </Button>
          </div>

          {/* 文件上传 */}
          {installMethod === "file" && (
            <div className="space-y-2">
              <Label>选择插件文件</Label>
              <div
                className="border-2 border-dashed rounded-lg p-6 text-center cursor-pointer hover:border-primary transition-colors"
                onClick={() => fileInputRef.current?.click()}
              >
                <input
                  ref={fileInputRef}
                  type="file"
                  accept=".jar,.zip"
                  onChange={handleFileSelect}
                  className="hidden"
                />
                {selectedFile ? (
                  <div className="flex items-center justify-center gap-2">
                    <File className="h-6 w-6" />
                    <span>{selectedFile.name}</span>
                    <Button
                      variant="ghost"
                      size="icon"
                      className="h-6 w-6"
                      onClick={(e) => {
                        e.stopPropagation()
                        setSelectedFile(null)
                      }}
                    >
                      <X className="h-4 w-4" />
                    </Button>
                  </div>
                ) : (
                  <div className="text-muted-foreground">
                    <Upload className="h-8 w-8 mx-auto mb-2" />
                    <p>点击选择 .jar 或 .zip 文件</p>
                  </div>
                )}
              </div>
            </div>
          )}

          {/* URL 输入 */}
          {installMethod === "url" && (
            <div className="space-y-2">
              <Label>插件下载地址</Label>
              <Input
                placeholder="https://example.com/plugin.jar"
                value={pluginUrl}
                onChange={(e) => setPluginUrl(e.target.value)}
              />
            </div>
          )}
        </div>

        <DialogFooter>
          <Button variant="outline" onClick={() => onOpenChange(false)}>
            取消
          </Button>
          <Button onClick={handleInstall} disabled={installing}>
            {installing ? "安装中..." : "安装"}
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  )
}
