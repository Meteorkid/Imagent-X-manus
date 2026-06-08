"use client"

import { useState, useEffect } from "react"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Badge } from "@/components/ui/badge"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"
import { Dialog, DialogContent, DialogDescription, DialogFooter, DialogHeader, DialogTitle, DialogTrigger } from "@/components/ui/dialog"
import { Label } from "@/components/ui/label"
import { Textarea } from "@/components/ui/textarea"
import { Switch } from "@/components/ui/switch"
import { toast } from "@/hooks/use-toast"
import { PluginCard } from "@/components/plugin/plugin-card"
import { PluginDetailDialog } from "@/components/plugin/plugin-detail-dialog"
import { PluginInstallDialog } from "@/components/plugin/plugin-install-dialog"
import {
  getPluginsWithToast,
  installPluginWithToast,
  uninstallPluginWithToast,
  enablePluginWithToast,
  disablePluginWithToast,
  type PluginInfo
} from "@/lib/plugin-service"

export default function PluginsPage() {
  const [plugins, setPlugins] = useState<PluginInfo[]>([])
  const [loading, setLoading] = useState(true)
  const [searchQuery, setSearchQuery] = useState("")
  const [activeTab, setActiveTab] = useState("all")
  const [selectedPlugin, setSelectedPlugin] = useState<PluginInfo | null>(null)
  const [isDetailOpen, setIsDetailOpen] = useState(false)
  const [isInstallOpen, setIsInstallOpen] = useState(false)

  // 获取插件列表
  const fetchPlugins = async () => {
    try {
      setLoading(true)
      const response = await getPluginsWithToast()
      if (response.code === 200) {
        setPlugins(response.data)
      }
    } catch (error) {
      console.error("获取插件列表失败:", error)
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => {
    fetchPlugins()
  }, [])

  // 过滤插件
  const filteredPlugins = plugins.filter(plugin => {
    const matchesSearch = plugin.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
                         plugin.description.toLowerCase().includes(searchQuery.toLowerCase())
    const matchesTab = activeTab === "all" ||
                      (activeTab === "enabled" && plugin.status === "enabled") ||
                      (activeTab === "disabled" && plugin.status === "disabled") ||
                      (activeTab === "error" && plugin.status === "error")
    return matchesSearch && matchesTab
  })

  // 处理启用/禁用插件
  const handleTogglePlugin = async (plugin: PluginInfo) => {
    try {
      if (plugin.status === "enabled") {
        await disablePluginWithToast(plugin.id)
        toast({ description: `已禁用插件: ${plugin.name}` })
      } else {
        await enablePluginWithToast(plugin.id)
        toast({ description: `已启用插件: ${plugin.name}` })
      }
      fetchPlugins()
    } catch (error) {
      toast({ description: "操作失败", variant: "destructive" })
    }
  }

  // 处理卸载插件
  const handleUninstallPlugin = async (plugin: PluginInfo) => {
    try {
      await uninstallPluginWithToast(plugin.id)
      toast({ description: `已卸载插件: ${plugin.name}` })
      fetchPlugins()
    } catch (error) {
      toast({ description: "卸载失败", variant: "destructive" })
    }
  }

  // 处理查看详情
  const handleViewDetail = (plugin: PluginInfo) => {
    setSelectedPlugin(plugin)
    setIsDetailOpen(true)
  }

  // 统计信息
  const stats = {
    total: plugins.length,
    enabled: plugins.filter(p => p.status === "enabled").length,
    disabled: plugins.filter(p => p.status === "disabled").length,
    error: plugins.filter(p => p.status === "error").length
  }

  return (
    <div className="container mx-auto py-6">
      <div className="flex justify-between items-center mb-6">
        <div>
          <h1 className="text-3xl font-bold">插件管理</h1>
          <p className="text-muted-foreground">管理和配置系统插件</p>
        </div>
        <Button onClick={() => setIsInstallOpen(true)}>
          安装插件
        </Button>
      </div>

      {/* 统计卡片 */}
      <div className="grid grid-cols-4 gap-4 mb-6">
        <Card>
          <CardHeader className="pb-2">
            <CardTitle className="text-sm font-medium">总插件数</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{stats.total}</div>
          </CardContent>
        </Card>
        <Card>
          <CardHeader className="pb-2">
            <CardTitle className="text-sm font-medium">已启用</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-green-600">{stats.enabled}</div>
          </CardContent>
        </Card>
        <Card>
          <CardHeader className="pb-2">
            <CardTitle className="text-sm font-medium">已禁用</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-gray-600">{stats.disabled}</div>
          </CardContent>
        </Card>
        <Card>
          <CardHeader className="pb-2">
            <CardTitle className="text-sm font-medium">错误</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-red-600">{stats.error}</div>
          </CardContent>
        </Card>
      </div>

      {/* 搜索和过滤 */}
      <div className="flex gap-4 mb-6">
        <Input
          placeholder="搜索插件..."
          value={searchQuery}
          onChange={(e) => setSearchQuery(e.target.value)}
          className="max-w-sm"
        />
        <Tabs value={activeTab} onValueChange={setActiveTab}>
          <TabsList>
            <TabsTrigger value="all">全部</TabsTrigger>
            <TabsTrigger value="enabled">已启用</TabsTrigger>
            <TabsTrigger value="disabled">已禁用</TabsTrigger>
            <TabsTrigger value="error">错误</TabsTrigger>
          </TabsList>
        </Tabs>
      </div>

      {/* 插件列表 */}
      {loading ? (
        <div className="text-center py-8">加载中...</div>
      ) : filteredPlugins.length === 0 ? (
        <div className="text-center py-8 text-muted-foreground">
          没有找到插件
        </div>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
          {filteredPlugins.map(plugin => (
            <PluginCard
              key={plugin.id}
              plugin={plugin}
              onToggle={() => handleTogglePlugin(plugin)}
              onUninstall={() => handleUninstallPlugin(plugin)}
              onViewDetail={() => handleViewDetail(plugin)}
            />
          ))}
        </div>
      )}

      {/* 插件详情对话框 */}
      <PluginDetailDialog
        plugin={selectedPlugin}
        open={isDetailOpen}
        onOpenChange={setIsDetailOpen}
        onToggle={handleTogglePlugin}
        onUninstall={handleUninstallPlugin}
      />

      {/* 安装插件对话框 */}
      <PluginInstallDialog
        open={isInstallOpen}
        onOpenChange={setIsInstallOpen}
        onInstallComplete={fetchPlugins}
      />
    </div>
  )
}
