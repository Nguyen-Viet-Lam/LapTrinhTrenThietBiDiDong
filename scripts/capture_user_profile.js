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

  // 2. Click User Profile at (120, 365)
  console.log('Clicking Trang User at (120, 365)...');
  await page.mouse.click(120, 365);
  await sleep(2500);
  await page.screenshot({ path: path.join(SCREENSHOT_DIR, 'profile_ocean_desktop.png') });
  console.log('Saved profile_ocean_desktop.png');

  await browser.close();
}

run().catch(console.error);
