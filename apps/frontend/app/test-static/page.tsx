export default function TestStaticPage() {
  return (
    <div className="p-8">
      <h1 className="text-2xl font-bold mb-4">静态文件测试</h1>
      
      <div className="space-y-4">
        <div>
          <h2 className="text-lg font-semibold mb-2">测试链接：</h2>
          <ul className="space-y-2">
            <li>
              <a 
                href="/offline-dino/verify-offline.html" 
                className="text-blue-600 hover:underline"
                target="_blank"
              >
                断网检测测试页面
              </a>
            </li>
            <li>
              <a 
                href="/offline-dino/test-service-worker.html" 
                className="text-blue-600 hover:underline"
                target="_blank"
              >
                Service Worker 测试页面
              </a>
            </li>
            <li>
              <a 
                href="/offline-dino/dino.html" 
                className="text-blue-600 hover:underline"
                target="_blank"
              >
                小恐龙游戏页面
              </a>
            </li>
            <li>
              <a 
                href="/offline-game.js" 
                className="text-blue-600 hover:underline"
                target="_blank"
              >
                离线游戏脚本
              </a>
            </li>
          </ul>
        </div>
        
        <div>
          <h2 className="text-lg font-semibold mb-2">直接访问测试：</h2>
          <div className="bg-gray-100 p-4 rounded">
            <p className="text-sm text-gray-600 mb-2">请在浏览器中直接访问以下URL：</p>
            <code className="text-xs bg-white p-2 rounded block">
              http://localhost:3000/offline-dino/verify-offline.html
            </code>
          </div>
        </div>
        
        <div>
          <h2 className="text-lg font-semibold mb-2">文件状态检查：</h2>
          <div className="bg-gray-100 p-4 rounded">
            <p className="text-sm text-gray-600">
              如果上述链接返回404错误，请检查：
            </p>
            <ul className="text-sm text-gray-600 mt-2 space-y-1">
              <li>• 文件是否存在于 public/offline-dino/ 目录中</li>
              <li>• Next.js 开发服务器是否正在运行</li>
              <li>• 是否需要重启开发服务器</li>
            </ul>
          </div>
        </div>
      </div>
    </div>
  )
}
