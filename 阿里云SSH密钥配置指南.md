# ☁️ 阿里云SSH密钥配置指南

## 📋 阿里云操作步骤

### 方法1: 通过阿里云控制台添加密钥对（推荐）

#### 1.1 登录阿里云控制台
1. 访问 [阿里云控制台](https://console.aliyun.com/)
2. 使用您的阿里云账号登录

#### 1.2 进入ECS实例管理
1. 在控制台首页，点击 **云服务器ECS**
2. 在左侧菜单中，选择 **实例**
3. 找到您的服务器实例 `103.151.173.98`

#### 1.3 绑定密钥对
1. 在实例列表中，找到您的服务器
2. 点击 **更多** → **密码/密钥** → **绑定密钥对**
3. 选择 **导入密钥对**
4. 输入密钥对名称：`imagentx-deploy`
5. 粘贴您的公钥内容：

```
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCT2mO7NwqPMb5ajaAN6Z/U7Ou4Ow
ci0Cj40+lEU1L+0oEq5jHVc/pFTs3rnWtfmAWgZSdW+A5lboFuZus+KwRVbPqWiLZo
Vyg92X8dteLmW/bwlT5x4BHgNwCOgZp+hTXqjiuKk+3Pky/YGBT9vjfh2eiz0iiye/
CURdfF3UhHLlP+bZe+I1AWpIGqlqZ45x+RKblRqgKGnYeveCtHCVJ0rjzjtFugFZA3
O0k6YXLnwc9O3W9io04h6d8St/2dfIiPnaDQtK73zXLKsOdJQ1YoH52E6fsqnbm41Y
tUxQdwXKZg9Sdsv79zzOOSmjBeIyQnIrbsw1a+zj8Hcn30Qs4PNGDkRHIe624GhWa+
GwiWVqYKPJH6WX+WCLLyphXuWIYAsKMCWNGQEy5XgQOvv/KfsBRtkYAPikto+YCIuj
8he58inHWsHkC6JDBffSQ2GxQR9ZMx9aaEtUGLNT9ueRQtFCY6AxfjU7l8VYiXHpeV
MWUVufIwHZ+iuPmJVDEtGAjmDFoxaaooJz+LFZBGgK97mmuGMFhz7c3w93uT6Mnv8x
BZ13ezWrZav1I2onyk8Atk3YhQkIm4zx5zJGClkU3QXn6ShlK0ehNLGnUDsoAT+TuN
WYdyqID8moErU8h7AZjKmeOyRqI2CUCgLzEr1LS+clIQQ8i4bAKHIGvsHviOfw== m
ereor@MeteorMacBook-Pro.local
```

6. 点击 **确定** 完成导入

#### 1.4 绑定密钥对到实例
1. 在实例列表中，选择您的服务器
2. 点击 **更多** → **密码/密钥** → **绑定密钥对**
3. 选择刚创建的密钥对 `imagentx-deploy`
4. 点击 **确定** 完成绑定

### 方法2: 通过VNC控制台直接添加

#### 2.1 连接VNC控制台
1. 在ECS实例列表中，找到您的服务器
2. 点击 **远程连接**
3. 选择 **VNC远程连接**
4. 点击 **立即登录**

#### 2.2 在服务器上添加公钥
1. 使用VNC登录到服务器
2. 在服务器终端中执行以下命令：

```bash
# 创建.ssh目录
mkdir -p ~/.ssh

# 创建authorized_keys文件
touch ~/.ssh/authorized_keys

# 添加公钥到authorized_keys文件
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCT2mO7NwqPMb5ajaAN6Z/U7Ou4Ow
ci0Cj40+lEU1L+0oEq5jHVc/pFTs3rnWtfmAWgZSdW+A5lboFuZus+KwRVbPqWiLZo
Vyg92X8dteLmW/bwlT5x4BHgNwCOgZp+hTXqjiuKk+3Pky/YGBT9vjfh2eiz0iiye/
CURdfF3UhHLlP+bZe+I1AWpIGqlqZ45x+RKblRqgKGnYeveCtHCVJ0rjzjtFugFZA3
O0k6YXLnwc9O3W9io04h6d8St/2dfIiPnaDQtK73zXLKsOdJQ1YoH52E6fsqnbm41Y
tUxQdwXKZg9Sdsv79zzOOSmjBeIyQnIrbsw1a+zj8Hcn30Qs4PNGDkRHIe624GhWa+
GwiWVqYKPJH6WX+WCLLyphXuWIYAsKMCWNGQEy5XgQOvv/KfsBRtkYAPikto+YCIuj
8he58inHWsHkC6JDBffSQ2GxQR9ZMx9aaEtUGLNT9ueRQtFCY6AxfjU7l8VYiXHpeV
MWUVufIwHZ+iuPmJVDEtGAjmDFoxaaooJz+LFZBGgK97mmuGMFhz7c3w93uT6Mnv8x
BZ13ezWrZav1I2onyk8Atk3YhQkIm4zx5zJGClkU3QXn6ShlK0ehNLGnUDsoAT+TuN
WYdyqID8moErU8h7AZjKmeOyRqI2CUCgLzEr1LS+clIQQ8i4bAKHIGvsHviOfw== m
ereor@MeteorMacBook-Pro.local" >> ~/.ssh/authorized_keys

# 设置正确的权限
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys

# 验证添加结果
cat ~/.ssh/authorized_keys
```

## 🔍 验证密钥配置

### 测试SSH连接
在您的Mac终端中执行：

```bash
# 测试SSH连接
./upload-deploy-package.sh --test
```

### 预期结果
```
📋 服务器信息
--------------------------------
服务器IP: 103.151.173.98
用户名: root
SSH配置: imagentx-server
部署包: imagentx-deploy.tar.gz

🔌 测试SSH连接
--------------------------------
✅ SSH密钥存在
测试连接到服务器...
✅ SSH连接成功
```

## 🚀 密钥配置完成后

一旦SSH连接成功，您就可以开始部署：

### 1. 上传部署包
```bash
./upload-deploy-package.sh --upload
```

### 2. 设置部署环境
```bash
./upload-deploy-package.sh --setup
```

### 3. 执行部署
```bash
./upload-deploy-package.sh --deploy
```

## 📞 阿里云技术支持

如果遇到问题：

### 1. 阿里云文档
- [ECS密钥对使用指南](https://help.aliyun.com/document_detail/51793.html)
- [SSH密钥对管理](https://help.aliyun.com/document_detail/51793.html)

### 2. 常见问题
- **密钥对绑定失败**: 检查实例状态，确保实例运行正常
- **VNC连接失败**: 检查安全组设置，确保开放了相应端口
- **权限问题**: 确保使用root用户或有sudo权限的用户

### 3. 联系支持
- 阿里云技术支持热线：400-801-3260
- 在线客服：阿里云控制台右上角

## 🎯 操作步骤总结

1. **登录阿里云控制台**
2. **进入ECS实例管理**
3. **导入SSH密钥对**
4. **绑定密钥对到实例**
5. **测试SSH连接**
6. **开始部署ImagentX项目**

**请按照上述步骤操作，完成后告诉我结果，我们就可以继续部署了！** 🚀
