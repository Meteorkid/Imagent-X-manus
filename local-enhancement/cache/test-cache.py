#!/usr/bin/env python3
"""
本地缓存测试脚本
"""

import time
import json
from datetime import datetime

class LocalCache:
    def __init__(self):
        self.cache = {}
        self.timestamps = {}
    
    def set(self, key, value, ttl=300):
        """设置缓存"""
        self.cache[key] = value
        self.timestamps[key] = time.time() + ttl
    
    def get(self, key):
        """获取缓存"""
        if key in self.cache:
            if time.time() < self.timestamps[key]:
                return self.cache[key]
            else:
                # 过期，删除
                del self.cache[key]
                del self.timestamps[key]
        return None
    
    def delete(self, key):
        """删除缓存"""
        if key in self.cache:
            del self.cache[key]
            del self.timestamps[key]
    
    def clear(self):
        """清空缓存"""
        self.cache.clear()
        self.timestamps.clear()
    
    def info(self):
        """缓存信息"""
        valid_keys = [k for k, v in self.timestamps.items() if time.time() < v]
        return {
            'total_keys': len(self.cache),
            'valid_keys': len(valid_keys),
            'expired_keys': len(self.cache) - len(valid_keys)
        }

def test_cache():
    """测试缓存功能"""
    print("🧪 本地缓存测试开始...")
    
    cache = LocalCache()
    
    # 测试基本操作
    print("\n🔧 测试基本操作...")
    cache.set('test:string', 'Hello ImagentX!')
    value = cache.get('test:string')
    print(f"字符串操作: {value}")
    
    # 测试复杂对象
    user_data = {
        'user_id': '12345',
        'username': 'testuser',
        'login_time': datetime.now().isoformat(),
        'permissions': ['read', 'write', 'admin']
    }
    cache.set('user:12345', user_data, ttl=3600)
    cached_user = cache.get('user:12345')
    print(f"用户数据缓存: {cached_user['username'] if cached_user else 'None'}")
    
    # 测试过期时间
    cache.set('test:expire', 'Will expire in 3 seconds', ttl=3)
    print(f"过期测试: {cache.get('test:expire')}")
    print("等待4秒...")
    time.sleep(4)
    print(f"过期后: {cache.get('test:expire')}")
    
    # 测试性能
    print("\n⚡ 测试性能...")
    start_time = time.time()
    for i in range(1000):
        cache.set(f'perf:key:{i}', f'value:{i}')
    write_time = time.time() - start_time
    print(f"批量写入1000条记录耗时: {write_time:.3f}秒")
    
    start_time = time.time()
    for i in range(1000):
        cache.get(f'perf:key:{i}')
    read_time = time.time() - start_time
    print(f"批量读取1000条记录耗时: {read_time:.3f}秒")
    
    # 显示缓存信息
    info = cache.info()
    print(f"\n📊 缓存信息: {info}")
    
    print("\n🎉 本地缓存测试完成！")

if __name__ == "__main__":
    test_cache()
