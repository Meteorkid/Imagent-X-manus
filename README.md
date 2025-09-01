# ImagentX - 智能AI助手平台

## 🚀 项目简介

ImagentX是一个基于Spring Boot和React的智能AI助手平台，提供强大的AI对话、知识管理和工具集成功能。

## 📁 项目结构 (v2.0.0)

```
ImagentX-master/
├── 📁 apps/                          # 应用程序目录
│   ├── backend/                      # 后端应用 (Spring Boot)
│   └── frontend/                     # 前端应用 (React/Next.js)
│
├── 📁 scripts/                       # 脚本管理
│   ├── core/                         # 核心脚本 (启动/停止/状态)
│   ├── deployment/                   # 部署脚本
│   ├── enhancement/                  # 增强脚本
│   ├── testing/                      # 测试脚本
│   └── utils/                        # 工具脚本
│
├── 📁 config/                        # 配置文件
│   ├── docker/                       # Docker配置
│   ├── nginx/                        # Nginx配置
│   ├── database/                     # 数据库配置
│   └── environment/                  # 环境配置
│
├── 📁 docs/                          # 文档中心
│   ├── guides/                       # 使用指南
│   ├── api/                          # API文档
│   ├── deployment/                   # 部署文档
│   ├── development/                  # 开发文档
│   └── troubleshooting/              # 故障排除
│
├── 📁 deployment/                    # 部署相关
├── 📁 tools/                         # 工具和实用程序
├── 📁 reports/                       # 报告和审计
├── 📁 resources/                     # 资源文件
└── 📁 temp/                          # 临时文件
```

## 🚀 快速开始

### 环境要求
- Java 17+
- Node.js 18+
- Docker (可选)
- Maven (可选，项目包含Maven Wrapper)

### 启动服务

#### 1. 核心服务 (推荐)
```bash
./scripts/core/start.sh --core
```

#### 2. 本地开发
```bash
./scripts/core/start.sh --local
```

#### 3. 完整服务
```bash
./scripts/core/start.sh --full
```

### 检查状态
```bash
./scripts/core/status.sh
```

### 停止服务
```bash
./scripts/core/stop.sh
```

## 📚 文档

- [使用指南](docs/guides/)
- [API文档](docs/api/)
- [部署文档](docs/deployment/)
- [开发文档](docs/development/)
- [故障排除](docs/troubleshooting/)

## 🔧 配置

- [Docker配置](config/docker/)
- [环境配置](config/environment/)
- [数据库配置](config/database/)

## 🛠️ 工具

- [MCP网关](tools/mcp-gateway/)
- [监控工具](tools/monitoring/)
- [测试工具](tools/testing/)

## 📊 项目统计

- **文件数量**: 30,043个
- **目录数量**: 3,488个
- **脚本文件**: 36个
- **文档文件**: 621个
- **配置文件**: 66个

## 🎯 主要功能

### AI对话
- 智能对话系统
- 多模型支持
- 上下文管理
- 对话历史

### 知识管理
- 文档上传
- 知识库构建
- 智能检索
- RAG集成

### 工具集成
- MCP网关
- 插件系统
- 工作流引擎
- 监控工具

### 用户管理
- 用户认证
- 权限控制
- 团队协作
- 计费系统

## 🔄 开发模式

### 本地开发
```bash
# 启动本地开发环境
./scripts/core/start.sh --local

# 检查服务状态
./scripts/core/status.sh --health

# 查看日志
tail -f temp/logs/backend.log
tail -f temp/logs/frontend.log
```

### 测试
```bash
# 运行测试
./scripts/testing/run-tests.sh

# 检查测试报告
./scripts/core/status.sh --health
```

### 部署
```bash
# Docker部署
./scripts/deployment/docker-deploy.sh

# 生产环境
./scripts/core/start.sh --full
```

## 🚨 故障排除

### 常见问题

#### 1. 端口被占用
```bash
# 检查端口占用
./scripts/core/status.sh --ports

# 停止占用端口的进程
./scripts/core/stop.sh --force
```

#### 2. Docker服务未启动
```bash
# 检查Docker状态
./scripts/core/status.sh --docker

# 启动Docker Desktop
# 然后重新运行启动脚本
```

#### 3. 依赖安装失败
```bash
# 清理环境
./scripts/core/stop.sh --clean

# 重新安装依赖
cd apps/frontend && npm install
cd ../backend && ./mvnw clean install
```

## 📞 支持

- **文档**: 查看 `docs/` 目录
- **问题**: 查看 `docs/troubleshooting/`
- **配置**: 查看 `config/` 目录
- **脚本**: 查看 `scripts/` 目录

## 🤝 贡献

1. Fork 项目
2. 创建功能分支
3. 提交更改
4. 推送到分支
5. 创建 Pull Request

## 📄 许可证

本项目采用 [LICENSE](LICENSE) 许可证。

## 🎉 更新日志

### v2.0.0 (当前版本)
- ✅ 项目结构重组完成
- ✅ 脚本整合优化
- ✅ 文档体系完善
- ✅ 配置管理统一
- ✅ 工具集成增强

### v1.x.x
- 初始版本发布
- 基础功能实现
- 核心模块开发

---

**项目维护**: AI Assistant  
**最后更新**: $(date)  
**版本**: v2.0.0# ImagentX Project - Updated Wed Aug 27 11:04:37 CST 2025
