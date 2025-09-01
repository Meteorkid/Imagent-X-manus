import { NextRequest, NextResponse } from 'next/server';

// API代理路由 - 支持内网和公网部署
export async function GET(
  request: NextRequest,
  { params }: { params: { path: string[] } }
) {
  return handleApiRequest(request, params.path, 'GET');
}

export async function POST(
  request: NextRequest,
  { params }: { params: { path: string[] } }
) {
  return handleApiRequest(request, params.path, 'POST');
}

export async function PUT(
  request: NextRequest,
  { params }: { params: { path: string[] } }
) {
  return handleApiRequest(request, params.path, 'PUT');
}

export async function DELETE(
  request: NextRequest,
  { params }: { params: { path: string[] } }
) {
  return handleApiRequest(request, params.path, 'DELETE');
}

export async function PATCH(
  request: NextRequest,
  { params }: { params: { path: string[] } }
) {
  return handleApiRequest(request, params.path, 'PATCH');
}

async function handleApiRequest(
  request: NextRequest,
  pathSegments: string[],
  method: string
) {
  try {
    // 获取后端地址 - 支持环境变量配置
    const backendUrl = process.env.BACKEND_URL || 'http://localhost:8088';
    const apiPath = pathSegments.join('/');
    const targetUrl = `${backendUrl}/api/${apiPath}`;
    
    // 获取查询参数
    const searchParams = request.nextUrl.searchParams.toString();
    const fullUrl = searchParams ? `${targetUrl}?${searchParams}` : targetUrl;
    
    // 获取请求头
    const headers = new Headers();
    request.headers.forEach((value, key) => {
      // 跳过一些Next.js特定的头部
      if (!key.startsWith('x-') && key !== 'host') {
        headers.set(key, value);
      }
    });
    
    // 设置后端请求头
    headers.set('host', new URL(backendUrl).host);
    
    // 获取请求体
    let body: string | undefined;
    if (method !== 'GET' && method !== 'HEAD') {
      body = await request.text();
    }
    
    // 转发请求到后端
    const response = await fetch(fullUrl, {
      method,
      headers,
      body,
    });
    
    // 获取响应头
    const responseHeaders = new Headers();
    response.headers.forEach((value, key) => {
      // 跳过一些可能导致问题的头部
      if (!key.startsWith('x-') && key !== 'transfer-encoding') {
        responseHeaders.set(key, value);
      }
    });
    
    // 返回响应
    return new NextResponse(response.body, {
      status: response.status,
      statusText: response.statusText,
      headers: responseHeaders,
    });
    
  } catch (error) {
    console.error('API代理错误:', error);
    return NextResponse.json(
      { 
        error: 'Internal Server Error', 
        message: 'API代理服务异常',
        details: process.env.NODE_ENV === 'development' ? error.message : undefined
      },
      { status: 500 }
    );
  }
}
