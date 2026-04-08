import { NextResponse } from 'next/server';

export async function GET() {
  try {
    // 简单的健康检查，返回当前时间
    return NextResponse.json({
      status: 'healthy',
      timestamp: new Date().toISOString(),
      uptime: process.uptime(),
      environment: process.env.NODE_ENV || 'development'
    });
  } catch (error) {
    return NextResponse.json(
      { 
        status: 'error', 
        message: 'Health check failed',
        timestamp: new Date().toISOString()
      },
      { status: 500 }
    );
  }
}

export async function HEAD() {
  // HEAD请求用于网络状态检测，只返回状态码
  return new NextResponse(null, { status: 200 });
}







