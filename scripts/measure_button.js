import puppeteer from 'puppeteer-core';
import fs from 'node:fs';

async function run() {
  const browser = await puppeteer.launch({
    executablePath: 'C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe',
    headless: true,
    args: ['--no-sandbox', '--disable-setuid-sandbox'],
  });

  const page = await browser.newPage();
  const b64 = fs.readFileSync('docs/screenshots/novara_login_desktop.png').toString('base64');

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
    
    // Look at the chip area: y between 1100 and 1300, x between 1200 and 2200
    // Chip "Admin (Lãm)" is blue: (r: 2, g: 132, b: 199) -> Color(0xFF0284C7)
    // Other chips are white with border
    const blueChipMatches = [];
    for (let y = 1100; y < 1300; y++) {
      for (let x = 1200; x < 2200; x++) {
        const i = (y * img.width + x) * 4;
        const r = data[i], g = data[i+1], b = data[i+2];
        if (r >= 0 && r <= 10 && g >= 120 && g <= 145 && b >= 185 && b <= 215) {
          blueChipMatches.push({ x, y });
        }
      }
    }

    return {
      blueChipCount: blueChipMatches.length,
      blueChipMinX: Math.min(...blueChipMatches.map(m => m.x)),
      blueChipMaxX: Math.max(...blueChipMatches.map(m => m.x)),
      blueChipMinY: Math.min(...blueChipMatches.map(m => m.y)),
      blueChipMaxY: Math.max(...blueChipMatches.map(m => m.y)),
    };
  }, b64);

  console.log('Blue Admin Chip in image:', coords);
  const adminChipCenter = {
    x: (coords.blueChipMinX + coords.blueChipMaxX) / 4,
    y: (coords.blueChipMinY + coords.blueChipMaxY) / 4,
  };
  console.log('Admin Chip CSS center:', adminChipCenter);
  // User (Demo) chip is immediately to the right of Admin chip!
  // Width of each chip is approx (coords.blueChipMaxX - coords.blueChipMinX) / 2
  const chipW = (coords.blueChipMaxX - coords.blueChipMinX) / 2;
  console.log('User Demo Chip estimated center:', {
    x: adminChipCenter.x + chipW + 15,
    y: adminChipCenter.y,
  });

  await browser.close();
}

run().catch(console.error);
