import puppeteer from 'puppeteer-core';
import fs from 'node:fs';

async function measureFile(file, filterFn) {
  const browser = await puppeteer.launch({
    executablePath: 'C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe',
    headless: true,
    args: ['--no-sandbox', '--disable-setuid-sandbox'],
  });

  const page = await browser.newPage();
  const b64 = fs.readFileSync(file).toString('base64');

  const coords = await page.evaluate(async (dataUrl, filterBody) => {
    const fn = new Function('r', 'g', 'b', filterBody);
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
    for (let y = 0; y < img.height; y++) {
      for (let x = 0; x < img.width; x++) {
        const i = (y * img.width + x) * 4;
        if (fn(data[i], data[i + 1], data[i + 2])) {
          matches.push({ x, y });
        }
      }
    }
    if (!matches.length) return null;
    return {
      first: matches[0],
      last: matches[matches.length - 1],
      center: {
        x: (matches[0].x + matches[matches.length - 1].x) / 4,
        y: (matches[0].y + matches[matches.length - 1].y) / 4,
      },
    };
  }, b64, filterFn);

  await browser.close();
  return coords;
}

async function run() {
  // 1. FAB in quests.png: light purple FAB background (r ~ 220-240, g ~ 220-240, b ~ 255) at bottom right
  const fab = await measureFile('docs/screenshots/quests.png', `
    return x > 400 && y > 1400 && r > 200 && r < 245 && g > 200 && g < 245 && b > 235;
  `);
  console.log('FAB CSS center:', fab?.center);

  // 2. Dark mode switch in profile-light.png: grey/blue pill at y around 600-800, x around 600-800
  const toggle = await measureFile('docs/screenshots/profile-light.png', `
    return x > 600 && y > 550 && y < 800 && r > 100 && r < 200 && g > 100 && g < 200 && b > 100 && b < 200;
  `);
  console.log('Toggle CSS center:', toggle?.center);
}

run().catch(console.error);

