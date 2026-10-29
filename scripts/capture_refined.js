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

  // Login
  await page.goto('http://localhost:8080/#/login', { waitUntil: 'networkidle0' });
  await sleep(1500);
  await page.mouse.click(206, 565);
  await sleep(2500);

  // 1. quest-create.png
  console.log('Capturing quest-create.png...');
  await page.mouse.click(123, 850); // Quest tab
  await sleep(1500);
  await page.mouse.click(300, 856); // FAB Quest mới
  await sleep(1500);
  await page.screenshot({ path: path.join(SCREENSHOT_DIR, 'quest-create.png') });
  await page.mouse.click(206, 50); // Close sheet
  await sleep(1000);

  // 2. quest-complete.png
  console.log('Capturing quest-complete.png...');
  await page.mouse.click(200, 220); // Quest card
  await sleep(1500);
  // Toggle step 1 at (370, 786)
  await page.mouse.click(370, 786);
  await sleep(1000);
  await page.screenshot({ path: path.join(SCREENSHOT_DIR, 'quest-complete.png') });
  await page.mouse.click(206, 50); // Close sheet
  await sleep(1000);

  // 3. ai-draft.png
  console.log('Capturing ai-draft.png...');
  await page.mouse.click(206, 850); // AI tab
  await sleep(1500);
  // Click in textfield
  await page.mouse.click(206, 280);
  await page.keyboard.type('Ôn thi môn Lập trình thiết bị di động trong 7 ngày');
  await sleep(500);
  // Click "Tạo kế hoạch an toàn" at (206, 528)
  console.log('Clicking generate AI at (206, 528)...');
  await page.mouse.click(206, 528);
  await sleep(5000);
  await page.screenshot({ path: path.join(SCREENSHOT_DIR, 'ai-draft.png') });

  // 4. safety-center.png
  console.log('Capturing safety-center.png...');
  await page.mouse.click(370, 850); // Profile tab
  await sleep(1500);
  // Click "Trung tâm an toàn" around (200, 715)
  await page.mouse.click(200, 715);
  await sleep(1500);
  await page.screenshot({ path: path.join(SCREENSHOT_DIR, 'safety-center.png') });
  await page.mouse.click(206, 830); // "Đã hiểu" button
  await sleep(1000);

  // 5. profile-dark.png
  console.log('Capturing profile-dark.png...');
  // Click switch "Giao diện tối" at (340, 340)
  await page.mouse.click(340, 340);
  await sleep(2000);
  await page.screenshot({ path: path.join(SCREENSHOT_DIR, 'profile-dark.png') });

  await browser.close();
  console.log('Refined captures done!');
}

run().catch((e) => {
  console.error(e);
  process.exit(1);
});

