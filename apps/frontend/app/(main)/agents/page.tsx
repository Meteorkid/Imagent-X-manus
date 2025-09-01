"use client"

import { useState, useEffect } from "react"
import { Button } from "@/components/ui/button"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Input } from "@/components/ui/input"
import { Textarea } from "@/components/ui/textarea"
import { Badge } from "@/components/ui/badge"
import { ScrollArea } from "@/components/ui/scroll-area"
import { Separator } from "@/components/ui/separator"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"
import { 
  Loader2, 
  Send, 
  Bot, 
  Settings, 
  RefreshCw, 
  Search, 
  Plus, 
  Sparkles,
  Code,
  Database,
  Globe,
  FileText,
  Brain,
  Zap,
  MessageSquare,
  Play,
  X,
  RotateCcw
} from "lucide-react"
import { toast } from "@/hooks/use-toast"

interface AgentMessage {
  id: string
  type: 'user' | 'agent'
  content: string
  timestamp: Date
  status?: 'pending' | 'success' | 'error'
  metadata?: {
    model?: string
    tokens?: number
    duration?: number
  }
}

interface AgentConfig {
  model: string
  maxTokens: number
  temperature: number
  useMCP: boolean
  useDataAnalysis: boolean
  useWebSearch: boolean
  useCodeExecution: boolean
}

interface AgentTemplate {
  id: string
  name: string
  description: string
  icon: React.ReactNode
  prompt: string
  category: string
}

