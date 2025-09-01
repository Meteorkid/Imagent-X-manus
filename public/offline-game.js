/**
 * ImagentX项目离线游戏集成
 * 当项目断网时自动显示小恐龙游戏
 */
class ImagentXOfflineGame {
    constructor() {
        this.isOffline = false;
        this.gameContainer = null;
        this.checkInterval = null;
        this.retryCount = 0;
        this.maxRetries = 3;
        this.isInitialized = false;
        this.init();
    }

    init() {
        try {
            console.log('🔄 初始化 ImagentX 离线检测器...');
            
            // 创建游戏容器样式
            this.injectStyles();
            
            // 初始检查
            this.checkConnection();
            
            // 监听网络状态
            window.addEventListener('online', () => this.handleOnline());
            window.addEventListener('offline', () => this.handleOffline());
            
            // 定期检查
            this.checkInterval = setInterval(() => {
                this.checkConnection();
            }, 10000);
            
            this.isInitialized = true;
            console.log('✅ ImagentX 离线检测器初始化成功');
            
            // 添加全局方法
            window.imagentxOffline = this;
            
        } catch (error) {
            console.error('❌ ImagentX 离线检测器初始化失败:', error);
        }
    }

    injectStyles() {
        const style = document.createElement('style');
        style.textContent = `
            .offline-game-overlay {
                position: fixed;
                top: 0;
                left: 0;
                width: 100%;
                height: 100%;
                background: rgba(248, 249, 250, 0.98);
                z-index: 9999;
                display: none;
                align-items: center;
                justify-content: center;
                backdrop-filter: blur(10px);
            }
            
            .offline-game-container {
                background: white;
                border-radius: 12px;
                box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
                overflow: hidden;
                max-width: 90vw;
                max-height: 90vh;
                position: relative;
            }
            
            .offline-game-header {
                background: #1a73e8;
                color: white;
                padding: 16px 24px;
                display: flex;
                justify-content: space-between;
                align-items: center;
            }
            
            .offline-game-title {
                font-size: 18px;
                font-weight: 500;
            }
            
            .offline-game-close {
                background: none;
                border: none;
                color: white;
                font-size: 24px;
                cursor: pointer;
                padding: 0;
                width: 32px;
                height: 32px;
                display: flex;
                align-items: center;
                justify-content: center;
                border-radius: 50%;
                transition: background-color 0.3s;
            }
            
            .offline-game-close:hover {
                background: rgba(255, 255, 255, 0.2);
            }
            
            .offline-game-body {
                padding: 0;
            }
            
            .offline-game-iframe {
                width: 800px;
                height: 400px;
                border: none;
                display: block;
            }
            
            .offline-status-bar {
                position: fixed;
                top: 0;
                left: 0;
                right: 0;
                background: #dc3545;
                color: white;
                padding: 8px 16px;
                font-size: 14px;
                display: none;
                align-items: center;
                justify-content: center;
                z-index: 10000;
                box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
            }
            
            .offline-status-dot {
                width: 8px;
                height: 8px;
                background: white;
                border-radius: 50%;
                margin-right: 8px;
                animation: pulse 2s infinite;
            }
            
            @keyframes pulse {
                0% { opacity: 1; }
                50% { opacity: 0.5; }
                100% { opacity: 1; }
            }
            
            @media (max-width: 768px) {
                .offline-game-iframe {
                    width: 100vw;
                    height: 60vh;
                }
            }
        `;
        document.head.appendChild(style);
    }

    async checkConnection() {
        try {
            const controller = new AbortController();
            const timeoutId = setTimeout(() => controller.abort(), 5000);
            
            const response = await fetch('/api/health', {
                method: 'HEAD',
                signal: controller.signal,
                cache: 'no-cache'
            });
            
            clearTimeout(timeoutId);
            
            if (response.ok) {
                this.handleOnline();
            } else {
                throw new Error('API响应异常');
            }
        } catch (error) {
            console.log('🌐 网络检查失败:', error.message);
            this.retryCount++;
            if (this.retryCount >= this.maxRetries) {
                this.handleOffline();
                this.retryCount = 0;
            }
        }
    }

