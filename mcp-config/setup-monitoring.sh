#!/bin/bash

# ImagentX 监控和可视化系统配置脚本

set -e

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}📊 配置ImagentX监控和可视化系统...${NC}"

# 配置Prometheus告警规则
setup_prometheus_alerts() {
    echo -e "${BLUE}🔔 配置Prometheus告警规则...${NC}"
    
    # 创建告警配置文件
    cat > mcp-config/prometheus/alerts.yml << 'EOF'
global:
  resolve_timeout: 5m

route:
  group_by: ['alertname']
  group_wait: 10s
  group_interval: 10s
  repeat_interval: 1h
  receiver: 'web.hook'

receivers:
  - name: 'web.hook'
    webhook_configs:
      - url: 'http://localhost:5001/alert'
        send_resolved: true

inhibit_rules:
  - source_match:
      severity: 'critical'
    target_match:
      severity: 'warning'
    equal: ['alertname', 'dev', 'instance']
EOF
    
    echo -e "${GREEN}✅ Prometheus告警规则配置完成${NC}"
}

# 配置Grafana仪表板
setup_grafana_dashboards() {
    echo -e "${BLUE}📈 配置Grafana仪表板...${NC}"
    
    # 创建Grafana配置目录
    mkdir -p mcp-config/grafana/provisioning/{datasources,dashboards}
    
    # 配置数据源
    cat > mcp-config/grafana/provisioning/datasources/prometheus.yml << 'EOF'
apiVersion: 1

datasources:
  - name: Prometheus
    type: prometheus
    access: proxy
    url: http://prometheus:9090
    isDefault: true
    editable: true
    jsonData:
      timeInterval: "15s"
      queryTimeout: "60s"
      httpMethod: "POST"
    secureJsonData: {}
EOF
    
    # 配置仪表板
    cat > mcp-config/grafana/provisioning/dashboards/dashboard.yml << 'EOF'
apiVersion: 1

providers:
  - name: 'default'
    orgId: 1
    folder: ''
    type: file
    disableDeletion: false
    updateIntervalSeconds: 10
    allowUiUpdates: true
    options:
      path: /etc/grafana/provisioning/dashboards
EOF
    
    echo -e "${GREEN}✅ Grafana仪表板配置完成${NC}"
}

# 配置Elasticsearch索引模板
setup_elasticsearch_templates() {
    echo -e "${BLUE}📝 配置Elasticsearch索引模板...${NC}"
    
    # 创建索引模板
    cat > mcp-config/elasticsearch/sandbox-template.json << 'EOF'
{
  "index_patterns": ["sandbox-logs-*"],
  "settings": {
    "number_of_shards": 1,
    "number_of_replicas": 0,
    "index.refresh_interval": "5s"
  },
  "mappings": {
    "properties": {
      "@timestamp": {
        "type": "date"
      },
      "container_name": {
        "type": "keyword"
      },
      "log_type": {
        "type": "keyword"
      },
      "violation_type": {
        "type": "keyword"
      },
      "anomaly_type": {
        "type": "keyword"
      },
      "security_score": {
        "type": "float"
      },
      "resource_usage": {
        "properties": {
          "memory": {
            "type": "float"
          },
          "cpu": {
            "type": "float"
          }
        }
      },
      "network_connections": {
        "type": "integer"
      },
      "process_count": {
        "type": "integer"
      },
      "message": {
        "type": "text"
      }
    }
  }
}
EOF
    
    echo -e "${GREEN}✅ Elasticsearch索引模板配置完成${NC}"
}

