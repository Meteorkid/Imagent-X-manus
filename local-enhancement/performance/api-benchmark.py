#!/usr/bin/env python3
"""
API性能测试脚本
"""

import requests
import time
import statistics
from concurrent.futures import ThreadPoolExecutor
import json

class APIBenchmark:
    def __init__(self, base_url="http://localhost:8088/api"):
        self.base_url = base_url
        self.session = requests.Session()
    
    def test_health_check(self, iterations=100):
        """测试健康检查接口"""
        print(f"🏥 测试健康检查接口 ({iterations}次)...")
        
        times = []
        errors = 0
        
        for i in range(iterations):
            start_time = time.time()
            try:
                response = self.session.get(f"{self.base_url}/health")
                if response.status_code == 200:
                    times.append(time.time() - start_time)
                else:
                    errors += 1
            except Exception as e:
                errors += 1
                print(f"错误: {e}")
        
        self._print_results("健康检查", times, errors, iterations)
    
    def test_agent_list(self, iterations=50):
        """测试Agent列表接口"""
        print(f"🤖 测试Agent列表接口 ({iterations}次)...")
        
        times = []
        errors = 0
        
        for i in range(iterations):
            start_time = time.time()
            try:
                response = self.session.get(f"{self.base_url}/agents/published")
                if response.status_code == 200:
                    times.append(time.time() - start_time)
                else:
                    errors += 1
            except Exception as e:
                errors += 1
                print(f"错误: {e}")
        
        self._print_results("Agent列表", times, errors, iterations)
    
    def test_concurrent_requests(self, endpoint="/health", concurrent=10, total=100):
        """测试并发请求"""
        print(f"🔄 测试并发请求 ({concurrent}并发, {total}总请求)...")
        
        def make_request():
            start_time = time.time()
            try:
                response = self.session.get(f"{self.base_url}{endpoint}")
                return time.time() - start_time, response.status_code == 200
            except:
                return time.time() - start_time, False
        
        times = []
        errors = 0
        
        with ThreadPoolExecutor(max_workers=concurrent) as executor:
            futures = [executor.submit(make_request) for _ in range(total)]
            for future in futures:
                response_time, success = future.result()
                times.append(response_time)
                if not success:
                    errors += 1
        
        self._print_results("并发请求", times, errors, total)
    
    def _print_results(self, test_name, times, errors, total):
        """打印测试结果"""
        if not times:
            print(f"❌ {test_name}: 所有请求都失败了")
            return
        
        success_rate = ((total - errors) / total) * 100
        avg_time = statistics.mean(times)
        min_time = min(times)
        max_time = max(times)
        p95_time = statistics.quantiles(times, n=20)[18] if len(times) >= 20 else max_time
        
        print(f"✅ {test_name} 测试结果:")
        print(f"  成功率: {success_rate:.1f}%")
        print(f"  平均响应时间: {avg_time*1000:.2f}ms")
        print(f"  最小响应时间: {min_time*1000:.2f}ms")
        print(f"  最大响应时间: {max_time*1000:.2f}ms")
        print(f"  95%响应时间: {p95_time*1000:.2f}ms")
        print(f"  错误数: {errors}")
        print()

def main():
    """主函数"""
    print("🚀 ImagentX API性能测试开始...")
    print("=" * 50)
    
    benchmark = APIBenchmark()
    
    # 运行各种测试
    benchmark.test_health_check(100)
    benchmark.test_agent_list(50)
    benchmark.test_concurrent_requests("/health", 10, 100)
    
    print("🎉 API性能测试完成！")

if __name__ == "__main__":
    main()
