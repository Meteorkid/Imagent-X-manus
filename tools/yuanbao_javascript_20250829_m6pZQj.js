// dimoo-dino-alien.js
class DimooDinoAlien {
    constructor(container) {
        this.container = container;
        this.state = {
            mood: 'depressed',
            ears: 'alien-pointy',
            hair: 'messy-cotton',
            eyes: 'sad-alien',
            antennas: 'drooping'
        };
        this.init();
    }

    init() {
        // 创建DOM结构
        this.element = document.createElement('div');
        this.element.className = 'dino-dimoo';
        this.container.appendChild(this.element);
        
        this.render();
    }

    render() {
        this.element.innerHTML = `
            <div class="dino-card">
                <div class="dino-hair ${this.state.hair}"></div>
                <div class="dino-antennas ${this.state.antennas}">
                    <div class="dino-antenna"></div>
                    <div class="dino-antenna"></div>
                </div>
                <div class="dino-ears ${this.state.ears}">
                    <div class="dino-ear left"></div>
                    <div class="dino-ear right"></div>
                </div>
                <div class="dino-head">
                    <div class="dino-eyes">
                        <div class="dino-eye ${this.state.eyes}">
                            <div class="eye-pupil"></div>
                            <div class="eye-highlight"></div>
                        </div>
                        <div class="dino-eye ${this.state.eyes}">
                            <div class="eye-pupil"></div>
                            <div class="eye-highlight"></div>
                        </div>
                    </div>
                </div>
                <div class="dino-body"></div>
            </div>
        `;
        
        // 添加CSS样式
        this.addStyles();
    }

