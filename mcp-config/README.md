# 🚀 ImagentX MCP 系统

基于成熟工具和框架构建的企业级MCP（Model Context Protocol）系统，为ImagentX项目提供完整的监控、管理和自动化运维能力。

## 📊 系统架构

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   ImagentX      │    │   Prometheus    │    │     Grafana     │
│   应用服务      │◄──►│    监控系统      │◄──►│   可视化面板    │
│  (前端+后端)    │    │   (指标收集)     │    │   (数据展示)    │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   MCP网关       │    │   MCP调度器     │    │   MCP配置中心   │
│  (服务管理)     │    │  (任务调度)     │    │  (配置管理)     │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## 🎯 核心功能

### 1. 监控系统
- **Prometheus**: 指标收集和存储
- **Grafana**: 数据可视化和告警
- **健康检查**: 自动服务状态监控

### 2. 自动化运维
- **任务调度**: 定时健康检查、备份清理
- **配置管理**: 统一配置中心
- **服务管理**: MCP网关统一管理

### 3. 可视化面板
- **实时监控**: 服务状态、性能指标
- **告警管理**: 异常情况自动告警
- **运维面板**: 一键操作界面

## 🚀 快速启动

### 1. 启动完整MCP系统
```bash
chmod +x mcp-config/start-mcp.sh
./mcp-config/start-mcp.sh
```

### 2. 手动启动
```bash
# 创建配置目录
mkdir -p mcp-config/grafana/provisioning/{datasources,dashboards}
mkdir -p mcp-config/configs
mkdir -p mcp-config/scheduler

# 启动服务
docker-compose -f mcp-config/docker-compose.mcp.yml up -d
```

## 📊 服务访问

| 服务 | 地址 | 用户名/密码 | 说明 |
|------|------|-------------|------|
| ImagentX前端 | http://localhost:3000 | - | 主应用界面 |
| ImagentX后端 | http://localhost:8088 | - | API服务 |
| Prometheus | http://localhost:9090 | - | 监控系统 |
| Grafana | http://localhost:3001 | admin/admin123 | 可视化面板 |
| MCP网关 | http://localhost:8080 | imagentx-mcp-key-2024 | 服务管理 |
| MCP配置中心 | http://localhost:8082 | - | 配置管理 |
| RabbitMQ管理 | http://localhost:15672 | guest/guest | 消息队列管理 |

## 🔧 管理命令

### 查看服务状态
```bash
docker-compose -f mcp-config/docker-compose.mcp.yml ps
```

### 查看日志
```bash
# 查看所有服务日志
docker-compose -f mcp-config/docker-compose.mcp.yml logs -f

# 查看特定服务日志
docker-compose -f mcp-config/docker-compose.mcp.yml logs -f prometheus
```

### 重启服务
```bash
# 重启所有服务
docker-compose -f mcp-config/docker-compose.mcp.yml restart

# 重启特定服务
docker-compose -f mcp-config/docker-compose.mcp.yml restart grafana
```

### 停止服务
```bash
docker-compose -f mcp-config/docker-compose.mcp.yml down
```

## 📈 监控指标

### 应用指标
- 服务响应时间
- 请求成功率
- 错误率统计
- 资源使用情况

### 系统指标
- CPU使用率
- 内存使用率
- 磁盘使用率
- 网络流量

### 业务指标
- 用户活跃度
- API调用次数
- 数据库连接数
- 消息队列状态

## 🔄 自动化任务

### 定时任务
- **每5分钟**: 服务健康检查
- **每10分钟**: 指标数据收集
- **每30分钟**: MCP网关检查
- **每天凌晨2点**: 备份文件清理

### 告警规则
- 服务不可用告警
- 性能指标阈值告警
- 资源使用率告警
- 错误率异常告警

## 🛠️ 自定义配置

### Prometheus配置
编辑 `mcp-config/prometheus.yml` 文件：
```yaml
scrape_configs:
  - job_name: 'custom-service'
    static_configs:
      - targets: ['your-service:port']
```

### Grafana仪表板
1. 访问 http://localhost:3001
2. 登录: admin/admin123
3. 创建新的仪表板
4. 添加Prometheus数据源

### 任务调度器
编辑 `mcp-config/scheduler/scheduler.py` 文件：
```python
# 添加自定义任务
def custom_task():
    logger.info("执行自定义任务")

# 设置调度
schedule.every().hour.do(custom_task)
```

## 🔒 安全配置

### API密钥管理
- MCP网关API密钥: `imagentx-mcp-key-2024`
- Grafana管理员密码: `admin123`
- RabbitMQ默认密码: `guest`

### 网络安全
- 所有服务运行在独立网络 `mcp-network`
- 仅暴露必要的端口
- 内部服务间通信加密

## 📝 故障排除

### 常见问题

1. **服务启动失败**
   ```bash
   # 检查端口占用
   lsof -i :3000,8088,9090,3001,8080
   
   # 查看详细日志
   docker-compose -f mcp-config/docker-compose.mcp.yml logs
   ```

2. **监控数据不显示**
   - 检查Prometheus配置
   - 验证服务端点可访问性
   - 查看Grafana数据源配置

3. **任务调度器异常**
   ```bash
   # 查看调度器日志
   docker logs mcp-scheduler
   
   # 重启调度器
   docker-compose -f mcp-config/docker-compose.mcp.yml restart mcp-scheduler
   ```

### 日志位置
- 应用日志: `docker logs imagentx-app`
- 监控日志: `docker logs mcp-prometheus`
- 调度器日志: `docker logs mcp-scheduler`

## 🎉 总结

这个MCP系统为ImagentX项目提供了：

✅ **完整的监控能力**: Prometheus + Grafana  
✅ **自动化运维**: 任务调度 + 健康检查  
✅ **统一管理**: MCP网关 + 配置中心  
✅ **可视化界面**: 实时监控 + 告警管理  
✅ **低成本部署**: 基于成熟开源工具  

**投入产出比高**: 使用成熟工具，开发成本低，运维效率显著提升！
