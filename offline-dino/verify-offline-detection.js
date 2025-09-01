/**
 * 断网检测功能验证脚本
 * 用于验证前端断网时是否能自动显示小游戏
 */

class OfflineDetectionVerifier {
    constructor() {
        this.testResults = [];
        this.currentTest = null;
        this.init();
    }

    init() {
        console.log('🔍 开始验证断网检测功能...');
        this.runTests();
    }

    async runTests() {
        console.log('\n📋 测试计划：');
        console.log('1. 验证离线检测器初始化');
        console.log('2. 验证网络状态监听');
        console.log('3. 验证API健康检查');
        console.log('4. 验证游戏显示功能');
        console.log('5. 验证游戏隐藏功能');
        console.log('6. 验证样式注入');
        console.log('7. 验证键盘事件处理');

        await this.testInitialization();
        await this.testNetworkListeners();
        await this.testApiHealthCheck();
        await this.testGameDisplay();
        await this.testGameHide();
        await this.testStyleInjection();
        await this.testKeyboardEvents();

        this.printResults();
    }

    async testInitialization() {
        this.currentTest = '离线检测器初始化';
        console.log(`\n🧪 测试: ${this.currentTest}`);

        try {
            // 检查全局对象是否存在
            if (typeof window.imagentxOffline === 'undefined') {
                throw new Error('离线检测器未初始化');
            }

            // 检查必要的方法是否存在
            const requiredMethods = ['checkConnection', 'handleOffline', 'handleOnline', 'showGame', 'hideGame'];
            for (const method of requiredMethods) {
                if (typeof window.imagentxOffline[method] !== 'function') {
                    throw new Error(`缺少方法: ${method}`);
                }
            }

            // 检查必要的属性是否存在
            const requiredProperties = ['isOffline', 'gameContainer', 'checkInterval', 'retryCount', 'maxRetries'];
            for (const prop of requiredProperties) {
                if (typeof window.imagentxOffline[prop] === 'undefined') {
                    throw new Error(`缺少属性: ${prop}`);
                }
            }

            this.addResult(true, '离线检测器初始化成功');
        } catch (error) {
            this.addResult(false, `初始化失败: ${error.message}`);
        }
    }

    async testNetworkListeners() {
        this.currentTest = '网络状态监听';
        console.log(`\n🧪 测试: ${this.currentTest}`);

        try {
            // 检查事件监听器是否已添加
            const listeners = getEventListeners ? getEventListeners(window) : null;
            
            // 模拟网络状态变化
            const originalOnline = navigator.onLine;
            
            // 模拟断网
            Object.defineProperty(navigator, 'onLine', {
                writable: true,
                value: false
            });
            
            // 触发offline事件
            window.dispatchEvent(new Event('offline'));
            
            // 等待一小段时间让事件处理
            await new Promise(resolve => setTimeout(resolve, 100));
            
            // 检查是否进入离线状态
            if (!window.imagentxOffline.isOffline) {
                throw new Error('断网事件未正确处理');
            }
            
            // 模拟联网
            Object.defineProperty(navigator, 'onLine', {
                writable: true,
                value: true
            });
            
            // 触发online事件
            window.dispatchEvent(new Event('online'));
            
            // 等待一小段时间让事件处理
            await new Promise(resolve => setTimeout(resolve, 100));
            
            // 恢复原始状态
            Object.defineProperty(navigator, 'onLine', {
                writable: true,
                value: originalOnline
            });

            this.addResult(true, '网络状态监听正常工作');
        } catch (error) {
            this.addResult(false, `网络监听失败: ${error.message}`);
        }
    }

    async testApiHealthCheck() {
        this.currentTest = 'API健康检查';
        console.log(`\n🧪 测试: ${this.currentTest}`);

        try {
            // 保存原始fetch函数
            const originalFetch = window.fetch;
            
            // 模拟API请求成功
            window.fetch = jest.fn().mockResolvedValue({
                ok: true,
                status: 200
            });
            
            // 调用健康检查
            await window.imagentxOffline.checkConnection();
            
            // 检查是否保持在线状态
            if (window.imagentxOffline.isOffline) {
                throw new Error('API正常时错误进入离线状态');
            }
            
            // 模拟API请求失败
            window.fetch = jest.fn().mockRejectedValue(new Error('Network error'));
            
            // 调用健康检查
            await window.imagentxOffline.checkConnection();
            
            // 恢复原始fetch函数
            window.fetch = originalFetch;

            this.addResult(true, 'API健康检查功能正常');
        } catch (error) {
            this.addResult(false, `API检查失败: ${error.message}`);
        }
    }

