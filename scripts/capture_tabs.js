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

  // Click login
  await page.mouse.click(705, 434);
  await sleep(3500);

  // Let's capture User Profile by clicking at y = 455
  console.log('Clicking Trang User at (120, 455)...');
  await page.mouse.click(120, 455);
  await sleep(2000);
  await page.screenshot({ path: path.join(SCREENSHOT_DIR, 'profile_ocean_desktop.png') });
  console.log('Saved profile_ocean_desktop.png');

  // Let's click Quản trị Admin at y = 530
  console.log('Clicking Quản trị Admin at (120, 530)...');
  await page.mouse.click(120, 530);
  await sleep(2000);
  await page.screenshot({ path: path.join(SCREENSHOT_DIR, 'admin_ocean_desktop.png') });
  console.log('Saved admin_ocean_desktop.png');

  // On Admin page, let's click Tab 2: "Quản lý Người dùng" (x: 600, y: 195)
  console.log('Clicking Quản lý Người dùng tab on Admin page...');
  await page.mouse.click(600, 195);
  await sleep(1500);
  await page.screenshot({ path: path.join(SCREENSHOT_DIR, 'admin_users_desktop.png') });
  console.log('Saved admin_users_desktop.png');

  // Also Mobile: Click mobile bottom navigation User tab (x: 370, y: 855)
  const mobile = await browser.newPage();
  await mobile.setViewport({ width: 412, height: 892, deviceScaleFactor: 2 });
  await mobile.goto('http://localhost:8080/#/login', { waitUntil: 'networkidle0' });
  await sleep(1500);
  await mobile.mouse.click(206, 592);
  await sleep(3500);

  // Mobile User Tab (index 4 on bottom nav)
  console.log('Clicking User tab on mobile bottom bar...');
  await mobile.mouse.click(370, 855);
  await sleep(2000);
  await mobile.screenshot({ path: path.join(SCREENSHOT_DIR, 'profile_ocean_mobile.png') });
  console.log('Saved profile_ocean_mobile.png');

  await browser.close();
  console.log('All done!');
}

run().catch(console.error);

