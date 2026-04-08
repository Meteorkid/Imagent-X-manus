import { DiscoverContent } from "@/components/discover-content"
import { Sidebar } from "@/components/sidebar"

export default function DiscoverPage() {
  return (
    <div className="flex h-full min-h-0">
      {/* 左侧边栏 */}
      <Sidebar />

      {/* 右侧内容区域 */}
      <div className="flex-1 overflow-auto">
        <DiscoverContent />
      </div>
    </div>
  )
}

