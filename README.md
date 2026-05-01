# ImagentX - AI Agent Platform

[![Version](https://img.shields.io/badge/version-1.0.3-blue.svg)](https://github.com/Meteorkid/Imagent-X-manus/releases)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Docker](https://img.shields.io/badge/docker-ready-blue.svg)](https://www.docker.com/)

## 🚀 项目简介

ImagentX 是一个完整的AI智能体平台，集成了OpenManus技术，提供智能自动化、知识管理和多模态AI能力。该平台专为企业级AI应用开发而设计，支持快速部署和扩展。

## ✨ 核心特性

### 🤖 AI智能体管理
- **智能体创建与配置**: 支持多种AI模型的智能体创建
- **工作流编排**: 基于OpenManus的高级工作流管理
- **版本控制**: 智能体版本管理和回滚功能
- **性能监控**: 实时性能指标和优化建议

### 📚 知识库集成
- **RAG系统**: 检索增强生成技术
- **文档处理**: 支持多种格式的文档上传和处理
- **向量数据库**: 基于pgvector的高效相似性搜索
- **知识图谱**: 智能知识关联和推理

### 🔌 多模态支持
- **文本处理**: 自然语言理解和生成
- **图像分析**: 计算机视觉和图像识别
- **文件处理**: 多格式文件上传和解析
- **API集成**: 丰富的第三方服务集成

### 🛡️ 安全与监控
- **身份认证**: 多因素认证和权限管理
- **API管理**: 完整的API密钥管理和使用追踪
- **安全监控**: 实时安全事件检测和响应
- **审计日志**: 完整的操作记录和审计追踪

## 🏗️ 技术架构

### 前端技术栈
- **框架**: Next.js 14 + TypeScript
- **样式**: Tailwind CSS + 响应式设计
- **状态管理**: React Context + Hooks
- **UI组件**: 自定义组件库 + shadcn/ui

### 后端技术栈
- **语言**: Java 17 + Spring Boot 3
- **数据库**: PostgreSQL 15 + pgvector
- **缓存**: Redis + 本地缓存
- **消息队列**: RabbitMQ + WebSocket

### 部署与运维
- **容器化**: Docker + Docker Compose
- **监控**: Prometheus + Grafana + Kibana
- **CI/CD**: GitHub Actions + 自动化部署
- **性能优化**: CDN + 负载均衡

## 📦 版本信息

当前发布版本：**v1.0.3**（Git 标签与 `package.json` / `apps/backend/pom.xml` 一致）。  
完整标签与发行说明见：[Releases](https://github.com/Meteorkid/Imagent-X-manus/releases)。

### v1.0.3（当前）

- 将 monorepo 与后端制品版本统一为 **1.0.3**（根目录与 `apps/frontend` 的 `package.json`、`apps/backend` 的 Maven 版本、Docker / 手动安全扫描 workflow 中的 `imagent-x-1.0.3.jar` 命名一致）。
- 在 **v1.0.2** 之后的 CI 修复基础上发版：Tests 工作流中「集成测试」步骤在无 `*IntegrationTest` 用例时不再误报失败；CI 通过 `docker build` 对前后端镜像做冒烟构建；推送 semver 标签时的镜像构建指向 **`apps/backend/Dockerfile`**。
- 建议以 **`v1.0.3` 标签** 作为 Docker 镜像构建与自动化发布的参考版本（优于早期仅修复 CI、未打新标签的提交）。

### v1.0.2

- 首次在发布流程中将**可安装制品版本**与 Git **semver 标签**对齐（后端由 `0.0.1-SNAPSHOT` 转为 **`1.0.2`**，并同步根目录与前端包版本、Docker 与 workflow 中的 JAR 文件名）。
- 后端接入 **JaCoCo**，`mvn test` / `mvn jacoco:report` 在 CI 中可稳定执行；Codecov 上传失败默认不再拖垮整次流水线。
- **Tests** 工作流：OWASP ZAP 改为在需要时 **手动触发**（`workflow_dispatch`），并在该流程中补充启动后端与依赖说明；**性能测试** job 在仓库尚未纳入 `integration-tests/performance` 前保持跳过，避免无效失败。

### v1.0.1

- 完整的平台基础架构与 OpenManus 智能体集成、UI 与文档、部署与脚本、安全与国际化等基线能力（详见历史提交与首版标签说明）。

## 🚀 快速开始

### 环境要求
- Docker 20.10+
- Docker Compose 2.0+
- Node.js 18+
- Java 17+
- PostgreSQL 15+

### 本地开发
```bash
# 克隆仓库
git clone https://github.com/Meteorkid/Imagent-X-manus.git
cd "Imagent-X-manus"

# 启动所有服务
./start-all-services.sh

# 或者使用Docker Compose
docker-compose -f docker-compose-local-dev.yml up -d
```

### 生产部署
```bash
# 使用生产部署脚本
./deploy-production.sh --init

# 或者手动部署
docker-compose -f docker-compose-production.yml up -d
```

## 📖 详细文档

- [🚀 启动指南](docs/guides/START_GUIDE.md)
- [📦 Monorepo 说明](MONOREPO.md)（主前端：`apps/frontend`）
- [🛠️ 工程改进基线](docs/guides/ENGINEERING_BASELINE.md)
- [🏛️ 架构治理基线（2026Q2）](docs/guides/ARCHITECTURE_GOVERNANCE_BASELINE.md)
- [🗃️ 数据库变更治理（Flyway Core）](docs/guides/DB_CHANGE_GOVERNANCE.md)
- [🔁 LangChain4j 迁移方案 A](docs/guides/LANGCHAIN4J_MIGRATION_PLAN_A.md)
- [🔧 开发文档](docs/develop_document.md)
- [📚 API参考](docs/api-reference/README.md)
- [🐳 Docker部署](docs/deployment/docker/DOCKER_SETUP.md)
- [🔒 安全指南](docs/guides/SECURITY_ENHANCEMENT_GUIDE.md)
- [📱 移动端指南](docs/guides/MOBILE_INTERNATIONALIZATION_GUIDE.md)

## 🌟 特色功能

### OpenManus集成
- 智能体工作流编排
- 高级任务调度
- 动态资源分配
- 智能负载均衡

### 性能优化
- CDN加速策略
- 数据库查询优化
- 缓存策略优化
- 前端性能监控

### 开发工具
- API测试集合
- 性能基准测试
- 自动化测试框架
- 代码质量检查

## 🤝 贡献指南

我们欢迎所有形式的贡献！请查看我们的[贡献指南](CONTRIBUTING.md)了解详情。

### 贡献方式
- 🐛 报告Bug
- 💡 提出新功能建议
- 📝 改进文档
- 🔧 提交代码修复
- 🌍 翻译和本地化

## 📄 许可证

本项目采用 [MIT 许可证](LICENSE) 开源。

## 📞 联系我们

- **项目主页**: [Imagent-X-manus](https://github.com/Meteorkid/Imagent-X-manus)
- **问题反馈**: [GitHub Issues](https://github.com/Meteorkid/Imagent-X-manus/issues)
- **讨论交流**: [GitHub Discussions](https://github.com/Meteorkid/Imagent-X-manus/discussions)

## 🙏 致谢

感谢所有为这个项目做出贡献的开发者和用户！

---

**ImagentX v1.0.3** - 让AI智能体开发更简单、更强大！ 🚀
