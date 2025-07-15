# 📸 图表和网页转换为图片的完整指南

## 🚀 快速转换方法

### 1. Mermaid图表转换

#### 在线转换（最简单）
1. 访问 [Mermaid Live Editor](https://mermaid.live/)
2. 粘贴 `architecture-diagram.mmd` 文件内容
3. 点击"Actions" → "Export as PNG/SVG/PDF"

#### 命令行转换（已演示）
```bash
# 安装工具
npm install -g @mermaid-js/mermaid-cli

# 基础转换
mmdc -i architecture-diagram.mmd -o architecture-diagram.png

# 高质量转换
mmdc -i architecture-diagram.mmd -o architecture-diagram.png -w 2000 -H 1500 -b white
```

### 2. HTML网页转换

#### 使用Puppeteer（需要Node.js）
```bash
# 安装依赖
npm install puppeteer

# 运行转换脚本
node convert-to-image.js
```

#### 浏览器截图（最简单）
1. 打开 `spring-boot-architecture.html`
2. 按 F12 打开开发者工具
3. 按 Ctrl+Shift+P（Mac: Cmd+Shift+P）
4. 输入 "screenshot"
5. 选择 "Capture full size screenshot"

### 3. SVG文件转换

#### 使用ImageMagick
```bash
# 安装ImageMagick
brew install imagemagick  # macOS
sudo apt-get install imagemagick  # Ubuntu

# 转换命令
convert input.svg output.png
convert input.svg -density 300 output.png  # 高分辨率
```

#### 使用Inkscape
```bash
# 安装Inkscape
brew install inkscape  # macOS

# 转换命令
inkscape --export-type=png --export-filename=output.png input.svg
inkscape --export-type=png --export-dpi=300 --export-filename=output.png input.svg
```

### 4. 在线转换工具

#### SVG转换
- [CloudConvert](https://cloudconvert.com/svg-to-png)
- [Convertio](https://convertio.co/svg-png/)
- [Online-Convert](https://www.online-convert.com/)

#### HTML转图片
- [HTML/CSS to Image API](https://htmlcsstoimage.com/)
- [URLBox](https://urlbox.io/)
- [Screenshot API](https://www.screenshotapi.net/)

## 📊 转换质量设置

### 高质量PNG设置
```bash
# Mermaid CLI
mmdc -i diagram.mmd -o diagram.png -w 2000 -H 1500 -b white

# Puppeteer
deviceScaleFactor: 2  // 2倍分辨率
type: 'png'
quality: 100
```

### PDF输出（矢量格式）
```bash
# Mermaid生成PDF
mmdc -i diagram.mmd -o diagram.pdf

# 浏览器打印为PDF
# 打开HTML → Ctrl+P → 选择"另存为PDF"
```

## 🎨 推荐配置

### 用于演示的配置
- 格式：PNG
- 分辨率：1920x1080 或更高
- 背景：白色
- DPI：300

### 用于文档的配置
- 格式：PNG或PDF
- 分辨率：适中（1200x800）
- 背景：透明或白色
- 压缩：适度压缩

## ⚡ 当前项目文件状态

✅ 已生成文件：
- `architecture-diagram.mmd` - Mermaid源文件
- `architecture-diagram.png` - 架构图PNG (49KB)
- `spring-boot-architecture.html` - 完整网页文档
- `convert-to-image.js` - HTML转图片脚本

📝 推荐操作：
1. 查看生成的 `architecture-diagram.png`
2. 使用浏览器截图保存HTML网页
3. 根据需要调整图片质量和尺寸 