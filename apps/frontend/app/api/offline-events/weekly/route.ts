import { NextResponse } from 'next/server';
import { getOfflineWeeklySummary } from '@/lib/server/offline-events-store';

export async function GET(request: Request) {
  const { searchParams } = new URL(request.url);
  const days = Number(searchParams.get('days') || '7');
  const safeDays = Number.isFinite(days) ? Math.min(Math.max(days, 1), 30) : 7;
  return NextResponse.json({
    ok: true,
    data: await getOfflineWeeklySummary(safeDays),
  });
}

