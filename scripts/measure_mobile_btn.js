import puppeteer from 'puppeteer-core';
import fs from 'node:fs';

async function run() {
  const browser = await puppeteer.launch({
    executablePath: 'C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe',
    headless: true,
    args: ['--no-sandbox', '--disable-setuid-sandbox'],
  });

  const page = await browser.newPage();
  const b64 = fs.readFileSync('docs/screenshots/login_ocean_mobile.png').toString('base64');

  const coords = await page.evaluate(async (dataUrl) => {
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
    const matches = [];
    for (let y = Math.floor(img.height * 0.4); y < img.height * 0.9; y++) {
      for (let x = 0; x < img.width; x++) {
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
      width: img.width,
      height: img.height,
      count: matches.length,
      sample: matches[Math.floor(matches.length / 2)],
    };
  }, b64);

  console.log('Mobile Ocean Blue Button:', coords);
  if (coords.sample) {
    console.log('Mobile CSS click coordinate (divide by 2):', {
      x: coords.sample.x / 2,
      y: coords.sample.y / 2,
    });
  }
  await browser.close();
}

run().catch(console.error);

