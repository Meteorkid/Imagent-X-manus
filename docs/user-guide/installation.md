# 📦 安装指南

## 📋 系统要求

### 最低配置
- **操作系统**: Ubuntu 20.04+ / CentOS 7+ / macOS 10.15+
- **CPU**: 2 核
- **内存**: 4 GB
- **磁盘**: 20 GB
- **网络**: 可访问互联网

### 推荐配置
- **操作系统**: Ubuntu 22.04 LTS
- **CPU**: 4 核
- **内存**: 8 GB
- **磁盘**: 50 GB SSD
- **网络**: 可访问互联网

## 🚀 安装步骤

### 1. 安装 Docker

```bash
# 安装 Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# 启动 Docker
sudo systemctl start docker
sudo systemctl enable docker

# 验证安装
docker --version
```

### 2. 安装 Docker Compose

```bash
# 安装 Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

# 添加执行权限
sudo chmod +x /usr/local/bin/docker-compose

# 验证安装
docker-compose --version
```

### 3. 下载 ImagentX

```bash
# 克隆仓库
git clone https://github.com/Meteorkid/Imagent-X-manus.git
cd "Imagent-X-manus"
```

### 4. 配置环境变量

```bash
# 复制环境变量模板
cp .env.example .env

# 编辑环境变量
nano .env
```

需要配置的变量：
- `DB_PASSWORD`: 数据库密码
- `JWT_SECRET`: JWT 密钥
- `ADMIN_EMAIL`: 管理员邮箱
- `ADMIN_PASSWORD`: 管理员密码

### 5. 启动服务

```bash
# 启动所有服务
docker-compose up -d

# 查看服务状态
docker-compose ps

# 查看日志
docker-compose logs -f
```

### 6. 初始化数据库

```bash
# 运行数据库初始化脚本
./init-database.sh
```

### 7. 访问平台

- **前端**: http://localhost:3000
- **后端 API**: http://localhost:8088/api
- **管理后台**: http://localhost:3000/admin

## 🔧 高级配置

### 1. 配置 SSL 证书

```bash
# 安装 Certbot
sudo apt install certbot

# 获取证书
sudo certbot certonly --standalone -d your-domain.com

# 配置 Nginx
# 编辑 config/nginx/nginx.conf
```

### 2. 配置反向代理

```nginx
# config/nginx/nginx.conf
server {
    listen 80;
    server_name your-domain.com;

    location / {
        proxy_pass http://localhost:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }

    location /api {
        proxy_pass http://localhost:8088;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

### 3. 配置监控

```bash
# 启动监控服务
docker-compose -f docker-compose.monitoring.yml up -d
```

## ❓ 常见问题

### Q: Docker 启动失败怎么办？
A: 检查 Docker 服务状态：
```bash
sudo systemctl status docker
sudo journalctl -u docker
```

### Q: 端口被占用怎么办？
A: 修改 `.env` 文件中的端口配置：
```bash
SERVER_PORT=8089
FRONTEND_PORT=3001
```

### Q: 数据库连接失败怎么办？
A: 检查数据库服务状态：
```bash
docker-compose logs postgres
```

## 📞 获取帮助

如果遇到问题，请：
1. 查看 [常见问题](#常见问题)
2. 搜索 [GitHub Issues](https://github.com/Meteorkid/Imagent-X-manus/issues)
3. 提交新的 Issue
