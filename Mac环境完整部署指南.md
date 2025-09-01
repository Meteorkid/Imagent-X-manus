# 🍎 Mac环境完整部署指南

## 📋 部署前准备

### 1. 服务器购买和准备

#### 推荐服务器配置
- **云服务商**: 阿里云、腾讯云、AWS、DigitalOcean
- **操作系统**: Ubuntu 20.04 LTS
- **配置**: 2核4GB内存，40GB存储
- **网络**: 公网IP，开放80/443端口

#### 服务器购买步骤
1. **阿里云购买示例**:
   - 访问 [阿里云官网](https://www.aliyun.com/)
   - 选择 **云服务器ECS**
   - 配置选择: 2核4GB，Ubuntu 20.04
   - 带宽: 5Mbps
   - 存储: 40GB SSD

2. **记录服务器信息**:
   - 服务器IP: `_________________`
   - SSH密码: `_________________`
   - 操作系统: Ubuntu 20.04

### 2. Mac环境准备

#### 安装必要工具
```bash
# 安装Homebrew（如果未安装）
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 安装SSH客户端（通常已预装）
# 安装Git
brew install git

# 安装Docker Desktop（用于本地测试）
brew install --cask docker
```

#### 验证工具安装
```bash
# 检查SSH
ssh -V

# 检查Git
git --version

# 检查Docker
docker --version
```

## 🚀 完整部署步骤

### 步骤1: 连接服务器

#### 1.1 获取服务器信息
- 登录云服务商控制台
- 找到您的服务器实例
- 记录公网IP地址

#### 1.2 SSH连接服务器
```bash
# 在Mac终端中执行
ssh root@[您的服务器IP]

# 示例
ssh root@123.456.789.123
```

**首次连接会提示确认，输入 `yes`**

#### 1.3 更新服务器系统
```bash
# 在服务器上执行
apt update && apt upgrade -y
```

### 步骤2: 配置DNS解析

#### 2.1 登录阿里云控制台
1. 访问 [阿里云控制台](https://console.aliyun.com/)
2. 进入 **域名** 管理
3. 找到 `imagentx.top` 域名

#### 2.2 添加DNS记录
在解析设置中添加：

| 记录类型 | 主机记录 | 解析线路 | 记录值 | TTL |
|----------|----------|----------|--------|-----|
| A | @ | 默认 | [您的服务器IP] | 10分钟 |
| A | www | 默认 | [您的服务器IP] | 10分钟 |

#### 2.3 验证DNS解析
```bash
# 在Mac终端中执行
nslookup imagentx.top
nslookup www.imagentx.top
```

### 步骤3: 上传项目代码

#### 3.1 在Mac上准备代码
```bash
# 进入项目目录
cd /Users/Meteorkid/Downloads/ImagentX-master

# 创建部署包
tar -czf imagentx-deploy.tar.gz \
  --exclude='.git' \
  --exclude='node_modules' \
  --exclude='target' \
  --exclude='logs' \
  --exclude='temp' \
  .
```

#### 3.2 上传到服务器
```bash
# 使用scp上传
scp imagentx-deploy.tar.gz root@[您的服务器IP]:/opt/

# 示例
scp imagentx-deploy.tar.gz root@123.456.789.123:/opt/
```

#### 3.3 在服务器上解压
```bash
# 在服务器上执行
mkdir -p /opt/imagentx
cd /opt/imagentx
tar -xzf /opt/imagentx-deploy.tar.gz
```

### 步骤4: 配置环境变量

#### 4.1 在服务器上配置
```bash
# 在服务器上执行
cd /opt/imagentx

# 复制环境变量模板
cp env.production.template .env.production

# 编辑环境变量
nano .env.production
```

#### 4.2 重要配置项
```bash
# 数据库配置
DB_USER=imagentx_user
DB_PASSWORD=your_secure_password_here
DB_NAME=imagentx

# JWT密钥（必须更改）
JWT_SECRET=your_very_secure_jwt_secret_key_here

# 管理员账户
IMAGENTX_ADMIN_EMAIL=admin@imagentx.top
IMAGENTX_ADMIN_PASSWORD=your_admin_password_here

# SSL证书邮箱
SSL_EMAIL=admin@imagentx.top

# 域名配置
DOMAIN=imagentx.top
```

### 步骤5: 执行部署

#### 5.1 设置服务器环境
```bash
# 在服务器上执行
cd /opt/imagentx
chmod +x quick-deploy.sh
./quick-deploy.sh --setup
```

#### 5.2 部署项目
```bash
# 在服务器上执行
./quick-deploy.sh --deploy
```

#### 5.3 检查部署状态
```bash
# 在服务器上执行
./quick-deploy.sh --status
```

### 步骤6: 验证部署

#### 6.1 在Mac上测试DNS解析
```bash
# 在Mac终端中执行
./check-dns.sh --check
```

#### 6.2 测试网站访问
```bash
# 在Mac终端中执行
curl -I https://imagentx.top
curl -I https://www.imagentx.top
```

#### 6.3 浏览器访问测试
- 打开浏览器访问: https://imagentx.top
- 测试管理员登录: https://imagentx.top/login

## 🔧 Mac环境下的辅助工具

### 1. 使用VSCode远程开发
```bash
# 安装VSCode Remote SSH扩展
# 在VSCode中按 Cmd+Shift+P
# 输入: Remote-SSH: Connect to Host
# 输入: root@[您的服务器IP]
```

### 2. 使用iTerm2进行SSH连接
```bash
# 安装iTerm2
brew install --cask iterm2

# 创建SSH配置文件
nano ~/.ssh/config
```

添加以下内容：
```
Host imagentx-server
    HostName [您的服务器IP]
    User root
    Port 22
    IdentityFile ~/.ssh/id_rsa
```

### 3. 使用Docker Desktop进行本地测试
```bash
# 在Mac上测试本地部署
cd /Users/Meteorkid/Downloads/ImagentX-master
docker-compose -f docker-compose-local-production.yml up -d
```

## 📊 部署监控

### 1. 实时监控部署状态
```bash
# 在服务器上执行
./quick-deploy.sh --logs

# 在Mac上监控
ssh root@[您的服务器IP] "tail -f /opt/imagentx/logs/*.log"
```

### 2. 检查服务健康状态
```bash
# 在Mac上执行
curl https://imagentx.top/health
curl https://imagentx.top/api/health
```

### 3. 监控系统资源
```bash
# 在服务器上执行
docker stats
htop
df -h
```

## 🚨 常见问题解决

### 1. SSH连接问题
```bash
# 检查SSH连接
ssh -v root@[您的服务器IP]

# 如果连接失败，检查：
# - 服务器防火墙设置
# - SSH服务是否启动
# - 密码是否正确
```

### 2. DNS解析问题
```bash
# 在Mac上检查DNS
dig imagentx.top
nslookup imagentx.top

# 清除Mac DNS缓存
sudo dscacheutil -flushcache
```

### 3. 文件上传问题
```bash
# 使用rsync替代scp（更稳定）
rsync -avz --progress /Users/Meteorkid/Downloads/ImagentX-master/ root@[您的服务器IP]:/opt/imagentx/
```

### 4. 权限问题
```bash
# 在服务器上修复权限
chmod +x /opt/imagentx/*.sh
chown -R root:root /opt/imagentx
```

## 🎯 部署完成检查清单

### 服务器端检查
- [ ] 服务器系统更新完成
- [ ] Docker和Docker Compose安装成功
- [ ] 项目代码上传成功
- [ ] 环境变量配置完成
- [ ] 部署脚本执行成功
- [ ] 所有服务启动正常

### DNS配置检查
- [ ] 阿里云DNS记录添加完成
- [ ] DNS解析生效（5-30分钟）
- [ ] 域名可正常解析到服务器IP

### 功能测试检查
- [ ] https://imagentx.top 可访问
- [ ] https://www.imagentx.top 可访问
- [ ] SSL证书自动获取成功
- [ ] 管理员登录功能正常
- [ ] API接口响应正常

## 🎉 部署成功

### 访问地址
- **主站**: https://imagentx.top
- **管理后台**: https://imagentx.top/login
- **API文档**: https://imagentx.top/api

### 管理员账户
- **邮箱**: admin@imagentx.top
- **密码**: 您在.env.production中设置的密码

### 后续维护
```bash
# 查看服务状态
ssh root@[您的服务器IP] "cd /opt/imagentx && ./quick-deploy.sh --status"

# 查看日志
ssh root@[您的服务器IP] "cd /opt/imagentx && ./quick-deploy.sh --logs"

# 重启服务
ssh root@[您的服务器IP] "cd /opt/imagentx && ./quick-deploy.sh --restart"
```

**恭喜！您的ImagentX项目已成功部署到生产环境！** 🚀
