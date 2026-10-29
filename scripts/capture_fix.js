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

  // 1. ai-draft.png
  console.log('Capturing ai-draft.png...');
  await page.mouse.click(206, 850); // AI tab
  await sleep(1500);
  console.log('Clicking "Tạo kế hoạch an toàn" at (206, 470)...');
  await page.mouse.click(206, 470);
  await sleep(5000);
  await page.screenshot({ path: path.join(SCREENSHOT_DIR, 'ai-draft.png') });

  // 2. quest-create.png
  console.log('Capturing quest-create.png...');
  await page.goto('http://localhost:8080/#/app', { waitUntil: 'networkidle0' });
  await sleep(1500);
  await page.mouse.click(123, 850); // Quests tab
  await sleep(1500);
  console.log('Clicking FAB at (330, 764)...');
  await page.mouse.click(330, 764);
  await sleep(2000);
  await page.screenshot({ path: path.join(SCREENSHOT_DIR, 'quest-create.png') });

  // 3. safety-center.png
  console.log('Capturing safety-center.png...');
  await page.goto('http://localhost:8080/#/app', { waitUntil: 'networkidle0' });
  await sleep(1500);
  await page.mouse.click(370, 850); // Profile tab
  await sleep(1500);
  console.log('Clicking Safety center at (200, 715)...');
  await page.mouse.click(200, 715);
  await sleep(2000);
  await page.screenshot({ path: path.join(SCREENSHOT_DIR, 'safety-center.png') });

  // 4. profile-dark.png
  console.log('Capturing profile-dark.png...');
  await page.goto('http://localhost:8080/#/app', { waitUntil: 'networkidle0' });
  await sleep(1500);
  await page.mouse.click(370, 850); // Profile tab
  await sleep(1500);
  console.log('Clicking Dark mode switch at (345, 340)...');
  await page.mouse.click(345, 340);
  await sleep(2000);
  await page.screenshot({ path: path.join(SCREENSHOT_DIR, 'profile-dark.png') });

  await browser.close();
  console.log('Done fix!');
}

run().catch((e) => {
  console.error(e);
  process.exit(1);
});

