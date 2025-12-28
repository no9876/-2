// 雪花特效
class SnowEffect {
    constructor() {
        this.canvas = null;
        this.ctx = null;
        this.snowflakes = [];
        this.animationId = null;
        this.init();
    }

    init() {
        // 创建canvas元素
        this.canvas = document.createElement('canvas');
        this.canvas.id = 'snow-canvas';
        this.canvas.style.position = 'fixed';
        this.canvas.style.top = '0';
        this.canvas.style.left = '0';
        this.canvas.style.width = '100%';
        this.canvas.style.height = '100%';
        this.canvas.style.pointerEvents = 'none';
        this.canvas.style.zIndex = '9999';
        document.body.appendChild(this.canvas);

        this.ctx = this.canvas.getContext('2d');
        this.resize();
        this.createSnowflakes();

        // 监听窗口大小变化
        window.addEventListener('resize', () => this.resize());
        
        // 开始动画
        this.animate();
    }

    resize() {
        this.canvas.width = window.innerWidth;
        this.canvas.height = window.innerHeight;
    }

    createSnowflakes() {
        const count = Math.floor((this.canvas.width * this.canvas.height) / 15000);
        this.snowflakes = [];

        for (let i = 0; i < count; i++) {
            this.snowflakes.push({
                x: Math.random() * this.canvas.width,
                y: Math.random() * this.canvas.height,
                radius: Math.random() * 3 + 1,
                speed: Math.random() * 2 + 0.5,
                opacity: Math.random() * 0.5 + 0.3,
                swing: Math.random() * 0.5 + 0.2,
                swingOffset: Math.random() * Math.PI * 2
            });
        }
    }

    animate() {
        this.ctx.clearRect(0, 0, this.canvas.width, this.canvas.height);

        this.snowflakes.forEach((flake, index) => {
            // 更新位置
            flake.y += flake.speed;
            flake.x += Math.sin(flake.swingOffset + flake.y * 0.01) * flake.swing;

            // 如果雪花飘出屏幕底部，重新从顶部开始
            if (flake.y > this.canvas.height) {
                flake.y = -10;
                flake.x = Math.random() * this.canvas.width;
            }

            // 如果雪花飘出屏幕左右，重新定位
            if (flake.x < -10) {
                flake.x = this.canvas.width + 10;
            } else if (flake.x > this.canvas.width + 10) {
                flake.x = -10;
            }

            // 绘制雪花
            this.ctx.beginPath();
            this.ctx.arc(flake.x, flake.y, flake.radius, 0, Math.PI * 2);
            this.ctx.fillStyle = `rgba(255, 255, 255, ${flake.opacity})`;
            this.ctx.fill();

            // 添加雪花的光晕效果
            this.ctx.shadowBlur = 10;
            this.ctx.shadowColor = 'rgba(255, 255, 255, 0.5)';
            this.ctx.beginPath();
            this.ctx.arc(flake.x, flake.y, flake.radius * 0.5, 0, Math.PI * 2);
            this.ctx.fill();
            this.ctx.shadowBlur = 0;
        });

        this.animationId = requestAnimationFrame(() => this.animate());
    }

    destroy() {
        if (this.animationId) {
            cancelAnimationFrame(this.animationId);
        }
        if (this.canvas && this.canvas.parentNode) {
            this.canvas.parentNode.removeChild(this.canvas);
        }
    }
}

// 页面加载完成后初始化雪花特效
document.addEventListener('DOMContentLoaded', function() {
    window.snowEffect = new SnowEffect();
});

