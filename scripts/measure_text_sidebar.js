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
    // Find text "Trang User" or dark grey text in the sidebar (x from 50 to 200, y from 300 to 600)
    // Dark grey text has r < 60, g < 60, b < 60
    // Let's sample points along the vertical strip at x = 120 (in CSS pixels, x = 240 in 2x image)
    const points = [];
    for (let y = 100; y < 1400; y += 10) {
      const i = (y * img.width + 240) * 4;
      const r = data[i];
      const g = data[i + 1];
      const b = data[i + 2];
      points.push({ yCss: y / 2, r, g, b });
    }
    return points;
  }, b64);

  // Filter dark points (text)
  const darkPoints = coords.filter(p => p.r < 80 && p.g < 80 && p.b < 80);
  console.log('Dark points along x=120:', darkPoints);
  await browser.close();
}

run().catch(console.error);

