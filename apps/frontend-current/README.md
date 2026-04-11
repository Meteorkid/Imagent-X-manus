# 已废弃（Deprecated）

本目录为历史快照/实验副本，**不再作为 CI、Docker 或日常开发入口**。

## 唯一主前端

请仅使用并维护：

- **`apps/frontend`** — 官方 Next.js 应用（`imagentx-frontend`）

根目录与 CI 中的 `npm run build` / `npm test` 均指向 `apps/frontend`。请勿在本目录新增功能；若需合并差异，请把变更迁回 `apps/frontend` 后删除本目录中的重复实现。
