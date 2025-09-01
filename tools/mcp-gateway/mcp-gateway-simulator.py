#!/usr/bin/env python3
"""
MCP网关模拟服务
用于测试MCP网关功能
"""

import json
import time
from http.server import HTTPServer, BaseHTTPRequestHandler
from urllib.parse import urlparse, parse_qs
import threading

class MCPGatewayHandler(BaseHTTPRequestHandler):
    """MCP网关HTTP处理器"""
    
    def __init__(self, *args, **kwargs):
        self.api_key = "default-api-key-1234567890"
        super().__init__(*args, **kwargs)
    
    def do_GET(self):
        """处理GET请求"""
        parsed_url = urlparse(self.path)
        path = parsed_url.path
        
        # 健康检查
        if path == "/health":
            self.send_health_response()
        elif path == "/api/health":
            self.send_api_health_response()
        elif path.startswith("/mcp/"):
            self.send_mcp_response(path)
        else:
            self.send_error(404, "Not Found")
    
    def do_POST(self):
        """处理POST请求"""
        parsed_url = urlparse(self.path)
        path = parsed_url.path
        
        if path == "/deploy":
            self.handle_deploy()
        else:
            self.send_error(404, "Not Found")
    
    def send_health_response(self):
        """发送健康检查响应"""
        response = {
            "status": "healthy",
            "timestamp": int(time.time()),
            "service": "mcp-gateway-simulator",
            "version": "1.0.0"
        }
        self.send_json_response(response)
    
    def send_api_health_response(self):
        """发送API健康检查响应"""
        response = {
            "code": 200,
            "message": "ok",
            "data": {
                "status": "healthy",
                "service": "mcp-gateway",
                "uptime": "1h30m"
            },
            "timestamp": int(time.time() * 1000)
        }
        self.send_json_response(response)
    
    def send_mcp_response(self, path):
        """发送MCP相关响应"""
        # 模拟MCP工具列表
        tools = [
            {
                "name": "file_system",
                "description": "文件系统操作工具",
                "version": "1.0.0",
                "status": "active"
            },
            {
                "name": "web_search",
                "description": "网络搜索工具",
                "version": "1.0.0",
                "status": "active"
            },
            {
                "name": "calculator",
                "description": "计算器工具",
                "version": "1.0.0",
                "status": "active"
            }
        ]
        
        response = {
            "code": 200,
            "message": "success",
            "data": tools,
            "timestamp": int(time.time() * 1000)
        }
        self.send_json_response(response)
    
    def handle_deploy(self):
        """处理工具部署请求"""
        try:
            content_length = int(self.headers.get('Content-Length', 0))
            post_data = self.rfile.read(content_length)
            deploy_config = json.loads(post_data.decode('utf-8'))
            
            # 模拟部署过程
            response = {
                "code": 200,
                "message": "部署成功",
                "data": {
                    "deployedTools": ["test-tool"],
                    "failedTools": []
                },
                "timestamp": int(time.time() * 1000)
            }
            self.send_json_response(response)
        except Exception as e:
            response = {
                "code": 500,
                "message": f"部署失败: {str(e)}",
                "data": None,
                "timestamp": int(time.time() * 1000)
            }
            self.send_json_response(response)
    
    def send_json_response(self, data):
        """发送JSON响应"""
        self.send_response(200)
        self.send_header('Content-Type', 'application/json')
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type, Authorization')
        self.end_headers()
        
        response_json = json.dumps(data, ensure_ascii=False, indent=2)
        self.wfile.write(response_json.encode('utf-8'))
    
    def log_message(self, format, *args):
        """自定义日志格式"""
        print(f"[{time.strftime('%Y-%m-%d %H:%M:%S')}] {format % args}")

def start_mcp_gateway_simulator(port=8081):
    """启动MCP网关模拟服务"""
    server_address = ('', port)
    httpd = HTTPServer(server_address, MCPGatewayHandler)
    
    print(f"🚀 MCP网关模拟服务启动成功！")
    print(f"🌐 服务地址: http://localhost:{port}")
    print(f"🔍 健康检查: http://localhost:{port}/health")
    print(f"🔧 API健康检查: http://localhost:{port}/api/health")
    print(f"📦 工具部署: POST http://localhost:{port}/deploy")
    print(f"📋 MCP工具: GET http://localhost:{port}/mcp/tools")
    print(f"\n按 Ctrl+C 停止服务")
    
    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        print(f"\n🛑 MCP网关模拟服务已停止")
        httpd.server_close()

if __name__ == "__main__":
    start_mcp_gateway_simulator()