    handleOffline() {
        if (!this.isOffline) {
            console.log('📴 检测到断网，显示离线游戏');
            this.isOffline = true;
            this.showOfflineStatus();
            this.showGame();
        }
    }

    handleOnline() {
        if (this.isOffline) {
            console.log('🌐 检测到网络恢复，隐藏离线游戏');
            this.isOffline = false;
            this.retryCount = 0;
            this.hideOfflineStatus();
            this.hideGame();
        }
    }

    showOfflineStatus() {
        let statusBar = document.getElementById('offline-status-bar');
        if (!statusBar) {
            statusBar = document.createElement('div');
            statusBar.id = 'offline-status-bar';
            statusBar.className = 'offline-status-bar';
            statusBar.innerHTML = `
                <span class="offline-status-dot"></span>
                <span>网络连接已断开</span>
            `;
            document.body.appendChild(statusBar);
        }
        statusBar.style.display = 'flex';
    }

    hideOfflineStatus() {
        const statusBar = document.getElementById('offline-status-bar');
        if (statusBar) {
            statusBar.style.display = 'none';
        }
    }

    showGame() {
        if (this.gameContainer) return;

        console.log('🎮 显示离线游戏');
        this.gameContainer = document.createElement('div');
        this.gameContainer.className = 'offline-game-overlay';
        this.gameContainer.innerHTML = `
            <div class="offline-game-container">
                <div class="offline-game-header">
                    <div class="offline-game-title">网络连接中断 - 小恐龙游戏</div>
                    <button class="offline-game-close" onclick="imagentxOffline.hideGame()">×</button>
                </div>
                <div class="offline-game-body">
                    <iframe 
                        class="offline-game-iframe" 
                        src="/offline-dino/dino.html"
                        allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture">
                    </iframe>
                </div>
            </div>
        `;
        
        document.body.appendChild(this.gameContainer);
        this.gameContainer.style.display = 'flex';
        
        // 添加键盘事件
        document.addEventListener('keydown', this.handleKeyPress.bind(this));
    }

    hideGame() {
        if (this.gameContainer) {
            console.log('🎮 隐藏离线游戏');
            this.gameContainer.remove();
            this.gameContainer = null;
            document.removeEventListener('keydown', this.handleKeyPress.bind(this));
        }
    }

    handleKeyPress(event) {
        if (event.key === 'Escape') {
            this.hideGame();
        }
    }

    // 手动触发方法
    forceShowGame() {
        console.log('🎮 手动显示游戏');
        this.showGame();
    }

    forceHideGame() {
        console.log('🎮 手动隐藏游戏');
        this.hideGame();
    }

    // 获取状态
    getStatus() {
        return {
            isInitialized: this.isInitialized,
            isOffline: this.isOffline,
            retryCount: this.retryCount,
            gameContainer: !!this.gameContainer
        };
    }

    destroy() {
        if (this.checkInterval) {
            clearInterval(this.checkInterval);
        }
        this.hideGame();
        this.hideOfflineStatus();
        console.log('🗑️ ImagentX 离线检测器已销毁');
    }
}

// 初始化
if (typeof window !== 'undefined') {
    // 等待DOM加载完成
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', () => {
            console.log('📄 DOM加载完成，初始化离线检测器');
            window.imagentxOffline = new ImagentXOfflineGame();
        });
    } else {
        console.log('📄 DOM已加载，立即初始化离线检测器');
        window.imagentxOffline = new ImagentXOfflineGame();
    }
    
    // 添加全局调试方法
    window.debugOfflineGame = () => {
        if (window.imagentxOffline) {
            console.log('🔍 离线检测器状态:', window.imagentxOffline.getStatus());
        } else {
            console.log('❌ 离线检测器未初始化');
        }
    };
}