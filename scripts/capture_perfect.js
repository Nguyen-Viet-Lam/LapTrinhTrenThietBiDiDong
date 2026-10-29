import puppeteer from 'puppeteer-core';
import fs from 'node:fs';
import path from 'node:path';

const SCREENSHOT_DIR = path.resolve('docs/screenshots');
const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

async function run() {
  const browser = await puppeteer.launch({
    executablePath: 'C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe',
    headless: true,
    args: ['--no-sandbox', '--disable-setuid-sandbox'],
    defaultViewport: { width: 412, height: 892, deviceScaleFactor: 2 },
  });

  const page = await browser.newPage();

  // 1. Login to Minh Anh
  console.log('Logging in...');
  await page.goto('http://localhost:8080/#/login', { waitUntil: 'networkidle0' });
  await sleep(1500);
  await page.mouse.click(206, 565);
  await sleep(2500);

  // 2. quest-create.png (click "Tạo" button on Home screen at 375, 478)
  console.log('Capturing quest-create.png...');
  await page.mouse.click(375, 478);
  await sleep(1500);
  await page.screenshot({ path: path.join(SCREENSHOT_DIR, 'quest-create.png') });

  // 3. Close sheet by reloading to app
  await page.goto('http://localhost:8080/#/app', { waitUntil: 'networkidle0' });
  await sleep(1500);

  // 4. quest-complete.png
  console.log('Capturing quest-complete.png...');
  await page.mouse.click(123, 850); // Quests tab
  await sleep(1200);
  await page.mouse.click(200, 220); // Quest card
  await sleep(1500);
  // Click "Hoàn thành nhiệm vụ" button inside sheet
  console.log('Clicking complete quest...');
  await page.mouse.click(206, 955);
  await sleep(1200);
  await page.screenshot({ path: path.join(SCREENSHOT_DIR, 'quest-complete.png') });

  // 5. ai-draft.png
  console.log('Capturing ai-draft.png...');
  await page.goto('http://localhost:8080/#/app', { waitUntil: 'networkidle0' });
  await sleep(1500);
  await page.mouse.click(206, 850); // AI tab
  await sleep(1200);
  console.log('Clicking "Tạo kế hoạch an toàn" at (206, 528)...');
  await page.mouse.click(206, 528);
  await sleep(4000);
  await page.screenshot({ path: path.join(SCREENSHOT_DIR, 'ai-draft.png') });

  // 6. safety-center.png
  console.log('Capturing safety-center.png...');
  await page.goto('http://localhost:8080/#/app', { waitUntil: 'networkidle0' });
  await sleep(1500);
  await page.mouse.click(370, 850); // Profile tab
  await sleep(1200);
  // Click "Trung tâm an toàn" around (200, 710)
  await page.mouse.click(200, 710);
  await sleep(1500);
  await page.screenshot({ path: path.join(SCREENSHOT_DIR, 'safety-center.png') });

  // 7. profile-dark.png
  console.log('Capturing profile-dark.png...');
  // Get token from localStorage to call PATCH /api/me
  const token = await page.evaluate(() => localStorage.getItem('flutter.lifequest_jwt_token'));
  if (token) {
    await fetch('http://localhost:3000/api/me', {
      method: 'PATCH',
      headers: {
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ darkMode: true }),
    });
  }
  await page.goto('http://localhost:8080/#/app', { waitUntil: 'networkidle0' });
  await sleep(1500);
  await page.mouse.click(370, 850); // Profile tab in dark mode
  await sleep(1200);
  await page.screenshot({ path: path.join(SCREENSHOT_DIR, 'profile-dark.png') });

  // Restore light mode
  if (token) {
    await fetch('http://localhost:3000/api/me', {
      method: 'PATCH',
      headers: {
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ darkMode: false }),
    });
  }

  await browser.close();
  console.log('Captures completed!');
}

run().catch((e) => {
  console.error(e);
  process.exit(1);
});