# 配置Kibana索引模式
setup_kibana_index_patterns() {
    echo -e "${BLUE}🔍 配置Kibana索引模式...${NC}"
    
    mkdir -p mcp-config/kibana/index-patterns
    
    # 创建索引模式配置
    cat > mcp-config/kibana/index-patterns/sandbox-logs.json << 'EOF'
{
  "index_patterns": [
    {
      "title": "sandbox-logs-*",
      "timeFieldName": "@timestamp",
      "fields": [
        {
          "name": "@timestamp",
          "type": "date",
          "count": 0,
          "scripted": false,
          "searchable": true,
          "aggregatable": true,
          "readFromDocValues": true
        },
        {
          "name": "container_name",
          "type": "string",
          "count": 0,
          "scripted": false,
          "searchable": true,
          "aggregatable": true,
          "readFromDocValues": true
        },
        {
          "name": "log_type",
          "type": "string",
          "count": 0,
          "scripted": false,
          "searchable": true,
          "aggregatable": true,
          "readFromDocValues": true
        },
        {
          "name": "violation_type",
          "type": "string",
          "count": 0,
          "scripted": false,
          "searchable": true,
          "aggregatable": true,
          "readFromDocValues": true
        },
        {
          "name": "anomaly_type",
          "type": "string",
          "count": 0,
          "scripted": false,
          "searchable": true,
          "aggregatable": true,
          "readFromDocValues": true
        },
        {
          "name": "security_score",
          "type": "number",
          "count": 0,
          "scripted": false,
          "searchable": true,
          "aggregatable": true,
          "readFromDocValues": true
        }
      ]
    }
  ]
}
EOF
    
    echo -e "${GREEN}✅ Kibana索引模式配置完成${NC}"
}

# 创建监控API
create_monitoring_api() {
    echo -e "${BLUE}🔌 创建监控API...${NC}"
    
    cat > mcp-config/monitoring-api.py << 'EOF'
#!/usr/bin/env python3
"""
ImagentX 监控API服务
提供监控数据的REST API接口
"""

import os
import json
import requests
from flask import Flask, jsonify, request
from prometheus_client import generate_latest, CONTENT_TYPE_LATEST

app = Flask(__name__)

# 配置
PROMETHEUS_URL = os.getenv('PROMETHEUS_URL', 'http://localhost:9090')
ELASTICSEARCH_URL = os.getenv('ELASTICSEARCH_URL', 'http://localhost:9200')
GRAFANA_URL = os.getenv('GRAFANA_URL', 'http://localhost:3001')

@app.route('/health')
def health():
    """健康检查"""
    return jsonify({
        'status': 'healthy',
        'services': {
            'prometheus': check_service(f'{PROMETHEUS_URL}/-/healthy'),
            'elasticsearch': check_service(f'{ELASTICSEARCH_URL}/_cluster/health'),
            'grafana': check_service(f'{GRAFANA_URL}/api/health')
        }
    })

@app.route('/metrics')
def metrics():
    """Prometheus指标"""
    return generate_latest(), 200, {'Content-Type': CONTENT_TYPE_LATEST}

@app.route('/api/security/scores')
def get_security_scores():
    """获取安全评分"""
    try:
        response = requests.get(f'{PROMETHEUS_URL}/api/v1/query', 
                              params={'query': 'sandbox_security_score'})
        if response.status_code == 200:
            data = response.json()
            return jsonify({
                'success': True,
                'data': data.get('data', {}).get('result', [])
            })
        else:
            return jsonify({'success': False, 'error': 'Failed to fetch data'}), 500
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500

@app.route('/api/security/violations')
def get_security_violations():
    """获取安全违规统计"""
    try:
        response = requests.get(f'{PROMETHEUS_URL}/api/v1/query', 
                              params={'query': 'sandbox_security_violations_total'})
        if response.status_code == 200:
            data = response.json()
            return jsonify({
                'success': True,
                'data': data.get('data', {}).get('result', [])
            })
        else:
            return jsonify({'success': False, 'error': 'Failed to fetch data'}), 500
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500

@app.route('/api/logs/search')
def search_logs():
    """搜索日志"""
    try:
        query = request.args.get('q', '*')
        size = request.args.get('size', '100')
        
        search_body = {
            "query": {
                "query_string": {
                    "query": query
                }
            },
            "size": int(size),
            "sort": [{"@timestamp": {"order": "desc"}}]
        }
        
        response = requests.post(f'{ELASTICSEARCH_URL}/sandbox-logs-*/_search', 
                               json=search_body)
        if response.status_code == 200:
            data = response.json()
            return jsonify({
                'success': True,
                'data': data.get('hits', {})
            })
        else:
            return jsonify({'success': False, 'error': 'Failed to search logs'}), 500
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500

@app.route('/api/alerts')
def get_alerts():
    """获取告警信息"""
    try:
        response = requests.get(f'{PROMETHEUS_URL}/api/v1/alerts')
        if response.status_code == 200:
            data = response.json()
            return jsonify({
                'success': True,
                'data': data.get('data', {}).get('alerts', [])
            })
        else:
            return jsonify({'success': False, 'error': 'Failed to fetch alerts'}), 500
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500

def check_service(url):
    """检查服务状态"""
    try:
        response = requests.get(url, timeout=5)
        return response.status_code == 200
    except:
        return False

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=False)
EOF
    
    chmod +x mcp-config/monitoring-api.py
    
    echo -e "${GREEN}✅ 监控API创建完成${NC}"
}

