# ImagentX 项目结构

## 📁 目录结构

```
ImagentX-master/
├── 📁 apps/                          # 应用程序目录
│   ├── backend/                      # 后端应用
│   └── frontend/                     # 前端应用
│
├── 📁 scripts/                       # 脚本管理
│   ├── core/                         # 核心脚本
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
│   ├── docker/                       # Docker部署
│   ├── kubernetes/                   # K8s部署
│   └── cloud/                        # 云部署
│
├── 📁 tools/                         # 工具和实用程序
│   ├── mcp-gateway/                  # MCP网关工具
│   ├── monitoring/                   # 监控工具
│   └── testing/                      # 测试工具
│
├── 📁 reports/                       # 报告和审计
│   ├── audit/                        # 审计报告
│   ├── performance/                  # 性能报告
│   └── testing/                      # 测试报告
│
├── 📁 resources/                     # 资源文件
│   ├── api-collections/              # API集合
│   ├── images/                       # 图片资源
│   └── templates/                    # 模板文件
│
└── 📁 temp/                          # 临时文件
    ├── logs/                         # 日志文件
    ├── pids/                         # 进程ID文件
    └── cache/                        # 缓存文件
```

## 🚀 快速开始

### 启动服务
```bash
./scripts/core/start.sh --core
```

### 停止服务
```bash
./scripts/core/stop.sh
```

### 检查状态
```bash
./scripts/core/status.sh
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
