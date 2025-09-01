import { NextRequest, NextResponse } from 'next/server'

export async function POST(request: NextRequest) {
  try {
    const body = await request.json()
    const { prompt, config } = body

    if (!prompt) {
      return NextResponse.json(
        { error: '请提供提示词' },
        { status: 400 }
      )
    }

    // 调用后端API
    const backendUrl = process.env.BACKEND_URL || 'http://localhost:8088'
    const response = await fetch(`${backendUrl}/api/agents/openmanus`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        prompt,
        config
      }),
    })

    if (!response.ok) {
      throw new Error(`后端API请求失败: ${response.status}`)
    }

    const data = await response.json()
    
    return NextResponse.json({
      success: true,
      response: data.response,
      message: data.message
    })

  } catch (error) {
    console.error('OpenManus API错误:', error)
    
    return NextResponse.json(
      { 
        success: false,
        error: '智能体服务暂时不可用，请稍后重试',
        details: error instanceof Error ? error.message : '未知错误'
      },
      { status: 500 }
    )
  }
}

export async function GET() {
  try {
    // 检查服务状态
    const backendUrl = process.env.BACKEND_URL || 'http://localhost:8088'
    const response = await fetch(`${backendUrl}/api/agents/status`, {
      method: 'GET',
    })

    if (!response.ok) {
      throw new Error(`状态检查失败: ${response.status}`)
    }

    const data = await response.json()
    
    return NextResponse.json({
      success: data.success,
      message: data.message
    })

  } catch (error) {
    console.error('状态检查错误:', error)
    
    return NextResponse.json(
      { 
        success: false,
        message: '无法连接到智能体服务'
      },
      { status: 500 }
    )
  }
}