# 创建监控仪表板HTML
create_monitoring_dashboard() {
    echo -e "${BLUE}🌐 创建监控仪表板HTML...${NC}"
    
    cat > mcp-config/monitoring-dashboard.html << 'EOF'
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ImagentX 监控仪表板</title>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            margin: 0;
            padding: 20px;
            background: #f5f5f5;
        }
        .container {
            max-width: 1200px;
            margin: 0 auto;
        }
        .header {
            text-align: center;
            margin-bottom: 30px;
        }
        .header h1 {
            color: #333;
            margin: 0;
        }
        .grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }
        .card {
            background: white;
            border-radius: 8px;
            padding: 20px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        .card h3 {
            margin-top: 0;
            color: #555;
        }
        .metric {
            font-size: 2em;
            font-weight: bold;
            color: #007bff;
        }
        .status {
            padding: 5px 10px;
            border-radius: 4px;
            font-size: 0.9em;
        }
        .status.healthy { background: #d4edda; color: #155724; }
        .status.warning { background: #fff3cd; color: #856404; }
        .status.critical { background: #f8d7da; color: #721c24; }
        .chart-container {
            position: relative;
            height: 300px;
            margin-top: 20px;
        }
        .refresh-btn {
            background: #007bff;
            color: white;
            border: none;
            padding: 10px 20px;
            border-radius: 4px;
            cursor: pointer;
            margin-bottom: 20px;
        }
        .refresh-btn:hover {
            background: #0056b3;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🛡️ ImagentX 沙箱监控仪表板</h1>
            <p>实时监控沙箱安全状态和系统性能</p>
        </div>
        
        <button class="refresh-btn" onclick="refreshData()">🔄 刷新数据</button>
        
        <div class="grid">
            <div class="card">
                <h3>系统健康状态</h3>
                <div id="health-status">加载中...</div>
            </div>
            
            <div class="card">
                <h3>容器安全评分</h3>
                <div id="security-score">加载中...</div>
            </div>
            
            <div class="card">
                <h3>安全违规统计</h3>
                <div id="violations-count">加载中...</div>
            </div>
            
            <div class="card">
                <h3>异常行为检测</h3>
                <div id="anomalies-count">加载中...</div>
            </div>
        </div>
        
        <div class="grid">
            <div class="card">
                <h3>安全评分趋势</h3>
                <div class="chart-container">
                    <canvas id="securityChart"></canvas>
                </div>
            </div>
            
            <div class="card">
                <h3>资源使用率</h3>
                <div class="chart-container">
                    <canvas id="resourceChart"></canvas>
                </div>
            </div>
        </div>
        
        <div class="card">
            <h3>最近告警</h3>
            <div id="alerts-list">加载中...</div>
        </div>
    </div>

    <script>
        let securityChart, resourceChart;
        
        // 初始化图表
        function initCharts() {
            const securityCtx = document.getElementById('securityChart').getContext('2d');
            securityChart = new Chart(securityCtx, {
                type: 'line',
                data: {
                    labels: [],
                    datasets: [{
                        label: '安全评分',
                        data: [],
                        borderColor: '#007bff',
                        tension: 0.1
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    scales: {
                        y: {
                            beginAtZero: true,
                            max: 100
                        }
                    }
                }
            });
            
            const resourceCtx = document.getElementById('resourceChart').getContext('2d');
            resourceChart = new Chart(resourceCtx, {
                type: 'bar',
                data: {
                    labels: ['内存使用率', 'CPU使用率'],
                    datasets: [{
                        label: '使用率 (%)',
                        data: [0, 0],
                        backgroundColor: ['#28a745', '#ffc107']
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    scales: {
                        y: {
                            beginAtZero: true,
                            max: 100
                        }
                    }
                }
            });
        }
        
        // 刷新数据
        async function refreshData() {
            try {
                // 获取健康状态
                const healthResponse = await fetch('/api/health');
                const healthData = await healthResponse.json();
                updateHealthStatus(healthData);
                
                // 获取安全评分
                const scoreResponse = await fetch('/api/security/scores');
                const scoreData = await scoreResponse.json();
                updateSecurityScore(scoreData);
                
                // 获取违规统计
                const violationsResponse = await fetch('/api/security/violations');
                const violationsData = await violationsResponse.json();
                updateViolationsCount(violationsData);
                
                // 获取告警信息
                const alertsResponse = await fetch('/api/alerts');
                const alertsData = await alertsResponse.json();
                updateAlertsList(alertsData);
                
            } catch (error) {
                console.error('刷新数据失败:', error);
            }
        }
        
        // 更新健康状态
        function updateHealthStatus(data) {
            const healthDiv = document.getElementById('health-status');
            if (data.status === 'healthy') {
                healthDiv.innerHTML = '<div class="status healthy">✅ 系统健康</div>';
            } else {
                healthDiv.innerHTML = '<div class="status critical">❌ 系统异常</div>';
            }
        }
        
        // 更新安全评分
        function updateSecurityScore(data) {
            const scoreDiv = document.getElementById('security-score');
            if (data.success && data.data.length > 0) {
                const score = data.data[0].value[1];
                scoreDiv.innerHTML = `<div class="metric">${score}</div>`;
                
                // 更新图表
                const now = new Date().toLocaleTimeString();
                securityChart.data.labels.push(now);
                securityChart.data.datasets[0].data.push(parseFloat(score));
                
                if (securityChart.data.labels.length > 20) {
                    securityChart.data.labels.shift();
                    securityChart.data.datasets[0].data.shift();
                }
                
                securityChart.update();
            } else {
                scoreDiv.innerHTML = '<div class="status warning">暂无数据</div>';
            }
        }
        
        // 更新违规统计
        function updateViolationsCount(data) {
            const violationsDiv = document.getElementById('violations-count');
            if (data.success && data.data.length > 0) {
                const total = data.data.reduce((sum, item) => sum + parseFloat(item.value[1]), 0);
                violationsDiv.innerHTML = `<div class="metric">${total}</div>`;
            } else {
                violationsDiv.innerHTML = '<div class="status healthy">0</div>';
            }
        }
        
        // 更新告警列表
        function updateAlertsList(data) {
            const alertsDiv = document.getElementById('alerts-list');
            if (data.success && data.data.length > 0) {
                const alertsHtml = data.data.map(alert => `
                    <div class="status ${alert.labels.severity}">
                        ${alert.labels.alertname}: ${alert.annotations.description || '无描述'}
                    </div>
                `).join('');
                alertsDiv.innerHTML = alertsHtml;
            } else {
                alertsDiv.innerHTML = '<div class="status healthy">暂无告警</div>';
            }
        }
        
        // 页面加载完成后初始化
        document.addEventListener('DOMContentLoaded', function() {
            initCharts();
            refreshData();
            
            // 每30秒自动刷新
            setInterval(refreshData, 30000);
        });
    </script>
</body>
</html>
EOF
    
    echo -e "${GREEN}✅ 监控仪表板HTML创建完成${NC}"
}

# 显示监控信息
show_monitoring_info() {
    echo -e "\n${BLUE}📊 监控和可视化系统信息:${NC}"
    echo -e "${GREEN}• Prometheus监控: http://localhost:9090${NC}"
    echo -e "${GREEN}• Grafana可视化: http://localhost:3001 (admin/admin123)${NC}"
    echo -e "${GREEN}• Elasticsearch: http://localhost:9200${NC}"
    echo -e "${GREEN}• Kibana日志分析: http://localhost:5601${NC}"
    echo -e "${GREEN}• 监控API: http://localhost:5000${NC}"
    echo -e "${GREEN}• 监控仪表板: http://localhost:5000/dashboard${NC}"
}

# 主函数
main() {
    echo -e "${BLUE}===== ImagentX 监控和可视化系统配置 =====${NC}"
    
    setup_prometheus_alerts
    setup_grafana_dashboards
    setup_elasticsearch_templates
    setup_kibana_index_patterns
    create_monitoring_api
    create_monitoring_dashboard
    show_monitoring_info
    
    echo -e "\n${GREEN}🎉 监控和可视化系统配置完成！${NC}"
    echo -e "${BLUE}📋 所有监控组件已准备就绪，可以开始收集和分析数据${NC}"
}

# 执行主函数
main "$@"
