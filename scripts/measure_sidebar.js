import puppeteer from 'puppeteer-core';
import fs from 'node:fs';

async function run() {
  const browser = await puppeteer.launch({
    executablePath: 'C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe',
    headless: true,
    args: ['--no-sandbox', '--disable-setuid-sandbox'],
  });

  const page = await browser.newPage();
  const b64 = fs.readFileSync('docs/screenshots/home_ocean_desktop.png').toString('base64');

  const info = await page.evaluate(async (dataUrl) => {
    const img = new Image();
    await new Promise((res) => {
      img.onload = res;
      img.src = 'data:image/png;base64,' + dataUrl;
    });

    const canvas = document.createElement('canvas');
    canvas.width = img.width;
    canvas.height = img.height;
    const ctx = canvas.getContext('2d');
    ctx.drawImage(img, 0, 0);

    const data = ctx.getImageData(0, 0, img.width, img.height).data;
    // In left sidebar (x from 0 to 500 in 2x image):
    // Find where the blue QL badge is Color(0xFF2563EB)
    const matches = [];
    for (let y = 0; y < img.height; y++) {
      for (let x = 0; x < 500; x++) {
        const i = (y * img.width + x) * 4;
        const r = data[i];
        const g = data[i + 1];
        const b = data[i + 2];
        if (r > 25 && r < 50 && g > 85 && g < 115 && b > 215 && b < 250) {
          matches.push({ x, y });
        }
      }
    }
    return {
      totalBluePixelsInSidebar: matches.length,
      sample: matches[Math.floor(matches.length / 2)],
    };
  }, b64);

  console.log('Sidebar blue items:', info);
  if (info.sample) {
    console.log('CSS position:', { x: info.sample.x / 2, y: info.sample.y / 2 });
  }
  await browser.close();
}

run().catch(console.error);

