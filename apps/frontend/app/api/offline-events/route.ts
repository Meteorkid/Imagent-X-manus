import { NextResponse } from 'next/server';
import { addOfflineEvent, getOfflineWeeklySummary, listOfflineEvents } from '@/lib/server/offline-events-store';

export async function POST(request: Request) {
  try {
    const body = await request.json();
    const payload = typeof body.payload === 'object' && body.payload !== null ? body.payload : {};
    const contextualPayload = {
      ...payload,
      _ctx: {
        activeGameVersion: typeof body.activeGameVersion === 'string' ? body.activeGameVersion : 'unknown',
        activeGameScript: typeof body.activeGameScript === 'string' ? body.activeGameScript : '',
      },
    };
    await addOfflineEvent({
      event: String(body.event || 'unknown'),
      payload: contextualPayload,
      experiment: body.experiment,
      sessionId: body.sessionId,
      route: body.route,
      timestamp: typeof body.timestamp === 'number' ? body.timestamp : Date.now(),
      userAgent: body.userAgent,
    });
    return NextResponse.json({ ok: true });
  } catch (error) {
    return NextResponse.json({ ok: false, error: 'invalid_payload' }, { status: 400 });
  }
}

export async function GET(request: Request) {
  const { searchParams } = new URL(request.url);
  const mode = searchParams.get('mode');
  const days = Number(searchParams.get('days') || '7');
  const safeDays = Number.isFinite(days) ? Math.min(Math.max(days, 1), 30) : 7;

  if (mode === 'raw') {
    return NextResponse.json({ ok: true, data: await listOfflineEvents(safeDays) });
  }
  return NextResponse.json({
    ok: true,
    data: await getOfflineWeeklySummary(safeDays),
  });
}

