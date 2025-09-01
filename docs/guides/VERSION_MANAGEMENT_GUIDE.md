# ImagentX 版本管理指南

## 📋 概述

本指南详细说明如何管理ImagentX项目的版本发布，包括新版本创建、旧版本访问和版本回滚等操作。

## 🔄 版本发布流程

### 1. 准备新版本

#### 使用自动化脚本（推荐）
```bash
# 准备版本1.0.2
./scripts/version-management.sh prepare 1.0.2

# 脚本会自动：
# - 检查Git状态
# - 更新版本号
# - 创建发布分支
# - 提交版本更新
```

#### 手动操作
```bash
# 确保在main分支上
git checkout main
git pull origin main

# 创建发布分支
git checkout -b release/v1.0.2

# 更新版本号
# 编辑相关文件...

# 提交更改
git add .
git commit -m "chore: prepare release v1.0.2"
```

### 2. 完成版本发布

#### 使用自动化脚本
```bash
# 完成版本1.0.2发布
./scripts/version-management.sh release 1.0.2

# 脚本会自动：
# - 创建版本标签
# - 推送发布分支和标签
# - 合并到主分支
# - 清理发布分支
```

#### 手动操作
```bash
# 创建版本标签
git tag -a v1.0.2 -m "ImagentX v1.0.2 Release"

# 推送标签
git push origin v1.0.2

# 合并到主分支
git checkout main
git merge release/v1.0.2
git push origin main

# 清理发布分支
git branch -d release/v1.0.2
git push origin --delete release/v1.0.2
```

## 📥 旧版本访问

### ✅ 完全支持！所有旧版本都可以访问

#### 1. 通过Git标签访问
```bash
# 克隆仓库
git clone https://github.com/Meteorkid/Imagent-X-manus.git
cd Imagent-X-manus

# 查看所有可用版本
git tag -l

# 切换到特定版本
git checkout v1.0.1

# 或者创建版本分支
git checkout -b v1.0.1-branch v1.0.1
```

#### 2. 通过GitHub Releases下载
1. 访问GitHub仓库
2. 点击 "Releases"
3. 选择需要的版本
4. 下载ZIP文件或查看源代码

#### 3. 直接下载链接
- **v1.0.1**: `https://github.com/Meteorkid/Imagent-X-manus/archive/v1.0.1.zip`
- **v1.0.2**: `https://github.com/Meteorkid/Imagent-X-manus/archive/v1.0.2.zip`
- **主分支**: `https://github.com/Meteorkid/Imagent-X-manus/archive/main.zip`

## 🏷️ 版本号规范

### 语义化版本 (SemVer)
```
v主版本.次版本.修订号
例如：v1.0.1

- 主版本号：不兼容的API修改
- 次版本号：向下兼容的功能性新增  
- 修订号：向下兼容的问题修正
```

### 版本类型说明

#### 主版本 (Major)
- 重大架构变更
- 不兼容的API修改
- 数据库结构重大变更
- 示例：v1.0.0 → v2.0.0

#### 次版本 (Minor)
- 新功能添加
- 向下兼容的API扩展
- 性能改进
- 示例：v1.0.0 → v1.1.0

#### 修订版本 (Patch)
- Bug修复
- 安全补丁
- 文档更新
- 示例：v1.0.0 → v1.0.1

## 🔧 版本管理工具

### 自动化脚本

#### 脚本位置
```bash
./scripts/version-management.sh
```

#### 可用命令
```bash
# 显示帮助
./scripts/version-management.sh help

# 准备新版本
./scripts/version-management.sh prepare 1.0.2

# 完成版本发布
./scripts/version-management.sh release 1.0.2

# 创建版本标签
./scripts/version-management.sh tag 1.0.2
```

### 手动版本管理

#### 创建版本标签
```bash
# 轻量标签
git tag v1.0.2

# 带注释的标签（推荐）
git tag -a v1.0.2 -m "ImagentX v1.0.2 Release"

# 推送标签
git push origin v1.0.2

# 推送所有标签
git push origin --tags
```

#### 删除标签
```bash
# 删除本地标签
git tag -d v1.0.2

# 删除远程标签
git push origin --delete v1.0.2
```

## 📚 版本文档管理

### CHANGELOG.md 更新
每次发布新版本时，需要更新CHANGELOG.md：

```markdown
## [1.0.2] - 2025-01-28

### ✨ 新增功能
- 新功能A
- 新功能B

### 🐛 Bug修复
- 修复了问题X
- 修复了问题Y

### 🔧 改进
- 性能优化
- 代码重构

---

## [1.0.1] - 2025-01-27

### 🎉 首次发布
- 完整的AI智能体平台
- OpenManus集成
- 高级UI组件系统
```

### README.md 更新
- 更新版本徽章
- 更新功能列表
- 更新安装说明

## 🔄 版本回滚

### 回滚到特定版本
```bash
# 查看提交历史
git log --oneline

# 回滚到特定提交
git reset --hard <commit-hash>

# 强制推送（谨慎使用）
git push --force origin main
```

### 创建回滚标签
```bash
# 创建回滚版本标签
git tag -a v1.0.1-rollback -m "Rollback to v1.0.1"

# 推送回滚标签
git push origin v1.0.1-rollback
```

## 📊 版本统计和监控

### 查看版本信息
```bash
# 查看所有标签
git tag -l

# 查看标签详细信息
git show v1.0.1

# 查看标签创建时间
git for-each-ref --format='%(refname:short) %(creatordate)' refs/tags
```

### 版本比较
```bash
# 比较两个版本
git diff v1.0.1 v1.0.2

# 查看版本间的提交
git log v1.0.1..v1.0.2 --oneline
```

## 🚨 注意事项

### 安全提醒
1. **不要强制推送主分支**：除非绝对必要
2. **备份重要数据**：发布前备份数据库和配置
3. **测试新版本**：在发布分支上充分测试
4. **文档同步**：确保文档与代码版本一致

### 最佳实践
1. **使用发布分支**：避免直接在main分支上开发
2. **语义化版本**：遵循版本号规范
3. **自动化流程**：使用提供的脚本简化操作
4. **及时沟通**：向团队和用户通知版本变更

## 📞 获取帮助

### 常见问题
- **Q**: 如何回滚到旧版本？
- **A**: 使用 `git checkout v1.0.1` 或下载ZIP文件

- **Q**: 旧版本还能下载吗？
- **A**: 是的，所有版本都可以通过Git标签或GitHub Releases下载

- **Q**: 如何管理多个版本？
- **A**: 使用Git标签和分支管理，每个版本都有独立的标签

### 技术支持
- 查看 [GitHub Issues](https://github.com/Meteorkid/Imagent-X-manus/issues)
- 参与 [GitHub Discussions](https://github.com/Meteorkid/Imagent-X-manus/discussions)
- 阅读项目文档

---

**版本管理是项目成功的关键**，遵循本指南可以确保版本发布的顺利进行和旧版本的可访问性。
