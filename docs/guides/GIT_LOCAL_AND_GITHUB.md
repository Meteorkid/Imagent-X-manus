# Git 本地使用与上传到 GitHub（完整流程）

本文说明：**先在本地用 Git 提交**，再**推送到 GitHub** 的整套顺序；适用于本仓库（远程示例：`git@github.com:Meteorkid/Imagent-X-manus.git`）。

---

## 原则

- **上传（`git push`）之前，必须先在本地完成提交（`git add` + `git commit`）**；没有新提交，推上去也不会多出新内容。
- 日常顺序：**改文件 → 暂存 → 提交 →（必要时拉取）→ 推送**。

---

## 零、一次性准备（每台电脑只做一次或很少做）

### 1. 确认已安装 Git

```bash
git --version
```

### 2. 告诉 Git 你是谁（会写进提交记录）

```bash
git config --global user.name "你的名字或 GitHub 用户名"
git config --global user.email "你在 GitHub 上用的邮箱"
```

### 3. 把仓库弄到本机（二选一）

**还没有项目文件夹时——克隆远程：**

```bash
cd ~/github项目
git clone git@github.com:Meteorkid/Imagent-X-manus.git
cd Imagent-X-manus
```

**若本机已有项目目录**，且在其中执行 `git status` 正常，则**无需再 clone**，直接进入该目录即可，例如：

```bash
cd "/Users/meteor/github项目/Imagent X"
```

### 4. 确认远程与 SSH（推送用）

查看远程名称与地址：

```bash
git remote -v
```

应能看到 `origin` 与 `git@github.com:Meteorkid/Imagent-X-manus.git`（HTTPS 地址亦可，视你的配置而定）。

测试 SSH 登录 GitHub：

```bash
ssh -T git@github.com
```

成功时会出现类似：`Hi <用户名>! You've successfully authenticated...`。

---

## 一、本地 Git（日常核心：改代码 → 暂存 → 提交）

在项目**根目录**下操作，例如：

```bash
cd "/Users/meteor/github项目/Imagent X"
```

### 1. 查看状态

```bash
git status
```

- **红色**：有改动，尚未暂存  
- **绿色**：已暂存，待提交  
- **nothing to commit, working tree clean**：无待提交改动

### 2. 暂存（准备纳入本次提交）

全部改动：

```bash
git add -A
```

仅部分文件：

```bash
git add README.md apps/frontend/package.json
```

### 3. 提交（在本地打快照）

```bash
git commit -m "写一句说明，例如：更新登录页样式"
```

若提示 `nothing to commit`，说明没有可提交内容（或尚未 `git add`）。

### 4.（可选）查看最近提交

```bash
git log --oneline -5
```

---

## 二、上传到 GitHub（推送到远程）

### 1. 与远程对齐（协作或远程有新提交时建议先做）

```bash
git pull origin main
```

若存在冲突，按提示解决后再次 `git add` / `git commit`，再推送。

### 2. 推送到 `main` 分支

```bash
git push origin main
```

成功后，GitHub 网页上可见新提交，且会触发已配置的 CI（如 GitHub Actions）。

---

## 三、一页纸流程（速查）

```text
改文件
  → git status
  → git add -A（或指定文件）
  → git commit -m "说明"
  → git pull origin main（需要时）
  → git push origin main
```

**记忆：** 先有 **commit**，再 **push**。

---

## 四、发版：打标签并推送（可选）

在已修改版本号并完成一次正常 `commit` 之后：

```bash
git tag -a v1.0.4 -m "v1.0.4"
git push origin main
git push origin v1.0.4
```

标签可用于 GitHub Releases，以及触发「仅在推送标签时运行」的自动化任务。

---

## 五、常见问题


| 情况                              | 处理                                                                                      |
| ------------------------------- | --------------------------------------------------------------------------------------- |
| 想丢弃**未暂存**的某文件修改                | `git restore 文件名`                                                                       |
| 想取消**已暂存**、尚未提交                 | `git restore --staged 文件名`                                                              |
| `push` 被拒绝，提示先拉取                | 先 `git pull origin main`，处理冲突后再提交并推送                                                    |
| `Permission denied (publickey)` | 检查 SSH 公钥是否已添加到 GitHub，以及 `~/.ssh/config` 中 `Host github.com` 的 `IdentityFile` 是否指向正确私钥 |
| 使用 HTTPS 时要求输入密码                | 使用 GitHub **Personal Access Token** 作为密码（非账户登录密码），或改用 SSH                               |


---

## 六、概念对照


| 说法            | 含义                                                             |
| ------------- | -------------------------------------------------------------- |
| **本地 Git**    | 在本机执行 `git add`、`git commit`，历史只存在于你的电脑。                       |
| **上传 GitHub** | `git push`，把已有提交同步到远程仓库。                                       |
| **SSH 远程**    | 远程地址为 `git@github.com:用户名/仓库.git` 时，一般使用密钥认证，无需每次在命令行输入 Token。 |


---

*文档随仓库维护；若远程仓库名或默认分支有变更，请相应替换文中的 `origin`、`main` 与克隆地址。*