export default function AgentsPage() {
  const [messages, setMessages] = useState<AgentMessage[]>([])
  const [inputValue, setInputValue] = useState("")
  const [isProcessing, setIsProcessing] = useState(false)
  const [activeTab, setActiveTab] = useState("chat")
  const [showConfig, setShowConfig] = useState(false)
  const [agentConfig, setAgentConfig] = useState<AgentConfig>({
    model: "gpt-4o",
    maxTokens: 4096,
    temperature: 0.7,
    useMCP: true,
    useDataAnalysis: false,
    useWebSearch: true,
    useCodeExecution: true
  })

  // 智能体模板
  const agentTemplates: AgentTemplate[] = [
    {
      id: "code-assistant",
      name: "代码助手",
      description: "帮助编写、调试和优化代码",
      icon: <Code className="h-5 w-5" />,
      prompt: "我是一个专业的代码助手，可以帮助你编写、调试和优化各种编程语言的代码。请告诉我你需要什么帮助。",
      category: "开发"
    },
    {
      id: "data-analyst",
      name: "数据分析师",
      description: "数据分析和可视化专家",
      icon: <Database className="h-5 w-5" />,
      prompt: "我是一个数据分析专家，可以帮助你分析数据、创建图表和生成报告。请提供你的数据或分析需求。",
      category: "分析"
    },
    {
      id: "web-researcher",
      name: "网络研究员",
      description: "实时网络搜索和信息收集",
      icon: <Globe className="h-5 w-5" />,
      prompt: "我可以帮你搜索最新的网络信息，收集资料和进行在线研究。请告诉我你想了解什么。",
      category: "研究"
    },
    {
      id: "content-writer",
      name: "内容创作",
      description: "文章、报告和创意写作",
      icon: <FileText className="h-5 w-5" />,
      prompt: "我是一个内容创作专家，可以帮助你写作文章、报告、创意内容等。请告诉我你的写作需求。",
      category: "创作"
    },
    {
      id: "ai-researcher",
      name: "AI研究员",
      description: "AI和机器学习专家",
      icon: <Brain className="h-5 w-5" />,
      prompt: "我是AI和机器学习领域的专家，可以帮你理解AI概念、设计模型和解决相关问题。",
      category: "AI"
    },
    {
      id: "general-assistant",
      name: "通用助手",
      description: "多功能的AI助手",
      icon: <Sparkles className="h-5 w-5" />,
      prompt: "我是一个多功能的AI助手，可以帮你处理各种任务，包括学习、工作、生活等方面的问题。",
      category: "通用"
    }
  ]

  const handleSendMessage = async () => {
    if (!inputValue.trim() || isProcessing) return

    const userMessage: AgentMessage = {
      id: Date.now().toString(),
      type: 'user',
      content: inputValue,
      timestamp: new Date()
    }

    const agentMessage: AgentMessage = {
      id: (Date.now() + 1).toString(),
      type: 'agent',
      content: '',
      timestamp: new Date(),
      status: 'pending'
    }

    setMessages(prev => [...prev, userMessage, agentMessage])
    setInputValue("")
    setIsProcessing(true)

    try {
      const response = await fetch('/api/agents/openmanus', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          prompt: inputValue,
          config: agentConfig
        }),
      })

      if (!response.ok) {
        throw new Error('请求失败')
      }

      const data = await response.json()
      
      setMessages(prev => prev.map(msg => 
        msg.id === agentMessage.id 
          ? { 
              ...msg, 
              content: data.response, 
              status: 'success',
              metadata: {
                model: agentConfig.model,
                tokens: data.tokens || 0,
                duration: data.duration || 0
              }
            }
          : msg
      ))

      toast({
        title: "智能体响应完成",
        description: "OpenManus 已成功处理您的请求"
      })

    } catch (error) {
      console.error('智能体请求错误:', error)
      setMessages(prev => prev.map(msg => 
        msg.id === agentMessage.id 
          ? { ...msg, content: '抱歉，处理您的请求时出现错误。请检查网络连接或稍后重试。', status: 'error' }
          : msg
      ))

      toast({
        title: "处理失败",
        description: "智能体处理失败，请重试",
        variant: "destructive"
      })
    } finally {
      setIsProcessing(false)
    }
  }

  const handleKeyPress = (e: React.KeyboardEvent) => {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault()
      handleSendMessage()
    }
  }

  const clearMessages = () => {
    setMessages([])
  }

  const useTemplate = (template: AgentTemplate) => {
    setInputValue(template.prompt)
    toast({
      title: "模板已加载",
      description: `已加载 ${template.name} 模板`
    })
  }

  const stopProcessing = () => {
    setIsProcessing(false)
    toast({
      title: "已停止",
      description: "智能体处理已停止"
    })
  }

  return (
    <div className="flex h-full flex-col bg-background">
      {/* 页面头部 */}
      <div className="flex items-center justify-between border-b bg-card px-6 py-4">
        <div className="flex items-center space-x-3">
          <div className="flex items-center space-x-2">
            <div className="flex h-8 w-8 items-center justify-center rounded-lg bg-gradient-to-br from-blue-500 to-purple-600">
              <Bot className="h-5 w-5 text-white" />
            </div>
            <div>
              <h1 className="text-xl font-semibold">智能体工作台</h1>
              <p className="text-sm text-muted-foreground">OpenManus 通用AI智能体</p>
            </div>
          </div>
          <Badge variant="secondary" className="bg-gradient-to-r from-blue-100 to-purple-100 text-blue-800">
            <Sparkles className="h-3 w-3 mr-1" />
            OpenManus
          </Badge>
        </div>
        
        <div className="flex items-center space-x-2">
          <Button
            variant="outline"
            size="sm"
            onClick={() => setShowConfig(!showConfig)}
            className="border-blue-200 hover:bg-blue-50"
          >
            <Settings className="h-4 w-4 mr-2" />
            配置
          </Button>
          <Button
            variant="outline"
            size="sm"
            onClick={clearMessages}
            disabled={messages.length === 0}
            className="border-orange-200 hover:bg-orange-50"
          >
            <RefreshCw className="h-4 w-4 mr-2" />
            清空
          </Button>
          {isProcessing && (
            <Button
              variant="outline"
              size="sm"
              onClick={stopProcessing}
              className="border-red-200 hover:bg-red-50"
            >
              <X className="h-4 w-4 mr-2" />
              停止
            </Button>
          )}
        </div>
      </div>

      <div className="flex-1 flex overflow-hidden">
        {/* 主内容区域 */}
        <div className="flex-1 flex flex-col">
          <Tabs value={activeTab} onValueChange={setActiveTab} className="flex-1 flex flex-col">
            <div className="border-b bg-card px-6">
              <TabsList className="grid w-full grid-cols-3">
                <TabsTrigger value="chat" className="flex items-center space-x-2">
                  <MessageSquare className="h-4 w-4" />
                  <span>对话</span>
                </TabsTrigger>
                <TabsTrigger value="templates" className="flex items-center space-x-2">
                  <Plus className="h-4 w-4" />
                  <span>模板</span>
                </TabsTrigger>
                <TabsTrigger value="history" className="flex items-center space-x-2">
                  <RotateCcw className="h-4 w-4" />
                  <span>历史</span>
                </TabsTrigger>
              </TabsList>
            </div>

            <TabsContent value="chat" className="flex-1 flex flex-col p-0">
              <ScrollArea className="flex-1 p-6">
                {messages.length === 0 ? (
                  <div className="flex flex-col items-center justify-center h-full text-center">
                    <div className="relative mb-6">
                      <div className="flex h-20 w-20 items-center justify-center rounded-full bg-gradient-to-br from-blue-100 to-purple-100">
                        <Bot className="h-10 w-10 text-blue-600" />
                      </div>
                      <div className="absolute -top-1 -right-1 flex h-6 w-6 items-center justify-center rounded-full bg-green-500">
                        <Zap className="h-3 w-3 text-white" />
                      </div>
                    </div>
                    <h3 className="text-xl font-semibold mb-2">欢迎使用 OpenManus 智能体</h3>
                    <p className="text-muted-foreground max-w-md mb-6">
                      OpenManus 是一个强大的通用AI智能体，可以执行各种任务，包括代码生成、数据分析、网页浏览、内容创作等。
                    </p>
                    <div className="grid grid-cols-2 gap-3 max-w-lg">
                      <div className="flex items-center space-x-2 text-sm text-muted-foreground">
                        <Code className="h-4 w-4" />
                        <span>代码生成</span>
                      </div>
                      <div className="flex items-center space-x-2 text-sm text-muted-foreground">
                        <Database className="h-4 w-4" />
                        <span>数据分析</span>
                      </div>
                      <div className="flex items-center space-x-2 text-sm text-muted-foreground">
                        <Globe className="h-4 w-4" />
                        <span>网络搜索</span>
                      </div>
                      <div className="flex items-center space-x-2 text-sm text-muted-foreground">
                        <FileText className="h-4 w-4" />
                        <span>内容创作</span>
                      </div>
                    </div>
                  </div>
                ) : (
                  <div className="space-y-6">
                    {messages.map((message) => (
                      <div
                        key={message.id}
                        className={`flex ${message.type === 'user' ? 'justify-end' : 'justify-start'}`}
                      >
                        <div
                          className={`max-w-[80%] rounded-2xl p-4 ${
                            message.type === 'user'
                              ? 'bg-gradient-to-r from-blue-500 to-blue-600 text-white shadow-lg'
                              : 'bg-card border shadow-sm'
                          }`}
                        >
                          <div className="flex items-start space-x-3">
                            {message.type === 'agent' && (
                              <div className="flex h-8 w-8 items-center justify-center rounded-full bg-gradient-to-br from-blue-100 to-purple-100 flex-shrink-0">
                                <Bot className="h-4 w-4 text-blue-600" />
                              </div>
                            )}
                            <div className="flex-1">
                              <div className="whitespace-pre-wrap leading-relaxed">{message.content}</div>
                              {message.status === 'pending' && (
                                <div className="flex items-center mt-3">
                                  <Loader2 className="h-4 w-4 animate-spin mr-2 text-blue-500" />
                                  <span className="text-sm text-muted-foreground">OpenManus 正在处理...</span>
                                </div>
                              )}
                              {message.status === 'error' && (
                                <div className="flex items-center mt-3 text-red-500">
                                  <span className="text-sm">处理失败，请重试</span>
                                </div>
                              )}
                              {message.metadata && message.status === 'success' && (
                                <div className="flex items-center space-x-4 mt-3 text-xs text-muted-foreground">
                                  <span>模型: {message.metadata.model}</span>
                                  {message.metadata.tokens && <span>令牌: {message.metadata.tokens}</span>}
                                  {message.metadata.duration && <span>耗时: {message.metadata.duration}ms</span>}
                                </div>
                              )}
                            </div>
                          </div>
                          <div className="text-xs opacity-70 mt-2">
                            {message.timestamp.toLocaleTimeString()}
                          </div>
                        </div>
                      </div>
                    ))}
                  </div>
                )}
              </ScrollArea>

              <div className="border-t bg-card p-6">
                <div className="flex space-x-3">
                  <Textarea
                    value={inputValue}
                    onChange={(e) => setInputValue(e.target.value)}
                    onKeyPress={handleKeyPress}
                    placeholder="输入您的任务或问题，OpenManus 将为您提供智能帮助..."
                    className="min-h-[60px] max-h-[200px] resize-none border-blue-200 focus:border-blue-400"
                    disabled={isProcessing}
                  />
                  <Button
                    onClick={handleSendMessage}
                    disabled={!inputValue.trim() || isProcessing}
                    className="self-end bg-gradient-to-r from-blue-500 to-purple-600 hover:from-blue-600 hover:to-purple-700"
                  >
                    {isProcessing ? (
                      <Loader2 className="h-4 w-4 animate-spin" />
                    ) : (
                      <Send className="h-4 w-4" />
                    )}
                  </Button>
                </div>
              </div>
            </TabsContent>

            <TabsContent value="templates" className="flex-1 p-6">
              <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
                {agentTemplates.map((template) => (
                  <Card 
                    key={template.id} 
                    className="hover:shadow-md transition-shadow cursor-pointer border-blue-100 hover:border-blue-200"
                    onClick={() => useTemplate(template)}
                  >
                    <CardHeader className="pb-3">
                      <div className="flex items-center space-x-3">
                        <div className="flex h-10 w-10 items-center justify-center rounded-lg bg-gradient-to-br from-blue-100 to-purple-100">
                          {template.icon}
                        </div>
                        <div>
                          <CardTitle className="text-lg">{template.name}</CardTitle>
                          <Badge variant="secondary" className="text-xs">
                            {template.category}
                          </Badge>
                        </div>
                      </div>
                    </CardHeader>
                    <CardContent>
                      <CardDescription className="text-sm leading-relaxed">
                        {template.description}
                      </CardDescription>
                    </CardContent>
                  </Card>
                ))}
              </div>
            </TabsContent>

            <TabsContent value="history" className="flex-1 p-6">
              <div className="text-center text-muted-foreground">
                <RotateCcw className="h-12 w-12 mx-auto mb-4 opacity-50" />
                <h3 className="text-lg font-medium mb-2">对话历史</h3>
                <p className="text-sm">对话历史功能即将推出</p>
              </div>
            </TabsContent>
          </Tabs>
        </div>

        {/* 配置面板 */}
        {showConfig && (
          <div className="w-80 border-l bg-card">
            <div className="p-6">
              <Card>
                <CardHeader>
                  <CardTitle className="text-lg flex items-center space-x-2">
                    <Settings className="h-5 w-5" />
                    <span>智能体配置</span>
                  </CardTitle>
                  <CardDescription>
                    配置 OpenManus 智能体的参数和功能
                  </CardDescription>
                </CardHeader>
                <CardContent className="space-y-4">
                  <div className="space-y-2">
                    <label className="text-sm font-medium">AI模型</label>
                    <select
                      value={agentConfig.model}
                      onChange={(e) => setAgentConfig(prev => ({ ...prev, model: e.target.value }))}
                      className="w-full p-2 border rounded-md bg-background"
                    >
                      <option value="gpt-4o">GPT-4o (推荐)</option>
                      <option value="gpt-4-turbo">GPT-4 Turbo</option>
                      <option value="gpt-3.5-turbo">GPT-3.5 Turbo</option>
                    </select>
                  </div>

                  <div className="space-y-2">
                    <label className="text-sm font-medium">最大令牌数</label>
                    <Input
                      type="number"
                      value={agentConfig.maxTokens}
                      onChange={(e) => setAgentConfig(prev => ({ ...prev, maxTokens: parseInt(e.target.value) }))}
                      min="1000"
                      max="16000"
                    />
                  </div>

                  <div className="space-y-2">
                    <label className="text-sm font-medium">创造性 (温度)</label>
                    <Input
                      type="number"
                      value={agentConfig.temperature}
                      onChange={(e) => setAgentConfig(prev => ({ ...prev, temperature: parseFloat(e.target.value) }))}
                      min="0"
                      max="2"
                      step="0.1"
                    />
                  </div>

                  <Separator />

                  <div className="space-y-3">
                    <h4 className="text-sm font-medium text-muted-foreground">功能开关</h4>
                    
                    <div className="space-y-2">
                      <div className="flex items-center space-x-2">
                        <input
                          type="checkbox"
                          id="useMCP"
                          checked={agentConfig.useMCP}
                          onChange={(e) => setAgentConfig(prev => ({ ...prev, useMCP: e.target.checked }))}
                          className="rounded"
                        />
                        <label htmlFor="useMCP" className="text-sm font-medium">
                          MCP 工具支持
                        </label>
                      </div>
                      <p className="text-xs text-muted-foreground ml-6">
                        启用 Model Context Protocol 工具支持
                      </p>
                    </div>

                    <div className="space-y-2">
                      <div className="flex items-center space-x-2">
                        <input
                          type="checkbox"
                          id="useWebSearch"
                          checked={agentConfig.useWebSearch}
                          onChange={(e) => setAgentConfig(prev => ({ ...prev, useWebSearch: e.target.checked }))}
                          className="rounded"
                        />
                        <label htmlFor="useWebSearch" className="text-sm font-medium">
                          网络搜索
                        </label>
                      </div>
                      <p className="text-xs text-muted-foreground ml-6">
                        允许智能体进行实时网络搜索
                      </p>
                    </div>

                    <div className="space-y-2">
                      <div className="flex items-center space-x-2">
                        <input
                          type="checkbox"
                          id="useCodeExecution"
                          checked={agentConfig.useCodeExecution}
                          onChange={(e) => setAgentConfig(prev => ({ ...prev, useCodeExecution: e.target.checked }))}
                          className="rounded"
                        />
                        <label htmlFor="useCodeExecution" className="text-sm font-medium">
                          代码执行
                        </label>
                      </div>
                      <p className="text-xs text-muted-foreground ml-6">
                        允许智能体执行代码和脚本
                      </p>
                    </div>

                    <div className="space-y-2">
                      <div className="flex items-center space-x-2">
                        <input
                          type="checkbox"
                          id="useDataAnalysis"
                          checked={agentConfig.useDataAnalysis}
                          onChange={(e) => setAgentConfig(prev => ({ ...prev, useDataAnalysis: e.target.checked }))}
                          className="rounded"
                        />
                        <label htmlFor="useDataAnalysis" className="text-sm font-medium">
                          数据分析
                        </label>
                      </div>
                      <p className="text-xs text-muted-foreground ml-6">
                        启用专门的数据分析功能
                      </p>
                    </div>
                  </div>
                </CardContent>
              </Card>
            </div>
          </div>
        )}
      </div>
    </div>
  )
}