    addStyles() {
        const style = document.createElement('style');
        style.textContent = `
            .dino-dimoo {
                position: relative;
                width: 150px;
                height: 200px;
                perspective: 1000px;
            }
            
            .dino-card {
                width: 100%;
                height: 100%;
                position: relative;
                transform-style: preserve-3d;
                transition: transform 0.8s cubic-bezier(0.175, 0.885, 0.32, 1.275);
            }
            
            .dino-body {
                position: absolute;
                width: 100px;
                height: 125px;
                bottom: 0;
                left: 50%;
                transform: translateX(-50%);
                background: #8bc34a;
                border-radius: 50px 50px 25px 25px;
                box-shadow: 
                    0 5px 10px rgba(0, 0, 0, 0.1),
                    inset 0 -5px 10px rgba(0, 0, 0, 0.1);
                overflow: hidden;
                z-index: 10;
            }
            
            .dino-body::before {
                content: '';
                position: absolute;
                top: 0;
                left: 0;
                right: 0;
                height: 40%;
                background: linear-gradient(to bottom, #7cb342, #8bc34a);
                border-radius: 50px 50px 0 0;
            }
            
            .dino-head {
                position: absolute;
                width: 90px;
                height: 90px;
                top: 10px;
                left: 50%;
                transform: translateX(-50%);
                background: #7cb342;
                border-radius: 35% 35% 30% 30%;
                box-shadow: 
                    0 4px 8px rgba(0, 0, 0, 0.1),
                    inset 0 -4px 8px rgba(0, 0, 0, 0.1);
                z-index: 20;
                overflow: hidden;
            }
            
            .dino-head::before {
                content: '';
                position: absolute;
                top: 0;
                left: 0;
                right: 0;
                height: 60%;
                background: linear-gradient(to bottom, #8bc34a, #7cb342);
                border-radius: 35% 35% 0 0;
            }
            
            .dino-ears {
                position: absolute;
                top: -5px;
                left: 0;
                width: 100%;
                display: flex;
                justify-content: space-between;
                z-index: 19;
            }
            
            .dino-ear {
                width: 20px;
                height: 30px;
                background: #7cb342;
                position: relative;
            }
            
            .dino-ear.left {
                border-radius: 50% 0 50% 50%;
                transform: rotate(-30deg);
                left: -3px;
            }
            
            .dino-ear.right {
                border-radius: 0 50% 50% 50%;
                transform: rotate(30deg);
                right: -3px;
            }
            
            .ear-alien-round {
                border-radius: 50% !important;
                height: 25px !important;
            }
            
            .dino-hair {
                position: absolute;
                top: -20px;
                left: 50%;
                transform: translateX(-50%);
                width: 60px;
                height: 40px;
                z-index: 18;
            }
            
            .hair-strand {
                position: absolute;
                bottom: 0;
                width: 100%;
                height: 35px;
                background: #f5deb3;
                border-radius: 25% 25% 0 0;
            }
            
            /* 发型状态 */
            .hair-messy-cotton {
                height: 30px !important;
                background: #f5deb3 !important;
                border-radius: 20% 20% 0 0 !important;
            }
            
            .hair-neat-cotton {
                height: 35px !important;
                background: #d8bfd8 !important;
                border-radius: 22% 22% 0 0 !important;
            }
            
            .hair-styled-cotton {
                height: 37px !important;
                background: #98fb98 !important;
                border-radius: 25% 25% 0 0 !important;
            }
            
            .hair-fluffy-cotton {
                height: 40px !important;
                background: #ffdab9 !important;
                border-radius: 27% 27% 0 0 !important;
            }
            
            .hair-glowing-cotton {
                height: 42px !important;
                background: #ffd700 !important;
                box-shadow: 0 0 10px #ffd700, 0 0 15px #ffff00 !important;
                border-radius: 30% 30% 0 0 !important;
            }
            
            .dino-eyes {
                position: absolute;
                top: 35px;
                left: 0;
                width: 100%;
                display: flex;
                justify-content: space-around;
                z-index: 25;
            }
            
            .dino-eye {
                width: 20px;
                height: 20px;
                background: white;
                border-radius: 50%;
                position: relative;
                overflow: hidden;
                box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1);
            }
            
            .eye-pupil {
                position: absolute;
                width: 12px;
                height: 12px;
                background: #2b6f5f;
                border-radius: 50%;
                top: 50%;
                left: 50%;
                transform: translate(-50%, -50%);
            }
            
            .eye-highlight {
                position: absolute;
                width: 5px;
                height: 5px;
                background: white;
                border-radius: 50%;
                top: 20%;
                right: 20%;
                z-index: 2;
            }
            
            /* 眼睛状态 */
            .eye-sad-alien {
                border-radius: 20% 20% 30% 30% !important;
            }
            
            .eye-sad-alien .eye-pupil {
                width: 15px !important;
                height: 15px !important;
                top: 60% !important;
            }
            
            .eye-twinkling-alien {
                background: #e0f7fa !important;
            }
            
            .eye-twinkling-alien .eye-pupil {
                background: #20b2aa !important;
            }
            
            .eye-bright-alien .eye-pupil {
                background: #32cd32 !important;
                box-shadow: 0 0 5px rgba(50, 205, 50, 0.5);
            }
            
            .eye-happy-alien {
                border-radius: 30% 30% 20% 20% !important;
            }
            
            .eye-happy-alien .eye-pupil {
                background: #ff4500 !important;
            }
            
            .eye-glowing-alien {
                box-shadow: 0 0 8px rgba(255, 255, 255, 0.8) !important;
            }
            
            .eye-glowing-alien .eye-pupil {
                background: #ff8c00 !important;
                box-shadow: 0 0 8px #ff8c00, 0 0 10px #ffa500 !important;
            }
            
            .dino-antennas {
                position: absolute;
                top: -10px;
                left: 50%;
                transform: translateX(-50%);
                width: 60px;
                height: 30px;
                display: flex;
                justify-content: space-between;
                z-index: 17;
            }
            
            .dino-antenna {
                width: 4px;
                height: 20px;
                background: #7cb342;
                position: relative;
                margin: 0 15px;
            }
            
            .dino-antenna::before {
                content: '';
                position: absolute;
                width: 10px;
                height: 10px;
                border-radius: 50%;
                background: #7cb342;
                top: -5px;
                left: 50%;
                transform: translateX(-50%);
            }
            
            /* 触角状态 */
            .antenna-drooping .dino-antenna {
                height: 15px !important;
                transform: rotate(10deg);
                background: #a9a9a9 !important;
            }
            
            .antenna-drooping .dino-antenna::before {
                background: #a9a9a9 !important;
            }
            
            .antenna-curious .dino-antenna {
                background: #4682b4 !important;
            }
            
            .antenna-curious .dino-antenna::before {
                background: #4682b4 !important;
            }
            
            .antenna-active .dino-antenna {
                background: #32cd32 !important;
                height: 22px !important;
            }
            
            .antenna-active .dino-antenna::before {
                background: #32cd32 !important;
            }
            
            .antenna-happy .dino-antenna {
                background: #ff8c00 !important;
                height: 25px !important;
            }
            
            .antenna-happy .dino-antenna::before {
                background: #ff8c00 !important;
            }
            
            .antenna-glowing .dino-antenna {
                background: #ffd700 !important;
                box-shadow: 0 0 5px #ffd700;
            }
            
            .antenna-glowing .dino-antenna::before {
                background: #ffd700 !important;
                box-shadow: 0 0 8px #ffd700, 0 0 10px #ffff00;
            }
            
            /* 动画 */
            @keyframes glow {
                0% { opacity: 0.6; }
                100% { opacity: 1; }
            }
            
            @keyframes bounce {
                0%, 100% { transform: translateY(0); }
                50% { transform: translateY(-5px); }
            }
            
            @keyframes blink {
                0%, 100% { transform: scaleY(1); }
                50% { transform: scaleY(0.1); }
            }
            
            .glowing {
                animation: glow 0.8s infinite alternate;
            }
            
            .bouncing {
                animation: bounce 1s infinite;
            }
            
            .blinking {
                animation: blink 0.5s;
            }
        `;
        document.head.appendChild(style);
    }

