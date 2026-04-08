"use client"

import { useState } from "react"
import { Plus, Database, Brain } from "lucide-react"
import Link from "next/link"

import { Button } from "@/components/ui/button"
import { CreateDatasetDialog } from "@/components/knowledge/CreateDatasetDialog"
import { CreatedRagsSection } from "@/components/knowledge/sections/CreatedRagsSection"
import { InstalledRagsSection } from "@/components/knowledge/sections/InstalledRagsSection"
import { RecommendedRagsSection } from "@/components/knowledge/sections/RecommendedRagsSection"

export default function KnowledgePage() {
  const [refreshTrigger, setRefreshTrigger] = useState(0)

  // 触发刷新
  const triggerRefresh = () => {
    setRefreshTrigger(prev => prev + 1)
  }

  return (
    <div className="min-h-full bg-background py-6">
      <div className="container mx-auto max-w-7xl px-2">
        {/* 页面头部 */}
        <div className="mb-8 flex items-center justify-between rounded-lg border bg-card p-6 shadow-sm">
          <div>
            <h1 className="bg-gradient-to-r from-primary to-primary/70 bg-clip-text text-3xl font-bold tracking-tight text-transparent">知识库</h1>
            <p className="text-muted-foreground mt-1">管理您的RAG数据集，发现和使用优质知识库</p>
          </div>
          
          <CreateDatasetDialog onSuccess={triggerRefresh} />
        </div>
        
        {/* 我创建的知识库部分 */}
        <CreatedRagsSection key={`created-${refreshTrigger}`} />
        
        {/* 我安装的知识库部分 */}
        <InstalledRagsSection key={`installed-${refreshTrigger}`} />
        
        {/* 推荐知识库部分 */}
        <RecommendedRagsSection key={`recommended-${refreshTrigger}`} />
      </div>
    </div>
  )
}

