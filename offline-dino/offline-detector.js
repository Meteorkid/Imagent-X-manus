/**
 * 离线检测器 - 专门用于3000端口
 * 当检测到断网时自动显示小恐龙游戏
 */
class OfflineDetector {
    constructor() {
        this.isOffline = false;
        this.gameWindow = null;
        this.checkInterval = null;
        this.init();
    }

    init() {
        // 初始检查
        this.checkNetworkStatus();
        
        // 监听网络状态变化
        window.addEventListener('online', () => this.handleOnline());
        window.addEventListener('offline', () => this.handleOffline());
        
        // 定期检查网络状态
        this.checkInterval = setInterval(() => {
            this.checkNetworkStatus();
        }, 5000);
    }

    async checkNetworkStatus() {
        try {
            // 尝试访问一个小的资源
            const controller = new AbortController();
            const timeoutId = setTimeout(() => controller.abort(), 3000);
            
            const response = await fetch('/favicon.ico', {
                method: 'HEAD',
                signal: controller.signal
            });
            
            clearTimeout(timeoutId);
            
            if (response.ok) {
                this.handleOnline();
            } else {
                this.handleOffline();
            }
        } catch (error) {
            this.handleOffline();
        }
    }

    handleOffline() {
        if (!this.isOffline) {
            this.isOffline = true;
            this.showOfflineGame();
        }
    }

    handleOnline() {
        if (this.isOffline) {
            this.isOffline = false;
            this.hideOfflineGame();
        }
    }

    showOfflineGame() {
        // 创建遮罩层
        const overlay = document.createElement('div');
        overlay.id = 'offline-overlay';
        overlay.style.cssText = `
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0, 0, 0, 0.8);
            z-index: 9999;
            display: flex;
            align-items: center;
            justify-content: center;
        `;

        // 创建游戏容器
        const gameContainer = document.createElement('div');
        gameContainer.style.cssText = `
            background: white;
            border-radius: 8px;
            padding: 20px;
            max-width: 800px;
            max-height: 90vh;
            overflow: hidden;
            position: relative;
        `;

        // 创建关闭按钮
        const closeButton = document.createElement('button');
        closeButton.innerHTML = '×';
        closeButton.style.cssText = `
            position: absolute;
            top: 10px;
            right: 15px;
            background: none;
            border: none;
            font-size: 24px;
            cursor: pointer;
            color: #666;
            z-index: 10001;
        `;
        closeButton.onclick = () => this.hideOfflineGame();

        // 创建iframe加载游戏
        const iframe = document.createElement('iframe');
        iframe.src = '/offline-dino/dino.html';
        iframe.style.cssText = `
            width: 100%;
            height: 400px;
            border: none;
            border-radius: 4px;
        `;

        // 组装元素
        gameContainer.appendChild(closeButton);
        gameContainer.appendChild(iframe);
        overlay.appendChild(gameContainer);
        document.body.appendChild(overlay);

        // 添加键盘事件监听
        document.addEventListener('keydown', this.handleKeyPress.bind(this));
    }

    hideOfflineGame() {
        const overlay = document.getElementById('offline-overlay');
        if (overlay) {
            overlay.remove();
        }
        document.removeEventListener('keydown', this.handleKeyPress.bind(this));
    }

    handleKeyPress(event) {
        if (event.key === 'Escape') {
            this.hideOfflineGame();
        }
    }

    destroy() {
        if (this.checkInterval) {
            clearInterval(this.checkInterval);
        }
        this.hideOfflineGame();
    }
}

// 初始化离线检测器
if (typeof window !== 'undefined') {
    window.addEventListener('DOMContentLoaded', () => {
        // 只在3000端口页面初始化
        if (window.location.port === '3000' || window.location.hostname === 'localhost') {
            new OfflineDetector();
        }
    });
}