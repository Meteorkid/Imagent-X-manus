class DinoGame {
    constructor() {
        this.canvas = document.getElementById('gameCanvas');
        this.ctx = this.canvas.getContext('2d');
        this.width = this.canvas.width;
        this.height = this.canvas.height;
        
        // 游戏状态
        this.gameRunning = false;
        this.gameOver = false;
        this.score = 0;
        this.speed = 3;
        this.gravity = 0.6;
        
        // 恐龙属性
        this.dino = {
            x: 80,
            y: this.height - 100,
            width: 40,
            height: 50,
            velocityY: 0,
            jumping: false,
            ducking: false,
            color: '#2c3e50'
        };
        
        // 地面
        this.ground = {
            y: this.height - 50,
            height: 50,
            color: '#8B4513'
        };
        
        // 障碍物数组
        this.obstacles = [];
        this.clouds = [];
        this.lastObstacleTime = 0;
        this.obstacleInterval = 2000; // 毫秒
        
        // 游戏循环
        this.lastTime = 0;
        
        this.init();
    }
    
    init() {
        this.setupEventListeners();
        this.generateClouds();
        this.gameLoop();
    }
    
    setupEventListeners() {
        // 键盘事件
        document.addEventListener('keydown', (e) => {
            if (e.code === 'Space') {
                e.preventDefault();
                if (!this.gameRunning && !this.gameOver) {
                    this.startGame();
                } else if (this.gameRunning) {
                    this.jump();
                } else if (this.gameOver) {
                    this.restart();
                }
            } else if (e.code === 'ArrowDown' && this.gameRunning) {
                this.duck();
            }
        });
        
        document.addEventListener('keyup', (e) => {
            if (e.code === 'ArrowDown') {
                this.stopDuck();
            }
        });
        
        // 鼠标/触摸事件
        this.canvas.addEventListener('click', () => {
            if (!this.gameRunning && !this.gameOver) {
                this.startGame();
            } else if (this.gameRunning) {
                this.jump();
            } else if (this.gameOver) {
                this.restart();
            }
        });
    }
    
    startGame() {
        this.gameRunning = true;
        this.gameOver = false;
        this.score = 0;
        this.speed = 3;
        this.obstacles = [];
        this.lastObstacleTime = Date.now();
        document.getElementById('gameOver').style.display = 'none';
    }
    
    jump() {
        if (!this.dino.jumping && this.gameRunning) {
            this.dino.velocityY = -15;
            this.dino.jumping = true;
        }
    }
    
    duck() {
        if (this.gameRunning && !this.dino.jumping) {
            this.dino.ducking = true;
            this.dino.height = 25;
            this.dino.y = this.height - 75;
        }
    }
    
    stopDuck() {
        this.dino.ducking = false;
        this.dino.height = 50;
        this.dino.y = this.height - 100;
    }
    
    restart() {
        this.dino.y = this.height - 100;
        this.dino.velocityY = 0;
        this.dino.jumping = false;
        this.dino.ducking = false;
        this.startGame();
    }
    
    generateClouds() {
        for (let i = 0; i < 5; i++) {
            this.clouds.push({
                x: Math.random() * this.width,
                y: Math.random() * 150 + 20,
                width: Math.random() * 60 + 40,
                height: Math.random() * 30 + 20,
                speed: Math.random() * 0.5 + 0.5
            });
        }
    }
    
    generateObstacle() {
        const types = ['cactus', 'bird'];
        const type = types[Math.random() < 0.8 ? 0 : 1]; // 仙人掌更常见
        
        let obstacle = {
            x: this.width + Math.random() * 200 + 100, // 增加初始距离，避免太密集
            type: type,
            width: type === 'cactus' ? 20 : 35,
            height: type === 'cactus' ? 45 : 20,
            color: type === 'cactus' ? '#228B22' : '#FF6347'
        };
        
        if (type === 'cactus') {
            obstacle.y = this.height - 95; // 仙人掌位置稍微调低
        } else {
            // 鸟类飞行高度分为两层，避免太高或太低
            obstacle.y = this.height - 100 - (Math.random() > 0.6 ? 20 : 50);
        }
        
        this.obstacles.push(obstacle);
    }
    
    updateDino() {
        // 应用重力
        this.dino.velocityY += this.gravity;
        this.dino.y += this.dino.velocityY;
        
        // 地面碰撞检测
        if (this.dino.y > this.height - 100 - this.dino.height) {
            this.dino.y = this.height - 100 - this.dino.height;
            this.dino.velocityY = 0;
            this.dino.jumping = false;
        }
    }
    
    updateObstacles() {
        // 生成新障碍物
        const currentTime = Date.now();
        if (currentTime - this.lastObstacleTime > this.obstacleInterval) {
            this.generateObstacle();
            this.lastObstacleTime = currentTime;
            this.obstacleInterval = Math.max(1000, this.obstacleInterval - 50);
        }
        
        // 更新障碍物位置
        this.obstacles.forEach((obstacle, index) => {
            obstacle.x -= this.speed;
            
            // 移除屏幕外的障碍物
            if (obstacle.x + obstacle.width < 0) {
                this.obstacles.splice(index, 1);
                this.score += 10;
            }
        });
    }
    
    updateClouds() {
        this.clouds.forEach(cloud => {
            cloud.x -= cloud.speed;
            if (cloud.x + cloud.width < 0) {
                cloud.x = this.width;
                cloud.y = Math.random() * 150 + 20;
            }
        });
    }
    
    checkCollisions() {
        this.obstacles.forEach(obstacle => {
            if (this.dino.x < obstacle.x + obstacle.width &&
                this.dino.x + this.dino.width > obstacle.x &&
                this.dino.y < obstacle.y + obstacle.height &&
                this.dino.y + this.dino.height > obstacle.y) {
                this.gameOver = true;
                this.gameRunning = false;
                this.showGameOver();
            }
        });
    }
    
    showGameOver() {
        document.getElementById('finalScore').textContent = this.score;
        document.getElementById('gameOver').style.display = 'block';
        
        // 3秒后自动刷新页面，检测网络是否恢复
        setTimeout(() => {
            window.location.reload();
        }, 3000);
    }
    
    drawDino() {
        this.ctx.fillStyle = this.dino.color;
        
        if (this.dino.ducking) {
            // 下蹲状态
            this.ctx.fillRect(this.dino.x, this.dino.y, this.dino.width, this.dino.height);
            // 画头部
            this.ctx.fillRect(this.dino.x + 30, this.dino.y - 10, 15, 15);
        } else {
            // 正常状态
            this.ctx.fillRect(this.dino.x, this.dino.y, this.dino.width, this.dino.height);
            // 画头部
            this.ctx.fillRect(this.dino.x + 25, this.dino.y - 15, 20, 20);
            // 画眼睛
            this.ctx.fillStyle = 'white';
            this.ctx.fillRect(this.dino.x + 35, this.dino.y - 10, 5, 5);
        }
    }
    
    drawObstacles() {
        this.obstacles.forEach(obstacle => {
            this.ctx.fillStyle = obstacle.color;
            
            if (obstacle.type === 'cactus') {
                // 画仙人掌
                this.ctx.fillRect(obstacle.x, obstacle.y, obstacle.width, obstacle.height);
                // 添加一些细节
                this.ctx.fillRect(obstacle.x - 5, obstacle.y + 10, 5, 15);
                this.ctx.fillRect(obstacle.x + 20, obstacle.y + 5, 5, 10);
            } else {
                // 画鸟
                this.ctx.fillRect(obstacle.x, obstacle.y, obstacle.width, obstacle.height);
                // 翅膀
                this.ctx.fillRect(obstacle.x - 5, obstacle.y + 5, 10, 5);
                this.ctx.fillRect(obstacle.x + 25, obstacle.y + 5, 10, 5);
            }
        });
    }
    
    drawClouds() {
        this.ctx.fillStyle = 'rgba(255, 255, 255, 0.8)';
        this.clouds.forEach(cloud => {
            this.ctx.beginPath();
            this.ctx.arc(cloud.x, cloud.y, cloud.width / 2, 0, Math.PI * 2);
            this.ctx.arc(cloud.x + cloud.width / 3, cloud.y, cloud.width / 3, 0, Math.PI * 2);
            this.ctx.arc(cloud.x - cloud.width / 3, cloud.y, cloud.width / 3, 0, Math.PI * 2);
            this.ctx.fill();
        });
    }
    
    drawGround() {
        this.ctx.fillStyle = this.ground.color;
        this.ctx.fillRect(0, this.ground.y, this.width, this.ground.height);
        
        // 地面纹理
        this.ctx.fillStyle = '#A0522D';
        for (let i = 0; i < this.width; i += 20) {
            this.ctx.fillRect(i, this.ground.y + 10, 10, 5);
        }
    }
    
    update() {
        if (!this.gameRunning || this.gameOver) return;
        
        this.updateDino();
        this.updateObstacles();
        this.updateClouds();
        this.checkCollisions();
        
        // 增加速度和得分
        this.speed += 0.001;
        this.score += 0.1;
        
        document.getElementById('score').textContent = Math.floor(this.score);
    }
    
    draw() {
        // 清空画布
        this.ctx.clearRect(0, 0, this.width, this.height);
        
        // 绘制背景
        const gradient = this.ctx.createLinearGradient(0, 0, 0, this.height);
        gradient.addColorStop(0, '#87CEEB');
        gradient.addColorStop(1, '#E0F6FF');
        this.ctx.fillStyle = gradient;
        this.ctx.fillRect(0, 0, this.width, this.height);
        
        this.drawClouds();
        this.drawGround();
        this.drawDino();
        this.drawObstacles();
        
        // 开始提示
        if (!this.gameRunning && !this.gameOver) {
            this.ctx.fillStyle = '#333';
            this.ctx.font = '20px Arial';
            this.ctx.textAlign = 'center';
            this.ctx.fillText('按空格键或点击开始游戏', this.width / 2, this.height / 2);
        }
    }
    
    gameLoop(currentTime = 0) {
        const deltaTime = currentTime - this.lastTime;
        this.lastTime = currentTime;
        
        this.update();
        this.draw();
        
        requestAnimationFrame((time) => this.gameLoop(time));
    }
}

// 全局函数
function restartGame() {
    game.restart();
}

// 初始化游戏
const game = new DinoGame();