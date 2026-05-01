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
        this.distance = 0; // 初始化距离
        this.speed = 3;
        this.baseSpeed = 3; // 基础速度
        this.speedMultiplier = 1; // 速度倍数
        // 生命系统
        this.lives = 1; // 初始生命
        this.maxLives = 99; // 最大生命数
        
        // 无敌状态和高速飞行系统
        this.isInvincible = false; // 是否处于无敌状态
        this.invincibleStartTime = 0; // 无敌状态开始时间
        this.invincibleDuration = 5000; // 无敌状态持续时间（5秒）
        this.lastInvincibleCheck = Date.now(); // 上次无敌状态检查时间
        this.invincibleLevel = 1; // 无敌状态等级（用于等差数列计算）
        this.maxSpeedMultiplier = 20; // 最大速度倍数
        
        // 背景系统
        this.backgrounds = {
            day: {
                sky: '#87CEEB',
                ground: '#8B4513',
                clouds: 'rgba(255, 255, 255, 0.8)',
                text: '#333'
            },
            night: {
                sky: '#1a1a2e',
                ground: '#16213e',
                clouds: 'rgba(255, 255, 255, 0.3)',
                text: '#fff'
            }
        };
        this.currentBackground = 'day';
        
        // DIMOO外星小男孩属性 - 完全重做DIMOO外星小男孩设计
        this.dimoo = {
            x: 80,
            y: this.height - 50 - 60, // 调整到地面上：地面位置减去角色高度
            width: 50, // 固定宽度
            height: 60, // 增加高度，让身体变长
            velocityY: 0,
            jumping: false,
            ducking: false,
            color: '#FFB6C1', // 浅粉色，代表温暖
            // 优化跳跃和滑翔系统
            jumpCount: 0,
            maxJumps: 3, // 改为3次跳跃，第3次为滑翔
            isGliding: false,
            isGlideKeyPressed: false, // 滑翔键是否被按下
            normalGravity: 0.12, // 进一步减少重力，增加滞空时间
            glideGravity: 0.008, // 滑翔时的重力，下降速度进一步减少
            fastFallGravity: 0.5, // 快速下落的重力，进一步减少下降速度
            canFastFall: false, // 是否可以快速下落
            // 跳跃参数优化 - 第一段跳跃高度减半
            jumpVelocity: -9, // 跳跃初速度（减半）
            doubleJumpVelocity: -3.5, // 连跳速度（减半）
            tripleJumpVelocity: -2.5, // 第三段跳跃速度（减半）
            quadrupleJumpVelocity: -3, // 第四段跳跃速度
            // 动画相关
            animationFrame: 0,
            runSpeed: 0.3, // 增加奔跑动画速度
            isRunning: true,
            // 滑翔系统优化
            glideStartTime: 0,
            glideDuration: 0,
            isGlideReleased: false,
            // 行走姿态优化
            walkCycle: 0,
            legOffset: 0,
            tailOffset: 0,
            // 下蹲状态
            originalHeight: 60, // 原始高度（更新为新的高度）
            duckHeight: 90, // 下蹲时高度下调25，比站立时高30像素
            // 网络检测
            networkCheckTimer: null,
            networkCheckInterval: 5000, // 5秒检测一次网络
            // 全新DIMOO形态系统 - 完全重新构建
            form: 'depressed', // 初始形态：抑郁状态
            forms: {
                'depressed': {
                    name: '抑郁小外星人',
                    color: '#8B4513', // 棕色，代表抑郁
                    eyeColor: '#8B0000', // 红色眼睛，代表痛苦
                    skinColor: '#DEB887', // 浅棕色皮肤
                    mood: 'sad', // 心情：悲伤
                    description: '一只患有抑郁症的小外星人，眼神黯淡，行动缓慢',
                    // 全新设计元素：梦幻太空风格
                    features: {
                        // 头部特征
                        head: 'large_round', // 大头圆脸
                        skin: 'light_peach', // 浅桃色皮肤
                        cheeks: 'none', // 无腮红
                        
                        // 头发特征
                        hair: 'messy_orange', // 凌乱橙色头发
                        hairStyle: 'fluffy_cloud', // 蓬松云朵状
                        hairColor: '#FFA500', // 橙色
                        
                        // 眼睛特征
                        eyes: 'sad_green', // 悲伤绿色眼睛
                        eyeColor: '#228B22', // 森林绿
                        eyeGlow: 'none', // 无发光
                        eyeHighlights: 'minimal', // 最小高光
                        
                        // 触角特征
                        antennae: 'droopy_yellow', // 下垂黄色触角
                        antennaColor: '#FFD700', // 金黄色
                        antennaGlow: 'none', // 无发光
                        antennaTips: 'small_sphere', // 小球体
                        
                        // 耳朵特征
                        ears: 'round_oversized', // 圆形大耳朵
                        earColor: '#DEB887', // 浅棕色
                        
                        // 嘴巴特征
                        mouth: 'sad_line', // 悲伤线条
                        mouthColor: '#8B0000', // 深红色
                        
                        // 太空服特征
                        suit: 'dark_futuristic', // 深色未来风格
                        suitColor: '#2F4F4F', // 深灰绿色
                        suitAccents: 'minimal', // 最少装饰
                        suitGlow: 'none', // 无发光
                        
                        // 背包特征
                        backpack: 'none', // 无背包
                        
                        // 装饰特征
                        decorations: 'none', // 无装饰
                        ribbons: 'none', // 无丝带
                        tubes: 'none', // 无管子
                        
                        // 鞋子特征
                        shoes: 'dark_blue', // 深蓝色鞋子
                        shoeColor: '#191970', // 午夜蓝
                        shoeAccents: 'none', // 无装饰
                        
                        // 发光效果
                        glow: 'none', // 无发光
                        aura: 'none', // 无光环
                        
                        // 表情特征
                        expression: 'sad_innocent', // 悲伤天真
                        energy: 'low', // 低能量
                        sparkle: 'none' // 无闪烁
                    }
                },
                'healing': {
                    name: '治愈中小外星人',
                    color: '#87CEEB', // 天蓝色，代表希望
                    eyeColor: '#00CED1', // 深青色眼睛
                    skinColor: '#F0E68C', // 卡其色皮肤
                    mood: 'hopeful', // 心情：充满希望
                    description: '正在接受治愈的小外星人，眼神开始有光芒',
                    features: {
                        // 头部特征
                        head: 'large_round', // 大头圆脸
                        skin: 'light_peach', // 浅桃色皮肤
                        cheeks: 'light_pink', // 浅粉色腮红
                        
                        // 头发特征
                        hair: 'neat_orange', // 整齐橙色头发
                        hairStyle: 'curly_fluffy', // 卷曲蓬松
                        hairColor: '#FFB347', // 浅橙色
                        
                        // 眼睛特征
                        eyes: 'bright_green', // 明亮绿色眼睛
                        eyeColor: '#32CD32', // 酸橙绿
                        eyeGlow: 'subtle', // 轻微发光
                        eyeHighlights: 'small_white', // 小白高光
                        
                        // 触角特征
                        antennae: 'curved_yellow', // 弯曲黄色触角
                        antennaColor: '#FFD700', // 金黄色
                        antennaGlow: 'subtle', // 轻微发光
                        antennaTips: 'medium_sphere', // 中等球体
                        
                        // 耳朵特征
                        ears: 'round_oversized', // 圆形大耳朵
                        earColor: '#F0E68C', // 卡其色
                        
                        // 嘴巴特征
                        mouth: 'gentle_smile', // 温柔微笑
                        mouthColor: '#FF69B4', // 热粉色
                        
                        // 太空服特征
                        suit: 'light_futuristic', // 浅色未来风格
                        suitColor: '#FFFFFF', // 白色
                        suitAccents: 'light_blue', // 浅蓝色装饰
                        suitGlow: 'mint_green', // 薄荷绿发光
                        
                        // 背包特征
                        backpack: 'small_light', // 小浅色背包
                        
                        // 装饰特征
                        decorations: 'yellow_star', // 黄色星星
                        ribbons: 'none', // 无丝带
                        tubes: 'yellow_wavy', // 黄色波浪管
                        
                        // 鞋子特征
                        shoes: 'light_blue', // 浅蓝色鞋子
                        shoeColor: '#87CEEB', // 天蓝色
                        shoeAccents: 'white_sole', // 白色鞋底
                        
                        // 发光效果
                        glow: 'subtle_blue', // 轻微蓝色发光
                        aura: 'none', // 无光环
                        
                        // 表情特征
                        expression: 'hopeful_innocent', // 希望天真
                        energy: 'medium', // 中等能量
                        sparkle: 'subtle' // 轻微闪烁
                    }
                },
                'recovering': {
                    name: '康复中小外星人',
                    color: '#98FB98', // 淡绿色，代表生机
                    eyeColor: '#00FF7F', // 春绿色眼睛
                    skinColor: '#F5DEB3', // 小麦色皮肤
                    mood: 'growing', // 心情：成长
                    description: '逐渐康复的小外星人，开始重新热爱生活',
                    features: {
                        // 头部特征
                        head: 'large_round', // 大头圆脸
                        skin: 'light_peach', // 浅桃色皮肤
                        cheeks: 'rosy_pink', // 玫瑰粉色腮红
                        
                        // 头发特征
                        hair: 'styled_orange', // 造型橙色头发
                        hairStyle: 'voluminous_curly', // 蓬松卷曲
                        hairColor: '#FFA07A', // 浅鲑鱼色
                        
                        // 眼睛特征
                        eyes: 'vibrant_green', // 鲜艳绿色眼睛
                        eyeColor: '#00FF00', // 酸橙绿
                        eyeGlow: 'bright', // 明亮发光
                        eyeHighlights: 'large_white', // 大白高光
                        
                        // 触角特征
                        antennae: 'active_yellow', // 活跃黄色触角
                        antennaColor: '#FFD700', // 金黄色
                        antennaGlow: 'bright', // 明亮发光
                        antennaTips: 'large_sphere', // 大球体
                        
                        // 耳朵特征
                        ears: 'round_oversized', // 圆形大耳朵
                        earColor: '#F5DEB3', // 小麦色
                        
                        // 嘴巴特征
                        mouth: 'happy_smile', // 开心微笑
                        mouthColor: '#FF1493', // 深粉色
                        
                        // 太空服特征
                        suit: 'colorful_futuristic', // 彩色未来风格
                        suitColor: '#F0F8FF', // 爱丽丝蓝
                        suitAccents: 'pastel_colors', // 粉彩色装饰
                        suitGlow: 'mint_green', // 薄荷绿发光
                        
                        // 背包特征
                        backpack: 'medium_colorful', // 中等彩色背包
                        
                        // 装饰特征
                        decorations: 'colorful_patterns', // 彩色图案
                        ribbons: 'none', // 无丝带
                        tubes: 'colorful_wavy', // 彩色波浪管
                        
                        // 鞋子特征
                        shoes: 'colorful_blue', // 彩色蓝色鞋子
                        shoeColor: '#87CEEB', // 天蓝色
                        shoeAccents: 'colorful_details', // 彩色细节
                        
                        // 发光效果
                        glow: 'moderate_green', // 中等绿色发光
                        aura: 'subtle', // 轻微光环
                        
                        // 表情特征
                        expression: 'happy_innocent', // 开心天真
                        energy: 'high', // 高能量
                        sparkle: 'moderate' // 中等闪烁
                    }
                },
                'healed': {
                    name: '温暖治愈小外星人',
                    color: '#FFE4B5', // 莫卡辛色，代表温暖
                    eyeColor: '#20B2AA', // 湖绿色眼睛
                    skinColor: '#FFEFD5', // 桃色皮肤
                    mood: 'joyful', // 心情：快乐
                    description: '温暖治愈的小外星人，充满好奇和光芒',
                    features: {
                        // 头部特征
                        head: 'large_round', // 大头圆脸
                        skin: 'light_peach', // 浅桃色皮肤
                        cheeks: 'soft_pink', // 柔和粉色腮红
                        
                        // 头发特征 - 棉花糖般蓬松的淡橙色发型
                        hair: 'cotton_candy_orange', // 棉花糖橙色头发
                        hairStyle: 'dreamy_fluffy', // 梦幻蓬松状
                        hairColor: '#FFB347', // 淡橙色
                        hairTexture: 'cotton_candy', // 棉花糖质感
                        hairGlow: 'soft_warm', // 柔和温暖发光
                        
                        // 眼睛特征 - 湖绿色的明亮眼睛充满好奇光芒
                        eyes: 'curious_lake_green', // 好奇湖绿色眼睛
                        eyeColor: '#20B2AA', // 湖绿色
                        eyeGlow: 'bright_curious', // 明亮好奇发光
                        eyeHighlights: 'multiple_sparkling', // 多重闪烁高光
                        eyeExpression: 'wonder', // 好奇表情
                        
                        // 触角特征 - 金黄色发光触角轻盈摆动
                        antennae: 'floating_golden', // 轻盈摆动金黄色触角
                        antennaColor: '#FFD700', // 金黄色
                        antennaGlow: 'gentle_glow', // 柔和发光
                        antennaTips: 'floating_sphere', // 轻盈摆动球体
                        antennaMovement: 'gentle_sway', // 轻柔摆动
                        
                        // 耳朵特征 - 圆润的外星耳朵
                        ears: 'round_alien', // 圆润外星耳朵
                        earColor: '#FFEFD5', // 桃色
                        earShape: 'soft_rounded', // 柔软圆润
                        
                        // 嘴巴特征
                        mouth: 'gentle_happy_smile', // 温柔快乐微笑
                        mouthColor: '#FF69B4', // 热粉色
                        mouthExpression: 'warm', // 温暖表情
                        
                        // 太空服特征 - 梦幻童话风格的太空服饰
                        suit: 'dreamy_fairy_tale', // 梦幻童话风格
                        suitColor: '#FFFFFF', // 白色
                        suitAccents: 'dreamy_pastels', // 梦幻粉彩
                        suitGlow: 'fairy_tale_light', // 童话光芒
                        suitPattern: 'starry_dream', // 星空梦幻图案
                        
                        // 背包特征
                        backpack: 'dreamy_backpack', // 梦幻背包
                        backpackStyle: 'fairy_tale', // 童话风格
                        
                        // 装饰特征
                        decorations: 'dreamy_patterns', // 梦幻图案
                        ribbons: 'soft_cloud_ribbons', // 柔软云朵丝带
                        tubes: 'gentle_wavy', // 轻柔波浪管
                        floatingGems: 'sparkling_stars', // 闪烁星星宝石
                        
                        // 鞋子特征
                        shoes: 'dreamy_blue', // 梦幻蓝色鞋子
                        shoeColor: '#87CEEB', // 天蓝色
                        shoeAccents: 'dreamy_details', // 梦幻细节
                        
                        // 发光效果 - 柔和光影营造出治愈氛围
                        glow: 'warm_healing', // 温暖治愈发光
                        aura: 'gentle_healing', // 柔和治愈光环
                        lightRays: 'soft_warm', // 柔和温暖光线
                        
                        // 表情特征
                        expression: 'warm_curious', // 温暖好奇
                        energy: 'gentle_high', // 柔和高能量
                        sparkle: 'dreamy_sparkle', // 梦幻闪烁
                        mood: 'healing_wonder' // 治愈好奇心情
                    }
                },
                'radiant': {
                    name: '梦幻光芒小外星人',
                    color: '#FF69B4', // 热粉色，代表热情
                    eyeColor: '#20B2AA', // 湖绿色眼睛
                    skinColor: '#FFFACD', // 柠檬色皮肤
                    mood: 'radiant', // 心情：光芒四射
                    description: '梦幻光芒的小外星人，站在星光闪烁的温柔星球上',
                    features: {
                        // 头部特征
                        head: 'large_round', // 大头圆脸
                        skin: 'light_peach', // 浅桃色皮肤
                        cheeks: 'dreamy_glow', // 梦幻发光腮红
                        
                        // 头发特征 - 棉花糖般蓬松的淡橙色发型
                        hair: 'dreamy_cotton_candy', // 梦幻棉花糖头发
                        hairStyle: 'ethereal_fluffy', // 空灵蓬松状
                        hairColor: '#FFB347', // 淡橙色
                        hairTexture: 'cotton_candy_dream', // 梦幻棉花糖质感
                        hairGlow: 'ethereal_warm', // 空灵温暖发光
                        hairMovement: 'gentle_float', // 轻柔飘动
                        
                        // 眼睛特征 - 湖绿色的明亮眼睛充满好奇光芒
                        eyes: 'ethereal_lake_green', // 空灵湖绿色眼睛
                        eyeColor: '#20B2AA', // 湖绿色
                        eyeGlow: 'ethereal_curious', // 空灵好奇发光
                        eyeHighlights: 'ethereal_sparkling', // 空灵闪烁高光
                        eyeExpression: 'ethereal_wonder', // 空灵好奇表情
                        eyeSparkle: 'starry_dream', // 星空梦幻闪烁
                        
                        // 触角特征 - 金黄色发光触角轻盈摆动
                        antennae: 'ethereal_golden', // 空灵金黄色触角
                        antennaColor: '#FFD700', // 金黄色
                        antennaGlow: 'ethereal_glow', // 空灵发光
                        antennaTips: 'ethereal_sphere', // 空灵球体
                        antennaMovement: 'ethereal_sway', // 空灵摆动
                        antennaTrail: 'golden_sparkles', // 金色火花轨迹
                        
                        // 耳朵特征 - 圆润的外星耳朵
                        ears: 'ethereal_round', // 空灵圆润耳朵
                        earColor: '#FFFACD', // 柠檬色
                        earShape: 'ethereal_soft', // 空灵柔软
                        earGlow: 'gentle_ethereal', // 柔和空灵发光
                        
                        // 嘴巴特征
                        mouth: 'ethereal_smile', // 空灵微笑
                        mouthColor: '#FF1493', // 深粉色
                        mouthExpression: 'ethereal_warm', // 空灵温暖表情
                        mouthGlow: 'gentle_pink', // 柔和粉色发光
                        
                        // 太空服特征 - 梦幻童话风格的太空服饰
                        suit: 'ethereal_fairy_tale', // 空灵童话风格
                        suitColor: '#FFFFFF', // 白色
                        suitAccents: 'ethereal_pastels', // 空灵粉彩
                        suitGlow: 'ethereal_fairy_light', // 空灵童话光芒
                        suitPattern: 'ethereal_starry_dream', // 空灵星空梦幻图案
                        suitTexture: 'dreamy_silk', // 梦幻丝绸质感
                        
                        // 背包特征
                        backpack: 'ethereal_backpack', // 空灵背包
                        backpackStyle: 'ethereal_fairy_tale', // 空灵童话风格
                        backpackGlow: 'gentle_ethereal', // 柔和空灵发光
                        
                        // 装饰特征 - 周围漂浮着柔软云朵和发光宝石
                        decorations: 'ethereal_patterns', // 空灵图案
                        ribbons: 'ethereal_cloud_ribbons', // 空灵云朵丝带
                        tubes: 'ethereal_wavy', // 空灵波浪管
                        floatingGems: 'ethereal_sparkling_stars', // 空灵闪烁星星宝石
                        floatingClouds: 'soft_dreamy', // 柔软梦幻云朵
                        starTrails: 'ethereal_sparkle', // 空灵火花轨迹
                        
                        // 鞋子特征
                        shoes: 'ethereal_blue', // 空灵蓝色鞋子
                        shoeColor: '#87CEEB', // 天蓝色
                        shoeAccents: 'ethereal_details', // 空灵细节
                        shoeGlow: 'gentle_blue', // 柔和蓝色发光
                        
                        // 发光效果 - 柔和光影营造出治愈氛围
                        glow: 'ethereal_healing', // 空灵治愈发光
                        aura: 'ethereal_healing', // 空灵治愈光环
                        lightRays: 'ethereal_warm', // 空灵温暖光线
                        starField: 'gentle_twinkle', // 柔和闪烁星空
                        dreamMist: 'ethereal_float', // 空灵飘浮梦幻雾气
                        
                        // 表情特征
                        expression: 'ethereal_curious', // 空灵好奇
                        energy: 'ethereal_high', // 空灵高能量
                        sparkle: 'ethereal_sparkle', // 空灵闪烁
                        mood: 'ethereal_wonder', // 空灵好奇心情
                        dreamState: 'ethereal_peace' // 空灵平静状态
                    }
                }
            }
        };
        
        // 地面
        this.ground = {
            y: this.height - 50,
            height: 50,
            color: this.backgrounds.day.ground
        };
        
        // 障碍物数组 - 代表世界的舆论压力、负面评论和干扰DIMOO活下去的阻碍
        this.obstacles = [];
        this.gems = []; // 希望宝石数组 - 代表世界中的爱、温暖、鼓励和支持
        this.gemCount = 0; // 爱与希望宝石收集计数
        this.lastGemFeast = Date.now(); // 上次爱与希望盛宴时间
        this.gemFeastInterval = 15000; // 每15秒一次爱与希望盛宴（更频繁）
        this.lastMagnetTime = Date.now(); // 上次爱心磁铁生成时间
        this.magnetInterval = 45000; // 每45秒生成一次爱心磁铁
        this.isMagnetActive = false; // 爱心磁铁是否激活
        this.magnetStartTime = 0; // 爱心磁铁激活开始时间
        this.magnetDuration = 6000; // 爱心磁铁持续6秒
        // 宝石吸附动画系统
        this.attractingGems = []; // 正在被吸附的宝石数组
        this.magnetEffectRadius = 200; // 磁铁效果半径
        this.attractionSpeed = 8; // 吸附速度
        this.attractionAcceleration = 1.2; // 吸附加速度
        this.isEvolutionMode = false; // 进化姿态重生模式
        this.evolutionStartTime = 0; // 进化模式开始时间
        this.evolutionDuration = 3000; // 进化模式基础持续时间3秒
        this.evolutionType = 'rebirth'; // 进化类型：'rebirth' 或 'death'
        this.evolutionAnimationFrame = 0; // 动画帧数
        this.evolutionParticles = []; // 缓存粒子数据
        this.evolutionStars = []; // 缓存星星数据
        this.lastFrameTime = 0; // 上一帧时间
        this.frameCount = 0; // 帧数计数
        this.fps = 60; // 目标帧率
        // 治愈冲刺道具系统
        this.healingBoosters = []; // 治愈冲刺道具数组
        this.lastHealingBoosterTime = Date.now(); // 上次治愈冲刺道具生成时间
        this.healingBoosterInterval = 20000; // 每20秒生成一次治愈冲刺道具
        this.isHealingBoosterActive = false; // 治愈冲刺道具是否激活
        this.healingBoosterStartTime = 0; // 治愈冲刺道具激活开始时间
        this.healingBoosterDuration = 3000; // 治愈冲刺道具持续3秒
        this.healingBoosterSpeedMultiplier = 2.0; // 治愈冲刺速度倍数（当前速度的两倍）
        // 爱心道具系统
        this.heartItems = []; // 爱心道具数组
        this.lastHeartItemTime = Date.now(); // 上次爱心道具生成时间
        this.heartItemInterval = 30000; // 每30秒生成一次爱心道具
        // 成功治愈系统
        this.isVictoryMode = false; // 是否处于胜利模式
        this.victoryType = 'life'; // 胜利类型：'life' 或 'score'
        this.victoryStartTime = 0; // 胜利模式开始时间
        this.victoryDuration = 10000; // 胜利模式持续10秒
        this.victoryGems = []; // 胜利宝石数组
        
        // 得分倍数道具系统
        this.scoreMultipliers = []; // 得分倍数道具数组
        this.lastScoreMultiplierTime = Date.now(); // 上次生成得分倍数道具时间
        this.scoreMultiplierInterval = 20000; // 得分倍数道具生成间隔（20秒）
        this.isScoreMultiplierActive = false; // 是否处于得分倍数状态
        this.scoreMultiplierStartTime = 0; // 得分倍数开始时间
        this.scoreMultiplierDuration = 5000; // 得分倍数持续时间（5秒）
        this.scoreMultiplierValue = 1; // 当前得分倍数
        
        // 临时提示系统
        this.tempMessage = ''; // 临时提示信息
        this.tempMessageStartTime = 0; // 临时提示开始时间
        this.tempMessageDuration = 3000; // 临时提示持续时间（3秒）
        
        // 爱与希望盛宴状态系统
        this.isGemFeastActive = false; // 是否处于爱与希望盛宴状态
        this.gemFeastStartTime = 0; // 爱与希望盛宴开始时间
        this.gemFeastDuration = 5000; // 爱与希望盛宴持续时间（5秒）
        this.gemFeastSpeedMultiplier = 1.0; // 爱与希望盛宴期间宝石移动速度倍数
        
        // 删除暖心话语系统
        this.clouds = [];
        this.lastObstacleTime = 0;
        this.obstacleInterval = 1800; // 减少障碍物间隔，增加障碍物密度
        this.lastGemTime = 0;
        this.gemInterval = 800; // 宝石生成间隔（更频繁）
        
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
        // 键盘事件 - 优化控制逻辑，添加W和S键支持
        document.addEventListener('keydown', (e) => {
            if (e.code === 'Space' || e.code === 'ArrowUp' || e.code === 'KeyW') {
                e.preventDefault();
                if (!this.gameRunning && !this.gameOver && !this.isVictoryMode) {
                    this.startGame();
                } else if (this.gameRunning) {
                    this.handleJump();
                } else if (this.gameOver) {
                    this.restart();
                } else if (this.isVictoryMode) {
                    // 胜利状态下按空格键重新开始
                    this.restartFromVictory();
                }
            } else if ((e.code === 'ArrowDown' || e.code === 'KeyS') && this.gameRunning) {
                e.preventDefault();
                this.handleDownKey();
            }
        });
        
        document.addEventListener('keyup', (e) => {
            if (e.code === 'ArrowDown' || e.code === 'KeyS') {
                this.stopDuck();
            } else if (e.code === 'Space' || e.code === 'ArrowUp' || e.code === 'KeyW') {
                this.handleGlideRelease();
            }
        });
        
        // 鼠标/触摸事件
        this.canvas.addEventListener('click', () => {
            if (!this.gameRunning && !this.gameOver) {
                this.startGame();
            } else if (this.gameRunning) {
                this.handleJump();
            } else if (this.gameOver) {
                this.restart();
            }
        });
    }
    
    startGame() {
        console.log('startGame() 被调用');
        this.gameRunning = true;
        this.gameOver = false;
        this.score = 0;
        this.distance = 0; // 前进距离
        this.speed = 3;
        this.baseSpeed = 3; // 基础速度
        this.speedMultiplier = 1; // 速度倍数
        this.obstacles = [];
        this.gems = [];
        this.attractingGems = []; // 重置吸附宝石
        this.lastObstacleTime = Date.now();
        this.lastGemTime = Date.now();
        this.currentBackground = 'day';
        
        // 重置生命系统
        this.lives = 1;
        
        // 重置宝石系统
        this.gemCount = 0;
        
        // 重置胜利模式
        this.isVictoryMode = false;
        this.victoryGems = [];
        this.lastGemFeast = Date.now();
        this.lastMagnetTime = Date.now();
        this.isMagnetActive = false;
        
        // 重置无敌状态系统
        this.isInvincible = false;
        this.invincibleStartTime = 0;
        this.lastInvincibleCheck = Date.now();
        this.invincibleLevel = 1; // 重置无敌状态等级
        
        // 初始化胜利条件相关变量
        this.gameStartTime = Date.now(); // 游戏开始时间
        this.totalHealingTime = 0; // 累计治愈时间
        this.lastHealingStartTime = 0; // 上次治愈开始时间
        
        // 重置DIMOO状态
        this.resetDinoState();
        
        // 尝试隐藏游戏结束界面（如果存在）
        const gameOverElement = document.getElementById('gameOver');
        if (gameOverElement) {
            gameOverElement.style.display = 'none';
        }
        
        // 停止网络检测
        this.stopNetworkCheck();
        
        console.log('游戏启动完成，gameRunning:', this.gameRunning);
    }
    
    resetDinoState() {
        // 确保DIMOO正确站在地面上
        this.dimoo.y = this.height - 50 - this.dimoo.height;
        this.dimoo.velocityY = 0;
        this.dimoo.jumping = false;
        this.dimoo.ducking = false;
        this.dimoo.jumpCount = 0;
        this.dimoo.isGliding = false;
        this.dimoo.isGlideKeyPressed = false;
        this.dimoo.canFastFall = false;
        this.dimoo.animationFrame = 0;
        this.dimoo.isGlideReleased = false;
        this.dimoo.glideStartTime = 0;
        this.dimoo.glideDuration = 0;
        this.dimoo.walkCycle = 0;
        this.dimoo.legOffset = 0;
        this.dimoo.tailOffset = 0;
    }
    
    handleJump() {
        if (this.gameRunning) {
            // 如果在地面上，重置跳跃计数
            if (this.isOnGround()) {
                this.dimoo.jumpCount = 0;
                this.dimoo.isGliding = false;
                this.dimoo.canFastFall = false;
                this.dimoo.isGlideReleased = false;
            }
            
            // 检查是否可以跳跃
            if (this.dimoo.jumpCount < this.dimoo.maxJumps) {
                this.dimoo.jumpCount++;
                
                if (this.dimoo.jumpCount === 1) {
                    // 第一次跳跃 - 基于地面高度
                    this.dimoo.velocityY = this.dimoo.jumpVelocity;
                    this.dimoo.jumping = true;
                    this.dimoo.isGliding = false;
                    this.dimoo.canFastFall = true; // 跳跃后可以快速下落
                    // 添加滞空时间
                    setTimeout(() => {
                        if (this.dimoo.jumpCount === 1) {
                            this.dimoo.velocityY = 0; // 滞空保持高度
                        }
                    }, 200);
                } else if (this.dimoo.jumpCount === 2) {
                    // 第二次跳跃（双连跳）- 基于当前高度向上跳得更高
                    this.dimoo.velocityY = this.dimoo.doubleJumpVelocity;
                    this.dimoo.jumping = true;
                    this.dimoo.isGliding = false;
                    this.dimoo.canFastFall = true;
                    // 添加滞空时间
                    setTimeout(() => {
                        if (this.dimoo.jumpCount === 2) {
                            this.dimoo.velocityY = 0; // 滞空保持高度
                        }
                    }, 300);
                } else if (this.dimoo.jumpCount === 3) {
                    // 第三次跳跃改为滑翔
                    this.startGlide();
                }
            } else if (this.dimoo.jumpCount >= this.dimoo.maxJumps && this.dimoo.jumping) {
                // 第三段长按跳跃键触发滑翔
                this.startGlide();
            } else if (this.dimoo.jumpCount === 2 && this.dimoo.jumping) {
                // 两连跳时长按跳跃键也能触发滑翔
                this.startGlide();
            }
        }
    }
    
    handleDownKey() {
        if (this.gameRunning) {
            // 无论是否跳跃，按S键或↓键都触发下蹲形态
            if (this.dimoo.jumping) {
                // 跳跃时按下蹲键，立即改变为下蹲形态并加速下降
                this.duck();
                this.startFastFall();
            } else {
                // 地面上按下蹲键
                this.duck();
            }
        }
    }
    
    startGlide() {
        if (this.dimoo.jumping && !this.dimoo.isGliding) {
            this.dimoo.isGliding = true;
            this.dimoo.isGlideKeyPressed = true;
            this.dimoo.isGlideReleased = false;
            this.dimoo.glideStartTime = Date.now();
            this.dimoo.velocityY = Math.max(this.dimoo.velocityY, -1); // 限制上升速度
            console.log(`🦅 滑翔启动！跳跃次数：${this.dimoo.jumpCount}`);
        }
    }
    
    handleGlideRelease() {
        if (this.dimoo.isGliding) {
            this.dimoo.isGlideKeyPressed = false;
            this.dimoo.isGlideReleased = true;
            this.dimoo.glideDuration = Date.now() - this.dimoo.glideStartTime;
            console.log(`🦅 滑翔释放！跳跃次数：${this.dimoo.jumpCount}`);
        }
    }
    
    startFastFall() {
        this.dimoo.velocityY = Math.max(this.dimoo.velocityY, 10); // 快速下落
    }
    
    duck() {
        if (this.gameRunning) {
            this.dimoo.ducking = true;
            // 改变身体状态，确保能通过低空障碍物
            this.dimoo.height = this.dimoo.duckHeight;
            this.dimoo.y = this.height - 50 - this.dimoo.height; // 调整到地面上
        }
    }
    
    stopDuck() {
        this.dimoo.ducking = false;
        // 恢复原本身体姿态
        this.dimoo.height = this.dimoo.originalHeight;
        this.dimoo.y = this.height - 50 - this.dimoo.height; // 调整到地面上
    }
    
    isOnGround() {
        return this.dimoo.y >= this.height - 50 - this.dimoo.height;
    }
    
    restart() {
        this.resetDinoState();
        this.startGame();
    }
    
    restartFromVictory() {
        // 从胜利状态重新开始游戏
        this.isVictoryMode = false;
        this.victoryGems = [];
        this.lifeScreenAnimation = null; // 清除动态效果
        this.startGame();
        console.log('🎉 从胜利状态重新开始游戏！');
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
        // 随机决定是否生成密集负面干扰（15%概率）
        if (Math.random() < 0.15) {
            this.generateDenseObstacles();
            return;
        }
        
        // 障碍物代表生活中的负面干扰和舆论压力
        const types = ['negative_comment', 'gossip', 'criticism', 'judgment', 'bullying', 'isolation', 'self_doubt', 'anxiety', 'depression', 'loneliness', 'pressure', 'expectation', 'comparison', 'failure', 'rejection', 'betrayal', 'rumor', 'slander', 'mockery', 'exclusion', 'cynicism', 'pessimism', 'despair', 'hopelessness', 'darkness', 'staircase', 'hanging_stick', 'ground_spike', 'simple_rock', 'simple_branch', 'simple_log'];
        const typeWeights = [0.08, 0.06, 0.04, 0.04, 0.04, 0.04, 0.03, 0.03, 0.03, 0.03, 0.04, 0.03, 0.02, 0.02, 0.02, 0.06, 0.02, 0.02, 0.02, 0.02, 0.05, 0.05, 0.04, 0.03, 0.04, 0.06, 0.12, 0.12, 0.08, 0.08, 0.08]; // 各种负面干扰的权重，简单障碍物权重更高
        const random = Math.random();
        let cumulativeWeight = 0;
        let selectedType = 'negative_comment';
        
        for (let i = 0; i < types.length; i++) {
            cumulativeWeight += typeWeights[i];
            if (random < cumulativeWeight) {
                selectedType = types[i];
                break;
            }
        }
        
        let obstacle = {
            x: this.width + Math.random() * 300 + 150,
            type: selectedType,
            width: 0,
            height: 0,
            color: '#228B22'
        };
        
        switch (selectedType) {
            case 'negative_comment':
                obstacle.width = 25;
                obstacle.height = 60;
                obstacle.color = '#8B0000'; // 深红色，代表伤害性言论
                obstacle.y = this.height - 110;
                break;
            case 'gossip':
                obstacle.width = 40;
                obstacle.height = 25;
                obstacle.color = '#FF6347'; // 橙红色，代表流言蜚语
                const heightLevel = Math.random();
                if (heightLevel < 0.4) {
                    obstacle.y = this.height - 120; // 低空
                } else if (heightLevel < 0.7) {
                    obstacle.y = this.height - 140; // 中空
                } else {
                    obstacle.y = this.height - 160; // 高空
                }
                break;
            case 'criticism':
                obstacle.width = 35;
                obstacle.height = 30;
                obstacle.color = '#696969'; // 灰色，代表批评
                obstacle.y = this.height - 80;
                break;
            case 'judgment':
                obstacle.width = 30;
                obstacle.height = 80;
                obstacle.color = '#228B22'; // 深绿色，代表评判
                obstacle.y = this.height - 130;
                break;
            case 'flying_saucer':
                obstacle.width = 50;
                obstacle.height = 20;
                obstacle.color = '#4169E1';
                obstacle.y = this.height - 150;
                break;
            case 'meteor':
                obstacle.width = 30;
                obstacle.height = 30;
                obstacle.color = '#FF4500';
                obstacle.y = this.height - 180; // 高空陨石
                break;
            case 'laser':
                obstacle.width = 5;
                obstacle.height = 100;
                obstacle.color = '#FF0000';
                obstacle.y = this.height - 200; // 高空激光
                break;
            case 'trap':
                obstacle.width = 40;
                obstacle.height = 10;
                obstacle.color = '#8B0000';
                obstacle.y = this.height - 60; // 地面陷阱
                break;
            case 'fake_coin':
                obstacle.width = 20;
                obstacle.height = 20;
                obstacle.color = '#FFD700';
                obstacle.y = this.height - 140; // 中空假金币
                break;
            case 'spike_ball':
                obstacle.width = 25;
                obstacle.height = 25;
                obstacle.color = '#4A4A4A';
                obstacle.y = this.height - 160; // 高空尖刺球
                break;
            case 'floating_platform':
                obstacle.width = 60;
                obstacle.height = 15;
                obstacle.color = '#8B4513';
                obstacle.y = this.height - 180; // 高空浮动平台
                obstacle.isPlatform = true; // 标记为平台，不会减少生命
                break;
            case 'moving_wall':
                obstacle.width = 20;
                obstacle.height = 120;
                obstacle.color = '#696969';
                obstacle.y = this.height - 170; // 移动墙壁
                obstacle.moving = true;
                obstacle.moveSpeed = 2;
                obstacle.moveDirection = 1;
                break;
            case 'energy_field':
                obstacle.width = 40;
                obstacle.height = 80;
                obstacle.color = '#00FFFF';
                obstacle.y = this.height - 130; // 能量场
                obstacle.isEnergyField = true;
                break;
            case 'time_bomb':
                obstacle.width = 20;
                obstacle.height = 20;
                obstacle.color = '#FF4500';
                obstacle.y = this.height - 140; // 定时炸弹
                obstacle.isTimeBomb = true;
                obstacle.explodeTime = Date.now() + 3000; // 3秒后爆炸
                break;
            case 'gravity_well':
                obstacle.width = 30;
                obstacle.height = 30;
                obstacle.color = '#800080';
                obstacle.y = this.height - 150; // 重力井
                obstacle.isGravityWell = true;
                break;
            case 'narrow_gap':
                // 狭窄间隙 - 只能通过下蹲通过
                obstacle.width = 40;
                obstacle.height = 80;
                obstacle.color = '#8B0000';
                obstacle.y = this.height - 130; // 高空间隙
                obstacle.isNarrowGap = true;
                break;
            case 'teleporter':
                // 传送门 - 随机传送到不同位置
                obstacle.width = 35;
                obstacle.height = 35;
                obstacle.color = '#00CED1';
                obstacle.y = this.height - 140; // 传送门
                obstacle.isTeleporter = true;
                break;
            case 'mirror_wall':
                // 镜像墙 - 反射移动方向
                obstacle.width = 25;
                obstacle.height = 100;
                obstacle.color = '#C0C0C0';
                obstacle.y = this.height - 150; // 镜像墙
                obstacle.isMirrorWall = true;
                break;
            case 'black_hole':
                // 黑洞 - 吸引玩家
                obstacle.width = 40;
                obstacle.height = 40;
                obstacle.color = '#000000';
                obstacle.y = this.height - 160; // 黑洞
                obstacle.isBlackHole = true;
                break;
            case 'speed_trap':
                // 速度陷阱 - 根据速度调整难度
                obstacle.width = 50;
                obstacle.height = 60;
                obstacle.color = '#FF4500';
                obstacle.y = this.height - 120; // 速度陷阱
                obstacle.isSpeedTrap = true;
                break;
            case 'flying_dragon':
                // 飞行龙 - 高空飞行物
                obstacle.width = 60;
                obstacle.height = 30;
                obstacle.color = '#8B0000';
                obstacle.y = this.height - 200; // 高空飞行龙
                obstacle.isFlyingDragon = true;
                obstacle.wingFlap = 0; // 翅膀扇动动画
                break;
            case 'hanging_vine':
                // 吊着的藤蔓 - 从顶部垂下的长障碍物
                obstacle.width = 15;
                obstacle.height = 120;
                obstacle.color = '#228B22';
                obstacle.y = 50; // 从顶部开始
                obstacle.isHangingVine = true;
                obstacle.swingOffset = 0; // 摆动动画
                break;
            case 'floating_rock':
                // 浮空岩石 - 中高空漂浮
                obstacle.width = 40;
                obstacle.height = 35;
                obstacle.color = '#696969';
                obstacle.y = this.height - 180; // 高空浮石
                obstacle.isFloatingRock = true;
                obstacle.floatOffset = 0; // 浮动动画
                break;
            case 'air_tornado':
                // 空中龙卷风 - 旋转的空中障碍物
                obstacle.width = 30;
                obstacle.height = 80;
                obstacle.color = '#87CEEB';
                obstacle.y = this.height - 220; // 高空龙卷风
                obstacle.isAirTornado = true;
                obstacle.rotation = 0; // 旋转动画
                break;
            case 'hanging_spider':
                // 吊着的蜘蛛 - 从顶部垂下的蜘蛛网
                obstacle.width = 25;
                obstacle.height = 100;
                obstacle.color = '#8B4513';
                obstacle.y = 30; // 从顶部开始
                obstacle.isHangingSpider = true;
                obstacle.webSwing = 0; // 蛛网摆动动画
                break;
            case 'staircase':
                // 阶梯障碍 - 需要连续跳跃才能通过
                obstacle.width = 40;
                obstacle.height = 60;
                obstacle.color = '#8B4513';
                obstacle.y = this.height - 120;
                obstacle.isStaircase = true;
                obstacle.stairLevel = Math.floor(Math.random() * 3) + 1; // 1-3级阶梯
                break;
            case 'hanging_stick':
                // 从天上吊着的长木棍 - 优化长度，只留出刚好一个身位
                obstacle.width = 8;
                obstacle.height = 120 + Math.random() * 60; // 120-180像素长，增加长度
                obstacle.color = '#8B4513'; // 棕色
                        // 计算位置，确保只留出刚好一个DIMOO身位（约45像素）
        const dinoHeight = 45; // DIMOO高度
                const gapHeight = dinoHeight + 10; // 留出10像素缓冲
                const maxY = this.height - 100 - gapHeight; // 最大Y位置
                const minY = 50; // 最小Y位置
                obstacle.y = minY + Math.random() * (maxY - minY); // 随机位置，但确保留出通过空间
                obstacle.isHangingStick = true;
                break;
            case 'ground_spike':
                // 地上长出的倒刺
                obstacle.width = 15;
                obstacle.height = 30 + Math.random() * 20; // 30-50像素高
                obstacle.color = '#696969'; // 灰色
                obstacle.y = this.height - (30 + Math.random() * 20); // 从地面长出
                obstacle.isGroundSpike = true;
                break;
            case 'simple_rock':
                // 简单石头
                obstacle.width = 25 + Math.random() * 15; // 25-40像素宽
                obstacle.height = 20 + Math.random() * 15; // 20-35像素高
                obstacle.color = '#696969'; // 灰色
                obstacle.y = this.height - (20 + Math.random() * 15);
                obstacle.isSimpleRock = true;
                break;
            case 'simple_branch':
                // 简单树枝
                obstacle.width = 30 + Math.random() * 20; // 30-50像素宽
                obstacle.height = 8;
                obstacle.color = '#8B4513'; // 棕色
                const branchHeight = Math.random();
                if (branchHeight < 0.4) {
                    obstacle.y = this.height - 120; // 低空
                } else if (branchHeight < 0.7) {
                    obstacle.y = this.height - 140; // 中空
                } else {
                    obstacle.y = this.height - 160; // 高空
                }
                obstacle.isSimpleBranch = true;
                break;
            case 'simple_log':
                // 简单木桩
                obstacle.width = 20;
                obstacle.height = 40 + Math.random() * 30; // 40-70像素高
                obstacle.color = '#8B4513'; // 棕色
                obstacle.y = this.height - (40 + Math.random() * 30);
                obstacle.isSimpleLog = true;
                break;
        }
        
        // 根据速度调整障碍物尺寸
        const speedMultiplier = Math.min(this.speedMultiplier / 5, 2); // 速度倍数影响，最大2倍
        obstacle.width = Math.floor(obstacle.width * (1 + speedMultiplier * 0.1));
        obstacle.height = Math.floor(obstacle.height * (1 + speedMultiplier * 0.1));
        
        this.obstacles.push(obstacle);
    }
    
    generateDenseObstacles() {
        // 生成密集高难度障碍物组合
        const baseX = this.width + Math.random() * 200 + 100;
        const obstacleCount = 3 + Math.floor(Math.random() * 4); // 3-6个障碍物
        
        for (let i = 0; i < obstacleCount; i++) {
            const types = ['laser', 'meteor', 'spike_ball', 'flying_dragon', 'air_tornado'];
            const selectedType = types[Math.floor(Math.random() * types.length)];
            
            let obstacle = {
                x: baseX + i * 80 + Math.random() * 40,
                type: selectedType,
                width: 0,
                height: 0,
                color: '#FF0000'
            };
            
            // 随机分布在各个高度
            const heightLevel = Math.random();
            let obstacleY;
            
            if (heightLevel < 0.2) {
                obstacleY = 50 + Math.random() * 60; // 屏幕顶部
            } else if (heightLevel < 0.4) {
                obstacleY = this.height - 200 + Math.random() * 80; // 高空
            } else if (heightLevel < 0.6) {
                obstacleY = this.height - 150 + Math.random() * 60; // 中空
            } else if (heightLevel < 0.8) {
                obstacleY = this.height - 120 + Math.random() * 40; // 低空
            } else {
                obstacleY = this.height - 80; // 地面
            }
            
            switch (selectedType) {
                case 'laser':
                    obstacle.width = 5;
                    obstacle.height = 120;
                    obstacle.color = '#FF0000';
                    obstacle.y = obstacleY;
                    break;
                case 'meteor':
                    obstacle.width = 35;
                    obstacle.height = 35;
                    obstacle.color = '#FF4500';
                    obstacle.y = obstacleY;
                    break;
                case 'spike_ball':
                    obstacle.width = 30;
                    obstacle.height = 30;
                    obstacle.color = '#4A4A4A';
                    obstacle.y = obstacleY;
                    break;
                case 'flying_dragon':
                    obstacle.width = 65;
                    obstacle.height = 35;
                    obstacle.color = '#8B0000';
                    obstacle.y = obstacleY;
                    obstacle.isFlyingDragon = true;
                    obstacle.wingFlap = 0;
                    break;
                case 'air_tornado':
                    obstacle.width = 35;
                    obstacle.height = 85;
                    obstacle.color = '#87CEEB';
                    obstacle.y = obstacleY;
                    obstacle.isAirTornado = true;
                    obstacle.rotation = 0;
                    break;
            }
            
            this.obstacles.push(obstacle);
        }
    }
    
    generateGem() {
        const gemPatterns = ['single', 'line', 'heart', 'star', 'circle', 'triangle', 'diamond'];
        const pattern = gemPatterns[Math.floor(Math.random() * gemPatterns.length)];
        
        // 根据速度和状态调整宝石生成概率
        let gemProbability = 0.35; // 基础概率（提高）
        if (this.speedMultiplier > 15) {
            gemProbability = 0.6; // 高速时增加宝石生成概率（提高）
        } else if (this.speedMultiplier < 1) {
            gemProbability = 0.2; // 低速时减少宝石生成概率（提高）
        }
        
        // 凋零阶段大幅增加宝石生成概率
        if (this.isEvolutionMode && this.evolutionType === 'death') {
            gemProbability = 0.8; // 凋零阶段80%概率生成宝石图案（提高）
        }
        
        // 随机决定是否生成希望图案
        if (Math.random() < gemProbability) {
            this.generateGemPattern(pattern);
        } else {
            this.generateSingleGem();
        }
        
        // 额外生成宝石数量也根据速度和状态调整
        let extraGems = 1; // 基础额外宝石数量（提高）
        if (this.speedMultiplier > 15) {
            extraGems = Math.floor(Math.random() * 5) + 2; // 高速时更多宝石（提高）
        } else if (this.speedMultiplier < 1) {
            extraGems = Math.floor(Math.random() * 2) + 0; // 低速时较少宝石（提高）
        } else {
            extraGems = Math.floor(Math.random() * 3) + 1; // 正常速度（提高）
        }
        
        // 凋零阶段大幅增加额外宝石数量
        if (this.isEvolutionMode && this.evolutionType === 'death') {
            extraGems = Math.floor(Math.random() * 6) + 3; // 凋零阶段3-8个额外宝石（提高）
        }
        
        for (let i = 0; i < extraGems; i++) {
            this.generateSingleGem();
        }
    }
    
    generateSingleGem() {
        const gemTypes = ['ground', 'air', 'high_air', 'top_air'];
        const type = gemTypes[Math.floor(Math.random() * gemTypes.length)];
        
        const gemType = this.getGemColor();
        let gem = {
            x: this.width + Math.random() * 300 + 100,
            type: type,
            width: 15,
            height: 15,
            color: gemType.color,
            value: gemType.value,
            name: gemType.name,
            collected: false,
            sparkle: 0
        };
        
        switch (type) {
            case 'ground':
                gem.y = this.height - 80; // 地面宝石
                break;
            case 'air':
                gem.y = this.height - 120 + Math.random() * 60; // 低空随机
                break;
            case 'high_air':
                gem.y = this.height - 180 + Math.random() * 40; // 高空随机
                break;
            case 'top_air':
                gem.y = 50 + Math.random() * 80; // 屏幕顶部随机
                break;
        }
        
        this.gems.push(gem);
    }
    
    generateGemPattern(pattern) {
        const baseX = this.width + Math.random() * 200 + 100;
        const baseY = this.height - 200 + Math.random() * 150;
        
        switch (pattern) {
            case 'line':
                // 水平线宝石
                for (let i = 0; i < 8; i++) {
                    const gemType = this.getGemColor();
                    this.gems.push({
                        x: baseX + i * 20,
                        y: baseY,
                        width: 15,
                        height: 15,
                        color: gemType.color,
                        value: gemType.value,
                        name: gemType.name,
                        collected: false,
                        sparkle: 0
                    });
                }
                break;
            case 'heart':
                // 爱心图案
                const heartPoints = [
                    [0, 0], [1, 0], [2, 0], [3, 0], [4, 0], [5, 0], [6, 0],
                    [0, 1], [1, 1], [2, 1], [3, 1], [4, 1], [5, 1], [6, 1],
                    [0, 2], [1, 2], [2, 2], [3, 2], [4, 2], [5, 2], [6, 2],
                    [1, 3], [2, 3], [3, 3], [4, 3], [5, 3],
                    [2, 4], [3, 4], [4, 4],
                    [3, 5]
                ];
                heartPoints.forEach(([dx, dy]) => {
                    const gemType = this.getGemColor();
                    this.gems.push({
                        x: baseX + dx * 15,
                        y: baseY + dy * 15,
                        width: 15,
                        height: 15,
                        color: gemType.color,
                        value: gemType.value,
                        name: gemType.name,
                        collected: false,
                        sparkle: 0
                    });
                });
                break;
            case 'star':
                // 星星图案
                const starPoints = [
                    [2, 0], [1, 1], [3, 1], [0, 2], [4, 2],
                    [1, 3], [3, 3], [2, 4]
                ];
                starPoints.forEach(([dx, dy]) => {
                    this.gems.push({
                        x: baseX + dx * 15,
                        y: baseY + dy * 15,
                        width: 15,
                        height: 15,
                        color: '#FFD700', // 金色星星
                        collected: false,
                        sparkle: 0
                    });
                });
                break;
            case 'circle':
                // 圆形图案
                for (let angle = 0; angle < Math.PI * 2; angle += Math.PI / 8) {
                    const radius = 30;
                    this.gems.push({
                        x: baseX + Math.cos(angle) * radius,
                        y: baseY + Math.sin(angle) * radius,
                        width: 15,
                        height: 15,
                        color: this.getGemColor(),
                        collected: false,
                        sparkle: 0
                    });
                }
                break;
            case 'triangle':
                // 三角形图案
                for (let row = 0; row < 5; row++) {
                    for (let col = 0; col <= row; col++) {
                        this.gems.push({
                            x: baseX + col * 15 - row * 7.5,
                            y: baseY + row * 15,
                            width: 15,
                            height: 15,
                            color: this.getGemColor(),
                            collected: false,
                            sparkle: 0
                        });
                    }
                }
                break;
            case 'diamond':
                // 钻石图案
                const diamondPoints = [
                    [2, 0], [1, 1], [3, 1], [0, 2], [4, 2],
                    [1, 3], [3, 3], [2, 4]
                ];
                diamondPoints.forEach(([dx, dy]) => {
                    this.gems.push({
                        x: baseX + dx * 15,
                        y: baseY + dy * 15,
                        width: 15,
                        height: 15,
                        color: '#00CED1', // 青色钻石
                        collected: false,
                        sparkle: 0
                    });
                });
                break;
        }
    }
    
    getGemColor() {
        // 宝石价值系统：不同颜色代表不同价值
        const gemTypes = [
            { color: '#FFD700', value: 1, name: '金色宝石', probability: 0.4 },    // 金色：普通宝石
            { color: '#FF69B4', value: 1, name: '粉色宝石', probability: 0.3 },    // 粉色：普通宝石
            { color: '#00CED1', value: 2, name: '青色宝石', probability: 0.15 },   // 青色：2倍价值
            { color: '#FF6347', value: 2, name: '红色宝石', probability: 0.1 },    // 红色：2倍价值
            { color: '#32CD32', value: 3, name: '绿色宝石', probability: 0.03 },   // 绿色：3倍价值
            { color: '#FF8C00', value: 4, name: '橙色宝石', probability: 0.015 },  // 橙色：4倍价值
            { color: '#9370DB', value: 5, name: '紫色宝石', probability: 0.005 }   // 紫色：5倍价值（稀有）
        ];
        
        // 根据概率选择宝石类型
        const random = Math.random();
        let cumulativeProbability = 0;
        
        for (const gemType of gemTypes) {
            cumulativeProbability += gemType.probability;
            if (random <= cumulativeProbability) {
                return gemType;
            }
        }
        
        // 默认返回金色宝石
        return gemTypes[0];
    }
    
    generateGemFeast() {
        // 生成大范围的希望盛宴，覆盖半个屏幕
        const feastPatterns = ['spiral', 'wave', 'grid', 'diamond_field', 'rainbow_path', 'text_message', 'warm_hearts', 'encouraging_words', 'butterfly', 'starry_night', 'flower_garden', 'mountain_range', 'ocean_waves', 'forest_path', 'city_lights', 'aurora_borealis', 'warm_words', 'love_message', 'hope_stars', 'dream_clouds', 'rainbow_bridge', 'crystal_tower', 'music_notes', 'angel_wings', 'healing_words', 'life_meaning', 'future_hope', 'inner_strength', 'love_yourself', 'never_give_up', 'beautiful_life', 'peaceful_mind', 'courage_heart', 'gentle_soul', 'bright_future', 'warm_embrace', 'healing_light', 'hope_springs', 'love_conquers', 'life_is_beautiful', 'you_are_worthy', 'dream_big', 'shine_bright', 'peace_love', 'healing_power', 'life_goals', 'hope_eternal'];
        const pattern = feastPatterns[Math.floor(Math.random() * feastPatterns.length)];
        
        switch (pattern) {
            case 'spiral':
                this.generateSpiralFeast();
                break;
            case 'wave':
                this.generateWaveFeast();
                break;
            case 'grid':
                this.generateGridFeast();
                break;
            case 'diamond_field':
                this.generateDiamondFieldFeast();
                break;
            case 'rainbow_path':
                this.generateRainbowPathFeast();
                break;
            case 'text_message':
                this.generateTextMessageFeast();
                break;
            case 'warm_hearts':
                this.generateWarmHeartsFeast();
                break;
            case 'encouraging_words':
                this.generateEncouragingWordsFeast();
                break;
            case 'butterfly':
                this.generateButterflyFeast();
                break;
            case 'starry_night':
                this.generateStarryNightFeast();
                break;
            case 'flower_garden':
                this.generateFlowerGardenFeast();
                break;
            case 'mountain_range':
                this.generateMountainRangeFeast();
                break;
            case 'ocean_waves':
                this.generateOceanWavesFeast();
                break;
            case 'forest_path':
                this.generateForestPathFeast();
                break;
            case 'city_lights':
                this.generateCityLightsFeast();
                break;
            case 'aurora_borealis':
                this.generateAuroraBorealisFeast();
                break;
            case 'warm_words':
                this.generateWarmWordsFeast();
                break;
            case 'love_message':
                this.generateLoveMessageFeast();
                break;
            case 'hope_stars':
                this.generateHopeStarsFeast();
                break;
            case 'dream_clouds':
                this.generateDreamCloudsFeast();
                break;
            case 'rainbow_bridge':
                this.generateRainbowBridgeFeast();
                break;
            case 'crystal_tower':
                this.generateCrystalTowerFeast();
                break;
            case 'music_notes':
                this.generateMusicNotesFeast();
                break;
            case 'angel_wings':
                this.generateAngelWingsFeast();
                break;
            case 'healing_words':
                this.generateHealingWordsFeast();
                break;
            case 'life_meaning':
                this.generateLifeMeaningFeast();
                break;
            case 'future_hope':
                this.generateFutureHopeFeast();
                break;
            case 'inner_strength':
                this.generateInnerStrengthFeast();
                break;
            case 'love_yourself':
                this.generateLoveYourselfFeast();
                break;
            case 'never_give_up':
                this.generateNeverGiveUpFeast();
                break;
            case 'beautiful_life':
                this.generateBeautifulLifeFeast();
                break;
            case 'peaceful_mind':
                this.generatePeacefulMindFeast();
                break;
            case 'courage_heart':
                this.generateCourageHeartFeast();
                break;
            case 'gentle_soul':
                this.generateGentleSoulFeast();
                break;
            case 'bright_future':
                this.generateBrightFutureFeast();
                break;
            case 'warm_embrace':
                this.generateWarmEmbraceFeast();
                break;
            case 'healing_light':
                this.generateHealingLightFeast();
                break;
            case 'hope_springs':
                this.generateHopeSpringsFeast();
                break;
            case 'love_conquers':
                this.generateLoveConquersFeast();
                break;
            case 'life_is_beautiful':
                this.generateLifeIsBeautifulFeast();
                break;
            case 'you_are_worthy':
                this.generateYouAreWorthyFeast();
                break;
            case 'dream_big':
                this.generateDreamBigFeast();
                break;
            case 'shine_bright':
                this.generateShineBrightFeast();
                break;
            case 'peace_love':
                this.generatePeaceLoveFeast();
                break;
            case 'healing_power':
                this.generateHealingPowerFeast();
                break;
            case 'life_goals':
                this.generateLifeGoalsFeast();
                break;
            case 'hope_eternal':
                this.generateHopeEternalFeast();
                break;
        }
    }
    
    generateSpiralFeast() {
        // 螺旋形宝石盛宴
        const centerX = this.width + 200;
        const centerY = this.height / 2;
        const radius = 100;
        const spacing = 15; // 减少间距，增加宝石数量
        
        for (let angle = 0; angle < Math.PI * 8; angle += 0.2) { // 增加螺旋圈数和密度
            const r = radius + angle * 8;
            const x = centerX + Math.cos(angle) * r;
            const y = centerY + Math.sin(angle) * r;
            
            if (y > 50 && y < this.height - 100) {
                this.gems.push({
                    x: x,
                    y: y,
                    width: 15,
                    height: 15,
                    color: this.getGemColor(),
                    collected: false,
                    sparkle: 0
                });
            }
        }
    }
    
    generateWaveFeast() {
        // 波浪形宝石盛宴
        const startX = this.width + 100;
        const amplitude = 80;
        const frequency = 0.02;
        
        for (let x = 0; x < 500; x += 12) { // 增加宽度和密度
            const waveY = this.height / 2 + Math.sin(x * frequency) * amplitude;
            const gemX = startX + x;
            
            if (waveY > 50 && waveY < this.height - 100) {
                this.gems.push({
                    x: gemX,
                    y: waveY,
                    width: 15,
                    height: 15,
                    color: this.getGemColor(),
                    collected: false,
                    sparkle: 0
                });
            }
        }
    }
    
    generateGridFeast() {
        // 网格形宝石盛宴
        const startX = this.width + 100;
        const startY = 100;
        const spacing = 20; // 减少间距，增加宝石数量
        
        for (let x = 0; x < 400; x += spacing) { // 增加宽度
            for (let y = 0; y < this.height - 200; y += spacing) {
                this.gems.push({
                    x: startX + x,
                    y: startY + y,
                    width: 15,
                    height: 15,
                    color: this.getGemColor(),
                    collected: false,
                    sparkle: 0
                });
            }
        }
    }
    
    generateDiamondFieldFeast() {
        // 钻石田宝石盛宴
        const startX = this.width + 100;
        const startY = 100;
        const spacing = 25; // 减少间距，增加宝石数量
        
        for (let row = 0; row < 12; row++) { // 增加行数
            for (let col = 0; col < 10; col++) { // 增加列数
                const x = startX + col * spacing + (row % 2) * spacing / 2;
                const y = startY + row * spacing;
                
                if (y < this.height - 100) {
                    this.gems.push({
                        x: x,
                        y: y,
                        width: 15,
                        height: 15,
                        color: this.getGemColor(),
                        collected: false,
                        sparkle: 0
                    });
                }
            }
        }
    }
    
    generateRainbowPathFeast() {
        // 彩虹路径宝石盛宴
        const colors = ['#FF0000', '#FF7F00', '#FFFF00', '#00FF00', '#0000FF', '#4B0082', '#9400D3'];
        const startX = this.width + 100;
        const pathWidth = 300; // 增加路径宽度
        
        for (let x = 0; x < pathWidth; x += 10) { // 减少间距，增加宝石数量
            const pathY = this.height / 2 + Math.sin(x * 0.02) * 60;
            const colorIndex = Math.floor((x / pathWidth) * colors.length) % colors.length;
            
            if (pathY > 50 && pathY < this.height - 100) {
                this.gems.push({
                    x: startX + x,
                    y: pathY,
                    width: 15,
                    height: 15,
                    color: colors[colorIndex],
                    collected: false,
                    sparkle: 0
                });
            }
        }
    }
    
    generateTextMessageFeast() {
        // 巨型文字希望盛宴 - 治愈的话语
        const messages = [
            'YOU MATTER!',
            'YOU ARE LOVED!',
            'YOU ARE ENOUGH!',
            'YOU ARE WORTHY!',
            'YOU ARE BEAUTIFUL!',
            'YOU ARE STRONG!',
            'YOU ARE BRAVE!',
            'YOU ARE KIND!',
            'YOU ARE SPECIAL!',
            'YOU ARE UNIQUE!',
            'DON T GIVE UP!',
            'KEEP GOING!',
            'STAY STRONG!',
            'YOU CAN DO IT!',
            'BELIEVE IN YOURSELF!',
            'YOU ARE AMAZING!',
            'YOU ARE INCREDIBLE!',
            'YOU ARE FANTASTIC!',
            'YOU ARE BRILLIANT!',
            'YOU ARE OUTSTANDING!',
            'YOU ARE PHENOMENAL!',
            'YOU ARE EXTRAORDINARY!',
            'YOU ARE WONDERFUL!',
            'YOU ARE MAGNIFICENT!',
            'YOU ARE SPECTACULAR!',
            'YOU ARE REMARKABLE!',
            'YOU ARE EXCEPTIONAL!',
            'YOU ARE FABULOUS!',
            'YOU ARE TERRIFIC!',
            'YOU ARE SENSATIONAL!',
            'YOU ARE MARVELOUS!',
            'YOU ARE GLORIOUS!',
            'YOU ARE SPLENDID!',
            'YOU ARE MAGICAL!',
            'YOU ARE INSPIRING!',
            'YOU ARE MOTIVATING!',
            'YOU ARE ENCOURAGING!',
            'YOU ARE UPLIFTING!',
            'YOU ARE HEALING!',
            'YOU ARE BLESSED!'
        ];
        
        const message = messages[Math.floor(Math.random() * messages.length)];
        const startX = this.width + 150;
        const startY = this.height / 2 - 100;
        const letterSpacing = 25;
        const lineHeight = 30;
        
        // 定义字母的点阵图案
        const letterPatterns = {
            'A': [
                [0,1,1,0],
                [1,0,0,1],
                [1,1,1,1],
                [1,0,0,1],
                [1,0,0,1]
            ],
            'W': [
                [1,0,0,1],
                [1,0,0,1],
                [1,0,0,1],
                [1,0,0,1],
                [1,1,1,1]
            ],
            'E': [
                [1,1,1,1],
                [1,0,0,0],
                [1,1,1,0],
                [1,0,0,0],
                [1,1,1,1]
            ],
            'S': [
                [0,1,1,1],
                [1,0,0,0],
                [0,1,1,0],
                [0,0,0,1],
                [1,1,1,0]
            ],
            'O': [
                [0,1,1,0],
                [1,0,0,1],
                [1,0,0,1],
                [1,0,0,1],
                [0,1,1,0]
            ],
            'M': [
                [1,0,0,1],
                [1,1,1,1],
                [1,0,0,1],
                [1,0,0,1],
                [1,0,0,1]
            ],
            'I': [
                [1,1,1,1],
                [0,1,0,0],
                [0,1,0,0],
                [0,1,0,0],
                [1,1,1,1]
            ],
            'N': [
                [1,0,0,1],
                [1,1,0,1],
                [1,0,1,1],
                [1,0,0,1],
                [1,0,0,1]
            ],
            'G': [
                [0,1,1,1],
                [1,0,0,0],
                [1,0,1,1],
                [1,0,0,1],
                [0,1,1,0]
            ],
            'F': [
                [1,1,1,1],
                [1,0,0,0],
                [1,1,1,0],
                [1,0,0,0],
                [1,0,0,0]
            ],
            'T': [
                [1,1,1,1],
                [0,1,0,0],
                [0,1,0,0],
                [0,1,0,0],
                [0,1,0,0]
            ],
            'C': [
                [0,1,1,1],
                [1,0,0,0],
                [1,0,0,0],
                [1,0,0,0],
                [0,1,1,1]
            ],
            'R': [
                [1,1,1,0],
                [1,0,0,1],
                [1,1,1,0],
                [1,0,1,0],
                [1,0,0,1]
            ],
            'D': [
                [1,1,1,0],
                [1,0,0,1],
                [1,0,0,1],
                [1,0,0,1],
                [1,1,1,0]
            ],
            'U': [
                [1,0,0,1],
                [1,0,0,1],
                [1,0,0,1],
                [1,0,0,1],
                [0,1,1,0]
            ],
            'P': [
                [1,1,1,0],
                [1,0,0,1],
                [1,1,1,0],
                [1,0,0,0],
                [1,0,0,0]
            ],
            'L': [
                [1,0,0,0],
                [1,0,0,0],
                [1,0,0,0],
                [1,0,0,0],
                [1,1,1,1]
            ],
            '!': [
                [0,1,0],
                [0,1,0],
                [0,1,0],
                [0,0,0],
                [0,1,0]
            ],
            'H': [
                [1,0,0,1],
                [1,0,0,1],
                [1,1,1,1],
                [1,0,0,1],
                [1,0,0,1]
            ],
            'Y': [
                [1,0,0,1],
                [1,0,0,1],
                [0,1,1,0],
                [0,1,0,0],
                [0,1,0,0]
            ],
            'K': [
                [1,0,0,1],
                [1,0,1,0],
                [1,1,0,0],
                [1,0,1,0],
                [1,0,0,1]
            ],
            'V': [
                [1,0,0,1],
                [1,0,0,1],
                [1,0,0,1],
                [0,1,1,0],
                [0,0,1,0]
            ],
            'B': [
                [1,1,1,0],
                [1,0,0,1],
                [1,1,1,0],
                [1,0,0,1],
                [1,1,1,0]
            ],
            'J': [
                [0,0,1,1],
                [0,0,0,1],
                [0,0,0,1],
                [1,0,0,1],
                [0,1,1,0]
            ],
            'Q': [
                [0,1,1,0],
                [1,0,0,1],
                [1,0,0,1],
                [1,0,1,1],
                [0,1,1,1]
            ],
            'X': [
                [1,0,0,1],
                [0,1,1,0],
                [0,0,1,0],
                [0,1,1,0],
                [1,0,0,1]
            ],
            'Z': [
                [1,1,1,1],
                [0,0,0,1],
                [0,0,1,0],
                [0,1,0,0],
                [1,1,1,1]
            ],
            ' ': [
                [0,0,0,0],
                [0,0,0,0],
                [0,0,0,0],
                [0,0,0,0],
                [0,0,0,0]
            ],
            "'": [
                [0,1,0],
                [0,1,0],
                [0,0,0],
                [0,0,0],
                [0,0,0]
            ],
            "'": [
                [0,1,0],
                [0,1,0],
                [0,0,0],
                [0,0,0],
                [0,0,0]
            ]
        };
        
        let currentX = startX;
        
        for (let i = 0; i < message.length; i++) {
            const letter = message[i];
            const pattern = letterPatterns[letter];
            
            if (pattern) {
                // 绘制字母的每个点
                for (let row = 0; row < pattern.length; row++) {
                    for (let col = 0; col < pattern[row].length; col++) {
                        if (pattern[row][col] === 1) {
                            const gemX = currentX + col * 8;
                            const gemY = startY + row * 8;
                            
                            if (gemY > 50 && gemY < this.height - 100) {
                                this.gems.push({
                                    x: gemX,
                                    y: gemY,
                                    width: 15,
                                    height: 15,
                                    color: this.getGemColor(),
                                    collected: false,
                                    sparkle: 0
                                });
                            }
                        }
                    }
                }
            }
            
            currentX += letterSpacing;
        }
    }
    
    generateWarmHeartsFeast() {
        // 治愈爱心希望盛宴
        const startX = this.width + 100;
        const startY = this.height / 2 - 150;
        
        // 定义爱心图案
        const heartPattern = [
            [0,1,1,0,1,1,0],
            [1,1,1,1,1,1,1],
            [1,1,1,1,1,1,1],
            [1,1,1,1,1,1,1],
            [0,1,1,1,1,1,0],
            [0,0,1,1,1,0,0],
            [0,0,0,1,0,0,0]
        ];
        
        // 绘制多个爱心
        for (let heartRow = 0; heartRow < 3; heartRow++) {
            for (let heartCol = 0; heartCol < 2; heartCol++) {
                const heartX = startX + heartCol * 100;
                const heartY = startY + heartRow * 80;
                
                // 绘制爱心图案
                for (let row = 0; row < heartPattern.length; row++) {
                    for (let col = 0; col < heartPattern[row].length; col++) {
                        if (heartPattern[row][col] === 1) {
                            const gemX = heartX + col * 6;
                            const gemY = heartY + row * 6;
                            
                            if (gemY > 50 && gemY < this.height - 100) {
                                this.gems.push({
                                    x: gemX,
                                    y: gemY,
                                    width: 15,
                                    height: 15,
                                    color: '#FF69B4', // 粉色爱心
                                    collected: false,
                                    sparkle: 0
                                });
                            }
                        }
                    }
                }
            }
        }
    }
    
    generateEncouragingWordsFeast() {
        // 治愈话语希望盛宴
        const encouragingMessages = [
            // 英文鼓励话语
            'YOU ARE NOT ALONE!',
            'IT WILL GET BETTER!',
            'YOU DESERVE HAPPINESS!',
            'YOU ARE LOVED!',
            'YOU MATTER TO US!',
            'YOUR FEELINGS ARE VALID!',
            'YOU ARE WORTHY OF LOVE!',
            'YOU ARE ENOUGH!',
            'YOU ARE BEAUTIFUL INSIDE!',
            'YOU ARE STRONGER THAN YOU KNOW!',
            // 中文暖心话语
            '你并不孤单！',
            '一切都会好起来！',
            '你值得拥有幸福！',
            '你是被爱着的！',
            '你对这个世界很重要！',
            '你的感受是真实的！',
            '你值得被爱！',
            '你已经足够好了！',
            '你的内心很美！',
            '你比想象中更坚强！',
            '世界因你而美好！',
            '你是独一无二的！',
            '你的存在就是奇迹！',
            '勇敢地做自己！',
            '明天会更好！'
        ];
        
        // 定义字母的点阵图案
        const letterPatterns = {
            'A': [[0,1,1,0],[1,0,0,1],[1,1,1,1],[1,0,0,1],[1,0,0,1]],
            'B': [[1,1,1,0],[1,0,0,1],[1,1,1,0],[1,0,0,1],[1,1,1,0]],
            'C': [[0,1,1,1],[1,0,0,0],[1,0,0,0],[1,0,0,0],[0,1,1,1]],
            'D': [[1,1,1,0],[1,0,0,1],[1,0,0,1],[1,0,0,1],[1,1,1,0]],
            'E': [[1,1,1,1],[1,0,0,0],[1,1,1,0],[1,0,0,0],[1,1,1,1]],
            'F': [[1,1,1,1],[1,0,0,0],[1,1,1,0],[1,0,0,0],[1,0,0,0]],
            'G': [[0,1,1,1],[1,0,0,0],[1,0,1,1],[1,0,0,1],[0,1,1,0]],
            'H': [[1,0,0,1],[1,0,0,1],[1,1,1,1],[1,0,0,1],[1,0,0,1]],
            'I': [[1,1,1,1],[0,1,0,0],[0,1,0,0],[0,1,0,0],[1,1,1,1]],
            'J': [[0,0,1,1],[0,0,0,1],[0,0,0,1],[1,0,0,1],[0,1,1,0]],
            'K': [[1,0,0,1],[1,0,1,0],[1,1,0,0],[1,0,1,0],[1,0,0,1]],
            'L': [[1,0,0,0],[1,0,0,0],[1,0,0,0],[1,0,0,0],[1,1,1,1]],
            'M': [[1,0,0,1],[1,1,1,1],[1,0,0,1],[1,0,0,1],[1,0,0,1]],
            'N': [[1,0,0,1],[1,1,0,1],[1,0,1,1],[1,0,0,1],[1,0,0,1]],
            'O': [[0,1,1,0],[1,0,0,1],[1,0,0,1],[1,0,0,1],[0,1,1,0]],
            'P': [[1,1,1,0],[1,0,0,1],[1,1,1,0],[1,0,0,0],[1,0,0,0]],
            'Q': [[0,1,1,0],[1,0,0,1],[1,0,0,1],[1,0,1,1],[0,1,1,1]],
            'R': [[1,1,1,0],[1,0,0,1],[1,1,1,0],[1,0,1,0],[1,0,0,1]],
            'S': [[0,1,1,1],[1,0,0,0],[0,1,1,0],[0,0,0,1],[1,1,1,0]],
            'T': [[1,1,1,1],[0,1,0,0],[0,1,0,0],[0,1,0,0],[0,1,0,0]],
            'U': [[1,0,0,1],[1,0,0,1],[1,0,0,1],[1,0,0,1],[0,1,1,0]],
            'V': [[1,0,0,1],[1,0,0,1],[1,0,0,1],[0,1,1,0],[0,0,1,0]],
            'W': [[1,0,0,1],[1,0,0,1],[1,0,0,1],[1,0,0,1],[1,1,1,1]],
            'X': [[1,0,0,1],[0,1,1,0],[0,0,1,0],[0,1,1,0],[1,0,0,1]],
            'Y': [[1,0,0,1],[1,0,0,1],[0,1,1,0],[0,1,0,0],[0,1,0,0]],
            'Z': [[1,1,1,1],[0,0,0,1],[0,0,1,0],[0,1,0,0],[1,1,1,1]],
            ' ': [[0,0,0,0],[0,0,0,0],[0,0,0,0],[0,0,0,0],[0,0,0,0]],
            '!': [[0,1,0],[0,1,0],[0,1,0],[0,0,0],[0,1,0]],
            "'": [[0,1,0],[0,1,0],[0,0,0],[0,0,0],[0,0,0]],
            // 中文字符点阵（简化版）
            '你': [[1,1,1,1],[0,0,1,0],[1,1,1,1],[0,0,1,0],[1,1,1,1]],
            '并': [[1,0,0,1],[1,1,1,1],[1,0,0,1],[1,1,1,1],[1,0,0,1]],
            '不': [[1,1,1,1],[0,0,1,0],[0,0,1,0],[0,0,1,0],[0,0,1,0]],
            '孤': [[1,0,0,1],[1,1,1,1],[1,0,0,1],[1,1,1,1],[1,0,0,1]],
            '单': [[0,1,1,0],[1,0,0,1],[1,0,0,1],[1,0,0,1],[0,1,1,0]],
            '一': [[0,0,0,0],[1,1,1,1],[0,0,0,0],[0,0,0,0],[0,0,0,0]],
            '切': [[1,1,1,1],[0,0,1,0],[1,1,1,1],[0,0,1,0],[1,1,1,1]],
            '都': [[1,0,0,1],[1,1,1,1],[1,0,0,1],[1,1,1,1],[1,0,0,1]],
            '会': [[1,1,1,1],[0,0,1,0],[1,1,1,1],[0,0,1,0],[1,1,1,1]],
            '好': [[1,0,0,1],[1,1,1,1],[1,0,0,1],[1,1,1,1],[1,0,0,1]],
            '起': [[1,1,1,1],[0,0,1,0],[1,1,1,1],[0,0,1,0],[1,1,1,1]],
            '来': [[1,0,0,1],[1,1,1,1],[1,0,0,1],[1,1,1,1],[1,0,0,1]],
            '值': [[1,1,1,1],[0,0,1,0],[1,1,1,1],[0,0,1,0],[1,1,1,1]],
            '得': [[1,0,0,1],[1,1,1,1],[1,0,0,1],[1,1,1,1],[1,0,0,1]],
            '拥': [[1,1,1,1],[0,0,1,0],[1,1,1,1],[0,0,1,0],[1,1,1,1]],
            '有': [[1,0,0,1],[1,1,1,1],[1,0,0,1],[1,1,1,1],[1,0,0,1]],
            '幸': [[1,1,1,1],[0,0,1,0],[1,1,1,1],[0,0,1,0],[1,1,1,1]],
            '福': [[1,0,0,1],[1,1,1,1],[1,0,0,1],[1,1,1,1],[1,0,0,1]],
            '是': [[1,1,1,1],[0,0,1,0],[1,1,1,1],[0,0,1,0],[1,1,1,1]],
            '被': [[1,0,0,1],[1,1,1,1],[1,0,0,1],[1,1,1,1],[1,0,0,1]],
            '爱': [[1,1,1,1],[0,0,1,0],[1,1,1,1],[0,0,1,0],[1,1,1,1]],
            '着': [[1,0,0,1],[1,1,1,1],[1,0,0,1],[1,1,1,1],[1,0,0,1]],
            '的': [[1,1,1,1],[0,0,1,0],[1,1,1,1],[0,0,1,0],[1,1,1,1]],
            '对': [[1,0,0,1],[1,1,1,1],[1,0,0,1],[1,1,1,1],[1,0,0,1]],
            '这': [[1,1,1,1],[0,0,1,0],[1,1,1,1],[0,0,1,0],[1,1,1,1]],
            '个': [[1,0,0,1],[1,1,1,1],[1,0,0,1],[1,1,1,1],[1,0,0,1]],
            '世': [[1,1,1,1],[0,0,1,0],[1,1,1,1],[0,0,1,0],[1,1,1,1]],
            '界': [[1,0,0,1],[1,1,1,1],[1,0,0,1],[1,1,1,1],[1,0,0,1]],
            '很': [[1,1,1,1],[0,0,1,0],[1,1,1,1],[0,0,1,0],[1,1,1,1]],
            '重': [[1,0,0,1],[1,1,1,1],[1,0,0,1],[1,1,1,1],[1,0,0,1]],
            '要': [[1,1,1,1],[0,0,1,0],[1,1,1,1],[0,0,1,0],[1,1,1,1]],
            '感': [[1,0,0,1],[1,1,1,1],[1,0,0,1],[1,1,1,1],[1,0,0,1]],
            '受': [[1,1,1,1],[0,0,1,0],[1,1,1,1],[0,0,1,0],[1,1,1,1]],
            '真': [[1,0,0,1],[1,1,1,1],[1,0,0,1],[1,1,1,1],[1,0,0,1]],
            '实': [[1,1,1,1],[0,0,1,0],[1,1,1,1],[0,0,1,0],[1,1,1,1]],
            '已': [[1,0,0,1],[1,1,1,1],[1,0,0,1],[1,1,1,1],[1,0,0,1]],
            '经': [[1,1,1,1],[0,0,1,0],[1,1,1,1],[0,0,1,0],[1,1,1,1]],
            '足': [[1,0,0,1],[1,1,1,1],[1,0,0,1],[1,1,1,1],[1,0,0,1]],
            '够': [[1,1,1,1],[0,0,1,0],[1,1,1,1],[0,0,1,0],[1,1,1,1]],
            '了': [[1,0,0,1],[1,1,1,1],[1,0,0,1],[1,1,1,1],[1,0,0,1]],
            '内': [[1,1,1,1],[0,0,1,0],[1,1,1,1],[0,0,1,0],[1,1,1,1]],
            '心': [[1,0,0,1],[1,1,1,1],[1,0,0,1],[1,1,1,1],[1,0,0,1]],
            '很': [[1,1,1,1],[0,0,1,0],[1,1,1,1],[0,0,1,0],[1,1,1,1]],
            '美': [[1,0,0,1],[1,1,1,1],[1,0,0,1],[1,1,1,1],[1,0,0,1]],
            '比': [[1,1,1,1],[0,0,1,0],[1,1,1,1],[0,0,1,0],[1,1,1,1]],
            '想': [[1,0,0,1],[1,1,1,1],[1,0,0,1],[1,1,1,1],[1,0,0,1]],
            '象': [[1,1,1,1],[0,0,1,0],[1,1,1,1],[0,0,1,0],[1,1,1,1]],
            '中': [[1,0,0,1],[1,1,1,1],[1,0,0,1],[1,1,1,1],[1,0,0,1]],
            '更': [[1,1,1,1],[0,0,1,0],[1,1,1,1],[0,0,1,0],[1,1,1,1]],
            '坚': [[1,0,0,1],[1,1,1,1],[1,0,0,1],[1,1,1,1],[1,0,0,1]],
            '强': [[1,1,1,1],[0,0,1,0],[1,1,1,1],[0,0,1,0],[1,1,1,1]],
            '因': [[1,0,0,1],[1,1,1,1],[1,0,0,1],[1,1,1,1],[1,0,0,1]],
            '而': [[1,1,1,1],[0,0,1,0],[1,1,1,1],[0,0,1,0],[1,1,1,1]],
            '美': [[1,0,0,1],[1,1,1,1],[1,0,0,1],[1,1,1,1],[1,0,0,1]],
            '好': [[1,1,1,1],[0,0,1,0],[1,1,1,1],[0,0,1,0],[1,1,1,1]],
            '独': [[1,0,0,1],[1,1,1,1],[1,0,0,1],[1,1,1,1],[1,0,0,1]],
            '一': [[1,1,1,1],[0,0,1,0],[1,1,1,1],[0,0,1,0],[1,1,1,1]],
            '无': [[1,0,0,1],[1,1,1,1],[1,0,0,1],[1,1,1,1],[1,0,0,1]],
            '二': [[1,1,1,1],[0,0,1,0],[1,1,1,1],[0,0,1,0],[1,1,1,1]],
            '存': [[1,0,0,1],[1,1,1,1],[1,0,0,1],[1,1,1,1],[1,0,0,1]],
            '在': [[1,1,1,1],[0,0,1,0],[1,1,1,1],[0,0,1,0],[1,1,1,1]],
            '就': [[1,0,0,1],[1,1,1,1],[1,0,0,1],[1,1,1,1],[1,0,0,1]],
            '是': [[1,1,1,1],[0,0,1,0],[1,1,1,1],[0,0,1,0],[1,1,1,1]],
            '奇': [[1,0,0,1],[1,1,1,1],[1,0,0,1],[1,1,1,1],[1,0,0,1]],
            '迹': [[1,1,1,1],[0,0,1,0],[1,1,1,1],[0,0,1,0],[1,1,1,1]],
            '勇': [[1,0,0,1],[1,1,1,1],[1,0,0,1],[1,1,1,1],[1,0,0,1]],
            '敢': [[1,1,1,1],[0,0,1,0],[1,1,1,1],[0,0,1,0],[1,1,1,1]],
            '地': [[1,0,0,1],[1,1,1,1],[1,0,0,1],[1,1,1,1],[1,0,0,1]],
            '做': [[1,1,1,1],[0,0,1,0],[1,1,1,1],[0,0,1,0],[1,1,1,1]],
            '自': [[1,0,0,1],[1,1,1,1],[1,0,0,1],[1,1,1,1],[1,0,0,1]],
            '己': [[1,1,1,1],[0,0,1,0],[1,1,1,1],[0,0,1,0],[1,1,1,1]],
            '明': [[1,0,0,1],[1,1,1,1],[1,0,0,1],[1,1,1,1],[1,0,0,1]],
            '天': [[1,1,1,1],[0,0,1,0],[1,1,1,1],[0,0,1,0],[1,1,1,1]],
            '会': [[1,0,0,1],[1,1,1,1],[1,0,0,1],[1,1,1,1],[1,0,0,1]],
            '更': [[1,1,1,1],[0,0,1,0],[1,1,1,1],[0,0,1,0],[1,1,1,1]],
            '好': [[1,0,0,1],[1,1,1,1],[1,0,0,1],[1,1,1,1],[1,0,0,1]]
        };
        
        const message = encouragingMessages[Math.floor(Math.random() * encouragingMessages.length)];
        const startX = this.width + 150;
        const startY = this.height / 2 - 100;
        const letterSpacing = 20;
        
        let currentX = startX;
        
        for (let i = 0; i < message.length; i++) {
            const letter = message[i];
            const pattern = letterPatterns[letter];
            
            if (pattern) {
                // 绘制字母的每个点
                for (let row = 0; row < pattern.length; row++) {
                    for (let col = 0; col < pattern[row].length; col++) {
                        if (pattern[row][col] === 1) {
                            const gemX = currentX + col * 6;
                            const gemY = startY + row * 6;
                            
                            if (gemY > 50 && gemY < this.height - 100) {
                                this.gems.push({
                                    x: gemX,
                                    y: gemY,
                                    width: 15,
                                    height: 15,
                                    color: '#FFD700', // 金色鼓励文字
                                    collected: false,
                                    sparkle: 0
                                });
                            }
                        }
                    }
                }
            }
            
            currentX += letterSpacing;
        }
    }
    
    updateDimooForm() {
        // 根据治愈进度更新DIMOO形态
        const healingProgress = Math.min(this.gemCount / 1000, 1); // 治愈进度：0-1
        
        let newForm = 'depressed';
        if (healingProgress >= 0.8) {
            newForm = 'radiant'; // 80%以上：光芒四射
        } else if (healingProgress >= 0.6) {
            newForm = 'healed'; // 60%以上：治愈完成
        } else if (healingProgress >= 0.4) {
            newForm = 'recovering'; // 40%以上：康复中
        } else if (healingProgress >= 0.2) {
            newForm = 'healing'; // 20%以上：治愈中
        }
        
        if (newForm !== this.dimoo.form) {
            this.dimoo.form = newForm;
            const formData = this.dimoo.forms[newForm];
            this.dimoo.color = formData.color;
            console.log(`👽 DIMOO形态变化：${formData.name} - ${formData.description}`);
        }
    }
    
    updateBackground() {
        // 每500000米切换背景（降低转换频率）
        const newBackground = Math.floor(this.distance / 500000) % 2 === 0 ? 'day' : 'night';
        if (newBackground !== this.currentBackground) {
            this.currentBackground = newBackground;
            this.ground.color = this.backgrounds[this.currentBackground].ground;
            
            // 黑夜模式下更新DIMOO颜色，增加对比度
            if (this.currentBackground === 'night') {
                this.dimoo.color = '#FFFFFF'; // 白色，与黑夜背景形成对比
            } else {
                this.dimoo.color = this.dimoo.forms[this.dimoo.form].color; // 使用当前形态的颜色
            }
        }
    }
    
    updateDino() {
        // 确保DIMOO X坐标固定，不会改变位置
        this.dimoo.x = 80;
        
        // 更新行走动画 - 只要游戏运行就更新动画
        if (this.gameRunning) {
            if (!this.dimoo.jumping && !this.dimoo.ducking) {
                this.dimoo.walkCycle += this.dimoo.runSpeed;
                this.dimoo.legOffset = Math.sin(this.dimoo.walkCycle) * 4;
                this.dimoo.tailOffset = Math.sin(this.dimoo.walkCycle * 0.7) * 3;
            }
        }
        
        // 根据状态应用不同的重力
        let currentGravity = this.dimoo.normalGravity;
        
        if (this.dimoo.isGliding) {
            if (this.dimoo.isGlideKeyPressed) {
                // 长按滑翔键 - 匀速下降
                currentGravity = this.dimoo.glideGravity;
            } else if (this.dimoo.isGlideReleased) {
                // 松开滑翔键 - 加速垂直下降
                currentGravity = this.dimoo.fastFallGravity;
            }
        } else if (this.dimoo.canFastFall && this.dimoo.velocityY > 0) {
            currentGravity = this.dimoo.fastFallGravity;
        }
        
        this.dimoo.velocityY += currentGravity;
        this.dimoo.y += this.dimoo.velocityY;
        
        // 地面碰撞检测 - 确保接触地板
        if (this.dimoo.y > this.height - 50 - this.dimoo.height) {
            this.dimoo.y = this.height - 50 - this.dimoo.height;
            this.dimoo.velocityY = 0;
            this.dimoo.jumping = false;
            this.dimoo.isGliding = false;
            this.dimoo.isGlideKeyPressed = false;
            this.dimoo.canFastFall = false;
            this.dimoo.isGlideReleased = false;
            // 落地时重置跳跃计数
            this.dimoo.jumpCount = 0;
        }
    }
    
    updateObstacles() {
        const currentTime = Date.now();
        
        // 计算下一次无敌状态触发时间（等差数列：2n + 10 秒）
        const nextInvincibleTime = this.lastInvincibleCheck + (this.invincibleLevel * 2000 + 10000); // 2n + 10 秒
        
        // 检查无敌状态（使用等差数列计算间隔）
        if (currentTime > nextInvincibleTime) {
            this.startInvincibleMode();
            this.lastInvincibleCheck = currentTime;
            this.invincibleLevel++; // 增加等级，下次间隔更长
        }
        
        // 更新无敌状态
        if (this.isInvincible) {
            if (currentTime - this.invincibleStartTime > this.invincibleDuration) {
                this.stopInvincibleMode();
            }
        }
        
        // 更新前进距离
        if (this.speed && !isNaN(this.speed)) {
            this.distance += this.speed;
        } else {
            console.warn('速度值异常:', this.speed);
            this.speed = this.baseSpeed || 3;
        }
        
        // 更新恐龙形态 - 根据治愈进度
        this.updateDimooForm();
        
        // 根据距离计算基础分数（不再覆盖宝石分数）
        const distanceScore = Math.floor(this.distance / 500); // 进一步降低距离得分：每500米1分（原来是每50米1分）
        if (!this.score) {
            this.score = distanceScore;
        }
        
        // 添加距离的0.0002倍到得分中（进一步降低距离得分增长）
        const distanceBonus = Math.floor(this.distance * 0.0002); // 进一步降低距离奖励：每5000米1分（原来是每500米1分）
        this.score += distanceBonus;
        
        // 删除暖心话语触发逻辑
        
        // 生成新障碍物
        if (currentTime - this.lastObstacleTime > this.obstacleInterval) {
            this.generateObstacle();
            this.lastObstacleTime = currentTime;
            // 根据距离调整障碍物间隔，确保后期障碍物更密集
            const distanceFactor = Math.min(this.distance / 10000, 3); // 距离因子，最大3倍
            const intervalReduction = 30 + distanceFactor * 10; // 距离越远，间隔减少越快
            this.obstacleInterval = Math.max(800, this.obstacleInterval - intervalReduction); // 最小间隔800ms
        }
        
        // 检查宝石盛宴（根据速度调整时间间隔）
        let currentGemFeastInterval = this.gemFeastInterval;
        if (this.speedMultiplier > 7) {
            currentGemFeastInterval = this.gemFeastInterval * 0.5; // 速度高于7时，时间间隔减半
        }
        
        if (currentTime - this.lastGemFeast > currentGemFeastInterval) {
            this.generateGemFeast();
            this.lastGemFeast = currentTime;
            
            // 启动希望盛宴状态
            this.isGemFeastActive = true;
            this.gemFeastStartTime = currentTime;
            
            // 根据速度调整持续时间
            if (this.speedMultiplier > 7) {
                this.gemFeastDuration = 15000; // 速度高于7时，持续时间翻三倍（15秒）
                this.gemFeastSpeedMultiplier = 0.3; // 宝石移动速度减慢，让玩家有更多时间收集
            } else {
                this.gemFeastDuration = 5000; // 正常持续时间5秒
                this.gemFeastSpeedMultiplier = 1.0; // 正常移动速度
            }
            
            console.log(`🎉 宝石盛宴开始！速度：${this.speedMultiplier.toFixed(1)}x，间隔：${(currentGemFeastInterval/1000).toFixed(1)}秒，持续：${(this.gemFeastDuration/1000).toFixed(1)}秒`);
        }
        
        // 检查希望盛宴状态
        if (this.isGemFeastActive && currentTime - this.gemFeastStartTime > this.gemFeastDuration) {
            this.isGemFeastActive = false;
            console.log('🎉 宝石盛宴结束！');
        }
        
        // 删除暖心话语状态检查
        
        // 检查吸铁石生成（根据速度调整概率）
        let magnetProbability = 1.0; // 基础概率
        if (this.speedMultiplier > 15) {
            magnetProbability = 1.5; // 高速时增加吸铁石概率
        }
        
        if (Math.random() < magnetProbability && currentTime - this.lastMagnetTime > this.magnetInterval) {
            this.generateMagnet();
            this.lastMagnetTime = currentTime;
            console.log('🧲 吸铁石生成！');
        }
        
        // 检查吸铁石状态
        if (this.isMagnetActive && currentTime - this.magnetStartTime > this.magnetDuration) {
            this.stopMagnet();
        }
        
        // 检查治愈冲刺道具生成（根据速度调整概率）
        let healingBoosterProbability = 1.0; // 基础概率
        if (this.speedMultiplier < 1) {
            healingBoosterProbability = 2.0; // 低速时增加加速道具概率
        }
        
        if (Math.random() < healingBoosterProbability && currentTime - this.lastHealingBoosterTime > this.healingBoosterInterval) {
            this.generateHealingBooster();
            this.lastHealingBoosterTime = currentTime;
            console.log('💊 治愈冲刺道具生成！');
        }
        
        // 检查治愈冲刺道具状态
        if (this.isHealingBoosterActive && currentTime - this.healingBoosterStartTime > this.healingBoosterDuration) {
            this.stopHealingBooster();
        }
        
        // 检查爱心道具生成（根据速度和状态调整概率）
        let heartItemProbability = 1.0; // 基础概率
        if (this.speedMultiplier > 15) {
            heartItemProbability = 1.3; // 高速时增加爱心道具概率
        }
        
        // 凋零阶段大幅增加爱心道具生成概率
        if (this.isEvolutionMode && this.evolutionType === 'death') {
            heartItemProbability = 5.0; // 凋零阶段5倍概率（进一步增加）
            console.log('💖 凋零阶段：爱心道具生成概率大幅提升！');
        }
        
        // 凋零阶段缩短爱心道具生成间隔
        let currentHeartItemInterval = this.heartItemInterval;
        if (this.isEvolutionMode && this.evolutionType === 'death') {
            currentHeartItemInterval = this.heartItemInterval * 0.2; // 凋零阶段生成间隔缩短到20%（进一步缩短）
            console.log('💖 凋零阶段：爱心道具生成间隔大幅缩短！');
        }
        
        if (Math.random() < heartItemProbability && currentTime - this.lastHeartItemTime > currentHeartItemInterval) {
            this.generateHeartItem();
            this.lastHeartItemTime = currentTime;
            console.log('💖 爱心道具生成！');
        }
        
        // 检查得分倍数道具生成
        if (currentTime - this.lastScoreMultiplierTime > this.scoreMultiplierInterval) {
            this.generateScoreMultiplier();
            this.lastScoreMultiplierTime = currentTime;
            console.log('🎯 得分倍数道具生成！');
        }
        
        // 检查得分倍数道具状态
        if (this.isScoreMultiplierActive && currentTime - this.scoreMultiplierStartTime > this.scoreMultiplierDuration) {
            this.stopScoreMultiplier();
        }
        
        // 检查进化模式状态
        if (this.isEvolutionMode && currentTime - this.evolutionStartTime > this.evolutionDuration) {
            this.stopEvolutionMode();
        }
        
        // 生成新宝石（凋零阶段更频繁）
        let currentGemInterval = this.gemInterval;
        if (this.isEvolutionMode && this.evolutionType === 'death') {
            currentGemInterval = this.gemInterval * 0.4; // 凋零阶段宝石生成间隔缩短到40%
        }
        
        if (currentTime - this.lastGemTime > currentGemInterval) {
            this.generateGem();
            this.lastGemTime = currentTime;
        }
        
        // 更新障碍物位置 - 使用for循环避免死循环
        for (let i = this.obstacles.length - 1; i >= 0; i--) {
            const obstacle = this.obstacles[i];
            obstacle.x -= this.speed;
            
            // 移除屏幕外的障碍物
            if (obstacle.x + obstacle.width < 0) {
                this.obstacles.splice(i, 1);
                this.updateBackground(); // 更新背景
            }
        }
        
        // 更新宝石位置 - 使用for循环避免死循环
        for (let i = this.gems.length - 1; i >= 0; i--) {
            const gem = this.gems[i];
            // 希望盛宴期间使用调整后的移动速度
            const moveSpeed = this.isGemFeastActive ? this.speed * this.gemFeastSpeedMultiplier : this.speed;
            gem.x -= moveSpeed;
            
            // 移除屏幕外的宝石
            if (gem.x + gem.width < 0) {
                this.gems.splice(i, 1);
            }
        }
        
        // 更新吸铁石位置 - 使用for循环避免死循环
        if (this.magnets) {
            for (let i = this.magnets.length - 1; i >= 0; i--) {
                const magnet = this.magnets[i];
                magnet.x -= this.speed;
                
                // 移除屏幕外的吸铁石
                if (magnet.x + magnet.width < 0) {
                    this.magnets.splice(i, 1);
                }
            }
        }
        
        // 更新治愈冲刺道具位置 - 使用for循环避免死循环
        for (let i = this.healingBoosters.length - 1; i >= 0; i--) {
            const booster = this.healingBoosters[i];
            booster.x -= this.speed;
            
            // 移除屏幕外的治愈冲刺道具
            if (booster.x + booster.width < 0) {
                this.healingBoosters.splice(i, 1);
            }
        }
        
        // 更新爱心道具位置 - 使用for循环避免死循环
        for (let i = this.heartItems.length - 1; i >= 0; i--) {
            const heart = this.heartItems[i];
            heart.x -= this.speed;
            
            // 移除屏幕外的爱心道具
            if (heart.x + heart.width < 0) {
                this.heartItems.splice(i, 1);
            }
        }
        
        // 更新得分倍数道具位置 - 使用for循环避免死循环
        for (let i = this.scoreMultipliers.length - 1; i >= 0; i--) {
            const multiplier = this.scoreMultipliers[i];
            multiplier.x -= this.speed;
            
            // 移除屏幕外的得分倍数道具
            if (multiplier.x + multiplier.width < 0) {
                this.scoreMultipliers.splice(i, 1);
            }
        }
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
        // 无敌状态下仍然可以拾取宝石，但不与障碍物碰撞
        if (this.isInvincible) {
            // 只检测宝石收集和吸铁石，不检测障碍物碰撞
            this.checkGemCollisions();
            this.checkMagnetCollisions();
            return;
        }
        
        // 正常状态下检测所有碰撞
        this.checkGemCollisions();
        this.checkMagnetCollisions();
        this.checkHealingBoosterCollisions();
        this.checkHeartItemCollisions();
        this.checkScoreMultiplierCollisions();
        this.checkVictoryGemCollisions();
        this.checkObstacleCollisions();
        
        // 检查胜利条件
        this.checkVictoryCondition();
    }
    
    checkGemCollisions() {
        // 吸铁石激活时，启动宝石吸附动画
        if (this.isMagnetActive) {
            // 将范围内的宝石添加到吸附数组 - 使用for循环避免死循环
            for (let i = this.gems.length - 1; i >= 0; i--) {
                const gem = this.gems[i];
                if (!gem.collected && !gem.isAttracting) {
                    const distance = Math.sqrt(
                        Math.pow(gem.x - this.dimoo.x, 2) + 
                        Math.pow(gem.y - this.dimoo.y, 2)
                    );
                    
                    if (distance <= this.magnetEffectRadius) {
                        gem.isAttracting = true;
                        gem.attractionSpeed = this.attractionSpeed;
                        gem.attractionProgress = 0;
                        this.attractingGems.push(gem);
                        this.gems.splice(i, 1);
                    }
                }
            }
            
            // 吸铁石激活时，自动拾取范围内的道具 - 使用for循环避免死循环
            for (let i = this.healingBoosters.length - 1; i >= 0; i--) {
                const booster = this.healingBoosters[i];
                if (!booster.collected) {
                    const distance = Math.sqrt(
                        Math.pow(booster.x - this.dimoo.x, 2) + 
                        Math.pow(booster.y - this.dimoo.y, 2)
                    );
                    
                    if (distance <= this.magnetEffectRadius) {
                        booster.collected = true;
                        this.healingBoosters.splice(i, 1);
                        this.startHealingBooster();
                        console.log('💊 爱心磁铁自动收集治愈冲刺道具！');
                    }
                }
            }
            
            // 吸铁石激活时，自动拾取范围内的爱心道具 - 使用for循环避免死循环
            for (let i = this.heartItems.length - 1; i >= 0; i--) {
                const heart = this.heartItems[i];
                if (!heart.collected) {
                    const distance = Math.sqrt(
                        Math.pow(heart.x - this.dimoo.x, 2) + 
                        Math.pow(heart.y - this.dimoo.y, 2)
                    );
                    
                    if (distance <= this.magnetEffectRadius) {
                        heart.collected = true;
                        this.heartItems.splice(i, 1);
                        this.lives = Math.min(this.lives + 1, 99);
                        
                        // 如果在凋零阶段通过吸铁石获得爱心道具，触发重生动画
                        if (this.isEvolutionMode && this.evolutionType === 'death') {
                            console.log('💖 凋零阶段通过爱心磁铁获得爱心道具！触发重生动画！');
                            this.stopEvolutionMode(); // 停止凋零动画
                            this.startEvolutionMode('rebirth'); // 启动重生动画
                            break; // 避免重复处理
                        } else {
                            console.log('💖 爱心磁铁自动收集爱心道具！生命 +1');
                        }
                    }
                }
            }
            
            // 更新吸附动画
            this.updateAttractionAnimation();
            return;
        }
        
        // 检测宝石收集（无敌状态和正常状态都可以） - 使用for循环避免死循环
        for (let i = this.gems.length - 1; i >= 0; i--) {
            const gem = this.gems[i];
            if (!gem.collected) {
                // 使用整个DIMOO的碰撞检测，包括腿部
                const dinoLeft = this.dimoo.x;
                const dinoRight = this.dimoo.x + this.dimoo.width;
                const dinoTop = this.dimoo.y;
                const dinoBottom = this.dimoo.y + this.dimoo.height;
                
                // 扩展腿部碰撞检测区域，确保腿部拉长时也能拾取
                const legExtension = 25; // 增加腿部延伸区域
                const extendedDinoBottom = dinoBottom + legExtension;
                
                // 考虑腿部拉长的情况，进一步扩展检测区域
                const maxLegExtension = 35; // 最大腿部延伸
                const finalDinoBottom = Math.max(extendedDinoBottom, dinoBottom + maxLegExtension);
                
                const gemLeft = gem.x;
                const gemRight = gem.x + gem.width;
                const gemTop = gem.y;
                const gemBottom = gem.y + gem.height;
                
                // 完整的碰撞检测，包括腿部延伸区域
                if (dinoRight > gemLeft && 
                    dinoLeft < gemRight && 
                    finalDinoBottom > gemTop && 
                    dinoTop < gemBottom) {
                    
                    // 收集希望宝石，根据宝石价值增加分数
                    const baseScore = Math.floor(this.speedMultiplier * 1); // 基础分数：速度倍数*1（进一步降低系数）
                    const gemScore = baseScore * (gem.value || 1) * this.scoreMultiplierValue; // 根据宝石价值和得分倍数计算分数
                    this.score += gemScore;
                    gem.collected = true;
                    
                    // 增加希望宝石计数（根据宝石价值）
                    this.gemCount += (gem.value || 1);
                    
                    // 检查是否达到100个希望宝石，获得治愈奖励
                    if (this.gemCount % 100 === 0) {
                        this.startGemInvincibleMode();
                        console.log(`💖 收集100个爱与希望宝石！获得4秒治愈状态！`);
                    }
                    
                    // 检查是否达到200个希望宝石，世界变得更温柔
                    if (this.gemCount % 200 === 0) {
                        this.reduceSpeedByHalf();
                        console.log(`🌍 收集200个爱与希望宝石！世界变得更温柔！`);
                    }
                    
                    // 移除已收集的宝石
                    this.gems.splice(i, 1);
                    
                    console.log(`💎 收集${gem.name || '宝石'}！得分 +${gemScore}，宝石计数：${this.gemCount}`);
                }
            }
        }
    }
    
    updateAttractionAnimation() {
        // 更新吸附动画
        for (let i = this.attractingGems.length - 1; i >= 0; i--) {
            const gem = this.attractingGems[i];
            
            // 计算到DIMOO的距离
            const dx = this.dimoo.x - gem.x;
            const dy = this.dimoo.y - gem.y;
            const distance = Math.sqrt(dx * dx + dy * dy);
            
            // 如果距离很近，收集宝石
            if (distance < 20) {
                const baseScore = Math.floor(this.speedMultiplier * 1); // 基础分数：速度倍数*1（进一步降低系数）
                const gemScore = baseScore * (gem.value || 1) * this.scoreMultiplierValue; // 根据宝石价值和得分倍数计算分数
                this.score += gemScore;
                this.gemCount += (gem.value || 1); // 根据宝石价值增加计数
                
                // 检查宝石奖励
                if (this.gemCount % 100 === 0) {
                    this.startGemInvincibleMode();
                    console.log(`🎉 收集100个宝石！获得4秒无敌状态！`);
                }
                if (this.gemCount % 200 === 0) {
                    this.reduceSpeedByHalf();
                    console.log(`🎯 收集200个宝石！速度减少一半！`);
                }
                
                console.log(`💖 爱心磁铁自动收集${gem.name || '宝石'}！得分 +${gemScore}，希望计数：${this.gemCount}`);
                this.attractingGems.splice(i, 1);
                continue;
            }
            
            // 更新宝石位置，向DIMOO移动
            const angle = Math.atan2(dy, dx);
            gem.attractionSpeed *= this.attractionAcceleration; // 加速
            gem.x += Math.cos(angle) * gem.attractionSpeed;
            gem.y += Math.sin(angle) * gem.attractionSpeed;
            
            // 添加螺旋轨迹效果
            gem.attractionProgress += 0.1;
            const spiralRadius = 5 * Math.sin(gem.attractionProgress);
            gem.x += Math.cos(angle + Math.PI/2) * spiralRadius * 0.1;
            gem.y += Math.sin(angle + Math.PI/2) * spiralRadius * 0.1;
        }
    }
    
    checkMagnetCollisions() {
        // 检测吸铁石收集
        if (!this.magnets) return;
        
        // 使用for循环避免死循环
        for (let i = this.magnets.length - 1; i >= 0; i--) {
            const magnet = this.magnets[i];
            if (!magnet.collected) {
                const dinoLeft = this.dimoo.x;
                const dinoRight = this.dimoo.x + this.dimoo.width;
                const dinoTop = this.dimoo.y;
                const dinoBottom = this.dimoo.y + this.dimoo.height;
                
                const magnetLeft = magnet.x;
                const magnetRight = magnet.x + magnet.width;
                const magnetTop = magnet.y;
                const magnetBottom = magnet.y + magnet.height;
                
                if (dinoRight > magnetLeft && 
                    dinoLeft < magnetRight && 
                    dinoBottom > magnetTop && 
                    dinoTop < magnetBottom) {
                    
                    magnet.collected = true;
                    this.magnets.splice(i, 1);
                    this.startMagnet();
                    console.log(`💖 收集爱心磁铁！激活世界之爱模式！`);
                }
            }
        }
    }
    
    checkCollision(obj1, obj2) {
        // 通用的碰撞检测函数
        return obj1.x < obj2.x + obj2.width &&
               obj1.x + obj1.width > obj2.x &&
               obj1.y < obj2.y + obj2.height &&
               obj1.y + obj1.height > obj2.y;
    }
    
    checkObstacleCollisions() {
        // 使用for循环而不是forEach，避免return语句的问题
        for (let i = this.obstacles.length - 1; i >= 0; i--) {
            const obstacle = this.obstacles[i];
            
            // 完善碰撞检测机制
            const dinoLeft = this.dimoo.x + 10; // 身体左边界
            const dinoRight = this.dimoo.x + this.dimoo.width - 10; // 身体右边界
            const dinoTop = this.dimoo.y + 15; // 身体顶部
            const dinoBottom = this.dimoo.y + this.dimoo.height - 15; // 身体底部
            
            const obstacleLeft = obstacle.x;
            const obstacleRight = obstacle.x + obstacle.width;
            const obstacleTop = obstacle.y;
            const obstacleBottom = obstacle.y + obstacle.height;
            
            // 精确的碰撞检测（包括下蹲状态）
            if (dinoRight > obstacleLeft && 
                dinoLeft < obstacleRight && 
                dinoBottom > obstacleTop && 
                dinoTop < obstacleBottom) {
                
                // 检查是否为特殊障碍物（不会减少生命）
                if (obstacle.isPlatform) {
                    // 浮动平台，不会减少生命，但会阻挡前进
                    console.log('碰到浮动平台，被阻挡');
                    continue;
                }
                
                // 检查定时炸弹是否爆炸
                if (obstacle.isTimeBomb && Date.now() < obstacle.explodeTime) {
                    // 炸弹还未爆炸，不会减少生命
                    console.log('碰到未爆炸的定时炸弹');
                    continue;
                }
                
                // 检查能量场是否激活
                if (obstacle.isEnergyField) {
                    // 能量场，不会减少生命，但会影响游戏
                    console.log('进入能量场');
                    continue;
                }
                
                // 检查重力井效果
                if (obstacle.isGravityWell) {
                    // 重力井，不会减少生命，但会影响重力
                    console.log('进入重力井');
                    continue;
                }
                
                // 检查狭窄间隙
                if (obstacle.isNarrowGap) {
                    // 狭窄间隙，只能下蹲通过
                    if (!this.dimoo.ducking) {
                        console.log('碰到狭窄间隙，需要下蹲通过');
                        this.lives--;
                        if (this.lives <= 0) {
                            // 没有生命了，启动凋零动画
                            this.lives = 0; // 确保生命值为0
                            this.startEvolutionMode('death');
                        } else {
                            this.resetDinoState();
                            this.obstacles.splice(i, 1);
                        }
                    } else {
                        console.log('下蹲通过狭窄间隙');
                    }
                    continue;
                }
                
                // 检查传送门
                if (obstacle.isTeleporter) {
                    // 传送门，随机传送位置
                    console.log('进入传送门');
                    this.dimoo.x = Math.random() * (this.width - 100) + 50;
                    this.dimoo.y = this.height - 100 - this.dimoo.height;
                    this.obstacles.splice(i, 1);
                    continue;
                }
                
                // 检查镜像墙
                if (obstacle.isMirrorWall) {
                    // 镜像墙，反射移动方向
                    console.log('碰到镜像墙');
                    this.speed = -this.speed; // 反向移动
                    this.obstacles.splice(i, 1);
                    continue;
                }
                
                // 检查黑洞
                if (obstacle.isBlackHole) {
                    // 黑洞，吸引玩家
                    console.log('进入黑洞');
                    this.dimoo.x += 2; // 被吸引
                    continue;
                }
                
                // 检查速度陷阱
                if (obstacle.isSpeedTrap) {
                    // 速度陷阱，根据速度决定伤害
                    console.log('进入速度陷阱');
                    if (this.speedMultiplier > 10) {
                        this.lives--;
                        if (this.lives <= 0) {
                            // 没有生命了，启动凋零动画
                            this.lives = 0; // 确保生命值为0
                            this.startEvolutionMode('death');
                        } else {
                            this.resetDinoState();
                        }
                    }
                    this.obstacles.splice(i, 1);
                    continue;
                }
                
                // 普通障碍物碰撞，使用生命系统
                if (!this.isInvincible && !this.isEvolutionMode) {
                    // 不处于治愈状态且不在进化动画时的特殊处理
                    this.lives--;
                    console.log(`💔 碰到负面干扰！生命减少！当前生命：${this.lives}`);
                    
                    // 获得爱心磁铁
                    this.generateMagnet();
                    console.log(`💖 获得爱心磁铁！世界给予温暖！`);
                    
                    if (this.lives <= 0) {
                        // 没有生命了，启动凋零动画
                        this.lives = 0; // 确保生命值为0
                        this.startEvolutionMode('death');
                        // 凋零动画结束后会自动检查是否获得爱心道具
                    } else {
                        // 还有生命，启动重生动画
                        this.startEvolutionMode('rebirth');
                        // 重置DIMOO位置
                        this.resetDinoState();
                    }
                    
                    // 移除碰撞的障碍物
                    this.obstacles.splice(i, 1);
                } else if (this.isEvolutionMode && this.evolutionType === 'death') {
                    // 凋零阶段碰到障碍物，不减少生命，但移除障碍物
                    console.log(`💀 凋零阶段碰到障碍物，继续寻找爱与希望！`);
                    // 移除碰撞的障碍物
                    this.obstacles.splice(i, 1);
                } else {
                    // 治愈状态下免疫伤害
                    console.log(`💖 治愈状态免疫负面干扰！`);
                    // 移除碰撞的障碍物
                    this.obstacles.splice(i, 1);
                }
                continue; // 避免多次触发
            }
        }
    }
    
    // 网络检测机制
    startNetworkCheck() {
        // 清除之前的定时器
        this.stopNetworkCheck();
        
        // 开始网络检测
        this.dimoo.networkCheckTimer = setInterval(() => {
            this.checkNetworkStatus();
        }, this.dimoo.networkCheckInterval);
    }
    
    stopNetworkCheck() {
        if (this.dimoo.networkCheckTimer) {
            clearInterval(this.dimoo.networkCheckTimer);
            this.dimoo.networkCheckTimer = null;
        }
    }
    
    // 无敌状态方法
    startInvincibleMode() {
        this.isInvincible = true;
        this.invincibleStartTime = Date.now();
        
        // 进入定期治愈状态时增加一条生命
        if (this.lives < this.maxLives) {
            this.lives++;
            console.log(`💖 定期治愈状态启动！获得一条生命！当前生命：${this.lives}/${this.maxLives}`);
        }
        
        // 定期治愈状态提升速度（翻2倍，最高15倍）
        this.speedMultiplier = Math.min(this.speedMultiplier * 2.0, 15);
        this.speed = this.baseSpeed * this.speedMultiplier;
        
        // 定期治愈状态期间速度翻两倍，最高不超过25倍
        const invincibleSpeedMultiplier = Math.min(this.speedMultiplier * 2.0, 25);
        this.invincibleSpeedMultiplier = invincibleSpeedMultiplier;
        this.originalSpeedMultiplier = this.speedMultiplier;
        this.speedMultiplier = invincibleSpeedMultiplier;
        this.speed = this.baseSpeed * this.speedMultiplier;
        
        console.log(`🌟 定期治愈状态启动！持续5秒，速度提升至 ${invincibleSpeedMultiplier.toFixed(1)}x，等级：${this.invincibleLevel}`);
    }
    
    stopInvincibleMode() {
        this.isInvincible = false;
        
        // 累计治愈时间（用于胜利条件）
        if (this.lastHealingStartTime) {
            const healingDuration = Date.now() - this.lastHealingStartTime;
            this.totalHealingTime += healingDuration;
            this.lastHealingStartTime = 0;
            console.log(`💖 累计治愈时间：${(this.totalHealingTime / 1000 / 60).toFixed(1)}分钟`);
        }
        
        // 恢复原始速度
        if (this.originalSpeedMultiplier !== undefined) {
            this.speedMultiplier = this.originalSpeedMultiplier;
            this.speed = this.baseSpeed * this.speedMultiplier;
            console.log(`🌟 定期治愈状态结束，速度恢复至 ${this.speedMultiplier.toFixed(1)}x`);
        } else {
            console.log('🌟 定期治愈状态结束');
        }
    }
    
    startGemInvincibleMode() {
        this.isInvincible = true;
        this.invincibleStartTime = Date.now();
        this.invincibleDuration = 4000; // 4秒治愈状态
        
        // 记录治愈开始时间（用于胜利条件）
        if (!this.lastHealingStartTime) {
            this.lastHealingStartTime = Date.now();
        }
        
        // 治愈状态只获得生命，不提升速度
        if (this.lives < this.maxLives) {
            this.lives++;
                            console.log(`💖 爱与希望宝石治愈状态启动！获得一条生命！当前生命：${this.lives}/${this.maxLives}`);
        } else {
                            console.log(`💖 爱与希望宝石治愈状态启动！持续4秒，负面干扰无法伤害你！`);
        }
    }
    
    reduceSpeedByHalf() {
        // 世界变得更温柔，负面干扰减少
        const minSpeed = this.baseSpeed * 0.5; // 最低速度为基础速度的一半
        this.speedMultiplier = Math.max(this.speedMultiplier * 0.5, 0.5);
        this.speed = this.baseSpeed * this.speedMultiplier;
        console.log(`🌍 世界变得更温柔！负面干扰减少，当前速度倍数：${this.speedMultiplier.toFixed(1)}x`);
    }
    
    generateMagnet() {
        // 生成爱心磁铁 - 代表世界给予的爱和温暖
        const magnetX = this.width + 100;
        const magnetY = Math.random() * (this.height - 200) + 100;
        
        this.magnets = this.magnets || [];
        this.magnets.push({
            x: magnetX,
            y: magnetY,
            width: 20,
            height: 20,
            collected: false,
            color: '#FF69B4', // 粉色爱心磁铁
            sparkle: 0
        });
    }
    
    startMagnet() {
        this.isMagnetActive = true;
        this.magnetStartTime = Date.now();
        console.log(`💖 爱心磁铁激活！持续6秒，世界给予的爱自动收集！`);
    }
    
    stopMagnet() {
        this.isMagnetActive = false;
        // 清理吸附的宝石
        this.attractingGems = [];
        console.log(`💖 爱心磁铁效果结束！`);
    }
    
    startEvolutionMode(type = 'rebirth') {
        this.isEvolutionMode = true;
        this.evolutionType = type;
        this.evolutionStartTime = Date.now();
        this.evolutionAnimationFrame = 0;
        
        // 根据类型设置不同的持续时间
        if (type === 'death') {
            this.evolutionDuration = 5000; // 凋零动画持续5秒
        } else {
            this.evolutionDuration = 3000; // 重生动画持续3秒
        }
        
        // 预生成粒子数据以提高性能
        if (type === 'death') {
            this.evolutionParticles = [];
            for (let i = 0; i < 20; i++) {
                this.evolutionParticles.push({
                    x: Math.random() * this.dimoo.width,
                    y: Math.random() * this.dimoo.height,
                    size: Math.random() * 3 + 1
                });
            }
        } else if (type === 'rebirth') {
            this.evolutionStars = [];
            for (let i = 0; i < 8; i++) {
                this.evolutionStars.push({
                    angle: (i / 8) * Math.PI * 2,
                    radius: 15 + Math.random() * 10
                });
            }
        }
        
        if (type === 'rebirth') {
            // 重生动画：35倍速度，获得吸铁石
            this.evolutionSpeedMultiplier = 35;
            this.originalSpeedMultiplier = this.speedMultiplier;
            this.speedMultiplier = this.evolutionSpeedMultiplier;
            this.speed = this.baseSpeed * this.speedMultiplier;
            
            // 激活吸铁石，让重生时收集希望
            this.startMagnet();
            
            console.log(`🌟 重生动画启动！3秒内速度提升至35x，获得爱心磁铁！`);
        } else if (type === 'death') {
            // 凋零动画：全速冲刺，获得吸铁石，持续5秒
            this.evolutionSpeedMultiplier = 50; // 全速冲刺
            this.originalSpeedMultiplier = this.speedMultiplier;
            this.speedMultiplier = this.evolutionSpeedMultiplier;
            this.speed = this.baseSpeed * this.speedMultiplier;
            
            // 激活吸铁石，让凋零前收集最后的希望
            this.startMagnet();
            
            console.log(`💀 凋零动画启动！5秒内全速冲刺50x，获得爱心磁铁！`);
        }
    }
    
    stopEvolutionMode() {
        this.isEvolutionMode = false;
        
        // 清理缓存数据
        this.evolutionParticles = [];
        this.evolutionStars = [];
        
        if (this.evolutionType === 'rebirth') {
            // 重生动画结束，速度减半，停止吸铁石
            this.stopMagnet();
            if (this.originalSpeedMultiplier !== undefined) {
                // 重生后速度减半，但保持最低速度
                const newSpeedMultiplier = Math.max(this.originalSpeedMultiplier * 0.5, 0.6);
                this.speedMultiplier = newSpeedMultiplier;
                this.speed = this.baseSpeed * this.speedMultiplier;
                console.log(`🌟 重生动画结束，速度减半至 ${this.speedMultiplier.toFixed(1)}x，停止爱心磁铁`);
            } else {
                console.log('🌟 重生动画结束，停止爱心磁铁');
            }
        } else if (this.evolutionType === 'death') {
            // 凋零动画结束，停止吸铁石
            this.stopMagnet();
            // 检查是否在凋零期间获得了爱心道具
            if (this.lives > 0) {
                // 获得了爱心道具，继续游戏
                console.log('💀 凋零动画结束，但获得了爱心道具，继续游戏！');
            } else {
                // 没有获得爱心道具，游戏结束
                console.log('💀 凋零动画结束，没有获得爱心道具，游戏结束');
                this.gameOver = true;
                this.gameRunning = false;
                this.showGameOver();
            }
        }
    }
    
    // 性能监控和优化
    checkPerformance() {
        const currentTime = Date.now();
        this.frameCount++;
        
        // 每秒检查一次性能
        if (currentTime - this.lastFrameTime >= 1000) {
            const actualFps = this.frameCount;
            this.frameCount = 0;
            this.lastFrameTime = currentTime;
            
            // 如果帧率过低，进行性能优化
            if (actualFps < 30) {
                console.warn(`⚠️ 性能警告：当前帧率 ${actualFps} FPS，进行性能优化`);
                this.optimizePerformance();
            }
        }
    }
    
    // 性能优化
    optimizePerformance() {
        // 减少粒子数量
        if (this.evolutionParticles && this.evolutionParticles.length > 10) {
            this.evolutionParticles = this.evolutionParticles.slice(0, 10);
        }
        
        // 减少星星数量
        if (this.evolutionStars && this.evolutionStars.length > 4) {
            this.evolutionStars = this.evolutionStars.slice(0, 4);
        }
        
        // 清理过多的障碍物和宝石
        if (this.obstacles.length > 20) {
            this.obstacles = this.obstacles.slice(-15);
        }
        
        if (this.gems.length > 30) {
            this.gems = this.gems.slice(-20);
        }
        
        console.log('🔧 性能优化完成');
    }
    
    checkNetworkStatus() {
        // 检测网络连接
        if (navigator.onLine) {
            console.log('🌐 网络连接已恢复');
            this.stopNetworkCheck();
            // 可以在这里添加网络恢复后的处理逻辑
        } else {
            console.log('📡 网络连接仍然断开');
        }
    }
    
    showGameOver() {
        document.getElementById('finalScore').textContent = this.score;
        document.getElementById('gameOver').style.display = 'block';
        
        // 游戏结束后开始网络检测
        this.startNetworkCheck();
        
        // 关闭自动弹窗，只在游戏结束时显示一次
        // 不再自动刷新页面，等待网络检测
        // setTimeout(() => {
        //     window.location.reload();
        // }, 3000);
    }
    
            // 优化DIMOO绘制 - 更可爱的形象，腿接触地面，优化行走姿态，DIMOO和腿结合
    drawDimoo() {
        const x = this.dimoo.x;
        const y = this.dimoo.y;
        const width = this.dimoo.width;
        const height = this.dimoo.height;
        
        // 进化模式动画效果
        if (this.isEvolutionMode) {
            this.drawEvolutionAnimation(x, y, width, height);
            return;
        }
        
        if (this.dimoo.ducking) {
            // 下蹲状态 - 不改变大小，只改变姿态
            this.drawDuckingDimoo(x, y, width, height);
        } else {
            // 正常状态 - 可爱的奔跑DIMOO
            this.drawRunningDimoo(x, y, width, height);
        }
    }
    
    drawRunningDimoo(x, y, width, height) {
        // 无敌状态下的飞行超人姿态
        if (this.isInvincible) {
            this.drawSupermanDimoo(x, y, width, height);
            return;
        }
        
        // 获取当前形态的数据
        const formData = this.dimoo.forms[this.dimoo.form];
        const features = formData.features;
        
        // 绘制发光光环效果
        this.drawAuraEffect(x, y, features.aura);
        
        // 绘制太空服主体
        this.drawFuturisticSuit(x, y, features.suit, features.suitColor, features.suitAccents, features.suitGlow);
        
        // 绘制背包
        this.drawSpaceBackpack(x, y, features.backpack);
        
        // 绘制装饰丝带和管子
        this.drawSpaceDecorations(x, y, features.ribbons, features.tubes);
        
        // 绘制身体
        this.drawAlienBody(x, y, features.head, features.skin);
        
        // 绘制腮红
        this.drawCheeks(x, y, features.cheeks);
        
        // 绘制头发
        this.drawAlienHair(x, y, features.hair, features.hairStyle, features.hairColor);
        
        // 绘制触角
        this.drawAlienAntennae(x, y, features.antennae, features.antennaColor, features.antennaGlow, features.antennaTips);
        
        // 绘制耳朵
        this.drawAlienEars(x, y, features.ears, features.earColor);
        
        // 绘制眼睛
        this.drawAlienEyes(x, y, features.eyes, features.eyeColor, features.eyeGlow, features.eyeHighlights);
        
        // 绘制嘴巴
        this.drawAlienMouth(x, y, features.mouth, features.mouthColor);
        
        // 绘制小鼻子
        this.drawAlienNose(x, y);
        
        // 绘制鞋子
        this.drawSpaceShoes(x, y, features.shoes, features.shoeColor, features.shoeAccents);
        
        // 绘制装饰图案
        this.drawSpaceDecorations(x, y, features.decorations);
        
        // 绘制整体发光效果
        this.drawOverallGlow(x, y, features.glow);
        
        // 绘制闪烁效果
        this.drawSparkleEffect(x, y, features.sparkle);
        
        // 滑翔时不改变形象，只添加翅膀效果
        if (this.dimoo.isGliding && this.dimoo.isGlideKeyPressed) {
            this.drawGlideWings(x, y);
        }
        
        // 无敌状态特效
        if (this.isInvincible) {
            this.drawInvincibleEffect(x, y, width, height);
        }
    }
    
    // 绘制进化动画
    drawEvolutionAnimation(x, y, width, height) {
        const currentTime = Date.now();
        const elapsed = currentTime - this.evolutionStartTime;
        const progress = Math.min(elapsed / this.evolutionDuration, 1);
        
        // 更新动画帧
        this.evolutionAnimationFrame = Math.floor(progress * 60); // 60帧动画
        
        if (this.evolutionType === 'rebirth') {
            this.drawRebirthAnimation(x, y, width, height, progress);
        } else if (this.evolutionType === 'death') {
            this.drawDeathAnimation(x, y, width, height, progress);
        }
    }
    
    // 绘制重生动画 - 基于新的DIMOO形象
    drawRebirthAnimation(x, y, width, height, progress) {
        // 重生光芒效果
        const glowIntensity = Math.sin(progress * Math.PI * 4) * 0.5 + 0.5;
        const glowRadius = 25 + progress * 35;
        const time = Date.now() * 0.01;
        
        // 外圈光芒 - 金色
        this.ctx.fillStyle = `rgba(255, 215, 0, ${0.4 * glowIntensity})`;
        this.ctx.beginPath();
        this.ctx.arc(x + width/2, y + height/2, glowRadius, 0, Math.PI * 2);
        this.ctx.fill();
        
        // 中圈光芒 - 白色
        this.ctx.fillStyle = `rgba(255, 255, 255, ${0.6 * glowIntensity})`;
        this.ctx.beginPath();
        this.ctx.arc(x + width/2, y + height/2, glowRadius * 0.7, 0, Math.PI * 2);
        this.ctx.fill();
        
        // 内圈光芒 - 彩虹色
        this.ctx.fillStyle = `hsl(${(time * 100) % 360}, 70%, 60%, ${0.8 * glowIntensity})`;
        this.ctx.beginPath();
        this.ctx.arc(x + width/2, y + height/2, glowRadius * 0.4, 0, Math.PI * 2);
        this.ctx.fill();
        
        // 旋转的星星效果
        if (this.evolutionStars) {
            for (let i = 0; i < this.evolutionStars.length; i++) {
                const star = this.evolutionStars[i];
                const currentAngle = star.angle + progress * Math.PI * 6;
                const currentRadius = star.radius + progress * 25;
                const starX = x + width/2 + Math.cos(currentAngle) * currentRadius;
                const starY = y + height/2 + Math.sin(currentAngle) * currentRadius;
                
                // 星星颜色渐变
                const starColor = `hsl(${(time * 50 + i * 30) % 360}, 80%, 60%)`;
                this.ctx.fillStyle = starColor;
                this.ctx.beginPath();
                this.ctx.arc(starX, starY, 4, 0, Math.PI * 2);
                this.ctx.fill();
                
                // 星星光芒
                this.ctx.strokeStyle = 'rgba(255, 255, 255, 0.8)';
                this.ctx.lineWidth = 1;
                this.ctx.beginPath();
                this.ctx.moveTo(starX - 6, starY);
                this.ctx.lineTo(starX + 6, starY);
                this.ctx.moveTo(starX, starY - 6);
                this.ctx.lineTo(starX, starY + 6);
                this.ctx.stroke();
            }
        }
        
        // DIMOO身体 - 重生时变大并发光
        const scale = 1 + progress * 0.4;
        const scaledWidth = width * scale;
        const scaledHeight = height * scale;
        const scaledX = x - (scaledWidth - width) / 2;
        const scaledY = y - (scaledHeight - height) / 2;
        
        // 身体光环
        this.ctx.shadowColor = 'rgba(255, 215, 0, 0.8)';
        this.ctx.shadowBlur = 15 * glowIntensity;
        
        // 身体 - 金色发光
        this.ctx.fillStyle = `rgba(255, 215, 0, ${0.9 + 0.1 * glowIntensity})`;
        this.ctx.fillRect(scaledX + 10, scaledY + 20, scaledWidth - 20, scaledHeight - 20);
        
        // 头部 - 金色发光
        this.ctx.fillStyle = `rgba(255, 215, 0, ${0.9 + 0.1 * glowIntensity})`;
        this.ctx.beginPath();
        this.ctx.arc(scaledX + 35, scaledY + 15, 18 * scale, 0, Math.PI * 2);
        this.ctx.fill();
        
        // 眼睛 - 发光的眼睛
        this.ctx.fillStyle = `rgba(255, 255, 255, ${0.95 + 0.05 * glowIntensity})`;
        this.ctx.beginPath();
        this.ctx.arc(scaledX + 38, scaledY + 12, 7 * scale, 0, Math.PI * 2);
        this.ctx.fill();
        
        this.ctx.fillStyle = `rgba(255, 215, 0, ${0.95 + 0.05 * glowIntensity})`;
        this.ctx.beginPath();
        this.ctx.arc(scaledX + 40, scaledY + 12, 4 * scale, 0, Math.PI * 2);
        this.ctx.fill();
        
        // 嘴巴 - 微笑
        this.ctx.strokeStyle = `rgba(255, 255, 255, ${0.9 + 0.1 * glowIntensity})`;
        this.ctx.lineWidth = 2 * scale;
        this.ctx.beginPath();
        this.ctx.arc(scaledX + 35, scaledY + 20, 8 * scale, 0, Math.PI);
        this.ctx.stroke();
        
        // 触角 - 发光
        this.ctx.strokeStyle = `rgba(255, 215, 0, ${0.8 + 0.2 * glowIntensity})`;
        this.ctx.lineWidth = 3 * scale;
        this.ctx.beginPath();
        this.ctx.moveTo(scaledX + 30, scaledY + 8);
        this.ctx.quadraticCurveTo(scaledX + 25, scaledY + 2, scaledX + 20, scaledY + 5);
        this.ctx.moveTo(scaledX + 40, scaledY + 8);
        this.ctx.quadraticCurveTo(scaledX + 45, scaledY + 2, scaledX + 50, scaledY + 5);
        this.ctx.stroke();
        
        // 翅膀 - 重生时展开
        if (progress > 0.3) {
            const wingProgress = (progress - 0.3) / 0.7;
            const wingSize = 20 * wingProgress;
            this.ctx.fillStyle = `rgba(255, 215, 0, ${0.8 * wingProgress})`;
            
            // 左翅膀
            this.ctx.beginPath();
            this.ctx.ellipse(scaledX - 10, scaledY + 30, wingSize, wingSize * 0.6, 0, 0, Math.PI * 2);
            this.ctx.fill();
            
            // 右翅膀
            this.ctx.beginPath();
            this.ctx.ellipse(scaledX + 60, scaledY + 30, wingSize, wingSize * 0.6, 0, 0, Math.PI * 2);
            this.ctx.fill();
        }
        
        // 重置阴影
        this.ctx.shadowBlur = 0;
        
        // 重生文字
        this.ctx.fillStyle = `rgba(255, 215, 0, ${0.9 + 0.1 * glowIntensity})`;
        this.ctx.font = 'bold 24px Arial';
        this.ctx.textAlign = 'center';
        this.ctx.fillText('🌟 重生！', x + width/2, y - 25);
        this.ctx.textAlign = 'left';
    }
    
    // 绘制死亡动画 - 基于新的DIMOO形象
    drawDeathAnimation(x, y, width, height, progress) {
        // 凋零效果
        const fadeIntensity = 1 - progress;
        const grayScale = progress * 0.9;
        const time = Date.now() * 0.01;
        
        // 暗色滤镜效果
        this.ctx.fillStyle = `rgba(64, 64, 64, ${grayScale})`;
        this.ctx.fillRect(x, y, width, height);
        
        // 身体 - 逐渐变暗
        this.ctx.fillStyle = `rgba(80, 80, 80, ${fadeIntensity})`;
        this.ctx.fillRect(x + 10, y + 20, width - 20, height - 20);
        
        // 头部 - 逐渐变暗
        this.ctx.fillStyle = `rgba(80, 80, 80, ${fadeIntensity})`;
        this.ctx.beginPath();
        this.ctx.arc(x + 35, y + 15, 18, 0, Math.PI * 2);
        this.ctx.fill();
        
        // 眼睛 - 逐渐失去光芒
        this.ctx.fillStyle = `rgba(60, 60, 60, ${fadeIntensity})`;
        this.ctx.beginPath();
        this.ctx.arc(x + 38, y + 12, 7, 0, Math.PI * 2);
        this.ctx.fill();
        
        this.ctx.fillStyle = `rgba(30, 30, 30, ${fadeIntensity})`;
        this.ctx.beginPath();
        this.ctx.arc(x + 40, y + 12, 4, 0, Math.PI * 2);
        this.ctx.fill();
        
        // 嘴巴 - 悲伤
        this.ctx.strokeStyle = `rgba(60, 60, 60, ${fadeIntensity})`;
        this.ctx.lineWidth = 2;
        this.ctx.beginPath();
        this.ctx.arc(x + 35, y + 20, 8, Math.PI, Math.PI * 2);
        this.ctx.stroke();
        
        // 触角 - 下垂
        this.ctx.strokeStyle = `rgba(60, 60, 60, ${fadeIntensity})`;
        this.ctx.lineWidth = 3;
        this.ctx.beginPath();
        this.ctx.moveTo(x + 30, y + 8);
        this.ctx.quadraticCurveTo(x + 25, y + 2, x + 20, y + 8);
        this.ctx.moveTo(x + 40, y + 8);
        this.ctx.quadraticCurveTo(x + 45, y + 2, x + 50, y + 8);
        this.ctx.stroke();
        
        // 翅膀 - 凋零时萎缩
        if (progress < 0.7) {
            const wingProgress = 1 - progress / 0.7;
            const wingSize = 15 * wingProgress;
            this.ctx.fillStyle = `rgba(60, 60, 60, ${fadeIntensity * wingProgress})`;
            
            // 左翅膀
            this.ctx.beginPath();
            this.ctx.ellipse(x - 10, y + 30, wingSize, wingSize * 0.6, 0, 0, Math.PI * 2);
            this.ctx.fill();
            
            // 右翅膀
            this.ctx.beginPath();
            this.ctx.ellipse(x + 60, y + 30, wingSize, wingSize * 0.6, 0, 0, Math.PI * 2);
            this.ctx.fill();
        }
        
        // 凋零粒子效果
        if (this.evolutionParticles) {
            for (let i = 0; i < this.evolutionParticles.length; i++) {
                const particle = this.evolutionParticles[i];
                const particleX = x + particle.x;
                const particleY = y + particle.y;
                
                // 粒子逐渐消失
                const particleAlpha = fadeIntensity * (1 - progress) * 0.6;
                this.ctx.fillStyle = `rgba(80, 80, 80, ${particleAlpha})`;
                this.ctx.beginPath();
                this.ctx.arc(particleX, particleY, particle.size, 0, Math.PI * 2);
                this.ctx.fill();
            }
        }
        
        // 凋零文字
        this.ctx.fillStyle = `rgba(100, 100, 100, ${fadeIntensity})`;
        this.ctx.font = '18px Arial';
        this.ctx.textAlign = 'center';
        this.ctx.fillText('💀 凋零...', x + width/2, y - 20);
        this.ctx.textAlign = 'left';
    }
    

    
    drawDuckingDimoo(x, y, width, height) {
        // 获取当前形态的数据
        const formData = this.dimoo.forms[this.dimoo.form];
        const bodyColor = formData.color;
        const eyeColor = formData.eyeColor;
        const skinColor = formData.skinColor;
        const features = formData.features;
        
        // 下蹲姿态重新设计 - 使用缩放和精确定位
        const scale = 0.8; // 整体缩放比例
        const scaledWidth = width * scale;
        const scaledHeight = height * scale;
        const scaledX = x + (width - scaledWidth) / 2;
        const scaledY = y + (height - scaledHeight) / 2 + 45; // 下移45px确保接触地面
        
        // 下蹲身体 - 使用缩放后的坐标
        this.ctx.fillStyle = bodyColor;
        this.ctx.strokeStyle = '#000000';
        this.ctx.lineWidth = 1;
        this.ctx.fillRect(scaledX + 10, scaledY + 20, scaledWidth - 20, scaledHeight - 20);
        this.ctx.strokeRect(scaledX + 10, scaledY + 20, scaledWidth - 20, scaledHeight - 20);
        
        // 下蹲头部 - 使用缩放后的坐标
        this.ctx.fillStyle = bodyColor;
        this.ctx.beginPath();
        this.ctx.arc(scaledX + 35, scaledY + 15, 18 * scale, 0, Math.PI * 2);
        this.ctx.fill();
        this.ctx.stroke();
        
        // 下蹲眼睛 - 使用缩放后的坐标
        this.ctx.fillStyle = 'white';
        this.ctx.beginPath();
        this.ctx.arc(scaledX + 38, scaledY + 12, 7 * scale, 0, Math.PI * 2);
        this.ctx.fill();
        
        this.ctx.strokeStyle = '#000000';
        this.ctx.lineWidth = 1;
        this.ctx.beginPath();
        this.ctx.arc(scaledX + 38, scaledY + 12, 7 * scale, 0, Math.PI * 2);
        this.ctx.stroke();
        
        // 下蹲眼睛瞳孔 - 使用缩放后的坐标
        this.ctx.fillStyle = eyeColor;
        this.ctx.beginPath();
        this.ctx.arc(scaledX + 40, scaledY + 12, 4 * scale, 0, Math.PI * 2);
        this.ctx.fill();
        
        // 下蹲嘴巴 - 使用缩放后的坐标
        this.ctx.strokeStyle = '#000000';
        this.ctx.lineWidth = 1;
        this.ctx.beginPath();
        this.ctx.arc(scaledX + 35, scaledY + 20, 8 * scale, 0, Math.PI);
        this.ctx.stroke();
        
        // 下蹲触角 - 使用缩放后的坐标
        this.ctx.strokeStyle = features.antennaColor || '#FFD700';
        this.ctx.lineWidth = 2 * scale;
        this.ctx.beginPath();
        this.ctx.moveTo(scaledX + 30, scaledY + 8);
        this.ctx.quadraticCurveTo(scaledX + 25, scaledY + 2, scaledX + 20, scaledY + 5);
        this.ctx.moveTo(scaledX + 40, scaledY + 8);
        this.ctx.quadraticCurveTo(scaledX + 45, scaledY + 2, scaledX + 50, scaledY + 5);
        this.ctx.stroke();
        
        // 下蹲腿部 - 使用缩放后的坐标
        this.drawDuckingDimooLegs(scaledX, scaledY, scaledHeight, bodyColor, scale);
    }
    
    // 绘制下蹲DIMOO腿部
    drawDuckingDimooLegs(x, y, height, bodyColor, scale = 1) {
        this.ctx.fillStyle = bodyColor;
        this.ctx.strokeStyle = '#000000';
        this.ctx.lineWidth = 1;
        
        // 下蹲时的两条腿 - 使用缩放后的坐标
        // 第一条腿
        this.ctx.beginPath();
        this.ctx.ellipse(x + 20, y + 85, 5 * scale, 8 * scale, 0, 0, Math.PI * 2);
        this.ctx.fill();
        this.ctx.stroke();
        
        // 第二条腿
        this.ctx.beginPath();
        this.ctx.ellipse(x + 30, y + 85, 5 * scale, 8 * scale, 0, 0, Math.PI * 2);
        this.ctx.fill();
        this.ctx.stroke();
        
        // 小脚丫 - 使用缩放后的坐标
        this.ctx.fillStyle = '#FF69B4';
        this.ctx.beginPath();
        this.ctx.arc(x + 20, y + 93, 3 * scale, 0, Math.PI * 2);
        this.ctx.fill();
        this.ctx.beginPath();
        this.ctx.arc(x + 30, y + 93, 3 * scale, 0, Math.PI * 2);
        this.ctx.fill();
    }
    
    // ===== 全新绘制函数系统 =====
    
    // 绘制发光光环效果
    drawAuraEffect(x, y, auraType) {
        if (auraType === 'none') return;
        
        const time = Date.now() * 0.001;
        const pulse = Math.sin(time * 2) * 0.3 + 0.7;
        
        switch(auraType) {
            case 'subtle':
                this.ctx.fillStyle = `rgba(135, 206, 235, ${0.1 * pulse})`;
                this.ctx.beginPath();
                this.ctx.arc(x + 35, y + 25, 35, 0, Math.PI * 2);
                this.ctx.fill();
                break;
            case 'moderate':
                this.ctx.fillStyle = `rgba(50, 205, 50, ${0.2 * pulse})`;
                this.ctx.beginPath();
                this.ctx.arc(x + 35, y + 25, 40, 0, Math.PI * 2);
                this.ctx.fill();
                break;
            case 'magical':
                // 彩虹光环
                const colors = ['#FF69B4', '#FFD700', '#87CEEB', '#32CD32', '#FF6347', '#9370DB'];
                for (let i = 0; i < 6; i++) {
                    this.ctx.fillStyle = `rgba(${colors[i]}, ${0.15 * pulse})`;
                    this.ctx.beginPath();
                    this.ctx.arc(x + 35, y + 25, 45 + i * 2, 0, Math.PI * 2);
                    this.ctx.fill();
                }
                break;
        }
    }
    
    // 绘制未来风格太空服
    drawFuturisticSuit(x, y, suitType, suitColor, suitAccents, suitGlow) {
        // 太空服主体
        this.ctx.fillStyle = suitColor;
        this.ctx.strokeStyle = '#000000';
        this.ctx.lineWidth = 2;
        
        // 身体部分
        this.ctx.beginPath();
        this.ctx.ellipse(x + 35, y + 25, 20, 15, 0, 0, Math.PI * 2);
        this.ctx.fill();
        this.ctx.stroke();
        
        // 胸部面板
        this.ctx.fillStyle = '#FFFFFF';
        this.ctx.beginPath();
        this.ctx.ellipse(x + 35, y + 25, 15, 10, 0, 0, Math.PI * 2);
        this.ctx.fill();
        
        // 根据类型添加装饰
        switch(suitType) {
            case 'light_futuristic':
                // 浅色未来风格 - 黄色星星装饰
                this.ctx.fillStyle = '#FFD700';
                this.ctx.beginPath();
                this.ctx.arc(x + 35, y + 25, 5, 0, Math.PI * 2);
                this.ctx.fill();
                break;
            case 'colorful_futuristic':
                // 彩色未来风格 - 彩色图案
                const colors = ['#FF69B4', '#87CEEB', '#32CD32'];
                for (let i = 0; i < 3; i++) {
                    this.ctx.fillStyle = colors[i];
                    this.ctx.beginPath();
                    this.ctx.arc(x + 30 + i * 5, y + 20, 2, 0, Math.PI * 2);
                    this.ctx.fill();
                }
                break;
            case 'pastel_futuristic':
                // 粉彩未来风格 - 柔和装饰
                this.ctx.fillStyle = '#FFE4B5';
                this.ctx.beginPath();
                this.ctx.arc(x + 35, y + 25, 4, 0, Math.PI * 2);
                this.ctx.fill();
                break;
            case 'iridescent_futuristic':
                // 彩虹未来风格 - 彩虹装饰
                const rainbowColors = ['#FF69B4', '#FFD700', '#87CEEB', '#32CD32', '#FF6347', '#9370DB'];
                for (let i = 0; i < 6; i++) {
                    this.ctx.fillStyle = rainbowColors[i];
                    this.ctx.beginPath();
                    this.ctx.arc(x + 28 + i * 3, y + 18, 1.5, 0, Math.PI * 2);
                    this.ctx.fill();
                }
                break;
        }
        
        // 发光效果
        if (suitGlow !== 'none') {
            this.ctx.shadowColor = suitGlow === 'mint_green' ? '#98FB98' : 
                                  suitGlow === 'warm_light' ? '#FFE4B5' : '#FFD700';
            this.ctx.shadowBlur = 10;
            this.ctx.beginPath();
            this.ctx.ellipse(x + 35, y + 25, 20, 15, 0, 0, Math.PI * 2);
            this.ctx.fill();
            this.ctx.shadowColor = 'transparent';
            this.ctx.shadowBlur = 0;
        }
    }
    
    // 绘制太空背包
    drawSpaceBackpack(x, y, backpackType) {
        if (backpackType === 'none') return;
        
        switch(backpackType) {
            case 'small_light':
                this.ctx.fillStyle = '#E6E6FA';
                this.ctx.strokeStyle = '#9370DB';
                this.ctx.lineWidth = 1;
                break;
            case 'medium_colorful':
                this.ctx.fillStyle = '#98FB98';
                this.ctx.strokeStyle = '#32CD32';
                this.ctx.lineWidth = 2;
                break;
            case 'large_pastel':
                this.ctx.fillStyle = '#FFE4B5';
                this.ctx.strokeStyle = '#FFD700';
                this.ctx.lineWidth = 2;
                break;
            case 'magical_rainbow':
                this.ctx.fillStyle = '#FF69B4';
                this.ctx.strokeStyle = '#9370DB';
                this.ctx.lineWidth = 3;
                break;
        }
        
        // 背包主体
        this.ctx.beginPath();
        this.ctx.ellipse(x + 35, y + 35, 12, 8, 0, 0, Math.PI * 2);
        this.ctx.fill();
        this.ctx.stroke();
        
        // 背包带子
        this.ctx.strokeStyle = '#000000';
        this.ctx.lineWidth = 2;
        this.ctx.beginPath();
        this.ctx.moveTo(x + 25, y + 25);
        this.ctx.lineTo(x + 25, y + 35);
        this.ctx.stroke();
        this.ctx.beginPath();
        this.ctx.moveTo(x + 45, y + 25);
        this.ctx.lineTo(x + 45, y + 35);
        this.ctx.stroke();
        
        // 魔法背包的发光效果
        if (backpackType === 'magical_rainbow') {
            this.ctx.fillStyle = '#FFD700';
            this.ctx.shadowColor = '#FFD700';
            this.ctx.shadowBlur = 15;
            this.ctx.beginPath();
            this.ctx.arc(x + 35, y + 35, 4, 0, Math.PI * 2);
            this.ctx.fill();
            this.ctx.shadowColor = 'transparent';
            this.ctx.shadowBlur = 0;
        }
    }
    
    // 绘制太空装饰
    drawSpaceDecorations(x, y, ribbons, tubes) {
        // 绘制丝带
        if (ribbons !== 'none') {
            switch(ribbons) {
                case 'translucent_iridescent':
                    this.ctx.fillStyle = 'rgba(255, 105, 180, 0.7)';
                    this.ctx.beginPath();
                    this.ctx.ellipse(x + 35, y + 20, 8, 3, Math.PI / 4, 0, Math.PI * 2);
                    this.ctx.fill();
                    break;
                case 'magical_rainbow':
                    const colors = ['#FF69B4', '#FFD700', '#87CEEB', '#32CD32'];
                    for (let i = 0; i < 4; i++) {
                        this.ctx.fillStyle = `rgba(${colors[i]}, 0.8)`;
                        this.ctx.beginPath();
                        this.ctx.ellipse(x + 35, y + 18 + i * 2, 6, 2, Math.PI / 4, 0, Math.PI * 2);
                        this.ctx.fill();
                    }
                    break;
            }
        }
        
        // 绘制管子
        if (tubes !== 'none') {
            switch(tubes) {
                case 'yellow_wavy':
                    this.ctx.strokeStyle = '#FFD700';
                    this.ctx.lineWidth = 3;
                    this.ctx.beginPath();
                    this.ctx.moveTo(x + 35, y + 25);
                    this.ctx.quadraticCurveTo(x + 45, y + 15, x + 55, y + 20);
                    this.ctx.stroke();
                    break;
                case 'colorful_wavy':
                    const tubeColors = ['#FF69B4', '#87CEEB', '#32CD32'];
                    for (let i = 0; i < 3; i++) {
                        this.ctx.strokeStyle = tubeColors[i];
                        this.ctx.lineWidth = 2;
                        this.ctx.beginPath();
                        this.ctx.moveTo(x + 35, y + 25 + i * 2);
                        this.ctx.quadraticCurveTo(x + 45, y + 15 + i * 2, x + 55, y + 20 + i * 2);
                        this.ctx.stroke();
                    }
                    break;
                case 'pastel_wavy':
                    this.ctx.strokeStyle = '#FFE4B5';
                    this.ctx.lineWidth = 3;
                    this.ctx.beginPath();
                    this.ctx.moveTo(x + 35, y + 25);
                    this.ctx.quadraticCurveTo(x + 45, y + 15, x + 55, y + 20);
                    this.ctx.stroke();
                    break;
                case 'rainbow_wavy':
                    const rainbowTubeColors = ['#FF69B4', '#FFD700', '#87CEEB', '#32CD32', '#FF6347', '#9370DB'];
                    for (let i = 0; i < 6; i++) {
                        this.ctx.strokeStyle = rainbowTubeColors[i];
                        this.ctx.lineWidth = 2;
                        this.ctx.beginPath();
                        this.ctx.moveTo(x + 35, y + 25 + i);
                        this.ctx.quadraticCurveTo(x + 45, y + 15 + i, x + 55, y + 20 + i);
                        this.ctx.stroke();
                    }
                    break;
            }
        }
    }
    
    // 绘制外星人身体
    drawAlienBody(x, y, headType, skinType) {
        const skinColor = skinType === 'light_peach' ? '#FFB6C1' : '#DEB887';
        
        // 大头圆脸
        this.ctx.fillStyle = skinColor;
        this.ctx.strokeStyle = '#000000';
        this.ctx.lineWidth = 1;
        this.ctx.beginPath();
        this.ctx.arc(x + 35, y + 15, 18, 0, Math.PI * 2);
        this.ctx.fill();
        this.ctx.stroke();
    }
    
    // 绘制腮红
    drawCheeks(x, y, cheeksType) {
        if (cheeksType === 'none') return;
        
        let cheekColor;
        switch(cheeksType) {
            case 'light_pink':
                cheekColor = '#FFB6C1';
                break;
            case 'rosy_pink':
                cheekColor = '#FF69B4';
                break;
            case 'bright_pink':
                cheekColor = '#FF1493';
                break;
            case 'glowing_pink':
                cheekColor = '#FF69B4';
                this.ctx.shadowColor = '#FF69B4';
                this.ctx.shadowBlur = 8;
                break;
        }
        
        this.ctx.fillStyle = cheekColor;
        this.ctx.beginPath();
        this.ctx.arc(x + 25, y + 18, 3, 0, Math.PI * 2);
        this.ctx.fill();
        this.ctx.beginPath();
        this.ctx.arc(x + 45, y + 18, 3, 0, Math.PI * 2);
        this.ctx.fill();
        
        if (cheeksType === 'glowing_pink') {
            this.ctx.shadowColor = 'transparent';
            this.ctx.shadowBlur = 0;
        }
    }
    
    // 绘制外星人头发
    drawAlienHair(x, y, hairType, hairStyle, hairColor) {
        this.ctx.fillStyle = hairColor;
        
        switch(hairStyle) {
            case 'fluffy_cloud':
                // 蓬松云朵状
                for (let i = 0; i < 8; i++) {
                    const offsetX = Math.sin(i * 0.5) * 2;
                    const offsetY = Math.cos(i * 0.5) * 2;
                    this.ctx.beginPath();
                    this.ctx.arc(x + 25 + i * 3 + offsetX, y - 8 + offsetY, 4, 0, Math.PI * 2);
                    this.ctx.fill();
                }
                break;
            case 'curly_fluffy':
                // 卷曲蓬松
                for (let i = 0; i < 7; i++) {
                    this.ctx.beginPath();
                    this.ctx.arc(x + 26 + i * 3, y - 6, 4, 0, Math.PI * 2);
                    this.ctx.fill();
                }
                break;
            case 'voluminous_curly':
                // 蓬松卷曲
                for (let i = 0; i < 7; i++) {
                    const wave = Math.sin(i * 0.8) * 1.5;
                    this.ctx.beginPath();
                    this.ctx.arc(x + 26 + i * 3, y - 7 + wave, 4.5, 0, Math.PI * 2);
                    this.ctx.fill();
                }
                break;
            case 'cotton_candy':
                // 棉花糖状
                for (let i = 0; i < 8; i++) {
                    const puff = Math.sin(i * 0.6) * 2;
                    this.ctx.beginPath();
                    this.ctx.arc(x + 25 + i * 3, y - 8 + puff, 5, 0, Math.PI * 2);
                    this.ctx.fill();
                }
                break;
            case 'dreamy_fluffy':
                // 梦幻蓬松状 - 棉花糖般蓬松的淡橙色发型
                this.ctx.shadowColor = hairColor;
                this.ctx.shadowBlur = 8;
                for (let i = 0; i < 9; i++) {
                    const dreamyPuff = Math.sin(i * 0.7) * 3;
                    const softWave = Math.cos(i * 0.5) * 1.5;
                    this.ctx.beginPath();
                    this.ctx.arc(x + 24 + i * 3, y - 9 + dreamyPuff + softWave, 5.5, 0, Math.PI * 2);
                    this.ctx.fill();
                }
                this.ctx.shadowColor = 'transparent';
                this.ctx.shadowBlur = 0;
                break;
            case 'ethereal_fluffy':
                // 空灵蓬松状 - 梦幻棉花糖质感
                this.ctx.shadowColor = hairColor;
                this.ctx.shadowBlur = 12;
                for (let i = 0; i < 10; i++) {
                    const etherealPuff = Math.sin(i * 0.8) * 4;
                    const gentleFloat = Math.cos(i * 0.6) * 2;
                    this.ctx.beginPath();
                    this.ctx.arc(x + 23 + i * 3, y - 10 + etherealPuff + gentleFloat, 6, 0, Math.PI * 2);
                    this.ctx.fill();
                }
                // 添加棉花糖质感
                this.ctx.fillStyle = 'rgba(255, 255, 255, 0.3)';
                for (let i = 0; i < 10; i++) {
                    const etherealPuff = Math.sin(i * 0.8) * 4;
                    const gentleFloat = Math.cos(i * 0.6) * 2;
                    this.ctx.beginPath();
                    this.ctx.arc(x + 23 + i * 3, y - 10 + etherealPuff + gentleFloat, 3, 0, Math.PI * 2);
                    this.ctx.fill();
                }
                this.ctx.shadowColor = 'transparent';
                this.ctx.shadowBlur = 0;
                break;
            case 'magical_cloud':
                // 魔法云朵状
                this.ctx.shadowColor = hairColor;
                this.ctx.shadowBlur = 15;
                for (let i = 0; i < 9; i++) {
                    const glow = Math.sin(i * 0.7) * 3;
                    this.ctx.beginPath();
                    this.ctx.arc(x + 24 + i * 3, y - 10 + glow, 6, 0, Math.PI * 2);
                    this.ctx.fill();
                }
                this.ctx.shadowColor = 'transparent';
                this.ctx.shadowBlur = 0;
                break;
        }
    }
    
    // 绘制外星人触角
    drawAlienAntennae(x, y, antennaeType, antennaColor, antennaGlow, antennaTips) {
        const time = Date.now() * 0.001;
        this.ctx.strokeStyle = antennaColor;
        this.ctx.lineWidth = antennaGlow === 'none' ? 2 : 3;
        
        if (antennaGlow !== 'none') {
            this.ctx.shadowColor = antennaColor;
            this.ctx.shadowBlur = antennaGlow === 'subtle' ? 8 : 
                                 antennaGlow === 'bright' ? 12 : 
                                 antennaGlow === 'intense' ? 15 : 
                                 antennaGlow === 'gentle_glow' ? 10 :
                                 antennaGlow === 'ethereal_glow' ? 15 : 20;
        }
        
        // 根据触角类型绘制不同的摆动效果
        let leftSway = 0, rightSway = 0;
        
        switch(antennaeType) {
            case 'floating_golden':
            case 'ethereal_golden':
                // 轻盈摆动的金黄色触角
                leftSway = Math.sin(time * 2) * 3;
                rightSway = Math.sin(time * 2 + Math.PI) * 3;
                break;
            default:
                leftSway = 0;
                rightSway = 0;
        }
        
        // 左触角
        this.ctx.beginPath();
        this.ctx.moveTo(x + 30, y - 5);
        this.ctx.quadraticCurveTo(x + 25 + leftSway, y - 15, x + 20 + leftSway * 1.5, y - 20);
        this.ctx.stroke();
        
        // 右触角
        this.ctx.beginPath();
        this.ctx.moveTo(x + 40, y - 5);
        this.ctx.quadraticCurveTo(x + 45 + rightSway, y - 15, x + 50 + rightSway * 1.5, y - 20);
        this.ctx.stroke();
        
        // 触角末端
        const tipSize = antennaTips === 'small_sphere' ? 3 : 
                       antennaTips === 'medium_sphere' ? 4 : 
                       antennaTips === 'large_sphere' ? 5 : 
                       antennaTips === 'large_glowing' ? 6 : 
                       antennaTips === 'floating_sphere' ? 5 :
                       antennaTips === 'ethereal_sphere' ? 6 : 7;
        
        this.ctx.fillStyle = antennaColor;
        
        // 左触角末端
        this.ctx.beginPath();
        this.ctx.arc(x + 20 + leftSway * 1.5, y - 20, tipSize, 0, Math.PI * 2);
        this.ctx.fill();
        
        // 右触角末端
        this.ctx.beginPath();
        this.ctx.arc(x + 50 + rightSway * 1.5, y - 20, tipSize, 0, Math.PI * 2);
        this.ctx.fill();
        
        // 特殊触角效果
        if (antennaTips === 'magical_sphere' || antennaTips === 'ethereal_sphere') {
            this.ctx.fillStyle = '#FFFFFF';
            this.ctx.shadowColor = 'transparent';
            this.ctx.shadowBlur = 0;
            this.ctx.beginPath();
            this.ctx.arc(x + 18 + leftSway * 1.5, y - 22, 2, 0, Math.PI * 2);
            this.ctx.fill();
            this.ctx.beginPath();
            this.ctx.arc(x + 48 + rightSway * 1.5, y - 22, 2, 0, Math.PI * 2);
            this.ctx.fill();
        }
        
        // 空灵触角的金色火花轨迹
        if (antennaeType === 'ethereal_golden') {
            this.ctx.fillStyle = 'rgba(255, 215, 0, 0.6)';
            for (let i = 0; i < 3; i++) {
                const sparkleX = x + 20 + leftSway * 1.5 + Math.sin(time * 3 + i) * 5;
                const sparkleY = y - 20 + Math.cos(time * 2 + i) * 3;
                this.ctx.beginPath();
                this.ctx.arc(sparkleX, sparkleY, 1, 0, Math.PI * 2);
                this.ctx.fill();
            }
            for (let i = 0; i < 3; i++) {
                const sparkleX = x + 50 + rightSway * 1.5 + Math.sin(time * 3 + i + Math.PI) * 5;
                const sparkleY = y - 20 + Math.cos(time * 2 + i + Math.PI) * 3;
                this.ctx.beginPath();
                this.ctx.arc(sparkleX, sparkleY, 1, 0, Math.PI * 2);
                this.ctx.fill();
            }
        }
        
        this.ctx.shadowColor = 'transparent';
        this.ctx.shadowBlur = 0;
    }
    
    // 绘制外星人耳朵
    drawAlienEars(x, y, earsType, earColor) {
        this.ctx.fillStyle = earColor;
        this.ctx.strokeStyle = '#000000';
        this.ctx.lineWidth = 1;
        
        // 左耳
        this.ctx.beginPath();
        this.ctx.arc(x + 20, y + 10, 8, 0, Math.PI * 2);
        this.ctx.fill();
        this.ctx.stroke();
        
        // 右耳
        this.ctx.beginPath();
        this.ctx.arc(x + 50, y + 10, 8, 0, Math.PI * 2);
        this.ctx.fill();
        this.ctx.stroke();
    }
    
    // 绘制外星人眼睛
    drawAlienEyes(x, y, eyesType, eyeColor, eyeGlow, eyeHighlights) {
        const time = Date.now() * 0.001;
        
        // 眼睛基础 - 白色
        this.ctx.fillStyle = 'white';
        this.ctx.strokeStyle = '#000000';
        this.ctx.lineWidth = 2;
        this.ctx.beginPath();
        this.ctx.arc(x + 40, y + 8, 8, 0, Math.PI * 2);
        this.ctx.fill();
        this.ctx.stroke();
        
        // 瞳孔 - 湖绿色的明亮眼睛充满好奇光芒
        this.ctx.fillStyle = eyeColor;
        this.ctx.beginPath();
        this.ctx.arc(x + 42, y + 8, 4, 0, Math.PI * 2);
        this.ctx.fill();
        
        // 发光效果
        if (eyeGlow !== 'none') {
            this.ctx.shadowColor = eyeColor;
            this.ctx.shadowBlur = eyeGlow === 'subtle' ? 5 : 
                                 eyeGlow === 'bright' ? 10 : 
                                 eyeGlow === 'intense' ? 15 : 
                                 eyeGlow === 'bright_curious' ? 12 :
                                 eyeGlow === 'ethereal_curious' ? 18 : 20;
            this.ctx.beginPath();
            this.ctx.arc(x + 42, y + 8, 4, 0, Math.PI * 2);
            this.ctx.fill();
        }
        
        // 高光 - 多重闪烁高光
        switch(eyeHighlights) {
            case 'minimal':
                this.ctx.fillStyle = 'rgba(255, 255, 255, 0.5)';
                this.ctx.beginPath();
                this.ctx.arc(x + 44, y + 6, 1, 0, Math.PI * 2);
                this.ctx.fill();
                break;
            case 'small_white':
                this.ctx.fillStyle = 'rgba(255, 255, 255, 0.8)';
                this.ctx.beginPath();
                this.ctx.arc(x + 44, y + 6, 2, 0, Math.PI * 2);
                this.ctx.fill();
                break;
            case 'large_white':
                this.ctx.fillStyle = 'rgba(255, 255, 255, 0.9)';
                this.ctx.beginPath();
                this.ctx.arc(x + 44, y + 6, 3, 0, Math.PI * 2);
                this.ctx.fill();
                break;
            case 'multiple_white':
                this.ctx.fillStyle = 'rgba(255, 255, 255, 0.9)';
                this.ctx.beginPath();
                this.ctx.arc(x + 44, y + 6, 2, 0, Math.PI * 2);
                this.ctx.fill();
                this.ctx.beginPath();
                this.ctx.arc(x + 40, y + 4, 1, 0, Math.PI * 2);
                this.ctx.fill();
                break;
            case 'multiple_sparkling':
                // 多重闪烁高光
                this.ctx.fillStyle = 'rgba(255, 255, 255, 0.9)';
                this.ctx.beginPath();
                this.ctx.arc(x + 44, y + 6, 2, 0, Math.PI * 2);
                this.ctx.fill();
                this.ctx.beginPath();
                this.ctx.arc(x + 40, y + 4, 1, 0, Math.PI * 2);
                this.ctx.fill();
                this.ctx.beginPath();
                this.ctx.arc(x + 46, y + 5, 1.5, 0, Math.PI * 2);
                this.ctx.fill();
                break;
            case 'ethereal_sparkling':
                // 空灵闪烁高光
                this.ctx.fillStyle = 'rgba(255, 255, 255, 0.9)';
                this.ctx.beginPath();
                this.ctx.arc(x + 44, y + 6, 2, 0, Math.PI * 2);
                this.ctx.fill();
                this.ctx.beginPath();
                this.ctx.arc(x + 40, y + 4, 1, 0, Math.PI * 2);
                this.ctx.fill();
                this.ctx.beginPath();
                this.ctx.arc(x + 46, y + 5, 1.5, 0, Math.PI * 2);
                this.ctx.fill();
                this.ctx.beginPath();
                this.ctx.arc(x + 38, y + 7, 1, 0, Math.PI * 2);
                this.ctx.fill();
                break;
            case 'rainbow':
                const colors = ['#FF69B4', '#FFD700', '#87CEEB', '#32CD32'];
                for (let i = 0; i < 4; i++) {
                    this.ctx.fillStyle = colors[i];
                    this.ctx.beginPath();
                    this.ctx.arc(x + 44 + i * 1.5, y + 6, 1, 0, Math.PI * 2);
                    this.ctx.fill();
                }
                break;
        }
        
        // 星空梦幻闪烁效果
        if (eyesType === 'ethereal_lake_green') {
            this.ctx.fillStyle = 'rgba(255, 215, 0, 0.7)';
            for (let i = 0; i < 2; i++) {
                const sparkleX = x + 42 + Math.sin(time * 2 + i) * 3;
                const sparkleY = y + 8 + Math.cos(time * 1.5 + i) * 2;
                this.ctx.beginPath();
                this.ctx.arc(sparkleX, sparkleY, 0.5, 0, Math.PI * 2);
                this.ctx.fill();
            }
        }
        
        this.ctx.shadowColor = 'transparent';
        this.ctx.shadowBlur = 0;
    }
    
    // 绘制外星人嘴巴
    drawAlienMouth(x, y, mouthType, mouthColor) {
        this.ctx.strokeStyle = mouthColor;
        this.ctx.lineWidth = 2;
        
        switch(mouthType) {
            case 'sad_line':
                this.ctx.beginPath();
                this.ctx.arc(x + 35, y + 15, 3, 0, Math.PI);
                this.ctx.stroke();
                break;
            case 'gentle_smile':
                this.ctx.beginPath();
                this.ctx.arc(x + 35, y + 15, 4, 0, Math.PI);
                this.ctx.stroke();
                break;
            case 'happy_smile':
                this.ctx.beginPath();
                this.ctx.arc(x + 35, y + 15, 5, 0, Math.PI);
                this.ctx.stroke();
                break;
            case 'big_happy_smile':
                this.ctx.beginPath();
                this.ctx.arc(x + 35, y + 15, 6, 0, Math.PI);
                this.ctx.stroke();
                break;
            case 'radiant_smile':
                this.ctx.beginPath();
                this.ctx.arc(x + 35, y + 15, 7, 0, Math.PI);
                this.ctx.stroke();
                break;
        }
    }
    
    // 绘制外星人鼻子
    drawAlienNose(x, y) {
        this.ctx.fillStyle = '#FF69B4';
        this.ctx.beginPath();
        this.ctx.arc(x + 37, y + 12, 2, 0, Math.PI * 2);
        this.ctx.fill();
    }
    
    // 绘制太空鞋子
    drawSpaceShoes(x, y, shoesType, shoeColor, shoeAccents) {
        this.ctx.fillStyle = shoeColor;
        this.ctx.strokeStyle = '#000000';
        this.ctx.lineWidth = 1;
        
        // 左鞋
        this.ctx.beginPath();
        this.ctx.ellipse(x + 25, y + 45, 6, 4, 0, 0, Math.PI * 2);
        this.ctx.fill();
        this.ctx.stroke();
        
        // 右鞋
        this.ctx.beginPath();
        this.ctx.ellipse(x + 45, y + 45, 6, 4, 0, 0, Math.PI * 2);
        this.ctx.fill();
        this.ctx.stroke();
        
        // 鞋底装饰
        if (shoeAccents !== 'none') {
            this.ctx.fillStyle = '#FFFFFF';
            this.ctx.beginPath();
            this.ctx.ellipse(x + 25, y + 48, 5, 2, 0, 0, Math.PI * 2);
            this.ctx.fill();
            this.ctx.beginPath();
            this.ctx.ellipse(x + 45, y + 48, 5, 2, 0, 0, Math.PI * 2);
            this.ctx.fill();
        }
    }
    
    // 绘制整体发光效果
    drawOverallGlow(x, y, glowType) {
        if (glowType === 'none') return;
        
        const time = Date.now() * 0.001;
        const pulse = Math.sin(time * 3) * 0.3 + 0.7;
        
        switch(glowType) {
            case 'subtle_blue':
                this.ctx.shadowColor = '#87CEEB';
                this.ctx.shadowBlur = 5 * pulse;
                break;
            case 'moderate_green':
                this.ctx.shadowColor = '#32CD32';
                this.ctx.shadowBlur = 10 * pulse;
                break;
            case 'bright_warm':
                this.ctx.shadowColor = '#FFD700';
                this.ctx.shadowBlur = 15 * pulse;
                break;
            case 'intense_rainbow':
                this.ctx.shadowColor = '#FF69B4';
                this.ctx.shadowBlur = 20 * pulse;
                break;
        }
        
        // 绘制发光主体
        this.ctx.fillStyle = 'rgba(255, 255, 255, 0.3)';
        this.ctx.beginPath();
        this.ctx.arc(x + 35, y + 25, 30, 0, Math.PI * 2);
        this.ctx.fill();
        
        this.ctx.shadowColor = 'transparent';
        this.ctx.shadowBlur = 0;
    }
    
    // 绘制闪烁效果
    drawSparkleEffect(x, y, sparkleType) {
        if (sparkleType === 'none') return;
        
        const time = Date.now() * 0.001;
        const sparkleCount = sparkleType === 'subtle' ? 3 : 
                            sparkleType === 'moderate' ? 5 : 
                            sparkleType === 'bright' ? 7 : 10;
        
        for (let i = 0; i < sparkleCount; i++) {
            const angle = (i * Math.PI * 2) / sparkleCount + time;
            const radius = 25 + Math.sin(time * 2 + i) * 5;
            const sparkleX = x + 35 + Math.cos(angle) * radius;
            const sparkleY = y + 25 + Math.sin(angle) * radius;
            
            this.ctx.fillStyle = `rgba(255, 215, 0, ${0.6 - Math.sin(time + i) * 0.3})`;
            this.ctx.beginPath();
            this.ctx.arc(sparkleX, sparkleY, 2, 0, Math.PI * 2);
            this.ctx.fill();
        }
    }
    
    // 绘制太空服 - DIMOO的太空装备
    drawAstronautSuit(x, y, suitType, bodyColor) {
        switch(suitType) {
            case 'dark_astronaut':
                // 深色太空服 - 抑郁状态
                this.ctx.fillStyle = '#2c3e50';
                this.ctx.strokeStyle = '#34495e';
                this.ctx.lineWidth = 2;
                break;
            case 'light_astronaut':
                // 浅色太空服 - 治愈中状态
                this.ctx.fillStyle = '#87CEEB';
                this.ctx.strokeStyle = '#5dade2';
                this.ctx.lineWidth = 2;
                break;
            case 'colorful_astronaut':
                // 彩色太空服 - 康复中状态
                this.ctx.fillStyle = '#98FB98';
                this.ctx.strokeStyle = '#32CD32';
                this.ctx.lineWidth = 2;
                break;
            case 'pastel_astronaut':
                // 粉彩色太空服 - 治愈完成状态
                this.ctx.fillStyle = '#FFE4B5';
                this.ctx.strokeStyle = '#FFD700';
                this.ctx.lineWidth = 2;
                break;
            case 'iridescent_astronaut':
                // 彩虹色太空服 - 光芒四射状态
                this.ctx.fillStyle = '#FF69B4';
                this.ctx.strokeStyle = '#9370DB';
                this.ctx.lineWidth = 3;
                break;
            default:
                return;
        }
        
        // 绘制太空服主体
        this.ctx.beginPath();
        this.ctx.ellipse(x + 35, y + 25, 20, 15, 0, 0, Math.PI * 2);
        this.ctx.fill();
        this.ctx.stroke();
        
        // 绘制太空服细节
        this.ctx.fillStyle = '#FFFFFF';
        this.ctx.beginPath();
        this.ctx.ellipse(x + 35, y + 25, 15, 10, 0, 0, Math.PI * 2);
        this.ctx.fill();
        
        // 绘制太空服装饰
        if (suitType === 'iridescent_astronaut') {
            // 彩虹色装饰
            const colors = ['#FF69B4', '#FFD700', '#87CEEB', '#32CD32', '#FF6347', '#9370DB'];
            for (let i = 0; i < 3; i++) {
                this.ctx.fillStyle = colors[i % colors.length];
                this.ctx.beginPath();
                this.ctx.arc(x + 30 + i * 5, y + 20, 2, 0, Math.PI * 2);
                this.ctx.fill();
            }
        }
    }
    
    // 绘制背包 - DIMOO的太空背包
    drawBackpack(x, y, backpackType, bodyColor) {
        switch(backpackType) {
            case 'none':
                return;
            case 'small':
                // 小背包 - 治愈中状态
                this.ctx.fillStyle = '#E6E6FA';
                this.ctx.strokeStyle = '#9370DB';
                this.ctx.lineWidth = 1;
                break;
            case 'medium':
                // 中等背包 - 康复中状态
                this.ctx.fillStyle = '#98FB98';
                this.ctx.strokeStyle = '#32CD32';
                this.ctx.lineWidth = 2;
                break;
            case 'large':
                // 大背包 - 治愈完成状态
                this.ctx.fillStyle = '#FFE4B5';
                this.ctx.strokeStyle = '#FFD700';
                this.ctx.lineWidth = 2;
                break;
            case 'magical':
                // 魔法背包 - 光芒四射状态
                this.ctx.fillStyle = '#FF69B4';
                this.ctx.strokeStyle = '#9370DB';
                this.ctx.lineWidth = 3;
                break;
            default:
                return;
        }
        
        // 绘制背包主体
        this.ctx.beginPath();
        this.ctx.ellipse(x + 35, y + 35, 12, 8, 0, 0, Math.PI * 2);
        this.ctx.fill();
        this.ctx.stroke();
        
        // 绘制背包带子
        this.ctx.strokeStyle = '#000000';
        this.ctx.lineWidth = 2;
        this.ctx.beginPath();
        this.ctx.moveTo(x + 25, y + 25);
        this.ctx.lineTo(x + 25, y + 35);
        this.ctx.stroke();
        this.ctx.beginPath();
        this.ctx.moveTo(x + 45, y + 25);
        this.ctx.lineTo(x + 45, y + 35);
        this.ctx.stroke();
        
        // 绘制背包装饰
        if (backpackType === 'magical') {
            // 魔法背包的发光效果
            this.ctx.fillStyle = '#FFD700';
            this.ctx.beginPath();
            this.ctx.arc(x + 35, y + 35, 4, 0, Math.PI * 2);
            this.ctx.fill();
        }
    }
    
    // 绘制发光效果 - DIMOO的魔法光芒
    drawGlowEffect(x, y, glowType, bodyColor) {
        switch(glowType) {
            case 'none':
                return;
            case 'subtle':
                // 轻微发光效果
                this.ctx.shadowColor = '#87CEEB';
                this.ctx.shadowBlur = 5;
                break;
            case 'moderate':
                // 中等发光效果
                this.ctx.shadowColor = '#32CD32';
                this.ctx.shadowBlur = 10;
                break;
            case 'bright':
                // 明亮发光效果
                this.ctx.shadowColor = '#FFD700';
                this.ctx.shadowBlur = 15;
                break;
            case 'intense':
                // 强烈发光效果
                this.ctx.shadowColor = '#FF69B4';
                this.ctx.shadowBlur = 20;
                break;
            default:
                return;
        }
        
        // 绘制发光光环
        this.ctx.fillStyle = 'rgba(255, 255, 255, 0.3)';
        this.ctx.beginPath();
        this.ctx.arc(x + 35, y + 25, 30, 0, Math.PI * 2);
        this.ctx.fill();
        
        // 重置阴影
        this.ctx.shadowColor = 'transparent';
        this.ctx.shadowBlur = 0;
    }
    

    
    drawGlideWings(x, y) {
        // 根据DIMOO当前状态设计不同的翅膀，使用原本角色的色彩基调
        const currentForm = this.dimoo.form;
        const formData = this.dimoo.forms[currentForm];
        
        let wingColor, trailColor, wingSize;
        
        switch (currentForm) {
            case 'depressed':
                // 抑郁状态：使用原本的棕色基调
                wingColor = formData.color; // 使用原本的bodyColor
                trailColor = 'rgba(139, 69, 19, 0.3)';
                wingSize = 15;
                break;
            case 'healing':
                // 治愈中：使用原本的橙色头发色彩
                wingColor = formData.features.hairColor || '#FFA500';
                trailColor = 'rgba(255, 165, 0, 0.3)';
                wingSize = 18;
                break;
            case 'recovering':
                // 康复中：使用原本的绿色眼睛色彩
                wingColor = formData.features.eyeColor || '#228B22';
                trailColor = 'rgba(34, 139, 34, 0.3)';
                wingSize = 20;
                break;
            case 'healed':
                // 治愈完成：使用原本的触角色彩
                wingColor = formData.features.antennaColor || '#FFD700';
                trailColor = 'rgba(255, 215, 0, 0.3)';
                wingSize = 22;
                break;
            case 'radiant':
                // 光芒四射：使用原本的太空服色彩
                wingColor = formData.features.suitColor || '#2F4F4F';
                trailColor = 'rgba(47, 79, 79, 0.3)';
                wingSize = 25;
                break;
            default:
                wingColor = formData.color;
                trailColor = 'rgba(44, 62, 80, 0.3)';
                wingSize = 20;
        }
        
        // 完全确保没有阴影效果 - 在每次绘制前都重置
        this.ctx.shadowColor = 'transparent';
        this.ctx.shadowBlur = 0;
        this.ctx.shadowOffsetX = 0;
        this.ctx.shadowOffsetY = 0;
        
        // 绘制翅膀主体 - 去掉阴影，使用固定颜色
        this.ctx.fillStyle = wingColor;
        
        // 左翅膀
        this.ctx.beginPath();
        this.ctx.ellipse(x - 15, y + 25, wingSize, wingSize * 0.6, 0, 0, Math.PI * 2);
        this.ctx.fill();
        
        // 右翅膀
        this.ctx.beginPath();
        this.ctx.ellipse(x + 65, y + 25, wingSize, wingSize * 0.6, 0, 0, Math.PI * 2);
        this.ctx.fill();
        
        // 翅膀边框 - 再次确保无阴影
        this.ctx.shadowColor = 'transparent';
        this.ctx.shadowBlur = 0;
        this.ctx.strokeStyle = wingColor;
        this.ctx.lineWidth = 1;
        this.ctx.stroke();
        
        // 滑翔特效 - 简化，去掉闪烁效果
        this.ctx.fillStyle = trailColor;
        this.ctx.fillRect(x - 30, y + 15, 30, 30);
        this.ctx.fillRect(x + 50, y + 15, 30, 30);
        
        // 滑翔粒子效果 - 使用固定颜色，不闪烁
        for (let i = 0; i < 4; i++) {
            const particleAlpha = 0.3 - i * 0.05;
            this.ctx.fillStyle = `${wingColor.replace(')', `, ${particleAlpha})`)}`;
            this.ctx.fillRect(x - 35 - i * 8, y + 20 + i * 2, 3, 3);
            this.ctx.fillRect(x + 62 + i * 8, y + 20 + i * 2, 3, 3);
        }
        
        // 最后再次确保阴影完全清除
        this.ctx.shadowColor = 'transparent';
        this.ctx.shadowBlur = 0;
        this.ctx.shadowOffsetX = 0;
        this.ctx.shadowOffsetY = 0;
    }
    
    drawInvincibleEffect(x, y, width, height) {
        // 无敌状态光环效果
        const time = Date.now() * 0.01;
        const alpha = 0.3 + Math.sin(time * 3) * 0.2;
        
        // 外圈光环
        this.ctx.strokeStyle = `rgba(255, 215, 0, ${alpha})`;
        this.ctx.lineWidth = 3;
        this.ctx.beginPath();
        this.ctx.arc(x + width/2, y + height/2, width/2 + 10, 0, Math.PI * 2);
        this.ctx.stroke();
        
        // 内圈光环
        this.ctx.strokeStyle = `rgba(255, 255, 255, ${alpha})`;
        this.ctx.lineWidth = 2;
        this.ctx.beginPath();
        this.ctx.arc(x + width/2, y + height/2, width/2 + 5, 0, Math.PI * 2);
        this.ctx.stroke();
        
        // 粒子效果
        for (let i = 0; i < 8; i++) {
            const angle = (i * Math.PI * 2) / 8 + time;
            const particleX = x + width/2 + Math.cos(angle) * (width/2 + 15);
            const particleY = y + height/2 + Math.sin(angle) * (height/2 + 15);
            
            this.ctx.fillStyle = `rgba(255, 215, 0, ${0.6 - Math.sin(time + i) * 0.3})`;
            this.ctx.beginPath();
            this.ctx.arc(particleX, particleY, 3, 0, Math.PI * 2);
            this.ctx.fill();
        }
    }
    
    drawSupermanDimoo(x, y, width, height) {
        // 飞行超人姿态 - 趴着的飞行姿势
        const time = Date.now() * 0.01;
        
        // 身体 - 扁平化设计，模拟飞行姿态
        this.ctx.fillStyle = '#2c3e50';
        this.ctx.fillRect(x + 10, y + 25, width - 20, height - 25);
        
        // 头部 - 向前伸展
        this.ctx.beginPath();
        this.ctx.ellipse(x + 45, y + 20, 12, 8, 0, 0, Math.PI * 2);
        this.ctx.fill();
        
        // 眼睛 - 专注的眼神
        this.ctx.fillStyle = 'white';
        this.ctx.beginPath();
        this.ctx.arc(x + 47, y + 18, 4, 0, Math.PI * 2);
        this.ctx.fill();
        
        this.ctx.fillStyle = '#2c3e50';
        this.ctx.beginPath();
        this.ctx.arc(x + 48, y + 18, 2, 0, Math.PI * 2);
        this.ctx.fill();
        
        // 嘴巴 - 坚定的表情
        this.ctx.strokeStyle = '#2c3e50';
        this.ctx.lineWidth = 2;
        this.ctx.beginPath();
        this.ctx.moveTo(x + 45, y + 22);
        this.ctx.lineTo(x + 50, y + 22);
        this.ctx.stroke();
        
        // 手臂 - 向前伸展
        this.ctx.fillStyle = '#34495e';
        this.ctx.fillRect(x + 45, y + 30, 20, 4);
        this.ctx.fillRect(x + 45, y + 35, 20, 4);
        
        // 腿部 - 向后伸展
        this.ctx.fillRect(x + 15, y + 40, 15, 3);
        this.ctx.fillRect(x + 35, y + 40, 15, 3);
        
        // 飞行特效 - 速度线
        for (let i = 0; i < 5; i++) {
            this.ctx.strokeStyle = `rgba(255, 255, 255, ${0.3 - i * 0.05})`;
            this.ctx.lineWidth = 2;
            this.ctx.beginPath();
            this.ctx.moveTo(x - 20 - i * 10, y + 25 + i * 2);
            this.ctx.lineTo(x - 10 - i * 10, y + 25 + i * 2);
            this.ctx.stroke();
        }
        
        // 无敌光环
        this.drawInvincibleEffect(x, y, width, height);
    }
    
    drawObstacles() {
        this.obstacles.forEach(obstacle => {
            this.ctx.fillStyle = obstacle.color;
            
            switch (obstacle.type) {
                case 'cactus':
                    // 画仙人掌 - 更高更可爱
                    this.ctx.fillRect(obstacle.x, obstacle.y, obstacle.width, obstacle.height);
                    
                    // 添加仙人掌的刺和装饰
                    this.ctx.fillStyle = '#006400';
                    this.ctx.fillRect(obstacle.x - 3, obstacle.y + 15, 6, 10);
                    this.ctx.fillRect(obstacle.x + obstacle.width - 3, obstacle.y + 20, 6, 10);
                    
                    // 仙人掌顶部的小花
                    this.ctx.fillStyle = '#FF69B4';
                    this.ctx.beginPath();
                    this.ctx.arc(obstacle.x + obstacle.width/2, obstacle.y - 5, 5, 0, Math.PI * 2);
                    this.ctx.fill();
                    break;
                    
                case 'bird':
                    // 画鸟 - 更大更可爱
                    this.ctx.fillRect(obstacle.x, obstacle.y, obstacle.width, obstacle.height);
                    
                    // 添加鸟的翅膀和眼睛
                    this.ctx.fillStyle = '#FF4500';
                    this.ctx.fillRect(obstacle.x - 8, obstacle.y + 8, 12, 8);
                    this.ctx.fillRect(obstacle.x + obstacle.width - 4, obstacle.y + 8, 12, 8);
                    
                    // 鸟的眼睛
                    this.ctx.fillStyle = 'white';
                    this.ctx.beginPath();
                    this.ctx.arc(obstacle.x + 10, obstacle.y + 10, 4, 0, Math.PI * 2);
                    this.ctx.fill();
                    
                    this.ctx.fillStyle = '#000';
                    this.ctx.beginPath();
                    this.ctx.arc(obstacle.x + 10, obstacle.y + 10, 2, 0, Math.PI * 2);
                    this.ctx.fill();
                    break;
                    
                case 'rock':
                    // 画岩石 - 圆形设计
                    this.ctx.beginPath();
                    this.ctx.arc(obstacle.x + obstacle.width/2, obstacle.y + obstacle.height/2, obstacle.width/2, 0, Math.PI * 2);
                    this.ctx.fill();
                    
                    // 添加岩石纹理
                    this.ctx.fillStyle = '#4A4A4A';
                    this.ctx.beginPath();
                    this.ctx.arc(obstacle.x + obstacle.width/2 - 5, obstacle.y + obstacle.height/2 - 5, 3, 0, Math.PI * 2);
                    this.ctx.fill();
                    break;
                    
                case 'tree':
                    // 画树 - 树干和树冠
                    this.ctx.fillStyle = '#8B4513';
                    this.ctx.fillRect(obstacle.x + obstacle.width/2 - 5, obstacle.y + obstacle.height - 20, 10, 20);
                    
                    this.ctx.fillStyle = '#228B22';
                    this.ctx.beginPath();
                    this.ctx.arc(obstacle.x + obstacle.width/2, obstacle.y + obstacle.height/2, obstacle.width/2, 0, Math.PI * 2);
                    this.ctx.fill();
                    break;
                    
                case 'flying_saucer':
                    // 画飞碟 - 椭圆形设计
                    this.ctx.beginPath();
                    this.ctx.ellipse(obstacle.x + obstacle.width/2, obstacle.y + obstacle.height/2, obstacle.width/2, obstacle.height/2, 0, 0, Math.PI * 2);
                    this.ctx.fill();
                    
                    // 添加飞碟的灯光
                    this.ctx.fillStyle = '#FFD700';
                    for (let i = 0; i < 3; i++) {
                        this.ctx.beginPath();
                        this.ctx.arc(obstacle.x + 10 + i * 15, obstacle.y + obstacle.height/2, 3, 0, Math.PI * 2);
                        this.ctx.fill();
                    }
                    break;
                    
                case 'meteor':
                    // 画陨石 - 圆形设计，带火焰效果
                    this.ctx.beginPath();
                    this.ctx.arc(obstacle.x + obstacle.width/2, obstacle.y + obstacle.height/2, obstacle.width/2, 0, Math.PI * 2);
                    this.ctx.fill();
                    
                    // 火焰效果
                    this.ctx.fillStyle = '#FF8C00';
                    this.ctx.beginPath();
                    this.ctx.arc(obstacle.x + obstacle.width/2, obstacle.y + obstacle.height/2, obstacle.width/2 - 3, 0, Math.PI * 2);
                    this.ctx.fill();
                    break;
                    
                case 'laser':
                    // 画激光 - 细长的红色光束
                    this.ctx.fillRect(obstacle.x, obstacle.y, obstacle.width, obstacle.height);
                    
                    // 激光光晕效果
                    this.ctx.fillStyle = 'rgba(255, 0, 0, 0.3)';
                    this.ctx.fillRect(obstacle.x - 2, obstacle.y, obstacle.width + 4, obstacle.height);
                    break;
                    
                case 'trap':
                    // 画陷阱 - 地面上的红色陷阱
                    this.ctx.fillRect(obstacle.x, obstacle.y, obstacle.width, obstacle.height);
                    
                    // 陷阱纹理
                    this.ctx.fillStyle = '#DC143C';
                    this.ctx.fillRect(obstacle.x + 5, obstacle.y + 2, obstacle.width - 10, obstacle.height - 4);
                    break;
                    
                case 'fake_coin':
                    // 画假金币 - 金色圆形，但会伤害玩家
                    this.ctx.fillStyle = '#FFD700';
                    this.ctx.beginPath();
                    this.ctx.arc(obstacle.x + obstacle.width/2, obstacle.y + obstacle.height/2, obstacle.width/2, 0, Math.PI * 2);
                    this.ctx.fill();
                    
                    // 假金币的"$"符号
                    this.ctx.fillStyle = '#B8860B';
                    this.ctx.font = '12px Arial';
                    this.ctx.fillText('$', obstacle.x + obstacle.width/2 - 3, obstacle.y + obstacle.height/2 + 4);
                    break;
                    
                case 'spike_ball':
                    // 画尖刺球 - 圆形带尖刺
                    this.ctx.beginPath();
                    this.ctx.arc(obstacle.x + obstacle.width/2, obstacle.y + obstacle.height/2, obstacle.width/2, 0, Math.PI * 2);
                    this.ctx.fill();
                    
                    // 尖刺
                    this.ctx.fillStyle = '#2F2F2F';
                    for (let i = 0; i < 8; i++) {
                        const angle = (i * Math.PI * 2) / 8;
                        const spikeX = obstacle.x + obstacle.width/2 + Math.cos(angle) * (obstacle.width/2 + 3);
                        const spikeY = obstacle.y + obstacle.height/2 + Math.sin(angle) * (obstacle.height/2 + 3);
                        this.ctx.beginPath();
                        this.ctx.arc(spikeX, spikeY, 2, 0, Math.PI * 2);
                        this.ctx.fill();
                    }
                    break;
                    
                case 'floating_platform':
                    // 画浮动平台 - 木制平台
                    this.ctx.fillRect(obstacle.x, obstacle.y, obstacle.width, obstacle.height);
                    
                    // 平台纹理
                    this.ctx.fillStyle = '#A0522D';
                    for (let i = 0; i < obstacle.width; i += 10) {
                        this.ctx.fillRect(obstacle.x + i, obstacle.y, 2, obstacle.height);
                    }
                    break;
                    
                case 'moving_wall':
                    // 画移动墙壁 - 动态移动
                    this.ctx.fillRect(obstacle.x, obstacle.y, obstacle.width, obstacle.height);
                    
                    // 移动效果
                    const time = Date.now() * 0.01;
                    obstacle.y += Math.sin(time) * obstacle.moveSpeed * obstacle.moveDirection;
                    break;
                    
                case 'energy_field':
                    // 画能量场 - 闪烁效果
                    const alpha = 0.5 + Math.sin(Date.now() * 0.01) * 0.3;
                    this.ctx.fillStyle = `rgba(0, 255, 255, ${alpha})`;
                    this.ctx.fillRect(obstacle.x, obstacle.y, obstacle.width, obstacle.height);
                    
                    // 能量波纹
                    this.ctx.strokeStyle = `rgba(0, 255, 255, ${alpha})`;
                    this.ctx.lineWidth = 2;
                    this.ctx.strokeRect(obstacle.x - 2, obstacle.y - 2, obstacle.width + 4, obstacle.height + 4);
                    break;
                    
                case 'time_bomb':
                    // 画定时炸弹 - 倒计时效果
                    this.ctx.beginPath();
                    this.ctx.arc(obstacle.x + obstacle.width/2, obstacle.y + obstacle.height/2, obstacle.width/2, 0, Math.PI * 2);
                    this.ctx.fill();
                    
                    // 倒计时数字
                    const timeLeft = Math.max(0, Math.ceil((obstacle.explodeTime - Date.now()) / 1000));
                    this.ctx.fillStyle = 'white';
                    this.ctx.font = '12px Arial';
                    this.ctx.fillText(timeLeft.toString(), obstacle.x + obstacle.width/2 - 3, obstacle.y + obstacle.height/2 + 4);
                    break;
                    
                case 'gravity_well':
                    // 画重力井 - 漩涡效果
                    this.ctx.beginPath();
                    this.ctx.arc(obstacle.x + obstacle.width/2, obstacle.y + obstacle.height/2, obstacle.width/2, 0, Math.PI * 2);
                    this.ctx.fill();
                    
                    // 漩涡效果
                    this.ctx.strokeStyle = 'rgba(255, 255, 255, 0.6)';
                    this.ctx.lineWidth = 2;
                    for (let i = 0; i < 3; i++) {
                        this.ctx.beginPath();
                        this.ctx.arc(obstacle.x + obstacle.width/2, obstacle.y + obstacle.height/2, obstacle.width/2 - i * 3, 0, Math.PI * 2);
                        this.ctx.stroke();
                    }
                    break;
                    
                case 'narrow_gap':
                    // 画狭窄间隙 - 只能下蹲通过
                    this.ctx.fillStyle = 'rgba(139, 0, 0, 0.8)';
                    this.ctx.fillRect(obstacle.x, obstacle.y, obstacle.width, obstacle.height);
                    
                    // 间隙指示
                    this.ctx.fillStyle = 'rgba(255, 255, 255, 0.6)';
                    this.ctx.fillRect(obstacle.x + 5, obstacle.y + obstacle.height - 20, obstacle.width - 10, 15);
                    break;
                    
                case 'teleporter':
                    // 画传送门 - 漩涡效果
                    this.ctx.fillStyle = obstacle.color;
                    this.ctx.beginPath();
                    this.ctx.arc(obstacle.x + obstacle.width/2, obstacle.y + obstacle.height/2, obstacle.width/2, 0, Math.PI * 2);
                    this.ctx.fill();
                    
                    // 漩涡效果
                    const teleporterTime = Date.now() * 0.01;
                    for (let i = 0; i < 4; i++) {
                        this.ctx.strokeStyle = `rgba(255, 255, 255, ${0.6 - i * 0.1})`;
                        this.ctx.lineWidth = 2;
                        this.ctx.beginPath();
                        this.ctx.arc(obstacle.x + obstacle.width/2, obstacle.y + obstacle.height/2, obstacle.width/2 - i * 3, teleporterTime + i, teleporterTime + i + Math.PI);
                        this.ctx.stroke();
                    }
                    break;
                    
                case 'mirror_wall':
                    // 画镜像墙 - 反光效果
                    this.ctx.fillStyle = obstacle.color;
                    this.ctx.fillRect(obstacle.x, obstacle.y, obstacle.width, obstacle.height);
                    
                    // 反光条纹
                    this.ctx.fillStyle = 'rgba(255, 255, 255, 0.4)';
                    for (let i = 0; i < obstacle.height; i += 8) {
                        this.ctx.fillRect(obstacle.x, obstacle.y + i, obstacle.width, 2);
                    }
                    break;
                    
                case 'black_hole':
                    // 画黑洞 - 吸引效果
                    this.ctx.fillStyle = obstacle.color;
                    this.ctx.beginPath();
                    this.ctx.arc(obstacle.x + obstacle.width/2, obstacle.y + obstacle.height/2, obstacle.width/2, 0, Math.PI * 2);
                    this.ctx.fill();
                    
                    // 吸引光环
                    const blackHoleTime = Date.now() * 0.005;
                    for (let i = 0; i < 3; i++) {
                        this.ctx.strokeStyle = `rgba(255, 0, 0, ${0.4 - i * 0.1})`;
                        this.ctx.lineWidth = 1;
                        this.ctx.beginPath();
                        this.ctx.arc(obstacle.x + obstacle.width/2, obstacle.y + obstacle.height/2, obstacle.width/2 + 5 + i * 3, 0, Math.PI * 2);
                        this.ctx.stroke();
                    }
                    break;
                    
                case 'speed_trap':
                    // 画速度陷阱 - 根据速度变化
                    this.ctx.fillStyle = obstacle.color;
                    this.ctx.fillRect(obstacle.x, obstacle.y, obstacle.width, obstacle.height);
                    
                    // 速度指示器
                    const speedLevel = Math.min(this.speedMultiplier / 10, 1);
                    this.ctx.fillStyle = `rgba(255, 255, 255, ${speedLevel})`;
                    this.ctx.fillRect(obstacle.x + 5, obstacle.y + 5, (obstacle.width - 10) * speedLevel, 5);
                    break;
                case 'flying_dragon':
                    // 画飞行龙 - 带翅膀扇动动画
                    this.ctx.fillStyle = obstacle.color;
                    
                    // 身体
                    this.ctx.beginPath();
                    this.ctx.ellipse(obstacle.x + obstacle.width/2, obstacle.y + obstacle.height/2, obstacle.width/2 - 5, obstacle.height/2, 0, 0, Math.PI * 2);
                    this.ctx.fill();
                    
                    // 翅膀扇动动画
                    obstacle.wingFlap += 0.3;
                    const wingFlapOffset = Math.sin(obstacle.wingFlap) * 5;
                    
                    // 左翅膀
                    this.ctx.beginPath();
                    this.ctx.moveTo(obstacle.x + 10, obstacle.y + obstacle.height/2);
                    this.ctx.quadraticCurveTo(obstacle.x - 15 + wingFlapOffset, obstacle.y + 5, obstacle.x - 20 + wingFlapOffset, obstacle.y + 15);
                    this.ctx.quadraticCurveTo(obstacle.x - 15 + wingFlapOffset, obstacle.y + 25, obstacle.x + 10, obstacle.y + obstacle.height/2);
                    this.ctx.fill();
                    
                    // 右翅膀
                    this.ctx.beginPath();
                    this.ctx.moveTo(obstacle.x + obstacle.width - 10, obstacle.y + obstacle.height/2);
                    this.ctx.quadraticCurveTo(obstacle.x + obstacle.width + 15 - wingFlapOffset, obstacle.y + 5, obstacle.x + obstacle.width + 20 - wingFlapOffset, obstacle.y + 15);
                    this.ctx.quadraticCurveTo(obstacle.x + obstacle.width + 15 - wingFlapOffset, obstacle.y + 25, obstacle.x + obstacle.width - 10, obstacle.y + obstacle.height/2);
                    this.ctx.fill();
                    
                    // 头部
                    this.ctx.beginPath();
                    this.ctx.arc(obstacle.x + obstacle.width - 5, obstacle.y + obstacle.height/2, 8, 0, Math.PI * 2);
                    this.ctx.fill();
                    break;
                case 'hanging_vine':
                    // 画吊着的藤蔓 - 摆动动画
                    obstacle.swingOffset += 0.1;
                    const swingAmount = Math.sin(obstacle.swingOffset) * 3;
                    
                    this.ctx.strokeStyle = obstacle.color;
                    this.ctx.lineWidth = 8;
                    this.ctx.lineCap = 'round';
                    
                    // 藤蔓主体
                    this.ctx.beginPath();
                    this.ctx.moveTo(obstacle.x + obstacle.width/2 + swingAmount, obstacle.y);
                    this.ctx.lineTo(obstacle.x + obstacle.width/2 + swingAmount, obstacle.y + obstacle.height);
                    this.ctx.stroke();
                    
                    // 藤蔓叶子
                    this.ctx.fillStyle = '#32CD32';
                    for (let i = 0; i < 5; i++) {
                        const leafY = obstacle.y + i * 20 + 10;
                        const leafX = obstacle.x + obstacle.width/2 + swingAmount + Math.sin(i) * 8;
                        this.ctx.beginPath();
                        this.ctx.ellipse(leafX, leafY, 6, 3, Math.PI/4, 0, Math.PI * 2);
                        this.ctx.fill();
                    }
                    break;
                case 'floating_rock':
                    // 画浮空岩石 - 浮动动画
                    obstacle.floatOffset += 0.05;
                    const floatAmount = Math.sin(obstacle.floatOffset) * 2;
                    
                    this.ctx.fillStyle = obstacle.color;
                    this.ctx.beginPath();
                    this.ctx.arc(obstacle.x + obstacle.width/2, obstacle.y + obstacle.height/2 + floatAmount, obstacle.width/2, 0, Math.PI * 2);
                    this.ctx.fill();
                    
                    // 岩石纹理
                    this.ctx.fillStyle = '#4A4A4A';
                    for (let i = 0; i < 3; i++) {
                        const crackX = obstacle.x + 5 + i * 10;
                        const crackY = obstacle.y + 5 + i * 8 + floatAmount;
                        this.ctx.fillRect(crackX, crackY, 2, 3);
                    }
                    break;
                case 'air_tornado':
                    // 画空中龙卷风 - 旋转动画
                    obstacle.rotation += 0.2;
                    
                    this.ctx.save();
                    this.ctx.translate(obstacle.x + obstacle.width/2, obstacle.y + obstacle.height/2);
                    this.ctx.rotate(obstacle.rotation);
                    
                    // 龙卷风主体
                    this.ctx.fillStyle = obstacle.color;
                    this.ctx.beginPath();
                    this.ctx.ellipse(0, 0, obstacle.width/2, obstacle.height/2, 0, 0, Math.PI * 2);
                    this.ctx.fill();
                    
                    // 旋转条纹
                    this.ctx.strokeStyle = 'rgba(255, 255, 255, 0.6)';
                    this.ctx.lineWidth = 2;
                    for (let i = 0; i < 4; i++) {
                        this.ctx.beginPath();
                        this.ctx.moveTo(-obstacle.width/2, -obstacle.height/2 + i * 15);
                        this.ctx.lineTo(obstacle.width/2, -obstacle.height/2 + i * 15);
                        this.ctx.stroke();
                    }
                    
                    this.ctx.restore();
                    break;
                case 'hanging_spider':
                    // 画吊着的蜘蛛 - 蛛网摆动动画
                    obstacle.webSwing += 0.08;
                    const webSwingAmount = Math.sin(obstacle.webSwing) * 2;
                    
                    // 蛛网
                    this.ctx.strokeStyle = 'rgba(255, 255, 255, 0.8)';
                    this.ctx.lineWidth = 1;
                    
                    // 蛛网中心
                    const webCenterX = obstacle.x + obstacle.width/2 + webSwingAmount;
                    const webCenterY = obstacle.y + 20;
                    
                    // 蛛网辐射线
                    for (let i = 0; i < 8; i++) {
                        const angle = (i * Math.PI * 2) / 8;
                        const endX = webCenterX + Math.cos(angle) * 15;
                        const endY = webCenterY + Math.sin(angle) * 15;
                        this.ctx.beginPath();
                        this.ctx.moveTo(webCenterX, webCenterY);
                        this.ctx.lineTo(endX, endY);
                        this.ctx.stroke();
                    }
                    
                    // 蜘蛛身体
                    this.ctx.fillStyle = obstacle.color;
                    this.ctx.beginPath();
                    this.ctx.arc(webCenterX, webCenterY, 6, 0, Math.PI * 2);
                    this.ctx.fill();
                    
                    // 蜘蛛腿
                    this.ctx.strokeStyle = obstacle.color;
                    this.ctx.lineWidth = 2;
                    for (let i = 0; i < 8; i++) {
                        const angle = (i * Math.PI * 2) / 8;
                        const legEndX = webCenterX + Math.cos(angle) * 8;
                        const legEndY = webCenterY + Math.sin(angle) * 8;
                        this.ctx.beginPath();
                        this.ctx.moveTo(webCenterX, webCenterY);
                        this.ctx.lineTo(legEndX, legEndY);
                        this.ctx.stroke();
                    }
                    break;
                    
                case 'hanging_stick':
                    // 画从天上吊着的长木棍
                    this.ctx.fillStyle = '#8B4513';
                    this.ctx.fillRect(obstacle.x, obstacle.y, obstacle.width, obstacle.height);
                    
                    // 添加木棍纹理
                    this.ctx.fillStyle = '#654321';
                    this.ctx.fillRect(obstacle.x - 1, obstacle.y, 2, obstacle.height);
                    this.ctx.fillRect(obstacle.x + obstacle.width - 1, obstacle.y, 2, obstacle.height);
                    
                    // 添加吊绳效果
                    this.ctx.fillStyle = '#8B7355';
                    this.ctx.fillRect(obstacle.x + obstacle.width/2 - 1, 0, 2, obstacle.y);
                    break;
                    
                case 'ground_spike':
                    // 画地上长出的倒刺
                    this.ctx.fillStyle = '#696969';
                    this.ctx.beginPath();
                    this.ctx.moveTo(obstacle.x, obstacle.y + obstacle.height);
                    this.ctx.lineTo(obstacle.x + obstacle.width/2, obstacle.y);
                    this.ctx.lineTo(obstacle.x + obstacle.width, obstacle.y + obstacle.height);
                    this.ctx.closePath();
                    this.ctx.fill();
                    
                    // 添加倒刺纹理
                    this.ctx.fillStyle = '#4A4A4A';
                    this.ctx.fillRect(obstacle.x + obstacle.width/2 - 2, obstacle.y, 4, obstacle.height);
                    break;
                    
                case 'simple_rock':
                    // 画简单石头
                    this.ctx.fillStyle = '#696969';
                    this.ctx.beginPath();
                    this.ctx.arc(obstacle.x + obstacle.width/2, obstacle.y + obstacle.height/2, obstacle.width/2, 0, Math.PI * 2);
                    this.ctx.fill();
                    
                    // 添加石头纹理
                    this.ctx.fillStyle = '#4A4A4A';
                    this.ctx.beginPath();
                    this.ctx.arc(obstacle.x + obstacle.width/2 - 3, obstacle.y + obstacle.height/2 - 3, 2, 0, Math.PI * 2);
                    this.ctx.fill();
                    break;
                    
                case 'simple_branch':
                    // 画简单树枝
                    this.ctx.fillStyle = '#8B4513';
                    this.ctx.fillRect(obstacle.x, obstacle.y, obstacle.width, obstacle.height);
                    
                    // 添加树枝纹理
                    this.ctx.fillStyle = '#654321';
                    this.ctx.fillRect(obstacle.x + 5, obstacle.y, 2, obstacle.height);
                    this.ctx.fillRect(obstacle.x + obstacle.width - 7, obstacle.y, 2, obstacle.height);
                    break;
                    
                case 'simple_log':
                    // 画简单木桩
                    this.ctx.fillStyle = '#8B4513';
                    this.ctx.fillRect(obstacle.x, obstacle.y, obstacle.width, obstacle.height);
                    
                    // 添加木桩纹理
                    this.ctx.fillStyle = '#654321';
                    this.ctx.fillRect(obstacle.x + 3, obstacle.y, 2, obstacle.height);
                    this.ctx.fillRect(obstacle.x + obstacle.width - 5, obstacle.y, 2, obstacle.height);
                    
                    // 添加年轮效果
                    this.ctx.fillStyle = '#654321';
                    this.ctx.beginPath();
                    this.ctx.arc(obstacle.x + obstacle.width/2, obstacle.y + obstacle.height/2, obstacle.width/3, 0, Math.PI * 2);
                    this.ctx.stroke();
                    break;
                    
                default:
                    // 默认绘制矩形障碍物
                    this.ctx.fillRect(obstacle.x, obstacle.y, obstacle.width, obstacle.height);
                    break;
            }
        });
    }
    
    drawGems() {
        this.gems.forEach(gem => {
            if (!gem.collected) {
                // 更新宝石闪烁动画
                gem.sparkle += 0.1;
                const sparkleOffset = Math.sin(gem.sparkle) * 2;
                
                // 绘制宝石主体
                this.ctx.fillStyle = gem.color;
                this.ctx.beginPath();
                this.ctx.arc(gem.x + gem.width/2, gem.y + gem.height/2 + sparkleOffset, gem.width/2, 0, Math.PI * 2);
                this.ctx.fill();
                
                // 绘制宝石高光
                this.ctx.fillStyle = 'rgba(255, 255, 255, 0.9)';
                this.ctx.beginPath();
                this.ctx.arc(gem.x + gem.width/2 - 3, gem.y + gem.height/2 - 3 + sparkleOffset, 4, 0, Math.PI * 2);
                this.ctx.fill();
                
                // 绘制宝石闪烁效果
                const time = Date.now() * 0.01;
                const alpha = 0.4 + Math.sin(time * 3) * 0.3;
                this.ctx.strokeStyle = `rgba(255, 255, 255, ${alpha})`;
                this.ctx.lineWidth = 3;
                this.ctx.beginPath();
                this.ctx.arc(gem.x + gem.width/2, gem.y + gem.height/2 + sparkleOffset, gem.width/2 + 3, 0, Math.PI * 2);
                this.ctx.stroke();
                
                // 绘制宝石内部纹理
                this.ctx.strokeStyle = `rgba(255, 255, 255, 0.6)`;
                this.ctx.lineWidth = 1;
                this.ctx.beginPath();
                this.ctx.moveTo(gem.x + gem.width/2 - 5, gem.y + gem.height/2 + sparkleOffset);
                this.ctx.lineTo(gem.x + gem.width/2 + 5, gem.y + gem.height/2 + sparkleOffset);
                this.ctx.moveTo(gem.x + gem.width/2, gem.y + gem.height/2 - 5 + sparkleOffset);
                this.ctx.lineTo(gem.x + gem.width/2, gem.y + gem.height/2 + 5 + sparkleOffset);
                this.ctx.stroke();
            }
        });
    }
    
    drawAttractingGems() {
        // 绘制正在被吸附的宝石
        this.attractingGems.forEach(gem => {
            // 更新宝石闪烁动画
            gem.sparkle += 0.15;
            const sparkleOffset = Math.sin(gem.sparkle) * 3;
            
            // 绘制宝石主体（带有磁铁吸引效果）
            this.ctx.fillStyle = gem.color;
            this.ctx.beginPath();
            this.ctx.arc(gem.x + gem.width/2, gem.y + gem.height/2 + sparkleOffset, gem.width/2, 0, Math.PI * 2);
            this.ctx.fill();
            
            // 绘制宝石高光
            this.ctx.fillStyle = 'rgba(255, 255, 255, 0.9)';
            this.ctx.beginPath();
            this.ctx.arc(gem.x + gem.width/2 - 3, gem.y + gem.height/2 - 3 + sparkleOffset, 4, 0, Math.PI * 2);
            this.ctx.fill();
            
            // 绘制磁铁吸引效果（更强的闪烁）
            const time = Date.now() * 0.02;
            const alpha = 0.6 + Math.sin(time * 5) * 0.4;
            this.ctx.strokeStyle = `rgba(255, 255, 255, ${alpha})`;
            this.ctx.lineWidth = 4;
            this.ctx.beginPath();
            this.ctx.arc(gem.x + gem.width/2, gem.y + gem.height/2 + sparkleOffset, gem.width/2 + 5, 0, Math.PI * 2);
            this.ctx.stroke();
            
            // 绘制磁力线效果
            const dx = this.dimoo.x - gem.x;
            const dy = this.dimoo.y - gem.y;
            const angle = Math.atan2(dy, dx);
            
            this.ctx.strokeStyle = `rgba(255, 255, 255, ${alpha * 0.7})`;
            this.ctx.lineWidth = 2;
            this.ctx.beginPath();
            this.ctx.moveTo(gem.x + gem.width/2, gem.y + gem.height/2 + sparkleOffset);
            this.ctx.lineTo(
                gem.x + gem.width/2 + Math.cos(angle) * 20,
                gem.y + gem.height/2 + Math.sin(angle) * 20 + sparkleOffset
            );
            this.ctx.stroke();
            
            // 绘制螺旋轨迹
            this.ctx.strokeStyle = `rgba(255, 255, 255, ${alpha * 0.3})`;
            this.ctx.lineWidth = 1;
            this.ctx.beginPath();
            for (let i = 0; i < 10; i++) {
                const t = i / 10;
                const spiralX = gem.x + gem.width/2 + Math.cos(angle + t * Math.PI * 2) * (10 - t * 5);
                const spiralY = gem.y + gem.height/2 + Math.sin(angle + t * Math.PI * 2) * (10 - t * 5) + sparkleOffset;
                if (i === 0) {
                    this.ctx.moveTo(spiralX, spiralY);
                } else {
                    this.ctx.lineTo(spiralX, spiralY);
                }
            }
            this.ctx.stroke();
        });
    }
    
    drawMagnets() {
        if (!this.magnets) return;
        
        this.magnets.forEach(magnet => {
            if (!magnet.collected) {
                // 更新闪烁动画
                magnet.sparkle += 0.15;
                const sparkleValue = Math.sin(magnet.sparkle) * 0.4 + 0.6;
                
                // 绘制吸铁石主体（磁铁形状）
                this.ctx.fillStyle = magnet.color;
                this.ctx.fillRect(magnet.x, magnet.y, magnet.width, magnet.height);
                
                // 绘制磁铁极标识
                this.ctx.fillStyle = '#FFFFFF';
                this.ctx.fillRect(magnet.x + 2, magnet.y + 2, magnet.width - 4, 3);
                this.ctx.fillRect(magnet.x + 2, magnet.y + magnet.height - 5, magnet.width - 4, 3);
                
                // 绘制高光效果
                this.ctx.fillStyle = `rgba(255, 255, 255, ${sparkleValue * 0.9})`;
                this.ctx.fillRect(magnet.x + 1, magnet.y + 1, magnet.width - 2, magnet.height - 2);
                
                // 绘制磁力线效果
                this.ctx.strokeStyle = `rgba(255, 255, 255, ${sparkleValue * 0.6})`;
                this.ctx.lineWidth = 1;
                this.ctx.beginPath();
                this.ctx.moveTo(magnet.x + magnet.width + 5, magnet.y + magnet.height / 2);
                this.ctx.lineTo(magnet.x + magnet.width + 15, magnet.y + magnet.height / 2);
                this.ctx.stroke();
            }
        });
    }
    
    drawClouds() {
        this.ctx.fillStyle = this.backgrounds[this.currentBackground].clouds;
        this.clouds.forEach(cloud => {
            // 画更圆润的云朵
            this.ctx.beginPath();
            this.ctx.arc(cloud.x + cloud.width/2, cloud.y + cloud.height/2, cloud.width/2, 0, Math.PI * 2);
            this.ctx.fill();
        });
    }
    
    drawGround() {
        this.ctx.fillStyle = this.ground.color;
        this.ctx.fillRect(0, this.ground.y, this.width, this.ground.height);
        
        // 添加地面纹理
        this.ctx.fillStyle = this.currentBackground === 'day' ? '#654321' : '#0f3460';
        for (let i = 0; i < this.width; i += 20) {
            this.ctx.fillRect(i, this.ground.y, 2, this.ground.height);
        }
    }
    
    drawScore() {
        // 设置基础样式
        this.ctx.textAlign = 'left';
        this.ctx.fillStyle = this.backgrounds[this.currentBackground].text;
        
        // 主标题区域 - 得分
        this.ctx.font = 'bold 24px Arial';
        this.ctx.fillText(`得分: ${this.score.toLocaleString()}`, 25, 35);
        
        // 副标题区域 - 距离和速度
        this.ctx.font = '16px Arial';
        this.ctx.fillText(`距离: ${this.distance.toFixed(1)}m`, 25, 55);
        this.ctx.fillText(`速度: ${this.speedMultiplier.toFixed(1)}x`, 25, 75);
        
        // 希望计数 - 重要信息
        this.ctx.fillStyle = '#FFD700';
        this.ctx.font = 'bold 18px Arial';
        this.ctx.fillText(`💖 希望: ${this.gemCount}`, 25, 95);
        
        // 基础分数信息 - 小字体
        this.ctx.fillStyle = this.backgrounds[this.currentBackground].text;
        this.ctx.font = '12px Arial';
        const baseScore = Math.floor(this.speedMultiplier * 1);
        this.ctx.fillText(`基础分数: ${baseScore}/宝石`, 25, 110);
        
        // 背景信息 - 小字体
        this.ctx.fillText(`背景: ${this.currentBackground === 'day' ? '白天' : '黑夜'}`, 25, 125);
        
        // 希望盛宴倒计时不再显示
        
        // 右侧状态信息区域
        this.ctx.textAlign = 'right';
        const rightX = this.width - 25;
        let rightY = 35;
        
        // 显示爱心磁铁状态
        if (this.isMagnetActive) {
            const magnetTimeLeft = this.magnetDuration - (Date.now() - this.magnetStartTime);
            if (magnetTimeLeft > 0) {
                this.ctx.fillStyle = '#FF69B4';
                this.ctx.font = 'bold 16px Arial';
                this.ctx.fillText(`💖 世界之爱`, rightX, rightY);
                this.ctx.font = '14px Arial';
                this.ctx.fillText(`${(magnetTimeLeft / 1000).toFixed(1)}秒`, rightX, rightY + 20);
                rightY += 45;
            }
        }
        
        // 显示治愈状态
        if (this.isInvincible) {
            const isPeriodicHeal = this.invincibleDuration === 5000;
            const remainingTime = Math.max(0, this.invincibleDuration - (Date.now() - this.invincibleStartTime));
            
            if (isPeriodicHeal) {
                this.ctx.fillStyle = '#FFD700';
                this.ctx.font = 'bold 16px Arial';
                this.ctx.fillText('🌟 定期治愈', rightX, rightY);
                this.ctx.font = '14px Arial';
                this.ctx.fillText(`${(remainingTime / 1000).toFixed(1)}秒`, rightX, rightY + 20);
            } else {
                this.ctx.fillStyle = '#FF69B4';
                this.ctx.font = 'bold 16px Arial';
                this.ctx.fillText('💖 希望治愈', rightX, rightY);
                this.ctx.font = '14px Arial';
                this.ctx.fillText(`${(remainingTime / 1000).toFixed(1)}秒`, rightX, rightY + 20);
            }
            rightY += 45;
        }
        
        // 显示进化姿态状态
        if (this.isEvolutionMode) {
            const remainingTime = Math.max(0, this.evolutionDuration - (Date.now() - this.evolutionStartTime));
            
            if (this.evolutionType === 'rebirth') {
                this.ctx.fillStyle = '#FFD700';
                this.ctx.font = 'bold 16px Arial';
                this.ctx.fillText('🌟 重生动画', rightX, rightY);
                this.ctx.font = '14px Arial';
                this.ctx.fillText(`${(remainingTime / 1000).toFixed(1)}秒`, rightX, rightY + 20);
            } else if (this.evolutionType === 'death') {
                this.ctx.fillStyle = '#FF0000';
                this.ctx.font = 'bold 16px Arial';
                this.ctx.fillText('💀 凋零冲刺', rightX, rightY);
                this.ctx.fillStyle = '#FF69B4';
                this.ctx.font = '12px Arial';
                this.ctx.fillText('收集最后的希望', rightX, rightY + 20);
                this.ctx.fillStyle = '#FF0000';
                this.ctx.font = '14px Arial';
                this.ctx.fillText(`${(remainingTime / 1000).toFixed(1)}秒`, rightX, rightY + 35);
                rightY += 20;
            }
            rightY += 45;
        }
        
        // 显示得分倍数状态 - 左侧重要信息
        if (this.isScoreMultiplierActive) {
            const scoreMultiplierTimeLeft = this.scoreMultiplierDuration - (Date.now() - this.scoreMultiplierStartTime);
            if (scoreMultiplierTimeLeft > 0) {
                this.ctx.textAlign = 'left';
                this.ctx.fillStyle = '#FFD700';
                this.ctx.font = 'bold 16px Arial';
                this.ctx.fillText(`🎯 得分倍数: ${this.scoreMultiplierValue}x`, 25, 145);
                this.ctx.font = '14px Arial';
                this.ctx.fillText(`${(scoreMultiplierTimeLeft / 1000).toFixed(1)}秒`, 25, 165);
            }
        }
        
        // 显示胜利状态
        if (this.isVictoryMode) {
            const victoryTimeLeft = this.victoryDuration - (Date.now() - this.victoryStartTime);
            
            // 胜利宝石盛宴逻辑
            if (this.isVictoryFeastActive) {
                const feastTimeLeft = this.victoryFeastDuration - (Date.now() - this.victoryFeastStartTime);
                if (feastTimeLeft > 0) {
                    // 每500ms生成一次暖心话语宝石盛宴
                    if (Date.now() - this.lastVictoryFeastTime > 500) {
                        this.generateVictoryWarmMessageFeast();
                        this.lastVictoryFeastTime = Date.now();
                    }
                } else {
                    this.isVictoryFeastActive = false;
                    console.log('🎉 胜利宝石盛宴结束！');
                }
            }
            
            if (victoryTimeLeft > 0) {
                // 检查是否需要进入下一阶段
                const phaseTimeLeft = this.victoryPhaseDuration - (Date.now() - this.victoryPhaseStartTime);
                if (phaseTimeLeft <= 0 && this.victoryPhase < 3) {
                    this.victoryPhase++;
                    this.victoryPhaseStartTime = Date.now();
                    
                    console.log(`🎉 胜利动画进入阶段 ${this.victoryPhase}`);
                    
                    // 根据阶段生成不同的宝石文字
                    if (this.victoryPhase === 1) {
                        this.generateVictoryGems('subtitle');
                        console.log('💖 生成副标题宝石文字');
                    } else if (this.victoryPhase === 2) {
                        this.generateVictoryGems('warm');
                        console.log('💝 生成温暖话语宝石文字');
                    } else if (this.victoryPhase === 3) {
                        this.generateVictoryGems('life');
                        console.log('🌟 生成LIFE宝石文字');
                    }
                }
                
                // 显示当前阶段的胜利信息
                this.ctx.textAlign = 'center';
                
                // 阶段0：主标题
                if (this.victoryPhase === 0) {
                    // 添加背景效果
                    this.ctx.fillStyle = 'rgba(0, 0, 0, 0.6)';
                    this.ctx.fillRect(this.width / 2 - 200, this.height / 2 - 80, 400, 60);
                    
                    this.ctx.fillStyle = '#FFD700';
                    this.ctx.font = 'bold 36px Arial';
                    this.ctx.strokeStyle = '#000000';
                    this.ctx.lineWidth = 3;
                    
                    // 根据胜利类型显示不同的主标题
                    if (this.victoryType === 'score') {
                        // 分数成就：显示分数放大动画
                        const scoreScale = 1 + Math.sin(Date.now() * 0.005) * 0.2; // 脉冲缩放效果
                        this.ctx.save();
                        this.ctx.translate(this.width / 2, this.height / 2 - 30);
                        this.ctx.scale(scoreScale, scoreScale);
                        
                        this.ctx.strokeText('💖 我爱我一生一世！', 0, 0);
                        this.ctx.fillText('💖 我爱我一生一世！', 0, 0);
                        
                        this.ctx.restore();
                    } else {
                        // 其他胜利类型
                        this.ctx.strokeText('🎉 重获新生！', this.width / 2, this.height / 2 - 30);
                        this.ctx.fillText('🎉 重获新生！', this.width / 2, this.height / 2 - 30);
                    }
                }
                
                // 阶段1：副标题
                if (this.victoryPhase >= 1) {
                    // 添加背景效果
                    this.ctx.fillStyle = 'rgba(0, 0, 0, 0.6)';
                    this.ctx.fillRect(this.width / 2 - 250, this.height / 2 - 30, 500, 50);
                    
                    this.ctx.fillStyle = '#FF69B4';
                    this.ctx.font = 'bold 28px Arial';
                    this.ctx.strokeStyle = '#000000';
                    this.ctx.lineWidth = 2;
                    
                    // 根据胜利类型显示不同的副标题
                    if (this.victoryType === 'score') {
                        // 分数成就：显示分数
                        const scoreText = `💎 小恐龙在逆境中绽放光芒！得分：${this.score.toLocaleString()}`;
                        this.ctx.strokeText(scoreText, this.width / 2, this.height / 2 + 10);
                        this.ctx.fillText(scoreText, this.width / 2, this.height / 2 + 10);
                    } else {
                        // 其他胜利类型
                        this.ctx.strokeText('💖 小恐龙在世界中重新找到爱与希望！', this.width / 2, this.height / 2 + 10);
                        this.ctx.fillText('💖 小恐龙在世界中重新找到爱与希望！', this.width / 2, this.height / 2 + 10);
                    }
                }
                
                // 阶段2：温暖话语（用宝石显示）
                if (this.victoryPhase >= 2) {
                    if (this.victoryType === 'score') {
                        // 分数成就：显示分数宝石文字
                        this.drawScoreVictoryGems();
                    } else {
                        this.drawVictoryGems();
                    }
                }
                
                // 阶段3：LIFE文字（用宝石显示）
                if (this.victoryPhase >= 3) {
                    this.drawVictoryGems();
                }
                
                // 胜利时间 - 右侧显示
                this.ctx.textAlign = 'right';
                this.ctx.fillStyle = '#FFD700';
                this.ctx.font = '16px Arial';
                this.ctx.fillText(`胜利时间: ${(victoryTimeLeft / 1000).toFixed(1)}秒`, rightX, rightY);
                
                // 阶段指示器
                this.ctx.fillStyle = '#FF69B4';
                this.ctx.font = '14px Arial';
                this.ctx.fillText(`阶段: ${this.victoryPhase + 1}/4`, rightX, rightY + 25);
                this.ctx.fillText(`剩余: ${(phaseTimeLeft / 1000).toFixed(1)}秒`, rightX, rightY + 45);
                
                this.ctx.textAlign = 'left';
            } else {
                // 胜利时间结束后，动态LIFE界面
                this.drawDynamicLifeScreen();
            }
        }
        
        // 绘制生命条
        this.drawLives();
        
        // 显示临时提示信息
        this.drawTempMessage();
        
        // 删除暖心话语显示
    }
    
    drawTempMessage() {
        if (this.tempMessage && Date.now() - this.tempMessageStartTime < this.tempMessageDuration) {
            const timeLeft = this.tempMessageDuration - (Date.now() - this.tempMessageStartTime);
            const alpha = Math.min(1, timeLeft / 500); // 最后0.5秒淡出
            
            this.ctx.save();
            this.ctx.globalAlpha = alpha;
            
            // 添加背景
            this.ctx.fillStyle = 'rgba(0, 0, 0, 0.7)';
            this.ctx.fillRect(this.width - 300, this.height - 80, 280, 40);
            
            // 绘制边框
            this.ctx.strokeStyle = '#FF69B4';
            this.ctx.lineWidth = 2;
            this.ctx.strokeRect(this.width - 300, this.height - 80, 280, 40);
            
            // 绘制文字
            this.ctx.fillStyle = '#FF69B4';
            this.ctx.font = 'bold 16px Arial';
            this.ctx.textAlign = 'center';
            this.ctx.fillText(this.tempMessage, this.width - 160, this.height - 55);
            
            this.ctx.restore();
        }
    }
    
    drawDynamicLifeScreen() {
        // 初始化动态效果
        if (!this.lifeScreenAnimation) {
            this.lifeScreenAnimation = {
                time: 0,
                particles: [],
                sunRotation: 0,
                heartBeat: 0,
                textGlow: 0
            };
            
            // 生成粒子效果
            for (let i = 0; i < 50; i++) {
                this.lifeScreenAnimation.particles.push({
                    x: Math.random() * this.width,
                    y: Math.random() * this.height,
                    vx: (Math.random() - 0.5) * 2,
                    vy: (Math.random() - 0.5) * 2,
                    size: Math.random() * 3 + 1,
                    color: ['#FFD700', '#FF69B4', '#00CED1', '#32CD32'][Math.floor(Math.random() * 4)]
                });
            }
        }
        
        // 更新动画时间
        this.lifeScreenAnimation.time += 0.016;
        this.lifeScreenAnimation.sunRotation += 0.02;
        this.lifeScreenAnimation.heartBeat = Math.sin(this.lifeScreenAnimation.time * 3) * 0.1 + 1;
        this.lifeScreenAnimation.textGlow = Math.sin(this.lifeScreenAnimation.time * 2) * 0.3 + 0.7;
        
        // 绘制动态背景
        this.ctx.fillStyle = 'rgba(0, 0, 0, 0.9)';
        this.ctx.fillRect(0, 0, this.width, this.height);
        
        // 绘制粒子效果
        this.lifeScreenAnimation.particles.forEach(particle => {
            particle.x += particle.vx;
            particle.y += particle.vy;
            
            // 边界反弹
            if (particle.x < 0 || particle.x > this.width) particle.vx *= -1;
            if (particle.y < 0 || particle.y > this.height) particle.vy *= -1;
            
            this.ctx.fillStyle = particle.color;
            this.ctx.globalAlpha = 0.6;
            this.ctx.beginPath();
            this.ctx.arc(particle.x, particle.y, particle.size, 0, Math.PI * 2);
            this.ctx.fill();
        });
        this.ctx.globalAlpha = 1;
        
        // 绘制动态太阳
        this.drawDynamicSun(this.width / 2 + 200, this.height / 2 - 100);
        
        // 绘制动态爱心
        this.drawDynamicHeart(this.width / 2 - 200, this.height / 2 - 100);
        
        // 绘制LIFE文字（带发光效果）
        this.ctx.textAlign = 'center';
        this.ctx.shadowColor = '#FFD700';
        this.ctx.shadowBlur = 20 * this.lifeScreenAnimation.textGlow;
        this.ctx.fillStyle = '#FFD700';
        this.ctx.font = 'bold 48px Arial';
        this.ctx.fillText('LIFE', this.width / 2, this.height / 2);
        this.ctx.shadowBlur = 0;
        
        // 绘制中文文字（带脉冲效果）
        this.ctx.fillStyle = '#FF69B4';
        this.ctx.font = 'bold 24px Arial';
        this.ctx.globalAlpha = this.lifeScreenAnimation.textGlow;
        this.ctx.fillText('生命的意义在于爱与希望', this.width / 2, this.height / 2 + 60);
        
        this.ctx.fillStyle = '#FFFFFF';
        this.ctx.font = '18px Arial';
        this.ctx.fillText('小恐龙成功治愈抑郁症，重获新生！', this.width / 2, this.height / 2 + 100);
        this.ctx.globalAlpha = 1;
        
        // 重新开始提示现在由drawControlHints()统一处理
        
        this.ctx.textAlign = 'left';
    }
    
    drawDynamicSun(x, y) {
        this.ctx.save();
        this.ctx.translate(x, y);
        this.ctx.rotate(this.lifeScreenAnimation.sunRotation);
        
        // 太阳主体
        this.ctx.fillStyle = '#FFD700';
        this.ctx.beginPath();
        this.ctx.arc(0, 0, 40, 0, Math.PI * 2);
        this.ctx.fill();
        
        // 太阳光芒（动态旋转）
        this.ctx.strokeStyle = '#FFA500';
        this.ctx.lineWidth = 3;
        for (let i = 0; i < 12; i++) {
            const angle = (i / 12) * Math.PI * 2;
            const startX = Math.cos(angle) * 45;
            const startY = Math.sin(angle) * 45;
            const endX = Math.cos(angle) * 60;
            const endY = Math.sin(angle) * 60;
            
            this.ctx.beginPath();
            this.ctx.moveTo(startX, startY);
            this.ctx.lineTo(endX, endY);
            this.ctx.stroke();
        }
        
        // 太阳内部光晕
        this.ctx.fillStyle = '#FFFF00';
        this.ctx.globalAlpha = 0.6;
        this.ctx.beginPath();
        this.ctx.arc(0, 0, 25, 0, Math.PI * 2);
        this.ctx.fill();
        
        this.ctx.restore();
    }
    
    drawDynamicHeart(x, y) {
        this.ctx.save();
        this.ctx.translate(x, y);
        this.ctx.scale(this.lifeScreenAnimation.heartBeat, this.lifeScreenAnimation.heartBeat);
        
        // 绘制爱心 - 优化形状，更加明显
        this.ctx.fillStyle = '#FF1493'; // 更鲜艳的粉色
        this.ctx.beginPath();
        
        // 使用更明显的爱心形状
        this.ctx.moveTo(0, 25);
        
        // 左半边 - 更明显的曲线
        this.ctx.bezierCurveTo(-35, 5, -35, -25, 0, -25);
        this.ctx.bezierCurveTo(35, -25, 35, 5, 0, 25);
        
        // 右半边 - 对称的曲线
        this.ctx.bezierCurveTo(35, 5, 35, -25, 0, -25);
        this.ctx.bezierCurveTo(-35, -25, -35, 5, 0, 25);
        
        this.ctx.fill();
        
        // 爱心边框 - 更粗的边框
        this.ctx.strokeStyle = '#FF69B4';
        this.ctx.lineWidth = 4;
        this.ctx.stroke();
        
        // 添加内部高光
        this.ctx.fillStyle = '#FFFFFF';
        this.ctx.globalAlpha = 0.3;
        this.ctx.beginPath();
        this.ctx.arc(-10, -5, 8, 0, Math.PI * 2);
        this.ctx.fill();
        
        this.ctx.restore();
    }
    
    // 绘制耳朵 - 根据形态变化（融合DIMOO外星特征）
    drawEars(x, y, earType, bodyColor) {
        this.ctx.fillStyle = bodyColor;
        this.ctx.strokeStyle = '#000000';
        this.ctx.lineWidth = 1;
        
        if (earType === 'alien_pointed') {
            // 外星尖耳朵 - 类似DIMOO
            // 左耳
            this.ctx.beginPath();
            this.ctx.moveTo(x + 25, y + 5);
            this.ctx.lineTo(x + 20, y - 12);
            this.ctx.lineTo(x + 30, y - 8);
            this.ctx.closePath();
            this.ctx.fill();
            this.ctx.stroke();
            
            // 右耳
            this.ctx.beginPath();
            this.ctx.moveTo(x + 45, y + 5);
            this.ctx.lineTo(x + 50, y - 12);
            this.ctx.lineTo(x + 40, y - 8);
            this.ctx.closePath();
            this.ctx.fill();
            this.ctx.stroke();
        } else if (earType === 'alien_rounded') {
            // 外星圆耳朵 - 类似DIMOO的圆润特征
            // 左耳
            this.ctx.beginPath();
            this.ctx.arc(x + 25, y + 2, 8, 0, Math.PI * 2);
            this.ctx.fill();
            this.ctx.stroke();
            
            // 右耳
            this.ctx.beginPath();
            this.ctx.arc(x + 45, y + 2, 8, 0, Math.PI * 2);
            this.ctx.fill();
            this.ctx.stroke();
        }
    }
    
    // 绘制棉花糖发型 - 根据形态变化（融合DIMOO太空风格）
    drawHair(x, y, hairType, bodyColor) {
        this.ctx.strokeStyle = '#000000';
        this.ctx.lineWidth = 1;
        
        if (hairType === 'messy_cotton') {
            // 凌乱棉花糖发型 - 抑郁状态 - 深灰色
            this.ctx.fillStyle = '#696969'; // 深灰色
            for (let i = 0; i < 8; i++) {
                const offsetX = Math.sin(i * 0.5) * 2;
                const offsetY = Math.cos(i * 0.5) * 2;
                this.ctx.beginPath();
                this.ctx.arc(x + 25 + i * 3 + offsetX, y - 8 + offsetY, 4, 0, Math.PI * 2);
                this.ctx.fill();
            }
        } else if (hairType === 'neat_cotton') {
            // 整齐棉花糖发型 - 治愈中 - 淡紫色
            this.ctx.fillStyle = '#E6E6FA'; // 淡紫色
            for (let i = 0; i < 7; i++) {
                this.ctx.beginPath();
                this.ctx.arc(x + 26 + i * 3, y - 6, 4, 0, Math.PI * 2);
                this.ctx.fill();
            }
        } else if (hairType === 'styled_cotton') {
            // 造型棉花糖发型 - 康复中 - 淡绿色
            this.ctx.fillStyle = '#98FB98'; // 淡绿色
            for (let i = 0; i < 7; i++) {
                const wave = Math.sin(i * 0.8) * 1.5;
                this.ctx.beginPath();
                this.ctx.arc(x + 26 + i * 3, y - 7 + wave, 4.5, 0, Math.PI * 2);
                this.ctx.fill();
            }
        } else if (hairType === 'fluffy_cotton') {
            // 蓬松棉花糖发型 - 治愈完成 - 淡橙色
            this.ctx.fillStyle = '#FFE4B5'; // 淡橙色
            for (let i = 0; i < 8; i++) {
                const puff = Math.sin(i * 0.6) * 2;
                this.ctx.beginPath();
                this.ctx.arc(x + 25 + i * 3, y - 8 + puff, 5, 0, Math.PI * 2);
                this.ctx.fill();
            }
        } else if (hairType === 'glowing_cotton') {
            // 发光棉花糖发型 - 光芒四射 - 金黄色发光
            this.ctx.fillStyle = '#FFD700';
            this.ctx.globalAlpha = 0.9;
            for (let i = 0; i < 9; i++) {
                const glow = Math.sin(i * 0.7) * 3;
                this.ctx.beginPath();
                this.ctx.arc(x + 24 + i * 3, y - 10 + glow, 6, 0, Math.PI * 2);
                this.ctx.fill();
            }
            // 添加发光效果
            this.ctx.shadowColor = '#FFD700';
            this.ctx.shadowBlur = 10;
            for (let i = 0; i < 9; i++) {
                const glow = Math.sin(i * 0.7) * 3;
                this.ctx.beginPath();
                this.ctx.arc(x + 24 + i * 3, y - 10 + glow, 6, 0, Math.PI * 2);
                this.ctx.fill();
            }
            this.ctx.shadowColor = 'transparent';
            this.ctx.shadowBlur = 0;
            this.ctx.globalAlpha = 1;
        }
    }
    
    // 绘制眼睛 - 根据形态变化（融合DIMOO外星特征）
    drawEyes(x, y, eyeType, eyeColor) {
        // 眼睛基础 - 白色
        this.ctx.fillStyle = 'white';
        this.ctx.beginPath();
        this.ctx.arc(x + 40, y + 8, 8, 0, Math.PI * 2);
        this.ctx.fill();
        
        // 眼睛轮廓
        this.ctx.strokeStyle = '#000000';
        this.ctx.lineWidth = 2;
        this.ctx.beginPath();
        this.ctx.arc(x + 40, y + 8, 8, 0, Math.PI * 2);
        this.ctx.stroke();
        
        // 根据眼睛类型绘制不同的瞳孔
        if (eyeType === 'sad_alien') {
            // 悲伤外星眼睛 - 下垂，更大
            this.ctx.fillStyle = eyeColor;
            this.ctx.beginPath();
            this.ctx.arc(x + 42, y + 10, 4, 0, Math.PI * 2);
            this.ctx.fill();
        } else if (eyeType === 'sparkling_alien') {
            // 闪烁外星眼睛 - 类似DIMOO的好奇眼神
            this.ctx.fillStyle = '#00CED1'; // 湖绿色
            this.ctx.beginPath();
            this.ctx.arc(x + 42, y + 8, 5, 0, Math.PI * 2);
            this.ctx.fill();
            
            // 添加闪烁效果
            this.ctx.fillStyle = 'rgba(255, 255, 255, 0.9)';
            this.ctx.beginPath();
            this.ctx.arc(x + 44, y + 6, 3, 0, Math.PI * 2);
            this.ctx.fill();
        } else if (eyeType === 'bright_alien') {
            // 明亮外星眼睛
            this.ctx.fillStyle = eyeColor;
            this.ctx.beginPath();
            this.ctx.arc(x + 42, y + 8, 5, 0, Math.PI * 2);
            this.ctx.fill();
            
            // 眼睛高光
            this.ctx.fillStyle = 'rgba(255, 255, 255, 0.9)';
            this.ctx.beginPath();
            this.ctx.arc(x + 41, y + 6, 3, 0, Math.PI * 2);
            this.ctx.fill();
        } else if (eyeType === 'joyful_alien') {
            // 快乐外星眼睛
            this.ctx.fillStyle = eyeColor;
            this.ctx.beginPath();
            this.ctx.arc(x + 42, y + 8, 5, 0, Math.PI * 2);
            this.ctx.fill();
            
            // 大眼睛高光
            this.ctx.fillStyle = 'rgba(255, 255, 255, 0.9)';
            this.ctx.beginPath();
            this.ctx.arc(x + 41, y + 6, 3, 0, Math.PI * 2);
            this.ctx.fill();
            this.ctx.beginPath();
            this.ctx.arc(x + 43, y + 7, 2, 0, Math.PI * 2);
            this.ctx.fill();
        } else if (eyeType === 'radiant_alien') {
            // 光芒四射的外星眼睛
            this.ctx.fillStyle = eyeColor;
            this.ctx.beginPath();
            this.ctx.arc(x + 42, y + 8, 5, 0, Math.PI * 2);
            this.ctx.fill();
            
            // 多层高光
            this.ctx.fillStyle = 'rgba(255, 255, 255, 0.9)';
            this.ctx.beginPath();
            this.ctx.arc(x + 41, y + 6, 3, 0, Math.PI * 2);
            this.ctx.fill();
            this.ctx.beginPath();
            this.ctx.arc(x + 43, y + 7, 2, 0, Math.PI * 2);
            this.ctx.fill();
            this.ctx.beginPath();
            this.ctx.arc(x + 40, y + 9, 1.5, 0, Math.PI * 2);
            this.ctx.fill();
        }
    }
    
    // 绘制嘴巴 - 根据形态变化
    drawMouth(x, y, mouthType) {
        this.ctx.strokeStyle = '#000000';
        this.ctx.lineWidth = 2;
        this.ctx.beginPath();
        
        if (mouthType === 'pout') {
            // 嘟嘴 - 类似Molly的经典表情
            this.ctx.arc(x + 35, y + 20, 4, 0, Math.PI);
        } else if (mouthType === 'slight_smile') {
            // 轻微微笑
            this.ctx.arc(x + 35, y + 16, 5, 0, Math.PI);
        } else if (mouthType === 'happy') {
            // 开心笑容 - 类似FARMER BOB的憨厚
            this.ctx.arc(x + 35, y + 15, 6, 0, Math.PI);
        } else if (mouthType === 'big_smile') {
            // 大笑 - 类似Molly的灿烂笑容
            this.ctx.arc(x + 35, y + 14, 7, 0, Math.PI);
        } else if (mouthType === 'radiant') {
            // 光芒四射的笑容 - 类似RiCO的可爱萌态
            this.ctx.arc(x + 35, y + 13, 8, 0, Math.PI);
        }
        
        this.ctx.stroke();
    }
    
    // 绘制发光触角 - DIMOO外星特征（太空风格）
    drawAntenna(x, y, antennaType, bodyColor) {
        this.ctx.strokeStyle = '#000000';
        this.ctx.lineWidth = 2;
        
        if (antennaType === 'droopy') {
            // 下垂触角 - 抑郁状态 - 灰色
            this.ctx.strokeStyle = '#666666';
            this.ctx.beginPath();
            this.ctx.moveTo(x + 35, y - 5);
            this.ctx.quadraticCurveTo(x + 35, y - 15, x + 30, y - 20);
            this.ctx.stroke();
            
            // 触角末端
            this.ctx.fillStyle = '#666666';
            this.ctx.beginPath();
            this.ctx.arc(x + 30, y - 20, 3, 0, Math.PI * 2);
            this.ctx.fill();
        } else if (antennaType === 'curious') {
            // 好奇触角 - 治愈中 - 蓝色
            this.ctx.strokeStyle = '#3498db';
            this.ctx.lineWidth = 3;
            this.ctx.beginPath();
            this.ctx.moveTo(x + 35, y - 5);
            this.ctx.quadraticCurveTo(x + 40, y - 15, x + 45, y - 18);
            this.ctx.stroke();
            
            // 触角末端 - 发光球体
            this.ctx.fillStyle = '#3498db';
            this.ctx.shadowColor = '#3498db';
            this.ctx.shadowBlur = 8;
            this.ctx.beginPath();
            this.ctx.arc(x + 45, y - 18, 4, 0, Math.PI * 2);
            this.ctx.fill();
            this.ctx.shadowColor = 'transparent';
            this.ctx.shadowBlur = 0;
        } else if (antennaType === 'active') {
            // 活跃触角 - 康复中 - 绿色
            this.ctx.strokeStyle = '#27ae60';
            this.ctx.lineWidth = 3;
            this.ctx.beginPath();
            this.ctx.moveTo(x + 35, y - 5);
            this.ctx.quadraticCurveTo(x + 42, y - 12, x + 48, y - 15);
            this.ctx.stroke();
            
            // 触角末端 - 发光球体
            this.ctx.fillStyle = '#27ae60';
            this.ctx.shadowColor = '#27ae60';
            this.ctx.shadowBlur = 10;
            this.ctx.beginPath();
            this.ctx.arc(x + 48, y - 15, 4, 0, Math.PI * 2);
            this.ctx.fill();
            this.ctx.shadowColor = 'transparent';
            this.ctx.shadowBlur = 0;
        } else if (antennaType === 'happy') {
            // 快乐触角 - 治愈完成 - 橙色
            this.ctx.strokeStyle = '#f39c12';
            this.ctx.lineWidth = 3;
            this.ctx.beginPath();
            this.ctx.moveTo(x + 35, y - 5);
            this.ctx.quadraticCurveTo(x + 45, y - 10, x + 50, y - 12);
            this.ctx.stroke();
            
            // 触角末端 - 发光球体
            this.ctx.fillStyle = '#f39c12';
            this.ctx.shadowColor = '#f39c12';
            this.ctx.shadowBlur = 12;
            this.ctx.beginPath();
            this.ctx.arc(x + 50, y - 12, 5, 0, Math.PI * 2);
            this.ctx.fill();
            this.ctx.shadowColor = 'transparent';
            this.ctx.shadowBlur = 0;
        } else if (antennaType === 'glowing') {
            // 发光触角 - 光芒四射 - 金黄色发光
            this.ctx.strokeStyle = '#FFD700';
            this.ctx.lineWidth = 4;
            this.ctx.globalAlpha = 0.9;
            this.ctx.shadowColor = '#FFD700';
            this.ctx.shadowBlur = 15;
            this.ctx.beginPath();
            this.ctx.moveTo(x + 35, y - 5);
            this.ctx.quadraticCurveTo(x + 48, y - 8, x + 55, y - 10);
            this.ctx.stroke();
            
            // 发光触角末端 - 强烈发光球体
            this.ctx.fillStyle = '#FFD700';
            this.ctx.shadowColor = '#FFD700';
            this.ctx.shadowBlur = 20;
            this.ctx.beginPath();
            this.ctx.arc(x + 55, y - 10, 6, 0, Math.PI * 2);
            this.ctx.fill();
            
            // 添加内部高光
            this.ctx.fillStyle = '#FFFFFF';
            this.ctx.shadowColor = 'transparent';
            this.ctx.shadowBlur = 0;
            this.ctx.beginPath();
            this.ctx.arc(x + 53, y - 12, 2, 0, Math.PI * 2);
            this.ctx.fill();
            
            this.ctx.globalAlpha = 1;
            this.ctx.lineWidth = 2;
            this.ctx.shadowColor = 'transparent';
            this.ctx.shadowBlur = 0;
        }
    }
    
    // 绘制DIMOO身体 - 根据形态变化
    drawDimooBody(x, y, bodyType, bodyColor, skinColor) {
        this.ctx.fillStyle = bodyColor;
        this.ctx.strokeStyle = '#000000';
        this.ctx.lineWidth = 1;
        
        if (bodyType === 'small') {
            // 小身体 - 抑郁状态
            this.ctx.beginPath();
            this.ctx.ellipse(x + 25, y + 25, 15, 10, 0, 0, Math.PI * 2);
            this.ctx.fill();
            this.ctx.stroke();
        } else if (bodyType === 'medium') {
            // 中等身体 - 治愈中
            this.ctx.beginPath();
            this.ctx.ellipse(x + 25, y + 25, 17, 11, 0, 0, Math.PI * 2);
            this.ctx.fill();
            this.ctx.stroke();
        } else if (bodyType === 'normal') {
            // 正常身体 - 康复中
            this.ctx.beginPath();
            this.ctx.ellipse(x + 25, y + 25, 18, 12, 0, 0, Math.PI * 2);
            this.ctx.fill();
            this.ctx.stroke();
        } else if (bodyType === 'full') {
            // 饱满身体 - 治愈完成
            this.ctx.beginPath();
            this.ctx.ellipse(x + 25, y + 25, 19, 13, 0, 0, Math.PI * 2);
            this.ctx.fill();
            this.ctx.stroke();
        } else if (bodyType === 'glowing') {
            // 发光身体 - 光芒四射
            this.ctx.globalAlpha = 0.8;
            this.ctx.fillStyle = bodyColor;
            this.ctx.beginPath();
            this.ctx.ellipse(x + 25, y + 25, 20, 14, 0, 0, Math.PI * 2);
            this.ctx.fill();
            this.ctx.globalAlpha = 1;
            this.ctx.stroke();
        }
    }
    
    // 绘制DIMOO头部
    drawDimooHead(x, y, bodyColor) {
        this.ctx.fillStyle = bodyColor;
        this.ctx.strokeStyle = '#000000';
        this.ctx.lineWidth = 1;
        
        // 头部 - 圆润的头部
        this.ctx.beginPath();
        this.ctx.arc(x + 35, y + 12, 18, 0, Math.PI * 2);
        this.ctx.fill();
        this.ctx.stroke();
    }
    
    // 绘制DIMOO手臂 - 根据形态变化
    drawDimooArms(x, y, armType, bodyColor) {
        this.ctx.fillStyle = bodyColor;
        this.ctx.strokeStyle = '#000000';
        this.ctx.lineWidth = 1;
        
        if (armType === 'droopy') {
            // 下垂手臂 - 抑郁状态
            this.ctx.beginPath();
            this.ctx.ellipse(x + 15, y + 30, 4, 8, 0, 0, Math.PI * 2);
            this.ctx.fill();
            this.ctx.stroke();
            this.ctx.beginPath();
            this.ctx.ellipse(x + 35, y + 30, 4, 8, 0, 0, Math.PI * 2);
            this.ctx.fill();
            this.ctx.stroke();
        } else if (armType === 'relaxed') {
            // 放松手臂 - 治愈中
            this.ctx.beginPath();
            this.ctx.ellipse(x + 16, y + 28, 5, 9, 0, 0, Math.PI * 2);
            this.ctx.fill();
            this.ctx.stroke();
            this.ctx.beginPath();
            this.ctx.ellipse(x + 34, y + 28, 5, 9, 0, 0, Math.PI * 2);
            this.ctx.fill();
            this.ctx.stroke();
        } else if (armType === 'active') {
            // 活跃手臂 - 康复中
            this.ctx.beginPath();
            this.ctx.ellipse(x + 17, y + 26, 6, 10, 0, 0, Math.PI * 2);
            this.ctx.fill();
            this.ctx.stroke();
            this.ctx.beginPath();
            this.ctx.ellipse(x + 33, y + 26, 6, 10, 0, 0, Math.PI * 2);
            this.ctx.fill();
            this.ctx.stroke();
        } else if (armType === 'happy') {
            // 快乐手臂 - 治愈完成
            this.ctx.beginPath();
            this.ctx.ellipse(x + 18, y + 24, 6, 11, 0, 0, Math.PI * 2);
            this.ctx.fill();
            this.ctx.stroke();
            this.ctx.beginPath();
            this.ctx.ellipse(x + 32, y + 24, 6, 11, 0, 0, Math.PI * 2);
            this.ctx.fill();
            this.ctx.stroke();
        } else if (armType === 'radiant') {
            // 光芒四射手臂 - 光芒四射
            this.ctx.globalAlpha = 0.8;
            this.ctx.fillStyle = bodyColor;
            this.ctx.beginPath();
            this.ctx.ellipse(x + 19, y + 22, 7, 12, 0, 0, Math.PI * 2);
            this.ctx.fill();
            this.ctx.stroke();
            this.ctx.beginPath();
            this.ctx.ellipse(x + 31, y + 22, 7, 12, 0, 0, Math.PI * 2);
            this.ctx.fill();
            this.ctx.stroke();
            this.ctx.globalAlpha = 1;
        }
    }
    
    // 绘制DIMOO腿部 - 根据形态变化
    drawDimooLegs(x, y, legType, bodyColor) {
        // 检查是否跳跃，如果跳跃则不绘制腿部
        if (this.dimoo.jumping || this.dimoo.isGliding) {
            return; // 跳跃时不绘制腿部
        }
        
        this.ctx.fillStyle = bodyColor;
        this.ctx.strokeStyle = '#000000';
        this.ctx.lineWidth = 1;
        
        if (legType === 'weak') {
            // 虚弱腿部 - 抑郁状态
            this.ctx.beginPath();
            this.ctx.ellipse(x + 18, y + 40, 3, 6, 0, 0, Math.PI * 2);
            this.ctx.fill();
            this.ctx.stroke();
            this.ctx.beginPath();
            this.ctx.ellipse(x + 28, y + 40, 3, 6, 0, 0, Math.PI * 2);
            this.ctx.fill();
            this.ctx.stroke();
            this.ctx.beginPath();
            this.ctx.ellipse(x + 38, y + 40, 3, 6, 0, 0, Math.PI * 2);
            this.ctx.fill();
            this.ctx.stroke();
            this.ctx.beginPath();
            this.ctx.ellipse(x + 48, y + 40, 3, 6, 0, 0, Math.PI * 2);
            this.ctx.fill();
            this.ctx.stroke();
        } else if (legType === 'normal') {
            // 正常腿部 - 治愈中
            this.ctx.beginPath();
            this.ctx.ellipse(x + 18, y + 40, 4, 7, 0, 0, Math.PI * 2);
            this.ctx.fill();
            this.ctx.stroke();
            this.ctx.beginPath();
            this.ctx.ellipse(x + 28, y + 40, 4, 7, 0, 0, Math.PI * 2);
            this.ctx.fill();
            this.ctx.stroke();
            this.ctx.beginPath();
            this.ctx.ellipse(x + 38, y + 40, 4, 7, 0, 0, Math.PI * 2);
            this.ctx.fill();
            this.ctx.stroke();
            this.ctx.beginPath();
            this.ctx.ellipse(x + 48, y + 40, 4, 7, 0, 0, Math.PI * 2);
            this.ctx.fill();
            this.ctx.stroke();
        } else if (legType === 'strong') {
            // 强壮腿部 - 康复中
            this.ctx.beginPath();
            this.ctx.ellipse(x + 18, y + 40, 5, 8, 0, 0, Math.PI * 2);
            this.ctx.fill();
            this.ctx.stroke();
            this.ctx.beginPath();
            this.ctx.ellipse(x + 28, y + 40, 5, 8, 0, 0, Math.PI * 2);
            this.ctx.fill();
            this.ctx.stroke();
            this.ctx.beginPath();
            this.ctx.ellipse(x + 38, y + 40, 5, 8, 0, 0, Math.PI * 2);
            this.ctx.fill();
            this.ctx.stroke();
            this.ctx.beginPath();
            this.ctx.ellipse(x + 48, y + 40, 5, 8, 0, 0, Math.PI * 2);
            this.ctx.fill();
            this.ctx.stroke();
        } else if (legType === 'energetic') {
            // 充满活力腿部 - 治愈完成
            this.ctx.beginPath();
            this.ctx.ellipse(x + 18, y + 40, 6, 9, 0, 0, Math.PI * 2);
            this.ctx.fill();
            this.ctx.stroke();
            this.ctx.beginPath();
            this.ctx.ellipse(x + 28, y + 40, 6, 9, 0, 0, Math.PI * 2);
            this.ctx.fill();
            this.ctx.stroke();
            this.ctx.beginPath();
            this.ctx.ellipse(x + 38, y + 40, 6, 9, 0, 0, Math.PI * 2);
            this.ctx.fill();
            this.ctx.stroke();
            this.ctx.beginPath();
            this.ctx.ellipse(x + 48, y + 40, 6, 9, 0, 0, Math.PI * 2);
            this.ctx.fill();
            this.ctx.stroke();
        } else if (legType === 'magical') {
            // 魔法腿部 - 光芒四射
            this.ctx.globalAlpha = 0.8;
            this.ctx.fillStyle = bodyColor;
            this.ctx.beginPath();
            this.ctx.ellipse(x + 18, y + 40, 7, 10, 0, 0, Math.PI * 2);
            this.ctx.fill();
            this.ctx.stroke();
            this.ctx.beginPath();
            this.ctx.ellipse(x + 28, y + 40, 7, 10, 0, 0, Math.PI * 2);
            this.ctx.fill();
            this.ctx.stroke();
            this.ctx.beginPath();
            this.ctx.ellipse(x + 38, y + 40, 7, 10, 0, 0, Math.PI * 2);
            this.ctx.fill();
            this.ctx.stroke();
            this.ctx.beginPath();
            this.ctx.ellipse(x + 48, y + 40, 7, 10, 0, 0, Math.PI * 2);
            this.ctx.fill();
            this.ctx.stroke();
            this.ctx.globalAlpha = 1;
        }
        
        // 小脚丫 - 可爱的小圆点
        this.ctx.fillStyle = '#FF69B4';
        this.ctx.beginPath();
        this.ctx.arc(x + 18, y + 48, 2, 0, Math.PI * 2);
        this.ctx.fill();
        this.ctx.beginPath();
        this.ctx.arc(x + 28, y + 48, 2, 0, Math.PI * 2);
        this.ctx.fill();
        this.ctx.beginPath();
        this.ctx.arc(x + 38, y + 48, 2, 0, Math.PI * 2);
        this.ctx.fill();
        this.ctx.beginPath();
        this.ctx.arc(x + 48, y + 48, 2, 0, Math.PI * 2);
        this.ctx.fill();
    }
    
    drawControlHints() {
        // 在画面底部显示游戏控制提示
        this.ctx.save();
        
        // 设置文本样式
        this.ctx.fillStyle = '#FFFFFF';
        this.ctx.font = '14px Arial';
        this.ctx.textAlign = 'center';
        this.ctx.globalAlpha = 0.8;
        
        const bottomY = this.height - 20;
        const spacing = 150; // 提示之间的间距
        
        // 根据游戏状态显示不同的控制提示
        if (!this.gameRunning && !this.gameOver && !this.isVictoryMode) {
            // 游戏开始前
            this.ctx.fillText('空格键/↑/W 开始治愈之旅', this.width / 2, bottomY);
        } else if (this.gameRunning) {
            // 游戏进行中 - 显示完整的控制说明
            this.ctx.fillText('空格键/↑/W 跳跃', this.width / 2 - spacing * 1.5, bottomY);
            this.ctx.fillText('↓/S 下蹲', this.width / 2 - spacing * 0.5, bottomY);
            this.ctx.fillText('W 滑翔', this.width / 2 + spacing * 0.5, bottomY);
            this.ctx.fillText('三连跳', this.width / 2 + spacing * 1.5, bottomY);
        } else if (this.gameOver) {
            // 游戏结束
            this.ctx.fillText('空格键 重新开始', this.width / 2, bottomY);
        } else if (this.isVictoryMode) {
            // 胜利状态
            this.ctx.fillText('空格键 重新开始', this.width / 2, bottomY);
        }
        
        this.ctx.restore();
    }
    
    // 删除drawWarmMessage函数
    
    showTempMessage(message) {
        this.tempMessage = message;
        this.tempMessageStartTime = Date.now();
    }
    
    drawLives() {
        const centerX = this.width / 2;
        const topY = 25;
        const heartSize = 22;
        const spacing = 28;
        
        // 移除生命条背景，保持画面简洁
        
        if (this.lives <= 12) {
            // 生命数量少时显示爱心图标
            const totalWidth = this.lives * spacing;
            const startX = centerX - totalWidth / 2;
            
            for (let i = 0; i < this.lives; i++) {
                const x = startX + i * spacing;
                this.drawHeart(x, topY, heartSize);
            }
        } else {
            // 生命数量多时显示数字在爱心里
            this.drawHeart(centerX - heartSize/2, topY, heartSize);
            
            // 在爱心里显示数字
            this.ctx.fillStyle = '#FFFFFF';
            this.ctx.font = 'bold 14px Arial';
            this.ctx.textAlign = 'center';
            this.ctx.fillText(this.lives.toString(), centerX, topY + heartSize/2 + 4);
            this.ctx.textAlign = 'left'; // 重置文本对齐
        }
    }
    
    drawHeart(x, y, size) {
        this.ctx.fillStyle = '#FF6B6B';
        this.ctx.strokeStyle = '#FF4757';
        this.ctx.lineWidth = 2;
        
        // 绘制爱心形状
        this.ctx.beginPath();
        this.ctx.moveTo(x, y + size * 0.3);
        
        // 左半边
        this.ctx.bezierCurveTo(
            x, y, 
            x - size * 0.5, y, 
            x - size * 0.5, y + size * 0.3
        );
        this.ctx.bezierCurveTo(
            x - size * 0.5, y + size * 0.6, 
            x, y + size * 0.8, 
            x, y + size * 0.8
        );
        
        // 右半边
        this.ctx.bezierCurveTo(
            x, y + size * 0.8, 
            x + size * 0.5, y + size * 0.6, 
            x + size * 0.5, y + size * 0.3
        );
        this.ctx.bezierCurveTo(
            x + size * 0.5, y, 
            x, y, 
            x, y + size * 0.3
        );
        
        this.ctx.fill();
        this.ctx.stroke();
    }
    
    draw() {
        // 清除画布
        this.ctx.clearRect(0, 0, this.width, this.height);
        
        // 绘制背景
        this.ctx.fillStyle = this.backgrounds[this.currentBackground].sky;
        this.ctx.fillRect(0, 0, this.width, this.height);
        
        // 绘制云朵
        this.drawClouds();
        
        // 绘制地面
        this.drawGround();
        
        // 绘制障碍物
        this.drawObstacles();
        
        // 绘制希望宝石
        this.drawGems();
        
        // 绘制正在被吸附的宝石
        this.drawAttractingGems();
        
        // 绘制爱心磁铁
        this.drawMagnets();
        
        // 绘制治愈冲刺道具
        this.drawHealingBoosters();
        
        // 绘制爱心道具
        this.drawHeartItems();
        
        // 绘制得分倍数道具
        this.drawScoreMultipliers();
        
        // 绘制胜利宝石
        this.drawVictoryGems();
        
        // 绘制DIMOO
        this.drawDimoo();
        
        // 绘制分数
        this.drawScore();
        
        // 绘制游戏控制提示
        this.drawControlHints();
    }
    
    gameLoop(currentTime = 0) {
        const deltaTime = currentTime - this.lastTime;
        this.lastTime = currentTime;
        
        // 性能监控
        this.checkPerformance();
        
        // 调试信息 - 只在第一次运行时输出
        if (!this.debugOutput) {
            console.log('游戏循环开始运行，gameRunning:', this.gameRunning);
            console.log('DIMOO位置:', this.dimoo.x, this.dimoo.y);
            console.log('距离:', this.distance);
            this.debugOutput = true;
        }
        
        if (this.gameRunning) {
            this.updateDino();
            this.updateObstacles();
            this.updateClouds();
            this.checkCollisions();
        }
        
        this.draw();
        requestAnimationFrame((time) => this.gameLoop(time));
    }
    
    // 新增的宝石排列模式
    generateButterflyFeast() {
        // 蝴蝶形宝石盛宴
        const centerX = this.width + 200;
        const centerY = this.height / 2;
        
        // 蝴蝶翅膀图案
        for (let angle = 0; angle < Math.PI * 2; angle += 0.1) {
            const r = 50 + Math.sin(angle * 4) * 30;
            const x = centerX + Math.cos(angle) * r;
            const y = centerY + Math.sin(angle) * r;
            
            if (y > 50 && y < this.height - 100) {
                this.gems.push({
                    x: x,
                    y: y,
                    width: 15,
                    height: 15,
                    color: this.getGemColor(),
                    collected: false,
                    sparkle: 0
                });
            }
        }
    }
    
    generateStarryNightFeast() {
        // 星空宝石盛宴
        const startX = this.width + 100;
        
        for (let i = 0; i < 50; i++) {
            const x = startX + Math.random() * 400;
            const y = 50 + Math.random() * (this.height - 200);
            
            this.gems.push({
                x: x,
                y: y,
                width: 15,
                height: 15,
                color: this.getGemColor(),
                collected: false,
                sparkle: 0
            });
        }
    }
    
    generateFlowerGardenFeast() {
        // 花园宝石盛宴
        const startX = this.width + 100;
        
        for (let i = 0; i < 5; i++) {
            const flowerX = startX + i * 80;
            const flowerY = this.height / 2;
            
            // 每朵花的花瓣
            for (let angle = 0; angle < Math.PI * 2; angle += Math.PI / 6) {
                const x = flowerX + Math.cos(angle) * 20;
                const y = flowerY + Math.sin(angle) * 20;
                
                if (y > 50 && y < this.height - 100) {
                    this.gems.push({
                        x: x,
                        y: y,
                        width: 15,
                        height: 15,
                        color: this.getGemColor(),
                        collected: false,
                        sparkle: 0
                    });
                }
            }
        }
    }
    
    generateMountainRangeFeast() {
        // 山脉宝石盛宴
        const startX = this.width + 100;
        const baseY = this.height - 150;
        
        for (let x = 0; x < 400; x += 15) {
            const mountainY = baseY - Math.sin(x * 0.01) * 50 - Math.sin(x * 0.03) * 30;
            
            if (mountainY > 50 && mountainY < this.height - 100) {
                this.gems.push({
                    x: startX + x,
                    y: mountainY,
                    width: 15,
                    height: 15,
                    color: this.getGemColor(),
                    collected: false,
                    sparkle: 0
                });
            }
        }
    }
    
    generateOceanWavesFeast() {
        // 海浪宝石盛宴
        const startX = this.width + 100;
        
        for (let x = 0; x < 400; x += 10) {
            const waveY = this.height / 2 + Math.sin(x * 0.02) * 40 + Math.sin(x * 0.05) * 20;
            
            if (waveY > 50 && waveY < this.height - 100) {
                this.gems.push({
                    x: startX + x,
                    y: waveY,
                    width: 15,
                    height: 15,
                    color: this.getGemColor(),
                    collected: false,
                    sparkle: 0
                });
            }
        }
    }
    
    generateForestPathFeast() {
        // 森林小径宝石盛宴
        const startX = this.width + 100;
        
        for (let i = 0; i < 8; i++) {
            const treeX = startX + i * 50;
            const treeY = this.height - 100 - Math.random() * 50;
            
            // 每棵树的树叶
            for (let j = 0; j < 5; j++) {
                const leafX = treeX + (Math.random() - 0.5) * 30;
                const leafY = treeY + Math.random() * 40;
                
                if (leafY > 50 && leafY < this.height - 100) {
                    this.gems.push({
                        x: leafX,
                        y: leafY,
                        width: 15,
                        height: 15,
                        color: this.getGemColor(),
                        collected: false,
                        sparkle: 0
                    });
                }
            }
        }
    }
    
    generateCityLightsFeast() {
        // 城市灯光宝石盛宴
        const startX = this.width + 100;
        
        for (let x = 0; x < 400; x += 20) {
            const buildingHeight = 30 + Math.random() * 60;
            const lightY = this.height - 100 - buildingHeight + Math.random() * buildingHeight;
            
            if (lightY > 50 && lightY < this.height - 100) {
                this.gems.push({
                    x: startX + x,
                    y: lightY,
                    width: 15,
                    height: 15,
                    color: this.getGemColor(),
                    collected: false,
                    sparkle: 0
                });
            }
        }
    }
    
    generateAuroraBorealisFeast() {
        // 极光宝石盛宴
        const startX = this.width + 100;
        
        for (let x = 0; x < 400; x += 8) {
            const auroraY = this.height / 3 + Math.sin(x * 0.01) * 30 + Math.sin(x * 0.03) * 20;
            
            if (auroraY > 50 && auroraY < this.height - 100) {
                this.gems.push({
                    x: startX + x,
                    y: auroraY,
                    width: 15,
                    height: 15,
                    color: this.getGemColor(),
                    collected: false,
                    sparkle: 0
                });
            }
        }
    }
    
    // 新增的宝石排列模式
    generateWarmWordsFeast() {
        // 暖心话语宝石盛宴
        const warmMessages = [
            '你是最棒的！',
            '世界因你而美好！',
            '你是独一无二的！',
            '你的存在就是奇迹！',
            '勇敢地做自己！',
            '明天会更好！',
            '你是被爱着的！',
            '你值得拥有幸福！'
        ];
        
        const message = warmMessages[Math.floor(Math.random() * warmMessages.length)];
        const startX = this.width + 150;
        const startY = this.height / 2 - 50;
        const letterSpacing = 18;
        
        // 定义中文字符点阵（简化版）
        const letterPatterns = {
            '你': [[1,1,1,1],[0,0,1,0],[1,1,1,1],[0,0,1,0],[1,1,1,1]],
            '是': [[1,0,0,1],[1,1,1,1],[1,0,0,1],[1,1,1,1],[1,0,0,1]],
            '最': [[1,1,1,1],[0,0,1,0],[1,1,1,1],[0,0,1,0],[1,1,1,1]],
            '棒': [[1,0,0,1],[1,1,1,1],[1,0,0,1],[1,1,1,1],[1,0,0,1]],
            '的': [[1,1,1,1],[0,0,1,0],[1,1,1,1],[0,0,1,0],[1,1,1,1]],
            '世': [[1,0,0,1],[1,1,1,1],[1,0,0,1],[1,1,1,1],[1,0,0,1]],
            '界': [[1,1,1,1],[0,0,1,0],[1,1,1,1],[0,0,1,0],[1,1,1,1]],
            '因': [[1,0,0,1],[1,1,1,1],[1,0,0,1],[1,1,1,1],[1,0,0,1]],
            '而': [[1,1,1,1],[0,0,1,0],[1,1,1,1],[0,0,1,0],[1,1,1,1]],
            '美': [[1,0,0,1],[1,1,1,1],[1,0,0,1],[1,1,1,1],[1,0,0,1]],
            '好': [[1,1,1,1],[0,0,1,0],[1,1,1,1],[0,0,1,0],[1,1,1,1]],
            '独': [[1,0,0,1],[1,1,1,1],[1,0,0,1],[1,1,1,1],[1,0,0,1]],
            '一': [[1,1,1,1],[0,0,1,0],[1,1,1,1],[0,0,1,0],[1,1,1,1]],
            '无': [[1,0,0,1],[1,1,1,1],[1,0,0,1],[1,1,1,1],[1,0,0,1]],
            '二': [[1,1,1,1],[0,0,1,0],[1,1,1,1],[0,0,1,0],[1,1,1,1]],
            '存': [[1,0,0,1],[1,1,1,1],[1,0,0,1],[1,1,1,1],[1,0,0,1]],
            '在': [[1,1,1,1],[0,0,1,0],[1,1,1,1],[0,0,1,0],[1,1,1,1]],
            '就': [[1,0,0,1],[1,1,1,1],[1,0,0,1],[1,1,1,1],[1,0,0,1]],
            '奇': [[1,1,1,1],[0,0,1,0],[1,1,1,1],[0,0,1,0],[1,1,1,1]],
            '迹': [[1,0,0,1],[1,1,1,1],[1,0,0,1],[1,1,1,1],[1,0,0,1]],
            '勇': [[1,1,1,1],[0,0,1,0],[1,1,1,1],[0,0,1,0],[1,1,1,1]],
            '敢': [[1,0,0,1],[1,1,1,1],[1,0,0,1],[1,1,1,1],[1,0,0,1]],
            '地': [[1,1,1,1],[0,0,1,0],[1,1,1,1],[0,0,1,0],[1,1,1,1]],
            '做': [[1,0,0,1],[1,1,1,1],[1,0,0,1],[1,1,1,1],[1,0,0,1]],
            '自': [[1,1,1,1],[0,0,1,0],[1,1,1,1],[0,0,1,0],[1,1,1,1]],
            '己': [[1,0,0,1],[1,1,1,1],[1,0,0,1],[1,1,1,1],[1,0,0,1]],
            '明': [[1,1,1,1],[0,0,1,0],[1,1,1,1],[0,0,1,0],[1,1,1,1]],
            '天': [[1,0,0,1],[1,1,1,1],[1,0,0,1],[1,1,1,1],[1,0,0,1]],
            '会': [[1,1,1,1],[0,0,1,0],[1,1,1,1],[0,0,1,0],[1,1,1,1]],
            '更': [[1,0,0,1],[1,1,1,1],[1,0,0,1],[1,1,1,1],[1,0,0,1]],
            '好': [[1,1,1,1],[0,0,1,0],[1,1,1,1],[0,0,1,0],[1,1,1,1]],
            '被': [[1,0,0,1],[1,1,1,1],[1,0,0,1],[1,1,1,1],[1,0,0,1]],
            '爱': [[1,1,1,1],[0,0,1,0],[1,1,1,1],[0,0,1,0],[1,1,1,1]],
            '着': [[1,0,0,1],[1,1,1,1],[1,0,0,1],[1,1,1,1],[1,0,0,1]],
            '值': [[1,1,1,1],[0,0,1,0],[1,1,1,1],[0,0,1,0],[1,1,1,1]],
            '得': [[1,0,0,1],[1,1,1,1],[1,0,0,1],[1,1,1,1],[1,0,0,1]],
            '拥': [[1,1,1,1],[0,0,1,0],[1,1,1,1],[0,0,1,0],[1,1,1,1]],
            '有': [[1,0,0,1],[1,1,1,1],[1,0,0,1],[1,1,1,1],[1,0,0,1]],
            '幸': [[1,1,1,1],[0,0,1,0],[1,1,1,1],[0,0,1,0],[1,1,1,1]],
            '福': [[1,0,0,1],[1,1,1,1],[1,0,0,1],[1,1,1,1],[1,0,0,1]],
            '！': [[0,1,0],[0,1,0],[0,1,0],[0,0,0],[0,1,0]]
        };
        
        let currentX = startX;
        
        for (let i = 0; i < message.length; i++) {
            const letter = message[i];
            const pattern = letterPatterns[letter];
            
            if (pattern) {
                for (let row = 0; row < pattern.length; row++) {
                    for (let col = 0; col < pattern[row].length; col++) {
                        if (pattern[row][col] === 1) {
                            const gemX = currentX + col * 6;
                            const gemY = startY + row * 6;
                            
                            if (gemY > 50 && gemY < this.height - 100) {
                                this.gems.push({
                                    x: gemX,
                                    y: gemY,
                                    width: 15,
                                    height: 15,
                                    color: '#FFD700', // 金色暖心文字
                                    collected: false,
                                    sparkle: 0
                                });
                            }
                        }
                    }
                }
            }
            
            currentX += letterSpacing;
        }
    }
    
    generateLoveMessageFeast() {
        // 爱心消息宝石盛宴
        const loveMessages = [
            'I LOVE YOU!',
            'YOU ARE LOVED!',
            'YOU MATTER!',
            'YOU ARE WORTHY!',
            'YOU ARE ENOUGH!'
        ];
        
        const message = loveMessages[Math.floor(Math.random() * loveMessages.length)];
        const startX = this.width + 150;
        const startY = this.height / 2 - 50;
        const letterSpacing = 20;
        
        // 定义英文字符点阵
        const letterPatterns = {
            'I': [[1,1,1,1],[0,1,0,0],[0,1,0,0],[0,1,0,0],[1,1,1,1]],
            'L': [[1,0,0,0],[1,0,0,0],[1,0,0,0],[1,0,0,0],[1,1,1,1]],
            'O': [[0,1,1,0],[1,0,0,1],[1,0,0,1],[1,0,0,1],[0,1,1,0]],
            'V': [[1,0,0,1],[1,0,0,1],[1,0,0,1],[0,1,1,0],[0,0,1,0]],
            'E': [[1,1,1,1],[1,0,0,0],[1,1,1,0],[1,0,0,0],[1,1,1,1]],
            'Y': [[1,0,0,1],[1,0,0,1],[0,1,1,0],[0,1,0,0],[0,1,0,0]],
            'U': [[1,0,0,1],[1,0,0,1],[1,0,0,1],[1,0,0,1],[0,1,1,0]],
            'A': [[0,1,1,0],[1,0,0,1],[1,1,1,1],[1,0,0,1],[1,0,0,1]],
            'R': [[1,1,1,0],[1,0,0,1],[1,1,1,0],[1,0,1,0],[1,0,0,1]],
            'M': [[1,0,0,1],[1,1,1,1],[1,0,0,1],[1,0,0,1],[1,0,0,1]],
            'T': [[1,1,1,1],[0,1,0,0],[0,1,0,0],[0,1,0,0],[0,1,0,0]],
            'W': [[1,0,0,1],[1,0,0,1],[1,0,0,1],[1,0,0,1],[1,1,1,1]],
            'H': [[1,0,0,1],[1,0,0,1],[1,1,1,1],[1,0,0,1],[1,0,0,1]],
            'N': [[1,0,0,1],[1,1,0,1],[1,0,1,1],[1,0,0,1],[1,0,0,1]],
            'G': [[0,1,1,1],[1,0,0,0],[1,0,1,1],[1,0,0,1],[0,1,1,0]],
            '!': [[0,1,0],[0,1,0],[0,1,0],[0,0,0],[0,1,0]],
            ' ': [[0,0,0,0],[0,0,0,0],[0,0,0,0],[0,0,0,0],[0,0,0,0]]
        };
        
        let currentX = startX;
        
        for (let i = 0; i < message.length; i++) {
            const letter = message[i];
            const pattern = letterPatterns[letter];
            
            if (pattern) {
                for (let row = 0; row < pattern.length; row++) {
                    for (let col = 0; col < pattern[row].length; col++) {
                        if (pattern[row][col] === 1) {
                            const gemX = currentX + col * 6;
                            const gemY = startY + row * 6;
                            
                            if (gemY > 50 && gemY < this.height - 100) {
                                this.gems.push({
                                    x: gemX,
                                    y: gemY,
                                    width: 15,
                                    height: 15,
                                    color: '#FF69B4', // 粉色爱心消息
                                    collected: false,
                                    sparkle: 0
                                });
                            }
                        }
                    }
                }
            }
            
            currentX += letterSpacing;
        }
    }
    
    generateHopeStarsFeast() {
        // 希望之星宝石盛宴
        const startX = this.width + 100;
        
        for (let i = 0; i < 20; i++) {
            const x = startX + Math.random() * 400;
            const y = 50 + Math.random() * (this.height - 200);
            
            this.gems.push({
                x: x,
                y: y,
                width: 20,
                height: 20,
                color: '#FFD700', // 金色希望之星
                collected: false,
                sparkle: 0
            });
        }
    }
    
    generateDreamCloudsFeast() {
        // 梦想云朵宝石盛宴
        const startX = this.width + 100;
        
        for (let i = 0; i < 6; i++) {
            const cloudX = startX + i * 80;
            const cloudY = this.height / 2 + (Math.random() - 0.5) * 100;
            
            // 每朵云的花瓣
            for (let j = 0; j < 8; j++) {
                const angle = (j / 8) * Math.PI * 2;
                const x = cloudX + Math.cos(angle) * 25;
                const y = cloudY + Math.sin(angle) * 15;
                
                if (y > 50 && y < this.height - 100) {
                    this.gems.push({
                        x: x,
                        y: y,
                        width: 15,
                        height: 15,
                        color: '#87CEEB', // 天蓝色梦想云朵
                        collected: false,
                        sparkle: 0
                    });
                }
            }
        }
    }
    
    generateRainbowBridgeFeast() {
        // 彩虹桥宝石盛宴
        const startX = this.width + 100;
        const colors = ['#FF0000', '#FF7F00', '#FFFF00', '#00FF00', '#0000FF', '#4B0082', '#9400D3'];
        
        for (let x = 0; x < 400; x += 15) {
            const rainbowY = this.height / 2 + Math.sin(x * 0.01) * 30;
            const colorIndex = Math.floor((x / 400) * colors.length) % colors.length;
            
            if (rainbowY > 50 && rainbowY < this.height - 100) {
                this.gems.push({
                    x: startX + x,
                    y: rainbowY,
                    width: 15,
                    height: 15,
                    color: colors[colorIndex],
                    collected: false,
                    sparkle: 0
                });
            }
        }
    }
    
    generateCrystalTowerFeast() {
        // 水晶塔宝石盛宴
        const startX = this.width + 200;
        const baseY = this.height - 150;
        
        for (let y = 0; y < 200; y += 20) {
            const towerX = startX + Math.sin(y * 0.02) * 10;
            const towerY = baseY - y;
            
            if (towerY > 50 && towerY < this.height - 100) {
                this.gems.push({
                    x: towerX,
                    y: towerY,
                    width: 15,
                    height: 15,
                    color: '#00CED1', // 青色水晶
                    collected: false,
                    sparkle: 0
                });
            }
        }
    }
    
    generateMusicNotesFeast() {
        // 音符宝石盛宴
        const startX = this.width + 100;
        
        for (let i = 0; i < 12; i++) {
            const noteX = startX + i * 35;
            const noteY = this.height / 2 + Math.sin(i * 0.5) * 50;
            
            this.gems.push({
                x: noteX,
                y: noteY,
                width: 20,
                height: 20,
                color: '#9370DB', // 紫色音符
                collected: false,
                sparkle: 0
            });
        }
    }
    
    generateAngelWingsFeast() {
        // 天使翅膀宝石盛宴
        const centerX = this.width + 200;
        const centerY = this.height / 2;
        
        // 左翅膀
        for (let i = 0; i < 15; i++) {
            const angle = (i / 15) * Math.PI;
            const x = centerX - 50 + Math.cos(angle) * 30;
            const y = centerY + Math.sin(angle) * 20;
            
            if (y > 50 && y < this.height - 100) {
                this.gems.push({
                    x: x,
                    y: y,
                    width: 15,
                    height: 15,
                    color: '#FFFFFF', // 白色天使翅膀
                    collected: false,
                    sparkle: 0
                });
            }
        }
        
        // 右翅膀
        for (let i = 0; i < 15; i++) {
            const angle = (i / 15) * Math.PI;
            const x = centerX + 50 + Math.cos(angle) * 30;
            const y = centerY + Math.sin(angle) * 20;
            
            if (y > 50 && y < this.height - 100) {
                this.gems.push({
                    x: x,
                    y: y,
                    width: 15,
                    height: 15,
                    color: '#FFFFFF', // 白色天使翅膀
                    collected: false,
                    sparkle: 0
                });
            }
        }
    }
    
    // 治愈冲刺道具系统
    generateHealingBooster() {
        const booster = {
            x: this.width + Math.random() * 200 + 100,
            y: this.height / 2 + (Math.random() - 0.5) * 100,
            width: 25,
            height: 25,
            color: '#00FF00',
            collected: false,
            pulse: 0
        };
        this.healingBoosters.push(booster);
    }
    
    drawHealingBoosters() {
        this.healingBoosters.forEach(booster => {
            // 脉冲动画
            booster.pulse += 0.1;
            const pulseScale = 1 + Math.sin(booster.pulse) * 0.2;
            
            // 绘制治愈冲刺道具
            this.ctx.save();
            this.ctx.translate(booster.x + booster.width/2, booster.y + booster.height/2);
            this.ctx.scale(pulseScale, pulseScale);
            
            // 绘制十字形治愈符号
            this.ctx.fillStyle = booster.color;
            this.ctx.fillRect(-booster.width/2, -2, booster.width, 4);
            this.ctx.fillRect(-2, -booster.height/2, 4, booster.height);
            
            // 绘制外圈光环
            this.ctx.strokeStyle = '#FFFFFF';
            this.ctx.lineWidth = 2;
            this.ctx.beginPath();
            this.ctx.arc(0, 0, booster.width/2 + 5, 0, Math.PI * 2);
            this.ctx.stroke();
            
            this.ctx.restore();
        });
    }
    
    checkHealingBoosterCollisions() {
        // 使用for循环避免死循环
        for (let i = this.healingBoosters.length - 1; i >= 0; i--) {
            const booster = this.healingBoosters[i];
            if (!booster.collected && this.checkCollision(this.dimoo, booster)) {
                booster.collected = true;
                this.healingBoosters.splice(i, 1);
                this.startHealingBooster();
                console.log('💊 获得治愈冲刺道具！3秒内速度提升2倍！');
            }
        }
    }
    
    startHealingBooster() {
        this.isHealingBoosterActive = true;
        this.healingBoosterStartTime = Date.now();
        
        // 保存原始速度
        this.originalSpeedForHealingBooster = this.speedMultiplier;
        
        // 应用治愈冲刺速度提升
        this.speedMultiplier *= this.healingBoosterSpeedMultiplier;
        this.speed = this.baseSpeed * this.speedMultiplier;
        
        console.log('💊 治愈冲刺激活！当前速度倍数：', this.speedMultiplier);
    }
    
    stopHealingBooster() {
        this.isHealingBoosterActive = false;
        
        // 恢复原始速度
        if (this.originalSpeedForHealingBooster) {
            this.speedMultiplier = this.originalSpeedForHealingBooster;
            this.speed = this.baseSpeed * this.speedMultiplier;
        }
        
        console.log('💊 治愈冲刺结束！速度恢复正常');
    }
    
    // 爱心道具系统
    generateHeartItem() {
        const heart = {
            x: this.width + Math.random() * 200 + 100,
            y: this.height / 2 + (Math.random() - 0.5) * 100,
            width: 30,
            height: 30,
            color: '#FF69B4',
            collected: false,
            pulse: 0
        };
        this.heartItems.push(heart);
    }
    
    // 得分倍数道具系统
    generateScoreMultiplier() {
        // 生成得分倍数道具 - 随机选择2倍或3倍
        const multiplierTypes = [
            { value: 2, name: '得分翻倍', color: '#FFD700', symbol: '2x' },
            { value: 3, name: '得分三倍', color: '#FF6347', symbol: '3x' }
        ];
        
        const selectedType = multiplierTypes[Math.floor(Math.random() * multiplierTypes.length)];
        const multiplier = {
            x: this.width + Math.random() * 200 + 100,
            y: this.height / 2 + (Math.random() - 0.5) * 100,
            width: 30,
            height: 30,
            color: selectedType.color,
            value: selectedType.value,
            name: selectedType.name,
            symbol: selectedType.symbol,
            collected: false,
            pulse: 0
        };
        this.scoreMultipliers.push(multiplier);
    }
    
    drawHeartItems() {
        this.heartItems.forEach(heart => {
            // 脉冲动画
            heart.pulse += 0.1;
            const pulseScale = 1 + Math.sin(heart.pulse) * 0.2;
            
            // 绘制爱心道具 - 使用与生命图标一致的绘制方法
            this.ctx.save();
            this.ctx.translate(heart.x + heart.width/2, heart.y + heart.height/2);
            this.ctx.scale(pulseScale, pulseScale);
            
            // 使用与drawHeart函数一致的样式和绘制方法
            this.ctx.fillStyle = '#FF6B6B';
            this.ctx.strokeStyle = '#FF4757';
            this.ctx.lineWidth = 2;
            
            // 绘制爱心形状 - 与生命图标完全一致
            this.ctx.beginPath();
            this.ctx.moveTo(0, heart.height * 0.3);
            
            // 左半边
            this.ctx.bezierCurveTo(
                0, 0, 
                -heart.width * 0.5, 0, 
                -heart.width * 0.5, heart.height * 0.3
            );
            this.ctx.bezierCurveTo(
                -heart.width * 0.5, heart.height * 0.6, 
                0, heart.height * 0.8, 
                0, heart.height * 0.8
            );
            
            // 右半边
            this.ctx.bezierCurveTo(
                0, heart.height * 0.8, 
                heart.width * 0.5, heart.height * 0.6, 
                heart.width * 0.5, heart.height * 0.3
            );
            this.ctx.bezierCurveTo(
                heart.width * 0.5, 0, 
                0, 0, 
                0, heart.height * 0.3
            );
            
            this.ctx.fill();
            this.ctx.stroke();
            
            this.ctx.restore();
        });
    }
    
    checkHeartItemCollisions() {
        // 使用for循环避免死循环
        for (let i = this.heartItems.length - 1; i >= 0; i--) {
            const heart = this.heartItems[i];
            if (!heart.collected && this.checkCollision(this.dimoo, heart)) {
                heart.collected = true;
                this.heartItems.splice(i, 1);
                this.lives = Math.min(this.lives + 1, 99);
                
                // 如果在凋零阶段获得爱心道具，触发重生动画
                if (this.isEvolutionMode && this.evolutionType === 'death') {
                    console.log('💖 凋零阶段获得爱心道具！触发重生动画！');
                    this.stopEvolutionMode(); // 停止凋零动画
                    this.startEvolutionMode('rebirth'); // 启动重生动画
                } else {
                    console.log('💖 获得爱心道具！生命 +1');
                }
            }
        }
    }
    
    drawScoreMultipliers() {
        this.scoreMultipliers.forEach(multiplier => {
            // 脉冲动画
            multiplier.pulse += 0.1;
            const pulseScale = 1 + Math.sin(multiplier.pulse) * 0.2;
            
            // 绘制得分倍数道具
            this.ctx.save();
            this.ctx.translate(multiplier.x + multiplier.width/2, multiplier.y + multiplier.height/2);
            this.ctx.scale(pulseScale, pulseScale);
            
            // 绘制圆形背景
            this.ctx.fillStyle = multiplier.color;
            this.ctx.strokeStyle = '#FFFFFF';
            this.ctx.lineWidth = 2;
            
            this.ctx.beginPath();
            this.ctx.arc(0, 0, multiplier.width/2, 0, Math.PI * 2);
            this.ctx.fill();
            this.ctx.stroke();
            
            // 绘制倍数符号
            this.ctx.fillStyle = '#FFFFFF';
            this.ctx.font = 'bold 16px Arial';
            this.ctx.textAlign = 'center';
            this.ctx.textBaseline = 'middle';
            this.ctx.fillText(multiplier.symbol, 0, 0);
            
            this.ctx.restore();
        });
    }
    
    checkScoreMultiplierCollisions() {
        // 使用for循环避免死循环
        for (let i = this.scoreMultipliers.length - 1; i >= 0; i--) {
            const multiplier = this.scoreMultipliers[i];
            if (!multiplier.collected && this.checkCollision(this.dimoo, multiplier)) {
                multiplier.collected = true;
                this.scoreMultipliers.splice(i, 1);
                
                // 激活得分倍数效果
                this.startScoreMultiplier(multiplier.value);
                console.log(`🎯 获得${multiplier.name}道具！得分倍数：${multiplier.value}x`);
            }
        }
    }
    
    startScoreMultiplier(value) {
        this.isScoreMultiplierActive = true;
        this.scoreMultiplierValue = value;
        this.scoreMultiplierStartTime = Date.now();
        console.log(`🎯 得分倍数激活！倍数：${value}x，持续5秒！`);
    }
    
    stopScoreMultiplier() {
        this.isScoreMultiplierActive = false;
        this.scoreMultiplierValue = 1;
        console.log('🎯 得分倍数效果结束！');
    }
    
    // 成功治愈系统 - 多种通关条件
    checkVictoryCondition() {
        if (this.isVictoryMode) return; // 已经在胜利模式中
        
        // 条件1：生命达到99条（治愈成功）
        if (this.lives >= 99) {
            this.startVictoryMode('life');
            return;
        }
        
        // 条件2：距离达到100万米（坚持到底）
        if (this.distance >= 1000000) {
            this.startVictoryMode('distance');
            return;
        }
        
        // 条件3：宝石收集达到10000颗（希望满满）
        if (this.gemCount >= 10000) {
            this.startVictoryMode('gems');
            return;
        }
        
        // 条件4：连续存活时间达到30分钟（坚韧不拔）
        const survivalTime = Date.now() - this.gameStartTime;
        if (survivalTime >= 30 * 60 * 1000) { // 30分钟
            this.startVictoryMode('survival');
            return;
        }
        
        // 条件5：得分达到5251314（分数成就）
        if (this.score >= 5251314) {
            this.startVictoryMode('score');
            return;
        }
    }
    
    startVictoryMode(type = 'life') {
        this.isVictoryMode = true;
        this.victoryType = type;
        this.victoryStartTime = Date.now();
        this.victoryDuration = 25000; // 25秒胜利时间（增加10秒宝石盛宴）
        this.victoryPhase = 0; // 胜利阶段：0=标题，1=副标题，2=温暖话语，3=LIFE文字
        this.victoryPhaseStartTime = Date.now();
        this.victoryPhaseDuration = 3000; // 每个阶段3秒
        
        // 设置胜利状态下的特殊参数
        this.speedMultiplier = 1; // 速度降低为1
        this.isVictoryFeastActive = true; // 激活胜利宝石盛宴
        this.victoryFeastStartTime = Date.now();
        this.victoryFeastDuration = 10000; // 10秒宝石盛宴
        
        // 根据胜利类型显示不同的消息
        const victoryMessages = {
            'life': '🎉 恭喜！小恐龙战胜了抑郁症！在世界中重新找到活下去的勇气！',
            'distance': '🏃 恭喜！小恐龙坚持到底！在舆论压力中依然前行！',
            'gems': '💎 恭喜！小恐龙收集了满满的爱与希望！世界依然温暖！',
            'survival': '⏰ 恭喜！小恐龙坚韧不拔！在纷扰中保持内心的平静！',
            'score': '🏆 恭喜！小恐龙获得巨大成就！在逆境中绽放光芒！'
        };
        
        console.log(victoryMessages[type] + ' 开始10秒宝石盛宴！');
    }
    
    generateWarmMessageGems(x, y) {
        // 生成温暖话语宝石文字："你要相信 你值得被爱 你值得被善待"
        const messages = [
            '你要相信',
            '你值得被爱', 
            '你值得被善待'
        ];
        
        const startY = y;
        const lineHeight = 60;
        
        messages.forEach((message, lineIndex) => {
            const currentY = startY + lineIndex * lineHeight;
            const startX = x - (message.length * 25) / 2;
            
            // 定义中文字符点阵（简化版）
            const letterPatterns = {
                '你': [[1,1,1,1],[0,0,1,0],[1,1,1,1],[0,0,1,0],[1,1,1,1]],
                '要': [[1,0,0,1],[1,1,1,1],[1,0,0,1],[1,1,1,1],[1,0,0,1]],
                '相': [[1,1,1,1],[0,0,1,0],[1,1,1,1],[0,0,1,0],[1,1,1,1]],
                '信': [[1,0,0,1],[1,1,1,1],[1,0,0,1],[1,1,1,1],[1,0,0,1]],
                '值': [[1,1,1,1],[0,0,1,0],[1,1,1,1],[0,0,1,0],[1,1,1,1]],
                '得': [[1,0,0,1],[1,1,1,1],[1,0,0,1],[1,1,1,1],[1,0,0,1]],
                '被': [[1,1,1,1],[0,0,1,0],[1,1,1,1],[0,0,1,0],[1,1,1,1]],
                '爱': [[1,0,0,1],[1,1,1,1],[1,0,0,1],[1,1,1,1],[1,0,0,1]],
                '善': [[1,1,1,1],[0,0,1,0],[1,1,1,1],[0,0,1,0],[1,1,1,1]],
                '待': [[1,0,0,1],[1,1,1,1],[1,0,0,1],[1,1,1,1],[1,0,0,1]]
            };
            
            message.split('').forEach((char, charIndex) => {
                const pattern = letterPatterns[char] || letterPatterns['你'];
                const charX = startX + charIndex * 25;
                
                pattern.forEach((row, rowIndex) => {
                    row.forEach((pixel, colIndex) => {
                        if (pixel === 1) {
                            this.victoryGems.push({
                                x: charX + colIndex * 4,
                                y: currentY + rowIndex * 4,
                                width: 3,
                                height: 3,
                                color: '#FF69B4',
                                collected: false,
                                sparkle: Math.random() * Math.PI * 2
                            });
                        }
                    });
                });
            });
        });
    }
    
    generateVictorySubtitle() {
        // 生成副标题宝石文字
        const subtitle = '小恐龙重获新生';
        const startX = this.width / 2 - (subtitle.length * 20) / 2;
        const startY = this.height / 2 + 20;
        
        // 定义中文字符点阵（简化版）
        const letterPatterns = {
            '小': [[1,1,1,1],[0,0,1,0],[1,1,1,1],[0,0,1,0],[1,1,1,1]],
            '恐': [[1,0,0,1],[1,1,1,1],[1,0,0,1],[1,1,1,1],[1,0,0,1]],
            '龙': [[1,1,1,1],[0,0,1,0],[1,1,1,1],[0,0,1,0],[1,1,1,1]],
            '重': [[1,0,0,1],[1,1,1,1],[1,0,0,1],[1,1,1,1],[1,0,0,1]],
            '获': [[1,1,1,1],[0,0,1,0],[1,1,1,1],[0,0,1,0],[1,1,1,1]],
            '新': [[1,0,0,1],[1,1,1,1],[1,0,0,1],[1,1,1,1],[1,0,0,1]],
            '生': [[1,1,1,1],[0,0,1,0],[1,1,1,1],[0,0,1,0],[1,1,1,1]],
            '获': [[1,0,0,1],[1,1,1,1],[1,0,0,1],[1,1,1,1],[1,0,0,1]],
            '得': [[1,1,1,1],[0,0,1,0],[1,1,1,1],[0,0,1,0],[1,1,1,1]],
            '巨': [[1,0,0,1],[1,1,1,1],[1,0,0,1],[1,1,1,1],[1,0,0,1]],
            '大': [[1,1,1,1],[0,0,1,0],[1,1,1,1],[0,0,1,0],[1,1,1,1]],
            '成': [[1,0,0,1],[1,1,1,1],[1,0,0,1],[1,1,1,1],[1,0,0,1]],
            '就': [[1,1,1,1],[0,0,1,0],[1,1,1,1],[0,0,1,0],[1,1,1,1]]
        };
        
        subtitle.split('').forEach((char, charIndex) => {
            const pattern = letterPatterns[char] || letterPatterns['小'];
            const charX = startX + charIndex * 20;
            
            pattern.forEach((row, rowIndex) => {
                row.forEach((pixel, colIndex) => {
                    if (pixel === 1) {
                        this.victoryGems.push({
                            x: charX + colIndex * 3,
                            y: startY + rowIndex * 3,
                            width: 2,
                            height: 2,
                            color: '#FF69B4',
                            collected: false,
                            sparkle: Math.random() * Math.PI * 2
                        });
                    }
                });
            });
        });
    }
    
    generateVictoryWarmMessageFeast() {
        // 胜利状态下的暖心话语宝石盛宴
        const warmMessages = [
            '你是最棒的',
            '未来可期',
            '世界充满爱',
            '重获新生',
            '治愈成功',
            '你是独一无二的',
            '生命的意义在于爱与希望',
            '你值得被爱',
            '你值得被善待',
            '你要相信',
            '美好生活',
            '勇敢前行',
            '温柔灵魂',
            '光明未来',
            '温暖拥抱',
            '治愈之光',
            '希望永存',
            '爱能战胜一切',
            '生命是美丽的',
            '你是有价值的',
            '梦想远大',
            '闪耀光芒',
            '和平与爱',
            '治愈力量',
            '生命目标',
            '永恒希望'
        ];
        
        const selectedMessage = warmMessages[Math.floor(Math.random() * warmMessages.length)];
        const startX = Math.random() * (this.width - 400) + 200;
        const startY = Math.random() * (this.height - 200) + 100;
        
        this.generateChineseTextFeast(selectedMessage, startX, startY, '#FFD700');
        console.log(`💖 胜利宝石盛宴：${selectedMessage}`);
    }
    
    generateLifeGems(x, y) {
        // 生成LIFE宝石文字
        const lifeText = 'LIFE';
        const startX = x - (lifeText.length * 30) / 2;
        
        // 定义英文字母点阵
        const letterPatterns = {
            'L': [[1,0,0,0],[1,0,0,0],[1,0,0,0],[1,0,0,0],[1,1,1,1]],
            'I': [[1,1,1,1],[0,1,0,0],[0,1,0,0],[0,1,0,0],[1,1,1,1]],
            'F': [[1,1,1,1],[1,0,0,0],[1,1,1,0],[1,0,0,0],[1,0,0,0]],
            'E': [[1,1,1,1],[1,0,0,0],[1,1,1,0],[1,0,0,0],[1,1,1,1]]
        };
        
        lifeText.split('').forEach((char, charIndex) => {
            const pattern = letterPatterns[char];
            const charX = startX + charIndex * 30;
            
            pattern.forEach((row, rowIndex) => {
                row.forEach((pixel, colIndex) => {
                    if (pixel === 1) {
                        this.victoryGems.push({
                            x: charX + colIndex * 5,
                            y: y + rowIndex * 5,
                            width: 4,
                            height: 4,
                            color: '#FFD700',
                            collected: false,
                            sparkle: Math.random() * Math.PI * 2
                        });
                    }
                });
            });
        });
    }
    
    // 新增暖心文字生成函数
    generateHealingWordsFeast() {
        this.generateChineseTextFeast('治愈心灵', this.width + 200, this.height / 2, '#FF69B4');
    }
    
    generateLifeMeaningFeast() {
        this.generateChineseTextFeast('生命意义', this.width + 200, this.height / 2, '#FFD700');
    }
    
    generateFutureHopeFeast() {
        this.generateChineseTextFeast('未来希望', this.width + 200, this.height / 2, '#87CEEB');
    }
    
    generateInnerStrengthFeast() {
        this.generateChineseTextFeast('内心力量', this.width + 200, this.height / 2, '#FF6347');
    }
    
    generateLoveYourselfFeast() {
        this.generateChineseTextFeast('爱你自己', this.width + 200, this.height / 2, '#FF69B4');
    }
    
    generateNeverGiveUpFeast() {
        this.generateChineseTextFeast('永不放弃', this.width + 200, this.height / 2, '#32CD32');
    }
    
    generateBeautifulLifeFeast() {
        this.generateChineseTextFeast('美好生活', this.width + 200, this.height / 2, '#FFD700');
    }
    
    generatePeacefulMindFeast() {
        this.generateChineseTextFeast('平静心灵', this.width + 200, this.height / 2, '#87CEEB');
    }
    
    generateCourageHeartFeast() {
        this.generateChineseTextFeast('勇敢的心', this.width + 200, this.height / 2, '#FF6347');
    }
    
    generateGentleSoulFeast() {
        this.generateChineseTextFeast('温柔灵魂', this.width + 200, this.height / 2, '#FF69B4');
    }
    
    generateBrightFutureFeast() {
        this.generateChineseTextFeast('光明未来', this.width + 200, this.height / 2, '#FFD700');
    }
    
    generateWarmEmbraceFeast() {
        this.generateChineseTextFeast('温暖拥抱', this.width + 200, this.height / 2, '#FF69B4');
    }
    
    generateHealingLightFeast() {
        this.generateChineseTextFeast('治愈之光', this.width + 200, this.height / 2, '#FFD700');
    }
    
    generateHopeSpringsFeast() {
        this.generateChineseTextFeast('希望之泉', this.width + 200, this.height / 2, '#87CEEB');
    }
    
    generateLoveConquersFeast() {
        this.generateChineseTextFeast('爱能战胜', this.width + 200, this.height / 2, '#FF69B4');
    }
    
    generateLifeIsBeautifulFeast() {
        this.generateChineseTextFeast('生命美好', this.width + 200, this.height / 2, '#FFD700');
    }
    
    generateYouAreWorthyFeast() {
        this.generateChineseTextFeast('你值得爱', this.width + 200, this.height / 2, '#FF69B4');
    }
    
    generateDreamBigFeast() {
        this.generateChineseTextFeast('梦想远大', this.width + 200, this.height / 2, '#87CEEB');
    }
    
    generateShineBrightFeast() {
        this.generateChineseTextFeast('闪耀光芒', this.width + 200, this.height / 2, '#FFD700');
    }
    
    generatePeaceLoveFeast() {
        this.generateChineseTextFeast('和平与爱', this.width + 200, this.height / 2, '#FF69B4');
    }
    
    generateHealingPowerFeast() {
        this.generateChineseTextFeast('治愈力量', this.width + 200, this.height / 2, '#FFD700');
    }
    
    generateLifeGoalsFeast() {
        this.generateChineseTextFeast('人生目标', this.width + 200, this.height / 2, '#32CD32');
    }
    
    generateHopeEternalFeast() {
        this.generateChineseTextFeast('永恒希望', this.width + 200, this.height / 2, '#87CEEB');
    }
    
    // 删除triggerWarmMessage函数
    
    generateChineseTextFeast(text, startX, startY, color) {
        // 通用中文文字生成函数
        const startXPos = startX;
        const startYPos = startY;
        const letterSpacing = 25;
        
        // 定义中文字符点阵（简化版）
        const letterPatterns = {
            '治': [[1,1,1,1],[0,0,1,0],[1,1,1,1],[0,0,1,0],[1,1,1,1]],
            '愈': [[1,0,0,1],[1,1,1,1],[1,0,0,1],[1,1,1,1],[1,0,0,1]],
            '心': [[1,1,1,1],[0,0,1,0],[1,1,1,1],[0,0,1,0],[1,1,1,1]],
            '灵': [[1,0,0,1],[1,1,1,1],[1,0,0,1],[1,1,1,1],[1,0,0,1]],
            '生': [[1,1,1,1],[0,0,1,0],[1,1,1,1],[0,0,1,0],[1,1,1,1]],
            '命': [[1,0,0,1],[1,1,1,1],[1,0,0,1],[1,1,1,1],[1,0,0,1]],
            '意': [[1,1,1,1],[0,0,1,0],[1,1,1,1],[0,0,1,0],[1,1,1,1]],
            '义': [[1,0,0,1],[1,1,1,1],[1,0,0,1],[1,1,1,1],[1,0,0,1]],
            '未': [[1,1,1,1],[0,0,1,0],[1,1,1,1],[0,0,1,0],[1,1,1,1]],
            '来': [[1,0,0,1],[1,1,1,1],[1,0,0,1],[1,1,1,1],[1,0,0,1]],
            '希': [[1,1,1,1],[0,0,1,0],[1,1,1,1],[0,0,1,0],[1,1,1,1]],
            '望': [[1,0,0,1],[1,1,1,1],[1,0,0,1],[1,1,1,1],[1,0,0,1]],
            '内': [[1,1,1,1],[0,0,1,0],[1,1,1,1],[0,0,1,0],[1,1,1,1]],
            '力': [[1,0,0,1],[1,1,1,1],[1,0,0,1],[1,1,1,1],[1,0,0,1]],
            '量': [[1,1,1,1],[0,0,1,0],[1,1,1,1],[0,0,1,0],[1,1,1,1]],
            '爱': [[1,0,0,1],[1,1,1,1],[1,0,0,1],[1,1,1,1],[1,0,0,1]],
            '你': [[1,1,1,1],[0,0,1,0],[1,1,1,1],[0,0,1,0],[1,1,1,1]],
            '自': [[1,0,0,1],[1,1,1,1],[1,0,0,1],[1,1,1,1],[1,0,0,1]],
            '己': [[1,1,1,1],[0,0,1,0],[1,1,1,1],[0,0,1,0],[1,1,1,1]],
            '永': [[1,0,0,1],[1,1,1,1],[1,0,0,1],[1,1,1,1],[1,0,0,1]],
            '不': [[1,1,1,1],[0,0,1,0],[1,1,1,1],[0,0,1,0],[1,1,1,1]],
            '放': [[1,0,0,1],[1,1,1,1],[1,0,0,1],[1,1,1,1],[1,0,0,1]],
            '弃': [[1,1,1,1],[0,0,1,0],[1,1,1,1],[0,0,1,0],[1,1,1,1]],
            '美': [[1,0,0,1],[1,1,1,1],[1,0,0,1],[1,1,1,1],[1,0,0,1]],
            '好': [[1,1,1,1],[0,0,1,0],[1,1,1,1],[0,0,1,0],[1,1,1,1]],
            '生': [[1,0,0,1],[1,1,1,1],[1,0,0,1],[1,1,1,1],[1,0,0,1]],
            '活': [[1,1,1,1],[0,0,1,0],[1,1,1,1],[0,0,1,0],[1,1,1,1]],
            '平': [[1,0,0,1],[1,1,1,1],[1,0,0,1],[1,1,1,1],[1,0,0,1]],
            '静': [[1,1,1,1],[0,0,1,0],[1,1,1,1],[0,0,1,0],[1,1,1,1]],
            '勇': [[1,0,0,1],[1,1,1,1],[1,0,0,1],[1,1,1,1],[1,0,0,1]],
            '敢': [[1,1,1,1],[0,0,1,0],[1,1,1,1],[0,0,1,0],[1,1,1,1]],
            '的': [[1,0,0,1],[1,1,1,1],[1,0,0,1],[1,1,1,1],[1,0,0,1]],
            '温': [[1,1,1,1],[0,0,1,0],[1,1,1,1],[0,0,1,0],[1,1,1,1]],
            '柔': [[1,0,0,1],[1,1,1,1],[1,0,0,1],[1,1,1,1],[1,0,0,1]],
            '灵': [[1,1,1,1],[0,0,1,0],[1,1,1,1],[0,0,1,0],[1,1,1,1]],
            '魂': [[1,0,0,1],[1,1,1,1],[1,0,0,1],[1,1,1,1],[1,0,0,1]],
            '光': [[1,1,1,1],[0,0,1,0],[1,1,1,1],[0,0,1,0],[1,1,1,1]],
            '明': [[1,0,0,1],[1,1,1,1],[1,0,0,1],[1,1,1,1],[1,0,0,1]],
            '未': [[1,1,1,1],[0,0,1,0],[1,1,1,1],[0,0,1,0],[1,1,1,1]],
            '来': [[1,0,0,1],[1,1,1,1],[1,0,0,1],[1,1,1,1],[1,0,0,1]],
            '拥': [[1,1,1,1],[0,0,1,0],[1,1,1,1],[0,0,1,0],[1,1,1,1]],
            '抱': [[1,0,0,1],[1,1,1,1],[1,0,0,1],[1,1,1,1],[1,0,0,1]],
            '之': [[1,1,1,1],[0,0,1,0],[1,1,1,1],[0,0,1,0],[1,1,1,1]],
            '光': [[1,0,0,1],[1,1,1,1],[1,0,0,1],[1,1,1,1],[1,0,0,1]],
            '泉': [[1,1,1,1],[0,0,1,0],[1,1,1,1],[0,0,1,0],[1,1,1,1]],
            '能': [[1,0,0,1],[1,1,1,1],[1,0,0,1],[1,1,1,1],[1,0,0,1]],
            '战': [[1,1,1,1],[0,0,1,0],[1,1,1,1],[0,0,1,0],[1,1,1,1]],
            '胜': [[1,0,0,1],[1,1,1,1],[1,0,0,1],[1,1,1,1],[1,0,0,1]],
            '美': [[1,1,1,1],[0,0,1,0],[1,1,1,1],[0,0,1,0],[1,1,1,1]],
            '好': [[1,0,0,1],[1,1,1,1],[1,0,0,1],[1,1,1,1],[1,0,0,1]],
            '值': [[1,1,1,1],[0,0,1,0],[1,1,1,1],[0,0,1,0],[1,1,1,1]],
            '得': [[1,0,0,1],[1,1,1,1],[1,0,0,1],[1,1,1,1],[1,0,0,1]],
            '爱': [[1,1,1,1],[0,0,1,0],[1,1,1,1],[0,0,1,0],[1,1,1,1]],
            '梦': [[1,0,0,1],[1,1,1,1],[1,0,0,1],[1,1,1,1],[1,0,0,1]],
            '想': [[1,1,1,1],[0,0,1,0],[1,1,1,1],[0,0,1,0],[1,1,1,1]],
            '远': [[1,0,0,1],[1,1,1,1],[1,0,0,1],[1,1,1,1],[1,0,0,1]],
            '大': [[1,1,1,1],[0,0,1,0],[1,1,1,1],[0,0,1,0],[1,1,1,1]],
            '闪': [[1,0,0,1],[1,1,1,1],[1,0,0,1],[1,1,1,1],[1,0,0,1]],
            '耀': [[1,1,1,1],[0,0,1,0],[1,1,1,1],[0,0,1,0],[1,1,1,1]],
            '芒': [[1,0,0,1],[1,1,1,1],[1,0,0,1],[1,1,1,1],[1,0,0,1]],
            '和': [[1,1,1,1],[0,0,1,0],[1,1,1,1],[0,0,1,0],[1,1,1,1]],
            '平': [[1,0,0,1],[1,1,1,1],[1,0,0,1],[1,1,1,1],[1,0,0,1]],
            '与': [[1,1,1,1],[0,0,1,0],[1,1,1,1],[0,0,1,0],[1,1,1,1]],
            '力': [[1,0,0,1],[1,1,1,1],[1,0,0,1],[1,1,1,1],[1,0,0,1]],
            '人': [[1,1,1,1],[0,0,1,0],[1,1,1,1],[0,0,1,0],[1,1,1,1]],
            '目': [[1,0,0,1],[1,1,1,1],[1,0,0,1],[1,1,1,1],[1,0,0,1]],
            '标': [[1,1,1,1],[0,0,1,0],[1,1,1,1],[0,0,1,0],[1,1,1,1]],
            '永': [[1,0,0,1],[1,1,1,1],[1,0,0,1],[1,1,1,1],[1,0,0,1]],
            '恒': [[1,1,1,1],[0,0,1,0],[1,1,1,1],[0,0,1,0],[1,1,1,1]]
        };
        
        text.split('').forEach((char, charIndex) => {
            const pattern = letterPatterns[char] || letterPatterns['爱'];
            const charX = startXPos + charIndex * letterSpacing;
            
            pattern.forEach((row, rowIndex) => {
                row.forEach((pixel, colIndex) => {
                    if (pixel === 1) {
                        this.gems.push({
                            x: charX + colIndex * 4,
                            y: startYPos + rowIndex * 4,
                            width: 3,
                            height: 3,
                            color: color,
                            value: 1,
                            name: '暖心宝石',
                            collected: false,
                            sparkle: Math.random() * Math.PI * 2
                        });
                    }
                });
            });
        });
    }
    
    generateVictoryGems(type = 'all') {
        // 清空之前的胜利宝石
        this.victoryGems = [];
        
        if (type === 'subtitle') {
            // 生成副标题宝石文字
            this.generateVictorySubtitle();
        } else if (type === 'warm') {
            // 生成温暖话语宝石文字
            this.generateWarmMessageGems(this.width / 2, this.height / 2 + 50);
        } else if (type === 'life') {
            // 生成LIFE宝石文字
            this.generateLifeGems(this.width / 2, this.height / 2 + 150);
        } else {
            // 生成所有胜利宝石图案
            const centerX = this.width / 2;
            const centerY = this.height / 2;
            
            // 生成爱心图案
            this.generateVictoryHeart(centerX - 150, centerY);
            
            // 生成太阳图案
            this.generateVictorySun(centerX + 150, centerY);
            
            // 生成治愈文字
            this.generateVictoryText(centerX, centerY + 100);
            
            // 生成温暖话语宝石文字
            this.generateWarmMessageGems(centerX, centerY - 100);
            
            // 生成LIFE宝石文字
            this.generateLifeGems(centerX, centerY + 200);
        }
    }
    
    generateVictoryHeart(x, y) {
        // 爱心形状的宝石排列
        for (let angle = 0; angle < Math.PI * 2; angle += 0.1) {
            const r = 30 + Math.sin(angle) * 20;
            const heartX = x + Math.cos(angle) * r;
            const heartY = y + Math.sin(angle) * r;
            
            this.victoryGems.push({
                x: heartX,
                y: heartY,
                width: 20,
                height: 20,
                color: '#FF69B4',
                collected: false,
                sparkle: 0
            });
        }
    }
    
    generateVictorySun(x, y) {
        // 动态太阳形状的宝石排列
        const time = Date.now() * 0.001;
        const pulseRadius = 40 + Math.sin(time * 3) * 5; // 脉冲半径
        
        for (let angle = 0; angle < Math.PI * 2; angle += 0.15) {
            const r = pulseRadius + Math.sin(angle * 3 + time * 2) * 3; // 波浪效果
            const sunX = x + Math.cos(angle) * r;
            const sunY = y + Math.sin(angle) * r;
            
            this.victoryGems.push({
                x: sunX,
                y: sunY,
                width: 18,
                height: 18,
                color: '#FFD700',
                collected: false,
                sparkle: Math.random() * Math.PI * 2,
                isSunGem: true,
                originalX: x,
                originalY: y,
                angle: angle,
                time: time
            });
        }
        
        // 动态太阳光芒（旋转）
        for (let i = 0; i < 12; i++) {
            const angle = (i / 12) * Math.PI * 2 + time * 0.5; // 旋转光芒
            const rayLength = 65 + Math.sin(time * 4 + i) * 10; // 脉冲长度
            const rayX = x + Math.cos(angle) * rayLength;
            const rayY = y + Math.sin(angle) * rayLength;
            
            this.victoryGems.push({
                x: rayX,
                y: rayY,
                width: 12,
                height: 12,
                color: '#FFA500',
                collected: false,
                sparkle: Math.random() * Math.PI * 2,
                isSunRay: true,
                originalX: x,
                originalY: y,
                angle: angle,
                time: time
            });
        }
        
        // 太阳中心光晕
        for (let i = 0; i < 6; i++) {
            const angle = (i / 6) * Math.PI * 2 + time * 0.3;
            const innerRadius = 15 + Math.sin(time * 5) * 3;
            const innerX = x + Math.cos(angle) * innerRadius;
            const innerY = y + Math.sin(angle) * innerRadius;
            
            this.victoryGems.push({
                x: innerX,
                y: innerY,
                width: 10,
                height: 10,
                color: '#FFFF00',
                collected: false,
                sparkle: Math.random() * Math.PI * 2,
                isSunCore: true,
                originalX: x,
                originalY: y,
                angle: angle,
                time: time
            });
        }
    }
    
    generateVictoryText(x, y) {
        const victoryMessages = [
            '治愈成功！',
            '重获新生！',
            '世界充满爱！',
            '你是最棒的！',
            '未来可期！'
        ];
        
        const message = victoryMessages[Math.floor(Math.random() * victoryMessages.length)];
        const startX = x - 100;
        const startY = y;
        const letterSpacing = 20;
        
        // 定义中文字符点阵（简化版）
        const letterPatterns = {
            '治': [[1,1,1,1],[0,0,1,0],[1,1,1,1],[0,0,1,0],[1,1,1,1]],
            '愈': [[1,0,0,1],[1,1,1,1],[1,0,0,1],[1,1,1,1],[1,0,0,1]],
            '成': [[1,1,1,1],[0,0,1,0],[1,1,1,1],[0,0,1,0],[1,1,1,1]],
            '功': [[1,0,0,1],[1,1,1,1],[1,0,0,1],[1,1,1,1],[1,0,0,1]],
            '重': [[1,1,1,1],[0,0,1,0],[1,1,1,1],[0,0,1,0],[1,1,1,1]],
            '获': [[1,0,0,1],[1,1,1,1],[1,0,0,1],[1,1,1,1],[1,0,0,1]],
            '新': [[1,1,1,1],[0,0,1,0],[1,1,1,1],[0,0,1,0],[1,1,1,1]],
            '生': [[1,0,0,1],[1,1,1,1],[1,0,0,1],[1,1,1,1],[1,0,0,1]],
            '世': [[1,1,1,1],[0,0,1,0],[1,1,1,1],[0,0,1,0],[1,1,1,1]],
            '界': [[1,0,0,1],[1,1,1,1],[1,0,0,1],[1,1,1,1],[1,0,0,1]],
            '充': [[1,1,1,1],[0,0,1,0],[1,1,1,1],[0,0,1,0],[1,1,1,1]],
            '满': [[1,0,0,1],[1,1,1,1],[1,0,0,1],[1,1,1,1],[1,0,0,1]],
            '爱': [[1,1,1,1],[0,0,1,0],[1,1,1,1],[0,0,1,0],[1,1,1,1]],
            '你': [[1,0,0,1],[1,1,1,1],[1,0,0,1],[1,1,1,1],[1,0,0,1]],
            '是': [[1,1,1,1],[0,0,1,0],[1,1,1,1],[0,0,1,0],[1,1,1,1]],
            '最': [[1,0,0,1],[1,1,1,1],[1,0,0,1],[1,1,1,1],[1,0,0,1]],
            '棒': [[1,1,1,1],[0,0,1,0],[1,1,1,1],[0,0,1,0],[1,1,1,1]],
            '的': [[1,0,0,1],[1,1,1,1],[1,0,0,1],[1,1,1,1],[1,0,0,1]],
            '未': [[1,1,1,1],[0,0,1,0],[1,1,1,1],[0,0,1,0],[1,1,1,1]],
            '来': [[1,0,0,1],[1,1,1,1],[1,0,0,1],[1,1,1,1],[1,0,0,1]],
            '可': [[1,1,1,1],[0,0,1,0],[1,1,1,1],[0,0,1,0],[1,1,1,1]],
            '期': [[1,0,0,1],[1,1,1,1],[1,0,0,1],[1,1,1,1],[1,0,0,1]],
            '！': [[0,1,0],[0,1,0],[0,1,0],[0,0,0],[0,1,0]]
        };
        
        let currentX = startX;
        
        for (let i = 0; i < message.length; i++) {
            const letter = message[i];
            const pattern = letterPatterns[letter];
            
            if (pattern) {
                for (let row = 0; row < pattern.length; row++) {
                    for (let col = 0; col < pattern[row].length; col++) {
                        if (pattern[row][col] === 1) {
                            const gemX = currentX + col * 6;
                            const gemY = startY + row * 6;
                            
                            this.victoryGems.push({
                                x: gemX,
                                y: gemY,
                                width: 15,
                                height: 15,
                                color: '#FFD700',
                                collected: false,
                                sparkle: 0
                            });
                        }
                    }
                }
            }
            
            currentX += letterSpacing;
        }
    }
    
    drawScoreVictoryGems() {
        // 分数成就的特殊宝石效果
        const centerX = this.width / 2;
        const centerY = this.height / 2 + 100;
        const scoreText = '5251314';
        const fontSize = 24;
        const letterSpacing = 20;
        
        this.ctx.save();
        this.ctx.textAlign = 'center';
        this.ctx.font = `bold ${fontSize}px Arial`;
        
        // 绘制分数文字，每个数字用宝石效果
        scoreText.split('').forEach((digit, index) => {
            const x = centerX + (index - scoreText.length / 2) * letterSpacing;
            const y = centerY;
            
            // 脉冲效果
            const pulse = Math.sin(Date.now() * 0.003 + index * 0.5) * 0.3 + 1;
            const gemSize = 15 * pulse;
            
            // 渐变色彩
            const colors = ['#FFD700', '#FF69B4', '#87CEEB', '#32CD32', '#FF6347', '#9370DB', '#FF8C00'];
            const color = colors[index % colors.length];
            
            // 绘制宝石背景
            this.ctx.fillStyle = color;
            this.ctx.globalAlpha = 0.8;
            this.ctx.fillRect(x - gemSize/2, y - gemSize/2, gemSize, gemSize);
            
            // 绘制数字
            this.ctx.fillStyle = '#FFFFFF';
            this.ctx.globalAlpha = 1;
            this.ctx.fillText(digit, x, y + 5);
            
            // 绘制边框
            this.ctx.strokeStyle = '#FFFFFF';
            this.ctx.lineWidth = 2;
            this.ctx.strokeRect(x - gemSize/2, y - gemSize/2, gemSize, gemSize);
        });
        
        this.ctx.restore();
    }
    
    drawVictoryGems() {
        this.victoryGems.forEach(gem => {
            // 绘制胜利宝石
            this.ctx.fillStyle = gem.color;
            this.ctx.fillRect(gem.x, gem.y, gem.width, gem.height);
            
            // 绘制高光
            this.ctx.fillStyle = '#FFFFFF';
            this.ctx.fillRect(gem.x + 2, gem.y + 2, 4, 4);
            
            // 绘制闪烁效果
            gem.sparkle += 0.1;
            const sparkleAlpha = 0.5 + Math.sin(gem.sparkle) * 0.3;
            this.ctx.globalAlpha = sparkleAlpha;
            this.ctx.fillStyle = '#FFFFFF';
            this.ctx.fillRect(gem.x + gem.width/2 - 2, gem.y + gem.height/2 - 2, 4, 4);
            this.ctx.globalAlpha = 1;
        });
    }
    
    checkVictoryGemCollisions() {
        // 使用for循环避免死循环
        for (let i = this.victoryGems.length - 1; i >= 0; i--) {
            const gem = this.victoryGems[i];
            if (!gem.collected && this.checkCollision(this.dimoo, gem)) {
                gem.collected = true;
                this.victoryGems.splice(i, 1);
                this.score += 1000; // 胜利宝石给予高分
                console.log('🎉 收集胜利宝石！得分 +1000！');
            }
        }
    }
}

// 不在此自动 new DinoGame()：由 public/offline-dino/dino.html 在对应脚本 onload 后创建实例（与精简版 dino-game.js 自行初始化区分）。
