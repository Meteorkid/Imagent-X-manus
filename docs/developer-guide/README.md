# ImagentX 开发指南

## 概述

欢迎加入ImagentX开发团队！本指南将帮助您快速上手项目开发。

## 🛠️ 开发环境

### 系统要求
- **操作系统**: macOS 10.15+, Ubuntu 18.04+, Windows 10+
- **Java**: OpenJDK 17+
- **Node.js**: 18+
- **数据库**: PostgreSQL 13+
- **消息队列**: RabbitMQ 3.8+

### 开发工具
- **IDE**: IntelliJ IDEA / VS Code
- **数据库工具**: DBeaver / pgAdmin
- **API测试**: Postman / Apifox
- **版本控制**: Git

## 🚀 快速开始

### 1. 克隆项目
```bash
git clone https://github.com/imagentx/imagentx.git
cd imagentx
```

### 2. 后端环境配置
```bash
# 安装Java 17
brew install openjdk@17  # macOS
sudo apt install openjdk-17-jdk  # Ubuntu

# 安装Maven
brew install maven  # macOS
sudo apt install maven  # Ubuntu

# 配置环境变量
export JAVA_HOME=/path/to/java17
export PATH=$JAVA_HOME/bin:$PATH
```

### 3. 前端环境配置
```bash
# 安装Node.js
brew install node  # macOS
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -  # Ubuntu
sudo apt-get install -y nodejs

# 安装依赖
cd imagentx-frontend-plus
npm install
```

### 4. 数据库配置
```bash
# 安装PostgreSQL
brew install postgresql  # macOS
sudo apt install postgresql postgresql-contrib  # Ubuntu

# 创建数据库
createdb imagentx_dev
createdb imagentx_test
```

### 5. 启动服务
```bash
# 启动后端
cd ImagentX
mvn spring-boot:run

# 启动前端
cd imagentx-frontend-plus
npm run dev
```

## 🏗️ 项目架构

### 后端架构 (DDD)
```
ImagentX/
├── src/main/java/org/xhy/
│   ├── application/          # 应用层
│   │   ├── service/         # 应用服务
│   │   └── dto/            # 数据传输对象
│   ├── domain/              # 领域层
│   │   ├── model/          # 领域模型
│   │   ├── service/        # 领域服务
│   │   └── repository/     # 仓储接口
│   ├── infrastructure/      # 基础设施层
│   │   ├── config/         # 配置类
│   │   ├── repository/     # 仓储实现
│   │   └── external/       # 外部服务
│   └── interfaces/          # 接口层
│       ├── api/            # API接口
│       └── dto/            # 接口DTO
```

### 前端架构 (Next.js)
```
imagentx-frontend-plus/
├── app/                     # App Router
│   ├── (auth)/             # 认证页面
│   ├── (dashboard)/        # 仪表板页面
│   └── api/                # API路由
├── components/              # React组件
│   ├── ui/                 # 基础UI组件
│   └── features/           # 功能组件
├── lib/                     # 工具库
├── hooks/                   # 自定义Hooks
└── types/                   # TypeScript类型
```

## 📝 开发规范

### 代码规范
- **Java**: 遵循Google Java Style Guide
- **JavaScript/TypeScript**: 使用ESLint + Prettier
- **提交信息**: 遵循Conventional Commits

### 分支管理
- **main**: 主分支，用于生产环境
- **develop**: 开发分支，用于集成测试
- **feature/***: 功能分支
- **hotfix/***: 热修复分支

### 提交规范
```
feat: 添加新功能
fix: 修复bug
docs: 更新文档
style: 代码格式调整
refactor: 代码重构
test: 添加测试
chore: 构建过程或辅助工具的变动
```

## 🧪 测试

### 后端测试
```bash
# 运行单元测试
mvn test

# 运行集成测试
mvn verify

# 生成测试报告
mvn jacoco:report
```

### 前端测试
```bash
# 运行单元测试
npm test

# 运行E2E测试
npm run test:e2e

# 生成覆盖率报告
npm run test:coverage
```

## 🚀 部署

### 本地部署
```bash
# 构建后端
mvn clean package

# 构建前端
npm run build

# 启动Docker服务
docker-compose up -d
```

### 生产部署
```bash
# 使用部署脚本
./deploy/deploy.sh production
```

## 📚 学习资源

### 技术文档
- [Spring Boot官方文档](https://spring.io/projects/spring-boot)
- [Next.js官方文档](https://nextjs.org/docs)
- [PostgreSQL官方文档](https://www.postgresql.org/docs/)

### 项目文档
- [API文档](./api-reference.md)
- [数据库设计](./database-design.md)
- [部署指南](./deployment-guide.md)

## 🤝 贡献指南

### 提交流程
1. Fork项目
2. 创建功能分支
3. 提交代码
4. 创建Pull Request
5. 代码审查
6. 合并代码

### 代码审查
- 所有代码必须通过审查
- 至少需要一名团队成员批准
- 确保测试覆盖率不低于80%

## 📞 联系方式

- **技术讨论**: https://github.com/imagentx/imagentx/discussions
- **问题反馈**: https://github.com/imagentx/imagentx/issues
- **团队邮箱**: dev-team@imagentx.ai
