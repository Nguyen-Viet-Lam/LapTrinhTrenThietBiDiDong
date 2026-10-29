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

  // 1. Desktop Experience
  const page = await browser.newPage();
  await page.setViewport({ width: 1280, height: 800, deviceScaleFactor: 2 });
  
  console.log('Navigating to login...');
  await page.goto('http://localhost:8080/#/login', { waitUntil: 'networkidle0' });
  await sleep(1500);

  console.log('Clicking Đăng nhập button at (705, 434)...');
  await page.mouse.click(705, 434);
  await sleep(3500);

  console.log('Capturing home_ocean_desktop.png...');
  await page.screenshot({ path: path.join(SCREENSHOT_DIR, 'home_ocean_desktop.png') });

  console.log('Clicking Quản trị (Admin) at (130, 435)...');
  await page.mouse.click(130, 435);
  await sleep(2500);
  await page.screenshot({ path: path.join(SCREENSHOT_DIR, 'admin_ocean_desktop.png') });

  console.log('Clicking Trang User at (130, 390)...');
  await page.mouse.click(130, 390);
  await sleep(2000);
  await page.screenshot({ path: path.join(SCREENSHOT_DIR, 'profile_ocean_desktop.png') });

  // 2. Mobile Experience
  const mobile = await browser.newPage();
  await mobile.setViewport({ width: 412, height: 892, deviceScaleFactor: 2 });
  await mobile.goto('http://localhost:8080/#/login', { waitUntil: 'networkidle0' });
  await sleep(1500);

  console.log('Clicking mobile login button at (206, 592)...');
  await mobile.mouse.click(206, 592);
  await sleep(3500);

  console.log('Capturing home_ocean_mobile.png...');
  await mobile.screenshot({ path: path.join(SCREENSHOT_DIR, 'home_ocean_mobile.png') });

  console.log('Clicking hamburger menu at (28, 45)...');
  await mobile.mouse.click(28, 45);
  await sleep(1500);
  await mobile.screenshot({ path: path.join(SCREENSHOT_DIR, 'mobile_drawer.png') });

  await browser.close();
  console.log('Done!');
}

run().catch(console.error);

