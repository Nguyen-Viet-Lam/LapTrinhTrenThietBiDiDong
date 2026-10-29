import puppeteer from 'puppeteer-core';
import fs from 'node:fs';
import path from 'node:path';

const SCREENSHOT_DIR = path.resolve('docs/screenshots');
const sleep = (ms) => new Promise(r => setTimeout(r, ms));

async function clickAt(page, x, y) {
  await page.mouse.move(x, y);
  await sleep(60);
  await page.mouse.down();
  await sleep(120);
  await page.mouse.up();
  await sleep(300);
}

async function run() {
  const browser = await puppeteer.launch({
    executablePath: 'C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe',
    headless: true,
    args: ['--no-sandbox', '--disable-setuid-sandbox'],
  });

  console.log('Creating fresh incognito context for Admin (Lãm)...');
  const context = await browser.createBrowserContext();
  const page = await context.newPage();
  await page.setViewport({ width: 1280, height: 950, deviceScaleFactor: 2 });
  await page.goto('http://localhost:8080/#/login', { waitUntil: 'networkidle0' });
  await sleep(2500);

  // Click Admin (Lãm) chip at (702, 571) just to be 100% sure
  console.log('Clicking Admin (Lãm) chip at (702, 571)...');
  await clickAt(page, 702, 571);
  await sleep(600);

  // Click Login button at (875, 433)
  console.log('Clicking Đăng nhập button at (875, 433)...');
  await clickAt(page, 875, 433);
  await sleep(4000);

  console.log('Admin URL:', page.url());
  await page.screenshot({ path: path.join(SCREENSHOT_DIR, 'novara_admin_ocean_dashboard.png') });
  console.log('Saved novara_admin_ocean_dashboard.png');

  // Let's also click Admin tab in sidebar (x: 120, y: 475)
  console.log('Clicking Admin tab in sidebar...');
  await clickAt(page, 120, 475);
  await sleep(2500);
  await page.screenshot({ path: path.join(SCREENSHOT_DIR, 'novara_admin_ocean_management.png') });
  console.log('Saved novara_admin_ocean_management.png');

  await browser.close();
  console.log('ADMIN INCOGNITO CAPTURE COMPLETE!');
}

run().catch(console.error);
