# ImagentX 域名配置指南 - imagent.top

本指南将帮助您将ImagentX项目配置为使用域名 `imagent.top`。

## 📋 前置要求

1. **域名所有权**: 您需要拥有 `imagent.top` 域名的管理权限
2. **服务器**: 一台公网可访问的服务器（VPS/云服务器）
3. **Docker**: 服务器上已安装Docker和Docker Compose
4. **防火墙**: 开放80和443端口

## 🌐 DNS配置

### 1. 登录域名管理面板

登录您的域名注册商管理面板（如阿里云、腾讯云、GoDaddy等）。

### 2. 配置DNS记录

在DNS管理页面添加以下记录：

#### A记录配置
```
类型: A
主机记录: @
记录值: [您的服务器IP地址]
TTL: 600

类型: A  
主机记录: www
记录值: [您的服务器IP地址]
TTL: 600
```

#### 示例配置
假设您的服务器IP是 `123.456.789.012`：

| 类型 | 主机记录 | 记录值 | TTL |
|------|----------|--------|-----|
| A | @ | 123.456.789.012 | 600 |
| A | www | 123.456.789.012 | 600 |

### 3. 验证DNS解析

配置完成后，等待5-10分钟，然后验证DNS解析：

```bash
# 检查主域名解析
nslookup imagent.top

# 检查www子域名解析  
nslookup www.imagent.top

# 使用dig命令检查
dig imagent.top
dig www.imagent.top
```

## 🚀 部署步骤

### 1. 上传项目文件

将ImagentX项目文件上传到您的服务器：

```bash
# 使用scp上传
scp -r /Users/Meteorkid/Downloads/Imagent-X user@your-server:/home/user/

# 或使用git克隆
git clone https://github.com/Meteor-kid/ImagentX.git
cd ImagentX
```

### 2. 配置环境变量

创建生产环境配置文件：

```bash
# 复制环境配置模板
cp config/env.production.template .env.production

# 编辑配置文件
nano .env.production
```

在 `.env.production` 中添加：

```env
# 域名配置
DOMAIN=imagent.top
WWW_DOMAIN=www.imagent.top

# 数据库配置
POSTGRES_DB=imagentx
POSTGRES_USER=imagentx_user
POSTGRES_PASSWORD=your_secure_password

# RabbitMQ配置
RABBITMQ_USER=imagentx
RABBITMQ_PASSWORD=your_secure_password

# SSL配置
SSL_EMAIL=admin@imagent.top
```

### 3. 启动服务

```bash
# 给脚本执行权限
chmod +x scripts/setup-ssl-imagent.top.sh

# 运行SSL配置脚本
./scripts/setup-ssl-imagent.top.sh
```

### 4. 验证部署

访问以下地址验证部署：

- **主站**: https://imagent.top
- **API**: https://imagent.top/api/health
- **管理界面**: https://imagent.top/admin

## 🔐 SSL证书管理

### 自动续期

脚本已自动配置证书续期，每月1号凌晨2点自动检查并续期。

### 手动续期

```bash
# 手动续期证书
./scripts/setup-ssl-imagent.top.sh

# 或直接运行certbot
docker-compose -f docker-compose.imagent.top.yml run --rm certbot renew
docker-compose -f docker-compose.imagent.top.yml restart nginx
```

### 证书状态检查

```bash
# 检查证书有效期
openssl x509 -in /etc/letsencrypt/live/imagent.top/cert.pem -text -noout | grep "Not After"

# 检查证书文件
ls -la /etc/letsencrypt/live/imagent.top/
```

## 🛠️ 服务管理

### 启动服务

```bash
docker-compose -f docker-compose.imagent.top.yml up -d
```

### 停止服务

```bash
docker-compose -f docker-compose.imagent.top.yml down
```

### 重启服务

```bash
docker-compose -f docker-compose.imagent.top.yml restart
```

### 查看日志

```bash
# 查看所有服务日志
docker-compose -f docker-compose.imagent.top.yml logs

# 查看特定服务日志
docker-compose -f docker-compose.imagent.top.yml logs nginx
docker-compose -f docker-compose.imagent.top.yml logs backend
docker-compose -f docker-compose.imagent.top.yml logs frontend
```

### 更新服务

```bash
# 拉取最新镜像
docker-compose -f docker-compose.imagent.top.yml pull

# 重新构建并启动
docker-compose -f docker-compose.imagent.top.yml up -d --build
```

## 🔧 故障排除

### 常见问题

#### 1. DNS解析失败

**症状**: 无法访问域名

**解决方案**:
```bash
# 检查DNS解析
nslookup imagent.top

# 检查服务器防火墙
sudo ufw status
sudo ufw allow 80
sudo ufw allow 443
```

#### 2. SSL证书申请失败

**症状**: HTTPS无法访问

**解决方案**:
```bash
# 检查80端口是否开放
sudo netstat -tlnp | grep :80

# 检查Nginx配置
docker-compose -f docker-compose.imagent.top.yml logs nginx

# 重新申请证书
docker-compose -f docker-compose.imagent.top.yml run --rm certbot certonly --webroot --webroot-path=/var/www/certbot --email admin@imagent.top --agree-tos --no-eff-email -d imagent.top -d www.imagent.top
```

#### 3. 服务无法启动

**症状**: Docker容器启动失败

**解决方案**:
```bash
# 检查端口占用
sudo netstat -tlnp | grep :80
sudo netstat -tlnp | grep :443

# 检查Docker状态
docker ps -a
docker-compose -f docker-compose.imagent.top.yml ps

# 查看详细错误日志
docker-compose -f docker-compose.imagent.top.yml logs --tail=100
```

### 性能优化

#### 1. 启用HTTP/2

Nginx配置已包含HTTP/2支持，确保使用现代浏览器访问。

#### 2. 启用Gzip压缩

Nginx配置已启用Gzip压缩，减少传输数据量。

#### 3. 静态资源缓存

配置了静态资源缓存，提高访问速度。

## 📊 监控和维护

### 健康检查

```bash
# 检查服务状态
curl -I https://imagent.top/health

# 检查API状态
curl -I https://imagent.top/api/health
```

### 日志监控

```bash
# 实时查看访问日志
tail -f logs/nginx/access.log

# 查看错误日志
tail -f logs/nginx/error.log
```

### 备份

```bash
# 备份数据库
docker exec imagentx-postgres pg_dump -U imagentx_user imagentx > backup_$(date +%Y%m%d_%H%M%S).sql

# 备份配置文件
tar -czf config_backup_$(date +%Y%m%d_%H%M%S).tar.gz config/
```

## 🎯 完成检查清单

- [ ] DNS记录配置完成
- [ ] 服务器防火墙开放80/443端口
- [ ] 项目文件上传到服务器
- [ ] 环境变量配置完成
- [ ] SSL证书申请成功
- [ ] 所有服务正常启动
- [ ] HTTPS访问正常
- [ ] API接口正常响应
- [ ] 证书自动续期配置完成

## 📞 技术支持

如果在配置过程中遇到问题，请：

1. 检查本文档的故障排除部分
2. 查看服务日志文件
3. 确认DNS解析和防火墙设置
4. 联系技术支持团队

---

**配置完成后，您就可以通过 https://imagent.top 访问您的ImagentX服务了！** 🎉



