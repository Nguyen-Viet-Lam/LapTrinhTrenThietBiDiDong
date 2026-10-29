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

  // Login
  console.log('Logging in...');
  await page.mouse.click(705, 434);
  await sleep(3500);

  // Click Quản trị Admin in sidebar (x: 120, y: 435)
  console.log('Clicking Quản trị Admin at (120, 435)...');
  await page.mouse.click(120, 435);
  await sleep(2500);
  await page.screenshot({ path: path.join(SCREENSHOT_DIR, 'admin_ocean_desktop.png') });
  console.log('Saved admin_ocean_desktop.png');

  // Click Tab 2: "Quản lý Người dùng" at (765, 150)
  console.log('Clicking Tab 2 at (765, 150)...');
  await page.mouse.click(765, 150);
  await sleep(2000);
  await page.screenshot({ path: path.join(SCREENSHOT_DIR, 'admin_users_desktop.png') });
  console.log('Saved admin_users_desktop.png');

  // Click Tab 3: "Báo cáo & An toàn" at (1108, 150)
  console.log('Clicking Tab 3 at (1108, 150)...');
  await page.mouse.click(1108, 150);
  await sleep(2000);
  await page.screenshot({ path: path.join(SCREENSHOT_DIR, 'admin_reports_desktop.png') });
  console.log('Saved admin_reports_desktop.png');

  await browser.close();
  console.log('Done!');
}

run().catch(console.error);

