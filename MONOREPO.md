# 仓库布局说明（Monorepo）

## 应用入口

| 路径 | 说明 |
|------|------|
| **`apps/frontend`** | **唯一主前端**：Next.js，CI（`npm ci` / `npm test` / `npm run build`）、Docker 镜像均以此为准。 |
| `apps/frontend-current` | **已废弃**，历史副本；请勿新增代码，见目录内 `README.md`。 |
| `apps/backend` | Spring Boot API（`context-path: /api`）。 |

根目录 `package.json` 提供便捷脚本（通过 `npm --prefix apps/frontend` 调用），无需在仓库根安装前端依赖即可从根目录运行测试/构建。

前端已将 `date-fns` 对齐为 `3.x`（与 `react-day-picker@8` 兼容），`npm ci` 可直接安装，不再依赖 `legacy-peer-deps`。

## 历史目录名

文档或旧脚本中可能出现的 `imagentx-frontend-plus` 指迁移前的目录名，现已统一为 **`apps/frontend`**。`local-enhancement/` 为可选本地增强脚本生成目录，与主应用解耦。
