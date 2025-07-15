<template>
    <canvas ref="canvas" class="bouncy-bubbles"></canvas>
  </template>
  
  <script>
  export default {
    name: 'BouncyBubbles',
    data() {
      return {
        canvas: null,
        ctx: null,
        balls: [],
        numBalls: 15,
        spring: 0.05,
        gravity: 0.03,
        friction: -0.9,
        animationFrameId: null,
        isActive: true
      }
    },
    mounted() {
      this.initCanvas()
      this.createBalls()
      this.animate()
      window.addEventListener('resize', this.handleResize)
    },
    activated() {
      // 当组件被 keep-alive 激活时调用
      if (!this.isActive) {
        this.isActive = true
        this.animate()
      }
    },
    deactivated() {
      // 当组件被 keep-alive 停用时调用
      this.isActive = false
      if (this.animationFrameId) {
        cancelAnimationFrame(this.animationFrameId)
        this.animationFrameId = null
      }
    },
    beforeUnmount() {
      this.isActive = false
      window.removeEventListener('resize', this.handleResize)
      if (this.animationFrameId) {
        cancelAnimationFrame(this.animationFrameId)
        this.animationFrameId = null
      }
    },
    methods: {
      initCanvas() {
        this.canvas = this.$refs.canvas
        this.ctx = this.canvas.getContext('2d')
        this.handleResize()
      },
      handleResize() {
        this.canvas.width = window.innerWidth
        this.canvas.height = window.innerHeight
      },
      createBalls() {
        this.balls = []
        for (let i = 0; i < this.numBalls; i++) {
          const isLightBlue = i % 2 === 0 // 偶数索引的球是浅蓝色
          this.balls.push(new Ball(
            Math.random() * this.canvas.width,
            Math.random() * this.canvas.height,
            Math.random() * 40 + 30,
            i,
            this.balls,
            isLightBlue
          ))
        }
      },
      animate() {
        if (!this.isActive) return

        this.ctx.fillStyle = 'rgba(255, 255, 255, 0.5)'
        this.ctx.fillRect(0, 0, this.canvas.width, this.canvas.height)
  
        for (const ball of this.balls) {
          ball.collide()
          ball.move()
          ball.display(this.ctx)
        }
  
        this.animationFrameId = requestAnimationFrame(this.animate)
      }
    }
  }
  
  class Ball {
    constructor(x, y, diameter, id, others, isLightBlue) {
      this.x = x
      this.y = y
      this.diameter = diameter
      this.id = id
      this.others = others
      this.vx = 0
      this.vy = 0
      this.isLightBlue = isLightBlue
    }
  
    collide() {
      for (let i = this.id + 1; i < this.others.length; i++) {
        const dx = this.others[i].x - this.x
        const dy = this.others[i].y - this.y
        const distance = Math.sqrt(dx * dx + dy * dy)
        const minDist = this.others[i].diameter / 2 + this.diameter / 2
  
        if (distance < minDist) {
          const angle = Math.atan2(dy, dx)
          const targetX = this.x + Math.cos(angle) * minDist
          const targetY = this.y + Math.sin(angle) * minDist
          const ax = (targetX - this.others[i].x) * 0.05
          const ay = (targetY - this.others[i].y) * 0.05
          this.vx -= ax
          this.vy -= ay
          this.others[i].vx += ax
          this.others[i].vy += ay
        }
      }
    }
  
    move() {
      this.vy += 0.03
      this.x += this.vx
      this.y += this.vy
  
      if (this.x + this.diameter / 2 > window.innerWidth) {
        this.x = window.innerWidth - this.diameter / 2
        this.vx *= -0.9
      } else if (this.x - this.diameter / 2 < 0) {
        this.x = this.diameter / 2
        this.vx *= -0.9
      }
  
      if (this.y + this.diameter / 2 > window.innerHeight) {
        this.y = window.innerHeight - this.diameter / 2
        this.vy *= -0.9
      } else if (this.y - this.diameter / 2 < 0) {
        this.y = this.diameter / 2
        this.vy *= -0.9
      }
    }
  
    display(ctx) {
      ctx.beginPath()
      ctx.arc(this.x, this.y, this.diameter / 2, 0, Math.PI * 2)
      ctx.fillStyle = this.isLightBlue ? 'rgba(100, 181, 246, 0.8)' : 'rgba(25, 118, 210, 0.8)'
      ctx.fill()
    }
  }
  </script>
  
  <style scoped>
  .bouncy-bubbles {
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    z-index: 0;
    pointer-events: none;
  }
  </style> 