    async testGameDisplay() {
        this.currentTest = '游戏显示功能';
        console.log(`\n🧪 测试: ${this.currentTest}`);

        try {
            // 调用显示游戏方法
            window.imagentxOffline.showGame();
            
            // 检查游戏容器是否创建
            const gameContainer = document.querySelector('.offline-game-overlay');
            if (!gameContainer) {
                throw new Error('游戏容器未创建');
            }
            
            // 检查容器是否显示
            if (gameContainer.style.display !== 'flex') {
                throw new Error('游戏容器未正确显示');
            }
            
            // 检查iframe是否存在
            const iframe = gameContainer.querySelector('iframe');
            if (!iframe) {
                throw new Error('游戏iframe未创建');
            }
            
            // 检查iframe源地址
            if (iframe.src !== '/offline-dino/dino.html') {
                throw new Error('游戏iframe源地址错误');
            }

            this.addResult(true, '游戏显示功能正常');
        } catch (error) {
            this.addResult(false, `游戏显示失败: ${error.message}`);
        }
    }

    async testGameHide() {
        this.currentTest = '游戏隐藏功能';
        console.log(`\n🧪 测试: ${this.currentTest}`);

        try {
            // 调用隐藏游戏方法
            window.imagentxOffline.hideGame();
            
            // 检查游戏容器是否被移除
            const gameContainer = document.querySelector('.offline-game-overlay');
            if (gameContainer) {
                throw new Error('游戏容器未被正确移除');
            }
            
            // 检查gameContainer属性是否重置
            if (window.imagentxOffline.gameContainer !== null) {
                throw new Error('gameContainer属性未重置');
            }

            this.addResult(true, '游戏隐藏功能正常');
        } catch (error) {
            this.addResult(false, `游戏隐藏失败: ${error.message}`);
        }
    }

    async testStyleInjection() {
        this.currentTest = '样式注入';
        console.log(`\n🧪 测试: ${this.currentTest}`);

        try {
            // 检查样式是否已注入
            const styles = document.querySelectorAll('style');
            let styleFound = false;
            
            for (const style of styles) {
                if (style.textContent.includes('.offline-game-overlay')) {
                    styleFound = true;
                    break;
                }
            }
            
            if (!styleFound) {
                throw new Error('离线游戏样式未注入');
            }

            this.addResult(true, '样式注入正常');
        } catch (error) {
            this.addResult(false, `样式注入失败: ${error.message}`);
        }
    }

    async testKeyboardEvents() {
        this.currentTest = '键盘事件处理';
        console.log(`\n🧪 测试: ${this.currentTest}`);

        try {
            // 先显示游戏
            window.imagentxOffline.showGame();
            
            // 模拟ESC键事件
            const escEvent = new KeyboardEvent('keydown', {
                key: 'Escape',
                code: 'Escape',
                keyCode: 27,
                which: 27,
                bubbles: true
            });
            
            document.dispatchEvent(escEvent);
            
            // 等待事件处理
            await new Promise(resolve => setTimeout(resolve, 100));
            
            // 检查游戏是否被隐藏
            const gameContainer = document.querySelector('.offline-game-overlay');
            if (gameContainer) {
                throw new Error('ESC键未正确隐藏游戏');
            }

            this.addResult(true, '键盘事件处理正常');
        } catch (error) {
            this.addResult(false, `键盘事件失败: ${error.message}`);
        }
    }

    addResult(success, message) {
        const result = {
            test: this.currentTest,
            success,
            message,
            timestamp: new Date().toISOString()
        };
        
        this.testResults.push(result);
        
        const status = success ? '✅' : '❌';
        console.log(`${status} ${message}`);
    }

    printResults() {
        console.log('\n📊 测试结果汇总:');
        console.log('='.repeat(50));
        
        const passed = this.testResults.filter(r => r.success).length;
        const total = this.testResults.length;
        
        console.log(`总测试数: ${total}`);
        console.log(`通过: ${passed}`);
        console.log(`失败: ${total - passed}`);
        console.log(`成功率: ${((passed / total) * 100).toFixed(1)}%`);
        
        console.log('\n详细结果:');
        this.testResults.forEach((result, index) => {
            const status = result.success ? '✅' : '❌';
            console.log(`${index + 1}. ${status} ${result.test}: ${result.message}`);
        });
        
        if (passed === total) {
            console.log('\n🎉 所有测试通过！断网检测功能正常工作。');
        } else {
            console.log('\n⚠️  部分测试失败，请检查相关功能。');
        }
    }
}

// 辅助函数：模拟jest.fn()
if (typeof jest === 'undefined') {
    window.jest = {
        fn: () => {
            const mockFn = (...args) => mockFn.mock.calls.push(args);
            mockFn.mock = { calls: [] };
            mockFn.mockResolvedValue = (value) => {
                mockFn.mockReturnValue = Promise.resolve(value);
                return mockFn;
            };
            mockFn.mockRejectedValue = (error) => {
                mockFn.mockReturnValue = Promise.reject(error);
                return mockFn;
            };
            return mockFn;
        }
    };
}

// 等待页面加载完成后运行验证
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', () => {
        setTimeout(() => new OfflineDetectionVerifier(), 1000);
    });
} else {
    setTimeout(() => new OfflineDetectionVerifier(), 1000);
}
