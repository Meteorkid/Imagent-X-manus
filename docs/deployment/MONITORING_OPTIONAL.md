# 可观测性栈（可选）

仓库根目录下的 **`mcp-config/`**（Grafana、Prometheus、Kibana 等）为**可选**组件，用于自建监控与日志分析。

## 最小运行集

日常开发与联调通常只需：

- **后端**：`apps/backend`（默认 `context-path: /api`）
- **前端**：`apps/frontend`
- **数据库**：PostgreSQL（及业务所需中间件，见各环境 `docker-compose`）

上述组合**不依赖** `mcp-config/` 即可启动核心功能。

## 何时启用 mcp-config

在需要统一仪表盘、指标抓取或日志聚合时，再根据运维环境将 `mcp-config` 中配置并入你的 Compose / K8s，并与后端 `actuator`、日志采集端点对接。

## 与默认 Compose 的关系

若根目录提供的 `docker-compose` 未包含 Prometheus/Grafana/Kibana 服务，属于预期行为：它们作为**增强项**单独启用即可，避免本地一键拉起过重依赖。
