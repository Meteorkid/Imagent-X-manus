import { NextResponse } from 'next/server';
import { listOfflineGameScriptVersions } from '@/lib/offline-game-script';

export async function GET() {
  return NextResponse.json({
    ok: true,
    data: {
      versions: listOfflineGameScriptVersions(),
    },
  });
}
