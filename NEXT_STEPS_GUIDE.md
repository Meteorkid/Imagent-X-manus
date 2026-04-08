# ImagentX 下一步配置指南

## 📋 当前状态

✅ **本地开发环境正常运行**
- 前端服务: http://localhost:3000
- 后端服务: http://localhost:8088
- 数据库服务: PostgreSQL + RabbitMQ
- 域名配置: imagent.top
- Cloudflare配置文件已准备

## 🚀 下一步配置步骤

### 第一步：设置Cloudflare账户

#### 1.1 注册Cloudflare账户
```bash
# 访问Cloudflare注册页面
open https://dash.cloudflare.com/sign-up
```

#### 1.2 添加域名到Cloudflare
1. 登录Cloudflare Dashboard
2. 点击 "Add a Site"
3. 输入域名 `imagent.top`
4. 选择 **免费计划 (Free Plan)**
5. 等待DNS扫描完成

#### 1.3 获取必要的配置信息
- **Zone ID**: 在域名概览页面右侧找到
- **API Token**: 在个人资料 -> API Tokens 创建

### 第二步：配置域名服务器

#### 2.1 更新域名服务器
Cloudflare会提供两个域名服务器，例如：
```
ns1.cloudflare.com
ns2.cloudflare.com
```

在您的域名注册商处：
1. 登录域名管理面板
2. 找到DNS设置或域名服务器设置
3. 将域名服务器更改为Cloudflare提供的服务器
4. 等待24-48小时完全生效

#### 2.2 验证域名服务器更新
```bash
# 检查域名服务器
nslookup -type=NS imagent.top
```

### 第三步：准备服务器环境

#### 3.1 服务器要求
- **操作系统**: Ubuntu 20.04+ 或 CentOS 8+
- **内存**: 最少2GB，推荐4GB+
- **存储**: 最少20GB可用空间
- **网络**: 公网IP，开放80和443端口

#### 3.2 安装必要软件
```bash
# 更新系统
sudo apt update && sudo apt upgrade -y

# 安装Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER

# 安装Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# 安装其他工具
sudo apt install -y curl wget git jq
```

### 第四步：上传项目到服务器

#### 4.1 使用SCP上传
```bash
# 从本地上传到服务器
scp -r /Users/Meteorkid/Downloads/Imagent-X user@your-server:/home/user/
```

#### 4.2 使用Git克隆
```bash
# 在服务器上克隆项目
git clone https://github.com/Meteor-kid/ImagentX.git
cd ImagentX
```

### 第五步：配置环境变量

#### 5.1 创建环境配置文件
```bash
# 创建生产环境配置
cp config/env.production.template .env.production
```

#### 5.2 编辑配置文件
```bash
nano .env.production
```

添加以下内容：
```env
# Cloudflare配置
CLOUDFLARE_API_TOKEN=your_api_token_here
CLOUDFLARE_ZONE_ID=your_zone_id_here

# 服务器配置
SERVER_IP=your_server_ip_here
DOMAIN=imagent.top

# 数据库配置
POSTGRES_PASSWORD=your_secure_password_here
RABBITMQ_PASSWORD=your_secure_password_here

# 应用配置
NODE_ENV=production
SPRING_PROFILES_ACTIVE=production
```

### 第六步：运行部署脚本

#### 6.1 给脚本执行权限
```bash
chmod +x scripts/deploy-cloudflare.sh
chmod +x scripts/test-cloudflare-local.sh
```

#### 6.2 设置环境变量
```bash
export CLOUDFLARE_API_TOKEN="your_token_here"
export CLOUDFLARE_ZONE_ID="your_zone_id_here"
export SERVER_IP="your_server_ip_here"
```

#### 6.3 运行部署脚本
```bash
./scripts/deploy-cloudflare.sh
```

### 第七步：验证部署

#### 7.1 检查服务状态
```bash
# 检查Docker服务
docker-compose -f docker-compose.imagent.top.cloudflare.yml ps

# 检查服务日志
docker-compose -f docker-compose.imagent.top.cloudflare.yml logs
```

#### 7.2 测试网站访问
```bash
# 测试HTTP访问
curl -I http://imagent.top

# 测试HTTPS访问
curl -I https://imagent.top

# 测试API接口
curl -I https://imagent.top/api/health
```

#### 7.3 运行测试脚本
```bash
./scripts/test-cloudflare-local.sh
```

## 🔧 配置优化

### Cloudflare设置优化

#### SSL/TLS设置
1. 进入 **SSL/TLS** 页面
2. 选择 **加密模式**: Flexible
3. 启用 **始终使用HTTPS**
4. 启用 **HTTP严格传输安全 (HSTS)**

#### 缓存设置
1. 进入 **缓存** 页面
2. 设置 **缓存级别**: 标准
3. 配置页面规则：
   ```
   URL: imagent.top/api/*
   设置: 缓存级别 = 绕过
   
   URL: imagent.top/*
   设置: 缓存级别 = 标准
   边缘缓存TTL = 4小时
   ```

#### 安全设置
1. 进入 **安全** 页面
2. 设置 **安全级别**: 中等
3. 启用 **Bot Fight Mode**
4. 配置 **WAF规则**

### 性能优化

#### 启用速度优化
1. 进入 **速度** 页面
2. 启用 **Auto Minify**:
   - HTML: ✅
   - CSS: ✅
   - JavaScript: ✅
3. 启用 **Brotli压缩**
4. 启用 **Rocket Loader**

## 📊 监控和维护

### 日志监控
```bash
# 实时查看访问日志
tail -f logs/nginx/access.log

# 查看错误日志
tail -f logs/nginx/error.log

# 查看应用日志
docker-compose -f docker-compose.imagent.top.cloudflare.yml logs -f
```

### 性能监控
```bash
# 监控脚本
#!/bin/bash
while true; do
    echo "$(date): $(curl -w '%{time_total}' -o /dev/null -s https://imagent.top)"
    sleep 60
done
```

### 备份策略
```bash
# 备份数据库
docker exec imagentx-postgres pg_dump -U imagentx_user imagentx > backup_$(date +%Y%m%d_%H%M%S).sql

# 备份配置文件
tar -czf config_backup_$(date +%Y%m%d_%H%M%S).tar.gz config/
```

## 🚨 故障排除

### 常见问题

#### 1. DNS解析失败
```bash
# 检查DNS解析
nslookup imagent.top
dig imagent.top

# 检查域名服务器
nslookup -type=NS imagent.top
```

#### 2. SSL证书问题
```bash
# 检查SSL证书
openssl s_client -connect imagent.top:443 -servername imagent.top

# 在线SSL测试
# 访问: https://www.ssllabs.com/ssltest/
```

#### 3. 服务无法启动
```bash
# 检查端口占用
sudo netstat -tlnp | grep :80
sudo netstat -tlnp | grep :443

# 检查Docker状态
docker ps -a
docker-compose -f docker-compose.imagent.top.cloudflare.yml ps

# 查看详细错误日志
docker-compose -f docker-compose.imagent.top.cloudflare.yml logs --tail=100
```

## 📞 技术支持

### 获取帮助
- **Cloudflare文档**: https://developers.cloudflare.com/
- **项目文档**: ./docs/CLOUDFLARE_SETUP_GUIDE.md
- **GitHub Issues**: https://github.com/Meteor-kid/ImagentX/issues

### 联系信息
- **技术支持**: support@imagent.top
- **文档反馈**: docs@imagent.top

---

**按照以上步骤配置完成后，您就可以通过 https://imagent.top 访问您的ImagentX服务了！** 🎉



