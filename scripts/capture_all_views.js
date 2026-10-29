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
  });

  const page = await browser.newPage();
  await page.setViewport({ width: 1280, height: 800, deviceScaleFactor: 2 });
  await page.goto('http://localhost:8080/#/login', { waitUntil: 'networkidle0' });
  await sleep(1500);

  // 1. Click login
  console.log('Logging in...');
  await page.mouse.click(705, 434);
  await sleep(3500);

  // 2. Click User Profile at (120, 385)
  console.log('Clicking Trang User at (120, 385)...');
  await page.mouse.click(120, 385);
  await sleep(2500);
  await page.screenshot({ path: path.join(SCREENSHOT_DIR, 'profile_ocean_desktop.png') });
  console.log('Saved profile_ocean_desktop.png');

  // 3. Click Quản trị Admin at (120, 455)
  console.log('Clicking Quản trị Admin at (120, 455)...');
  await page.mouse.click(120, 455);
  await sleep(2500);
  await page.screenshot({ path: path.join(SCREENSHOT_DIR, 'admin_ocean_desktop.png') });
  console.log('Saved admin_ocean_desktop.png');

  // 4. Click Tab 2: "Quản lý Người dùng" at (597, 155)
  console.log('Clicking Quản lý Người dùng tab at (597, 155)...');
  await page.mouse.click(597, 155);
  await sleep(2000);
  await page.screenshot({ path: path.join(SCREENSHOT_DIR, 'admin_users_desktop.png') });
  console.log('Saved admin_users_desktop.png');

  // 5. Click Tab 3: "Báo cáo & An toàn" at (865, 155)
  console.log('Clicking Báo cáo & An toàn tab at (865, 155)...');
  await page.mouse.click(865, 155);
  await sleep(2000);
  await page.screenshot({ path: path.join(SCREENSHOT_DIR, 'admin_reports_desktop.png') });
  console.log('Saved admin_reports_desktop.png');

  // 6. Mobile Profile & Drawer
  const mobile = await browser.newPage();
  await mobile.setViewport({ width: 412, height: 892, deviceScaleFactor: 2 });
  await mobile.goto('http://localhost:8080/#/login', { waitUntil: 'networkidle0' });
  await sleep(1500);
  await mobile.mouse.click(206, 592);
  await sleep(3500);

  // Close any open bottom sheet by clicking near top
  await mobile.mouse.click(206, 120);
  await sleep(1000);

  // Open Drawer by clicking hamburger icon at (28, 45)
  console.log('Opening mobile Drawer...');
  await mobile.mouse.click(28, 45);
  await sleep(1500);
  await mobile.screenshot({ path: path.join(SCREENSHOT_DIR, 'mobile_drawer.png') });
  console.log('Saved mobile_drawer.png');

  await browser.close();
  console.log('All views successfully captured!');
}

run().catch(console.error);

