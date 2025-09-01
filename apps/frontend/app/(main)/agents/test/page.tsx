"use client"

import { useState } from "react"
import { Button } from "@/components/ui/button"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Badge } from "@/components/ui/badge"
import { Loader2, CheckCircle, XCircle, Bot } from "lucide-react"
import { toast } from "@/hooks/use-toast"

interface TestResult {
  name: string
  status: 'pending' | 'success' | 'error'
  message: string
}

export default function AgentTestPage() {
  const [testResults, setTestResults] = useState<TestResult[]>([])
  const [isRunning, setIsRunning] = useState(false)

  const tests = [
    {
      name: "OpenManus 目录检查",
      test: () => checkOpenManusDirectory()
    },
    {
      name: "Python 环境检查",
      test: () => checkPythonEnvironment()
    },
    {
      name: "配置文件检查",
      test: () => checkConfigFile()
    },
    {
      name: "API 连接测试",
      test: () => testAPIConnection()
    },
    {
      name: "智能体功能测试",
      test: () => testAgentFunction()
    }
  ]

  const checkOpenManusDirectory = async (): Promise<string> => {
    try {
      const response = await fetch('/api/agents/status')
      const data = await response.json()
      
      if (data.success) {
        return "OpenManus 目录和文件存在"
      } else {
        throw new Error(data.message)
      }
    } catch (error) {
      throw new Error(`OpenManus 目录检查失败: ${error}`)
    }
  }

  const checkPythonEnvironment = async (): Promise<string> => {
    try {
      const response = await fetch('/api/agents/status')
      const data = await response.json()
      
      if (data.success) {
        return "Python 环境正常"
      } else {
        throw new Error("Python 环境检查失败")
      }
    } catch (error) {
      throw new Error(`Python 环境检查失败: ${error}`)
    }
  }

  const checkConfigFile = async (): Promise<string> => {
    try {
      const response = await fetch('/api/agents/status')
      const data = await response.json()
      
      if (data.success) {
        return "配置文件存在且有效"
      } else {
        throw new Error("配置文件检查失败")
      }
    } catch (error) {
      throw new Error(`配置文件检查失败: ${error}`)
    }
  }

  const testAPIConnection = async (): Promise<string> => {
    try {
      const response = await fetch('/api/agents/status')
      
      if (!response.ok) {
        throw new Error(`HTTP ${response.status}`)
      }
      
      const data = await response.json()
      return "API 连接正常"
    } catch (error) {
      throw new Error(`API 连接失败: ${error}`)
    }
  }

  const testAgentFunction = async (): Promise<string> => {
    try {
      const response = await fetch('/api/agents/openmanus', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          prompt: "请简单介绍一下你自己",
          config: {
            model: "gpt-4o",
            maxTokens: 100,
            temperature: 0.0,
            useMCP: false,
            useDataAnalysis: false
          }
        }),
      })

      if (!response.ok) {
        throw new Error(`HTTP ${response.status}`)
      }

      const data = await response.json()
      
      if (data.success) {
        return "智能体功能测试成功"
      } else {
        throw new Error(data.message || "智能体功能测试失败")
      }
    } catch (error) {
      throw new Error(`智能体功能测试失败: ${error}`)
    }
  }

  const runAllTests = async () => {
    setIsRunning(true)
    setTestResults([])

    for (const test of tests) {
      // 添加测试到结果列表
      setTestResults(prev => [...prev, {
        name: test.name,
        status: 'pending',
        message: '测试中...'
      }])

      try {
        const message = await test.test()
        
        // 更新测试结果
        setTestResults(prev => prev.map(result => 
          result.name === test.name 
            ? { ...result, status: 'success', message }
            : result
        ))
      } catch (error) {
        // 更新测试结果
        setTestResults(prev => prev.map(result => 
          result.name === test.name 
            ? { ...result, status: 'error', message: error instanceof Error ? error.message : '未知错误' }
            : result
        ))
      }
    }

    setIsRunning(false)
    
    // 检查所有测试是否通过
    const allPassed = testResults.every(result => result.status === 'success')
    
    if (allPassed) {
      toast({
        title: "测试完成",
        description: "所有测试都通过了！",
      })
    } else {
      toast({
        title: "测试完成",
        description: "部分测试失败，请检查配置",
        variant: "destructive"
      })
    }
  }

  const getStatusIcon = (status: TestResult['status']) => {
    switch (status) {
      case 'pending':
        return <Loader2 className="h-4 w-4 animate-spin" />
      case 'success':
        return <CheckCircle className="h-4 w-4 text-green-500" />
      case 'error':
        return <XCircle className="h-4 w-4 text-red-500" />
    }
  }

  const getStatusBadge = (status: TestResult['status']) => {
    switch (status) {
      case 'pending':
        return <Badge variant="secondary">测试中</Badge>
      case 'success':
        return <Badge variant="default" className="bg-green-500">通过</Badge>
      case 'error':
        return <Badge variant="destructive">失败</Badge>
    }
  }

  return (
    <div className="container mx-auto p-6">
      <div className="flex items-center space-x-2 mb-6">
        <Bot className="h-6 w-6 text-blue-600" />
        <h1 className="text-2xl font-bold">智能体集成测试</h1>
      </div>

      <Card className="mb-6">
        <CardHeader>
          <CardTitle>测试控制</CardTitle>
          <CardDescription>
            运行测试以验证 OpenManus 集成是否正常工作
          </CardDescription>
        </CardHeader>
        <CardContent>
          <Button 
            onClick={runAllTests} 
            disabled={isRunning}
            className="w-full"
          >
            {isRunning ? (
              <>
                <Loader2 className="h-4 w-4 animate-spin mr-2" />
                运行测试中...
              </>
            ) : (
              "运行所有测试"
            )}
          </Button>
        </CardContent>
      </Card>

      <div className="space-y-4">
        {testResults.map((result, index) => (
          <Card key={index}>
            <CardHeader>
              <div className="flex items-center justify-between">
                <div className="flex items-center space-x-2">
                  {getStatusIcon(result.status)}
                  <CardTitle className="text-lg">{result.name}</CardTitle>
                </div>
                {getStatusBadge(result.status)}
              </div>
            </CardHeader>
            <CardContent>
              <p className="text-sm text-muted-foreground">{result.message}</p>
            </CardContent>
          </Card>
        ))}
      </div>

      {testResults.length === 0 && (
        <Card>
          <CardContent className="pt-6">
            <div className="text-center text-muted-foreground">
              <Bot className="h-12 w-12 mx-auto mb-4 opacity-50" />
              <p>点击"运行所有测试"开始测试 OpenManus 集成</p>
            </div>
          </CardContent>
        </Card>
      )}
    </div>
  )
}

