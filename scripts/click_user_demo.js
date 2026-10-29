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
  await page.setViewport({ width: 1280, height: 950, deviceScaleFactor: 2 });
  await page.goto('http://localhost:8080/#/login', { waitUntil: 'networkidle0' });
  await sleep(2000);

  // 1. Click User (Demo) chip:
  // In right column, chips row is at y: 602, User Demo is second chip at x: 645
  console.log('Clicking User (Demo) chip...');
  await page.mouse.click(645, 602);
  await sleep(600);

  // 2. Click Login button at (865, 455)
  console.log('Clicking Đăng nhập button...');
  await page.mouse.click(865, 455);
  await sleep(4000);

  await page.screenshot({ path: path.join(SCREENSHOT_DIR, 'novara_user_home_live.png') });
  console.log('Saved novara_user_home_live.png');

  // Let's scroll down to capture the 5 Pillar cards & Metrics
  await page.evaluate(() => {
    window.scrollBy(0, 500);
  });
  await sleep(1500);
  await page.screenshot({ path: path.join(SCREENSHOT_DIR, 'novara_user_pillars_live.png') });
  console.log('Saved novara_user_pillars_live.png');

  // 3. Admin Login test
  console.log('Now testing Admin login...');
  const pageAdmin = await browser.newPage();
  await pageAdmin.setViewport({ width: 1280, height: 950, deviceScaleFactor: 2 });
  await pageAdmin.goto('http://localhost:8080/#/login', { waitUntil: 'networkidle0' });
  await sleep(2000);
  // Default is already lam@lifequest.vn, so just click Login button (865, 455)
  await pageAdmin.mouse.click(865, 455);
  await sleep(4000);
  await pageAdmin.screenshot({ path: path.join(SCREENSHOT_DIR, 'novara_admin_ocean_live.png') });
  console.log('Saved novara_admin_ocean_live.png');

  await browser.close();
  console.log('DONE!');
}

run().catch(console.error);
