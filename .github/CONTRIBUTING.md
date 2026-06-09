# 🤝 贡献指南

感谢您对 ImagentX 的关注！我们欢迎所有形式的贡献。

## 📋 贡献方式

### 1. 报告 Bug

如果您发现了 Bug，请：
1. 搜索 [GitHub Issues](https://github.com/Meteorkid/Imagent-X-manus/issues) 确认是否已存在
2. 如果不存在，创建新的 Issue
3. 提供详细的信息：
   - 问题描述
   - 复现步骤
   - 期望行为
   - 实际行为
   - 环境信息

### 2. 提出新功能

如果您有新功能建议，请：
1. 搜索 [GitHub Discussions](https://github.com/Meteorkid/Imagent-X-manus/discussions) 确认是否已存在
2. 如果不存在，创建新的 Discussion
3. 详细描述：
   - 功能描述
   - 使用场景
   - 预期效果

### 3. 提交代码

如果您想贡献代码，请：
1. Fork 项目
2. 创建功能分支
3. 提交代码
4. 创建 Pull Request

## 🚀 开发流程

### 1. 设置开发环境

```bash
# 克隆仓库
git clone https://github.com/your-username/Imagent-X-manus.git
cd "Imagent-X-manus"

# 安装依赖
# 后端
cd apps/backend
mvn clean install

# 前端
cd ../frontend
npm install
```

### 2. 创建功能分支

```bash
# 从 main 分支创建功能分支
git checkout -b feature/your-feature-name
```

### 3. 开发和测试

```bash
# 开发功能
# ...

# 运行测试
# 后端
cd apps/backend
mvn test

# 前端
cd ../frontend
npm test
```

### 4. 提交代码

```bash
# 添加修改
git add .

# 提交代码（遵循提交规范）
git commit -m "feat: 添加新功能描述"

# 推送到远程
git push origin feature/your-feature-name
```

### 5. 创建 Pull Request

1. 访问 GitHub 仓库
2. 点击 "New pull request"
3. 选择您的分支
4. 填写 PR 描述
5. 提交 PR

## 📝 提交规范

### 提交信息格式

```
<type>(<scope>): <subject>

<body>

<footer>
```

### 类型说明

| 类型 | 说明 |
|------|------|
| feat | 新功能 |
| fix | 修复 bug |
| docs | 文档更新 |
| style | 代码格式调整（不影响代码运行） |
| refactor | 重构（既不修复 bug 也不添加功能） |
| test | 添加测试 |
| chore | 构建过程或辅助工具的变动 |

### 示例

```
feat(agent): 添加智能体版本管理功能

- 支持智能体版本创建
- 支持版本回滚
- 添加版本历史记录

Closes #123
```

## 🔍 代码审查

### 审查标准

1. **代码质量**
   - 遵循代码规范
   - 代码清晰易读
   - 适当的注释

2. **功能完整性**
   - 功能按需求实现
   - 边界情况处理
   - 错误处理完善

3. **测试覆盖**
   - 单元测试完整
   - 集成测试覆盖
   - 测试通过

4. **文档更新**
   - API 文档更新
   - 使用文档更新
   - 变更日志更新

### 审查流程

1. 提交 PR
2. 自动化测试运行
3. 至少一名团队成员审查
4. 根据反馈修改
5. 合并代码

## 🎯 贡献者等级

### 1. 贡献者 (Contributor)
- 提交过至少一个被合并的 PR
- 获得贡献者徽章

### 2. 活跃贡献者 (Active Contributor)
- 提交过至少 10 个被合并的 PR
- 参与代码审查
- 获得活跃贡献者徽章

### 3. 核心贡献者 (Core Contributor)
- 提交过至少 50 个被合并的 PR
- 持续参与项目维护
- 获得核心贡献者徽章
- 获得仓库写权限

## 📞 获取帮助

如果您在贡献过程中遇到问题，请：
1. 查看本文档
2. 搜索 [GitHub Discussions](https://github.com/Meteorkid/Imagent-X-manus/discussions)
3. 创建新的 Discussion
4. 联系维护团队

## 📜 行为准则

### 我们的承诺

为了营造一个开放和友好的环境，我们承诺：
- 尊重每位参与者
- 接受建设性的批评
- 关注对社区最有利的事情
- 对其他社区成员表示同理心

### 我们的标准

以下行为是不可接受的：
- 使用性暗示的语言或图像
- 恶意评论、人身攻击或政治攻击
- 公开或私下的骚扰
- 未经明确许可发布他人的私人信息
- 其他在专业环境中被合理认为不当的行为

## 🙏 致谢

感谢所有为 ImagentX 做出贡献的人！
