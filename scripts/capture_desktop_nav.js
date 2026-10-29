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
  console.log('Logging in...');
  await page.mouse.click(705, 434);
  await sleep(3500);

  // Click User Profile at (120, 420)
  console.log('Clicking Trang User at (120, 420)...');
  await page.mouse.click(120, 420);
  await sleep(2500);
  await page.screenshot({ path: path.join(SCREENSHOT_DIR, 'profile_ocean_desktop.png') });
  console.log('Saved profile_ocean_desktop.png');

  // Click Quản trị Admin at (120, 485)
  console.log('Clicking Quản trị Admin at (120, 485)...');
  await page.mouse.click(120, 485);
  await sleep(2500);
  await page.screenshot({ path: path.join(SCREENSHOT_DIR, 'admin_ocean_desktop.png') });
  console.log('Saved admin_ocean_desktop.png');

  // On Admin page, click Tab 2: "Quản lý Người dùng" (x: 597, y: 195)
  console.log('Clicking Quản lý Người dùng tab on Admin page...');
  await page.mouse.click(597, 195);
  await sleep(2000);
  await page.screenshot({ path: path.join(SCREENSHOT_DIR, 'admin_users_desktop.png') });
  console.log('Saved admin_users_desktop.png');

  await browser.close();
  console.log('Finished capturing desktop screens!');
}

run().catch(console.error);

