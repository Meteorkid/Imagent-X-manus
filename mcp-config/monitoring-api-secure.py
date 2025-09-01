#!/usr/bin/env python3
"""
ImagentX 监控API服务 (带认证)
提供监控数据的REST API接口
"""

import os
import json
import requests
from flask import Flask, jsonify, request, Response
from functools import wraps
from prometheus_client import generate_latest, CONTENT_TYPE_LATEST

app = Flask(__name__)

# 配置
PROMETHEUS_URL = os.getenv('PROMETHEUS_URL', 'http://localhost:9090')
ELASTICSEARCH_URL = os.getenv('ELASTICSEARCH_URL', 'http://localhost:9200')
GRAFANA_URL = os.getenv('GRAFANA_URL', 'http://localhost:3001')

# 认证配置
PROMETHEUS_USER = os.getenv('PROMETHEUS_USER', 'admin')
PROMETHEUS_PASS = os.getenv('PROMETHEUS_PASS', 'prometheus123')
ELASTICSEARCH_USER = os.getenv('ELASTICSEARCH_USER', 'elastic')
ELASTICSEARCH_PASS = os.getenv('ELASTICSEARCH_PASS', 'elastic123')
GRAFANA_USER = os.getenv('GRAFANA_USER', 'admin')
GRAFANA_PASS = os.getenv('GRAFANA_PASS', 'admin123')

# API认证
API_USERNAME = os.getenv('API_USERNAME', 'admin')
API_PASSWORD = os.getenv('API_PASSWORD', 'api123')

def check_auth(username, password):
    """检查API认证"""
    return username == API_USERNAME and password == API_PASSWORD

def authenticate():
    """认证装饰器"""
    def decorator(f):
        @wraps(f)
        def decorated_function(*args, **kwargs):
            auth = request.authorization
            if not auth or not check_auth(auth.username, auth.password):
                return Response(
                    'Could not verify your access level for that URL.\n'
                    'You have to login with proper credentials', 401,
                    {'WWW-Authenticate': 'Basic realm="Login Required"'})
            return f(*args, **kwargs)
        return decorated_function
    return decorator

@app.route('/health')
def health():
    """健康检查"""
    return jsonify({
        'status': 'healthy',
        'services': {
            'prometheus': check_service(f'{PROMETHEUS_URL}/-/healthy', PROMETHEUS_USER, PROMETHEUS_PASS),
            'elasticsearch': check_service(f'{ELASTICSEARCH_URL}/_cluster/health', ELASTICSEARCH_USER, ELASTICSEARCH_PASS),
            'grafana': check_service(f'{GRAFANA_URL}/api/health', GRAFANA_USER, GRAFANA_PASS)
        }
    })

@app.route('/metrics')
def metrics():
    """Prometheus指标"""
    return generate_latest(), 200, {'Content-Type': CONTENT_TYPE_LATEST}

@app.route('/api/security/scores')
@authenticate()
def get_security_scores():
    """获取安全评分"""
    try:
        response = requests.get(f'{PROMETHEUS_URL}/api/v1/query', 
                              params={'query': 'sandbox_security_score'},
                              auth=(PROMETHEUS_USER, PROMETHEUS_PASS))
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
@authenticate()
def get_security_violations():
    """获取安全违规统计"""
    try:
        response = requests.get(f'{PROMETHEUS_URL}/api/v1/query', 
                              params={'query': 'sandbox_security_violations_total'},
                              auth=(PROMETHEUS_USER, PROMETHEUS_PASS))
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
@authenticate()
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
                               json=search_body,
                               auth=(ELASTICSEARCH_USER, ELASTICSEARCH_PASS))
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
@authenticate()
def get_alerts():
    """获取告警信息"""
    try:
        response = requests.get(f'{PROMETHEUS_URL}/api/v1/alerts',
                              auth=(PROMETHEUS_USER, PROMETHEUS_PASS))
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

def check_service(url, username=None, password=None):
    """检查服务状态"""
    try:
        auth = (username, password) if username and password else None
        response = requests.get(url, timeout=5, auth=auth)
        return response.status_code == 200
    except:
        return False

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=False)
