# 🚀 ImagentX Cloudflare Tunnel 完整配置指南

## 📋 准备工作

### ✅ 当前状态确认
- ✅ 前端服务: http://localhost:3002 (运行中)
- ✅ 后端服务: http://localhost:8088 (运行中)
- ✅ Cloudflared 已安装

## 🎯 步骤1: 获取域名

### 选项A: 使用免费域名
1. 访问 [freenom.com](https://www.freenom.com)
2. 搜索并注册免费域名 (如: yourname.tk)
3. 将域名DNS服务器设置为 Cloudflare:
   - `bob.ns.cloudflare.com`
   - `elma.ns.cloudflare.com`

### 选项B: 使用Cloudflare域名
1. 在 [Cloudflare](https://dash.cloudflare.com) 注册域名
2. 或使用已有域名

## 🔐 步骤2: 配置Cloudflare Tunnel

### 1. 登录Cloudflare
```bash
cloudflared tunnel login
```
- 浏览器会打开Cloudflare登录页面
- 选择你的域名或添加新域名

### 2. 创建隧道
```bash
cloudflared tunnel create imagentx-tunnel
```
- 记下返回的 **隧道UUID** (格式: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx)

### 3. 创建配置文件
```bash
# 创建配置目录
mkdir -p ~/.cloudflared

# 创建配置文件
nano ~/.cloudflared/config.yml
```

### 📄 配置文件内容 (替换你的隧道UUID和域名)
```yaml
tunnel: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
credentials-file: ~/.cloudflared/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx.json

ingress:
  # 前端服务
  - hostname: imagentx.yourdomain.com
    service: http://localhost:3002
  
  # 后端API服务
  - hostname: api.imagentx.yourdomain.com
    service: http://localhost:8088
    
  # 默认404页面
  - service: http_status:404
```

### 4. 配置DNS记录
```bash
# 替换为你的隧道UUID和域名
cloudflared tunnel route dns imagentx-tunnel imagentx.yourdomain.com
cloudflared tunnel route dns imagentx-tunnel api.imagentx.yourdomain.com
```

## 🚀 步骤3: 启动隧道

### 手动启动
```bash
cloudflared tunnel run imagentx-tunnel
```

### 后台启动
```bash
# 使用screen或tmux
screen -S cloudflared
cloudflared tunnel run imagentx-tunnel
# 按 Ctrl+A, D 退出screen
```

### 系统服务启动 (推荐)
```bash
# 启用macOS服务
launchctl load ~/Library/LaunchAgents/com.imagentx.cloudflared.plist

# 启动服务
launchctl start com.imagentx.cloudflared
```

## 🧪 步骤4: 测试访问

### 测试命令
```bash
# 测试前端
curl -I https://imagentx.yourdomain.com

# 测试后端API
curl -I https://api.imagentx.yourdomain.com/api/actuator/health

# 浏览器测试
open https://imagentx.yourdomain.com
```

## 📱 分享给其他用户

配置完成后，其他用户可通过以下地址访问：

- **前端界面**: `https://imagentx.yourdomain.com`
- **后端API**: `https://api.imagentx.yourdomain.com/api`

## 🔧 一键配置脚本

### 快速配置 (已为你准备好)
```bash
# 运行一键配置
~/.cloudflared/start-tunnel.sh

# 测试连接
~/.cloudflared/test-tunnel.sh
```

## 🛡️ 安全建议

### 1. 访问控制
```yaml
# 在config.yml中添加访问控制
access:
  aud:
    - https://imagentx.yourdomain.com
    - https://api.imagentx.yourdomain.com
```

### 2. 速率限制
- 在Cloudflare Dashboard中配置
- 路径: Firewall → Tools → Rate limiting

### 3. 日志监控
```bash
# 查看隧道日志
tail -f /tmp/imagentx-cloudflared.log
```

## 🚨 故障排除

### 常见问题

1. **域名未生效**
   - 等待DNS传播 (通常5-10分钟)
   - 检查DNS记录是否正确

2. **隧道连接失败**
   - 检查服务是否运行: `lsof -i :3002,8088`
   - 验证配置文件: `cloudflared tunnel validate`

3. **证书错误**
   - 确保域名DNS指向Cloudflare
   - 检查SSL/TLS设置为"Full"或"Flexible"

### 调试命令
```bash
# 检查隧道状态
cloudflared tunnel info imagentx-tunnel

# 验证配置
cloudflared tunnel validate

# 查看实时日志
cloudflared tunnel run imagentx-tunnel --log-level debug
```

## 📊 监控和管理

### 查看统计信息
- 登录 [Cloudflare Dashboard](https://dash.cloudflare.com)
- 选择你的域名 → Analytics → Traffic

### 重启隧道
```bash
# 停止
launchctl stop com.imagentx.cloudflared

# 启动
launchctl start com.imagentx.cloudflared
```

## 🎯 完成配置后的状态

✅ **HTTPS安全访问** (自动SSL证书)
✅ **无需路由器配置** (绕过NAT限制)
✅ **全球CDN加速** (Cloudflare网络)
✅ **DDoS保护** (Cloudflare防护)
✅ **易于分享** (友好的域名地址)

## 📞 需要帮助?

如果遇到问题:
1. 检查 [Cloudflare文档](https://developers.cloudflare.com/cloudflare-one/connections/connect-apps)
2. 运行测试脚本: `~/.cloudflared/test-tunnel.sh`
3. 查看日志: `tail -f /tmp/imagentx-cloudflared.log`