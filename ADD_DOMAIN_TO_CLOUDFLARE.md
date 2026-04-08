# 添加域名到Cloudflare指南

## 🚨 当前问题

您的Cloudflare账户中还没有添加域名 `imagentx.top`，需要先添加域名才能获取Zone ID。

## 🔧 解决步骤

### 第一步：添加域名到Cloudflare

#### 1.1 登录Cloudflare Dashboard
```bash
# 打开Cloudflare Dashboard
open https://dash.cloudflare.com
```

#### 1.2 添加站点
1. 点击 **"Add a Site"** 按钮
2. 输入域名：`imagentx.top`
3. 点击 **"Add Site"**

#### 1.3 选择计划
- 选择 **"Free"** 计划（免费）
- 点击 **"Continue"**

#### 1.4 扫描DNS记录
- Cloudflare会自动扫描您现有的DNS记录
- 检查扫描结果，确保所有记录都正确
- 点击 **"Continue"**

### 第二步：更新域名服务器

#### 2.1 获取Cloudflare域名服务器
Cloudflare会显示两个域名服务器，例如：
```
ns1.cloudflare.com
ns2.cloudflare.com
```

#### 2.2 在域名注册商处更新
1. 登录您的域名注册商管理面板
2. 找到域名 `imagentx.top` 的管理页面
3. 找到 **"域名服务器"** 或 **"Nameservers"** 设置
4. 将域名服务器更改为Cloudflare提供的服务器
5. 保存更改

#### 2.3 等待DNS传播
- DNS传播通常需要24-48小时
- 您可以使用以下命令检查传播状态：
```bash
nslookup -type=NS imagentx.top
```

### 第三步：获取Zone ID

#### 3.1 在Cloudflare Dashboard中获取
1. 在Cloudflare Dashboard中选择域名 `imagentx.top`
2. 在右侧边栏找到 **"Zone ID"**
3. 复制Zone ID

#### 3.2 使用API获取
```bash
# 替换 YOUR_API_TOKEN 为您的实际Token
curl -X GET "https://api.cloudflare.com/client/v4/zones" \
     -H "Authorization: Bearer YOUR_API_TOKEN" \
     -H "Content-Type: application/json" | jq '.result[] | select(.name=="imagentx.top") | .id'
```

### 第四步：重新运行配置脚本

完成上述步骤后，重新运行配置脚本：

```bash
./scripts/setup-api-token.sh
```

## 🔍 验证步骤

### 验证域名服务器更新
```bash
# 检查域名服务器
nslookup -type=NS imagentx.top

# 应该显示Cloudflare的域名服务器
```

### 验证DNS记录
```bash
# 检查A记录
nslookup imagentx.top

# 检查www子域名
nslookup www.imagentx.top
```

### 验证Cloudflare配置
```bash
# 检查Zone ID
curl -X GET "https://api.cloudflare.com/client/v4/zones" \
     -H "Authorization: Bearer YOUR_API_TOKEN" \
     -H "Content-Type: application/json" | jq '.result[] | select(.name=="imagentx.top")'
```

## ⏰ 时间线

1. **立即**: 添加域名到Cloudflare
2. **立即**: 更新域名服务器
3. **24-48小时**: 等待DNS传播完成
4. **传播完成后**: 获取Zone ID并运行配置脚本

## 🚨 常见问题

### 问题1：域名服务器更新失败
**解决方案**:
- 确认域名注册商支持自定义域名服务器
- 检查域名服务器格式是否正确
- 联系域名注册商技术支持

### 问题2：DNS传播时间过长
**解决方案**:
- 使用不同的DNS检查工具验证
- 清除本地DNS缓存
- 等待更长时间（最多72小时）

### 问题3：Zone ID获取失败
**解决方案**:
- 确认域名已成功添加到Cloudflare
- 检查API Token权限
- 重新登录Cloudflare Dashboard

## 📞 需要帮助？

如果遇到问题，可以：
1. 查看Cloudflare官方文档
2. 联系Cloudflare技术支持
3. 检查域名注册商文档

---

**完成这些步骤后，您就可以成功配置ImagentX了！** 🚀



