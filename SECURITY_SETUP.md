# 🔒 安全配置指南

## ⚠️ 重要提醒

**不要将密码、密钥等敏感信息提交到 Git 仓库！**

## 📋 配置步骤

### 1. 复制环境变量模板

```bash
cp .env.example .env
```

### 2. 编辑 .env 文件

```bash
nano .env
```

### 3. 修改以下关键配置

#### 数据库密码
```
DB_PASSWORD=your_secure_password_here
```

#### JWT 密钥（必须修改！）
```
JWT_SECRET=your_jwt_secret_key_here_make_it_strong_and_random
```

生成强随机密钥：
```bash
openssl rand -base64 32
```

#### 管理员密码
```
IMAGENTX_ADMIN_PASSWORD=change_this_password
```

#### LLM API 密钥
```
OPENAI_API_KEY=your_openai_api_key
ANTHROPIC_API_KEY=your_anthropic_api_key
```

### 4. 验证配置

```bash
# 检查环境变量是否加载
source .env
echo $DB_PASSWORD
echo $JWT_SECRET
```

## 🚨 安全检查清单

- [ ] `.env` 文件已添加到 `.gitignore`
- [ ] 所有默认密码已修改
- [ ] JWT 密钥使用强随机字符串
- [ ] API 密钥已配置
- [ ] 生产环境使用不同的密码

## 🔐 生产环境建议

1. **使用 Secrets 管理工具**
   - Docker Secrets
   - Kubernetes Secrets
   - AWS Secrets Manager
   - HashiCorp Vault

2. **启用 HTTPS**
   - 配置 SSL/TLS 证书
   - 强制 HTTPS 重定向

3. **限制网络访问**
   - 数据库只允许应用访问
   - 管理界面只允许内网访问

4. **定期轮换密钥**
   - JWT 密钥定期更换
   - 数据库密码定期更新

## 📝 相关文件

- `.env.example` - 环境变量模板
- `.env` - 实际配置（不提交）
- `.gitignore` - Git 忽略规则

## ⚡ 快速启动

```bash
# 1. 克隆仓库
git clone https://github.com/Meteorkid/Imagent-X-manus.git
cd "Imagent-X-manus"

# 2. 配置环境变量
cp .env.example .env
# 编辑 .env 文件，修改密码和密钥

# 3. 启动服务
docker-compose up -d
```

## 🆘 常见问题

### Q: 忘记修改密码怎么办？
A: 重新编辑 `.env` 文件，修改密码后重启服务。

### Q: JWT 密钥泄露怎么办？
A: 立即生成新的密钥，更新 `.env` 文件，重启服务。所有已登录用户需要重新登录。

### Q: 如何检查是否有敏感信息泄露？
A: 使用以下工具：
```bash
# 检查 Git 历史
git log --all --pretty=format: --name-only | grep -i "password\|secret\|key"

# 使用 truffleHog 扫描
trufflehog git file://.
```
