'use client';

import { useSearchParams } from 'next/navigation';
import { Suspense, useEffect, useRef } from 'react';

function DinoFrame() {
  const searchParams = useSearchParams();
  const iframeRef = useRef<HTMLIFrameElement>(null);
  const raw = searchParams.get('game');
  const safe =
    raw && /^[a-zA-Z0-9._-]+\.js$/.test(raw) ? raw : '';
  const src = safe
    ? `/offline-dino/dino.html?game=${encodeURIComponent(safe)}`
    : '/offline-dino/dino.html';

  useEffect(() => {
    const timer = setTimeout(() => iframeRef.current?.focus(), 300);
    return () => clearTimeout(timer);
  }, [src]);

  return (
    <iframe
      ref={iframeRef}
      src={src}
      title="Offline Dino Game"
      className="h-[calc(100vh-4rem)] w-full border-0"
      allow="fullscreen"
      tabIndex={0}
      onLoad={() => iframeRef.current?.focus()}
    />
  );
}

export default function DinoGamePage() {
  return (
    <Suspense
      fallback={
        <div className="flex h-[calc(100vh-4rem)] items-center justify-center text-muted-foreground">
          加载中…
        </div>
      }
    >
      <DinoFrame />
    </Suspense>
  );
}