    // 状态设置方法
    setMood(mood) {
        this.state.mood = mood;
        
        // 根据情绪自动设置其他部位状态
        switch(mood) {
            case 'depressed':
                this.setEars('alien-pointy');
                this.setHair('messy-cotton');
                this.setEyes('sad-alien');
                this.setAntennas('drooping');
                break;
            case 'healing':
                this.setEars('alien-pointy');
                this.setHair('neat-cotton');
                this.setEyes('twinkling-alien');
                this.setAntennas('curious');
                break;
            case 'recovering':
                this.setEars('alien-round');
                this.setHair('styled-cotton');
                this.setEyes('bright-alien');
                this.setAntennas('active');
                break;
            case 'cured':
                this.setEars('alien-round');
                this.setHair('fluffy-cotton');
                this.setEyes('happy-alien');
                this.setAntennas('happy');
                break;
            case 'radiant':
                this.setEars('alien-round');
                this.setHair('glowing-cotton');
                this.setEyes('glowing-alien');
                this.setAntennas('glowing');
                break;
        }
        
        this.render();
    }

    setEars(type) {
        this.state.ears = type;
        this.render();
    }

    setHair(type) {
        this.state.hair = type;
        this.render();
    }

    setEyes(type) {
        this.state.eyes = type;
        this.render();
    }

    setAntennas(type) {
        this.state.antennas = type;
        this.render();
    }

    // 游戏交互方法
    blink() {
        const eyes = this.element.querySelectorAll('.dino-eye');
        eyes.forEach(eye => {
            eye.classList.add('blinking');
            setTimeout(() => eye.classList.remove('blinking'), 500);
        });
    }

    bounce() {
        const hair = this.element.querySelector('.dino-hair');
        hair.classList.add('bouncing');
        setTimeout(() => hair.classList.remove('bouncing'), 1000);
    }

    glow() {
        const glowingParts = this.element.querySelectorAll('.glowing');
        glowingParts.forEach(part => {
            part.classList.add('glowing');
            setTimeout(() => part.classList.remove('glowing'), 2000);
        });
    }
}

// 导出模块
if (typeof module !== 'undefined' && module.exports) {
    module.exports = DimooDinoAlien;
}