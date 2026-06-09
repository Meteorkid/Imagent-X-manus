# 🚀 GitHub Actions 配置指南

## 📋 概述

本指南帮助您配置和启用 ImagentX 项目的 GitHub Actions 工作流。

## 🎯 已配置的工作流

### 1. 安全扫描 (security-scan.yml)
- **触发条件**: 推送到 main/develop、PR、每周一定时
- **功能**: 依赖漏洞检查、代码扫描、密钥检测、许可证检查

### 2. PR 检查 (pr-check.yml)
- **触发条件**: 创建 PR 到 main/develop
- **功能**: 代码质量检查、单元测试、测试覆盖率、构建、安全检查

## 🔧 启用 GitHub Actions

### 1. 检查工作流文件

确保 `.github/workflows/` 目录下有以下文件：
- `security-scan.yml`
- `pr-check.yml`

### 2. 推送到 GitHub

```bash
cd /Users/meteor/github/Imagent\ X
git add .github/workflows/
git commit -m "ci: 添加 GitHub Actions 工作流"
git push origin main
```

### 3. 检查工作流状态

1. 访问 GitHub 仓库
2. 点击 "Actions" 标签
3. 查看工作流运行状态

## 📊 工作流说明

### 安全扫描工作流

```yaml
name: Security Scan

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]
  schedule:
    - cron: '0 2 * * 1'  # 每周一凌晨 2 点
```

**包含的检查**:
- OWASP Dependency Check - 依赖漏洞扫描
- Trivy - 代码安全扫描
- TruffleHog - 密钥检测
- License Check - 许可证合规检查

### PR 检查工作流

```yaml
name: PR Check

on:
  pull_request:
    branches: [ main, develop ]
```

**包含的检查**:
- Code Quality - Checkstyle、SpotBugs
- Unit Tests - Maven 单元测试
- Test Coverage - JaCoCo 覆盖率
- Build - 后端和前端构建
- Security - Trivy 安全扫描

## 🔧 配置 secrets（可选）

如果需要更高级的功能，可以配置以下 secrets：

1. 进入仓库 Settings → Secrets and variables → Actions
2. 添加以下 secrets（如果需要）：
   - `CODECOV_TOKEN` - Codecov 上传令牌
   - `SLACK_WEBHOOK_URL` - Slack 通知 webhook

## 📈 查看工作流结果

### 1. 工作流运行历史

访问 `https://github.com/{owner}/{repo}/actions` 查看所有工作流运行。

### 2. PR 检查结果

在 PR 页面会显示所有检查的结果：
- ✅ 通过
- ❌ 失败
- ⏳ 进行中

### 3. 安全扫描报告

安全扫描报告会作为 artifact 上传，可以在工作流运行详情中下载。

## 🚨 常见问题

### Q: 工作流没有运行？

**可能原因**:
1. GitHub Actions 未启用
2. 工作流文件语法错误
3. 权限不足

**解决方法**:
1. 进入 Settings → Actions → General
2. 确保 "Allow all actions" 已启用
3. 检查工作流文件语法

### Q: 测试失败怎么办？

**解决方法**:
1. 查看测试报告
2. 在本地运行 `mvn test`
3. 修复失败的测试
4. 推送修复代码

### Q: 安全扫描发现漏洞？

**解决方法**:
1. 查看安全扫描报告
2. 评估漏洞风险
3. 升级依赖或应用修复
4. 重新运行扫描

## 📚 相关文档

- [GitHub Actions 官方文档](https://docs.github.com/en/actions)
- [安全扫描工作流](../.github/workflows/security-scan.yml)
- [PR 检查工作流](../.github/workflows/pr-check.yml)
