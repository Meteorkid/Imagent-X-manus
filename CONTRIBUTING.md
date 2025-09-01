# 贡献指南

感谢您对ImagentX项目的关注！我们欢迎所有形式的贡献，无论是代码、文档、测试还是其他形式的帮助。

## 🤝 如何贡献

### 1. 报告Bug
如果您发现了Bug，请：
- 使用GitHub Issues报告
- 提供详细的复现步骤
- 包含错误日志和截图
- 说明您的环境信息

### 2. 功能建议
如果您有新功能的想法，请：
- 在GitHub Discussions中讨论
- 创建Feature Request Issue
- 描述功能的使用场景和价值

### 3. 代码贡献
如果您想贡献代码，请：
- Fork项目仓库
- 创建功能分支
- 编写测试用例
- 提交Pull Request

## 🚀 开发环境设置

### 环境要求
- Java 17+
- Node.js 18+
- Docker 20.10+
- PostgreSQL 15+

### 本地开发
```bash
# 克隆仓库
git clone https://github.com/Meteor-kid/ImagentX.git
cd ImagentX

# 安装依赖
cd apps/frontend && npm install
cd ../backend && ./mvnw clean install

# 启动服务
./start-all-services.sh
```

## 📝 代码规范

### 代码风格
- 遵循项目现有的代码风格
- 使用有意义的变量和函数名
- 添加必要的注释
- 保持代码简洁清晰

### 提交规范
使用规范的提交信息格式：
```
type(scope): description

[optional body]

[optional footer]
```

类型包括：
- `feat`: 新功能
- `fix`: Bug修复
- `docs`: 文档更新
- `style`: 代码格式调整
- `refactor`: 代码重构
- `test`: 测试相关
- `chore`: 构建过程或辅助工具的变动

### 测试要求
- 新功能需要包含测试用例
- 修复Bug需要包含回归测试
- 保持测试覆盖率不降低

## 🔄 工作流程

### 1. 创建Issue
- 描述问题或功能需求
- 添加适当的标签
- 指定优先级和里程碑

### 2. Fork和克隆
```bash
# Fork项目到您的GitHub账户
# 克隆您的Fork
git clone https://github.com/YOUR_USERNAME/ImagentX.git
cd ImagentX

# 添加上游仓库
git remote add upstream https://github.com/Meteor-kid/ImagentX.git
```

### 3. 创建分支
```bash
# 创建功能分支
git checkout -b feature/your-feature-name

# 或者Bug修复分支
git checkout -b fix/your-bug-description
```

### 4. 开发和测试
- 编写代码
- 运行测试
- 确保代码质量
- 更新相关文档

### 5. 提交代码
```bash
# 添加更改
git add .

# 提交更改
git commit -m "feat: add new feature description"

# 推送到您的Fork
git push origin feature/your-feature-name
```

### 6. 创建Pull Request
- 在GitHub上创建PR
- 填写PR模板
- 链接相关Issue
- 等待代码审查

## 📚 文档贡献

### 文档类型
- 用户指南
- API文档
- 开发文档
- 部署指南
- 故障排除

### 文档要求
- 使用清晰的Markdown格式
- 包含代码示例
- 提供截图和图表
- 保持文档的时效性

## 🧪 测试贡献

### 测试类型
- 单元测试
- 集成测试
- 端到端测试
- 性能测试
- 安全测试

### 测试要求
- 测试覆盖率不低于80%
- 测试用例清晰易懂
- 包含边界条件测试
- 提供测试数据

## 🔒 安全贡献

如果您发现了安全漏洞，请：
- **不要**在公开的Issue中报告
- 发送邮件到安全团队
- 等待安全团队响应
- 配合安全团队修复

## 📋 审查流程

### 代码审查
- 至少需要一名维护者审查
- 审查者会检查代码质量
- 可能需要修改和改进
- 通过审查后合并代码

### 审查重点
- 代码质量和风格
- 功能完整性
- 测试覆盖
- 文档更新
- 性能影响

## 🎉 贡献者权益

### 贡献者列表
- 您的名字将出现在贡献者列表中
- 获得项目的贡献者徽章
- 参与项目的决策讨论

### 社区参与
- 加入项目讨论
- 参与功能规划
- 帮助其他贡献者
- 推广项目

## 📞 获取帮助

### 交流渠道
- GitHub Issues
- GitHub Discussions
- 项目Wiki
- 邮件列表

### 资源链接
- [项目主页](https://github.com/Meteor-kid/ImagentX)
- [API文档](docs/api-reference/README.md)
- [开发指南](docs/develop_document.md)
- [部署指南](docs/deployment/README.md)

## 🙏 致谢

感谢所有为ImagentX项目做出贡献的开发者！您的贡献让这个项目变得更好。

---

**让我们一起构建更好的AI智能体平台！** 🚀
