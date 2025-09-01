import { readFileSync } from 'fs';
import { join } from 'path';

export default function TestServiceWorkerPage() {
  // 读取HTML文件内容
  const htmlPath = join(process.cwd(), 'public', 'offline-dino', 'test-service-worker.html');
  const htmlContent = readFileSync(htmlPath, 'utf-8');
  
  return (
    <div dangerouslySetInnerHTML={{ __html: htmlContent }} />
  );
}
