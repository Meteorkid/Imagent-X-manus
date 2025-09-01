# ImagentX 服务认证信息

## 服务访问地址和认证信息

| 服务 | 地址 | 用户名/密码 | 功能 |
|------|------|-------------|------|
| ImagentX前端 | http://localhost:3000 | admin@imagentx.top/admin123 | 主应用界面 |
| ImagentX后端 | http://localhost:8088 | admin@imagentx.top/admin123 | API服务 |
| Prometheus | http://localhost:9090 | admin/prometheus123 | 监控系统 |
| Grafana | http://localhost:3001 | admin/admin123 | 可视化面板 |
| Elasticsearch | http://localhost:9200 | elastic/elastic123 | 日志存储 |
| Kibana | http://localhost:5601 | elastic/elastic123 | 日志分析 |
| MCP网关 | http://localhost:8080 | imagentx-mcp-key-2024 | 服务管理 |
| 沙箱安全监控 | http://localhost:8001 | - | 安全指标 |
| 监控API | http://localhost:5000 | admin/api123 | REST API接口 |
| 监控仪表板 | http://localhost:5000/dashboard | admin/api123 | Web仪表板 |

## 认证说明

### 1. ImagentX前端
- 用户名: `admin@imagentx.top`
- 密码: `admin123`
- 访问: http://localhost:3000
- 认证方式: JWT Token (登录后自动获取)

### 2. ImagentX后端
- 用户名: `admin@imagentx.top`
- 密码: `admin123`
- 访问: http://localhost:8088
- 认证方式: JWT Token (通过Authorization头)
- API端点: POST /api/login

### 3. Prometheus
- 用户名: `admin` 或 `monitor`
- 密码: `prometheus123` 或 `monitor123`
- 访问: http://localhost:9090

### 2. Grafana
- 用户名: `admin`
- 密码: `admin123`
- 访问: http://localhost:3001

### 3. Elasticsearch
- 用户名: `elastic`
- 密码: `elastic123`
- 访问: http://localhost:9200

### 4. Kibana
- 用户名: `elastic`
- 密码: `elastic123`
- 访问: http://localhost:5601

### 5. 监控API
- 用户名: `admin`
- 密码: `api123`
- 访问: http://localhost:5000

### 6. MCP网关
- API Key: `imagentx-mcp-key-2024`
- 访问: http://localhost:8080

### 7. 测试用户 (可选)
- 用户名: `test@imagentx.top`
- 密码: `test123`
- 昵称: `测试用户`
- 说明: 仅在测试环境启用

## 安全建议

1. **生产环境**: 请修改所有默认密码
2. **HTTPS**: 建议配置SSL证书
3. **网络隔离**: 限制访问IP范围
4. **定期更新**: 定期更换密码
5. **审计日志**: 启用访问日志记录

## 认证流程

### ImagentX登录流程
1. **访问登录页面**: http://localhost:3000/login
2. **输入凭据**:
   - 账号: `admin@imagentx.top`
   - 密码: `admin123`
3. **获取Token**: 登录成功后自动获取JWT token
4. **使用Token**: 前端自动在请求头中添加Authorization

### API调用示例
```bash
# 登录获取token
curl -X POST http://localhost:8088/api/login \
  -H "Content-Type: application/json" \
  -d '{"account":"admin@imagentx.top","password":"admin123"}'

# 使用token访问API
curl -X GET http://localhost:8088/api/users/me \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

## 密码修改方法

### ImagentX用户
```bash
# 修改环境变量
IMAGENTX_ADMIN_EMAIL=newadmin@imagentx.top
IMAGENTX_ADMIN_PASSWORD=newpassword123
IMAGENTX_TEST_EMAIL=newtest@imagentx.top
IMAGENTX_TEST_PASSWORD=newtest123
```

### Prometheus
```bash
# 生成新密码哈希
htpasswd -nbB admin newpassword
# 更新 mcp-config/prometheus/web.yml
```

### Elasticsearch
```bash
# 修改环境变量
ELASTIC_PASSWORD=newpassword
```

### Grafana
```bash
# 通过Web界面修改
# 或修改环境变量
GF_SECURITY_ADMIN_PASSWORD=newpassword
```
