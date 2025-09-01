#!/usr/bin/env python3
"""
ImagentX 沙箱安全监控服务
实时监控容器安全状态，检测异常行为
"""

import os
import time
import json
import logging
import requests
import subprocess
from datetime import datetime
from prometheus_client import start_http_server, Counter, Gauge, Histogram
from threading import Thread, Lock

# 配置日志
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# Prometheus指标
SECURITY_VIOLATIONS = Counter('sandbox_security_violations_total', 'Total security violations', ['container_name', 'violation_type'])
ANOMALY_DETECTIONS = Counter('sandbox_anomaly_detections_total', 'Total anomaly detections', ['container_name', 'anomaly_type'])
CONTAINER_HEALTH = Gauge('sandbox_container_health', 'Container health status', ['container_name'])
RESOURCE_USAGE = Gauge('sandbox_resource_usage', 'Resource usage metrics', ['container_name', 'resource_type'])
SECURITY_SCORE = Gauge('sandbox_security_score', 'Container security score', ['container_name'])

class SandboxSecurityMonitor:
    """沙箱安全监控器"""
    
    def __init__(self):
        self.docker_host = os.getenv('DOCKER_HOST', 'unix:///var/run/docker.sock')
        self.monitoring_interval = int(os.getenv('MONITORING_INTERVAL', '30'))
        self.containers = {}
        self.lock = Lock()
        
        # 安全规则配置
        self.security_rules = {
            'memory_threshold': 80,  # 内存使用率阈值
            'cpu_threshold': 90,     # CPU使用率阈值
            'network_threshold': 100, # 网络连接数阈值
            'process_threshold': 40,  # 进程数阈值
            'file_write_threshold': 1073741824,  # 文件写入阈值 (1GB)
            'privilege_escalation_keywords': [
                'sudo', 'su', 'chmod 777', 'chown root', 'setuid', 'setgid'
            ],
            'suspicious_commands': [
                'rm -rf /', 'dd if=/dev/zero', 'fork bomb', 'curl -s http://'
            ]
        }
    
    def get_container_stats(self, container_id):
        """获取容器统计信息"""
        try:
            cmd = f"docker stats {container_id} --no-stream --format json"
            result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
            
            if result.returncode == 0:
                stats = json.loads(result.stdout.strip())
                return stats
            else:
                logger.warning(f"获取容器 {container_id} 统计信息失败: {result.stderr}")
                return None
                
        except Exception as e:
            logger.error(f"获取容器统计信息异常: {str(e)}")
            return None
    
    def check_container_logs(self, container_id):
        """检查容器日志中的安全事件"""
        try:
            cmd = f"docker logs {container_id} --since 5m 2>&1"
            result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
            
            if result.returncode == 0:
                logs = result.stdout
                
                # 检查特权提升
                for keyword in self.security_rules['privilege_escalation_keywords']:
                    if keyword in logs:
                        SECURITY_VIOLATIONS.labels(container_name=container_id, violation_type='privilege_escalation').inc()
                        logger.warning(f"检测到特权提升尝试: {container_id} - {keyword}")
                
                # 检查可疑命令
                for command in self.security_rules['suspicious_commands']:
                    if command in logs:
                        SECURITY_VIOLATIONS.labels(container_name=container_id, violation_type='suspicious_command').inc()
                        logger.warning(f"检测到可疑命令: {container_id} - {command}")
                
                return logs
            else:
                logger.warning(f"获取容器 {container_id} 日志失败: {result.stderr}")
                return None
                
        except Exception as e:
            logger.error(f"检查容器日志异常: {str(e)}")
            return None
    
    def check_container_processes(self, container_id):
        """检查容器进程"""
        try:
            cmd = f"docker exec {container_id} ps aux 2>/dev/null || echo 'Process check failed'"
            result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
            
            if result.returncode == 0:
                processes = result.stdout
                process_count = len([line for line in processes.split('\n') if line.strip() and not line.startswith('USER')])
                
                # 检查进程数
                if process_count > self.security_rules['process_threshold']:
                    ANOMALY_DETECTIONS.labels(container_name=container_id, anomaly_type='high_process_count').inc()
                    logger.warning(f"容器进程数过多: {container_id} - {process_count}")
                
                return process_count
            else:
                logger.warning(f"检查容器进程失败: {container_id}")
                return 0
                
        except Exception as e:
            logger.error(f"检查容器进程异常: {str(e)}")
            return 0
    
    def check_container_network(self, container_id):
        """检查容器网络活动"""
        try:
            cmd = f"docker exec {container_id} netstat -an 2>/dev/null || echo 'Network check failed'"
            result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
            
            if result.returncode == 0:
                connections = result.stdout
                connection_count = len([line for line in connections.split('\n') if 'ESTABLISHED' in line])
                
                # 检查网络连接数
                if connection_count > self.security_rules['network_threshold']:
                    ANOMALY_DETECTIONS.labels(container_name=container_id, anomaly_type='high_network_connections').inc()
                    logger.warning(f"容器网络连接数过多: {container_id} - {connection_count}")
                
                return connection_count
            else:
                logger.warning(f"检查容器网络失败: {container_id}")
                return 0
                
        except Exception as e:
            logger.error(f"检查容器网络异常: {str(e)}")
            return 0
    
    def calculate_security_score(self, container_id, stats, process_count, network_count):
        """计算容器安全评分"""
        score = 100
        
        try:
            # 内存使用率评分
            if stats and 'MemPerc' in stats:
                mem_percent = float(stats['MemPerc'].replace('%', ''))
                if mem_percent > self.security_rules['memory_threshold']:
                    score -= 20
                    logger.warning(f"内存使用率过高: {container_id} - {mem_percent}%")
            
            # CPU使用率评分
            if stats and 'CPUPerc' in stats:
                cpu_percent = float(stats['CPUPerc'].replace('%', ''))
                if cpu_percent > self.security_rules['cpu_threshold']:
                    score -= 20
                    logger.warning(f"CPU使用率过高: {container_id} - {cpu_percent}%")
            
            # 进程数评分
            if process_count > self.security_rules['process_threshold']:
                score -= 15
                logger.warning(f"进程数过多: {container_id} - {process_count}")
            
            # 网络连接数评分
            if network_count > self.security_rules['network_threshold']:
                score -= 15
                logger.warning(f"网络连接数过多: {container_id} - {network_count}")
            
            # 确保评分不低于0
            score = max(0, score)
            
            # 更新Prometheus指标
            SECURITY_SCORE.labels(container_name=container_id).set(score)
            
            return score
            
        except Exception as e:
            logger.error(f"计算安全评分异常: {str(e)}")
            return 50  # 默认评分
    
    def monitor_container(self, container_id):
        """监控单个容器"""
        try:
            # 获取容器统计信息
            stats = self.get_container_stats(container_id)
            
            # 检查容器日志
            self.check_container_logs(container_id)
            
            # 检查容器进程
            process_count = self.check_container_processes(container_id)
            
            # 检查容器网络
            network_count = self.check_container_network(container_id)
            
            # 计算安全评分
            security_score = self.calculate_security_score(container_id, stats, process_count, network_count)
            
            # 更新容器健康状态
            if security_score >= 80:
                CONTAINER_HEALTH.labels(container_name=container_id).set(1)
                logger.info(f"容器 {container_id} 健康状态良好，安全评分: {security_score}")
            else:
                CONTAINER_HEALTH.labels(container_name=container_id).set(0)
                logger.warning(f"容器 {container_id} 健康状态异常，安全评分: {security_score}")
            
            # 更新资源使用指标
            if stats:
                if 'MemPerc' in stats:
                    mem_percent = float(stats['MemPerc'].replace('%', ''))
                    RESOURCE_USAGE.labels(container_name=container_id, resource_type='memory').set(mem_percent)
                
                if 'CPUPerc' in stats:
                    cpu_percent = float(stats['CPUPerc'].replace('%', ''))
                    RESOURCE_USAGE.labels(container_name=container_id, resource_type='cpu').set(cpu_percent)
            
        except Exception as e:
            logger.error(f"监控容器 {container_id} 异常: {str(e)}")
    
    def get_sandbox_containers(self):
        """获取沙箱容器列表"""
        try:
            cmd = "docker ps --filter 'label=sandbox=true' --format '{{.ID}}'"
            result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
            
            if result.returncode == 0:
                containers = [line.strip() for line in result.stdout.split('\n') if line.strip()]
                return containers
            else:
                logger.warning("获取沙箱容器列表失败")
                return []
                
        except Exception as e:
            logger.error(f"获取沙箱容器列表异常: {str(e)}")
            return []
    
    def monitor_all_containers(self):
        """监控所有沙箱容器"""
        while True:
            try:
                # 获取沙箱容器列表
                containers = self.get_sandbox_containers()
                
                logger.info(f"监控 {len(containers)} 个沙箱容器")
                
                # 并发监控所有容器
                threads = []
                for container_id in containers:
                    thread = Thread(target=self.monitor_container, args=(container_id,))
                    thread.start()
                    threads.append(thread)
                
                # 等待所有监控线程完成
                for thread in threads:
                    thread.join()
                
                # 等待下次监控
                time.sleep(self.monitoring_interval)
                
            except Exception as e:
                logger.error(f"监控所有容器异常: {str(e)}")
                time.sleep(self.monitoring_interval)
    
    def run(self):
        """运行监控服务"""
        logger.info("🚀 沙箱安全监控服务启动")
        
        # 启动Prometheus指标服务器
        start_http_server(8001)
        logger.info("📊 Prometheus指标服务器启动在端口8001")
        
        # 启动容器监控
        self.monitor_all_containers()

if __name__ == '__main__':
    monitor = SandboxSecurityMonitor()
    monitor.run()
