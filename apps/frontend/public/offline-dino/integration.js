/**
 * 离线小恐龙游戏集成脚本
 * 将此脚本添加到您的网站中以实现断网时自动显示游戏
 */

class OfflineGameIntegration {
    constructor(options = {}) {
        this.options = {
            gameUrl: '/offline-dino/dino.html',
            offlineUrl: '/offline-dino/offline.html',
            checkInterval: 1000,
            autoShow: true,
            ...options
        };
        
        this.isOffline = !navigator.onLine;
        this.gameContainer = null;
        this.init();
    }
    
    init() {
        this.setupEventListeners();
        this.createGameContainer();
        
        if (this.isOffline) {
            this.showGame();
        }
        
        // 定期检查网络状态
        setInterval(() => this.checkNetworkStatus(), this.options.checkInterval);
    }
    
    setupEventListeners() {
        window.addEventListener('online', () => this.handleOnline());
        window.addEventListener('offline', () => this.handleOffline());
    }
    
    createGameContainer() {
        this.gameContainer = document.createElement('div');
        this.gameContainer.id = 'offline-game-container';
        this.gameContainer.style.cssText = `
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0, 0, 0, 0.8);
            z-index: 9999;
            display: none;
            justify-content: center;
            align-items: center;
        `;
        
        // 创建iframe加载游戏
        const iframe = document.createElement('iframe');
        iframe.src = this.options.gameUrl;
        iframe.style.cssText = `
            width: 90%;
            height: 90%;
            max-width: 900px;
            max-height: 600px;
            border: none;
            border-radius: 10px;
            background: white;
        `;
        
        // 创建关闭按钮
        const closeButton = document.createElement('button');
        closeButton.innerHTML = '×';
        closeButton.style.cssText = `
            position: absolute;
            top: 20px;
            right: 20px;
            background: #ff4444;
            color: white;
            border: none;
            border-radius: 50%;
            width: 40px;
            height: 40px;
            font-size: 24px;
            cursor: pointer;
            z-index: 10000;
        `;
        closeButton.onclick = () => this.hideGame();
        
        this.gameContainer.appendChild(iframe);
        this.gameContainer.appendChild(closeButton);
        document.body.appendChild(this.gameContainer);
    }
    
    checkNetworkStatus() {
        const wasOffline = this.isOffline;
        this.isOffline = !navigator.onLine;
        
        if (!wasOffline && this.isOffline) {
            this.handleOffline();
        } else if (wasOffline && !this.isOffline) {
            this.handleOnline();
        }
    }
    
    handleOffline() {
        this.isOffline = true;
        console.log('网络已断开，显示离线游戏');
        
        if (this.options.autoShow) {
            setTimeout(() => this.showGame(), 2000);
        }
    }
    
    handleOnline() {
        this.isOffline = false;
        console.log('网络已恢复，隐藏离线游戏');
        this.hideGame();
    }
    
    showGame() {
        if (this.gameContainer) {
            this.gameContainer.style.display = 'flex';
            document.body.style.overflow = 'hidden';
        }
    }
    
    hideGame() {
        if (this.gameContainer) {
            this.gameContainer.style.display = 'none';
            document.body.style.overflow = '';
        }
    }
    
    // 手动显示游戏
    show() {
        this.showGame();
    }
    
    // 手动隐藏游戏
    hide() {
        this.hideGame();
    }
    
    // 销毁集成
    destroy() {
        if (this.gameContainer) {
            document.body.removeChild(this.gameContainer);
            this.gameContainer = null;
        }
    }
}

// 使用示例
// 在您的网站中添加以下代码：

/*
// 1. 引入集成脚本
<script src="/offline-dino/integration.js"></script>

// 2. 初始化集成
<script>
document.addEventListener('DOMContentLoaded', () => {
    const offlineGame = new OfflineGameIntegration({
        gameUrl: '/offline-dino/dino.html',
        autoShow: true,
        checkInterval: 2000
    });
    
    // 可选：手动触发
    // offlineGame.show();
});
</script>
*/

// 3. 或者使用CDN方式
// <script src="https://your-cdn.com/offline-dino/integration.js"></script>

// 导出供模块化使用
if (typeof module !== 'undefined' && module.exports) {
    module.exports = OfflineGameIntegration;
}

// 全局注册
if (typeof window !== 'undefined') {
    window.OfflineGameIntegration = OfflineGameIntegration;
}