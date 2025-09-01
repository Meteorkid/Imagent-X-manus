import { readFileSync } from 'fs';
import { join } from 'path';

export default function DinoGamePage() {
  // 读取HTML文件内容
  const htmlPath = join(process.cwd(), 'public', 'offline-dino', 'dino.html');
  const htmlContent = readFileSync(htmlPath, 'utf-8');
  
  return (
    <div dangerouslySetInnerHTML={{ __html: htmlContent }} />
  );
}
