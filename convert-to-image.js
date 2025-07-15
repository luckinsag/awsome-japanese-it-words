const puppeteer = require('puppeteer');
const path = require('path');

async function convertHTMLToImage() {
    // 启动浏览器
    const browser = await puppeteer.launch();
    const page = await browser.newPage();
    
    // 设置视口大小
    await page.setViewport({
        width: 1200,
        height: 800,
        deviceScaleFactor: 2 // 高分辨率
    });
    
    // 加载HTML文件
    const htmlPath = path.join(__dirname, 'spring-boot-architecture.html');
    await page.goto(`file://${htmlPath}`, { waitUntil: 'networkidle0' });
    
    // 等待页面完全加载
    await page.waitForTimeout(2000);
    
    // 截图整个页面
    await page.screenshot({
        path: 'spring-boot-architecture-full.png',
        fullPage: true,
        type: 'png'
    });
    
    // 截图特定区域（如果需要）
    const element = await page.$('.container');
    if (element) {
        await element.screenshot({
            path: 'spring-boot-architecture-container.png',
            type: 'png'
        });
    }
    
    await browser.close();
    console.log('HTML转换为图片完成！');
}

// 运行转换
convertHTMLToImage().catch(console.error); 