#!/usr/bin/env python3
"""
ImagentX MCP 任务调度器
负责自动化运维任务调度
"""

import os
import time
import schedule
import requests
import logging
from datetime import datetime
from prometheus_client import start_http_server, Counter, Gauge, Histogram

# 配置日志
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# Prometheus指标
TASK_EXECUTION_COUNTER = Counter('mcp_task_executions_total', 'Total task executions', ['task_name', 'status'])
SERVICE_HEALTH_GAUGE = Gauge('mcp_service_health', 'Service health status', ['service_name'])
TASK_DURATION_HISTOGRAM = Histogram('mcp_task_duration_seconds', 'Task execution duration', ['task_name'])

class MCPScheduler:
    """MCP任务调度器"""
    
    def __init__(self):
        self.prometheus_url = os.getenv('PROMETHEUS_URL', 'http://prometheus:9090')
        self.grafana_url = os.getenv('GRAFANA_URL', 'http://grafana:3000')
        self.mcp_gateway_url = os.getenv('MCP_GATEWAY_URL', 'http://mcp-gateway:8080')
        self.api_key = os.getenv('MCP_GATEWAY_API_KEY', 'imagentx-mcp-key-2024')
        
        # 服务健康检查配置
        self.services = {
            'imagentx-app': 'http://imagentx:3000',
            'imagentx-api': 'http://imagentx:8088/api/health',
            'postgres': 'http://postgres:5432',
            'rabbitmq': 'http://rabbitmq:15672',
            'prometheus': f'{self.prometheus_url}/-/healthy',
            'grafana': f'{self.grafana_url}/api/health'
        }
    
    def health_check(self):
        """健康检查任务"""
        logger.info("执行健康检查任务")
        
        for service_name, url in self.services.items():
            try:
                start_time = time.time()
                response = requests.get(url, timeout=10)
                duration = time.time() - start_time
                
                if response.status_code == 200:
                    SERVICE_HEALTH_GAUGE.labels(service_name=service_name).set(1)
                    logger.info(f"✅ {service_name} 健康检查通过")
                else:
                    SERVICE_HEALTH_GAUGE.labels(service_name=service_name).set(0)
                    logger.warning(f"⚠️ {service_name} 健康检查失败: {response.status_code}")
                
                TASK_DURATION_HISTOGRAM.labels(task_name='health_check').observe(duration)
                TASK_EXECUTION_COUNTER.labels(task_name='health_check', status='success').inc()
                
            except Exception as e:
                SERVICE_HEALTH_GAUGE.labels(service_name=service_name).set(0)
                logger.error(f"❌ {service_name} 健康检查异常: {str(e)}")
                TASK_EXECUTION_COUNTER.labels(task_name='health_check', status='error').inc()
    
    def metrics_collection(self):
        """指标收集任务"""
        logger.info("执行指标收集任务")
        
        try:
            # 收集Prometheus指标
            response = requests.get(f'{self.prometheus_url}/api/v1/query', 
                                  params={'query': 'up'}, timeout=10)
            
            if response.status_code == 200:
                data = response.json()
                logger.info(f"✅ 收集到 {len(data.get('data', {}).get('result', []))} 个指标")
                TASK_EXECUTION_COUNTER.labels(task_name='metrics_collection', status='success').inc()
            else:
                logger.warning(f"⚠️ 指标收集失败: {response.status_code}")
                TASK_EXECUTION_COUNTER.labels(task_name='metrics_collection', status='error').inc()
                
        except Exception as e:
            logger.error(f"❌ 指标收集异常: {str(e)}")
            TASK_EXECUTION_COUNTER.labels(task_name='metrics_collection', status='error').inc()
    
    def backup_cleanup(self):
        """备份清理任务"""
        logger.info("执行备份清理任务")
        
        try:
            # 清理超过7天的备份文件
            backup_dir = '/app/storage/backups'
            if os.path.exists(backup_dir):
                current_time = time.time()
                for filename in os.listdir(backup_dir):
                    filepath = os.path.join(backup_dir, filename)
                    if os.path.isfile(filepath):
                        file_age = current_time - os.path.getmtime(filepath)
                        if file_age > 7 * 24 * 3600:  # 7天
                            os.remove(filepath)
                            logger.info(f"🗑️ 删除过期备份: {filename}")
            
            TASK_EXECUTION_COUNTER.labels(task_name='backup_cleanup', status='success').inc()
            
        except Exception as e:
            logger.error(f"❌ 备份清理异常: {str(e)}")
            TASK_EXECUTION_COUNTER.labels(task_name='backup_cleanup', status='error').inc()
    
    def mcp_gateway_health(self):
        """MCP网关健康检查"""
        logger.info("执行MCP网关健康检查")
        
        try:
            headers = {'Authorization': f'Bearer {self.api_key}'}
            response = requests.get(f'{self.mcp_gateway_url}/health', 
                                  headers=headers, timeout=10)
            
            if response.status_code == 200:
                logger.info("✅ MCP网关健康检查通过")
                TASK_EXECUTION_COUNTER.labels(task_name='mcp_gateway_health', status='success').inc()
            else:
                logger.warning(f"⚠️ MCP网关健康检查失败: {response.status_code}")
                TASK_EXECUTION_COUNTER.labels(task_name='mcp_gateway_health', status='error').inc()
                
        except Exception as e:
            logger.error(f"❌ MCP网关健康检查异常: {str(e)}")
            TASK_EXECUTION_COUNTER.labels(task_name='mcp_gateway_health', status='error').inc()
    
    def setup_schedule(self):
        """设置任务调度"""
        # 每5分钟执行健康检查
        schedule.every(5).minutes.do(self.health_check)
        
        # 每10分钟收集指标
        schedule.every(10).minutes.do(self.metrics_collection)
        
        # 每天凌晨2点执行备份清理
        schedule.every().day.at("02:00").do(self.backup_cleanup)
        
        # 每30分钟检查MCP网关
        schedule.every(30).minutes.do(self.mcp_gateway_health)
        
        logger.info("📅 任务调度已设置")
    
    def run(self):
        """运行调度器"""
        logger.info("🚀 MCP任务调度器启动")
        
        # 启动Prometheus指标服务器
        start_http_server(8000)
        logger.info("📊 Prometheus指标服务器启动在端口8000")
        
        # 设置任务调度
        self.setup_schedule()
        
        # 立即执行一次健康检查
        self.health_check()
        
        # 运行调度循环
        while True:
            schedule.run_pending()
            time.sleep(60)  # 每分钟检查一次

if __name__ == '__main__':
    scheduler = MCPScheduler()
    scheduler.run()
