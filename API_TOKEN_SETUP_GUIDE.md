# API Token 配置指南

## 🔑 获取API Token后的操作步骤

### 第一步：验证API Token

#### 1.1 测试API Token是否有效
```bash
# 替换 YOUR_API_TOKEN 为您的实际Token
curl -X GET "https://api.cloudflare.com/client/v4/user/tokens/verify" \
     -H "Authorization: Bearer YOUR_API_TOKEN" \
     -H "Content-Type: application/json"
```

如果返回 `"success": true`，说明Token有效。

#### 1.2 获取Zone ID
```bash
# 替换 YOUR_API_TOKEN 为您的实际Token
curl -X GET "https://api.cloudflare.com/client/v4/zones" \
     -H "Authorization: Bearer YOUR_API_TOKEN" \
     -H "Content-Type: application/json"
```

在返回结果中找到 `imagentx.top` 对应的 `id` 字段，这就是您的Zone ID。

### 第二步：配置环境变量

#### 2.1 创建环境配置文件
```bash
# 创建生产环境配置
cp config/env.production.template .env.production
```

#### 2.2 编辑配置文件
```bash
nano .env.production
```

添加以下内容（替换为您的实际值）：
```env
# Cloudflare配置
CLOUDFLARE_API_TOKEN=your_actual_api_token_here
CLOUDFLARE_ZONE_ID=your_actual_zone_id_here

# 服务器配置
SERVER_IP=your_server_ip_here
DOMAIN=imagentx.top

# 数据库配置
POSTGRES_PASSWORD=your_secure_password_here
RABBITMQ_PASSWORD=your_secure_password_here

# 应用配置
NODE_ENV=production
SPRING_PROFILES_ACTIVE=production
```

### 第三步：设置环境变量

#### 3.1 临时设置（当前会话有效）
```bash
export CLOUDFLARE_API_TOKEN="your_actual_api_token_here"
export CLOUDFLARE_ZONE_ID="your_actual_zone_id_here"
export SERVER_IP="your_server_ip_here"
```

#### 3.2 永久设置（推荐）
```bash
# 添加到 ~/.bashrc 或 ~/.zshrc
echo 'export CLOUDFLARE_API_TOKEN="your_actual_api_token_here"' >> ~/.bashrc
echo 'export CLOUDFLARE_ZONE_ID="your_actual_zone_id_here"' >> ~/.bashrc
echo 'export SERVER_IP="your_server_ip_here"' >> ~/.bashrc

# 重新加载配置
source ~/.bashrc
```

### 第四步：验证配置

#### 4.1 检查环境变量
```bash
echo "API Token: $CLOUDFLARE_API_TOKEN"
echo "Zone ID: $CLOUDFLARE_ZONE_ID"
echo "Server IP: $SERVER_IP"
```

#### 4.2 测试API连接
```bash
# 测试API连接
curl -X GET "https://api.cloudflare.com/client/v4/zones/$CLOUDFLARE_ZONE_ID" \
     -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
     -H "Content-Type: application/json"
```

### 第五步：运行部署脚本

#### 5.1 给脚本执行权限
```bash
chmod +x scripts/deploy-imagentx.top.sh
```

#### 5.2 运行部署脚本
```bash
./scripts/deploy-imagentx.top.sh
```

## 🚨 常见问题解决

### 问题1：API Token无效
**错误信息**: `"success": false, "errors": [{"code": 6003, "message": "Invalid request headers"}]`

**解决方案**:
1. 检查Token是否正确复制
2. 确认Token权限包含：Zone:Read, DNS:Edit, SSL:Edit
3. 重新创建Token

### 问题2：Zone ID错误
**错误信息**: `"success": false, "errors": [{"code": 1001, "message": "Invalid zone identifier"}]`

**解决方案**:
1. 确认域名已添加到Cloudflare
2. 检查Zone ID是否正确
3. 确认域名服务器已更新

### 问题3：权限不足
**错误信息**: `"success": false, "errors": [{"code": 10001, "message": "Insufficient permissions"}]`

**解决方案**:
1. 检查Token权限设置
2. 确认Token包含必要的权限
3. 重新创建Token

## 🔧 快速配置脚本

创建一个快速配置脚本：

```bash
#!/bin/bash
# 快速配置脚本

echo "🔑 ImagentX API Token 配置脚本"
echo "================================"

# 获取用户输入
read -p "请输入您的Cloudflare API Token: " API_TOKEN
read -p "请输入您的Cloudflare Zone ID: " ZONE_ID
read -p "请输入您的服务器IP地址: " SERVER_IP

# 验证输入
if [ -z "$API_TOKEN" ] || [ -z "$ZONE_ID" ] || [ -z "$SERVER_IP" ]; then
    echo "❌ 所有字段都必须填写"
    exit 1
fi

# 设置环境变量
export CLOUDFLARE_API_TOKEN="$API_TOKEN"
export CLOUDFLARE_ZONE_ID="$ZONE_ID"
export SERVER_IP="$SERVER_IP"

# 验证API连接
echo "🔍 验证API连接..."
if curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$ZONE_ID" \
    -H "Authorization: Bearer $API_TOKEN" \
    -H "Content-Type: application/json" | grep -q '"success":true'; then
    echo "✅ API连接验证成功"
else
    echo "❌ API连接验证失败，请检查Token和Zone ID"
    exit 1
fi

# 创建环境配置文件
echo "📝 创建环境配置文件..."
cat > .env.production << EOF
# Cloudflare配置
CLOUDFLARE_API_TOKEN=$API_TOKEN
CLOUDFLARE_ZONE_ID=$ZONE_ID

# 服务器配置
SERVER_IP=$SERVER_IP
DOMAIN=imagentx.top

# 数据库配置
POSTGRES_PASSWORD=imagentx_secure_password_$(date +%s)
RABBITMQ_PASSWORD=imagentx_secure_password_$(date +%s)

# 应用配置
NODE_ENV=production
SPRING_PROFILES_ACTIVE=production
EOF

echo "✅ 环境配置文件已创建: .env.production"
echo ""
echo "🚀 现在可以运行部署脚本："
echo "   ./scripts/deploy-imagentx.top.sh"
```

## 📋 检查清单

- [ ] API Token已获取并验证
- [ ] Zone ID已获取
- [ ] 服务器IP地址已确认
- [ ] 环境变量已设置
- [ ] API连接测试通过
- [ ] 环境配置文件已创建
- [ ] 部署脚本已准备就绪

## 🎯 下一步操作

1. **验证配置**: 确保所有环境变量正确设置
2. **运行部署**: 执行部署脚本
3. **监控进度**: 观察部署过程
4. **验证结果**: 测试网站访问

---

**完成以上步骤后，您就可以成功部署ImagentX到imagentx.top了！** 🚀



